#!/usr/bin/env bash
set -e

# ==============================================================================
# 1. CENTRAL COSTING SERVICE (Exact Dynamic RM & MB evaluation for all vendors)
# ==============================================================================
cat << 'SERVICE_EOF' > src/shared/costCalculationService.js
import { getActiveRmMapping, getActiveMbMapping } from './masterStore';

// Atomberg 38-Line Formula Calculation
export function calculateAtombergCost(p) {
  const rmBase = Number(p.rmBase ?? p.rmRate ?? 140.0);
  const rmIcc = rmBase * 0.01;
  const rmFreight = Number(p.rmFreight ?? 1.50);
  const rmLanded = rmBase + rmIcc + rmFreight;

  const mbBase = Number(p.mbBase ?? p.masterbatchRate ?? 254.0);
  const mbIcc = mbBase * 0.01;
  const mbFreight = Number(p.mbFreight ?? 2.00);
  const mbLanded = mbBase + mbIcc + mbFreight;

  const rawMbPct = Number(p.mbPct !== undefined ? p.mbPct : (p.masterbatchPct !== undefined ? p.masterbatchPct : 4.0));
  const mbPct = rawMbPct > 1 ? rawMbPct / 100 : rawMbPct;
  const rmCombRate = rmLanded * (1.0 - mbPct) + mbLanded * mbPct;

  const partWt = Number(p.partWt ?? p.netWeight ?? 37.0);
  const runnerWt = Number(p.runnerWt ?? p.runnerWeight ?? 1.0);
  const grossWt = partWt + runnerWt;

  const rmCost = (grossWt / 1000.0) * rmCombRate;
  const bopCost = Number(p.bopCost ?? 0.0);
  const rmBopCost = rmCost + bopCost;

  const tonnage = Number(p.tonnage ?? p.machineTonnage ?? 200.0);
  const shiftRate = 10.0 * tonnage;
  const cycleTime = Math.max(1, Number(p.cycleTime ?? p.cycleTimeApproved ?? 47.0));
  const efficiency = Number(p.efficiency ?? 0.90);
  const cavity = Math.max(1, Number(p.cavity ?? 2));

  const partsPerShift = (28800.0 / cycleTime) * efficiency * cavity;
  const processCost = partsPerShift > 0 ? (shiftRate / partsPerShift) : 0;

  const bopHandling = 0.03 * bopCost;
  const postOpCost = Number(p.postOpCost ?? 1.73);
  const totalProcessCost = processCost + bopHandling + postOpCost;

  const profitOh = (rmCost + totalProcessCost) * 0.12;
  const inprocessRejection = (rmBopCost + totalProcessCost) * 0.04;
  const runnerRecovery = -25.0 * (runnerWt / 1000.0);
  const icc = 0.0;
  const packingCost = Number(p.packingCost ?? 0.86);
  const transportCost = Number(p.transportCost ?? 0.62);
  const mouldMaint = 0.02 * totalProcessCost;

  const otherCost = profitOh + inprocessRejection + runnerRecovery + icc + packingCost + transportCost + mouldMaint;
  const finalLanded = rmBopCost + totalProcessCost + otherCost;

  return {
    rmBase, rmIcc, rmFreight, rmLanded,
    mbBase, mbIcc, mbFreight, mbLanded,
    mbPct, rmCombRate, partWt, runnerWt, grossWt,
    rmCost, bopCost, rmBopCost, tonnage, shiftRate,
    cycleTime, efficiency, cavity, partsPerShift,
    processCost, bopHandling, postOpCost, totalProcessCost,
    profitOh, inprocessRejection, runnerRecovery, icc,
    packingCost, transportCost, mouldMaint, otherCost,
    finalLanded, totalCost: finalLanded
  };
}

// Haier 18-Line Formula Calculation (Full dynamic MB Support)
export function calculateHaierCost(params) {
  const cavity = Math.max(1, Number(params.cavity) || 1);
  const netWeight = Number(params.netWeight ?? params.partWt) || 0;
  const runnerWeight = Number(params.runnerWeight ?? params.runnerWt) || 0;
  const rmRate = Number(params.rmRate ?? params.rmBase) || 130.00;
  const mbPct = Number(params.masterbatchPct ?? params.mbPct) || 0;
  const mbRate = Number(params.masterbatchRate ?? params.mbBase) || 0.00;
  const cycleTime = Math.max(1, Number(params.cycleTime ?? params.cycleTimeApproved) || 48);
  const machineTonnage = Number(params.machineTonnage ?? params.tonnage) || (netWeight > 300 ? 650 : 450);
  const shiftTariff = Number(params.shiftTariff || (machineTonnage >= 650 ? 5760 : (machineTonnage <= 200 ? 2000 : 4600)));

  const shotWeightPerPiece = ((netWeight * cavity) + runnerWeight) / cavity;
  const reconciliationWeight = shotWeightPerPiece * 1.01;

  const mbFraction = mbPct > 1 ? mbPct / 100 : mbPct;
  const pureRmFraction = Math.max(0, 1 - mbFraction);

  const rawMaterialCost = (reconciliationWeight / 1000) * rmRate * pureRmFraction;
  const masterbatchCost = (reconciliationWeight / 1000) * mbRate * mbFraction;
  const runnerCredit = (runnerWeight / cavity / 1000) * (rmRate * 0.25);
  const totalRmCost = (rawMaterialCost + masterbatchCost) - runnerCredit;

  const partsPerShift = ((28800 / cycleTime) * cavity) * 0.90;
  const conversionCost = partsPerShift > 0 ? (shiftTariff / partsPerShift) : 0;
  const totalCost = totalRmCost + conversionCost;

  return {
    cavity, netWeight, runnerWeight, shotWeightPerPiece, reconciliationWeight,
    rawMaterialCost, masterbatchCost, runnerCredit, totalRmCost,
    machineTonnage, shiftTariff, conversionCost, totalCost, finalLanded: totalCost
  };
}

// Master Unified Costing Dispatcher
export function calculatePieceCostUnified({ item, isBaseline = false, targetDate = null }) {
  const vendor = (item.vendor || 'Haier').trim();
  const isAtomberg = vendor.toLowerCase().includes('atomberg');
  const isCrisper = item.itemCode === '0060217978E';
  const params = item.parameters || {};

  const rmMapping = getActiveRmMapping(item.approvedRm || (isCrisper ? 'GPPS SC201LV' : 'ABS 300 Pre Colour'), vendor, targetDate);
  const mbMapping = getActiveMbMapping(vendor, targetDate);

  if (isAtomberg) {
    if (isBaseline) {
      return calculateAtombergCost({
        vendor: 'Atomberg',
        rmBase: Number(rmMapping.approvedPrice || item.approvedRmRate || 140.00),
        mbBase: Number(mbMapping.approvedMbPrice || item.masterbatchRate || 254.00),
        rmFreight: 1.50,
        mbFreight: 2.00,
        mbPct: Number(item.masterbatchPct ?? params.masterbatchPct ?? 4.0),
        partWt: Number(item.netWeight ?? params.netWeightApproved ?? 37.0),
        runnerWt: Number(item.runnerWeight ?? params.runnerWeight ?? 1.0),
        bopCost: Number(item.bopCost || params.bopCost || 0.0),
        tonnage: Number(item.machineTonnage ?? params.machineTonnage ?? 200.0),
        cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 47.0),
        efficiency: 0.90,
        cavity: Number(item.cavity ?? params.cavity ?? 2),
        postOpCost: 1.73,
        packingCost: 0.86,
        transportCost: 0.62
      });
    } else {
      return calculateAtombergCost({
        vendor: 'Atomberg',
        rmBase: Number(rmMapping.activeWaPrice || 135.83),
        mbBase: Number(mbMapping.activeMbPrice || 258.54),
        rmFreight: 1.50,
        mbFreight: 2.00,
        mbPct: Number(params.runningMbPct !== undefined ? params.runningMbPct : (item.masterbatchPct ?? 4.0)),
        partWt: Number(params.runningNetWeight ?? item.netWeight ?? 37.0),
        runnerWt: Number(params.runningRunnerWeight ?? item.runnerWeight ?? 1.0),
        bopCost: Number(params.runningBopCost ?? item.bopCost ?? 0.0),
        tonnage: Number(params.runningTonnage ?? item.machineTonnage ?? 200.0),
        cycleTime: Number(params.runningCycleTime ?? item.cycleTimeApproved ?? 47.0),
        efficiency: 0.90,
        cavity: Number(params.runningCavity ?? item.cavity ?? 2),
        postOpCost: 1.73,
        packingCost: 0.86,
        transportCost: 0.62
      });
    }
  } else {
    // Haier / Multi-Vendor Standard Engine
    const mbApprovedRate = isCrisper ? Number(mbMapping.approvedMbPrice || 400.00) : Number(item.masterbatchRate || 0.0);
    const mbActiveRate = isCrisper ? Number(mbMapping.activeMbPrice || 240.00) : Number(item.masterbatchRate || 0.0);
    const mbPctVal = isCrisper ? 3.5 : Number(item.masterbatchPct || 0.0);
    const tonnageVal = isCrisper ? 650 : Number(item.machineTonnage || 450);
    const shiftTariffVal = tonnageVal >= 650 ? 5760 : (tonnageVal <= 200 ? 2000 : 4600);
    const cycleTimeVal = isCrisper ? 58 : Number(item.cycleTimeApproved || item.cycleTime || 48);

    if (isBaseline) {
      return calculateHaierCost({
        cavity: Number(item.cavity || (isCrisper ? 1 : 2)),
        netWeight: Number(item.netWeight || (isCrisper ? 485 : 197)),
        runnerWeight: Number(item.runnerWeight || (isCrisper ? 22 : 40)),
        rmRate: Number(rmMapping.approvedPrice || item.approvedRmRate || (isCrisper ? 103.08 : 130.00)),
        masterbatchPct: mbPctVal,
        masterbatchRate: mbApprovedRate,
        machineTonnage: tonnageVal,
        shiftTariff: shiftTariffVal,
        cycleTime: cycleTimeVal
      });
    } else {
      return calculateHaierCost({
        cavity: Number(params.runningCavity ?? item.cavity ?? (isCrisper ? 1 : 2)),
        netWeight: Number(params.runningNetWeight ?? item.netWeight ?? (isCrisper ? 485 : 197)),
        runnerWeight: Number(params.runningRunnerWeight ?? item.runnerWeight ?? (isCrisper ? 22 : 40)),
        rmRate: Number(rmMapping.activeWaPrice || (isCrisper ? 98.40 : 134.80)),
        masterbatchPct: Number(params.runningMbPct ?? mbPctVal),
        masterbatchRate: mbActiveRate,
        machineTonnage: Number(params.runningTonnage ?? tonnageVal),
        shiftTariff: Number(params.runningShiftTariff ?? shiftTariffVal),
        cycleTime: Number(params.runningCycleTime ?? cycleTimeVal)
      });
    }
  }
}
SERVICE_EOF

# ==============================================================================
# 2. INLINE EDIT MODAL (Dynamic Approved vs Actual Masterbatch Cost line)
# ==============================================================================
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, Lock, TrendingUp, TrendingDown } from 'lucide-react';
import { getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const isAtomberg = (item.vendor || '').toLowerCase().includes('atomberg');
  const isCrisper = item.itemCode === '0060217978E';
  const rmInfo = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');
  const mbInfo = getActiveMbMapping(item.vendor, '2026-08-01');

  // ---------- ATOMBERG VIEW ----------
  if (isAtomberg) {
    const approvedRmBase = Number(rmInfo.approvedPrice || 140.00);
    const approvedMbBase = Number(mbInfo.approvedMbPrice || 254.00);
    const actualRmBase = Number(rmInfo.activeWaPrice || 135.83);
    const actualMbBase = Number(mbInfo.activeMbPrice || 258.54);

    const baseP = {
      vendor: 'Atomberg',
      rmBase: approvedRmBase,
      rmFreight: 1.50,
      mbBase: approvedMbBase,
      mbFreight: 2.00,
      mbPct: 0.04,
      partWt: Number(item.netWeight || 37.0),
      runnerWt: Number(item.runnerWeight || 1.0),
      bopCost: Number(item.bopCost || 0.0),
      tonnage: Number(item.machineTonnage || 200.0),
      cycleTime: Number(item.cycleTimeApproved || 47.0),
      efficiency: 0.90,
      cavity: Number(item.cavity || 2),
      postOpCost: 1.73,
      packingCost: 0.86,
      transportCost: 0.62
    };
    const baseCalc = calculateAtombergCost(baseP);

    const params = item.parameters || {};
    const [partWt, setPartWt] = useState(params.runningNetWeight ?? baseP.partWt);
    const [runnerWt, setRunnerWt] = useState(params.runningRunnerWeight ?? baseP.runnerWt);
    const [mbPctVal, setMbPctVal] = useState((params.runningMbPct !== undefined ? params.runningMbPct : (baseP.mbPct * 100)));
    const [bopCost, setBopCost] = useState(params.runningBopCost ?? baseP.bopCost);
    const [cycleTime, setCycleTime] = useState(params.runningCycleTime ?? baseP.cycleTime);
    const [cavity, setCavity] = useState(params.runningCavity ?? baseP.cavity);
    const [tonnage, setTonnage] = useState(params.runningTonnage ?? baseP.tonnage);
    const [reason, setReason] = useState("Atomberg shopfloor spec verification");

    const runningP = {
      ...baseP,
      rmBase: actualRmBase,
      mbBase: actualMbBase,
      partWt: Number(partWt),
      runnerWt: Number(runnerWt),
      mbPct: Number(mbPctVal) / 100,
      bopCost: Number(bopCost),
      cycleTime: Number(cycleTime),
      cavity: Number(cavity),
      tonnage: Number(tonnage)
    };
    const runCalc = calculateAtombergCost(runningP);
    const profitLossDelta = Number((baseCalc.finalLanded - runCalc.finalLanded).toFixed(2));

    const handleSaveAtomberg = () => {
      onSave({
        updatedItem: {
          ...item,
          masterbatchPct: Number(mbPctVal),
          bopCost: Number(bopCost),
          parameters: {
            ...item.parameters,
            runningNetWeight: Number(partWt),
            runningRunnerWeight: Number(runnerWt),
            runningMbPct: Number(mbPctVal),
            runningBopCost: Number(bopCost),
            runningCycleTime: Number(cycleTime),
            runningCavity: Number(cavity),
            runningTonnage: Number(tonnage)
          }
        },
        changeType: "Atomberg Spec Adjustment",
        reason
      });
    };

    return (
      <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
        <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto">
          <div className="flex justify-between items-center border-b pb-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="bg-purple-600 text-white font-mono px-2 py-0.5 rounded font-bold">{item.itemCode || 'A101701'}</span>
                <h2 className="text-sm font-bold text-slate-900">{item.componentName || 'Aris Top Canopy- Gloss White'}</h2>
                <span className="bg-purple-100 text-purple-900 font-bold px-2 py-0.5 rounded text-[10px]">Atomberg Prescribed Format</span>
              </div>
              <p className="text-[11px] text-slate-500 font-mono mt-0.5">
                Vendor: <span className="font-bold text-slate-700">Atomberg Technologies</span> | Model: Aris | RM Link: <span className="text-emerald-700 font-bold">{rmInfo.activeRmName}</span>
              </p>
            </div>
            <button onClick={onClose} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div className="bg-slate-100 p-3 rounded-xl border">
              <span className="text-[10px] font-bold text-slate-500 uppercase block">APPROVED BASELINE CONTRACT</span>
              <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">₹{baseCalc.finalLanded.toFixed(2)}</span>
              <span className="text-[10px] text-slate-500 font-mono">RM: ₹{baseCalc.rmCost.toFixed(2)} | Process: ₹{baseCalc.totalProcessCost.toFixed(2)} | OH: ₹{baseCalc.otherCost.toFixed(2)}</span>
            </div>
            <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
              <span className="text-[10px] font-bold text-blue-700 uppercase block">ACTUAL RUNNING SHOPFLOOR</span>
              <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{runCalc.finalLanded.toFixed(2)}</span>
              <span className="text-[10px] text-blue-600 font-mono">RM: ₹{runCalc.rmCost.toFixed(2)} | Process: ₹{runCalc.totalProcessCost.toFixed(2)} | OH: ₹{runCalc.otherCost.toFixed(2)}</span>
            </div>
            <div className={`p-3 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
              <div className="flex justify-between items-center">
                <span className="text-[10px] font-bold text-slate-600 uppercase block">PROFIT / LOSS (Δ)</span>
                {profitLossDelta >= 0 ? <TrendingUp className="w-4 h-4 text-emerald-600" /> : <TrendingDown className="w-4 h-4 text-rose-600" />}
              </div>
              <span className={`text-2xl font-black font-mono mt-1 block ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                {profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}
              </span>
              <span className={`text-[10px] font-bold ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                {profitLossDelta >= 0 ? 'Cost Saving (Profit)' : 'Cost Escalation (Loss)'}
              </span>
            </div>
          </div>

          <div className="border border-slate-200 rounded-xl overflow-hidden">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0">
                <tr>
                  <th className="p-2 w-10 text-center">#</th>
                  <th className="p-2">ATOMBERG COSTING LINE</th>
                  <th className="p-2 w-20 text-center">UOM / RATE</th>
                  <th className="p-2 text-right w-44 bg-slate-200/50">APPROVED BASELINE</th>
                  <th className="p-2 text-right w-48 bg-blue-100/50">ACTUAL RUNNING</th>
                  <th className="p-2 text-right w-24">DELTA (Δ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                <tr><td className="p-2 text-center text-slate-400">1</td><td className="p-2 font-bold">Vendor</td><td className="p-2 text-center">-</td><td className="p-2 text-right">Atomberg</td><td className="p-2 text-right bg-blue-50/30">Atomberg</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">2</td><td className="p-2 font-bold">Part Code</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono font-bold">A101701</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">A101701</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">3</td><td className="p-2 font-bold">Part name</td><td className="p-2 text-center">-</td><td className="p-2 text-right">Aris Top Canopy- Gloss White</td><td className="p-2 text-right bg-blue-50/30">Aris Top Canopy- Gloss White</td><td className="p-2 text-right">-</td></tr>
                <tr className="bg-amber-50/40"><td className="p-2 text-center text-slate-400">4</td><td className="p-2 font-bold text-blue-900 flex items-center gap-1"><Lock className="w-3 h-3 text-amber-600" /> RM grade (Locked & Linked)</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-bold">{rmInfo.approvedRm}</td><td className="p-2 text-right bg-blue-50/30 font-bold text-blue-950">{rmInfo.activeRmName}</td><td className="p-2 text-right">-</td></tr>
                <tr className="bg-amber-50/60 font-bold"><td className="p-2 text-center text-slate-400">5</td><td className="p-2 font-black text-amber-950">RM Base Rate (From RM Matrix)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-amber-900 bg-amber-100/50">₹{baseCalc.rmBase.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-blue-900 bg-blue-100/50">₹{runCalc.rmBase.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.rmBase - baseCalc.rmBase).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">6</td><td className="p-2">ICC Cost @ 1% of RM</td><td className="p-2 text-center">1%</td><td className="p-2 text-right font-mono">₹{baseCalc.rmIcc.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rmIcc.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.rmIcc - baseCalc.rmIcc).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">7</td><td className="p-2">Freight Cost</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono">₹{baseCalc.rmFreight.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rmFreight.toFixed(2)}</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-emerald-50/70 font-bold border-y-2 border-emerald-200"><td className="p-2 text-center text-emerald-800">8</td><td className="p-2 font-black text-emerald-950">RM Landed Cost (Base + ICC + Freight)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-emerald-900 bg-emerald-100/60">₹{baseCalc.rmLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-emerald-900 bg-blue-100/60">₹{runCalc.rmLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-emerald-800">{(runCalc.rmLanded - baseCalc.rmLanded).toFixed(2)}</td></tr>
                <tr className="bg-purple-50/60 font-bold"><td className="p-2 text-center text-slate-400">9</td><td className="p-2 font-black text-purple-950">MB Base Cost (From RM Matrix)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-purple-900 bg-purple-100/50">₹{baseCalc.mbBase.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-blue-900 bg-blue-100/50">₹{runCalc.mbBase.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.mbBase - baseCalc.mbBase).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">10</td><td className="p-2">MB-ICC Cost @ 1% of MB</td><td className="p-2 text-center">1%</td><td className="p-2 text-right font-mono">₹{baseCalc.mbIcc.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mbIcc.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.mbIcc - baseCalc.mbIcc).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">11</td><td className="p-2">MB Freight Cost</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono">₹{baseCalc.mbFreight.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mbFreight.toFixed(2)}</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-purple-100/50 font-bold border-y-2 border-purple-200"><td className="p-2 text-center text-purple-900">12</td><td className="p-2 font-black text-purple-950">MB Landed Cost (Base + ICC + Freight)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-purple-950 bg-purple-200/50">₹{baseCalc.mbLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-purple-950 bg-blue-100/60">₹{runCalc.mbLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-purple-900">{(runCalc.mbLanded - baseCalc.mbLanded).toFixed(2)}</td></tr>
                <tr className="bg-purple-50/30"><td className="p-2 text-center text-slate-400">13</td><td className="p-2 font-bold text-purple-950">MB %</td><td className="p-2 text-center">%</td><td className="p-2 text-right font-mono font-bold bg-slate-50">4.00%</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.1" value={mbPctVal} onChange={e => setMbPctVal(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-purple-700">{(Number(mbPctVal) - 4).toFixed(2)}%</td></tr>
                <tr className="bg-amber-100/50 font-bold"><td className="p-2 text-center">14</td><td className="p-2 font-black">RM cost( PP + MB) /KG</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono font-black">₹{baseCalc.rmCombRate.toFixed(4)}</td><td className="p-2 text-right bg-blue-100/60 font-mono font-black">₹{runCalc.rmCombRate.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmCombRate - baseCalc.rmCombRate).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">15</td><td className="p-2 font-bold">part weight grams</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono font-bold">37.0g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={partWt} onChange={e => setPartWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(partWt) - 37).toFixed(1)}g</td></tr>
                <tr><td className="p-2 text-center text-slate-400">16</td><td className="p-2 font-bold">Runner weight grams</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono font-bold">1.0g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runnerWt} onChange={e => setRunnerWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(runnerWt) - 1).toFixed(1)}g</td></tr>
                <tr className="bg-slate-50/50"><td className="p-2 text-center text-slate-400">17</td><td className="p-2 font-bold">Gross weight</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono">{baseCalc.grossWt}g</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{runCalc.grossWt}g</td><td className="p-2 text-right font-mono">{runCalc.grossWt - baseCalc.grossWt}g</td></tr>
                <tr className="bg-amber-50 font-bold"><td className="p-2 text-center">18</td><td className="p-2 font-black">RM cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono font-bold">₹{baseCalc.rmCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50 font-mono font-bold">₹{runCalc.rmCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmCost - baseCalc.rmCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">19</td><td className="p-2 font-bold">Inserts/BOP cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.00</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.01" value={bopCost} onChange={e => setBopCost(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">₹{Number(bopCost).toFixed(2)}</td></tr>
                <tr className="bg-slate-50 font-bold"><td className="p-2 text-center">20</td><td className="p-2 font-black">RM + BOP Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.rmBopCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50 font-mono">₹{runCalc.rmBopCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmBopCost - baseCalc.rmBopCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">21</td><td className="p-2 font-bold">M/c tonnage</td><td className="p-2 text-center">T</td><td className="p-2 text-right font-mono">200T</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={tonnage} onChange={e => setTonnage(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(tonnage) - 200}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">22</td><td className="p-2">shift rate (Tonnage × ₹10)</td><td className="p-2 text-center">₹/shift</td><td className="p-2 text-right font-mono">₹2,000</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.shiftRate}</td><td className="p-2 text-right font-mono">{runCalc.shiftRate - 2000}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">23</td><td className="p-2 font-bold">cycle time( seconds)</td><td className="p-2 text-center">Sec</td><td className="p-2 text-right font-mono font-bold">47s</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="1" value={cycleTime} onChange={e => setCycleTime(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-blue-700">{(Number(cycleTime) - 47).toFixed(1)}s</td></tr>
                <tr><td className="p-2 text-center text-slate-400">24</td><td className="p-2">Efficiency</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono">0.90</td><td className="p-2 text-right bg-blue-50/30 font-mono">0.90</td><td className="p-2 text-right font-mono">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">25</td><td className="p-2 font-bold">No of cavity</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono font-bold">2</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={cavity} onChange={e => setCavity(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(cavity) - 2}</td></tr>
                <tr className="bg-slate-50"><td className="p-2 text-center text-slate-400">26</td><td className="p-2">No. of parts/shift</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono">{baseCalc.partsPerShift.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{runCalc.partsPerShift.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.partsPerShift - baseCalc.partsPerShift).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">27</td><td className="p-2 font-bold">Process cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.processCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{runCalc.processCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.processCost - baseCalc.processCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">28</td><td className="p-2">Handling cost for BOP</td><td className="p-2 text-center">3%</td><td className="p-2 text-right font-mono">₹0.00</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.bopHandling.toFixed(4)}</td><td className="p-2 text-right font-mono">{runCalc.bopHandling.toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">29</td><td className="p-2 font-bold">Post operation cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹1.73</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹1.73</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-blue-100/50 font-bold"><td className="p-2 text-center">30</td><td className="p-2 font-black text-blue-950">Total Process Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono font-black">₹{baseCalc.totalProcessCost.toFixed(4)}</td><td className="p-2 bg-blue-100/70 font-mono font-black">₹{runCalc.totalProcessCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.totalProcessCost - baseCalc.totalProcessCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">31</td><td className="p-2">Profit & OH</td><td className="p-2 text-center">12%</td><td className="p-2 text-right font-mono">₹{baseCalc.profitOh.toFixed(4)}</td><td className="p-2 bg-blue-50/30 font-mono">₹{runCalc.profitOh.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.profitOh - baseCalc.profitOh).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">32</td><td className="p-2">Inprocess Rejection</td><td className="p-2 text-center">4%</td><td className="p-2 text-right font-mono">₹{baseCalc.inprocessRejection.toFixed(4)}</td><td className="p-2 bg-blue-50/30 font-mono">₹{runCalc.inprocessRejection.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.inprocessRejection - baseCalc.inprocessRejection).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">33</td><td className="p-2 font-bold text-emerald-800">Runner recovery cost</td><td className="p-2 text-center">₹25/kg</td><td className="p-2 text-right font-mono text-emerald-700">- ₹0.025</td><td className="p-2 bg-blue-50/30 font-mono text-emerald-700">- ₹{Math.abs(runCalc.runnerRecovery).toFixed(3)}</td><td className="p-2 text-right font-mono">{(runCalc.runnerRecovery - baseCalc.runnerRecovery).toFixed(3)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">34</td><td className="p-2">Packing cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.86</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹0.86</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr><td className="p-2 text-center text-slate-400">35</td><td className="p-2">Transport cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.62</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹0.62</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr><td className="p-2 text-center text-slate-400">36</td><td className="p-2">Mould maintenance cost</td><td className="p-2 text-center">2%</td><td className="p-2 text-right font-mono">₹{baseCalc.mouldMaint.toFixed(4)}</td><td className="p-2 bg-blue-50/30 font-mono">₹{runCalc.mouldMaint.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.mouldMaint - baseCalc.mouldMaint).toFixed(4)}</td></tr>
                <tr className="bg-slate-100 font-bold"><td className="p-2 text-center">37</td><td className="p-2 font-black">Other Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.otherCost.toFixed(4)}</td><td className="p-2 bg-blue-50 font-mono">₹{runCalc.otherCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.otherCost - baseCalc.otherCost).toFixed(4)}</td></tr>
                <tr className="bg-slate-900 text-white font-bold">
                  <td className="p-2.5 text-center">38</td>
                  <td className="p-2.5 font-black text-amber-300 uppercase tracking-wider">Final Landed cost</td>
                  <td className="p-2.5 text-center font-mono">₹/pc</td>
                  <td className="p-2.5 text-right font-mono font-black text-amber-300 text-sm">₹{baseCalc.finalLanded.toFixed(2)}</td>
                  <td className="p-2.5 font-mono font-black text-emerald-300 text-sm bg-slate-800 text-right">₹{runCalc.finalLanded.toFixed(2)}</td>
                  <td className={`p-2.5 text-right font-mono font-black text-sm ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                    {profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div className="space-y-2 pt-2 border-t">
            <div>
              <label className="font-bold text-slate-700 block mb-1">Reason for Shopfloor Spec Drift / Audit Trail Record *</label>
              <input type="text" value={reason} onChange={e => setReason(e.target.value)} className="w-full border p-2 rounded-xl text-xs outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div className="flex justify-between items-center pt-2">
              <button onClick={onClose} className="px-4 py-2 border rounded-xl hover:bg-slate-50 cursor-pointer">Cancel</button>
              <button onClick={handleSaveAtomberg} className="px-6 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"><Save className="w-4 h-4" /> Save & Log Atomberg Parameters</button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ---------- HAIER VIEW (DYNAMIC RM & MB LINKED) ----------
  const dynamicHaierApprovedRm = Number(rmInfo.approvedPrice || item.approvedRmRate || (isCrisper ? 103.08 : 130.00));
  const dynamicHaierActualRm = Number(rmInfo.activeWaPrice || (isCrisper ? 98.40 : 134.80));

  // Dynamic Masterbatch Approved & Actual rates from Module 2
  const dynamicHaierApprovedMb = isCrisper ? Number(mbInfo.approvedMbPrice || 400.00) : 0.0;
  const dynamicHaierActualMb = isCrisper ? Number(mbInfo.activeMbPrice || 240.00) : 0.0;

  const baseCavity = Number(item.cavity || (isCrisper ? 1 : 2));
  const baseNetWt = Number(item.netWeight || (isCrisper ? 485 : 197));
  const baseRunnerWt = Number(item.runnerWeight || (isCrisper ? 22 : 40));
  const baseMbPct = Number(item.masterbatchPct ?? (isCrisper ? 3.5 : 0.0));
  const baseCycle = Number(item.cycleTimeApproved || item.cycleTime || (isCrisper ? 58 : 48));
  const baseTonnage = Number(item.machineTonnage || (isCrisper ? 650 : 450));
  const baseTariff = Number(item.parameters?.shiftTariff || (baseTonnage >= 650 ? 5760 : 4600));

  const params = item.parameters || {};
  const [runningCavity, setRunningCavity] = useState(params.runningCavity ?? baseCavity);
  const [runningNetWeight, setRunningNetWeight] = useState(params.runningNetWeight ?? baseNetWt);
  const [runningRunnerWeight, setRunningRunnerWeight] = useState(params.runningRunnerWeight ?? baseRunnerWt);
  const [runningMbPct, setRunningMbPct] = useState(params.runningMbPct ?? baseMbPct);
  const [runningCycleTime, setRunningCycleTime] = useState(params.runningCycleTime ?? baseCycle);
  const [runningTonnage, setRunningTonnage] = useState(params.runningTonnage ?? baseTonnage);
  const [reason, setReason] = useState("Shopfloor parameters & MB tuning");

  const actualTariff = Number(params.runningShiftTariff ?? (runningTonnage >= 650 ? 5760 : 4600));

  const baselineCalc = calculateHaierCost({
    cavity: baseCavity, netWeight: baseNetWt, runnerWeight: baseRunnerWt,
    rmRate: dynamicHaierApprovedRm, masterbatchPct: baseMbPct, masterbatchRate: dynamicHaierApprovedMb,
    cycleTime: baseCycle, machineTonnage: baseTonnage, shiftTariff: baseTariff
  });

  const runningCalc = calculateHaierCost({
    cavity: Number(runningCavity), netWeight: Number(runningNetWeight), runnerWeight: Number(runningRunnerWeight),
    rmRate: dynamicHaierActualRm, masterbatchPct: Number(runningMbPct), masterbatchRate: dynamicHaierActualMb,
    cycleTime: Number(runningCycleTime), machineTonnage: Number(runningTonnage), shiftTariff: actualTariff
  });

  const profitLossDelta = Number((baselineCalc.totalCost - runningCalc.totalCost).toFixed(2));

  const handleSaveHaier = () => {
    onSave({
      updatedItem: {
        ...item,
        masterbatchPct: Number(runningMbPct),
        parameters: {
          ...item.parameters,
          runningCavity: Number(runningCavity),
          runningNetWeight: Number(runningNetWeight),
          runningRunnerWeight: Number(runningRunnerWeight),
          runningMbPct: Number(runningMbPct),
          runningCycleTime: Number(runningCycleTime),
          runningTonnage: Number(runningTonnage),
          runningShiftTariff: actualTariff
        }
      },
      changeType: "Shopfloor Spec Adjustment",
      reason
    });
  };

  return (
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto">
        <div className="flex justify-between items-center border-b pb-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="bg-blue-600 text-white font-mono px-2 py-0.5 rounded font-bold">{item.itemCode}</span>
              <h2 className="text-sm font-bold text-slate-900">{item.componentName}</h2>
              <span className="bg-blue-100 text-blue-900 font-bold px-2 py-0.5 rounded text-[10px]">Haier Prescribed Format</span>
            </div>
            <p className="text-[11px] text-slate-500 font-mono mt-0.5">
              Vendor: <span className="font-bold text-slate-700">{item.vendor}</span> | Model: {item.model} | RM Link: <span className="text-blue-700 font-bold">{rmInfo.activeRmName}</span>
            </p>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
        </div>

        <div className="grid grid-cols-3 gap-3">
          <div className="bg-slate-100 p-3 rounded-xl border">
            <span className="text-[10px] font-bold text-slate-500 uppercase block">APPROVED BASELINE CONTRACT</span>
            <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">₹{baselineCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-slate-500 font-mono">RM: ₹{baselineCalc.totalRmCost.toFixed(2)} | Conv: ₹{baselineCalc.conversionCost.toFixed(2)}</span>
          </div>
          <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
            <span className="text-[10px] font-bold text-blue-700 uppercase block">ACTUAL RUNNING SHOPFLOOR</span>
            <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{runningCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-blue-600 font-mono">RM: ₹{runningCalc.totalRmCost.toFixed(2)} | Conv: ₹{runningCalc.conversionCost.toFixed(2)}</span>
          </div>
          <div className={`p-3 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
            <div className="flex justify-between items-center">
              <span className="text-[10px] font-bold text-slate-600 uppercase block">PROFIT / LOSS (Δ)</span>
              {profitLossDelta >= 0 ? <TrendingUp className="w-4 h-4 text-emerald-600" /> : <TrendingDown className="w-4 h-4 text-rose-600" />}
            </div>
            <span className={`text-2xl font-black font-mono mt-1 block ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
              {profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}
            </span>
            <span className={`text-[10px] font-bold ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
              {profitLossDelta >= 0 ? 'Cost Saving (Profit)' : 'Cost Escalation (Loss)'}
            </span>
          </div>
        </div>

        <div className="border border-slate-200 rounded-xl overflow-hidden">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0">
              <tr>
                <th className="p-2.5 w-12 text-center">#</th>
                <th className="p-2.5">HAIER PARAMETER / SPEC LINE</th>
                <th className="p-2.5 w-16 text-center">UOM</th>
                <th className="p-2.5 text-right w-44 bg-slate-200/50">APPROVED BASELINE</th>
                <th className="p-2.5 text-right w-48 bg-blue-100/50">ACTUAL RUNNING</th>
                <th className="p-2.5 text-right w-24">DELTA (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              <tr><td className="p-2 text-center text-slate-400">1</td><td className="p-2 font-bold text-slate-700">Name Of Component</td><td className="p-2 text-center font-mono">-</td><td className="p-2 text-right font-semibold">{item.componentName}</td><td className="p-2 text-right bg-blue-50/30 font-semibold">{item.componentName}</td><td className="p-2 text-right font-mono text-slate-400">-</td></tr>
              <tr><td className="p-2 text-center text-slate-400">2</td><td className="p-2 font-bold text-slate-700">Mould Size L * W * H</td><td className="p-2 text-center font-mono">mm</td><td className="p-2 text-right font-mono">{item.mouldSize || '1070*720*650'}</td><td className="p-2 text-right bg-blue-50/30 font-mono">{item.mouldSize || '1070*720*650'}</td><td className="p-2 text-right font-mono text-slate-400">-</td></tr>
              <tr className="bg-amber-50/30"><td className="p-2 text-center text-slate-400">3</td><td className="p-2 font-bold text-slate-900 flex items-center gap-1"><Lock className="w-3 h-3 text-amber-600" /> Approved RM Grade (Locked & Linked)</td><td className="p-2 text-center font-mono">-</td><td className="p-2 text-right font-mono font-bold bg-slate-50 text-amber-900">{item.approvedRm} (₹{dynamicHaierApprovedRm.toFixed(2)})</td><td className="p-2 text-right bg-blue-50/40 font-mono font-bold text-blue-950">{rmInfo.activeRmName} (₹{dynamicHaierActualRm.toFixed(2)})</td><td className="p-2 text-right font-mono font-bold">{(dynamicHaierActualRm - dynamicHaierApprovedRm).toFixed(2)}</td></tr>
              <tr className="bg-purple-50/40"><td className="p-2 text-center text-slate-400">4</td><td className="p-2 font-bold text-purple-950">Masterbatch Required {isCrisper ? `(Base: ₹${dynamicHaierApprovedMb.toFixed(2)} vs Act: ₹${dynamicHaierActualMb.toFixed(2)})` : ''}</td><td className="p-2 text-center font-mono">%</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseMbPct.toFixed(2)}%</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.1" value={runningMbPct} onChange={e => setRunningMbPct(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-purple-700">{(Number(runningMbPct) - baseMbPct).toFixed(2)}%</td></tr>
              <tr><td className="p-2 text-center text-slate-400">5</td><td className="p-2 font-bold text-slate-900">No. of Cavity</td><td className="p-2 text-center font-mono">Nos</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseCavity}</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={runningCavity} onChange={e => setRunningCavity(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(runningCavity) - baseCavity}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">6</td><td className="p-2 font-bold text-slate-900">Runner Weight</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baseRunnerWt}g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runningRunnerWeight} onChange={e => setRunningRunnerWeight(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(runningRunnerWeight) - baseRunnerWt).toFixed(1)}g</td></tr>
              <tr><td className="p-2 text-center text-slate-400">7</td><td className="p-2 font-bold text-slate-900">Net Weight</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseNetWt}g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runningNetWeight} onChange={e => setRunningNetWeight(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold">{(Number(runningNetWeight) - baseNetWt).toFixed(1)}g</td></tr>
              <tr className="bg-slate-50/40"><td className="p-2 text-center text-slate-400">8</td><td className="p-2 font-bold text-slate-700">Shot Weight (Calculated / pc)</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baselineCalc.shotWeightPerPiece.toFixed(2)}g</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runningCalc.shotWeightPerPiece.toFixed(2)}g</td><td className="p-2 text-right font-mono">{(runningCalc.shotWeightPerPiece - baselineCalc.shotWeightPerPiece).toFixed(2)}g</td></tr>
              <tr className="bg-slate-50/40"><td className="p-2 text-center text-slate-400">9</td><td className="p-2 font-bold text-slate-700">Reconciliation Weight (Shot wt + 1.0% Melt Loss)</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baselineCalc.reconciliationWeight.toFixed(2)}g</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runningCalc.reconciliationWeight.toFixed(2)}g</td><td className="p-2 text-right font-mono">{(runningCalc.reconciliationWeight - baselineCalc.reconciliationWeight).toFixed(2)}g</td></tr>
              <tr><td className="p-2 text-center text-slate-400">10</td><td className="p-2 font-bold text-slate-900">Raw Material Cost</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.rawMaterialCost.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">₹{runningCalc.rawMaterialCost.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runningCalc.rawMaterialCost - baselineCalc.rawMaterialCost).toFixed(2)}</td></tr>
              <tr className="bg-purple-50/60 font-bold"><td className="p-2 text-center text-slate-400">11</td><td className="p-2 font-bold text-purple-950">Master Batch Cost (Linked to MB Inward Rate)</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono font-black text-purple-900 bg-purple-100/50">₹{baselineCalc.masterbatchCost.toFixed(2)}</td><td className="p-2 text-right bg-blue-100/50 font-mono font-black text-blue-900">₹{runningCalc.masterbatchCost.toFixed(2)}</td><td className="p-2 text-right font-mono font-bold text-purple-800">₹{(runningCalc.masterbatchCost - baselineCalc.masterbatchCost).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">12</td><td className="p-2 font-bold text-emerald-800">Runner Recovery Credit (Scrap Credit)</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50 text-emerald-700">- ₹{baselineCalc.runnerCredit.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold text-emerald-700">- ₹{runningCalc.runnerCredit.toFixed(2)}</td><td className="p-2 text-right font-mono text-slate-500">₹{(runningCalc.runnerCredit - baselineCalc.runnerCredit).toFixed(2)}</td></tr>
              <tr className="bg-amber-100/60 font-bold"><td className="p-2 text-center">13</td><td className="p-2 font-black text-slate-900">TOTAL RAW MATERIAL COST</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono font-black bg-amber-50">₹{baselineCalc.totalRmCost.toFixed(2)}</td><td className="p-2 bg-blue-100/70 font-mono font-black text-blue-950">₹{runningCalc.totalRmCost.toFixed(2)}</td><td className="p-2 text-right font-mono font-black">₹{(runningCalc.totalRmCost - baselineCalc.totalRmCost).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">14</td><td className="p-2 font-bold text-slate-900">Cycle Time Approved</td><td className="p-2 text-center font-mono">Sec</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseCycle}s</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="1" value={runningCycleTime} onChange={e => setRunningCycleTime(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-blue-700">{(Number(runningCycleTime) - baseCycle).toFixed(1)}s</td></tr>
              <tr><td className="p-2 text-center text-slate-400">15</td><td className="p-2 font-bold text-slate-900">Shift Machine Tariff (Tonnage: {runningTonnage}T)</td><td className="p-2 text-center font-mono">₹/shift</td><td className="p-2 text-right font-mono bg-slate-50">₹{baseTariff}</td><td className="p-2 text-right bg-blue-50/40 font-mono font-bold">₹{actualTariff}</td><td className="p-2 text-right font-mono">{actualTariff - baseTariff}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">16</td><td className="p-2 font-bold text-slate-900">Machine Conversion Cost / Piece</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.conversionCost.toFixed(2)}</td><td className="p-2 bg-blue-50/30 font-mono font-bold">₹{runningCalc.conversionCost.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runningCalc.conversionCost - baselineCalc.conversionCost).toFixed(2)}</td></tr>
              <tr className="bg-slate-900 text-white font-bold">
                <td className="p-2.5 text-center">17</td>
                <td className="p-2.5 font-black text-amber-300 uppercase tracking-wider">TOTAL COMPONENT BASELINE COST</td>
                <td className="p-2.5 text-center font-mono">₹</td>
                <td className="p-2.5 text-right font-mono font-black text-amber-300 text-sm">₹{baselineCalc.totalCost.toFixed(2)}</td>
                <td className="p-2.5 font-mono font-black text-emerald-300 text-sm bg-slate-800 text-right">₹{runningCalc.totalCost.toFixed(2)}</td>
                <td className={`p-2.5 text-right font-mono font-black text-sm ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                  {profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div className="space-y-2 pt-2 border-t">
          <div>
            <label className="font-bold text-slate-700 block mb-1">Reason for Shopfloor Spec Drift / Audit Trail Record *</label>
            <input type="text" value={reason} onChange={e => setReason(e.target.value)} className="w-full border p-2 rounded-xl text-xs outline-none focus:ring-2 focus:ring-blue-500" />
          </div>
          <div className="flex justify-between items-center pt-2">
            <button onClick={onClose} className="px-4 py-2 border rounded-xl hover:bg-slate-50 cursor-pointer">Cancel</button>
            <button onClick={handleSaveHaier} className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"><Save className="w-4 h-4" /> Save & Log Haier Parameters</button>
          </div>
        </div>
      </div>
    </div>
  );
}
MODAL_EOF

# ==============================================================================
# 3. COSTING RUN ENGINE (Evaluates accurate dynamic RM & MB)
# ==============================================================================
cat << 'COST_EOF' > src/modules/module3-costing-engine/CostingRunEnginePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  DollarSign, Sliders, Search, TrendingUp, TrendingDown, 
  CheckCircle2 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping, getVendorBaselineData } from '../../shared/masterStore';
import { calculatePieceCostUnified } from '../../shared/costCalculationService';

export default function CostingRunEnginePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [searchQuery, setSearchQuery] = useState('');

  const rawList = getVendorBaselineData(selectedVendor);

  const filteredItems = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <DollarSign className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">3. Dynamic Costing Run Engine</h1>
            <p className="text-[11px] text-slate-300">Live simulation of product piece costing matching contract baselines against active material inward rates.</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/40 px-2.5 py-1 rounded-full font-bold flex items-center gap-1.5">
            <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" /> Engine Active & Linked to RM Matrix
          </span>
        </div>
      </div>

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search components by name or part number..."
            className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-700">Filter Vendor:</span>
          <select
            value={selectedVendor}
            onChange={(e) => setSelectedVendor(e.target.value)}
            className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
            <option value="ALL">All Vendors Combined</option>
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
          <h2 className="text-sm font-bold flex items-center gap-2">
            <Sliders className="w-4 h-4 text-blue-400" /> Live Product Cost Simulation Matrix
          </h2>
          <span className="text-[11px] text-slate-300 font-mono">{filteredItems.length} Products</span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
              <tr>
                <th className="p-3">ITEM CODE / COMPONENT</th>
                <th className="p-3 text-center">VENDOR</th>
                <th className="p-3">APPROVED RM</th>
                <th className="p-3 text-right bg-amber-50">APPROVED RM RATE</th>
                <th className="p-3">ACTIVE ALTERNATE RM (INWARD)</th>
                <th className="p-3 text-right bg-blue-50">ACTIVE WA RATE</th>
                <th className="p-3 text-right bg-amber-50 font-bold">APPROVED BASELINE</th>
                <th className="p-3 text-right bg-blue-50 font-bold">SIMULATED ACTUAL</th>
                <th className="p-3 text-right">PROFIT / LOSS (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {filteredItems.map((item) => {
                const vName = item.vendor || selectedVendor;
                const rmMapping = getActiveRmMapping(item.approvedRm, vName, '2026-08-01');

                const baselineCalc = calculatePieceCostUnified({
                  item: { ...item, vendor: vName },
                  isBaseline: true,
                  targetDate: '2026-08-01'
                });

                const runningCalc = calculatePieceCostUnified({
                  item: { ...item, vendor: vName },
                  isBaseline: false,
                  targetDate: '2026-08-01'
                });

                const contractBaseline = Number(baselineCalc.finalLanded.toFixed(2));
                const actualCost = Number(runningCalc.finalLanded.toFixed(2));
                const unitProfitLoss = Number((contractBaseline - actualCost).toFixed(2));

                return (
                  <tr key={item.id} className="hover:bg-slate-50">
                    <td className="p-3">
                      <span className="font-mono font-bold text-blue-700 block">{item.itemCode}</span>
                      <span className="font-semibold text-slate-900">{item.componentName}</span>
                    </td>
                    <td className="p-3 text-center">
                      <span className="bg-slate-100 border border-slate-300 font-bold px-2 py-0.5 rounded text-[10px]">
                        {vName}
                      </span>
                    </td>
                    <td className="p-3 font-semibold text-slate-800">{item.approvedRm}</td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900 bg-amber-50/50">
                      ₹{Number(rmMapping.approvedPrice || item.approvedRmRate).toFixed(2)}/kg
                    </td>
                    <td className="p-3">
                      <span className="font-bold text-blue-900 block">{rmMapping.activeRmName}</span>
                      <span className="text-[10px] text-slate-500 font-mono">Linked to RM Matrix</span>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-blue-900 bg-blue-50/50">
                      ₹{Number(rmMapping.activeWaPrice).toFixed(2)}/kg
                    </td>
                    <td className="p-3 text-right font-mono font-black text-slate-900 bg-amber-50/50 text-xs">
                      ₹{contractBaseline.toFixed(2)}
                    </td>
                    <td className="p-3 text-right font-mono font-black text-blue-950 bg-blue-50/50 text-xs">
                      ₹{actualCost.toFixed(2)}
                    </td>
                    <td className="p-3 text-right font-mono font-black">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded text-[11px] ${
                        unitProfitLoss >= 0 ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-rose-100 text-rose-800 border border-rose-300'
                      }`}>
                        {unitProfitLoss >= 0 ? <TrendingUp className="w-3.5 h-3.5 text-emerald-600" /> : <TrendingDown className="w-3.5 h-3.5 text-rose-600" />}
                        {unitProfitLoss >= 0 ? `₹ +${unitProfitLoss.toFixed(2)}` : `₹ -${Math.abs(unitProfitLoss).toFixed(2)}`}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
COST_EOF

# ==============================================================================
# 4. MIS INTELLIGENCE (Strictly mirrors calculatePieceCostUnified)
# ==============================================================================
cat << 'MIS_PAGE_EOF' > src/modules/module4-mis/MISIntelligencePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Search, Calendar, 
  Eye, FileSpreadsheet, Layers, ShieldCheck, CheckCircle2 
} from 'lucide-react';
import { globalStore, subscribeStore, getVendorBaselineData } from '../../shared/masterStore';
import { calculatePieceCostUnified } from '../../shared/costCalculationService';

export default function MISIntelligencePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('All Vendors Combined');
  const [fromDate, setFromDate] = useState('2026-08-01');
  const [toDate, setToDate] = useState('2026-08-31');

  const allBaselines = getVendorBaselineData('ALL');

  const salesData = (globalStore.salesData || []).filter(s => {
    const vMatch = selectedVendor === 'All Vendors Combined' || selectedVendor === 'ALL' || s.vendor === selectedVendor;
    const dMatch = (!fromDate || s.invoiceDate >= fromDate) && (!toDate || s.invoiceDate <= toDate);
    return vMatch && dMatch;
  });

  const analyzedRows = useMemo(() => {
    return salesData.map(sale => {
      let part = allBaselines.find(p => p.itemCode === sale.itemCode && p.vendor === sale.vendor);
      if (!part) {
        part = allBaselines.find(p => p.itemCode === sale.itemCode);
      }
      if (!part) {
        part = {
          vendor: sale.vendor,
          itemCode: sale.itemCode,
          componentName: sale.componentName,
          approvedRm: sale.vendor === 'Atomberg' ? 'PP H110MA' : (sale.itemCode === '0060217978E' ? 'GPPS SC201LV' : 'ABS 300 Pre Colour'),
          masterbatchPct: sale.itemCode === '0060217978E' ? 3.5 : 0.0,
          machineTonnage: sale.itemCode === '0060217978E' ? 650 : (sale.vendor === 'Atomberg' ? 200 : 450),
          cycleTimeApproved: sale.itemCode === '0060217978E' ? 58 : (sale.vendor === 'Atomberg' ? 47 : 48),
          netWeight: sale.itemCode === '0060217978E' ? 485 : (sale.vendor === 'Atomberg' ? 37 : 197),
          runnerWeight: sale.itemCode === '0060217978E' ? 22 : (sale.vendor === 'Atomberg' ? 1 : 40),
          cavity: sale.itemCode === '0060217978E' ? 1 : 2
        };
      }

      const baseResult = calculatePieceCostUnified({
        item: { ...part, vendor: sale.vendor },
        isBaseline: true,
        targetDate: sale.invoiceDate
      });

      const actualResult = calculatePieceCostUnified({
        item: { ...part, vendor: sale.vendor },
        isBaseline: false,
        targetDate: sale.invoiceDate
      });

      const contractBaseline = Number(baseResult.finalLanded.toFixed(2));
      const actualUnitCost = Number(actualResult.finalLanded.toFixed(2));

      const unitDelta = Number((contractBaseline - actualUnitCost).toFixed(2));
      const totalDelta = Number((unitDelta * sale.saleUnit).toFixed(2));
      const totalSales = Number((sale.sellingPrice * sale.saleUnit).toFixed(2));
      const totalActualCost = Number((actualUnitCost * sale.saleUnit).toFixed(2));
      const grossMarginAmt = Number((totalSales - totalActualCost).toFixed(2));

      return {
        ...sale,
        contractBaseline,
        actualUnitCost,
        unitDelta,
        totalDelta,
        totalSales,
        grossMarginAmt
      };
    });
  }, [salesData, allBaselines, selectedVendor]);

  const summary = useMemo(() => {
    const totalVolume = analyzedRows.reduce((a, b) => a + (b.saleUnit || 0), 0);
    const totalRevenue = analyzedRows.reduce((a, b) => a + (b.totalSales || 0), 0);
    const totalCostDelta = analyzedRows.reduce((a, b) => a + (b.totalDelta || 0), 0);
    const totalGrossProfit = analyzedRows.reduce((a, b) => a + (b.grossMarginAmt || 0), 0);
    const grossProfitPct = totalRevenue > 0 ? ((totalGrossProfit / totalRevenue) * 100).toFixed(1) : '0.0';

    return {
      totalVolume,
      totalRevenue,
      totalCostDelta,
      totalGrossProfit,
      grossProfitPct
    };
  }, [analyzedRows]);

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <BarChart3 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">4. Vendor & Product Sales P&L MIS Intelligence</h1>
            <p className="text-[11px] text-slate-300">Synchronized Piece Costing Variance Engine</p>
          </div>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700">VENDOR:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
            >
              <option value="All Vendors Combined">All Vendors Combined</option>
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 border rounded-xl px-3 py-1 text-slate-700">
            <Calendar className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-[11px]">PERIOD:</span>
            <input type="date" value={fromDate} onChange={e => setFromDate(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs" />
            <span>&rarr;</span>
            <input type="date" value={toDate} onChange={e => setToDate(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs" />
          </div>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Period Sales Volume</span>
          <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">{summary.totalVolume.toLocaleString()} pcs</span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Total Sales Revenue</span>
          <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{summary.totalRevenue.toLocaleString('en-IN')}</span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Gross Profit & Margin</span>
          <span className="text-2xl font-black text-emerald-900 font-mono mt-1 block">
            ₹{summary.totalGrossProfit.toLocaleString('en-IN')} <span className="text-xs font-bold text-emerald-700">({summary.grossProfitPct}%)</span>
          </span>
        </div>

        <div className={`border rounded-2xl p-4 shadow-xs ${summary.totalCostDelta >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
          <div className="flex justify-between items-center">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-600">Cost Variance Gain / Loss</span>
            {summary.totalCostDelta >= 0 ? <TrendingUp className="w-4 h-4 text-emerald-600" /> : <TrendingDown className="w-4 h-4 text-rose-600" />}
          </div>
          <span className={`text-2xl font-black font-mono mt-1 block ${summary.totalCostDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {summary.totalCostDelta >= 0 ? `₹ +${summary.totalCostDelta.toLocaleString('en-IN')}` : `₹ -${Math.abs(summary.totalCostDelta).toLocaleString('en-IN')}`}
          </span>
        </div>
      </div>

      {/* Product Realization Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
          <h2 className="text-sm font-bold flex items-center gap-2">
            <FileSpreadsheet className="w-4 h-4 text-blue-400" /> Product Sales Realization & Costing Analysis
          </h2>
          <span className="text-[11px] text-slate-300 font-mono">{analyzedRows.length} Dispatch Invoices</span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
              <tr>
                <th className="p-3">Date</th>
                <th className="p-3">Part Code</th>
                <th className="p-3">Component Name</th>
                <th className="p-3 text-center">Vendor</th>
                <th className="p-3 text-right">Qty Sold</th>
                <th className="p-3 text-right">Selling Price</th>
                <th className="p-3 text-right bg-amber-50 font-bold">Contract Baseline</th>
                <th className="p-3 text-right bg-blue-50 font-bold">Actual Unit Cost</th>
                <th className="p-3 text-right bg-yellow-100/70 font-black">Profit / Loss (Δ)</th>
                <th className="p-3 text-right bg-cyan-100/70 font-black">Total Profit / Loss (Δ)</th>
                <th className="p-3 text-right bg-orange-100/70 font-black">Total Sales</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {analyzedRows.map((row) => (
                <tr key={row.id} className="hover:bg-slate-50">
                  <td className="p-3 font-mono text-slate-500">{row.invoiceDate}</td>
                  <td className="p-3 font-mono font-bold text-blue-700">{row.itemCode}</td>
                  <td className="p-3 font-semibold text-slate-900">{row.componentName}</td>
                  <td className="p-3 text-center font-bold text-slate-700">{row.vendor}</td>
                  <td className="p-3 text-right font-mono font-bold">{row.saleUnit.toLocaleString()}</td>
                  <td className="p-3 text-right font-mono font-bold">₹{row.sellingPrice.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-black text-slate-900 bg-amber-50/50">₹{row.contractBaseline.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-black text-blue-950 bg-blue-50/50">₹{row.actualUnitCost.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-black bg-yellow-50">
                    <span className={row.unitDelta >= 0 ? 'text-emerald-700 font-bold' : 'text-rose-700 font-bold'}>
                      {row.unitDelta >= 0 ? `₹ +${row.unitDelta.toFixed(2)}` : `₹ -${Math.abs(row.unitDelta).toFixed(2)}`}
                    </span>
                  </td>
                  <td className="p-3 text-right font-mono font-black bg-cyan-50">
                    <span className={row.totalDelta >= 0 ? 'text-emerald-700 font-bold' : 'text-rose-700 font-bold'}>
                      {row.totalDelta >= 0 ? `₹ +${row.totalDelta.toLocaleString('en-IN')}` : `₹ -${Math.abs(row.totalDelta).toLocaleString('en-IN')}`}
                    </span>
                  </td>
                  <td className="p-3 text-right font-mono font-black text-slate-900 bg-orange-50">
                    ₹{row.totalSales.toLocaleString('en-IN')}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
MIS_PAGE_EOF

echo "==> 5. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Masterbatch link & synchronized pricing deployed."
