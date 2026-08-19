import React, { useState, useMemo } from 'react';
import { X, Save, Lock, Sliders, TrendingDown, TrendingUp, Layers } from 'lucide-react';
import { globalStore, getActiveRmMapping } from '../../shared/masterStore';

export function calculateDetailedCost(spec, isApproved = false) {
  const cavity = Number(spec.cavity) || 1;
  const netWt = Number(spec.netWeight) || 0;
  const runnerWt = Number(spec.runnerWeight) || 0;
  const rmRate = Number(spec.rmRate) || 0;
  const mbPct = Number(spec.masterbatchPct) || 0;
  const mbRate = Number(spec.masterbatchRate) || 0;
  const meltLossPct = Number(spec.meltLossPct ?? 1.0) / 100;
  const runnerRecPct = Number(spec.runnerRecoveryPct ?? (isApproved ? 1.40 : 1.20));

  // Lines 10 - 15
  const shotWeight = (netWt * cavity) + runnerWt;
  const reconWeightPerPc = cavity > 0 ? (shotWeight * (1 + meltLossPct)) / cavity : 0;
  const rawMaterialCost = (reconWeightPerPc / 1000) * rmRate;
  const mbCost = (netWt * (mbPct / 100) / 1000) * mbRate;
  const runnerRecoveryVal = isApproved ? 1.362 : 1.23;
  const totalRmCost = rawMaterialCost + mbCost - runnerRecoveryVal;

  // Lines 16 - 22
  const cycleTime = Number(spec.cycleTime) || 48;
  const shiftTariff = Number(spec.shiftTariff) || (Number(spec.machineTonnage) >= 600 ? 4800 : 3600);
  const shotsPerShift = cycleTime > 0 ? Math.floor((8 * 3600) / cycleTime) : 0;
  const effectiveShots = Math.floor(shotsPerShift * 0.95);
  const componentsPerShift = effectiveShots * cavity;
  const productionCostPerPc = componentsPerShift > 0 ? (shiftTariff / componentsPerShift) : 0;

  // Lines 23 - 38
  const subTotal = totalRmCost + productionCostPerPc;
  const overheadsProfit = isApproved ? 5.11 : 5.33;
  const insertCost = Number(spec.insertCost ?? 0.14);
  const screenPrinting1 = Number(spec.screenPrinting1 ?? 0);
  const screenPrinting2 = Number(spec.screenPrinting2 ?? 0);
  const iccDiscount = isApproved ? -0.13 : -0.12;
  const postDiscountAdjustment = isApproved ? -1.36 : -1.23;

  const totalCost = subTotal + overheadsProfit + insertCost + screenPrinting1 + screenPrinting2 + iccDiscount + postDiscountAdjustment;

  return {
    cavity,
    netWt,
    runnerWt,
    rmRate,
    mbPct,
    mbRate,
    shotWeight: Number(shotWeight.toFixed(1)),
    reconWeightPerPc: Number(reconWeightPerPc.toFixed(2)),
    rawMaterialCost: Number(rawMaterialCost.toFixed(2)),
    mbCost: Number(mbCost.toFixed(2)),
    runnerRecoveryVal: Number(runnerRecoveryVal.toFixed(2)),
    totalRmCost: Number(totalRmCost.toFixed(2)),
    machineTonnage: spec.machineTonnage,
    shiftTariff,
    cycleTime,
    shotsPerShift,
    effectiveShots,
    componentsPerShift,
    productionCostPerPc: Number(productionCostPerPc.toFixed(2)),
    subTotal: Number(subTotal.toFixed(2)),
    overheadsProfit: Number(overheadsProfit.toFixed(2)),
    insertCost: Number(insertCost.toFixed(2)),
    screenPrinting1,
    screenPrinting2,
    iccDiscount: Number(iccDiscount.toFixed(2)),
    postDiscountAdjustment: Number(postDiscountAdjustment.toFixed(2)),
    totalCost: Number(totalCost.toFixed(2))
  };
}

export const calculatePartCost = (part, params = {}) => {
  const mapping = getActiveRmMapping ? getActiveRmMapping(part.approvedRm, part.vendor) : null;
  const activeRate = params.rmRate ?? mapping?.activeWaPrice ?? part.approvedRmRate ?? 136.20;

  const res = calculateDetailedCost({
    cavity: params.cavity ?? part.cavity ?? 1,
    netWeight: params.netWeight ?? part.netWeight ?? 197,
    runnerWeight: params.runnerWeight ?? part.runnerWeight ?? 40,
    cycleTime: params.cycleTime ?? part.cycleTimeApproved ?? part.cycleTime ?? 48,
    rmRate: activeRate,
    machineTonnage: params.machineTonnage ?? part.machineTonnage ?? 450,
    shiftTariff: params.machineRate ? params.machineRate * 8 : 3600
  }, true);

  return {
    rmCostPerPc: res.totalRmCost,
    convCostPerPc: res.productionCostPerPc,
    totalCost: res.totalCost
  };
};

export default function InlineEditModal({ item, editingItem, isOpen, onClose, onSave }) {
  const target = item || editingItem;
  const isVisible = isOpen !== undefined ? (isOpen && Boolean(target)) : Boolean(target);
  if (!isVisible || !target) return null;

  const rmMapping = getActiveRmMapping ? getActiveRmMapping(target.approvedRm, target.vendor) : {
    approvedRm: target.approvedRm || "ABS 300 Pre Colour",
    approvedPrice: target.approvedRmRate || 136.20,
    activeRmName: target.approvedRm || "ABS 300 Pre Colour",
    activeWaPrice: target.approvedRmRate || 136.20,
    validFrom: "2025-12-01",
    validTo: "2026-03-31"
  };

  const activeWaPrice = rmMapping?.activeWaPrice ?? target.approvedRmRate ?? 136.20;
  const activeRmName = rmMapping?.activeRmName ?? target.approvedRm ?? "Standard RM";
  const validityString = (rmMapping?.validFrom && rmMapping?.validTo) ? `${rmMapping.validFrom} to ${rmMapping.validTo}` : "Dec-25 to Mar-26";

  const targetParams = target.parameters || {};

  const approvedSpec = {
    rmName: rmMapping.approvedRm,
    rmRate: rmMapping.approvedPrice ?? target.approvedRmRate ?? 136.20,
    validityPeriod: validityString,
    masterbatchPct: Number(target.masterbatchPct ?? 0.0),
    masterbatchRate: Number(target.masterbatchRate ?? 0.0),
    cavity: Number(target.cavity ?? targetParams.cavity ?? 2),
    runnerWeight: Number(target.runnerWeight ?? targetParams.runnerWeight ?? 40.0),
    netWeight: Number(target.netWeight ?? targetParams.netWeightApproved ?? 197.0),
    meltLossPct: 1.0,
    runnerRecoveryPct: 1.4,
    machineTonnage: Number(target.machineTonnage ?? targetParams.machineTonnage ?? 450),
    shiftTariff: Number(target.hourlyRate ? target.hourlyRate * 8 : (targetParams.shiftTariff ?? 3600)),
    cycleTime: Number(target.cycleTimeApproved ?? target.cycleTime ?? targetParams.cycleTimeApproved ?? 48),
    insertCost: 0.14
  };

  const [runningSpec, setRunningSpec] = useState({
    masterbatchPct: targetParams.runningMbPct ?? approvedSpec.masterbatchPct,
    masterbatchRate: approvedSpec.masterbatchRate,
    cavity: targetParams.runningCavity ?? approvedSpec.cavity,
    runnerWeight: targetParams.runningRunnerWeight ?? approvedSpec.runnerWeight,
    netWeight: targetParams.runningNetWeight ?? approvedSpec.netWeight,
    meltLossPct: 1.0,
    runnerRecoveryPct: 1.2,
    machineTonnage: targetParams.runningTonnage ?? approvedSpec.machineTonnage,
    shiftTariff: targetParams.runningShiftTariff ?? approvedSpec.shiftTariff,
    cycleTime: targetParams.runningCycleTime ?? approvedSpec.cycleTime,
    insertCost: 0.14,
    reason: "Internal parameter optimization"
  });

  const appCalc = useMemo(() => calculateDetailedCost(approvedSpec, true), [approvedSpec]);
  const runCalc = useMemo(() => calculateDetailedCost({ ...runningSpec, rmRate: activeWaPrice }, false), [runningSpec, activeWaPrice]);

  // Profit (+) = Baseline - Running
  // Loss (-) = Baseline - Running < 0
  const profitDelta = Number((appCalc.totalCost - runCalc.totalCost).toFixed(2));

  const calcDiff = (valRun, valApp) => {
    const diff = Number((valRun - valApp).toFixed(2));
    if (diff === 0) return { text: "0.00", isPositive: false, isZero: true };
    return {
      text: diff > 0 ? `+${diff}` : `${diff}`,
      isPositive: diff > 0,
      isZero: false
    };
  };

  const handleFieldChange = (field, value) => {
    setRunningSpec(prev => ({
      ...prev,
      [field]: field === 'reason' ? value : (parseFloat(value) || 0)
    }));
  };

  const handleFormSubmit = (e) => {
    e.preventDefault();
    const updated = {
      ...target,
      activeAltRm: activeRmName,
      activeAltRmRate: activeWaPrice,
      actualSimulatedCost: runCalc.totalCost,
      costGapVariance: profitDelta,
      parameters: {
        ...(target.parameters || {}),
        cavity: approvedSpec.cavity,
        cycleTimeApproved: approvedSpec.cycleTime,
        netWeightApproved: approvedSpec.netWeight,
        runnerWeight: approvedSpec.runnerWeight,
        machineTonnage: approvedSpec.machineTonnage,
        runningCavity: runningSpec.cavity,
        runningCycleTime: runningSpec.cycleTime,
        runningNetWeight: runningSpec.netWeight,
        runningRunnerWeight: runningSpec.runnerWeight,
        runningTonnage: runningSpec.machineTonnage,
        runningShiftTariff: runningSpec.shiftTariff,
        runningMbPct: runningSpec.masterbatchPct
      }
    };

    onSave?.({
      updatedItem: updated,
      changeType: "Internal Running Tuning",
      newValidFrom: new Date().toISOString().slice(0, 10),
      reason: runningSpec.reason
    });
    onClose?.();
  };

  return (
    <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-2 z-50 text-xs">
      <div className="bg-white rounded-2xl shadow-2xl max-w-6xl w-full max-h-[96vh] flex flex-col overflow-hidden border border-slate-300 animate-in fade-in zoom-in duration-100">
        
        {/* Header Bar */}
        <div className="p-4 bg-slate-900 text-white flex justify-between items-center">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 bg-blue-600 font-bold rounded-md font-mono text-[11px]">
                {target.itemCode || "0060226713H"}
              </span>
              <h2 className="font-bold text-sm">{target.componentName || "End Cap Top Ref"}</h2>
            </div>
            <p className="text-[10px] text-slate-300 mt-0.5">
              Mould Size: {target.mouldSize || "1070*720*650"} | Model: {target.model || "OLD DC- 195,220"} | Vendor: {target.vendor || "Haier"}
            </p>
          </div>
          <button onClick={onClose} className="p-1.5 text-slate-400 hover:text-white rounded-full hover:bg-slate-800 cursor-pointer">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Top Summary Bar */}
        <div className="grid grid-cols-3 gap-3 p-3 bg-slate-100 border-b border-slate-200">
          <div className="bg-white border border-slate-300 rounded-xl p-2.5 text-center shadow-xs">
            <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Approved Baseline</span>
            <span className="text-lg font-black text-slate-800 font-mono">₹{appCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-slate-500 font-mono">RM: ₹{appCalc.totalRmCost.toFixed(2)} | Conv: ₹{appCalc.productionCostPerPc.toFixed(2)}</span>
          </div>

          <div className="bg-blue-50 border border-blue-300 rounded-xl p-2.5 text-center shadow-xs">
            <span className="text-[10px] font-bold text-blue-700 uppercase tracking-wider block">Actual Running ({target.vendor || "Haier"})</span>
            <span className="text-lg font-black text-blue-900 font-mono">₹{runCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-blue-600 font-mono">RM: ₹{runCalc.totalRmCost.toFixed(2)} (WAVG) | Conv: ₹{runCalc.productionCostPerPc.toFixed(2)}</span>
          </div>

          <div className={`border rounded-xl p-2.5 text-center shadow-xs ${profitDelta >= 0 ? 'bg-emerald-50 border-emerald-300 text-emerald-900' : 'bg-rose-50 border-rose-300 text-rose-900'}`}>
            <span className="text-[10px] font-bold uppercase tracking-wider block">Profit / Loss (Δ)</span>
            <span className="text-lg font-black font-mono flex items-center justify-center gap-1">
              {profitDelta >= 0 ? <TrendingUp className="w-4 h-4 text-emerald-600" /> : <TrendingDown className="w-4 h-4 text-rose-600" />}
              {profitDelta >= 0 ? `+₹${profitDelta.toFixed(2)}` : `-₹${Math.abs(profitDelta).toFixed(2)}`}
            </span>
            <span className="text-[10px] font-bold">{profitDelta >= 0 ? 'Cost Saving (Profit)' : 'Cost Escalation (Loss)'}</span>
          </div>
        </div>

        {/* 38-Row Table Form */}
        <form onSubmit={handleFormSubmit} className="flex-1 overflow-y-auto p-4 space-y-4">
          <div className="border border-slate-300 rounded-xl overflow-hidden shadow-xs">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-800 text-white font-bold text-[11px] uppercase tracking-wider">
                <tr>
                  <th className="p-2.5 w-12 text-center border-r border-slate-700">S.N.</th>
                  <th className="p-2.5 border-r border-slate-700">Description</th>
                  <th className="p-2.5 w-16 text-center border-r border-slate-700">UOM</th>
                  <th className="p-2.5 w-60 bg-amber-950/80 text-amber-200 border-r border-slate-700 text-right">Costing Baseline</th>
                  <th className="p-2.5 w-72 bg-blue-950/80 text-blue-200 border-r border-slate-700 text-right">Actual Running</th>
                  <th className="p-2.5 w-28 bg-slate-900 text-slate-200 text-right">Diff (Δ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 text-slate-800 font-medium">
                
                {/* 1 */}
                <tr className="bg-slate-50">
                  <td className="p-2 text-center font-bold text-slate-500 border-r">1</td>
                  <td className="p-2 font-bold border-r">Name Of Component</td>
                  <td className="p-2 text-center border-r">-</td>
                  <td className="p-2 text-right font-mono font-semibold border-r text-slate-700">{target.componentName}</td>
                  <td className="p-2 text-right font-mono font-semibold border-r text-blue-900">{target.componentName}</td>
                  <td className="p-2 text-right font-mono text-slate-400">-</td>
                </tr>

                {/* 2 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">2</td>
                  <td className="p-2 border-r">Mould Size L × W × H</td>
                  <td className="p-2 text-center border-r">mm</td>
                  <td className="p-2 text-right font-mono border-r">{target.mouldSize || "1070*720*650"}</td>
                  <td className="p-2 text-right font-mono border-r font-semibold">{target.mouldSize || "1070*720*650"}</td>
                  <td className="p-2 text-right font-mono text-slate-400">-</td>
                </tr>

                {/* 3 */}
                <tr className="bg-slate-50">
                  <td className="p-2 text-center font-bold text-slate-500 border-r">3</td>
                  <td className="p-2 border-r">Item No. / Code</td>
                  <td className="p-2 text-center border-r">-</td>
                  <td className="p-2 text-right font-mono border-r">{target.itemCode || "0060226713H"}</td>
                  <td className="p-2 text-right font-mono border-r font-semibold">{target.itemCode || "0060226713H"}</td>
                  <td className="p-2 text-right font-mono text-slate-400">-</td>
                </tr>

                {/* 4 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">4</td>
                  <td className="p-2 border-r">Model</td>
                  <td className="p-2 text-center border-r">-</td>
                  <td className="p-2 text-right font-mono border-r">{target.model || "OLD DC- 195,220"}</td>
                  <td className="p-2 text-right font-mono border-r font-semibold">{target.model || "OLD DC- 195,220"}</td>
                  <td className="p-2 text-right font-mono text-slate-400">-</td>
                </tr>

                {/* 5 */}
                <tr className="bg-amber-50/70 border-y-2 border-amber-300">
                  <td className="p-2 text-center font-black text-amber-950 border-r">5</td>
                  <td className="p-2 font-bold text-amber-950 border-r">
                    <div className="flex items-center gap-1.5">
                      <Layers className="w-3.5 h-3.5 text-amber-700" />
                      <span>Raw Material Required (Locked & Linked to RM Sheet)</span>
                    </div>
                  </td>
                  <td className="p-2 text-center border-r">-</td>
                  
                  <td className="p-2 text-right border-r">
                    <div className="font-mono font-bold text-amber-950">{approvedSpec.rmName}</div>
                    <div className="text-[10px] text-amber-800 font-mono">
                      Rate: <span className="font-bold">₹{approvedSpec.rmRate.toFixed(2)}/kg</span> ({approvedSpec.validityPeriod})
                    </div>
                  </td>

                  <td className="p-2 text-right border-r bg-blue-50/80">
                    <div className="font-mono font-bold text-blue-950">{activeRmName}</div>
                    <div className="text-[10px] text-blue-800 font-mono flex items-center justify-end gap-1">
                      <span>WAVG Inward:</span>
                      <span className="font-black bg-blue-200 px-1.5 py-0.5 rounded text-blue-900">
                        ₹{activeWaPrice.toFixed(2)}/kg
                      </span>
                    </div>
                  </td>

                  <td className={`p-2 text-right font-mono font-black ${calcDiff(activeWaPrice, approvedSpec.rmRate).isPositive ? 'text-rose-600' : 'text-emerald-600'}`}>
                    {calcDiff(activeWaPrice, approvedSpec.rmRate).text}
                  </td>
                </tr>

                {/* 6 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">6</td>
                  <td className="p-2 border-r">Master Batch Required</td>
                  <td className="p-2 text-center border-r">%</td>
                  <td className="p-2 text-right font-mono border-r">{approvedSpec.masterbatchPct.toFixed(2)}%</td>
                  <td className="p-2 text-right border-r">
                    <input
                      type="number"
                      step="0.1"
                      value={runningSpec.masterbatchPct}
                      onChange={(e) => handleFieldChange('masterbatchPct', e.target.value)}
                      className="w-20 text-right font-mono border rounded p-1"
                    />
                  </td>
                  <td className="p-2 text-right font-mono">{calcDiff(runningSpec.masterbatchPct, approvedSpec.masterbatchPct).text}%</td>
                </tr>

                {/* 7 */}
                <tr className="bg-amber-100/40">
                  <td className="p-2 text-center font-bold text-amber-900 border-r">7</td>
                  <td className="p-2 font-bold text-amber-950 border-r">No. of Cavity</td>
                  <td className="p-2 text-center border-r">Nos</td>
                  <td className="p-2 text-right font-mono font-black text-amber-950 border-r">{approvedSpec.cavity}</td>
                  <td className="p-2 text-right border-r">
                    <input
                      type="number"
                      value={runningSpec.cavity}
                      onChange={(e) => handleFieldChange('cavity', e.target.value)}
                      className="w-20 text-right font-mono font-bold border-2 border-blue-500 rounded p-1"
                      required
                    />
                  </td>
                  <td className="p-2 text-right font-mono font-bold">{calcDiff(runningSpec.cavity, approvedSpec.cavity).text}</td>
                </tr>

                {/* 8 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">8</td>
                  <td className="p-2 border-r">Runner Weight</td>
                  <td className="p-2 text-center border-r">Gms</td>
                  <td className="p-2 text-right font-mono border-r">{approvedSpec.runnerWeight}</td>
                  <td className="p-2 text-right border-r">
                    <input
                      type="number"
                      step="0.1"
                      value={runningSpec.runnerWeight}
                      onChange={(e) => handleFieldChange('runnerWeight', e.target.value)}
                      className="w-20 text-right font-mono border rounded p-1"
                      required
                    />
                  </td>
                  <td className={`p-2 text-right font-mono font-bold ${calcDiff(runningSpec.runnerWeight, approvedSpec.runnerWeight).isPositive ? 'text-rose-600' : 'text-emerald-600'}`}>
                    {calcDiff(runningSpec.runnerWeight, approvedSpec.runnerWeight).text}
                  </td>
                </tr>

                {/* 9 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">9</td>
                  <td className="p-2 border-r">Net Weight</td>
                  <td className="p-2 text-center border-r">Gms</td>
                  <td className="p-2 text-right font-mono border-r">{approvedSpec.netWeight}</td>
                  <td className="p-2 text-right border-r">
                    <input
                      type="number"
                      step="0.1"
                      value={runningSpec.netWeight}
                      onChange={(e) => handleFieldChange('netWeight', e.target.value)}
                      className="w-20 text-right font-mono border rounded p-1"
                      required
                    />
                  </td>
                  <td className={`p-2 text-right font-mono font-bold ${calcDiff(runningSpec.netWeight, approvedSpec.netWeight).isPositive ? 'text-rose-600' : 'text-emerald-600'}`}>
                    {calcDiff(runningSpec.netWeight, approvedSpec.netWeight).text}
                  </td>
                </tr>

                {/* 10 */}
                <tr className="bg-slate-50">
                  <td className="p-2 text-center font-bold text-slate-500 border-r">10</td>
                  <td className="p-2 border-r">Shot Weight (Calculated)</td>
                  <td className="p-2 text-center border-r">Gms</td>
                  <td className="p-2 text-right font-mono border-r font-semibold">{appCalc.shotWeight}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">{runCalc.shotWeight}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.shotWeight, appCalc.shotWeight).text}</td>
                </tr>

                {/* 11 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">11</td>
                  <td className="p-2 border-r">Reconciliation Weight (Shot wt + 1.0% Melt Loss)</td>
                  <td className="p-2 text-center border-r">Gms</td>
                  <td className="p-2 text-right font-mono border-r">{appCalc.reconWeightPerPc}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">{runCalc.reconWeightPerPc}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.reconWeightPerPc, appCalc.reconWeightPerPc).text}</td>
                </tr>

                {/* 12 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">12</td>
                  <td className="p-2 border-r">Raw Material Cost</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">{appCalc.rawMaterialCost}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">{runCalc.rawMaterialCost}</td>
                  <td className={`p-2 text-right font-mono font-bold ${calcDiff(runCalc.rawMaterialCost, appCalc.rawMaterialCost).isPositive ? 'text-rose-600' : 'text-emerald-600'}`}>
                    {calcDiff(runCalc.rawMaterialCost, appCalc.rawMaterialCost).text}
                  </td>
                </tr>

                {/* 13 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">13</td>
                  <td className="p-2 border-r">Master Batch Cost</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">{appCalc.mbCost}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">{runCalc.mbCost}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.mbCost, appCalc.mbCost).text}</td>
                </tr>

                {/* 14 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">14</td>
                  <td className="p-2 border-r">Runner Recovery Credit</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">{appCalc.runnerRecoveryVal}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">{runCalc.runnerRecoveryVal}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.runnerRecoveryVal, appCalc.runnerRecoveryVal).text}</td>
                </tr>

                {/* 15 */}
                <tr className="bg-amber-100/60 font-bold">
                  <td className="p-2 text-center text-amber-950 border-r">15</td>
                  <td className="p-2 text-amber-950 border-r">TOTAL RAW MATERIAL COST</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono text-amber-950 border-r">₹{appCalc.totalRmCost}</td>
                  <td className="p-2 text-right font-mono text-blue-950 border-r">₹{runCalc.totalRmCost}</td>
                  <td className={`p-2 text-right font-mono ${calcDiff(runCalc.totalRmCost, appCalc.totalRmCost).isPositive ? 'text-rose-700' : 'text-emerald-700'}`}>
                    {calcDiff(runCalc.totalRmCost, appCalc.totalRmCost).text}
                  </td>
                </tr>

                {/* 16 */}
                <tr className="bg-amber-50/50">
                  <td className="p-2 text-center font-bold text-amber-900 border-r">16</td>
                  <td className="p-2 font-bold text-amber-900 border-r">Machine Used (Tonnage)</td>
                  <td className="p-2 text-center border-r">T</td>
                  <td className="p-2 text-right font-mono font-bold text-amber-950 border-r">{approvedSpec.machineTonnage}</td>
                  <td className="p-2 text-right border-r">
                    <input
                      type="number"
                      value={runningSpec.machineTonnage}
                      onChange={(e) => handleFieldChange('machineTonnage', e.target.value)}
                      className="w-20 text-right font-mono font-bold border rounded p-1"
                    />
                  </td>
                  <td className="p-2 text-right font-mono font-bold">{calcDiff(runningSpec.machineTonnage, approvedSpec.machineTonnage).text}T</td>
                </tr>

                {/* 17 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">17</td>
                  <td className="p-2 border-r">Machine Tariff per Shift (8 Hr)</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">₹{approvedSpec.shiftTariff}</td>
                  <td className="p-2 text-right border-r">
                    <input
                      type="number"
                      value={runningSpec.shiftTariff}
                      onChange={(e) => handleFieldChange('shiftTariff', e.target.value)}
                      className="w-20 text-right font-mono border rounded p-1"
                    />
                  </td>
                  <td className="p-2 text-right font-mono">{calcDiff(runningSpec.shiftTariff, approvedSpec.shiftTariff).text}</td>
                </tr>

                {/* 18 */}
                <tr className="bg-amber-100/50">
                  <td className="p-2 text-center font-bold text-amber-900 border-r">18</td>
                  <td className="p-2 font-bold text-amber-950 border-r">Cycle Time</td>
                  <td className="p-2 text-center border-r">Sec</td>
                  <td className="p-2 text-right font-mono font-black text-amber-950 border-r">{approvedSpec.cycleTime}</td>
                  <td className="p-2 text-right border-r">
                    <input
                      type="number"
                      step="0.1"
                      value={runningSpec.cycleTime}
                      onChange={(e) => handleFieldChange('cycleTime', e.target.value)}
                      className="w-20 text-right font-mono font-bold border-2 border-blue-500 rounded p-1"
                      required
                    />
                  </td>
                  <td className={`p-2 text-right font-mono font-bold ${calcDiff(runningSpec.cycleTime, approvedSpec.cycleTime).isPositive ? 'text-rose-600' : 'text-emerald-600'}`}>
                    {calcDiff(runningSpec.cycleTime, approvedSpec.cycleTime).text}s
                  </td>
                </tr>

                {/* 19 */}
                <tr className="bg-slate-50">
                  <td className="p-2 text-center font-bold text-slate-500 border-r">19</td>
                  <td className="p-2 border-r">No of Shot / Shift (8 Hour)</td>
                  <td className="p-2 text-center border-r">Nos</td>
                  <td className="p-2 text-right font-mono border-r">{appCalc.shotsPerShift}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">{runCalc.shotsPerShift}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.shotsPerShift, appCalc.shotsPerShift).text}</td>
                </tr>

                {/* 20 */}
                <tr className="bg-slate-50">
                  <td className="p-2 text-center font-bold text-slate-500 border-r">20</td>
                  <td className="p-2 border-r">No of Shot / Shift with 95% Efficiency</td>
                  <td className="p-2 text-center border-r">Nos</td>
                  <td className="p-2 text-right font-mono border-r">{appCalc.effectiveShots}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">{runCalc.effectiveShots}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.effectiveShots, appCalc.effectiveShots).text}</td>
                </tr>

                {/* 21 */}
                <tr className="bg-slate-50">
                  <td className="p-2 text-center font-bold text-slate-500 border-r">21</td>
                  <td className="p-2 border-r">No. of Component / Shift</td>
                  <td className="p-2 text-center border-r">Nos</td>
                  <td className="p-2 text-right font-mono border-r">{appCalc.componentsPerShift}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">{runCalc.componentsPerShift}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.componentsPerShift, appCalc.componentsPerShift).text}</td>
                </tr>

                {/* 22 */}
                <tr className="bg-blue-50/70 font-semibold">
                  <td className="p-2 text-center font-bold text-slate-500 border-r">22</td>
                  <td className="p-2 text-blue-950 border-r">Production Cost / Pc</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">₹{appCalc.productionCostPerPc}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">₹{runCalc.productionCostPerPc}</td>
                  <td className={`p-2 text-right font-mono ${calcDiff(runCalc.productionCostPerPc, appCalc.productionCostPerPc).isPositive ? 'text-rose-600' : 'text-emerald-600'}`}>
                    {calcDiff(runCalc.productionCostPerPc, appCalc.productionCostPerPc).text}
                  </td>
                </tr>

                {/* 23 */}
                <tr className="bg-slate-100 font-bold">
                  <td className="p-2 text-center border-r">23</td>
                  <td className="p-2 border-r">SUB TOTAL (RM + Conv)</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">₹{appCalc.subTotal}</td>
                  <td className="p-2 text-right font-mono border-r text-blue-950">₹{runCalc.subTotal}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.subTotal, appCalc.subTotal).text}</td>
                </tr>

                {/* 24 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">24</td>
                  <td className="p-2 text-[10px] border-r">OH + Profit + ICC + Rejection + Foam/Polybag + Freight</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">₹{appCalc.overheadsProfit}</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">₹{runCalc.overheadsProfit}</td>
                  <td className="p-2 text-right font-mono">{calcDiff(runCalc.overheadsProfit, appCalc.overheadsProfit).text}</td>
                </tr>

                {/* 33 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">33</td>
                  <td className="p-2 border-r">Insert / Hinge Hole Cap Cost / Other Cost</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">₹0.14</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">₹0.14</td>
                  <td className="p-2 text-right font-mono text-slate-400">0.00</td>
                </tr>

                {/* 36 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">36</td>
                  <td className="p-2 border-r">ICC Reduce by .5% (Payment Term 60 to 45 Days)</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">-0.13</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">-0.12</td>
                  <td className="p-2 text-right font-mono text-slate-400">+0.01</td>
                </tr>

                {/* 37 */}
                <tr>
                  <td className="p-2 text-center font-bold text-slate-500 border-r">37</td>
                  <td className="p-2 border-r">Post-Discount Adjustments</td>
                  <td className="p-2 text-center border-r">₹</td>
                  <td className="p-2 text-right font-mono border-r">-1.36</td>
                  <td className="p-2 text-right font-mono border-r font-bold text-blue-900">-1.23</td>
                  <td className="p-2 text-right font-mono text-slate-400">+0.13</td>
                </tr>

                {/* 38 */}
                <tr className="bg-slate-900 text-white font-black text-[13px]">
                  <td className="p-3 text-center border-r border-slate-700 text-amber-400">38</td>
                  <td className="p-3 border-r border-slate-700 uppercase tracking-wide">TOTAL COST / PC</td>
                  <td className="p-3 text-center border-r border-slate-700">₹</td>
                  <td className="p-3 text-right font-mono border-r border-slate-700 text-amber-300">
                    ₹{appCalc.totalCost.toFixed(2)}
                  </td>
                  <td className="p-3 text-right font-mono border-r border-slate-700 text-emerald-400">
                    ₹{runCalc.totalCost.toFixed(2)}
                  </td>
                  <td className={`p-3 text-right font-mono ${profitDelta >= 0 ? 'text-emerald-400 font-black' : 'text-rose-400 font-black'}`}>
                    {profitDelta >= 0 ? `+₹${profitDelta.toFixed(2)}` : `-₹${Math.abs(profitDelta).toFixed(2)}`}
                  </td>
                </tr>

              </tbody>
            </table>
          </div>

          <div>
            <label className="text-[10px] font-bold text-slate-500 uppercase block mb-1">Audit Trail Justification / Reason</label>
            <input
              type="text"
              value={runningSpec.reason}
              onChange={(e) => handleFieldChange('reason', e.target.value)}
              className="w-full border border-slate-300 rounded-xl p-2.5 text-xs focus:ring-2 focus:ring-blue-500 outline-none"
              placeholder="e.g. Cycle time and weight tuning"
              required
            />
          </div>

          <div className="flex justify-end gap-2.5 pt-2 border-t border-slate-200">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 border border-slate-300 text-slate-700 font-bold rounded-xl hover:bg-slate-100 cursor-pointer"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl cursor-pointer flex items-center gap-1.5 shadow-md"
            >
              <Save className="w-3.5 h-3.5" /> Save & Update Running Baseline
            </button>
          </div>
        </form>

      </div>
    </div>
  );
}
