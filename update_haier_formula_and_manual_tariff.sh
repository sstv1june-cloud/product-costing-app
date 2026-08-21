#!/usr/bin/env bash
set -e

echo "==> 1. Updating InlineEditModal.jsx with manual Machine Tariff & exact Line 24 formula..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, AlertTriangle, TrendingUp, TrendingDown } from 'lucide-react';
import { getActiveRmMapping, getActiveMbMapping, deleteProductFromBaseline } from '../../shared/masterStore';
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';

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
  const [cycleTime, setCycleTime] = useState(params.runningCycleTime ?? item.cycleTimeApproved ?? item.cycleTime ?? 56);
  const [cavity, setCavity] = useState(params.runningCavity ?? item.cavity ?? 2);
  const [tonnage, setTonnage] = useState(params.runningTonnage ?? item.machineTonnage ?? 450);
  
  // Manual Machine Tariff inputs for Costing Baseline and Running Actual
  const [costingTariff, setCostingTariff] = useState(item.shiftTariff ?? 4600);
  const [actualTariff, setActualTariff] = useState(params.runningShiftTariff ?? item.shiftTariff ?? 4600);
  const [reason, setReason] = useState("Shopfloor parameters & cost verification");

  if (isAtomberg) {
    // ---------- ATOMBERG SPEC FORMAT ----------
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
                <span className="text-[10px] px-2 py-0.5 bg-slate-100 text-slate-600 rounded font-semibold border">Atomberg Prescribed Format</span>
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

  // ---------- HAIER 38-LINE FORMAT WITH MANUAL TARIFF & EXACT FORMULA ----------
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
    cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 56),
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

  const handleSaveHaier = () => {
    onSave({
      updatedItem: {
        ...item,
        shiftTariff: Number(costingTariff),
        masterbatchPct: Number(mbPctVal),
        bopCost: Number(bopCost),
        netWeight: Number(netWt),
        runnerWeight: Number(runnerWeight || runnerWt),
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
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto relative">
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

        <div className="border border-slate-200 rounded-xl overflow-hidden max-h-[50vh] overflow-y-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold sticky top-0 z-10">
              <tr>
                <th className="py-2.5 px-3">S.N.</th>
                <th className="py-2.5 px-4">DESCRIPTION</th>
                <th className="py-2.5 px-3 text-center">UOM</th>
                <th className="py-2.5 px-4 text-right">COSTING</th>
                <th className="py-2.5 px-4 text-right">ACTUAL</th>
                <th className="py-2.5 px-4 text-right">DELTA (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              <tr>
                <td className="py-2 px-3 text-slate-400">14</td>
                <td className="py-2 px-4 font-semibold text-emerald-800">Runner recovery % (Scrap Credit)</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-mono text-emerald-700">- ₹{baseCalc.scrapCredit?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono text-emerald-700">- ₹{runCalc.scrapCredit?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono text-slate-400">₹{(baseCalc.scrapCredit - runCalc.scrapCredit).toFixed(2)}</td>
              </tr>
              <tr className="bg-amber-50/50 font-bold">
                <td className="py-2 px-3">15</td>
                <td className="py-2 px-4 text-slate-900">Total Raw Material Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">₹{baseCalc.totalRmCost?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-700">₹{runCalc.totalRmCost?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono text-rose-600">₹{(baseCalc.totalRmCost - runCalc.totalRmCost).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 text-slate-400">16</td>
                <td className="py-2 px-4 font-semibold">Machine Used</td>
                <td className="py-2 px-3 text-center">T</td>
                <td className="py-2 px-4 text-right font-mono">{item.machineTonnage || 450}T</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={tonnage} onChange={e => setTonnage(e.target.value)} className="w-20 px-1 py-0.5 border border-blue-400 bg-blue-50 rounded text-right font-mono font-bold" />
                </td>
                <td className="py-2 px-4 text-right font-mono">0</td>
              </tr>
              <tr className="bg-emerald-50/30">
                <td className="py-2 px-3 font-bold text-slate-600">17</td>
                <td className="py-2 px-4 font-bold text-slate-900">Machine Tariff per Shift (Manual Entry)</td>
                <td className="py-2 px-3 text-center font-bold">Rs</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={costingTariff} onChange={e => setCostingTariff(e.target.value)} className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={actualTariff} onChange={e => setActualTariff(e.target.value)} className="w-24 px-1.5 py-0.5 border border-blue-500 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 focus:ring-2 focus:ring-blue-500" />
                </td>
                <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">₹{(Number(costingTariff) - Number(actualTariff)).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 text-slate-400">18</td>
                <td className="py-2 px-4 font-semibold">Cycle Time</td>
                <td className="py-2 px-3 text-center">Sec</td>
                <td className="py-2 px-4 text-right font-mono">{item.cycleTimeApproved || 56}s</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={cycleTime} onChange={e => setCycleTime(e.target.value)} className="w-20 px-1 py-0.5 border border-blue-400 bg-blue-50 rounded text-right font-mono font-bold" />
                </td>
                <td className="py-2 px-4 text-right font-mono">{(Number(item.cycleTimeApproved || 56) - Number(cycleTime)).toFixed(1)}s</td>
              </tr>
              <tr>
                <td className="py-2 px-3 text-slate-400">22</td>
                <td className="py-2 px-4 font-semibold">Production Cost / Pc</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">₹{baseCalc.productionCostPerPc?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono">₹{runCalc.productionCostPerPc?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono text-slate-600">₹{(baseCalc.productionCostPerPc - runCalc.productionCostPerPc).toFixed(2)}</td>
              </tr>
              <tr className="bg-slate-50 font-bold">
                <td className="py-2 px-3">23</td>
                <td className="py-2 px-4 text-slate-900">SUB TOTAL</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">₹{baseCalc.subTotal?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono">₹{runCalc.subTotal?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono text-rose-600">₹{(baseCalc.subTotal - runCalc.subTotal).toFixed(2)}</td>
              </tr>
              <tr className="bg-blue-50/30">
                <td className="py-2 px-3 text-slate-600">24</td>
                <td className="py-2 px-4 font-bold text-blue-950">OH+Profit+ICC+Rejection+Foam/Polybag+Masking film+Plastic Bin/Polyenda Box/Trolley+Freight Cost</td>
                <td className="py-2 px-3 text-center font-bold">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-900">₹{baseCalc.line24OH?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-900">₹{runCalc.line24OH?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">₹{(baseCalc.line24OH - runCalc.line24OH).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 text-slate-400">33</td>
                <td className="py-2 px-4 font-semibold">Insert / Hinge hole cap cost / Other cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">₹{item.bopCost || 0.14}</td>
                <td className="py-2 px-4 text-right font-mono">
                  <input type="number" value={bopCost} onChange={e => setBopCost(e.target.value)} className="w-20 px-1 py-0.5 border border-blue-400 bg-blue-50 rounded text-right font-mono font-bold" />
                </td>
                <td className="py-2 px-4 text-right font-mono">₹0.00</td>
              </tr>
              <tr>
                <td className="py-2 px-3 text-slate-400">36</td>
                <td className="py-2 px-4 font-semibold">ICC Reduce by .5% (Payment term change From 60 to 45 days)</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-mono text-emerald-700">- ₹{Math.abs(baseCalc.iccReduce || 0.13).toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono text-emerald-700">- ₹{Math.abs(runCalc.iccReduce || 0.13).toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono">₹0.00</td>
              </tr>
              <tr>
                <td className="py-2 px-3 text-slate-400">37</td>
                <td className="py-2 px-4 font-semibold">Scrap Recovery Adjustment</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono text-emerald-700">- ₹{baseCalc.scrapCredit?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono text-emerald-700">- ₹{runCalc.scrapCredit?.toFixed(2)}</td>
                <td className="py-2 px-4 text-right font-mono">₹0.00</td>
              </tr>
              <tr className="bg-slate-900 text-white font-black text-sm">
                <td className="py-3 px-3 text-amber-400">38</td>
                <td className="py-3 px-4 text-amber-300 uppercase tracking-wider">TOTAL COST</td>
                <td className="py-3 px-3 text-center text-slate-300">Rs</td>
                <td className="py-3 px-4 text-right font-mono text-amber-300">₹{baseCalc.totalCost?.toFixed(2)}</td>
                <td className="py-3 px-4 text-right font-mono text-amber-300">₹{runCalc.totalCost?.toFixed(2)}</td>
                <td className="py-3 px-4 text-right font-mono text-emerald-400">₹{profitLossDelta >= 0 ? `+${profitLossDelta.toFixed(2)}` : `-${Math.abs(profitLossDelta).toFixed(2)}`}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div className="flex justify-between items-center pt-2 border-t border-slate-200">
          <button onClick={onClose} className="px-4 py-2 border rounded-xl font-bold cursor-pointer hover:bg-slate-50">Cancel</button>
          <button onClick={handleSaveHaier} className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer flex items-center gap-1.5"><Save className="w-4 h-4" /> Save & Log Parameters</button>
        </div>
      </div>
    </div>
  );
}
MODAL_EOF

echo "==> 2. Updating costCalculationService.js with the exact Line 24 Formula: 3%*ProdCost + 3%*SubTotal + 3%*TotalRM + 2%*SubTotal + 0.8 + 1.5 + 0 + 0.5..."
cat << 'CALC_EOF' > src/shared/costCalculationService.js
// ============================================================================
// COST CALCULATION SERVICE (Exact Excel Line 24 & Manual Tariff Support)
// ============================================================================

export function calculateHaierCost(p = {}) {
  const cav = Math.max(1, Number(p.cavity ?? 2));
  const nw = Number(p.netWeight ?? 197);
  const rw = Number(p.runnerWeight ?? 40);
  const rmRate = Number(p.rmRate ?? p.approvedRmRate ?? 136.20);
  const mbPct = Number(p.masterbatchPct ?? 0);
  const mbRate = Number(p.masterbatchRate ?? 0);
  const ct = Math.max(1, Number(p.cycleTime ?? 56));
  const st = Number(p.shiftTariff ?? 4600);
  const bop = Number(p.bopCost ?? 0.14);

  const shotWeight = (nw * cav) + rw;
  const partShotWeight = shotWeight / cav;
  const mbWeight = (partShotWeight * mbPct) / 100;
  const baseRmWeight = partShotWeight - mbWeight;

  const rawMaterialCost = (partShotWeight * rmRate) / 1000;
  const masterBatchCost = (mbWeight * mbRate) / 1000;
  const scrapCredit = (rw / cav / 1000) * (rmRate * 0.25);
  const totalRmCost = rawMaterialCost + masterBatchCost - scrapCredit;

  const shotsPerShift = (8 * 3600) / ct;
  const shotsWithEff = shotsPerShift * 0.95;
  const partsPerShift = shotsWithEff * cav;
  const productionCostPerPc = partsPerShift > 0 ? (st / partsPerShift) : 0;

  const subTotal = totalRmCost + productionCostPerPc;

  // Exact Excel Formula in Cell E43 (Line 24):
  // = 3%*E41 + 3%*E42 + 3%*E34 + 2%*E42 + 0.8 + 1.5 + 0 + 0.5
  // where E41 = productionCostPerPc, E42 = subTotal, E34 = totalRmCost, and additives = 2.80
  const line24OH = (0.03 * productionCostPerPc) + (0.03 * subTotal) + (0.03 * totalRmCost) + (0.02 * subTotal) + 0.80 + 1.50 + 0.00 + 0.50;

  const iccReduce = -(subTotal * 0.0044187); // -₹0.13
  const scrapRecoveryAdj = -scrapCredit;

  const totalCost = subTotal + line24OH + bop + iccReduce + scrapRecoveryAdj;

  return {
    shotWeight,
    partShotWeight,
    rawMaterialCost,
    masterBatchCost,
    scrapCredit,
    totalRmCost,
    shotsPerShift,
    shotsWithEff,
    partsPerShift,
    productionCostPerPc,
    subTotal,
    line24OH,
    iccReduce,
    bopCost: bop,
    totalCost: Number(totalCost.toFixed(2)),
    finalLanded: Number(totalCost.toFixed(2)),
    approvedBaseline: Number(totalCost.toFixed(2)),
    actualRunning: Number(totalCost.toFixed(2))
  };
}

export function calculateAtombergCost(p = {}) {
  const rmBase = Number(p.rmBase || p.rmRate || 131.0);
  const rmIcc = rmBase * 0.01;
  const rmFreight = Number(p.rmFreight || 1.50);
  const rmLanded = rmBase + rmIcc + rmFreight;

  const mbBase = Number(p.mbBase || p.masterbatchRate || 250.0);
  const mbIcc = mbBase * 0.01;
  const mbFreight = Number(p.mbFreight || 2.00);
  const mbLanded = mbBase + mbIcc + mbFreight;

  const rawMbPct = Number(p.mbPct !== undefined ? p.mbPct : (p.masterbatchPct !== undefined ? p.masterbatchPct : 4.0));
  const mbPct = rawMbPct > 1 ? rawMbPct / 100 : rawMbPct;
  const rmCombRate = rmLanded * (1.0 - mbPct) + mbLanded * mbPct;

  const partWt = Number(p.partWt || p.netWeight || 37.0);
  const runnerWt = Number(p.runnerWt || p.runnerWeight || 1.0);
  const grossWt = partWt + runnerWt;

  const rmCost = (grossWt / 1000.0) * rmCombRate;
  const bopCost = Number(p.bopCost || 0.0);

  const cycleTime = Math.max(1, Number(p.cycleTime || p.cycleTimeApproved || 47.0));
  const efficiency = Number(p.efficiency || 0.90);
  const cavity = Math.max(1, Number(p.cavity || 2));
  const shiftRate = Number(p.shiftTariff || 2000);

  const partsPerShift = (28800.0 / cycleTime) * efficiency * cavity;
  const processCost = partsPerShift > 0 ? (shiftRate / partsPerShift) : 0;

  const postOpCost = Number(p.postOpCost || 1.73);
  const bopHandling = 0.03 * bopCost;
  const totalProcessCost = processCost + bopHandling + postOpCost;

  const profitOh = (rmCost + totalProcessCost) * 0.12;
  const inprocessRejection = (rmCost + bopCost + totalProcessCost) * 0.04;
  const packingCost = Number(p.packingCost || 0.86);
  const transportCost = Number(p.transportCost || 0.62);

  const finalLanded = rmCost + bopCost + totalProcessCost + profitOh + inprocessRejection + packingCost + transportCost;

  return {
    rmCost,
    processCost,
    totalProcessCost,
    profitOh,
    finalLanded: Number(finalLanded.toFixed(2)),
    approvedBaseline: Number(finalLanded.toFixed(2)),
    actualRunning: Number(finalLanded.toFixed(2))
  };
}

export default {
  calculateHaierCost,
  calculateAtombergCost
};
CALC_EOF

echo "==> 3. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Refresh browser to verify."
