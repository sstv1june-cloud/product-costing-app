#!/usr/bin/env bash
set -e

# 1. Update InlineEditModal.jsx with the FULL parameter matrix and exact formula engine
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState, useEffect } from 'react';
import { X, Save, RotateCcw, AlertTriangle, ShieldCheck, Check, Info } from 'lucide-react';
import { getActiveRmMapping } from '../../shared/masterStore';

export function calculateDetailedCost(params, isBaseline = false) {
  const cavity = Math.max(1, Number(params.cavity) || 1);
  const netWeight = Number(params.netWeight) || 0;
  const runnerWeight = Number(params.runnerWeight) || 0;
  const rmRate = Number(params.rmRate) || 0;
  const mbPct = Number(params.masterbatchPct) || 0;
  const mbRate = Number(params.masterbatchRate) || 0;
  const bopCost = Number(params.bopCost) || 0;
  const cycleTime = Math.max(1, Number(params.cycleTime) || 1);
  const machineTonnage = Number(params.machineTonnage) || 450;
  
  // Machine shift tariff: 4600 for <=450T, 5760 for >=650T, 2000 for 200T (or hourlyRate * 8)
  const defaultTariff = machineTonnage >= 650 ? 5760 : (machineTonnage <= 200 ? 2000 : 4600);
  const shiftTariff = Number(params.shiftTariff || (params.hourlyRate ? params.hourlyRate * 8 : defaultTariff));

  // 1. Weight Calculations
  const shotWeightPerPiece = ((netWeight * cavity) + runnerWeight) / cavity;
  const meltLossPct = 1.0; // 1% melt loss
  const reconciliationWeight = shotWeightPerPiece * (1 + meltLossPct / 100);

  // 2. Material Cost Calculations
  const pureRmFraction = Math.max(0, 1 - (mbPct / 100));
  const mbFraction = mbPct / 100;

  const rawMaterialCost = (reconciliationWeight / 1000) * rmRate * pureRmFraction;
  const masterbatchCost = (reconciliationWeight / 1000) * (mbRate > 0 ? mbRate : (rmRate * 1.9)) * mbFraction;
  
  // Runner recovery credit: (runnerWeight / cavity / 1000) * (RM Rate * 25%)
  const runnerCredit = (runnerWeight / cavity / 1000) * (rmRate * 0.25);
  const totalRmCost = (rawMaterialCost + masterbatchCost) - runnerCredit;

  // 3. Machine Conversion Cost
  // 8 Hours = 28,800 seconds
  const partsPerShift = ((28800 / cycleTime) * cavity) * 0.90; // 90% efficiency
  const conversionCost = partsPerShift > 0 ? (shiftTariff / partsPerShift) : (shiftTariff / ((28800 / cycleTime) * cavity));

  // 4. Overheads / Other Post Ops (if applicable)
  const otherCost = Number(params.otherCost || 0);

  // Total Unit Cost
  const totalCost = totalRmCost + conversionCost + bopCost + otherCost;

  return {
    cavity,
    netWeight,
    runnerWeight,
    shotWeightPerPiece,
    reconciliationWeight,
    rawMaterialCost,
    masterbatchCost,
    runnerCredit,
    totalRmCost,
    shiftTariff,
    partsPerShift,
    conversionCost,
    bopCost,
    otherCost,
    totalCost
  };
}

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const rmInfo = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');

  // Baseline Standards
  const baseCavity = Number(item.cavity || 1);
  const baseNetWt = Number(item.netWeight || 197);
  const baseRunnerWt = Number(item.runnerWeight || 40);
  const baseMbPct = Number(item.masterbatchPct ?? (item.itemCode === '0060217978E' ? 3.5 : (item.vendor === 'Atomberg' ? 4.0 : 0.0)));
  const baseMbRate = Number(item.masterbatchRate || (item.itemCode === '0060217978E' ? 240.00 : (item.vendor === 'Atomberg' ? 258.54 : 0.0)));
  const baseBopCost = Number(item.bopCost || 0.0);
  const baseCycle = Number(item.cycleTimeApproved || item.cycleTime || 48);
  const baseTonnage = Number(item.machineTonnage || 450);
  const baseRmRate = Number(item.approvedRmRate || rmInfo.approvedPrice || (item.itemCode === '0060217978E' ? 103.08 : 136.20));
  const baseTariff = Number(item.parameters?.shiftTariff || (baseTonnage >= 650 ? 5760 : (baseTonnage <= 200 ? 2000 : 4600)));

  // Actual Running State
  const params = item.parameters || {};
  const [runningCavity, setRunningCavity] = useState(params.runningCavity ?? baseCavity);
  const [runningNetWeight, setRunningNetWeight] = useState(params.runningNetWeight ?? baseNetWt);
  const [runningRunnerWeight, setRunningRunnerWeight] = useState(params.runningRunnerWeight ?? baseRunnerWt);
  const [runningMbPct, setRunningMbPct] = useState(params.runningMbPct ?? baseMbPct);
  const [runningBopCost, setRunningBopCost] = useState(params.runningBopCost ?? baseBopCost);
  const [runningCycleTime, setRunningCycleTime] = useState(params.runningCycleTime ?? baseCycle);
  const [runningTonnage, setRunningTonnage] = useState(params.runningTonnage ?? baseTonnage);
  const [reason, setReason] = useState("Shopfloor parameters & MB tuning");

  const actualRmRate = Number(rmInfo.activeWaPrice || baseRmRate);
  const actualTariff = Number(params.runningShiftTariff ?? (runningTonnage >= 650 ? 5760 : (runningTonnage <= 200 ? 2000 : 4600)));

  const baselineCalc = calculateDetailedCost({
    cavity: baseCavity,
    netWeight: baseNetWt,
    runnerWeight: baseRunnerWt,
    rmRate: baseRmRate,
    masterbatchPct: baseMbPct,
    masterbatchRate: baseMbRate,
    bopCost: baseBopCost,
    cycleTime: baseCycle,
    machineTonnage: baseTonnage,
    shiftTariff: baseTariff
  }, true);

  const runningCalc = calculateDetailedCost({
    cavity: Number(runningCavity),
    netWeight: Number(runningNetWeight),
    runnerWeight: Number(runningRunnerWeight),
    rmRate: actualRmRate,
    masterbatchPct: Number(runningMbPct),
    masterbatchRate: baseMbRate,
    bopCost: Number(runningBopCost),
    cycleTime: Number(runningCycleTime),
    machineTonnage: Number(runningTonnage),
    shiftTariff: actualTariff
  }, false);

  const costVariance = Number((runningCalc.totalCost - baselineCalc.totalCost).toFixed(2));

  const handleSave = () => {
    onSave({
      updatedItem: {
        ...item,
        masterbatchPct: Number(runningMbPct),
        bopCost: Number(runningBopCost),
        parameters: {
          ...item.parameters,
          runningCavity: Number(runningCavity),
          runningNetWeight: Number(runningNetWeight),
          runningRunnerWeight: Number(runningRunnerWeight),
          runningMbPct: Number(runningMbPct),
          runningBopCost: Number(runningBopCost),
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
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto">
        
        {/* Modal Top Header */}
        <div className="flex justify-between items-center border-b pb-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="bg-blue-600 text-white font-mono px-2 py-0.5 rounded font-bold">{item.itemCode}</span>
              <h2 className="text-sm font-bold text-slate-900">{item.componentName}</h2>
            </div>
            <p className="text-[11px] text-slate-500 font-mono mt-0.5">
              Vendor: <span className="font-bold text-slate-700">{item.vendor}</span> | Model: {item.model} | Tool Size: {item.mouldSize || '1070*720*650'}
            </p>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* 3 KPI Summary Cards */}
        <div className="grid grid-cols-3 gap-3">
          <div className="bg-slate-100 p-3 rounded-xl border border-slate-200">
            <span className="text-[10px] font-bold text-slate-500 uppercase block">APPROVED BASELINE CONTRACT</span>
            <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">₹{baselineCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-slate-500 font-mono">RM: ₹{baselineCalc.totalRmCost.toFixed(2)} | Conv: ₹{baselineCalc.conversionCost.toFixed(2)}</span>
          </div>

          <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
            <span className="text-[10px] font-bold text-blue-700 uppercase block">ACTUAL RUNNING SHOPFLOOR</span>
            <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{runningCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-blue-600 font-mono">RM: ₹{runningCalc.totalRmCost.toFixed(2)} | Conv: ₹{runningCalc.conversionCost.toFixed(2)}</span>
          </div>

          <div className={`p-3 rounded-xl border ${costVariance <= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
            <span className="text-[10px] font-bold text-slate-600 uppercase block">COST VARIANCE (Δ)</span>
            <span className={`text-2xl font-black font-mono mt-1 block ${costVariance <= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
              ₹ {costVariance <= 0 ? `${costVariance.toFixed(2)}` : `+${costVariance.toFixed(2)}`}
            </span>
            <span className="text-[10px] font-semibold">{costVariance <= 0 ? 'Cost Optimization (Profit)' : 'Cost Escalation (Loss)'}</span>
          </div>
        </div>

        {/* FULL 18-LINE PARAMETER TABLE WITH EXACT FORMULAS */}
        <div className="border border-slate-200 rounded-xl overflow-hidden">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0">
              <tr>
                <th className="p-2.5 w-12 text-center">#</th>
                <th className="p-2.5">PARAMETER / SPEC LINE</th>
                <th className="p-2.5 w-16 text-center">UOM</th>
                <th className="p-2.5 text-right w-44 bg-slate-200/50">APPROVED BASELINE</th>
                <th className="p-2.5 text-left w-52 bg-blue-100/50">ACTUAL RUNNING (SHOPFLOOR)</th>
                <th className="p-2.5 text-right w-24">DELTA (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">

              {/* 1. Header Information */}
              <tr className="bg-slate-50/50">
                <td className="p-2 text-center font-mono text-slate-400">1</td>
                <td className="p-2 font-bold text-slate-700">Name Of Component</td>
                <td className="p-2 text-center font-mono">-</td>
                <td className="p-2 text-right font-semibold bg-slate-50">{item.componentName}</td>
                <td className="p-2 bg-blue-50/30 font-semibold">{item.componentName}</td>
                <td className="p-2 text-right font-mono text-slate-400">-</td>
              </tr>

              <tr className="bg-slate-50/50">
                <td className="p-2 text-center font-mono text-slate-400">2</td>
                <td className="p-2 font-bold text-slate-700">Mould Size L * W * H</td>
                <td className="p-2 text-center font-mono">mm</td>
                <td className="p-2 text-right font-mono bg-slate-50">{item.mouldSize || '1070*720*650'}</td>
                <td className="p-2 bg-blue-50/30 font-mono">{item.mouldSize || '1070*720*650'}</td>
                <td className="p-2 text-right font-mono text-slate-400">-</td>
              </tr>

              {/* 3. RM Mapping Row */}
              <tr className="bg-amber-50/30">
                <td className="p-2 text-center font-mono text-slate-400">3</td>
                <td className="p-2 font-bold text-slate-900">Approved RM Grade (Locked & Linked to RM Sheet)</td>
                <td className="p-2 text-center font-mono">-</td>
                <td className="p-2 text-right font-mono font-bold bg-slate-50 text-slate-900">
                  {item.approvedRm} (₹{baseRmRate.toFixed(2)})
                </td>
                <td className="p-2 bg-blue-50/40 font-mono font-bold text-blue-950">
                  {rmInfo.activeRmName} (₹{actualRmRate.toFixed(2)})
                </td>
                <td className="p-2 text-right font-mono font-bold">
                  {(actualRmRate - baseRmRate).toFixed(2)}
                </td>
              </tr>

              {/* 4. Masterbatch % */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">4</td>
                <td className="p-2 font-bold text-purple-950">
                  Masterbatch Required {baseMbRate > 0 ? `(MB Rate: ₹${baseMbRate.toFixed(2)}/kg)` : ''}
                </td>
                <td className="p-2 text-center font-mono">%</td>
                <td className="p-2 text-right font-mono font-bold bg-slate-50">{baseMbPct.toFixed(2)}%</td>
                <td className="p-2 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.1"
                    value={runningMbPct}
                    onChange={e => setRunningMbPct(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded"
                  />
                </td>
                <td className="p-2 text-right font-mono font-bold text-purple-700">
                  {(Number(runningMbPct) - baseMbPct).toFixed(2)}%
                </td>
              </tr>

              {/* 5. BOP / Insert Cost */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">5</td>
                <td className="p-2 font-bold text-slate-900">Inserts / BOP Component Cost</td>
                <td className="p-2 text-center font-mono">₹/pc</td>
                <td className="p-2 text-right font-mono bg-slate-50">₹{baseBopCost.toFixed(2)}</td>
                <td className="p-2 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.01"
                    value={runningBopCost}
                    onChange={e => setRunningBopCost(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded"
                  />
                </td>
                <td className="p-2 text-right font-mono">
                  ₹{(Number(runningBopCost) - baseBopCost).toFixed(2)}
                </td>
              </tr>

              {/* 6. Cavity */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">6</td>
                <td className="p-2 font-bold text-slate-900">No. of Cavity</td>
                <td className="p-2 text-center font-mono">Nos</td>
                <td className="p-2 text-right font-mono font-bold bg-slate-50">{baseCavity}</td>
                <td className="p-2 bg-blue-50/40">
                  <input
                    type="number"
                    value={runningCavity}
                    onChange={e => setRunningCavity(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded"
                  />
                </td>
                <td className="p-2 text-right font-mono">{Number(runningCavity) - baseCavity}</td>
              </tr>

              {/* 7. Runner Weight */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">7</td>
                <td className="p-2 font-bold text-slate-900">Runner Weight</td>
                <td className="p-2 text-center font-mono">Gms</td>
                <td className="p-2 text-right font-mono bg-slate-50">{baseRunnerWt}g</td>
                <td className="p-2 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.5"
                    value={runningRunnerWeight}
                    onChange={e => setRunningRunnerWeight(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded"
                  />
                </td>
                <td className="p-2 text-right font-mono">{(Number(runningRunnerWeight) - baseRunnerWt).toFixed(1)}g</td>
              </tr>

              {/* 8. Net Weight */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">8</td>
                <td className="p-2 font-bold text-slate-900">Net Weight</td>
                <td className="p-2 text-center font-mono">Gms</td>
                <td className="p-2 text-right font-mono font-bold bg-slate-50">{baseNetWt}g</td>
                <td className="p-2 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.5"
                    value={runningNetWeight}
                    onChange={e => setRunningNetWeight(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded"
                  />
                </td>
                <td className="p-2 text-right font-mono font-bold">{(Number(runningNetWeight) - baseNetWt).toFixed(1)}g</td>
              </tr>

              {/* 9. Shot Weight */}
              <tr className="bg-slate-50/40">
                <td className="p-2 text-center font-mono text-slate-400">9</td>
                <td className="p-2 font-bold text-slate-700">Shot Weight (Calculated / pc)</td>
                <td className="p-2 text-center font-mono">Gms</td>
                <td className="p-2 text-right font-mono bg-slate-50">{baselineCalc.shotWeightPerPiece.toFixed(2)}g</td>
                <td className="p-2 bg-blue-50/30 font-mono">{runningCalc.shotWeightPerPiece.toFixed(2)}g</td>
                <td className="p-2 text-right font-mono">{(runningCalc.shotWeightPerPiece - baselineCalc.shotWeightPerPiece).toFixed(2)}g</td>
              </tr>

              {/* 10. Reconciliation Weight */}
              <tr className="bg-slate-50/40">
                <td className="p-2 text-center font-mono text-slate-400">10</td>
                <td className="p-2 font-bold text-slate-700">Reconciliation Weight (Shot wt + 1.0% Melt Loss)</td>
                <td className="p-2 text-center font-mono">Gms</td>
                <td className="p-2 text-right font-mono bg-slate-50">{baselineCalc.reconciliationWeight.toFixed(2)}g</td>
                <td className="p-2 bg-blue-50/30 font-mono">{runningCalc.reconciliationWeight.toFixed(2)}g</td>
                <td className="p-2 text-right font-mono">{(runningCalc.reconciliationWeight - baselineCalc.reconciliationWeight).toFixed(2)}g</td>
              </tr>

              {/* 11. Raw Material Cost */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">11</td>
                <td className="p-2 font-bold text-slate-900">Raw Material Cost</td>
                <td className="p-2 text-center font-mono">₹</td>
                <td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.rawMaterialCost.toFixed(2)}</td>
                <td className="p-2 bg-blue-50/30 font-mono font-bold">₹{runningCalc.rawMaterialCost.toFixed(2)}</td>
                <td className="p-2 text-right font-mono">₹{(runningCalc.rawMaterialCost - baselineCalc.rawMaterialCost).toFixed(2)}</td>
              </tr>

              {/* 12. Master Batch Cost */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">12</td>
                <td className="p-2 font-bold text-purple-950">Master Batch Cost</td>
                <td className="p-2 text-center font-mono">₹</td>
                <td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.masterbatchCost.toFixed(2)}</td>
                <td className="p-2 bg-blue-50/30 font-mono font-bold">₹{runningCalc.masterbatchCost.toFixed(2)}</td>
                <td className="p-2 text-right font-mono">₹{(runningCalc.masterbatchCost - baselineCalc.masterbatchCost).toFixed(2)}</td>
              </tr>

              {/* 13. Runner Recovery Credit */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">13</td>
                <td className="p-2 font-bold text-emerald-800">Runner Recovery Credit (Scrap Credit)</td>
                <td className="p-2 text-center font-mono">₹</td>
                <td className="p-2 text-right font-mono bg-slate-50 text-emerald-700">- ₹{baselineCalc.runnerCredit.toFixed(2)}</td>
                <td className="p-2 bg-blue-50/30 font-mono font-bold text-emerald-700">- ₹{runningCalc.runnerCredit.toFixed(2)}</td>
                <td className="p-2 text-right font-mono text-slate-500">₹{(runningCalc.runnerCredit - baselineCalc.runnerCredit).toFixed(2)}</td>
              </tr>

              {/* 14. TOTAL RAW MATERIAL COST */}
              <tr className="bg-amber-100/60 font-bold">
                <td className="p-2 text-center font-mono">14</td>
                <td className="p-2 font-black text-slate-900">TOTAL RAW MATERIAL COST (Net + Scrap - Recovery)</td>
                <td className="p-2 text-center font-mono">₹</td>
                <td className="p-2 text-right font-mono font-black text-slate-900 bg-amber-50">₹{baselineCalc.totalRmCost.toFixed(2)}</td>
                <td className="p-2 bg-blue-100/70 font-mono font-black text-blue-950">₹{runningCalc.totalRmCost.toFixed(2)}</td>
                <td className="p-2 text-right font-mono font-black">₹{(runningCalc.totalRmCost - baselineCalc.totalRmCost).toFixed(2)}</td>
              </tr>

              {/* 15. Cycle Time */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">15</td>
                <td className="p-2 font-bold text-slate-900">Cycle Time Approved</td>
                <td className="p-2 text-center font-mono">Sec</td>
                <td className="p-2 text-right font-mono font-bold bg-slate-50">{baseCycle}s</td>
                <td className="p-2 bg-blue-50/40">
                  <input
                    type="number"
                    step="1"
                    value={runningCycleTime}
                    onChange={e => setRunningCycleTime(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded"
                  />
                </td>
                <td className="p-2 text-right font-mono font-bold text-blue-700">{(Number(runningCycleTime) - baseCycle).toFixed(1)}s</td>
              </tr>

              {/* 16. Shift Machine Tariff */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">16</td>
                <td className="p-2 font-bold text-slate-900">Shift Machine Tariff (Tonnage: {runningTonnage}T)</td>
                <td className="p-2 text-center font-mono">₹/shift</td>
                <td className="p-2 text-right font-mono bg-slate-50">₹{baseTariff}</td>
                <td className="p-2 bg-blue-50/40 font-mono font-bold">₹{actualTariff}</td>
                <td className="p-2 text-right font-mono">{actualTariff - baseTariff}</td>
              </tr>

              {/* 17. Machine Conversion Cost */}
              <tr>
                <td className="p-2 text-center font-mono text-slate-400">17</td>
                <td className="p-2 font-bold text-slate-900">Machine Conversion Cost / Piece</td>
                <td className="p-2 text-center font-mono">₹</td>
                <td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.conversionCost.toFixed(2)}</td>
                <td className="p-2 bg-blue-50/30 font-mono font-bold">₹{runningCalc.conversionCost.toFixed(2)}</td>
                <td className="p-2 text-right font-mono">₹{(runningCalc.conversionCost - baselineCalc.conversionCost).toFixed(2)}</td>
              </tr>

              {/* 18. TOTAL COMPONENT BASELINE COST */}
              <tr className="bg-slate-900 text-white font-bold">
                <td className="p-2.5 text-center font-mono">18</td>
                <td className="p-2.5 font-black text-amber-300 uppercase tracking-wider">TOTAL COMPONENT BASELINE COST</td>
                <td className="p-2.5 text-center font-mono">₹</td>
                <td className="p-2.5 text-right font-mono font-black text-amber-300 text-sm">₹{baselineCalc.totalCost.toFixed(2)}</td>
                <td className="p-2.5 font-mono font-black text-emerald-300 text-sm bg-slate-800">₹{runningCalc.totalCost.toFixed(2)}</td>
                <td className="p-2.5 text-right font-mono font-black text-white text-sm">
                  ₹ {costVariance <= 0 ? `${costVariance.toFixed(2)}` : `+${costVariance.toFixed(2)}`}
                </td>
              </tr>

            </tbody>
          </table>
        </div>

        {/* Reason for Spec Tuning & Actions */}
        <div className="space-y-2 pt-2 border-t">
          <div>
            <label className="font-bold text-slate-700 block mb-1">Reason for Shopfloor Spec Drift / Audit Trail Record *</label>
            <input
              type="text"
              value={reason}
              onChange={e => setReason(e.target.value)}
              placeholder="e.g. Shopfloor cycle time tuning and inward RM reconciliation"
              className="w-full border p-2 rounded-xl text-xs outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div className="flex justify-between items-center pt-2">
            <button onClick={onClose} className="px-4 py-2 border rounded-xl hover:bg-slate-50 cursor-pointer">Cancel</button>
            <button
              onClick={handleSave}
              className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"
            >
              <Save className="w-4 h-4" /> Save & Log Parameter Changes
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}
MODAL_EOF

echo "==> Exact 18-line parameter matrix and formula calculations fully restored."
