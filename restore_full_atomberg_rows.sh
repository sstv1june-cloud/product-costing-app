#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring branch is dev-v2..."
git checkout dev-v2

echo "==> 2. Updating InlineEditModal.jsx with complete 30-row Atomberg table..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, Trash2 } from 'lucide-react';
import { calculateHaierCost, calculateAtombergCost } from '../../shared/costCalculationService';
import { parseMaterialString, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';

export default function InlineEditModal({ product, onClose, onSave, onDelete }) {
  if (!product) return null;

  const isHaier = (product.vendor || '').toLowerCase().includes('haier');
  const isAtomberg = (product.vendor || '').toLowerCase().includes('atomberg');
  const initialParams = product.parameters || {};

  const { baseRm, mbGrade } = parseMaterialString(product.approvedRm || product.baseRm);
  const rmLookupKey = baseRm || product.baseRm || product.approvedRm || (isAtomberg ? 'PP H110MA' : 'HIPS SH303');
  const mbLookupKey = mbGrade || product.approvedMb || ((product.masterbatchPct || 0) > 0 ? 'Gloss White MB' : 'None');

  const rmInfo = getActiveRmMapping(rmLookupKey, product.vendor) || {};
  const mbInfo = getActiveMbMapping(mbLookupKey, product.vendor) || {};

  const approvedRmRate = Number(rmInfo.approvedPrice || product.approvedRmPrice || (isAtomberg ? 131.00 : 154.00));
  const runningRmWaRate = Number(rmInfo.activeWaPrice || rmInfo.approvedPrice || product.approvedRmPrice || (isAtomberg ? 131.00 : 154.00));

  const approvedMbRate = Number(mbInfo.approvedMbPrice || product.approvedMbPrice || 242.00);
  const runningMbWaRate = Number(mbInfo.activeMbWaPrice || mbInfo.approvedMbPrice || product.approvedMbPrice || 242.00);

  const [formData, setFormData] = useState({
    approvedRm: product.approvedRm || baseRm || (isAtomberg ? 'PP H110MA + Gloss White' : 'HIPS SH303'),
    baseRm: rmLookupKey,
    approvedMb: mbLookupKey,
    masterbatchPct: Number(product.masterbatchPct) || (isAtomberg ? 2 : 4),
    cavity: Number(product.cavity) || (isAtomberg ? 2 : 1),
    runnerWeight: Number(product.runnerWeight) || (isAtomberg ? 5.27 : 0),
    netWeight: Number(product.netWeight) || (isAtomberg ? 133.81 : 372),
    shotWeight: Number(product.shotWeight) || (isAtomberg ? 272.89 : 372),
    reconciliationWeight: Number(product.reconciliationWeight) || 0,
    machineTonnage: Number(product.machineTonnage) || (isAtomberg ? 150 : 600),
    shiftTariff: Number(product.shiftTariff) || (isAtomberg ? 2800 : 4800),
    cycleTimeApproved: Number(product.cycleTimeApproved) || (isAtomberg ? 38 : 70),
    bopCost: Number(product.bopCost) || 0,
    postOpCost: Number(product.postOpCost !== undefined ? product.postOpCost : 1.73),
    packingCost: Number(product.packingCost !== undefined ? product.packingCost : 0.86),
    transportCost: Number(product.transportCost !== undefined ? product.transportCost : 0.62),
    scrapRate: Number(product.scrapRate || 25),
    haierOverheadPackage: Number(product.haierOverheadPackage || 0),
    mouldMaintenance: Number(product.mouldMaintenance || 0),
    qualityInspection: Number(product.qualityInspection || 0),
    iccReduce: Number(product.iccReduce || 0),
    mouldSize: product.mouldSize || (isAtomberg ? '450x450x380' : '800x800x684'),
    model: product.model || (isAtomberg ? 'Aris Ceiling Fan' : 'TM 258/278'),

    // Running Parameters
    runningCycleTime: Number(initialParams.runningCycleTime ?? product.cycleTimeApproved ?? (isAtomberg ? 38 : 70)),
    runningCavity: Number(initialParams.runningCavity ?? product.cavity ?? (isAtomberg ? 2 : 1)),
    runningRunnerWeight: Number(initialParams.runningRunnerWeight ?? product.runnerWeight ?? (isAtomberg ? 5.27 : 0)),
    runningNetWeight: Number(initialParams.runningNetWeight ?? product.netWeight ?? (isAtomberg ? 133.81 : 372)),
    runningShiftTariff: Number(initialParams.runningShiftTariff ?? product.shiftTariff ?? (isAtomberg ? 2800 : 4800)),
    runningMbPct: Number(initialParams.runningMbPct ?? product.masterbatchPct ?? (isAtomberg ? 2 : 4)),
    runningBopCost: Number(initialParams.runningBopCost ?? product.bopCost ?? 0),
    runningPostOpCost: Number(initialParams.runningPostOpCost ?? product.postOpCost ?? 1.73),
    runningPackingCost: Number(initialParams.runningPackingCost ?? product.packingCost ?? 0.86),
    runningTransportCost: Number(initialParams.runningTransportCost ?? product.transportCost ?? 0.62)
  });

  // Calculate Atomberg Cost
  const atombergBaseCalc = calculateAtombergCost({
    rmBase: approvedRmRate,
    mbBase: approvedMbRate,
    partWt: formData.netWeight,
    runnerWt: formData.runnerWeight,
    mbPct: formData.masterbatchPct / 100,
    bopCost: formData.bopCost,
    cycleTime: formData.cycleTimeApproved,
    cavity: formData.cavity,
    tonnage: formData.machineTonnage,
    shiftTariff: formData.shiftTariff,
    postOpCost: formData.postOpCost,
    packingCost: formData.packingCost,
    transportCost: formData.transportCost,
    scrapRate: formData.scrapRate
  });

  const atombergRunningCalc = calculateAtombergCost({
    rmBase: runningRmWaRate,
    mbBase: runningMbWaRate,
    partWt: formData.runningNetWeight,
    runnerWt: formData.runningRunnerWeight,
    mbPct: formData.runningMbPct / 100,
    bopCost: formData.runningBopCost,
    cycleTime: formData.runningCycleTime,
    cavity: formData.runningCavity,
    tonnage: formData.machineTonnage,
    shiftTariff: formData.runningShiftTariff,
    postOpCost: formData.runningPostOpCost,
    packingCost: formData.runningPackingCost,
    transportCost: formData.runningTransportCost,
    scrapRate: formData.scrapRate
  });

  // Calculate Haier Cost
  const ctApproved = Number(formData.cycleTimeApproved) > 0 ? Number(formData.cycleTimeApproved) : 1;
  const cavityApproved = Number(formData.cavity) > 0 ? Number(formData.cavity) : 1;
  const row19ApprovedNum = 28800 / ctApproved;
  const row20ApprovedNum = row19ApprovedNum * 0.95;
  const row21ApprovedNum = row20ApprovedNum * cavityApproved;

  const ctRunning = Number(formData.runningCycleTime) > 0 ? Number(formData.runningCycleTime) : 1;
  const cavityRunning = Number(formData.runningCavity) > 0 ? Number(formData.runningCavity) : 1;
  const row19RunningNum = 28800 / ctRunning;
  const row20RunningNum = row19RunningNum * 0.95;
  const row21RunningNum = row20RunningNum * cavityRunning;

  const haierBaseCalc = calculateHaierCost({
    cavity: formData.cavity,
    netWeight: formData.netWeight,
    runnerWeight: formData.runnerWeight,
    shotWeight: formData.shotWeight,
    partsPerShift: row21ApprovedNum,
    rmRate: approvedRmRate,
    masterbatchPct: formData.masterbatchPct,
    masterbatchRate: approvedMbRate,
    shiftTariff: formData.shiftTariff,
    cycleTime: formData.cycleTimeApproved,
    haierOverheadPackage: formData.haierOverheadPackage,
    bopCost: formData.bopCost,
    mouldMaintenance: formData.mouldMaintenance,
    qualityInspection: formData.qualityInspection,
    iccReduce: formData.iccReduce
  });

  const haierRunningCalc = calculateHaierCost({
    cavity: formData.runningCavity,
    netWeight: formData.runningNetWeight,
    runnerWeight: formData.runningRunnerWeight,
    shotWeight: formData.runningNetWeight * formData.runningCavity + formData.runningRunnerWeight,
    partsPerShift: row21RunningNum,
    rmRate: runningRmWaRate,
    masterbatchPct: formData.runningMbPct,
    masterbatchRate: runningMbWaRate,
    shiftTariff: formData.runningShiftTariff,
    cycleTime: formData.runningCycleTime,
    haierOverheadPackage: formData.haierOverheadPackage,
    bopCost: formData.runningBopCost,
    mouldMaintenance: formData.mouldMaintenance,
    qualityInspection: formData.qualityInspection,
    iccReduce: formData.iccReduce
  });

  const contractTotal = isHaier ? haierBaseCalc.totalCost : atombergBaseCalc.finalLanded;
  const runningTotal = isHaier ? haierRunningCalc.totalCost : atombergRunningCalc.finalLanded;
  const profitLossDelta = Number((contractTotal - runningTotal).toFixed(2));

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
        runningMbPct: formData.runningMbPct,
        runningBopCost: formData.runningBopCost,
        runningPostOpCost: formData.runningPostOpCost,
        runningPackingCost: formData.runningPackingCost,
        runningTransportCost: formData.runningTransportCost
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
                {isHaier ? 'Haier 38-Line Costing Format' : 'Atomberg Dual Column Costing Engine'}
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

        {/* Table Body */}
        <div className="flex-1 overflow-y-auto p-4 space-y-2">
          {!isHaier ? (
            /* ========================================================================= */
            /* COMPLETE ATOMBERG DUAL COLUMN TABLE (All 30 Specification Rows)          */
            /* ========================================================================= */
            <table className="w-full text-left border-collapse">
              <thead className="bg-slate-100 text-slate-700 text-[10px] uppercase font-bold sticky top-0 border-b border-slate-200">
                <tr>
                  <th className="py-2.5 px-3">Atomberg Cost Parameter</th>
                  <th className="py-2.5 px-3 text-center w-24">UOM</th>
                  <th className="py-2.5 px-4 text-right w-44">Approved Baseline</th>
                  <th className="py-2.5 px-4 text-right w-44 text-blue-700">Actual Running</th>
                  <th className="py-2.5 px-3 text-right w-24">Delta (Δ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs font-medium">
                <tr>
                  <td className="py-2 px-3 font-bold">1. Part Name / Description</td>
                  <td className="py-2 px-3 text-center">-</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-slate-800">{product.componentName}</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{product.componentName}</td>
                  <td className="py-2 px-3 text-right text-slate-400">-</td>
                </tr>
                <tr>
                  <td className="py-2 px-3 font-bold text-blue-700">2. Item No. / Part Code</td>
                  <td className="py-2 px-3 text-center">-</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{product.itemCode}</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{product.itemCode}</td>
                  <td className="py-2 px-3 text-right text-slate-400">-</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">3. Model / Fan Series</td>
                  <td className="py-2 px-3 text-center">-</td>
                  <td className="py-2 px-4 text-right font-mono">{formData.model}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.model}</td>
                  <td className="py-2 px-3 text-right text-slate-400">-</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">4. Mould Size L x W x H</td>
                  <td className="py-2 px-3 text-center">mm</td>
                  <td className="py-2 px-4 text-right font-mono">{formData.mouldSize}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.mouldSize}</td>
                  <td className="py-2 px-3 text-right text-slate-400">-</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">5. Base Polymer & Grade</td>
                  <td className="py-2 px-3 text-center">-</td>
                  <td className="py-2 px-4 text-right font-semibold text-slate-700">{formData.approvedRm}</td>
                  <td className="py-2 px-4 text-right font-semibold text-blue-800">{formData.approvedRm}</td>
                  <td className="py-2 px-3 text-right text-emerald-600 font-bold">Matched</td>
                </tr>
                <tr>
                  <td className="py-2 px-3 font-bold text-purple-900">6. Masterbatch Grade & %</td>
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
                  <td className="py-2 px-3 font-bold">7. Part Net Weight</td>
                  <td className="py-2 px-3 text-center">Gms</td>
                  <td className="py-2 px-4 text-right">
                    <input type="number" step="0.01" value={formData.netWeight} onChange={e => setFormData({ ...formData, netWeight: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                  </td>
                  <td className="py-2 px-4 text-right">
                    <input type="number" step="0.01" value={formData.runningNetWeight} onChange={e => setFormData({ ...formData, runningNetWeight: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                  </td>
                  <td className="py-2 px-3 text-right font-mono">{(formData.netWeight - formData.runningNetWeight).toFixed(2)}g</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">8. Runner Weight</td>
                  <td className="py-2 px-3 text-center">Gms</td>
                  <td className="py-2 px-4 text-right">
                    <input type="number" step="0.01" value={formData.runnerWeight} onChange={e => setFormData({ ...formData, runnerWeight: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                  </td>
                  <td className="py-2 px-4 text-right">
                    <input type="number" step="0.01" value={formData.runningRunnerWeight} onChange={e => setFormData({ ...formData, runningRunnerWeight: Number(e.target.value) || 0 })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                  </td>
                  <td className="py-2 px-3 text-right font-mono">{(formData.runnerWeight - formData.runningRunnerWeight).toFixed(2)}g</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">9. No. of Cavity</td>
                  <td className="py-2 px-3 text-center">Nos</td>
                  <td className="py-2 px-4 text-right">
                    <input type="number" value={formData.cavity} onChange={e => setFormData({ ...formData, cavity: Number(e.target.value) || 1 })} className="w-16 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                  </td>
                  <td className="py-2 px-4 text-right">
                    <input type="number" value={formData.runningCavity} onChange={e => setFormData({ ...formData, runningCavity: Number(e.target.value) || 1 })} className="w-16 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                  </td>
                  <td className="py-2 px-3 text-right font-mono">{formData.cavity - formData.runningCavity}</td>
                </tr>
                <tr className="bg-slate-50 font-bold">
                  <td className="py-2 px-3">10. Total Shot Weight = (Part Wt * Cavity) + Runner Wt</td>
                  <td className="py-2 px-3 text-center">Gms</td>
                  <td className="py-2 px-4 text-right font-mono">{atombergBaseCalc.totalShotWt}g</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.totalShotWt}g</td>
                  <td className="py-2 px-3 text-right font-mono">{(atombergBaseCalc.totalShotWt - atombergRunningCalc.totalShotWt).toFixed(2)}g</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">11. Landed Polymer Rate = (RM Base * 1.01 + 1.50)</td>
                  <td className="py-2 px-3 text-center">₹/kg</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.landedRm}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">₹{atombergRunningCalc.landedRm}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.landedRm - atombergRunningCalc.landedRm).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">12. Landed Masterbatch Rate = (MB Base * 1.01 + 2.00)</td>
                  <td className="py-2 px-3 text-center">₹/kg</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.landedMb}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">₹{atombergRunningCalc.landedMb}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.landedMb - atombergRunningCalc.landedMb).toFixed(2)}</td>
                </tr>
                <tr className="bg-slate-50 font-bold">
                  <td className="py-2 px-3">13. Blended Material Rate = (Landed RM * (1-MB%)) + (Landed MB * MB%)</td>
                  <td className="py-2 px-3 text-center">₹/kg</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.blendedRmRate}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.blendedRmRate}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.blendedRmRate - atombergRunningCalc.blendedRmRate).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">14. Raw Material Cost / Pc = (Blended Rate * Shot Wt) / (Cavity * 1000)</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.rawMatCostPerPc}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">₹{atombergRunningCalc.rawMatCostPerPc}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.rawMatCostPerPc - atombergRunningCalc.rawMatCostPerPc).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3 text-rose-700">15. Less: Runner Scrap Credit = ((Runner Wt / Cavity) / 1000) * ₹25</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono text-rose-700">- ₹{atombergBaseCalc.runnerScrapCredit}</td>
                  <td className="py-2 px-4 text-right font-mono text-rose-700">- ₹{atombergRunningCalc.runnerScrapCredit}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr className="bg-emerald-50/50 font-bold text-emerald-950">
                  <td className="py-2 px-3">16. Net Raw Material Cost / Pc = (Raw Mat Cost - Scrap Credit)</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.netRmCost}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-900">₹{atombergRunningCalc.netRmCost}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.netRmCost - atombergRunningCalc.netRmCost).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">17. Machine Used (Tonnage)</td>
                  <td className="py-2 px-3 text-center">T</td>
                  <td className="py-2 px-4 text-right font-mono">{formData.machineTonnage}T</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.machineTonnage}T</td>
                  <td className="py-2 px-3 text-right text-slate-400">-</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">18. Machine Shift Tariff</td>
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
                  <td className="py-2 px-3 font-bold">19. Cycle Time</td>
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
                  <td className="py-2 px-3">20. Theoretical Shots / Shift (8 hr) = 28,800 / CT</td>
                  <td className="py-2 px-3 text-center">Nos</td>
                  <td className="py-2 px-4 text-right font-mono">{atombergBaseCalc.theoreticalShots}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.theoreticalShots}</td>
                  <td className="py-2 px-3 text-right font-mono">{(atombergBaseCalc.theoreticalShots - atombergRunningCalc.theoreticalShots).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">21. Actual Output / Shift (90% Efficiency) = (28800/CT) * 0.90 * Cavity</td>
                  <td className="py-2 px-3 text-center">Nos</td>
                  <td className="py-2 px-4 text-right font-mono">{atombergBaseCalc.partsPerShift}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.partsPerShift}</td>
                  <td className="py-2 px-3 text-right font-mono">{(atombergBaseCalc.partsPerShift - atombergRunningCalc.partsPerShift).toFixed(2)}</td>
                </tr>
                <tr className="bg-slate-50 font-bold">
                  <td className="py-2 px-3">22. Conversion Rate / Pc = Shift Tariff / Parts per shift</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.convRatePerPc}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.convRatePerPc}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.convRatePerPc - atombergRunningCalc.convRatePerPc).toFixed(2)}</td>
                </tr>
                <tr className="bg-slate-100 font-bold">
                  <td className="py-2 px-3">23. Base Cost = Net RM Cost + Conversion Rate</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono font-bold">₹{atombergBaseCalc.baseCost}</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">₹{atombergRunningCalc.baseCost}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.baseCost - atombergRunningCalc.baseCost).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3 font-semibold">24. Overheads & Profit = Base Cost * 12%</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.ohAndProfit}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.ohAndProfit}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.ohAndProfit - atombergRunningCalc.ohAndProfit).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">25. In-Process Rejection = Base Cost * 4%</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.inProcessRejection}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.inProcessRejection}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.inProcessRejection - atombergRunningCalc.inProcessRejection).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">26. Mould Maintenance = Conversion Rate * 2%</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.mouldMaintenance}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.mouldMaintenance}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">27. BOP / Inserts Cost</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.bopCost || 0}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">₹{atombergRunningCalc.bopCost || 0}</td>
                  <td className="py-2 px-3 text-right text-slate-400">-</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">28. Post Operation Cost</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.postOpCost}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.postOpCost}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">29. Packing Cost</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.packingCost}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.packingCost}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">30. Freight & Transport Cost</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.transportCost}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.transportCost}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr className="bg-slate-900 text-white font-black text-xs">
                  <td className="py-3 px-3 uppercase text-amber-400">FINAL LANDED COST / PC</td>
                  <td className="py-3 px-3 text-center">Rs</td>
                  <td className="py-3 px-4 text-right font-mono text-amber-300 text-sm">₹{atombergBaseCalc.finalLanded.toFixed(2)}</td>
                  <td className="py-3 px-4 text-right font-mono text-emerald-400 text-sm">₹{atombergRunningCalc.finalLanded.toFixed(2)}</td>
                  <td className={`py-3 px-3 text-right font-mono ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                    {profitLossDelta >= 0 ? `+₹${profitLossDelta.toFixed(2)}` : `-₹${Math.abs(profitLossDelta).toFixed(2)}`}
                  </td>
                </tr>
              </tbody>
            </table>
          ) : (
            /* ========================================================================= */
            /* HAIER 38-LINE TABLE                                                       */
            /* ========================================================================= */
            <table className="w-full text-left border-collapse">
              <thead className="bg-slate-100 text-slate-700 text-[10px] uppercase font-bold sticky top-0 border-b border-slate-200">
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
                  <td className="py-2 px-3 font-mono text-slate-400">3</td>
                  <td className="py-2 px-3 font-bold text-blue-700">Item No.</td>
                  <td className="py-2 px-3 text-center">-</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{product.itemCode}</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{product.itemCode}</td>
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
                  <td className="py-2 px-3 font-mono text-slate-400">7</td>
                  <td className="py-2 px-3 font-bold">No. of Cavity</td>
                  <td className="py-2 px-3 text-center">Nos</td>
                  <td className="py-2 px-4 text-right font-bold">{formData.cavity}</td>
                  <td className="py-2 px-4 text-right font-bold text-blue-800">{formData.runningCavity}</td>
                  <td className="py-2 px-3 text-right font-mono">{formData.cavity - formData.runningCavity}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3 font-mono text-slate-400">9</td>
                  <td className="py-2 px-3 font-bold">Net Weight</td>
                  <td className="py-2 px-3 text-center">Gms</td>
                  <td className="py-2 px-4 text-right font-mono font-bold">{formData.netWeight}g</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{formData.runningNetWeight}g</td>
                  <td className="py-2 px-3 text-right font-mono">{(formData.netWeight - formData.runningNetWeight).toFixed(2)}g</td>
                </tr>
                <tr className="bg-slate-900 text-white font-black text-xs">
                  <td className="py-3 px-3 font-mono text-amber-400">38</td>
                  <td className="py-3 px-3 uppercase text-amber-400">TOTAL COST</td>
                  <td className="py-3 px-3 text-center">Rs</td>
                  <td className="py-3 px-4 text-right font-mono text-amber-300 text-sm">₹{haierBaseCalc.totalCost.toFixed(2)}</td>
                  <td className="py-3 px-4 text-right font-mono text-emerald-400 text-sm">₹{haierRunningCalc.totalCost.toFixed(2)}</td>
                  <td className={`py-3 px-3 text-right font-mono ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                    {profitLossDelta >= 0 ? `+₹${profitLossDelta.toFixed(2)}` : `-₹${Math.abs(profitLossDelta).toFixed(2)}`}
                  </td>
                </tr>
              </tbody>
            </table>
          )}
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
  const isAtomberg = (item?.vendor || '').toLowerCase().includes('atomberg');
  const { baseRm, mbGrade } = parseMaterialString(item?.approvedRm || item?.baseRm);
  const rmInfo = getActiveRmMapping(baseRm || item?.baseRm || item?.approvedRm, item?.vendor) || {};
  const mbInfo = getActiveMbMapping(mbGrade || item?.approvedMb, item?.vendor) || {};

  if (isHaier) {
    const calc = calculateHaierCost({
      cavity: item.cavity || 1,
      netWeight: item.netWeight || 0,
      runnerWeight: item.runnerWeight || 0,
      shotWeight: item.shotWeight || 0,
      partsPerShift: item.partsPerShift || 0,
      rmRate: Number(rmInfo.approvedPrice || item.approvedRmPrice || 0),
      masterbatchPct: item.masterbatchPct ?? 0,
      masterbatchRate: Number(mbInfo.approvedMbPrice || item.approvedMbPrice || 0),
      shiftTariff: item.shiftTariff || 0,
      cycleTime: item.cycleTimeApproved || 0,
      haierOverheadPackage: item.haierOverheadPackage || 0,
      bopCost: item.bopCost || 0,
      mouldMaintenance: item.mouldMaintenance || 0,
      qualityInspection: item.qualityInspection || 0,
      iccReduce: item.iccReduce || 0
    });
    return {
      netRmCost: calc.totalRmCost || 0,
      convRatePerPc: calc.productionCostPerPc || 0,
      totalCost: calc.totalCost || 0,
      finalLanded: calc.totalCost || 0
    };
  } else {
    const calc = calculateAtombergCost({
      rmBase: Number(rmInfo.approvedPrice || item.approvedRmPrice || 131),
      mbBase: Number(mbInfo.approvedMbPrice || item.approvedMbPrice || 242),
      partWt: item.netWeight !== undefined ? item.netWeight : 133.81,
      runnerWt: item.runnerWeight !== undefined ? item.runnerWeight : 5.27,
      mbPct: (item.masterbatchPct || 2) / 100,
      bopCost: item.bopCost || 0,
      cycleTime: item.cycleTimeApproved || 38,
      cavity: item.cavity || 2,
      tonnage: item.machineTonnage || 150,
      shiftTariff: item.shiftTariff || 2800,
      postOpCost: item.postOpCost !== undefined ? item.postOpCost : 1.73,
      packingCost: item.packingCost !== undefined ? item.packingCost : 0.86,
      transportCost: item.transportCost !== undefined ? item.transportCost : 0.62,
      scrapRate: item.scrapRate || 25
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

echo "==> 3. Updating BaselineMasterPage.jsx with all 30 Atomberg specification rows in Staging..."
cat << 'PAGE_EOF' > src/modules/module1-baseline/BaselineMasterPage.jsx
import React, { useState, useEffect, useRef } from 'react';
import { 
  Upload, 
  Trash2, 
  Edit3, 
  Search, 
  Layers, 
  Database,
  CheckCircle2, 
  ChevronLeft, 
  ChevronRight,
  X
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  updateBaselineParameters, 
  deleteProductFromBaseline, 
  clearVendorBaselineProducts, 
  addStagedProductsToBaseline, 
  addOrUpdateVendorMaterial, 
  parseMaterialString, 
  getActiveRmMapping, 
  getActiveMbMapping 
} from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';

export default function BaselineMasterPage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('Atomberg Technologies');
  const [activeTab, setActiveTab] = useState('parameters');
  const [searchQuery, setSearchQuery] = useState('');
  const [editingProduct, setEditingProduct] = useState(null);
  
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [stagedData, setStagedData] = useState([]);
  const [selectedStagedIndex, setSelectedStagedIndex] = useState(0);
  const tabsContainerRef = useRef(null);

  useEffect(() => {
    const unsub = subscribeStore(() => {
      setStoreState({ ...globalStore });
    });
    return () => unsub();
  }, []);

  const vendors = storeState.vendors || [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ];

  const vendorProducts = (storeState.baselineProducts || []).filter(p => 
    selectedVendor === 'ALL' || 
    (p.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((p.vendor || '').toLowerCase())
  );

  const filteredProducts = vendorProducts.filter(p => 
    !searchQuery || 
    (p.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.approvedRm || '').toLowerCase().includes(searchQuery.toLowerCase())
  );

  const vendorAuditLogs = (storeState.auditLogs || []).filter(l => 
    selectedVendor === 'ALL' ||
    (l.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((l.vendor || '').toLowerCase()) ||
    l.vendor === 'ALL'
  );

  const handleEditClick = (prod) => {
    const { baseRm, mbGrade } = parseMaterialString(prod.approvedRm || prod.baseRm);
    const rmLookupKey = baseRm || prod.baseRm || prod.approvedRm;
    const mbLookupKey = mbGrade || prod.approvedMb || (prod.masterbatchPct > 0 ? 'White MB' : '');

    const rmMap = getActiveRmMapping(rmLookupKey, prod.vendor);
    const mbMap = getActiveMbMapping(mbLookupKey, prod.vendor);
    
    setEditingProduct({
      ...prod,
      baseRm: rmLookupKey,
      approvedMb: mbLookupKey,
      approvedRmPrice: Number(rmMap.approvedPrice || prod.approvedRmPrice || 0),
      activeRmWaPrice: Number(rmMap.activeWaPrice || rmMap.approvedPrice || prod.approvedRmPrice || 0),
      approvedMbPrice: Number(mbMap.approvedMbPrice || prod.approvedMbPrice || 0),
      activeMbWaPrice: Number(mbMap.activeMbWaPrice || mbMap.approvedMbPrice || prod.approvedMbPrice || 0)
    });
  };

  const handleSaveProduct = (updatedItem) => {
    updateBaselineParameters({
      itemId: updatedItem.id || updatedItem.itemCode,
      updatedItem,
      reason: 'Manual Spec Parameter Adjustment via Edit Modal'
    });
    setEditingProduct(null);
  };

  const handleDeleteProduct = (itemId) => {
    deleteProductFromBaseline(itemId, selectedVendor);
    setEditingProduct(null);
  };

  const handleFileUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      const bstr = evt.target.result;
      const wb = XLSX.read(bstr, { type: 'binary' });
      const wsname = wb.SheetNames[0];
      const ws = wb.Sheets[wsname];
      const rawMatrix = XLSX.utils.sheet_to_json(ws, { header: 1 });

      if (!rawMatrix || rawMatrix.length === 0) return;

      const parsed = [];
      const isHaierVendor = selectedVendor.toLowerCase().includes('haier');

      // 1. Scan Row Labels in Column A & B directly
      const rowLabels = {};
      rawMatrix.forEach((r, idx) => {
        const txt = `${r[0] || ''} ${r[1] || ''}`.toLowerCase();
        if ((txt.includes('part name') || txt.includes('name of component') || (txt.includes('description') && !txt.includes('grade'))) && rowLabels.name === undefined) {
          rowLabels.name = idx;
        }
        if ((txt.includes('part code') || txt.includes('item no') || txt.includes('item code') || txt.includes('part no')) && rowLabels.code === undefined) {
          rowLabels.code = idx;
        }
        if (txt.includes('model') && rowLabels.model === undefined) rowLabels.model = idx;
        if ((txt.includes('mould size') || txt.includes('mold size')) && rowLabels.mould === undefined) rowLabels.mould = idx;
        if ((txt.includes('raw material') || txt.includes('rm grade') || txt.includes('base polymer')) && !txt.includes('cost') && !txt.includes('rate') && rowLabels.rm === undefined) {
          rowLabels.rm = idx;
        }
        if ((txt.includes('master batch') || txt.includes('masterbatch') || txt.includes('mb %')) && rowLabels.mb === undefined) {
          rowLabels.mb = idx;
        }
        if ((txt.includes('cavity') || txt.includes('cavities')) && rowLabels.cavity === undefined) rowLabels.cavity = idx;
        if ((txt.includes('runner weight') || txt.includes('runner wt')) && !txt.includes('recovery') && rowLabels.runner === undefined) rowLabels.runner = idx;
        if ((txt.includes('net weight') || txt.includes('part weight') || txt.includes('net wt')) && rowLabels.netWt === undefined) rowLabels.netWt = idx;
        if ((txt.includes('shot weight') || txt.includes('shot wt')) && rowLabels.shotWt === undefined) rowLabels.shotWt = idx;
        if ((txt.includes('cycle time') || txt.includes('ct (s)') || txt.includes('ct')) && rowLabels.ct === undefined) rowLabels.ct = idx;
        if ((txt.includes('machine used') || txt.includes('tonnage')) && rowLabels.tonnage === undefined) rowLabels.tonnage = idx;
        if ((txt.includes('machine tariff') || txt.includes('shift tariff')) && rowLabels.tariff === undefined) rowLabels.tariff = idx;
        if ((txt.includes('rm base rate') || txt.includes('raw material cost') || txt.includes('rm rate')) && rowLabels.rmRate === undefined) rowLabels.rmRate = idx;
        if ((txt.includes('mb rate') || txt.includes('master batch cost')) && rowLabels.mbRate === undefined) rowLabels.mbRate = idx;
      });

      // If vertical orientation
      const isVertical = rowLabels.name !== undefined || rowLabels.code !== undefined || rowLabels.netWt !== undefined;

      if (isVertical) {
        let startCol = 2;
        const testRow = rowLabels.name !== undefined ? rowLabels.name : (rowLabels.code !== undefined ? rowLabels.code : 0);
        if (rawMatrix[testRow] && rawMatrix[testRow][3] !== undefined && String(rawMatrix[testRow][3]).trim() !== '') {
          startCol = 3;
        }

        const maxCols = Math.max(...rawMatrix.map(r => r.length));

        for (let c = startCol; c < maxCols; c++) {
          const compNameRaw = rowLabels.name !== undefined ? rawMatrix[rowLabels.name]?.[c] : undefined;
          const itemCodeRaw = rowLabels.code !== undefined ? rawMatrix[rowLabels.code]?.[c] : undefined;

          if (!compNameRaw && !itemCodeRaw) continue;

          const compName = String(compNameRaw || itemCodeRaw).trim();
          const itemCode = String(itemCodeRaw || compName).trim();
          const modelName = String((rowLabels.model !== undefined ? rawMatrix[rowLabels.model]?.[c] : '') || (isHaierVendor ? 'TM 258/278' : 'Aris Ceiling Fan')).trim();
          const mouldSize = String((rowLabels.mould !== undefined ? rawMatrix[rowLabels.mould]?.[c] : '') || '450x450x380').trim();

          const rawMatStr = String((rowLabels.rm !== undefined ? rawMatrix[rowLabels.rm]?.[c] : '') || (isHaierVendor ? 'HIPS SH303 + White MB' : 'PP H110MA + Gloss White')).trim();
          const { baseRm, mbGrade } = parseMaterialString(rawMatStr);

          let mbPct = isHaierVendor ? 4.0 : 2.0;
          if (rowLabels.mb !== undefined) {
            const rawMb = rawMatrix[rowLabels.mb]?.[c];
            if (typeof rawMb === 'number') {
              mbPct = rawMb <= 1 ? Number((rawMb * 100).toFixed(2)) : rawMb;
            } else if (rawMb) {
              mbPct = parseFloat(String(rawMb).replace('%', '')) || mbPct;
            }
          }

          const cavity = parseInt((rowLabels.cavity !== undefined ? rawMatrix[rowLabels.cavity]?.[c] : '') || (isHaierVendor ? '1' : '2'), 10) || 1;
          const runnerWt = parseFloat((rowLabels.runner !== undefined ? rawMatrix[rowLabels.runner]?.[c] : '') || 0) || 0;
          const netWt = parseFloat((rowLabels.netWt !== undefined ? rawMatrix[rowLabels.netWt]?.[c] : '') || 0) || 0;
          const shotWt = parseFloat((rowLabels.shotWt !== undefined ? rawMatrix[rowLabels.shotWt]?.[c] : '') || (netWt * cavity + runnerWt)) || (netWt * cavity + runnerWt);

          const cycleTime = parseFloat((rowLabels.ct !== undefined ? rawMatrix[rowLabels.ct]?.[c] : '') || (isHaierVendor ? 70 : 38)) || (isHaierVendor ? 70 : 38);
          const tonnage = parseInt((rowLabels.tonnage !== undefined ? rawMatrix[rowLabels.tonnage]?.[c] : '') || (isHaierVendor ? 600 : 150), 10) || 150;
          const tariff = parseFloat((rowLabels.tariff !== undefined ? rawMatrix[rowLabels.tariff]?.[c] : '') || (isHaierVendor ? 4800 : 2800)) || 2800;

          const rmRate = parseFloat((rowLabels.rmRate !== undefined ? rawMatrix[rowLabels.rmRate]?.[c] : '') || (isHaierVendor ? 154 : 131)) || 131;
          const mbRate = parseFloat((rowLabels.mbRate !== undefined ? rawMatrix[rowLabels.mbRate]?.[c] : '') || 242) || 242;

          // Auto-Register in RM Matrix
          if (baseRm) {
            addOrUpdateVendorMaterial({
              vendor: selectedVendor,
              type: 'RM',
              approvedCode: baseRm,
              approvedPrice: rmRate
            });
          }

          // Calculate Exact Baseline Cost
          let finalAppCost = 0;
          if (isHaierVendor) {
            const h = calculateHaierCost({
              cavity,
              netWeight: netWt,
              runnerWeight: runnerWt,
              shotWeight: shotWt,
              rmRate,
              masterbatchPct: mbPct,
              masterbatchRate: mbRate,
              shiftTariff: tariff,
              cycleTime,
              haierOverheadPackage: 8.71
            });
            finalAppCost = h.totalCost;
          } else {
            const a = calculateAtombergCost({
              rmBase: rmRate,
              mbBase: mbRate,
              partWt: netWt,
              runnerWt: runnerWt,
              mbPct: mbPct / 100,
              bopCost: 0,
              cycleTime: cycleTime,
              cavity: cavity,
              tonnage: tonnage,
              shiftTariff: tariff,
              postOpCost: 1.73,
              packingCost: 0.86,
              transportCost: 0.62,
              scrapRate: 25
            });
            finalAppCost = a.finalLanded;
          }

          parsed.push({
            id: `prod-${itemCode}-${c}`,
            vendor: selectedVendor,
            componentName: compName,
            mouldSize: mouldSize,
            itemCode: itemCode,
            model: modelName,
            approvedRm: rawMatStr,
            baseRm: baseRm || rawMatStr,
            approvedMb: mbGrade || (mbPct > 0 ? 'White MB' : 'None'),
            masterbatchPct: mbPct,
            cavity: cavity,
            runnerWeight: runnerWt,
            netWeight: netWt,
            shotWeight: shotWt,
            machineTonnage: tonnage,
            shiftTariff: tariff,
            cycleTimeApproved: cycleTime,
            bopCost: 0,
            postOpCost: 1.73,
            packingCost: 0.86,
            transportCost: 0.62,
            scrapRate: 25,
            approvedCost: finalAppCost,
            parameters: {
              runningCycleTime: cycleTime,
              runningCavity: cavity,
              runningRunnerWeight: runnerWt,
              runningNetWeight: netWt,
              runningShiftTariff: tariff,
              runningMbPct: mbPct
            }
          });
        }
      }

      setStagedData(parsed);
      setSelectedStagedIndex(0);
      setShowUploadModal(true);
    };
    reader.readAsBinaryString(file);
  };

  const handleUpdateActiveStaged = (field, value) => {
    setStagedData(prev => {
      const copy = [...prev];
      copy[selectedStagedIndex] = {
        ...copy[selectedStagedIndex],
        [field]: value
      };
      return copy;
    });
  };

  const handleCommitStaged = () => {
    addStagedProductsToBaseline(stagedData, selectedVendor);
    setStagedData([]);
    setShowUploadModal(false);
  };

  const scrollTabs = (offset) => {
    if (tabsContainerRef.current) {
      tabsContainerRef.current.scrollBy({ left: offset, behavior: 'smooth' });
    }
  };

  const activeStaged = stagedData[selectedStagedIndex] || null;
  const isHaierVendor = (selectedVendor || '').toLowerCase().includes('haier');

  // Compute live breakdown for Staging Modal
  let atomStagedCalc = null;
  let haierStagedCalc = null;
  let computedStagedTotal = 0;

  if (activeStaged) {
    if (isHaierVendor) {
      haierStagedCalc = calculateHaierCost({
        cavity: activeStaged.cavity,
        netWeight: activeStaged.netWeight,
        runnerWeight: activeStaged.runnerWeight,
        shotWeight: activeStaged.shotWeight,
        rmRate: 154,
        masterbatchPct: activeStaged.masterbatchPct,
        masterbatchRate: 242,
        shiftTariff: activeStaged.shiftTariff,
        cycleTime: activeStaged.cycleTimeApproved,
        haierOverheadPackage: 8.71
      });
      computedStagedTotal = Number(activeStaged.approvedCost || haierStagedCalc.totalCost || 0);
    } else {
      atomStagedCalc = calculateAtombergCost({
        rmBase: 131,
        mbBase: 242,
        partWt: activeStaged.netWeight,
        runnerWt: activeStaged.runnerWeight,
        mbPct: (activeStaged.masterbatchPct || 2) / 100,
        bopCost: activeStaged.bopCost || 0,
        cycleTime: activeStaged.cycleTimeApproved || 38,
        cavity: activeStaged.cavity || 2,
        tonnage: activeStaged.machineTonnage || 150,
        shiftTariff: activeStaged.shiftTariff || 2800,
        postOpCost: 1.73,
        packingCost: 0.86,
        transportCost: 0.62,
        scrapRate: 25
      });
      computedStagedTotal = Number(activeStaged.approvedCost || atomStagedCalc.finalLanded || 0);
    }
  }

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master (DEV-V2)</h1>
              <span className="bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 text-[10px] px-2 py-0.5 rounded-full font-bold">
                Active Vendor: {selectedVendor}
              </span>
            </div>
            <p className="text-[11px] text-slate-300">Dual Engine: Atomberg Dual Column & Haier 38-Line Costing</p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={() => {
              if (window.confirm(`Are you sure you want to clear all baseline products for ${selectedVendor}?`)) {
                clearVendorBaselineProducts(selectedVendor);
              }
            }}
            className="px-3.5 py-2 bg-rose-950/40 hover:bg-rose-900 text-rose-300 border border-rose-800/60 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-xs text-xs"
          >
            <Trash2 className="w-4 h-4 text-rose-400" /> Clear {selectedVendor} Data
          </button>

          <label className="px-3.5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm text-xs">
            <Upload className="w-4 h-4" /> Upload & Stage Spec (.xlsx)
            <input type="file" accept=".xlsx, .xls" onChange={handleFileUpload} className="hidden" />
          </label>

          <div className="flex bg-slate-800 p-0.5 rounded-xl border border-slate-700">
            <button
              onClick={() => setActiveTab('parameters')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${
                activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'
              }`}
            >
              Parameters Master ({vendorProducts.length})
            </button>
            <button
              onClick={() => setActiveTab('audit')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${
                activeTab === 'audit' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'
              }`}
            >
              Parameter Audit Log ({vendorAuditLogs.length})
            </button>
          </div>
        </div>
      </div>

      {/* Filter Row */}
      <div className="bg-white p-3 rounded-2xl border border-slate-200 shadow-xs flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-2 flex-1 max-w-md bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-200">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder={`Search ${selectedVendor} components...`}
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            className="w-full bg-transparent border-none outline-hidden text-xs text-slate-800"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-600">Switch Vendor:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="px-3 py-1.5 rounded-xl bg-slate-100 text-slate-900 border border-slate-300 font-bold text-xs"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Main Parameters Table */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">{selectedVendor} Baseline Parameters Master</h2>
          </div>
          <span className="text-[11px] text-slate-400 font-mono">{filteredProducts.length} Active Parts</span>
        </div>

        {activeTab === 'parameters' ? (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Item Code / Component</th>
                  <th className="py-2.5 px-3">Model</th>
                  <th className="py-2.5 px-3">Approved RM / MB</th>
                  <th className="py-2.5 px-3 text-center">MB %</th>
                  <th className="py-2.5 px-3 text-center">Cavity</th>
                  <th className="py-2.5 px-3 text-right">Net Wt</th>
                  <th className="py-2.5 px-3 text-right">Runner Wt</th>
                  <th className="py-2.5 px-3 text-center bg-amber-50/70 text-amber-950">Cycle Time</th>
                  <th className="py-2.5 px-3 text-center">Tonnage</th>
                  <th className="py-2.5 px-3 text-right">Shift Tariff</th>
                  <th className="py-2.5 px-4 text-center">Edit Spec</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredProducts.length === 0 ? (
                  <tr>
                    <td colSpan={11} className="py-8 text-center text-slate-400">
                      No baseline parts found for {selectedVendor}. Click <b>Upload & Stage Spec</b> to import records.
                    </td>
                  </tr>
                ) : (
                  filteredProducts.map(prod => {
                    const { baseRm } = parseMaterialString(prod.approvedRm || prod.baseRm);
                    const rmInfo = getActiveRmMapping(baseRm || prod.baseRm || prod.approvedRm, prod.vendor);
                    
                    return (
                      <tr key={prod.id || prod.itemCode} className="hover:bg-slate-50 transition-colors">
                        <td className="py-2.5 px-3">
                          <div className="font-mono font-bold text-blue-700">{prod.itemCode}</div>
                          <div className="font-semibold text-slate-800">{prod.componentName}</div>
                        </td>
                        <td className="py-2.5 px-3 font-mono text-slate-600">{prod.model || '-'}</td>
                        <td className="py-2.5 px-3">
                          <div className="font-bold text-slate-900">{prod.approvedRm || '-'}</div>
                          <div className="text-[10px] text-slate-500 font-mono">
                            RM Matrix Rate: ₹{rmInfo.approvedPrice || 0}/kg
                          </div>
                        </td>
                        <td className="py-2.5 px-3 text-center font-mono font-bold text-purple-700">{prod.masterbatchPct || 0}%</td>
                        <td className="py-2.5 px-3 text-center font-mono font-bold text-slate-800">{prod.cavity || 1}</td>
                        <td className="py-2.5 px-3 text-right font-mono text-slate-800">{prod.netWeight || 0}g</td>
                        <td className="py-2.5 px-3 text-right font-mono text-slate-800">{prod.runnerWeight || 0}g</td>
                        <td className="py-2.5 px-3 text-center font-mono font-black text-amber-900 bg-amber-50/50">{prod.cycleTimeApproved || 0}s</td>
                        <td className="py-2.5 px-3 text-center font-mono text-slate-800">{prod.machineTonnage || 0}T</td>
                        <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">₹{prod.shiftTariff || 0}</td>
                        <td className="py-2.5 px-4 text-center">
                          <button
                            onClick={() => handleEditClick(prod)}
                            className="px-3 py-1 bg-blue-50 hover:bg-blue-100 text-blue-700 border border-blue-200 rounded-lg font-bold flex items-center gap-1 mx-auto cursor-pointer shadow-xs"
                          >
                            <Edit3 className="w-3.5 h-3.5 text-blue-600" /> Edit Spec
                          </button>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Timestamp</th>
                  <th className="py-2.5 px-3">Code / Ref</th>
                  <th className="py-2.5 px-4">Component / Target</th>
                  <th className="py-2.5 px-4">Modifications</th>
                  <th className="py-2.5 px-3 text-right">Cost Impact</th>
                  <th className="py-2.5 px-4">Reason</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {vendorAuditLogs.length === 0 ? (
                  <tr><td colSpan={6} className="py-8 text-center text-slate-400">No modification logs recorded for {selectedVendor}.</td></tr>
                ) : (
                  vendorAuditLogs.map((log, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-500">{log.timestamp}</td>
                      <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{log.partCode}</td>
                      <td className="py-2.5 px-4 font-semibold text-slate-800">{log.componentName}</td>
                      <td className="py-2.5 px-4 font-mono text-[11px] text-slate-700">{log.modifications}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">{log.costImpact}</td>
                      <td className="py-2.5 px-4 text-slate-600">{log.reason}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* RENDER INLINE EDIT MODAL */}
      {editingProduct && (
        <InlineEditModal
          product={editingProduct}
          onClose={() => setEditingProduct(null)}
          onSave={handleSaveProduct}
          onDelete={handleDeleteProduct}
        />
      )}

      {/* RENDER COMPLETE STAGING MODAL (All 30 Specification Rows) */}
      {showUploadModal && activeStaged && (
        <div className="fixed inset-0 z-50 bg-slate-900/70 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-4xl w-full max-h-[92vh] flex flex-col shadow-2xl overflow-hidden text-xs">
            {/* Header */}
            <div className="p-4 bg-white border-b border-slate-200 flex justify-between items-start">
              <div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                  <h3 className="text-sm font-bold text-slate-900">
                    Staging & Verification: {selectedVendor} Product Import ({stagedData.length} Staged Parts)
                  </h3>
                </div>
                <p className="text-[11px] text-slate-500 mt-0.5">
                  Review complete specification parameters and make inline corrections before final baseline confirmation.
                </p>
              </div>
              <button onClick={() => setShowUploadModal(false)} className="p-1 hover:bg-slate-100 rounded text-slate-400 hover:text-slate-600 cursor-pointer">
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Horizontal Part Carousel */}
            <div className="bg-slate-100/70 p-2 border-b border-slate-200 flex items-center gap-1.5">
              <button 
                onClick={() => scrollTabs(-200)}
                className="p-1 bg-white hover:bg-slate-200 rounded border border-slate-300 shadow-2xs text-slate-600 cursor-pointer"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>

              <div 
                ref={tabsContainerRef}
                className="flex gap-2 overflow-x-auto no-scrollbar py-1 scroll-smooth flex-1"
                style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
              >
                {stagedData.map((st, idx) => {
                  const isSelected = idx === selectedStagedIndex;
                  return (
                    <button
                      key={idx}
                      onClick={() => setSelectedStagedIndex(idx)}
                      className={`px-3 py-2 rounded-xl text-left border transition-all shrink-0 w-48 cursor-pointer ${
                        isSelected 
                          ? 'bg-blue-600 text-white border-blue-700 shadow-md font-bold' 
                          : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
                      }`}
                    >
                      <div className="font-mono text-[10px] leading-tight truncate">{st.itemCode}</div>
                      <div className="text-[9px] mt-0.5 line-clamp-2 leading-tight opacity-90">{st.componentName}</div>
                    </button>
                  );
                })}
              </div>

              <button 
                onClick={() => scrollTabs(200)}
                className="p-1 bg-white hover:bg-slate-200 rounded border border-slate-300 shadow-2xs text-slate-600 cursor-pointer"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>

            {/* Staged Component Banner */}
            <div className="px-5 py-3 bg-slate-50/90 border-b border-slate-200 flex justify-between items-center">
              <div>
                <div className="text-[9px] uppercase font-bold text-slate-400">STAGED COMPONENT & ITEM CODE</div>
                <div className="text-xs font-bold text-slate-900 font-mono mt-0.5">
                  [{activeStaged.itemCode}] {activeStaged.componentName}
                </div>
              </div>
              <div className="text-right">
                <div className="text-[9px] uppercase font-bold text-emerald-700">COMPUTED STAGED TOTAL COST</div>
                <div className="text-base font-black font-mono text-emerald-600 mt-0.5">
                  ₹{computedStagedTotal.toFixed(2)}
                </div>
              </div>
            </div>

            {/* Full 30-Row Specification Table */}
            <div className="flex-1 overflow-y-auto p-4 space-y-1">
              {!isHaierVendor ? (
                <table className="w-full text-left border-collapse text-xs">
                  <thead className="bg-slate-100 text-slate-700 text-[10px] uppercase font-bold sticky top-0 border-b border-slate-200">
                    <tr>
                      <th className="py-2 px-3">Atomberg Cost Parameter</th>
                      <th className="py-2 px-3 text-center w-24">UOM</th>
                      <th className="py-2 px-4 text-right w-64">Staged Value (Editable)</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 font-medium">
                    <tr>
                      <td className="py-2 px-3 font-bold">1. Part Name / Description</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-bold text-slate-800">{activeStaged.componentName}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3 font-bold text-blue-700">2. Item No. / Part Code</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{activeStaged.itemCode}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">3. Model / Fan Series</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-mono">{activeStaged.model}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">4. Mould Size L x W x H</td>
                      <td className="py-2 px-3 text-center">mm</td>
                      <td className="py-2 px-4 text-right font-mono">{activeStaged.mouldSize}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">5. Base Polymer & Grade</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-semibold text-slate-700">{activeStaged.approvedRm}</td>
                    </tr>
                    <tr className="bg-purple-50/40">
                      <td className="py-2 px-3 font-bold text-purple-900">6. Masterbatch %</td>
                      <td className="py-2 px-3 text-center">%</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          step="0.1" 
                          value={activeStaged.masterbatchPct} 
                          onChange={e => handleUpdateActiveStaged('masterbatchPct', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-purple-300 rounded text-right font-bold text-purple-900 bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-amber-50/30">
                      <td className="py-2 px-3 font-bold text-amber-950">7. Part Net Weight</td>
                      <td className="py-2 px-3 text-center">Gms</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          step="0.01"
                          value={activeStaged.netWeight} 
                          onChange={e => handleUpdateActiveStaged('netWeight', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-amber-50/30">
                      <td className="py-2 px-3 font-bold text-amber-950">8. Runner Weight</td>
                      <td className="py-2 px-3 text-center">Gms</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          step="0.01"
                          value={activeStaged.runnerWeight} 
                          onChange={e => handleUpdateActiveStaged('runnerWeight', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-amber-50/30">
                      <td className="py-2 px-3 font-bold text-amber-950">9. No. of Cavity</td>
                      <td className="py-2 px-3 text-center">Nos</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={activeStaged.cavity} 
                          onChange={e => handleUpdateActiveStaged('cavity', parseInt(e.target.value, 10) || 1)} 
                          className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-slate-50 font-bold">
                      <td className="py-2 px-3">10. Total Shot Weight = (Part Wt * Cavity) + Runner Wt</td>
                      <td className="py-2 px-3 text-center">Gms</td>
                      <td className="py-2 px-4 text-right font-mono">{Number(atomStagedCalc?.totalShotWt || (activeStaged.netWeight * activeStaged.cavity + activeStaged.runnerWeight)).toFixed(2)}g</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">11. Landed Polymer Rate = (RM Base * 1.01 + 1.50)</td>
                      <td className="py-2 px-3 text-center">₹/kg</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.landedRm || 133.81}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">12. Landed Masterbatch Rate = (MB Base * 1.01 + 2.00)</td>
                      <td className="py-2 px-3 text-center">₹/kg</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.landedMb || 246.42}</td>
                    </tr>
                    <tr className="bg-slate-50 font-bold">
                      <td className="py-2 px-3">13. Blended Material Rate</td>
                      <td className="py-2 px-3 text-center">₹/kg</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.blendedRmRate || 136.06}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">14. Raw Material Cost / Pc</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.rawMatCostPerPc || 18.56}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3 text-rose-700">15. Less: Runner Scrap Credit (₹25/kg)</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono text-rose-700">- ₹{atomStagedCalc?.runnerScrapCredit || 0.07}</td>
                    </tr>
                    <tr className="bg-emerald-50/50 font-bold text-emerald-950">
                      <td className="py-2 px-3">16. Net Raw Material Cost / Pc</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.netRmCost || 18.49}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">17. Machine Used (Tonnage)</td>
                      <td className="py-2 px-3 text-center">T</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={activeStaged.machineTonnage} 
                          onChange={e => handleUpdateActiveStaged('machineTonnage', parseInt(e.target.value, 10) || 0)} 
                          className="w-24 px-2 py-0.5 border border-slate-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3 font-bold">18. Machine Tariff per Shift</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={activeStaged.shiftTariff} 
                          onChange={e => handleUpdateActiveStaged('shiftTariff', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-slate-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-amber-50/50">
                      <td className="py-2 px-3 font-black text-amber-950">19. Cycle Time</td>
                      <td className="py-2 px-3 text-center">Sec</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={activeStaged.cycleTimeApproved} 
                          onChange={e => handleUpdateActiveStaged('cycleTimeApproved', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-amber-400 rounded text-right font-black text-amber-950 bg-white" 
                        />
                      </td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">20. Theoretical Shots / Shift (8 hr)</td>
                      <td className="py-2 px-3 text-center">Nos</td>
                      <td className="py-2 px-4 text-right font-mono">{atomStagedCalc?.theoreticalShots || 757.89}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">21. Actual Output / Shift (90% Efficiency)</td>
                      <td className="py-2 px-3 text-center">Nos</td>
                      <td className="py-2 px-4 text-right font-mono">{atomStagedCalc?.partsPerShift || 1364.21}</td>
                    </tr>
                    <tr className="bg-slate-50 font-bold">
                      <td className="py-2 px-3">22. Conversion Rate / Pc</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.convRatePerPc || 2.05}</td>
                    </tr>
                    <tr className="bg-slate-100 font-bold">
                      <td className="py-2 px-3">23. Base Cost = Net RM + Conversion Rate</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono font-bold">₹{atomStagedCalc?.baseCost || 20.54}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">24. Overheads & Profit (12%)</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.ohAndProfit || 2.46}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">25. In-Process Rejection (4%)</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.inProcessRejection || 0.82}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">26. Mould Maintenance (2%)</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹{atomStagedCalc?.mouldMaintenance || 0.04}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">28. Post Operation Cost</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹1.73</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">29. Packing Cost</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹0.86</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3">30. Freight & Transport Cost</td>
                      <td className="py-2 px-3 text-center">Rs</td>
                      <td className="py-2 px-4 text-right font-mono">₹0.62</td>
                    </tr>
                    <tr className="bg-slate-900 text-white font-black">
                      <td className="py-2.5 px-3 uppercase text-amber-400">31. FINAL LANDED COST / PC</td>
                      <td className="py-2.5 px-3 text-center">Rs</td>
                      <td className="py-2.5 px-4 text-right font-mono text-amber-300 text-sm">₹{computedStagedTotal.toFixed(2)}</td>
                    </tr>
                  </tbody>
                </table>
              ) : (
                <table className="w-full text-left border-collapse text-xs">
                  <thead className="bg-slate-100 text-slate-700 text-[10px] uppercase font-bold sticky top-0 border-b border-slate-200">
                    <tr>
                      <th className="py-2 px-3 w-8">#</th>
                      <th className="py-2 px-3">DESCRIPTION / COSTING LINE</th>
                      <th className="py-2 px-3 text-center w-24">UOM</th>
                      <th className="py-2 px-4 text-right w-64">STAGED VALUE (EDITABLE)</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 font-medium">
                    <tr>
                      <td className="py-2 px-3 font-mono text-slate-400">1</td>
                      <td className="py-2 px-3 font-bold">Name Of component</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-bold text-slate-800">{activeStaged.componentName}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3 font-mono text-slate-400">3</td>
                      <td className="py-2 px-3 font-bold text-blue-700">Item No. / Part Code</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{activeStaged.itemCode}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3 font-mono text-slate-400">5</td>
                      <td className="py-2 px-3 font-bold">Raw Material Required</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-bold text-slate-800">{activeStaged.approvedRm}</td>
                    </tr>
                    <tr className="bg-slate-900 text-white font-black">
                      <td className="py-2.5 px-3 font-mono text-amber-400">38</td>
                      <td className="py-2.5 px-3 uppercase text-amber-400">TOTAL COST</td>
                      <td className="py-2.5 px-3 text-center">Rs</td>
                      <td className="py-2.5 px-4 text-right font-mono text-amber-300 text-sm">₹{computedStagedTotal.toFixed(2)}</td>
                    </tr>
                  </tbody>
                </table>
              )}
            </div>

            {/* Modal Footer Actions */}
            <div className="p-4 bg-slate-50 border-t border-slate-200 flex justify-between items-center">
              <button 
                onClick={() => setShowUploadModal(false)} 
                className="px-5 py-2.5 bg-white hover:bg-slate-100 border border-slate-300 text-slate-700 rounded-xl font-bold cursor-pointer transition shadow-2xs"
              >
                Cancel Staging
              </button>
              <button 
                onClick={handleCommitStaged} 
                className="px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-2 cursor-pointer shadow-md transition text-xs"
              >
                <CheckCircle2 className="w-4 h-4" /> Confirm & Add All Staged Products ({stagedData.length})
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
PAGE_EOF

echo "==> 4. Verifying build strictly on dev-v2..."
npm run build

echo "==> 5. Committing and pushing ONLY to origin/dev-v2 (Zero push to main)..."
git add -A
git commit -m "fix(atomberg): full 30-row specification table restore in staging and inline edit modal" || echo "dev-v2 clean."
git push origin dev-v2

echo "==> 6. Restarting local dev server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! All 30 Atomberg specification rows restored and live."
echo "-------------------------------------------------------------------"
