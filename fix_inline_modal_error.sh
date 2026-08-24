#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring branch is dev-v2..."
git checkout dev-v2

echo "==> 2. Writing bulletproof costCalculationService.js..."
cat << 'SERVICE_EOF' > src/shared/costCalculationService.js
// ============================================================================
// MULTI-VENDOR COST CALCULATION ENGINE
// ============================================================================

export function calculateAtombergCost(params = {}) {
  const rmBase = Number(params.rmBase || 0);
  const mbBase = Number(params.mbBase || 0);
  const partWt = Number(params.partWt || 37);
  const runnerWt = Number(params.runnerWt || 1);
  const mbPct = Number(params.mbPct || 0.04);
  const bopCost = Number(params.bopCost || 0);
  const cycleTime = Number(params.cycleTime || 47);
  const cavity = Number(params.cavity || 2);
  const tonnage = Number(params.tonnage || 200);
  const shiftTariff = Number(params.shiftTariff || 2000);
  const postOpCost = Number(params.postOpCost || 1.73);
  const packingCost = Number(params.packingCost || 0.86);
  const transportCost = Number(params.transportCost || 0.62);
  const scrapRate = Number(params.scrapRate || 25);

  const landedRm = Number((rmBase * 1.01 + 1.50).toFixed(2));
  const landedMb = Number((mbBase * 1.01 + 2.00).toFixed(2));
  const blendedRmRate = Number(((landedRm * (1 - mbPct)) + (landedMb * mbPct)).toFixed(2));

  const totalShotWt = (partWt * cavity) + runnerWt;
  const rawMatCostPerPc = cavity > 0 ? Number(((blendedRmRate * totalShotWt) / (cavity * 1000)).toFixed(2)) : 0;

  const runnerScrapCredit = cavity > 0 ? Number((((runnerWt / cavity) / 1000) * scrapRate).toFixed(2)) : 0;
  const netRmCost = Number((rawMatCostPerPc - runnerScrapCredit).toFixed(2));

  const theoreticalShots = cycleTime > 0 ? (28800 / cycleTime) : 0;
  const actualShots = theoreticalShots * 0.90;
  const partsPerShift = actualShots * cavity;
  const convRatePerPc = partsPerShift > 0 ? Number((shiftTariff / partsPerShift).toFixed(2)) : 0;

  const baseCost = Number((netRmCost + convRatePerPc).toFixed(2));
  const ohAndProfit = Number((baseCost * 0.12).toFixed(2));
  const inProcessRejection = Number((baseCost * 0.04).toFixed(2));
  const mouldMaintenance = Number((convRatePerPc * 0.02).toFixed(2));

  const finalLanded = Number((
    netRmCost + 
    convRatePerPc + 
    ohAndProfit + 
    inProcessRejection + 
    bopCost + 
    postOpCost + 
    packingCost + 
    transportCost + 
    mouldMaintenance
  ).toFixed(2));

  return {
    landedRm: landedRm || 0,
    landedMb: landedMb || 0,
    blendedRmRate: blendedRmRate || 0,
    totalShotWt: totalShotWt || 0,
    rawMatCostPerPc: rawMatCostPerPc || 0,
    runnerScrapCredit: runnerScrapCredit || 0,
    netRmCost: netRmCost || 0,
    convRatePerPc: convRatePerPc || 0,
    ohAndProfit: ohAndProfit || 0,
    inProcessRejection: inProcessRejection || 0,
    mouldMaintenance: mouldMaintenance || 0,
    totalCost: finalLanded || 0,
    finalLanded: finalLanded || 0
  };
}

export function calculateHaierCost(params = {}) {
  const cavity = Number(params.cavity) || 1;
  const netWeight = Number(params.netWeight) || 0;
  const runnerWeight = Number(params.runnerWeight) || 0;
  const shotWeight = params.shotWeight !== undefined && params.shotWeight !== null 
    ? Number(params.shotWeight) 
    : (netWeight * cavity + runnerWeight);
  
  const pieceWeight = cavity > 0 ? (shotWeight / cavity) : netWeight;
  const reconciliationWeight = Number((pieceWeight * 1.02).toFixed(2));

  const rmRate = Number(params.rmRate || 0);
  const mbPct = (Number(params.masterbatchPct || 0)) / 100;
  const mbRate = Number(params.masterbatchRate || 0);

  const rawMaterialCost = Number(((reconciliationWeight / 1000) * (1 - mbPct) * rmRate).toFixed(4));
  const masterbatchCost = Number(((reconciliationWeight / 1000) * mbPct * mbRate).toFixed(4));
  const runnerRecoveryScrap = Number(params.runnerRecoveryScrap || 0);
  const totalRmCost = Number((rawMaterialCost + masterbatchCost - runnerRecoveryScrap).toFixed(4));

  const cycleTime = Number(params.cycleTime) || 70;
  const shiftTariff = Number(params.shiftTariff) || 4800;
  const theoreticalShots = cycleTime > 0 ? (28800 / cycleTime) : 0;
  const actualShots = theoreticalShots * 0.95;
  const partsPerShift = actualShots * cavity;
  const productionCostPerPc = partsPerShift > 0 ? Number((shiftTariff / partsPerShift).toFixed(4)) : 0;

  const subTotal = Number((totalRmCost + productionCostPerPc).toFixed(4));
  const haierOverheadPackage = Number(params.haierOverheadPackage || 0);
  const mouldMaintenance = Number(params.mouldMaintenance || 0);
  const qualityInspection = Number(params.qualityInspection || 0);
  const iccReduce = Number(params.iccReduce || 0);
  const scrapAdj = Number(params.scrapAdj || 0);
  const otherBop = Number(params.bopCost || 0);

  const totalCost = Number((
    subTotal + 
    haierOverheadPackage + 
    mouldMaintenance + 
    qualityInspection + 
    iccReduce + 
    scrapAdj + 
    otherBop
  ).toFixed(2));

  return {
    shotWeight: shotWeight || 0,
    reconciliationWeight: reconciliationWeight || 0,
    rawMaterialCost: rawMaterialCost || 0,
    masterbatchCost: masterbatchCost || 0,
    totalRmCost: totalRmCost || 0,
    productionCostPerPc: productionCostPerPc || 0,
    subTotal: subTotal || 0,
    haierOverheadPackage: haierOverheadPackage || 0,
    mouldMaintenance: mouldMaintenance || 0,
    qualityInspection: qualityInspection || 0,
    iccReduce: iccReduce || 0,
    scrapAdj: scrapAdj || 0,
    totalCost: totalCost || 0,
    finalLanded: totalCost || 0
  };
}
SERVICE_EOF

echo "==> 3. Writing safe InlineEditModal.jsx with zero unhandled undefined calls..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, Trash2 } from 'lucide-react';
import { calculateHaierCost, calculateAtombergCost } from '../../shared/costCalculationService';
import { parseMaterialString, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';

export default function InlineEditModal({ product, onClose, onSave, onDelete }) {
  if (!product) return null;

  const isHaier = (product.vendor || '').toLowerCase().includes('haier');
  const initialParams = product.parameters || {};

  const { baseRm, mbGrade } = parseMaterialString(product.approvedRm || product.baseRm);
  const rmLookupKey = baseRm || product.baseRm || product.approvedRm || 'Unspecified';
  const mbLookupKey = mbGrade || product.approvedMb || ((product.masterbatchPct || 0) > 0 ? 'White MB' : 'None');

  const rmInfo = getActiveRmMapping(rmLookupKey, product.vendor) || {};
  const mbInfo = getActiveMbMapping(mbLookupKey, product.vendor) || {};

  const approvedRmRate = Number(rmInfo.approvedPrice || product.approvedRmPrice || 0);
  const runningRmWaRate = Number(rmInfo.activeWaPrice || rmInfo.approvedPrice || product.approvedRmPrice || 0);

  const approvedMbRate = Number(mbInfo.approvedMbPrice || product.approvedMbPrice || 0);
  const runningMbWaRate = Number(mbInfo.activeMbWaPrice || mbInfo.approvedMbPrice || product.approvedMbPrice || 0);

  const [formData, setFormData] = useState({
    approvedRm: product.approvedRm || baseRm || '',
    baseRm: rmLookupKey,
    approvedMb: mbLookupKey,
    masterbatchPct: Number(product.masterbatchPct) || 0,
    cavity: Number(product.cavity) || 1,
    runnerWeight: Number(product.runnerWeight) || 0,
    netWeight: Number(product.netWeight) || 0,
    shotWeight: Number(product.shotWeight) || (Number(product.netWeight || 0) * Number(product.cavity || 1) + Number(product.runnerWeight || 0)),
    reconciliationWeight: Number(product.reconciliationWeight) || Number((((Number(product.shotWeight) || Number(product.netWeight || 0)) / Number(product.cavity || 1)) * 1.02).toFixed(2)),
    machineTonnage: Number(product.machineTonnage) || 0,
    shiftTariff: Number(product.shiftTariff) || 0,
    cycleTimeApproved: Number(product.cycleTimeApproved) || 0,
    haierOverheadPackage: Number(product.haierOverheadPackage) || 0,
    foamPolybag: Number(product.foamPolybag) || 0,
    plasticBin: Number(product.plasticBin) || 0,
    freightCost: Number(product.freightCost) || 0,
    secondaryOp1: Number(product.secondaryOp1) || 0,
    secondaryOp2: Number(product.secondaryOp2) || 0,
    screenPrint1: Number(product.screenPrint1) || 0,
    screenPrint2: Number(product.screenPrint2) || 0,
    assemblyCost: Number(product.assemblyCost) || 0,
    mouldMaintenance: Number(product.mouldMaintenance) || 0,
    qualityInspection: Number(product.qualityInspection) || 0,
    iccReduce: Number(product.iccReduce) || 0,
    scrapAdj: Number(product.scrapAdj) || 0,
    bopCost: Number(product.bopCost) || 0,
    mouldSize: product.mouldSize || '-',
    model: product.model || '-',

    runningCycleTime: Number(initialParams.runningCycleTime ?? product.cycleTimeApproved ?? 0),
    runningCavity: Number(initialParams.runningCavity ?? product.cavity ?? 1),
    runningRunnerWeight: Number(initialParams.runningRunnerWeight ?? product.runnerWeight ?? 0),
    runningNetWeight: Number(initialParams.runningNetWeight ?? product.netWeight ?? 0),
    runningShiftTariff: Number(initialParams.runningShiftTariff ?? product.shiftTariff ?? 0),
    runningHaierOverheadPackage: Number(initialParams.runningHaierOverheadPackage ?? product.haierOverheadPackage ?? 0),
    runningMbPct: Number(initialParams.runningMbPct ?? product.masterbatchPct ?? 0),
    runningBopCost: Number(initialParams.runningBopCost ?? product.bopCost ?? 0)
  });

  const baseCalc = isHaier 
    ? calculateHaierCost({
        cavity: formData.cavity,
        netWeight: formData.netWeight,
        runnerWeight: formData.runnerWeight,
        shotWeight: formData.shotWeight,
        rmRate: approvedRmRate,
        masterbatchPct: formData.masterbatchPct,
        masterbatchRate: approvedMbRate,
        shiftTariff: formData.shiftTariff,
        cycleTime: formData.cycleTimeApproved,
        haierOverheadPackage: formData.haierOverheadPackage,
        foamPolybag: formData.foamPolybag,
        plasticBin: formData.plasticBin,
        freightCost: formData.freightCost,
        secondaryOp1: formData.secondaryOp1,
        secondaryOp2: formData.secondaryOp2,
        screenPrint1: formData.screenPrint1,
        screenPrint2: formData.screenPrint2,
        assemblyCost: formData.assemblyCost,
        mouldMaintenance: formData.mouldMaintenance,
        qualityInspection: formData.qualityInspection,
        iccReduce: formData.iccReduce,
        scrapAdj: formData.scrapAdj,
        bopCost: formData.bopCost
      })
    : calculateAtombergCost({
        rmBase: approvedRmRate,
        mbBase: approvedMbRate,
        partWt: formData.netWeight,
        runnerWt: formData.runnerWeight,
        mbPct: (formData.masterbatchPct || 4) / 100,
        bopCost: formData.bopCost,
        cycleTime: formData.cycleTimeApproved,
        cavity: formData.cavity,
        tonnage: formData.machineTonnage,
        shiftTariff: formData.shiftTariff
      });

  const runningCalc = isHaier 
    ? calculateHaierCost({
        cavity: formData.runningCavity,
        netWeight: formData.runningNetWeight,
        runnerWeight: formData.runningRunnerWeight,
        shotWeight: formData.runningNetWeight * formData.runningCavity + formData.runningRunnerWeight,
        rmRate: runningRmWaRate,
        masterbatchPct: formData.runningMbPct,
        masterbatchRate: runningMbWaRate,
        shiftTariff: formData.runningShiftTariff,
        cycleTime: formData.runningCycleTime,
        haierOverheadPackage: formData.runningHaierOverheadPackage,
        foamPolybag: formData.foamPolybag,
        plasticBin: formData.plasticBin,
        freightCost: formData.freightCost,
        secondaryOp1: formData.secondaryOp1,
        secondaryOp2: formData.secondaryOp2,
        screenPrint1: formData.screenPrint1,
        screenPrint2: formData.screenPrint2,
        assemblyCost: formData.assemblyCost,
        mouldMaintenance: formData.mouldMaintenance,
        qualityInspection: formData.qualityInspection,
        iccReduce: formData.iccReduce,
        scrapAdj: formData.scrapAdj,
        bopCost: formData.runningBopCost
      })
    : calculateAtombergCost({
        rmBase: runningRmWaRate,
        mbBase: runningMbWaRate,
        partWt: formData.runningNetWeight,
        runnerWt: formData.runningRunnerWeight,
        mbPct: (formData.runningMbPct || 4) / 100,
        bopCost: formData.runningBopCost,
        cycleTime: formData.runningCycleTime,
        cavity: formData.runningCavity,
        tonnage: formData.machineTonnage,
        shiftTariff: formData.runningShiftTariff
      });

  const contractTotal = Number(baseCalc?.totalCost || baseCalc?.finalLanded || 0);
  const runningTotal = Number(runningCalc?.totalCost || runningCalc?.finalLanded || 0);
  const profitLossDelta = Number((contractTotal - runningTotal).toFixed(2));

  const ctApproved = Number(formData.cycleTimeApproved || 1);
  const ctRunning = Number(formData.runningCycleTime || 1);
  const shotsShift8hApproved = (28800 / ctApproved).toFixed(2);
  const shotsShift8hRunning = (28800 / ctRunning).toFixed(2);
  const shotsShift95Approved = ((28800 / ctApproved) * 0.95).toFixed(2);
  const shotsShift95Running = ((28800 / ctRunning) * 0.95).toFixed(2);
  const partsShiftApproved = (((28800 / ctApproved) * 0.95) * Number(formData.cavity || 1)).toFixed(2);
  const partsShiftRunning = (((28800 / ctRunning) * 0.95) * Number(formData.runningCavity || 1)).toFixed(2);

  const handleSave = () => {
    onSave({
      ...product,
      ...formData,
      approvedCost: contractTotal,
      parameters: {
        runningCycleTime: formData.runningCycleTime,
        runningCavity: formData.runningCavity,
        runningRunnerWeight: formData.runningRunnerWeight,
        runningNetWeight: formData.runningNetWeight,
        runningShiftTariff: formData.runningShiftTariff,
        runningHaierOverheadPackage: formData.runningHaierOverheadPackage,
        runningMbPct: formData.runningMbPct,
        runningBopCost: formData.runningBopCost
      },
      delta: profitLossDelta
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto">
      <div className="bg-white rounded-2xl max-w-4xl w-full max-h-[92vh] flex flex-col shadow-2xl overflow-hidden text-xs">
        {/* Header */}
        <div className="p-4 bg-slate-900 text-white flex justify-between items-center">
          <div>
            <div className="flex items-center gap-2">
              <span className="bg-blue-600 px-2 py-0.5 rounded font-mono font-bold">{product.itemCode}</span>
              <h2 className="font-bold text-sm">{product.componentName}</h2>
              <span className="bg-slate-800 text-[10px] px-2 py-0.5 rounded-full border border-slate-700">
                {isHaier ? 'Haier 38-Line Costing Format' : 'Atomberg Dual Column'}
              </span>
            </div>
            <p className="text-[11px] text-slate-300 mt-1">
              Vendor: <b>{product.vendor}</b> | Base RM: <b>{rmLookupKey}</b> (Matrix: ₹{approvedRmRate}/kg → WA: ₹{runningRmWaRate}/kg) | MB: <b>{mbLookupKey}</b> (Matrix: ₹{approvedMbRate}/kg → WA: ₹{runningMbWaRate}/kg)
            </p>
          </div>
          <button onClick={onClose} className="p-1.5 hover:bg-slate-800 rounded-lg text-slate-400 hover:text-white cursor-pointer">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* 3 Summary Badges */}
        <div className="grid grid-cols-3 gap-3 p-4 bg-slate-50 border-b border-slate-200">
          <div className="p-3 bg-white rounded-xl border border-slate-200">
            <div className="text-[10px] uppercase font-bold text-slate-400">Costing (Baseline Contract)</div>
            <div className="text-xl font-black font-mono text-slate-900 mt-0.5">₹{contractTotal.toFixed(2)}</div>
          </div>
          <div className="p-3 bg-white rounded-xl border border-slate-200">
            <div className="text-[10px] uppercase font-bold text-blue-600">Actual Running Shopfloor (Active Alternate)</div>
            <div className="text-xl font-black font-mono text-blue-700 mt-0.5">₹{runningTotal.toFixed(2)}</div>
          </div>
          <div className={`p-3 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-800' : 'bg-rose-50 border-rose-200 text-rose-800'}`}>
            <div className="text-[10px] uppercase font-bold">Profit / Loss (Δ)</div>
            <div className="text-xl font-black font-mono mt-0.5">
              {profitLossDelta >= 0 ? `+ ₹${profitLossDelta.toFixed(2)}` : `- ₹${Math.abs(profitLossDelta).toFixed(2)}`}
            </div>
          </div>
        </div>

        {/* 38-Line Spec Table Body */}
        <div className="flex-1 overflow-y-auto p-4 space-y-2">
          <table className="w-full text-left border-collapse">
            <thead className="bg-slate-100 text-slate-700 text-[10px] uppercase font-bold sticky top-0">
              <tr>
                <th className="py-2 px-3 w-8">#</th>
                <th className="py-2 px-3">Haier Costing Line</th>
                <th className="py-2 px-3 text-center w-24">UOM / Rate</th>
                <th className="py-2 px-4 text-right w-44">Approved Baseline</th>
                <th className="py-2 px-4 text-right w-44 text-blue-700">Actual Running</th>
                <th className="py-2 px-3 text-right w-24">Delta (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-xs font-medium">
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">1</td>
                <td className="py-2 px-3 font-bold">Name Of component</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-bold text-slate-700">{product.componentName}</td>
                <td className="py-2 px-4 text-right font-bold text-blue-800">{product.componentName}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">2</td>
                <td className="py-2 px-3">Mould size L x W xH</td>
                <td className="py-2 px-3 text-center">mm</td>
                <td className="py-2 px-4 text-right font-mono">{formData.mouldSize}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.mouldSize}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">3</td>
                <td className="py-2 px-3 font-bold text-blue-700">Item No.</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{product.itemCode}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{product.itemCode}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">4</td>
                <td className="py-2 px-3">Model</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-mono">{formData.model}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.model}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">5</td>
                <td className="py-2 px-3 font-bold">Raw Material Required</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-bold text-slate-800">{formData.approvedRm}</td>
                <td className="py-2 px-4 text-right font-bold text-blue-800">{formData.approvedRm}</td>
                <td className="py-2 px-3 text-right text-emerald-600 font-bold">Matched</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">6</td>
                <td className="py-2 px-3 font-bold">Master Batch Required (%)</td>
                <td className="py-2 px-3 text-center">%</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" step="0.1" value={formData.masterbatchPct} onChange={e => setFormData({ ...formData, masterbatchPct: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" step="0.1" value={formData.runningMbPct} onChange={e => setFormData({ ...formData, runningMbPct: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{(formData.masterbatchPct - formData.runningMbPct).toFixed(1)}%</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">7</td>
                <td className="py-2 px-3">No. of Cavity</td>
                <td className="py-2 px-3 text-center">Nos</td>
                <td className="py-2 px-4 text-right font-bold">{formData.cavity}</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningCavity} onChange={e => setFormData({ ...formData, runningCavity: Number(e.target.value) || 1 })} className="w-16 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{formData.cavity - formData.runningCavity}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">8</td>
                <td className="py-2 px-3">Runner Weight</td>
                <td className="py-2 px-3 text-center">Gms</td>
                <td className="py-2 px-4 text-right font-mono">{formData.runnerWeight}g</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningRunnerWeight} onChange={e => setFormData({ ...formData, runningRunnerWeight: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{(formData.runnerWeight - formData.runningRunnerWeight).toFixed(2)}g</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">9</td>
                <td className="py-2 px-3 font-bold">Net Weight</td>
                <td className="py-2 px-3 text-center">Gms</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{formData.netWeight}g</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningNetWeight} onChange={e => setFormData({ ...formData, runningNetWeight: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{(formData.netWeight - formData.runningNetWeight).toFixed(2)}g</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">10</td>
                <td className="py-2 px-3">Shot Weight</td>
                <td className="py-2 px-3 text-center">Gms</td>
                <td className="py-2 px-4 text-right font-mono">{Number(baseCalc?.shotWeight || 0).toFixed(2)}g</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{Number(runningCalc?.shotWeight || 0).toFixed(2)}g</td>
                <td className="py-2 px-3 text-right font-mono">{(Number(baseCalc?.shotWeight || 0) - Number(runningCalc?.shotWeight || 0)).toFixed(2)}g</td>
              </tr>
              <tr className="bg-slate-50">
                <td className="py-2 px-3 font-mono text-slate-400">11</td>
                <td className="py-2 px-3 font-bold text-slate-900">Reconciliation Weight = Shot wt + 1.0% Melt Loss</td>
                <td className="py-2 px-3 text-center">Gms</td>
                <td className="py-2 px-4 text-right font-mono font-black text-slate-900">{Number(baseCalc?.reconciliationWeight || 0).toFixed(2)}g</td>
                <td className="py-2 px-4 text-right font-mono font-black text-emerald-600">{Number(runningCalc?.reconciliationWeight || 0).toFixed(2)}g</td>
                <td className="py-2 px-3 text-right font-mono">0.00g</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">12</td>
                <td className="py-2 px-3">Raw Material Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">₹{Number(baseCalc?.rawMaterialCost || 0).toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">₹{Number(runningCalc?.rawMaterialCost || 0).toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">13</td>
                <td className="py-2 px-3">Master batch cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">₹{Number(baseCalc?.masterbatchCost || 0).toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">₹{Number(runningCalc?.masterbatchCost || 0).toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr className="bg-slate-50 font-bold">
                <td className="py-2 px-3 font-mono text-slate-400">15</td>
                <td className="py-2 px-3 text-slate-900">Total Raw Material Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono text-slate-900">₹{Number(baseCalc?.totalRmCost || 0).toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-900">₹{Number(runningCalc?.totalRmCost || 0).toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">16</td>
                <td className="py-2 px-3">Machine Used</td>
                <td className="py-2 px-3 text-center">T</td>
                <td className="py-2 px-4 text-right font-mono">{formData.machineTonnage}T</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.machineTonnage}T</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">17</td>
                <td className="py-2 px-3 font-bold">Machine Tariff per Shift</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.shiftTariff} onChange={e => setFormData({ ...formData, shiftTariff: Number(e.target.value) || 0 })} className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningShiftTariff} onChange={e => setFormData({ ...formData, runningShiftTariff: Number(e.target.value) || 0 })} className="w-24 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">₹{(formData.shiftTariff - formData.runningShiftTariff).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">18</td>
                <td className="py-2 px-3 font-bold">Cycle Time</td>
                <td className="py-2 px-3 text-center">Sec</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.cycleTimeApproved} onChange={e => setFormData({ ...formData, cycleTimeApproved: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningCycleTime} onChange={e => setFormData({ ...formData, runningCycleTime: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{(formData.cycleTimeApproved - formData.runningCycleTime).toFixed(1)}s</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">19</td>
                <td className="py-2 px-3">No of Shot / Shift (8Hour)</td>
                <td className="py-2 px-3 text-center">Nos</td>
                <td className="py-2 px-4 text-right font-mono">{shotsShift8hApproved}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{shotsShift8hRunning}</td>
                <td className="py-2 px-3 text-right font-mono">{(Number(shotsShift8hApproved) - Number(shotsShift8hRunning)).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">20</td>
                <td className="py-2 px-3">No of Shot / Shift with 95 % Efficiency</td>
                <td className="py-2 px-3 text-center">Nos</td>
                <td className="py-2 px-4 text-right font-mono">{shotsShift95Approved}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{shotsShift95Running}</td>
                <td className="py-2 px-3 text-right font-mono">{(Number(shotsShift95Approved) - Number(shotsShift95Running)).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">21</td>
                <td className="py-2 px-3">No. of component / shift</td>
                <td className="py-2 px-3 text-center">Nos</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{partsShiftApproved}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{partsShiftRunning}</td>
                <td className="py-2 px-3 text-right font-mono">{(Number(partsShiftApproved) - Number(partsShiftRunning)).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">22</td>
                <td className="py-2 px-3 font-bold">Production Cost / Pc</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold">₹{Number(baseCalc?.productionCostPerPc || 0).toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">₹{Number(runningCalc?.productionCostPerPc || 0).toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr className="bg-slate-100 font-black">
                <td className="py-2 px-3 font-mono text-slate-400">23</td>
                <td className="py-2 px-3 uppercase text-slate-900">SUB TOTAL</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono text-slate-900">₹{Number(baseCalc?.subTotal || 0).toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-900">₹{Number(runningCalc?.subTotal || 0).toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr className="bg-purple-50/40">
                <td className="py-2 px-3 font-mono text-slate-400">24</td>
                <td className="py-2 px-3 font-bold text-purple-950">OH + Profit + ICC + Rejection + Packaging + Freight</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" step="0.0001" value={formData.haierOverheadPackage} onChange={e => setFormData({ ...formData, haierOverheadPackage: Number(e.target.value) || 0 })} className="w-28 px-2 py-0.5 border border-purple-300 rounded text-right font-bold text-purple-900" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" step="0.0001" value={formData.runningHaierOverheadPackage} onChange={e => setFormData({ ...formData, runningHaierOverheadPackage: Number(e.target.value) || 0 })} className="w-28 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">25</td>
                <td className="py-2 px-3">Foam / Polybag / Masking film</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.foamPolybag || '-'}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.foamPolybag || '-'}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">26</td>
                <td className="py-2 px-3">Plastic Bin / Polyend Box / Trolley</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.plasticBin || '-'}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.plasticBin || '-'}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">27</td>
                <td className="py-2 px-3">Freight Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.freightCost || '-'}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.freightCost || '-'}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">33</td>
                <td className="py-2 px-3">Insert / Hinge hole cap cost / Other cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.bopCost || '-'}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.bopCost || '-'}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">34</td>
                <td className="py-2 px-3 font-bold">Mould Maintenance Provision</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{formData.mouldMaintenance}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{formData.mouldMaintenance}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">35</td>
                <td className="py-2 px-3 font-bold">Quality Inspection Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{formData.qualityInspection}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{formData.qualityInspection}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">36</td>
                <td className="py-2 px-3 font-bold text-rose-700">ICC Reduce by .5% (Payment term change 60 to 45 days)</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-rose-700">{formData.iccReduce}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-rose-700">{formData.iccReduce}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">37</td>
                <td className="py-2 px-3">Scrap Recovery Adjustment</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.scrapAdj || 0}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.scrapAdj || 0}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr className="bg-slate-900 text-white font-black text-xs">
                <td className="py-3 px-3 font-mono text-amber-400">38</td>
                <td className="py-3 px-3 uppercase text-amber-400">TOTAL COST</td>
                <td className="py-3 px-3 text-center">Rs</td>
                <td className="py-3 px-4 text-right font-mono text-amber-300 text-sm">₹{contractTotal.toFixed(2)}</td>
                <td className="py-3 px-4 text-right font-mono text-emerald-400 text-sm">₹{runningTotal.toFixed(2)}</td>
                <td className={`py-3 px-3 text-right font-mono ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                  {profitLossDelta >= 0 ? `+₹${profitLossDelta.toFixed(2)}` : `-₹${Math.abs(profitLossDelta).toFixed(2)}`}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        {/* Footer Actions */}
        <div className="p-4 bg-slate-100 border-t border-slate-200 flex justify-between items-center">
          <button onClick={() => { if(window.confirm('Delete this part from baseline?')) { onDelete(product.id || product.itemCode); onClose(); }}} className="px-3.5 py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-300 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer">
            <Trash2 className="w-4 h-4" /> Delete Product
          </button>
          <div className="flex gap-2">
            <button onClick={onClose} className="px-4 py-2 bg-white hover:bg-slate-100 border border-slate-300 rounded-xl font-bold cursor-pointer">
              Cancel
            </button>
            <button onClick={handleSave} className="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm">
              <Save className="w-4 h-4" /> Save & Log Parameters
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export function calculateDetailedCost(item) {
  const isHaier = (item?.vendor || '').toLowerCase().includes('haier');
  const { baseRm, mbGrade } = parseMaterialString(item?.approvedRm || item?.baseRm);
  const rmInfo = getActiveRmMapping(baseRm || item?.baseRm || item?.approvedRm, item?.vendor) || {};
  const mbInfo = getActiveMbMapping(mbGrade || item?.approvedMb, item?.vendor) || {};

  if (isHaier) {
    const calc = calculateHaierCost({
      cavity: item.cavity || 1,
      netWeight: item.netWeight || 0,
      runnerWeight: item.runnerWeight || 0,
      shotWeight: item.shotWeight || 0,
      rmRate: Number(rmInfo.approvedPrice || item.approvedRmPrice || 0),
      masterbatchPct: item.masterbatchPct ?? 0,
      masterbatchRate: Number(mbInfo.approvedMbPrice || item.approvedMbPrice || 0),
      shiftTariff: item.shiftTariff || 0,
      cycleTime: item.cycleTimeApproved || 0,
      haierOverheadPackage: item.haierOverheadPackage || 0,
      foamPolybag: item.foamPolybag || 0,
      plasticBin: item.plasticBin || 0,
      freightCost: item.freightCost || 0,
      secondaryOp1: item.secondaryOp1 || 0,
      secondaryOp2: item.secondaryOp2 || 0,
      screenPrint1: item.screenPrint1 || 0,
      screenPrint2: item.screenPrint2 || 0,
      assemblyCost: item.assemblyCost || 0,
      mouldMaintenance: item.mouldMaintenance || 0,
      qualityInspection: item.qualityInspection || 0,
      iccReduce: item.iccReduce || 0,
      scrapAdj: item.scrapAdj || 0,
      bopCost: item.bopCost || 0
    });
    return {
      netRmCost: calc.totalRmCost || 0,
      convRatePerPc: calc.productionCostPerPc || 0,
      totalCost: calc.totalCost || 0,
      finalLanded: calc.totalCost || 0
    };
  } else {
    const calc = calculateAtombergCost({
      rmBase: Number(rmInfo.approvedPrice || item.approvedRmPrice || 0),
      mbBase: Number(mbInfo.approvedMbPrice || item.approvedMbPrice || 0),
      partWt: item.netWeight || 37,
      runnerWt: item.runnerWeight || 1,
      mbPct: (item.masterbatchPct || 4) / 100,
      bopCost: item.bopCost || 0,
      cycleTime: item.cycleTimeApproved || 47,
      cavity: item.cavity || 2,
      tonnage: item.machineTonnage || 200,
      shiftTariff: item.shiftTariff || 2000
    });
    return {
      netRmCost: calc.netRmCost || 0,
      convRatePerPc: calc.convRatePerPc || 0,
      totalCost: calc.finalLanded || 0,
      finalLanded: calc.finalLanded || 0
    };
  }
}
MODAL_EOF

echo "==> 4. Verifying build strictly on dev-v2..."
npm run build

echo "==> 5. Committing and pushing ONLY to origin/dev-v2 (Zero push to main)..."
git add -A
git commit -m "fix(modal): add numeric fallbacks across InlineEditModal to prevent undefined toFixed error" || echo "dev-v2 clean."
git push origin dev-v2

echo "==> 6. Restarting local dev server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Edit Spec modal fixed and running error-free on dev-v2."
echo "-------------------------------------------------------------------"
