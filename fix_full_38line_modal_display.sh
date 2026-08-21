#!/usr/bin/env bash
set -e

echo "==> Updating InlineEditModal.jsx with the complete 38-line sequence (Lines 1 to 38)..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, AlertTriangle, TrendingUp, TrendingDown, Trash2 } from 'lucide-react';
import { getActiveRmMapping, getActiveMbMapping, deleteProductFromBaseline } from '../../shared/masterStore';
import { 
  calculateAtombergCost, 
  calculateHaierCost, 
  calculateDetailedCost, 
  calculatePieceCostUnified 
} from '../../shared/costCalculationService';

export { 
  calculateAtombergCost, 
  calculateHaierCost, 
  calculateDetailedCost, 
  calculatePieceCostUnified 
};

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const isAtomberg = (item.vendor || '').toLowerCase().includes('atomberg');
  const rmInfo = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');
  const mbInfo = getActiveMbMapping(item.vendor, '2026-08-01');

  const handleDelete = () => {
    deleteProductFromBaseline(item.itemCode, item.vendor);
    setShowDeleteConfirm(false);
    onClose();
  };

  const params = item.parameters || {};
  const [netWt, setNetWt] = useState(params.runningNetWeight ?? item.netWeight ?? 197);
  const [runnerWt, setRunnerWt] = useState(params.runningRunnerWeight ?? item.runnerWeight ?? 40);
  const [mbPctVal, setMbPctVal] = useState(params.runningMbPct !== undefined ? params.runningMbPct : (item.masterbatchPct ?? 0.0));
  const [bopCost, setBopCost] = useState(params.runningBopCost ?? item.bopCost ?? 0.14);
  const [cycleTime, setCycleTime] = useState(params.runningCycleTime ?? item.cycleTimeApproved ?? item.cycleTime ?? 48);
  const [cavity, setCavity] = useState(params.runningCavity ?? item.cavity ?? 2);
  const [tonnage, setTonnage] = useState(params.runningTonnage ?? item.machineTonnage ?? 450);
  
  // Machine Tariff manual inputs
  const [costingTariff, setCostingTariff] = useState(item.shiftTariff ?? 3600);
  const [actualTariff, setActualTariff] = useState(params.runningShiftTariff ?? item.shiftTariff ?? 3600);
  const [reason, setReason] = useState("Shopfloor parameters & cost verification");

  if (isAtomberg) {
    // ---------- ATOMBERG FORMAT ----------
    const approvedRmBase = Number(rmInfo.approvedPrice || 140.00);
    const approvedMbBase = Number(mbInfo.approvedMbPrice || 254.00);
    const actualRmBase = Number(rmInfo.activeWaPrice || 135.83);
    const actualMbBase = Number(mbInfo.activeMbPrice || 258.54);

    const baseP = {
      vendor: 'Atomberg',
      rmBase: approvedRmBase,
      mbBase: approvedMbBase,
      partWt: Number(item.netWeight || 37),
      runnerWt: Number(item.runnerWeight || 1),
      mbPct: Number(item.masterbatchPct || 4.0) / 100,
      bopCost: Number(item.bopCost || 0),
      cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 47),
      cavity: Number(item.cavity || 2),
      tonnage: Number(item.machineTonnage || 200),
      shiftTariff: Number(costingTariff),
      postOpCost: 1.73,
      packingCost: 0.86,
      transportCost: 0.62
    };
    const baseCalc = calculateAtombergCost(baseP);

    const runningP = {
      ...baseP,
      rmBase: actualRmBase,
      mbBase: actualMbBase,
      partWt: Number(netWt),
      runnerWt: Number(runnerWt),
      mbPct: Number(mbPctVal) / 100,
      bopCost: Number(bopCost),
      cycleTime: Number(cycleTime),
      cavity: Number(cavity),
      tonnage: Number(tonnage),
      shiftTariff: Number(actualTariff)
    };
    const runCalc = calculateAtombergCost(runningP);
    const profitLossDelta = Number((baseCalc.finalLanded - runCalc.finalLanded).toFixed(2));

    const handleSaveAtomberg = () => {
      onSave({
        updatedItem: {
          ...item,
          shiftTariff: Number(costingTariff),
          masterbatchPct: Number(mbPctVal),
          bopCost: Number(bopCost),
          parameters: {
            ...item.parameters,
            runningNetWeight: Number(netWt),
            runningRunnerWeight: Number(runnerWt),
            runningMbPct: Number(mbPctVal),
            runningBopCost: Number(bopCost),
            runningCycleTime: Number(cycleTime),
            runningCavity: Number(cavity),
            runningTonnage: Number(tonnage),
            runningShiftTariff: Number(actualTariff)
          }
        },
        changeType: "Atomberg Spec Adjustment",
        reason
      });
    };

    return (
      <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
        <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto relative">
          <div className="flex justify-between items-start border-b border-slate-200 pb-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="px-2.5 py-0.5 bg-blue-600 text-white rounded font-mono font-bold text-xs">{item.itemCode}</span>
                <h2 className="text-base font-bold text-slate-900">{item.componentName}</h2>
                <span className="text-[10px] px-2 py-0.5 bg-slate-100 text-slate-600 rounded font-semibold border">Atomberg Format</span>
              </div>
              <div className="text-[11px] text-slate-500 mt-0.5">Vendor: <span className="font-bold text-slate-700">{item.vendor}</span> | RM Link: <span className="font-mono font-bold text-blue-600">(₹{Number(rmInfo.activeWaPrice || 0).toFixed(2)}/kg)</span></div>
            </div>
            <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-700 cursor-pointer"><X className="w-5 h-5" /></button>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl">
              <div className="text-[10px] font-bold text-slate-400 uppercase">APPROVED BASELINE CONTRACT</div>
              <div className="text-2xl font-black text-slate-900 font-mono mt-1">₹{baseCalc.finalLanded?.toFixed(2)}</div>
            </div>
            <div className="p-4 bg-blue-50/60 border border-blue-200 rounded-xl">
              <div className="text-[10px] font-bold text-blue-600 uppercase">ACTUAL RUNNING SHOPFLOOR</div>
              <div className="text-2xl font-black text-blue-700 font-mono mt-1">₹{runCalc.finalLanded?.toFixed(2)}</div>
            </div>
            <div className={`p-4 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-rose-50 border-rose-200 text-rose-700'}`}>
              <div className="text-[10px] font-bold uppercase">PROFIT / LOSS (Δ)</div>
              <div className="text-2xl font-black font-mono mt-1 flex items-center gap-1">
                {profitLossDelta >= 0 ? `+ ₹${profitLossDelta.toFixed(2)}` : `- ₹${Math.abs(profitLossDelta).toFixed(2)}`}
              </div>
            </div>
          </div>

          <div className="border border-slate-200 rounded-xl overflow-hidden">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold">
                <tr>
                  <th className="py-2.5 px-3">#</th>
                  <th className="py-2.5 px-3">ATOMBERG COSTING LINE</th>
                  <th className="py-2.5 px-3 text-center">UOM / RATE</th>
                  <th className="py-2.5 px-3 text-right">APPROVED BASELINE</th>
                  <th className="py-2.5 px-3 text-right">ACTUAL RUNNING</th>
                  <th className="py-2.5 px-3 text-right">DELTA (Δ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                <tr>
                  <td className="py-2 px-3 text-slate-400">17</td>
                  <td className="py-2 px-3 font-semibold text-slate-800">Machine Tariff per Shift</td>
                  <td className="py-2 px-3 text-center font-mono">₹/Shift</td>
                  <td className="py-2 px-3 text-right font-mono">
                    <input type="number" value={costingTariff} onChange={e => setCostingTariff(e.target.value)} className="w-20 px-1 py-0.5 border border-amber-300 bg-amber-50 rounded text-right font-mono font-bold" />
                  </td>
                  <td className="py-2 px-3 text-right font-mono">
                    <input type="number" value={actualTariff} onChange={e => setActualTariff(e.target.value)} className="w-20 px-1 py-0.5 border border-blue-400 bg-blue-50 rounded text-right font-mono font-bold" />
                  </td>
                  <td className="py-2 px-3 text-right font-mono text-slate-400">-</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div className="flex justify-between items-center pt-2 border-t border-slate-200">
            <button onClick={onClose} className="px-4 py-2 border rounded-xl font-bold cursor-pointer hover:bg-slate-50">Cancel</button>
            <button onClick={handleSaveAtomberg} className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer flex items-center gap-1.5"><Save className="w-4 h-4" /> Save & Log Parameters</button>
          </div>
        </div>
      </div>
    );
  }

  // ---------- HAIER 38-LINE COMPLETE CALCULATIONS ----------
  const dynamicHaierApprovedRm = Number(rmInfo.approvedPrice || item.approvedRmRate || 136.20);
  const dynamicHaierActualRm = Number(rmInfo.activeWaPrice || 134.80);
  const dynamicHaierApprovedMb = Number(mbInfo.approvedMbPrice || item.masterbatchRate || 0.0);

  const baseCalc = calculateHaierCost({
    cavity: Number(item.cavity || 2),
    netWeight: Number(item.netWeight || 197),
    runnerWeight: Number(item.runnerWeight || 40),
    rmRate: dynamicHaierApprovedRm,
    masterbatchPct: Number(item.masterbatchPct || 0.0),
    masterbatchRate: dynamicHaierApprovedMb,
    machineTonnage: Number(item.machineTonnage || 450),
    shiftTariff: Number(costingTariff),
    cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 48),
    bopCost: Number(item.bopCost || 0.14)
  });

  const runCalc = calculateHaierCost({
    cavity: Number(cavity),
    netWeight: Number(netWt),
    runnerWeight: Number(runnerWt),
    rmRate: dynamicHaierActualRm,
    masterbatchPct: Number(mbPctVal),
    masterbatchRate: dynamicHaierApprovedMb,
    machineTonnage: Number(tonnage),
    shiftTariff: Number(actualTariff),
    cycleTime: Number(cycleTime),
    bopCost: Number(bopCost)
  });

  const profitLossDelta = Number((baseCalc.totalCost - runCalc.totalCost).toFixed(2));

  // Build the complete 38 lines array for Haier
  const haier38FullRows = [
    { sn: 1, desc: 'Name Of component', uom: '-', costing: item.componentName, actual: item.componentName, delta: '-' },
    { sn: 2, desc: 'Mould size L x W xH', uom: 'mm', costing: item.mouldSize || '1070*720*650', actual: item.mouldSize || '1070*720*650', delta: '-' },
    { sn: 3, desc: 'Item No.', uom: '-', costing: item.itemCode, actual: item.itemCode, delta: '-' },
    { sn: 4, desc: 'Model', uom: '-', costing: item.model || 'OLD DC- 195,220', actual: item.model || 'OLD DC- 195,220', delta: '-' },
    { sn: 5, desc: 'Raw Material Required (Fetched from RM Page)', uom: '-', costing: `${item.approvedRm || 'ABS 300 Pre Colour'} (₹${dynamicHaierApprovedRm.toFixed(2)}/kg)`, actual: `(₹${dynamicHaierActualRm.toFixed(2)}/kg)`, delta: `${(dynamicHaierApprovedRm - dynamicHaierActualRm).toFixed(2)}` },
    { sn: 6, desc: 'Master Batch Required (%)', uom: '%', costing: `${Number(item.masterbatchPct || 0).toFixed(2)}%`, isInput: true, inputType: 'mbPct', actual: mbPctVal, delta: `${(Number(item.masterbatchPct || 0) - Number(mbPctVal)).toFixed(2)}%` },
    { sn: 7, desc: 'No. of Cavity', uom: 'Nos', costing: item.cavity || 2, isInput: true, inputType: 'cavity', actual: cavity, delta: (Number(item.cavity || 2) - Number(cavity)) },
    { sn: 8, desc: 'Runner Weight', uom: 'Gms', costing: `${item.runnerWeight || 40}g`, isInput: true, inputType: 'runnerWt', actual: runnerWt, delta: `${(Number(item.runnerWeight || 40) - Number(runnerWt)).toFixed(1)}g` },
    { sn: 9, desc: 'Net Weight', uom: 'Gms', costing: `${item.netWeight || 197}g`, isInput: true, inputType: 'netWt', actual: netWt, delta: `${(Number(item.netWeight || 197) - Number(netWt)).toFixed(1)}g` },
    { sn: 10, desc: 'Shot Weight', uom: 'Gms', costing: `${baseCalc.shotWeight?.toFixed(2)}g`, actual: `${runCalc.shotWeight?.toFixed(2)}g`, delta: `${(baseCalc.shotWeight - runCalc.shotWeight).toFixed(2)}g` },
    { sn: 11, desc: 'Reconciliation Weight = Shot wt + 1.0 % Melt Loss on shot wt', uom: 'Gms', costing: `${(Number(item.netWeight || 197) * 1.01).toFixed(2)}g`, actual: `${(Number(netWt) * 1.01).toFixed(2)}g`, delta: `${((Number(item.netWeight || 197) - Number(netWt)) * 1.01).toFixed(2)}g` },
    { sn: 12, desc: 'Raw Material Cost', uom: 'Rs', costing: `₹${baseCalc.rawMaterialCost?.toFixed(2)}`, actual: `₹${runCalc.rawMaterialCost?.toFixed(2)}`, delta: `₹${(baseCalc.rawMaterialCost - runCalc.rawMaterialCost).toFixed(2)}` },
    { sn: 13, desc: 'Master batch cost', uom: 'Rs', costing: `₹${baseCalc.masterBatchCost?.toFixed(2)}`, actual: `₹${runCalc.masterBatchCost?.toFixed(2)}`, delta: `₹${(baseCalc.masterBatchCost - runCalc.masterBatchCost).toFixed(2)}` },
    { sn: 14, desc: 'Runner recovery % (Scrap Credit)', uom: '-', costing: `- ₹${baseCalc.scrapCredit?.toFixed(2)}`, actual: `- ₹${runCalc.scrapCredit?.toFixed(2)}`, delta: `₹${(baseCalc.scrapCredit - runCalc.scrapCredit).toFixed(2)}`, isHighlight: true },
    { sn: 15, desc: 'Total Raw Material Cost', uom: 'Rs', costing: `₹${baseCalc.totalRmCost?.toFixed(2)}`, actual: `₹${runCalc.totalRmCost?.toFixed(2)}`, delta: `₹${(baseCalc.totalRmCost - runCalc.totalRmCost).toFixed(2)}`, isSubtotal: true },
    { sn: 16, desc: 'Machine Used', uom: 'T', costing: `${item.machineTonnage || 450}T`, isInput: true, inputType: 'tonnage', actual: tonnage, delta: (Number(item.machineTonnage || 450) - Number(tonnage)) },
    { sn: 17, desc: 'Machine Tariff per Shift (Manual Entry)', uom: 'Rs', isTariffInput: true, costing: costingTariff, actual: actualTariff, delta: `₹${(Number(costingTariff) - Number(actualTariff)).toFixed(2)}`, isTariffRow: true },
    { sn: 18, desc: 'Cycle Time', uom: 'Sec', costing: `${item.cycleTimeApproved || item.cycleTime || 48}s`, isInput: true, inputType: 'cycleTime', actual: cycleTime, delta: `${(Number(item.cycleTimeApproved || 48) - Number(cycleTime)).toFixed(1)}s` },
    { sn: 19, desc: 'No of Shot / Shift (8Hour)', uom: 'Nos', costing: Math.round(baseCalc.shotsPerShift), actual: Math.round(runCalc.shotsPerShift), delta: Math.round(baseCalc.shotsPerShift - runCalc.shotsPerShift) },
    { sn: 20, desc: 'No of Shot / Shift with 95 % Efficiency', uom: 'Nos', costing: Math.round(baseCalc.shotsWithEff), actual: Math.round(runCalc.shotsWithEff), delta: Math.round(baseCalc.shotsWithEff - runCalc.shotsWithEff) },
    { sn: 21, desc: 'No. of component / shift', uom: 'Nos', costing: Math.round(baseCalc.partsPerShift), actual: Math.round(runCalc.partsPerShift), delta: Math.round(baseCalc.partsPerShift - runCalc.partsPerShift) },
    { sn: 22, desc: 'Production Cost / Pc', uom: 'Rs', costing: `₹${baseCalc.productionCostPerPc?.toFixed(2)}`, actual: `₹${runCalc.productionCostPerPc?.toFixed(2)}`, delta: `₹${(baseCalc.productionCostPerPc - runCalc.productionCostPerPc).toFixed(2)}` },
    { sn: 23, desc: 'SUB TOTAL', uom: 'Rs', costing: `₹${baseCalc.subTotal?.toFixed(2)}`, actual: `₹${runCalc.subTotal?.toFixed(2)}`, delta: `₹${(baseCalc.subTotal - runCalc.subTotal).toFixed(2)}`, isSubtotal: true },
    { sn: 24, desc: 'OH+Profit+ICC+Rejection+Foam/Polybag+Masking film+Plastic Bin/Polyenda Box/Trolley+Freight Cost', uom: 'Rs', costing: `₹${baseCalc.line24OH?.toFixed(2)}`, actual: `₹${runCalc.line24OH?.toFixed(2)}`, delta: `₹${(baseCalc.line24OH - runCalc.line24OH).toFixed(2)}`, isBlueHighlight: true },
    { sn: 25, desc: 'Foam / Polybag / Masking film', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 26, desc: 'Plastic Bin / Polyend Box / Trolley', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 27, desc: 'Freight Cost', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 28, desc: 'Secondary Operation 1', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 29, desc: 'Secondary Operation 2', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 30, desc: 'Screen printing - 1st stroke', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 31, desc: 'Screen printing - 2nd stroke', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 32, desc: 'Assembly Cost', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 33, desc: 'Insert / Hinge hole cap cost / Other cost', uom: 'Rs', costing: `₹${Number(item.bopCost || 0.14).toFixed(2)}`, isInput: true, inputType: 'bopCost', actual: bopCost, delta: `₹${(Number(item.bopCost || 0.14) - Number(bopCost)).toFixed(2)}` },
    { sn: 34, desc: 'Mould Maintenance Provision', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 35, desc: 'Quality Inspection Cost', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 36, desc: 'ICC Reduce by .5% (Payment term change From 60 to 45 days)', uom: '-', costing: `- ₹${Math.abs(baseCalc.iccReduce || 0.14).toFixed(2)}`, actual: `- ₹${Math.abs(runCalc.iccReduce || 0.14).toFixed(2)}`, delta: '₹0.00' },
    { sn: 37, desc: 'Scrap Recovery Adjustment', uom: 'Rs', costing: `- ₹${baseCalc.scrapCredit?.toFixed(2)}`, actual: `- ₹${runCalc.scrapCredit?.toFixed(2)}`, delta: '₹0.00' },
    { sn: 38, desc: 'TOTAL COST', uom: 'Rs', costing: `₹${baseCalc.totalCost?.toFixed(2)}`, actual: `₹${runCalc.totalCost?.toFixed(2)}`, delta: `₹${profitLossDelta >= 0 ? '+' : ''}${profitLossDelta.toFixed(2)}`, isTotal: true }
  ];

  const handleSaveHaier = () => {
    onSave({
      updatedItem: {
        ...item,
        shiftTariff: Number(costingTariff),
        masterbatchPct: Number(mbPctVal),
        bopCost: Number(bopCost),
        netWeight: Number(netWt),
        runnerWeight: Number(runnerWt),
        machineTonnage: Number(tonnage),
        cycleTimeApproved: Number(cycleTime),
        cavity: Number(cavity),
        parameters: {
          ...item.parameters,
          runningNetWeight: Number(netWt),
          runningRunnerWeight: Number(runnerWt),
          runningMbPct: Number(mbPctVal),
          runningBopCost: Number(bopCost),
          runningCycleTime: Number(cycleTime),
          runningCavity: Number(cavity),
          runningTonnage: Number(tonnage),
          runningShiftTariff: Number(actualTariff)
        }
      },
      changeType: "Haier Parameter Drift Update",
      reason
    });
  };

  return (
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] flex flex-col justify-between relative">
        
        {/* Header */}
        <div className="flex justify-between items-start border-b border-slate-200 pb-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 bg-blue-600 text-white rounded font-mono font-bold text-xs">{item.itemCode}</span>
              <h2 className="text-base font-bold text-slate-900">{item.componentName}</h2>
              <span className="text-[10px] px-2 py-0.5 bg-blue-50 text-blue-700 rounded font-semibold border border-blue-200">Haier 38-Line Exact Costing Sheet</span>
            </div>
            <div className="text-[11px] text-slate-500 mt-0.5">Vendor: <span className="font-bold text-slate-700">{item.vendor}</span> | RM Link: <span className="font-mono font-bold text-blue-600">(₹{Number(rmInfo.activeWaPrice || 0).toFixed(2)}/kg)</span></div>
          </div>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-700 cursor-pointer"><X className="w-5 h-5" /></button>
        </div>

        {/* Top 3 KPI Summary Cards */}
        <div className="grid grid-cols-3 gap-3">
          <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl">
            <div className="text-[10px] font-bold text-slate-400 uppercase">COSTING (BASELINE)</div>
            <div className="text-2xl font-black text-slate-900 font-mono mt-1">₹{baseCalc.totalCost?.toFixed(2)}</div>
          </div>
          <div className="p-4 bg-blue-50/60 border border-blue-200 rounded-xl">
            <div className="text-[10px] font-bold text-blue-600 uppercase">ACTUAL RUNNING</div>
            <div className="text-2xl font-black text-blue-700 font-mono mt-1">₹{runCalc.totalCost?.toFixed(2)}</div>
          </div>
          <div className={`p-4 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-rose-50 border-rose-200 text-rose-700'}`}>
            <div className="text-[10px] font-bold uppercase">PROFIT / LOSS (Δ)</div>
            <div className="text-2xl font-black font-mono mt-1 flex items-center gap-1">
              {profitLossDelta >= 0 ? `+ ₹${profitLossDelta.toFixed(2)}` : `- ₹${Math.abs(profitLossDelta).toFixed(2)}`}
            </div>
          </div>
        </div>

        {/* Full 38 Lines Sequential Table */}
        <div className="border border-slate-200 rounded-xl overflow-hidden max-h-[50vh] overflow-y-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold sticky top-0 z-10">
              <tr>
                <th className="py-2.5 px-3 w-12 text-center">S.N.</th>
                <th className="py-2.5 px-4">DESCRIPTION</th>
                <th className="py-2.5 px-3 text-center w-16">UOM</th>
                <th className="py-2.5 px-4 text-right w-44">COSTING</th>
                <th className="py-2.5 px-4 text-right w-44">ACTUAL</th>
                <th className="py-2.5 px-4 text-right w-28">DELTA (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {haier38FullRows.map((r) => {
                if (r.isTotal) {
                  return (
                    <tr key={r.sn} className="bg-slate-900 text-white font-black text-sm">
                      <td className="py-3 px-3 text-center text-amber-400 font-bold">{r.sn}</td>
                      <td className="py-3 px-4 text-amber-300 uppercase tracking-wider">{r.desc}</td>
                      <td className="py-3 px-3 text-center text-slate-300">{r.uom}</td>
                      <td className="py-3 px-4 text-right font-mono text-amber-300">{r.costing}</td>
                      <td className="py-3 px-4 text-right font-mono text-amber-300">{r.actual}</td>
                      <td className={`py-3 px-4 text-right font-mono ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>{r.delta}</td>
                    </tr>
                  );
                }

                if (r.isTariffRow) {
                  return (
                    <tr key={r.sn} className="bg-emerald-50/40">
                      <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                      <td className="py-2 px-4 font-bold text-slate-900">{r.desc}</td>
                      <td className="py-2 px-3 text-center font-mono font-semibold text-slate-600">{r.uom}</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={costingTariff} 
                          onChange={e => setCostingTariff(e.target.value)} 
                          className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                        />
                      </td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={actualTariff} 
                          onChange={e => setActualTariff(e.target.value)} 
                          className="w-24 px-1.5 py-0.5 border border-blue-500 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 focus:ring-2 focus:ring-blue-500" 
                        />
                      </td>
                      <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">{r.delta}</td>
                    </tr>
                  );
                }

                return (
                  <tr 
                    key={r.sn} 
                    className={`${r.isSubtotal ? 'bg-amber-50/50 font-bold' : r.isBlueHighlight ? 'bg-blue-50/30' : 'hover:bg-slate-50'}`}
                  >
                    <td className="py-2 px-3 text-center font-mono text-slate-400">{r.sn}</td>
                    <td className={`py-2 px-4 ${r.isSubtotal ? 'text-slate-900' : r.isBlueHighlight ? 'font-bold text-blue-950' : 'text-slate-800 font-medium'}`}>{r.desc}</td>
                    <td className="py-2 px-3 text-center font-mono text-slate-500">{r.uom}</td>
                    <td className="py-2 px-4 text-right font-mono">{r.costing}</td>
                    <td className="py-2 px-4 text-right">
                      {r.isInput ? (
                        <input 
                          type="number" 
                          value={r.actual} 
                          onChange={e => {
                            const val = e.target.value;
                            if (r.inputType === 'mbPct') setMbPctVal(val);
                            else if (r.inputType === 'cavity') setCavity(val);
                            else if (r.inputType === 'runnerWt') setRunnerWt(val);
                            else if (r.inputType === 'netWt') setNetWt(val);
                            else if (r.inputType === 'tonnage') setTonnage(val);
                            else if (r.inputType === 'cycleTime') setCycleTime(val);
                            else if (r.inputType === 'bopCost') setBopCost(val);
                          }} 
                          className="w-20 px-1 py-0.5 border border-blue-400 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 outline-none focus:ring-2 focus:ring-blue-500" 
                        />
                      ) : (
                        <span className={`font-mono ${r.isSubtotal ? 'text-blue-700 font-bold' : r.isBlueHighlight ? 'text-blue-900 font-bold' : r.isHighlight ? 'text-emerald-700 font-bold' : 'text-slate-700'}`}>
                          {r.actual}
                        </span>
                      )}
                    </td>
                    <td className={`py-2 px-4 text-right font-mono ${r.isSubtotal ? 'text-rose-600 font-bold' : 'text-slate-500'}`}>{r.delta}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Footer */}
        <div className="flex justify-between items-center pt-2 border-t border-slate-200">
          <button onClick={onClose} className="px-4 py-2 border rounded-xl font-bold cursor-pointer hover:bg-slate-50 text-slate-700">Cancel</button>
          <button onClick={handleSaveHaier} className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer flex items-center gap-1.5"><Save className="w-4 h-4" /> Save & Log Parameters</button>
        </div>
      </div>
    </div>
  );
}
MODAL_EOF

echo "==> Restarting Vite dev server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> All 38 lines restored and visible in the modal!"
