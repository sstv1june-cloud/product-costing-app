#!/usr/bin/env bash
set -e

echo "==> 1. Updating CostingRunEnginePage.jsx to use exact calculateHaierCost & calculateAtombergCost..."
cat << 'PAGE_EOF' > src/modules/module3-costing-engine/CostingRunEnginePage.jsx
import React, { useState, useEffect } from 'react';
import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';
import { pushCostOutputsFromCostingPage } from '../../shared/costOutputStore';
import * as XLSX from 'xlsx';
import { Calculator, Download, Search, TrendingUp, TrendingDown, CheckCircle2 } from 'lucide-react';

export default function CostingRunEnginePage() {
  const [, setTick] = useState(0);
  const [vendorFilter, setVendorFilter] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    return subscribeStore(() => setTick(t => t + 1));
  }, []);

  const products = globalStore.baselineProducts || [];

  // Compute live matrix for each product using exact vendor formulas
  const calculatedRows = products.map(prod => {
    const isAtomberg = (prod.vendor || '').toLowerCase().includes('atomberg');
    const rmMap = getActiveRmMapping(prod.approvedRm || '', prod.vendor || 'Haier');
    const mbMap = getActiveMbMapping(prod.vendor || 'Haier');

    // 1. Baseline contract calculation
    const baseCalc = isAtomberg
      ? calculateAtombergCost(prod, {})
      : calculateHaierCost(prod, {});

    // 2. Simulated actual running calculation with active WA prices & shopfloor params
    const runCalc = isAtomberg
      ? calculateAtombergCost(prod, {
          actualRmRate: rmMap.activeWaPrice,
          actualMbRate: mbMap.activeMbWaPrice
        })
      : calculateHaierCost(prod, {
          actualRmRate: rmMap.activeWaPrice,
          actualMbRate: mbMap.activeMbWaPrice
        });

    const approvedBaseline = Number(baseCalc.finalLanded ?? baseCalc.approvedBaseline ?? baseCalc.totalApproved ?? 0);
    const simulatedActual = Number(runCalc.finalLanded ?? runCalc.actualRunning ?? runCalc.totalActual ?? 0);
    const delta = Number((approvedBaseline - simulatedActual).toFixed(2));

    return {
      vendor: prod.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: prod.itemCode,
      componentName: prod.componentName,
      approvedRm: prod.approvedRm,
      approvedRmRate: prod.approvedRmRate || rmMap.approvedPrice,
      activeRmRate: rmMap.activeWaPrice,
      approvedCost: Number(approvedBaseline.toFixed(2)),
      actualCost: Number(simulatedActual.toFixed(2)),
      deltaCost: delta,
      period: '2026-08'
    };
  });

  // AUTO-PUSH exact summary rows to costOutputStore.js (One-way communication)
  useEffect(() => {
    if (calculatedRows.length > 0) {
      pushCostOutputsFromCostingPage(calculatedRows, '2026-08');
    }
  }, [products, globalStore]);

  const filteredRows = calculatedRows.filter(row => {
    const matchVendor = vendorFilter === 'ALL' || (row.vendor || '').toLowerCase().includes(vendorFilter.toLowerCase());
    const matchSearch = !searchTerm || 
      (row.itemCode || '').toLowerCase().includes(searchTerm.toLowerCase()) || 
      (row.componentName || '').toLowerCase().includes(searchTerm.toLowerCase());
    return matchVendor && matchSearch;
  });

  const exportExcel = () => {
    const wsData = filteredRows.map(r => ({
      'Item Code': r.itemCode,
      'Component Name': r.componentName,
      'Vendor': r.vendor,
      'Approved RM': r.approvedRm,
      'Approved RM Rate (₹/kg)': Number(r.approvedRmRate || 0).toFixed(2),
      'Active WA RM Rate (₹/kg)': Number(r.activeRmRate || 0).toFixed(2),
      'Approved Baseline (₹)': r.approvedCost.toFixed(2),
      'Simulated Actual (₹)': r.actualCost.toFixed(2),
      'Profit / Loss Delta (₹)': r.deltaCost.toFixed(2)
    }));
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.json_to_sheet(wsData);
    XLSX.utils.book_append_sheet(wb, ws, 'Cost Simulation Output');
    XLSX.writeFile(wb, `Live_Cost_Simulation_Output_${new Date().toISOString().slice(0, 10)}.xlsx`);
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Top Banner */}
      <div className="bg-[#0f172a] text-white p-6 rounded-2xl shadow-xl flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-blue-600/30 rounded-xl border border-blue-500/30 text-blue-400">
            <Calculator className="w-8 h-8" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl md:text-2xl font-bold tracking-tight">3. Dynamic Costing Run Engine</h1>
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-950/80 text-emerald-300 border border-emerald-500/30">
                <CheckCircle2 className="w-3 h-3" /> Linked to costOutputStore.js
              </span>
            </div>
            <p className="text-sm text-slate-400">Live simulation matching contract baselines against active material inward rates.</p>
          </div>
        </div>

        <button
          onClick={exportExcel}
          className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold px-4 py-2.5 rounded-xl transition-all shadow-md shadow-emerald-600/20 cursor-pointer"
        >
          <Download className="w-4 h-4" /> Export Simulation (.xlsx)
        </button>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm flex flex-wrap justify-between items-center gap-4">
        <div className="relative flex-1 min-w-[260px]">
          <Search className="w-4 h-4 absolute left-3 top-3 text-slate-400" />
          <input
            type="text"
            placeholder="Search components by name or part number..."
            value={searchTerm}
            onChange={e => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs font-bold text-slate-500">Filter Vendor:</span>
          <select
            value={vendorFilter}
            onChange={e => setVendorFilter(e.target.value)}
            className="bg-slate-100 border border-slate-300 text-slate-800 text-xs font-bold rounded-xl px-3 py-2 outline-none cursor-pointer"
          >
            <option value="ALL">All Vendors Combined</option>
            <option value="Haier">Haier Appliances</option>
            <option value="Atomberg">Atomberg Technologies</option>
          </select>
        </div>
      </div>

      {/* Live Simulation Matrix */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="p-4 bg-[#0b1329] text-white flex justify-between items-center">
          <div className="font-bold text-xs uppercase tracking-wider flex items-center gap-2">
            <TrendingUp className="w-4 h-4 text-blue-400" /> Live Product Cost Simulation Matrix
          </div>
          <span className="text-xs text-slate-400 font-mono">{filteredRows.length} Products</span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold border-b border-slate-200">
                <th className="py-3 px-4">Item Code / Component</th>
                <th className="py-3 px-3 text-center">Vendor</th>
                <th className="py-3 px-3">Approved RM</th>
                <th className="py-3 px-3 text-right">Approved RM Rate</th>
                <th className="py-3 px-3 text-center text-slate-400">Active Material Link</th>
                <th className="py-3 px-3 text-right bg-blue-50 text-blue-900 font-bold">Active WA Rate</th>
                <th className="py-3 px-3 text-right bg-amber-50 text-amber-900 font-bold">Approved Baseline</th>
                <th className="py-3 px-3 text-right bg-slate-200/60 font-bold">Simulated Actual</th>
                <th className="py-3 px-4 text-right font-bold">Profit / Loss (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredRows.map((r, idx) => {
                const isGain = r.deltaCost >= 0;
                return (
                  <tr key={idx} className="hover:bg-slate-50 transition-colors">
                    <td className="py-3 px-4">
                      <div className="font-bold text-blue-600 font-mono">{r.itemCode}</div>
                      <div className="text-[11px] text-slate-600">{r.componentName}</div>
                    </td>
                    <td className="py-3 px-3 text-center">
                      <span className="px-2 py-0.5 bg-slate-100 text-slate-700 rounded text-[10px] font-bold">{r.vendor}</span>
                    </td>
                    <td className="py-3 px-3 font-medium text-slate-700">{r.approvedRm}</td>
                    <td className="py-3 px-3 text-right font-mono font-bold text-slate-800">₹{Number(r.approvedRmRate || 0).toFixed(2)}/kg</td>
                    <td className="py-3 px-3 text-center text-slate-400 font-mono text-[10px]">Linked to RM Matrix</td>
                    <td className="py-3 px-3 text-right font-mono font-bold bg-blue-50/50 text-blue-800">₹{Number(r.activeRmRate || 0).toFixed(2)}/kg</td>
                    <td className="py-3 px-3 text-right font-mono font-bold bg-amber-50/50 text-amber-900">₹{r.approvedCost.toFixed(2)}</td>
                    <td className="py-3 px-3 text-right font-mono font-bold bg-slate-50 text-slate-900">₹{r.actualCost.toFixed(2)}</td>
                    <td className="py-3 px-4 text-right font-mono font-bold">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-lg border text-xs ${
                        isGain ? 'bg-emerald-50 text-emerald-700 border-emerald-300' : 'bg-rose-50 text-rose-700 border-rose-300'
                      }`}>
                        {isGain ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
                        {isGain ? `+ ₹${r.deltaCost.toFixed(2)}` : `- ₹${Math.abs(r.deltaCost).toFixed(2)}`}
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
PAGE_EOF

echo "==> 2. Restarting Vite development server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done!"
