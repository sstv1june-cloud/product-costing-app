#!/usr/bin/env bash
set -e

echo "==> 1. Updating InlineEditModal.jsx to display fetched RM prices on Line 5..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, Lock, TrendingUp, TrendingDown, Trash2, AlertTriangle } from 'lucide-react';
import { getActiveRmMapping, getActiveMbMapping, deleteProductFromBaseline } from '../../shared/masterStore';
import { 
  calculateAtombergCost, 
  calculateHaierCost, 
  calculateDetailedCost, 
  calculatePieceCostUnified 
} from '../../shared/costCalculationService';

export { calculateAtombergCost, calculateHaierCost, calculateDetailedCost, calculatePieceCostUnified };

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
  const [reason, setReason] = useState("Shopfloor parameters & cost verification");

  if (isAtomberg) {
    // ---------- ATOMBERG 38-LINE FORMAT ----------
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
            runningNetWeight: Number(netWt),
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
        <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto relative">
          {showDeleteConfirm && (
            <div className="absolute inset-0 bg-slate-900/90 backdrop-blur-sm z-60 rounded-2xl flex items-center justify-center p-6">
              <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl border-2 border-rose-500 text-center space-y-4">
                <div className="w-12 h-12 bg-rose-100 text-rose-600 rounded-full flex items-center justify-center mx-auto"><AlertTriangle className="w-6 h-6" /></div>
                <h3 className="text-base font-bold text-slate-900">Delete Product Baseline?</h3>
                <p className="text-xs text-slate-600">Remove <span className="font-bold text-slate-900 font-mono">[{item.itemCode}] {item.componentName}</span>?</p>
                <div className="flex justify-center gap-3 pt-2">
                  <button onClick={() => setShowDeleteConfirm(false)} className="px-4 py-2 border rounded-xl hover:bg-slate-50 font-bold cursor-pointer">Cancel</button>
                  <button onClick={handleDelete} className="px-4 py-2 bg-rose-600 hover:bg-rose-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm"><Trash2 className="w-4 h-4" /> Yes, Delete</button>
                </div>
              </div>
            </div>
          )}

          <div className="flex justify-between items-center border-b pb-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="bg-purple-600 text-white font-mono px-2 py-0.5 rounded font-bold">{item.itemCode}</span>
                <h2 className="text-sm font-bold text-slate-900">{item.componentName}</h2>
                <span className="bg-purple-100 text-purple-900 font-bold px-2 py-0.5 rounded text-[10px]">Atomberg Prescribed Format</span>
              </div>
              <p className="text-[11px] text-slate-500 font-mono mt-0.5">Vendor: <span className="font-bold text-slate-700">Atomberg</span> | RM Link: <span className="text-emerald-700 font-bold">{rmInfo.activeRmName} (₹{actualRmBase.toFixed(2)}/kg)</span></p>
            </div>
            <button onClick={onClose} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div className="bg-slate-100 p-3 rounded-xl border">
              <span className="text-[10px] font-bold text-slate-500 uppercase block">APPROVED BASELINE CONTRACT</span>
              <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">₹{baseCalc.finalLanded.toFixed(2)}</span>
            </div>
            <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
              <span className="text-[10px] font-bold text-blue-700 uppercase block">ACTUAL RUNNING SHOPFLOOR</span>
              <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{runCalc.finalLanded.toFixed(2)}</span>
            </div>
            <div className={`p-3 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
              <span className="text-[10px] font-bold text-slate-600 uppercase block">PROFIT / LOSS (Δ)</span>
              <span className={`text-2xl font-black font-mono mt-1 block ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>{profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}</span>
            </div>
          </div>

          <div className="border border-slate-200 rounded-xl overflow-hidden max-h-[50vh] overflow-y-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0 z-10">
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
                <tr><td className="p-2 text-center text-slate-400">2</td><td className="p-2 font-bold">Part Code</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono font-bold">{item.itemCode}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{item.itemCode}</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">3</td><td className="p-2 font-bold">Part name</td><td className="p-2 text-center">-</td><td className="p-2 text-right">{item.componentName}</td><td className="p-2 text-right bg-blue-50/30">{item.componentName}</td><td className="p-2 text-right">-</td></tr>
                <tr className="bg-amber-50/40"><td className="p-2 text-center text-slate-400">4</td><td className="p-2 font-bold text-blue-900 flex items-center gap-1"><Lock className="w-3 h-3 text-amber-600" /> RM grade (Locked & Linked)</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-bold">{rmInfo.approvedRm} (₹{approvedRmBase.toFixed(2)})</td><td className="p-2 text-right bg-blue-50/30 font-bold text-blue-950">{rmInfo.activeRmName} (₹{actualRmBase.toFixed(2)})</td><td className="p-2 text-right font-mono">{(actualRmBase - approvedRmBase).toFixed(2)}</td></tr>
                <tr className="bg-amber-50/60 font-bold"><td className="p-2 text-center text-slate-400">5</td><td className="p-2 font-black text-amber-950">RM Base Rate (From RM Matrix)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-amber-900 bg-amber-100/50">₹{baseCalc.rmBase.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-blue-900 bg-blue-100/50">₹{runCalc.rmBase.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.rmBase - baseCalc.rmBase).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">6</td><td className="p-2">ICC Cost @ 1% of RM</td><td className="p-2 text-center">1%</td><td className="p-2 text-right font-mono">₹{baseCalc.rmIcc.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rmIcc.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.rmIcc - baseCalc.rmIcc).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">7</td><td className="p-2">Freight Cost</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono">₹{baseCalc.rmFreight.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rmFreight.toFixed(2)}</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-emerald-50/70 font-bold border-y-2 border-emerald-200"><td className="p-2 text-center text-emerald-800">8</td><td className="p-2 font-black text-emerald-950">RM Landed Cost</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-emerald-900 bg-emerald-100/60">₹{baseCalc.rmLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-emerald-900 bg-blue-100/60">₹{runCalc.rmLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-emerald-800">{(runCalc.rmLanded - baseCalc.rmLanded).toFixed(2)}</td></tr>
                <tr className="bg-purple-50/60 font-bold"><td className="p-2 text-center text-slate-400">9</td><td className="p-2 font-black text-purple-950">MB Base Cost</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-purple-900 bg-purple-100/50">₹{baseCalc.mbBase.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-blue-900 bg-blue-100/50">₹{runCalc.mbBase.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.mbBase - baseCalc.mbBase).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">10</td><td className="p-2">MB-ICC Cost @ 1% of MB</td><td className="p-2 text-center">1%</td><td className="p-2 text-right font-mono">₹{baseCalc.mbIcc.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mbIcc.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.mbIcc - baseCalc.mbIcc).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">11</td><td className="p-2">MB Freight Cost</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono">₹{baseCalc.mbFreight.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mbFreight.toFixed(2)}</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-purple-100/50 font-bold border-y-2 border-purple-200"><td className="p-2 text-center text-purple-900">12</td><td className="p-2 font-black text-purple-950">MB Landed Cost</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-purple-950 bg-purple-200/50">₹{baseCalc.mbLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-purple-950 bg-blue-100/60">₹{runCalc.mbLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-purple-900">{(runCalc.mbLanded - baseCalc.mbLanded).toFixed(2)}</td></tr>
                <tr className="bg-purple-50/30"><td className="p-2 text-center text-slate-400">13</td><td className="p-2 font-bold text-purple-950">MB %</td><td className="p-2 text-center">%</td><td className="p-2 text-right font-mono font-bold bg-slate-50">4.00%</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.1" value={mbPctVal} onChange={e => setMbPctVal(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-purple-700">{(Number(mbPctVal) - 4).toFixed(2)}%</td></tr>
                <tr className="bg-amber-100/50 font-bold"><td className="p-2 text-center">14</td><td className="p-2 font-black">RM cost (PP + MB) /KG</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono font-black">₹{baseCalc.rmCombRate.toFixed(4)}</td><td className="p-2 text-right bg-blue-100/60 font-mono font-black">₹{runCalc.rmCombRate.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmCombRate - baseCalc.rmCombRate).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">15</td><td className="p-2 font-bold">Part weight grams</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono font-bold">37.0g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={netWt} onChange={e => setNetWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(netWt) - 37).toFixed(1)}g</td></tr>
                <tr><td className="p-2 text-center text-slate-400">16</td><td className="p-2 font-bold">Runner weight grams</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono font-bold">1.0g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runnerWt} onChange={e => setRunnerWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(runnerWt) - 1).toFixed(1)}g</td></tr>
                <tr className="bg-slate-50/50"><td className="p-2 text-center text-slate-400">17</td><td className="p-2 font-bold">Gross weight</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono">{baseCalc.grossWt}g</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{runCalc.grossWt}g</td><td className="p-2 text-right font-mono">{runCalc.grossWt - baseCalc.grossWt}g</td></tr>
                <tr className="bg-amber-50 font-bold"><td className="p-2 text-center">18</td><td className="p-2 font-black">RM cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono font-bold">₹{baseCalc.rmCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50 font-mono font-bold">₹{runCalc.rmCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmCost - baseCalc.rmCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">19</td><td className="p-2 font-bold">Inserts/BOP cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.00</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.01" value={bopCost} onChange={e => setBopCost(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">₹{Number(bopCost).toFixed(2)}</td></tr>
                <tr className="bg-slate-50 font-bold"><td className="p-2 text-center">20</td><td className="p-2 font-black">RM + BOP Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.rmBopCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50 font-mono">₹{runCalc.rmBopCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmBopCost - baseCalc.rmBopCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">21</td><td className="p-2 font-bold">M/c tonnage</td><td className="p-2 text-center">T</td><td className="p-2 text-right font-mono">200T</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={tonnage} onChange={e => setTonnage(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(tonnage) - 200}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">22</td><td className="p-2">Shift rate</td><td className="p-2 text-center">₹/shift</td><td className="p-2 text-right font-mono">₹2,000</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.shiftRate}</td><td className="p-2 text-right font-mono">{runCalc.shiftRate - 2000}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">23</td><td className="p-2 font-bold">Cycle time</td><td className="p-2 text-center">Sec</td><td className="p-2 text-right font-mono font-bold">47s</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="1" value={cycleTime} onChange={e => setCycleTime(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-blue-700">{(Number(cycleTime) - 47).toFixed(1)}s</td></tr>
                <tr><td className="p-2 text-center text-slate-400">24</td><td className="p-2">Efficiency</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono">0.90</td><td className="p-2 text-right bg-blue-50/30 font-mono">0.90</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">25</td><td className="p-2 font-bold">No of cavity</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono font-bold">2</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={cavity} onChange={e => setCavity(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(cavity) - 2}</td></tr>
                <tr className="bg-slate-50"><td className="p-2 text-center text-slate-400">26</td><td className="p-2">Parts/shift</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono">{baseCalc.partsPerShift.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{runCalc.partsPerShift.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.partsPerShift - baseCalc.partsPerShift).toFixed(2)}</td></tr>
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
                  <td className={`p-2.5 text-right font-mono font-black text-sm ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>{profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}</td>
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
              <button type="button" onClick={() => setShowDeleteConfirm(true)} className="px-3.5 py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-300 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer"><Trash2 className="w-4 h-4" /> Delete Product</button>
              <div className="flex items-center gap-2">
                <button onClick={onClose} className="px-4 py-2 border rounded-xl hover:bg-slate-50 cursor-pointer">Cancel</button>
                <button onClick={handleSaveAtomberg} className="px-6 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"><Save className="w-4 h-4" /> Save & Log Parameters</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  } else {
    // ---------- HAIER EXACT 38-LINE FORMAT WITH FETCHED RM PRICES ----------
    const dynamicHaierApprovedRm = Number(rmInfo.approvedPrice || item.approvedRmRate || 130.00);
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
      shiftTariff: Number(item.machineTonnage >= 650 ? 5760 : 4600),
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
      shiftTariff: Number(tonnage >= 650 ? 5760 : 4600),
      cycleTime: Number(cycleTime),
      bopCost: Number(bopCost)
    });

    const profitLossDelta = Number((baseCalc.totalCost - runCalc.totalCost).toFixed(2));

    const handleSaveHaier = () => {
      onSave({
        updatedItem: {
          ...item,
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
            runningShiftTariff: Number(tonnage >= 650 ? 5760 : 4600)
          }
        },
        changeType: "Shopfloor Spec Adjustment",
        reason
      });
    };

    return (
      <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
        <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto relative">
          {showDeleteConfirm && (
            <div className="absolute inset-0 bg-slate-900/90 backdrop-blur-sm z-60 rounded-2xl flex items-center justify-center p-6">
              <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl border-2 border-rose-500 text-center space-y-4">
                <div className="w-12 h-12 bg-rose-100 text-rose-600 rounded-full flex items-center justify-center mx-auto"><AlertTriangle className="w-6 h-6" /></div>
                <h3 className="text-base font-bold text-slate-900">Delete Product Baseline?</h3>
                <p className="text-xs text-slate-600">Remove <span className="font-bold text-slate-900 font-mono">[{item.itemCode}] {item.componentName}</span>?</p>
                <div className="flex justify-center gap-3 pt-2">
                  <button onClick={() => setShowDeleteConfirm(false)} className="px-4 py-2 border rounded-xl hover:bg-slate-50 font-bold cursor-pointer">Cancel</button>
                  <button onClick={handleDelete} className="px-4 py-2 bg-rose-600 hover:bg-rose-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm"><Trash2 className="w-4 h-4" /> Yes, Delete</button>
                </div>
              </div>
            </div>
          )}

          <div className="flex justify-between items-center border-b pb-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="bg-blue-600 text-white font-mono px-2 py-0.5 rounded font-bold">{item.itemCode}</span>
                <h2 className="text-sm font-bold text-slate-900">{item.componentName}</h2>
                <span className="bg-blue-100 text-blue-900 font-bold px-2 py-0.5 rounded text-[10px]">Haier 38-Line Exact Costing Sheet</span>
              </div>
              <p className="text-[11px] text-slate-500 font-mono mt-0.5">
                Vendor: <span className="font-bold text-slate-700">Haier</span> | RM Link: <span className="text-blue-700 font-bold">{rmInfo.activeRmName} (₹{dynamicHaierActualRm.toFixed(2)}/kg)</span>
              </p>
            </div>
            <button onClick={onClose} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div className="bg-slate-100 p-3 rounded-xl border">
              <span className="text-[10px] font-bold text-slate-500 uppercase block">COSTING (BASELINE)</span>
              <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">₹{baseCalc.totalCost.toFixed(2)}</span>
            </div>
            <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
              <span className="text-[10px] font-bold text-blue-700 uppercase block">ACTUAL RUNNING</span>
              <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{runCalc.totalCost.toFixed(2)}</span>
            </div>
            <div className={`p-3 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
              <span className="text-[10px] font-bold text-slate-600 uppercase block">PROFIT / LOSS (Δ)</span>
              <span className={`text-2xl font-black font-mono mt-1 block ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>{profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}</span>
            </div>
          </div>

          <div className="border border-slate-200 rounded-xl overflow-hidden max-h-[50vh] overflow-y-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0 z-10">
                <tr>
                  <th className="p-2 w-10 text-center">S.N.</th>
                  <th className="p-2">Description</th>
                  <th className="p-2 w-16 text-center">UOM</th>
                  <th className="p-2 text-right w-44 bg-slate-200/50">Costing</th>
                  <th className="p-2 text-right w-48 bg-blue-100/50">Actual</th>
                  <th className="p-2 text-right w-24">Delta (Δ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                <tr><td className="p-2 text-center text-slate-400">1</td><td className="p-2 font-bold">Name Of component</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-semibold">{item.componentName}</td><td className="p-2 text-right bg-blue-50/30 font-semibold">{item.componentName}</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">2</td><td className="p-2 font-bold">Mould size L x W xH</td><td className="p-2 text-center">mm</td><td className="p-2 text-right font-mono">{item.mouldSize || '1070*720*650'}</td><td className="p-2 text-right bg-blue-50/30 font-mono">{item.mouldSize || '1070*720*650'}</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">3</td><td className="p-2 font-bold">Item No.</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono font-bold">{item.itemCode}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{item.itemCode}</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">4</td><td className="p-2 font-bold">Model</td><td className="p-2 text-center">-</td><td className="p-2 text-right">{item.model || 'OLD DC'}</td><td className="p-2 text-right bg-blue-50/30">{item.model || 'OLD DC'}</td><td className="p-2 text-right">-</td></tr>
                <tr className="bg-amber-50/30"><td className="p-2 text-center text-slate-400">5</td><td className="p-2 font-bold flex items-center gap-1"><Lock className="w-3 h-3 text-amber-600" /> Raw Material Required (Fetched from RM Page)</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-bold">{item.approvedRm} (₹{dynamicHaierApprovedRm.toFixed(2)}/kg)</td><td className="p-2 text-right bg-blue-50/40 font-bold text-blue-950">{rmInfo.activeRmName} (₹{dynamicHaierActualRm.toFixed(2)}/kg)</td><td className="p-2 text-right font-mono">{(dynamicHaierActualRm - dynamicHaierApprovedRm).toFixed(2)}</td></tr>
                <tr className="bg-purple-50/40"><td className="p-2 text-center text-slate-400">6</td><td className="p-2 font-bold text-purple-950">Master Batch Required (%)</td><td className="p-2 text-center">%</td><td className="p-2 text-right font-mono">{Number(item.masterbatchPct || 0).toFixed(2)}%</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.1" value={mbPctVal} onChange={e => setMbPctVal(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono text-purple-700">{(Number(mbPctVal) - Number(item.masterbatchPct || 0)).toFixed(2)}%</td></tr>
                <tr className="bg-yellow-50 font-bold"><td className="p-2 text-center text-slate-400">7</td><td className="p-2 text-slate-900">No. of Cavity</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono">{item.cavity || 2}</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={cavity} onChange={e => setCavity(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(cavity) - Number(item.cavity || 2)}</td></tr>
                <tr className="bg-yellow-50 font-bold"><td className="p-2 text-center text-slate-400">8</td><td className="p-2 text-slate-900">Runner Weight</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono">{item.runnerWeight || 40}g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runnerWt} onChange={e => setRunnerWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(runnerWt) - Number(item.runnerWeight || 40)).toFixed(1)}g</td></tr>
                <tr className="bg-yellow-50 font-bold"><td className="p-2 text-center text-slate-400">9</td><td className="p-2 text-slate-900">Net Weight</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono">{item.netWeight || 197}g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={netWt} onChange={e => setNetWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(netWt) - Number(item.netWeight || 197)).toFixed(1)}g</td></tr>
                <tr className="bg-yellow-50 font-bold"><td className="p-2 text-center text-slate-400">10</td><td className="p-2 text-slate-900">Shot Weight</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono">{baseCalc.shotWeightPerPiece?.toFixed(2)}g</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runCalc.shotWeightPerPiece?.toFixed(2)}g</td><td className="p-2 text-right font-mono">{(runCalc.shotWeightPerPiece - baseCalc.shotWeightPerPiece).toFixed(2)}g</td></tr>
                <tr><td className="p-2 text-center text-slate-400">11</td><td className="p-2 font-bold">Reconciliation Weight = Shot wt + 1.0% Melt Loss</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono">{baseCalc.reconciliationWeight?.toFixed(2)}g</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runCalc.reconciliationWeight?.toFixed(2)}g</td><td className="p-2 text-right font-mono">{(runCalc.reconciliationWeight - baseCalc.reconciliationWeight).toFixed(2)}g</td></tr>
                <tr><td className="p-2 text-center text-slate-400">12</td><td className="p-2 font-bold">Raw Material Cost</td><td className="p-2 text-center">Rs</td><td className="p-2 text-right font-mono">₹{baseCalc.rawMaterialCost?.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rawMaterialCost?.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runCalc.rawMaterialCost - baseCalc.rawMaterialCost).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">13</td><td className="p-2 font-bold">Master batch cost</td><td className="p-2 text-center">Rs</td><td className="p-2 text-right font-mono">₹{baseCalc.masterbatchCost?.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.masterbatchCost?.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runCalc.masterbatchCost - baseCalc.masterbatchCost).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">14</td><td className="p-2 font-bold text-emerald-800">Runner recovery % (Scrap Credit)</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono text-emerald-700">- ₹{baseCalc.runnerRecoveryCredit?.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono text-emerald-700">- ₹{runCalc.runnerRecoveryCredit?.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runCalc.runnerRecoveryCredit - baseCalc.runnerRecoveryCredit).toFixed(2)}</td></tr>
                <tr className="bg-amber-100/60 font-bold"><td className="p-2 text-center">15</td><td className="p-2 font-black text-slate-900">Total Raw Material Cost</td><td className="p-2 text-center">Rs</td><td className="p-2 text-right font-mono font-black">₹{baseCalc.totalRmCost?.toFixed(2)}</td><td className="p-2 bg-blue-100/70 font-mono font-black text-blue-950">₹{runCalc.totalRmCost?.toFixed(2)}</td><td className="p-2 text-right font-mono font-black">₹{(runCalc.totalRmCost - baseCalc.totalRmCost).toFixed(2)}</td></tr>
                <tr className="bg-yellow-50 font-bold"><td className="p-2 text-center text-slate-400">16</td><td className="p-2 text-slate-900">Machine Used</td><td className="p-2 text-center">T</td><td className="p-2 text-right font-mono">{item.machineTonnage || 450}T</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={tonnage} onChange={e => setTonnage(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(tonnage) - Number(item.machineTonnage || 450)}</td></tr>
                <tr className="bg-yellow-50 font-bold"><td className="p-2 text-center text-slate-400">17</td><td className="p-2 text-slate-900">Machine Tariff per Shift</td><td className="p-2 text-center">Rs</td><td className="p-2 text-right font-mono">₹{baseCalc.shiftTariff}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.shiftTariff}</td><td className="p-2 text-right font-mono">{runCalc.shiftTariff - baseCalc.shiftTariff}</td></tr>
                <tr className="bg-yellow-50 font-bold"><td className="p-2 text-center text-slate-400">18</td><td className="p-2 text-slate-900">Cycle Time</td><td className="p-2 text-center">Sec</td><td className="p-2 text-right font-mono">{item.cycleTimeApproved || 48}s</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="1" value={cycleTime} onChange={e => setCycleTime(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(cycleTime) - Number(item.cycleTimeApproved || 48)).toFixed(1)}s</td></tr>
                <tr><td className="p-2 text-center text-slate-400">19</td><td className="p-2 font-bold">No of Shot / Shift (8Hour)</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono">{baseCalc.shotsPerShift8Hr?.toFixed(0)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runCalc.shotsPerShift8Hr?.toFixed(0)}</td><td className="p-2 text-right font-mono">{(runCalc.shotsPerShift8Hr - baseCalc.shotsPerShift8Hr).toFixed(0)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">20</td><td className="p-2 font-bold">No of Shot / Shift with 95 % Efficiency</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono">{baseCalc.shotsPerShiftEff?.toFixed(0)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runCalc.shotsPerShiftEff?.toFixed(0)}</td><td className="p-2 text-right font-mono">{(runCalc.shotsPerShiftEff - baseCalc.shotsPerShiftEff).toFixed(0)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">21</td><td className="p-2 font-bold">No. of component / shift</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono">{baseCalc.partsPerShift?.toFixed(0)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runCalc.partsPerShift?.toFixed(0)}</td><td className="p-2 text-right font-mono">{(runCalc.partsPerShift - baseCalc.partsPerShift).toFixed(0)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">22</td><td className="p-2 font-bold">Production Cost / Pc</td><td className="p-2 text-center">Rs</td><td className="p-2 text-right font-mono">₹{baseCalc.productionCostPerPc?.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.productionCostPerPc?.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runCalc.productionCostPerPc - baseCalc.productionCostPerPc).toFixed(2)}</td></tr>
                <tr className="bg-slate-100 font-bold"><td className="p-2 text-center text-slate-400">23</td><td className="p-2 font-black">SUB TOTAL</td><td className="p-2 text-center">Rs</td><td className="p-2 text-right font-mono">₹{baseCalc.subTotal?.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.subTotal?.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runCalc.subTotal - baseCalc.subTotal).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">24</td><td className="p-2">OH + Profit + ICC + Rejection + Packaging + Freight</td><td className="p-2 text-center">Rs</td><td className="p-2 text-right font-mono">₹{baseCalc.ohProfitIccRej?.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.ohProfitIccRej?.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runCalc.ohProfitIccRej - baseCalc.ohProfitIccRej).toFixed(2)}</td></tr>
                <tr className="bg-yellow-50 font-bold"><td className="p-2 text-center text-slate-400">33</td><td className="p-2 text-slate-900">Insert / Hinge hole cap cost / Other cost</td><td className="p-2 text-center">Rs</td><td className="p-2 text-right font-mono">₹{Number(item.bopCost || 0.14).toFixed(2)}</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.01" value={bopCost} onChange={e => setBopCost(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">₹{(Number(bopCost) - Number(item.bopCost || 0.14)).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">36</td><td className="p-2">ICC Reduce by .5% (Payment term change 60 to 45 days)</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono">₹-0.13</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹-0.13</td><td className="p-2 text-right font-mono">₹0.00</td></tr>
                <tr className="bg-slate-900 text-white font-bold">
                  <td className="p-2.5 text-center">38</td>
                  <td className="p-2.5 font-black text-amber-300 uppercase tracking-wider">TOTAL COST</td>
                  <td className="p-2.5 text-center font-mono">Rs</td>
                  <td className="p-2.5 text-right font-mono font-black text-amber-300 text-sm">₹{baseCalc.totalCost.toFixed(2)}</td>
                  <td className="p-2.5 font-mono font-black text-emerald-300 text-sm bg-slate-800 text-right">₹{runCalc.totalCost.toFixed(2)}</td>
                  <td className={`p-2.5 text-right font-mono font-black text-sm ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>{profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}</td>
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
              <button type="button" onClick={() => setShowDeleteConfirm(true)} className="px-3.5 py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-300 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer"><Trash2 className="w-4 h-4" /> Delete Product</button>
              <div className="flex items-center gap-2">
                <button onClick={onClose} className="px-4 py-2 border rounded-xl hover:bg-slate-50 cursor-pointer">Cancel</button>
                <button onClick={handleSaveHaier} className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"><Save className="w-4 h-4" /> Save & Log Parameters</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
MODAL_EOF

echo "==> 2. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Fetched RM prices are now clearly displayed on Line 5."
