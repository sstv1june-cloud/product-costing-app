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
    cavity: Number(product.cavity) || 2,
    runnerWeight: Number(product.runnerWeight) || (isAtomberg ? 5.27 : 0),
    netWeight: Number(product.netWeight) || (isAtomberg ? 133.81 : 372),
    shotWeight: Number(product.shotWeight) || (isAtomberg ? 272.89 : 372),
    reconciliationWeight: Number(product.reconciliationWeight) || 0,
    machineTonnage: Number(product.machineTonnage) || 150,
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

        {/* Modal Body */}
        <div className="flex-1 overflow-y-auto p-4 space-y-2">
          {!isHaier ? (
            /* ========================================================================= */
            /* ATOMBERG DUAL COLUMN TABLE                                                */
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
                  <td className="py-2 px-3 font-bold">Part Name / Item Code</td>
                  <td className="py-2 px-3 text-center">-</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-slate-800">{product.componentName}</td>
                  <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{product.componentName}</td>
                  <td className="py-2 px-3 text-right text-slate-400">-</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">Base Polymer & Grade</td>
                  <td className="py-2 px-3 text-center">-</td>
                  <td className="py-2 px-4 text-right font-semibold text-slate-700">{formData.approvedRm}</td>
                  <td className="py-2 px-4 text-right font-semibold text-blue-800">{formData.approvedRm}</td>
                  <td className="py-2 px-3 text-right text-emerald-600 font-bold">Matched</td>
                </tr>
                <tr>
                  <td className="py-2 px-3 font-bold text-purple-900">Masterbatch %</td>
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
                  <td className="py-2 px-3">Part Net Weight</td>
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
                  <td className="py-2 px-3">Runner Weight</td>
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
                  <td className="py-2 px-3">No. of Cavity</td>
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
                  <td className="py-2 px-3">Total Shot Weight</td>
                  <td className="py-2 px-3 text-center">Gms</td>
                  <td className="py-2 px-4 text-right font-mono">{atombergBaseCalc.totalShotWt}g</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.totalShotWt}g</td>
                  <td className="py-2 px-3 text-right font-mono">{(atombergBaseCalc.totalShotWt - atombergRunningCalc.totalShotWt).toFixed(2)}g</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">Landed Polymer Base Rate (RM * 1.01 + 1.50)</td>
                  <td className="py-2 px-3 text-center">₹/kg</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.landedRm}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">₹{atombergRunningCalc.landedRm}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.landedRm - atombergRunningCalc.landedRm).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">Landed Masterbatch Rate (MB * 1.01 + 2.00)</td>
                  <td className="py-2 px-3 text-center">₹/kg</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.landedMb}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.landedMb}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.landedMb - atombergRunningCalc.landedMb).toFixed(2)}</td>
                </tr>
                <tr className="bg-slate-50 font-bold">
                  <td className="py-2 px-3">Blended Material Rate</td>
                  <td className="py-2 px-3 text-center">₹/kg</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.blendedRmRate}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.blendedRmRate}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.blendedRmRate - atombergRunningCalc.blendedRmRate).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">Raw Material Cost / Pc</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.rawMatCostPerPc}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.rawMatCostPerPc}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.rawMatCostPerPc - atombergRunningCalc.rawMatCostPerPc).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3 text-rose-700">Less: Runner Scrap Credit (₹25/kg)</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono text-rose-700">- ₹{atombergBaseCalc.runnerScrapCredit}</td>
                  <td className="py-2 px-4 text-right font-mono text-rose-700">- ₹{atombergRunningCalc.runnerScrapCredit}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr className="bg-emerald-50/50 font-bold text-emerald-950">
                  <td className="py-2 px-3">Net Raw Material Cost / Pc</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.netRmCost}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-900">₹{atombergRunningCalc.netRmCost}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.netRmCost - atombergRunningCalc.netRmCost).toFixed(2)}</td>
                </tr>
                <tr>
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
                  <td className="py-2 px-3">Machine Shift Tariff</td>
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
                  <td className="py-2 px-3">Actual Output / Shift (90% Efficiency)</td>
                  <td className="py-2 px-3 text-center">Nos</td>
                  <td className="py-2 px-4 text-right font-mono">{atombergBaseCalc.partsPerShift}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.partsPerShift}</td>
                  <td className="py-2 px-3 text-right font-mono">{(atombergBaseCalc.partsPerShift - atombergRunningCalc.partsPerShift).toFixed(2)}</td>
                </tr>
                <tr className="bg-slate-50 font-bold">
                  <td className="py-2 px-3">Conversion Rate / Pc</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.convRatePerPc}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.convRatePerPc}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.convRatePerPc - atombergRunningCalc.convRatePerPc).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3 font-semibold">Overheads & Profit (12% on Base Cost)</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.ohAndProfit}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.ohAndProfit}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.ohAndProfit - atombergRunningCalc.ohAndProfit).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">In-Process Rejection (4% on Base Cost)</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.inProcessRejection}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.inProcessRejection}</td>
                  <td className="py-2 px-3 text-right font-mono">₹{(atombergBaseCalc.inProcessRejection - atombergRunningCalc.inProcessRejection).toFixed(2)}</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">Mould Maintenance (2% on Conversion)</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.mouldMaintenance}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.mouldMaintenance}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">Post Operation Cost</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.postOpCost}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.postOpCost}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">Packing Cost</td>
                  <td className="py-2 px-3 text-center">Rs</td>
                  <td className="py-2 px-4 text-right font-mono">₹{atombergBaseCalc.packingCost}</td>
                  <td className="py-2 px-4 text-right font-mono text-blue-800">{atombergRunningCalc.packingCost}</td>
                  <td className="py-2 px-3 text-right font-mono">₹0.00</td>
                </tr>
                <tr>
                  <td className="py-2 px-3">Freight & Transport Cost</td>
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
      postOpCost: item.postOpCost || 1.73,
      packingCost: item.packingCost || 0.86,
      transportCost: item.transportCost || 0.62,
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
