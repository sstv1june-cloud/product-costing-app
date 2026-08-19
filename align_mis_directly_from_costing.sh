#!/usr/bin/env bash
set -e

echo "==> 1. Writing MIS Intelligence page using the exact Costing Engine loop & logic..."
cat << 'MIS_EOF' > src/modules/module4-mis/MISIntelligencePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Calendar, 
  FileSpreadsheet 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping, getVendorBaselineData } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISIntelligencePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [fromDate, setFromDate] = useState('2026-08-01');
  const [toDate, setToDate] = useState('2026-08-31');

  const allBaselines = getVendorBaselineData('ALL');

  const salesData = (globalStore.salesData || []).filter(s => {
    const vMatch = selectedVendor === 'All Vendors Combined' || selectedVendor === 'ALL' || s.vendor === selectedVendor;
    const dMatch = (!fromDate || s.invoiceDate >= fromDate) && (!toDate || s.invoiceDate <= toDate);
    return vMatch && dMatch;
  });

  // Calculate using the exact same spec mapper as Module 3 (Costing Engine)
  const analyzedRows = useMemo(() => {
    return salesData.map(sale => {
      const item = allBaselines.find(p => p.itemCode === sale.itemCode && p.vendor === sale.vendor) || 
                   allBaselines.find(p => p.itemCode === sale.itemCode) || {};

      const params = item.parameters || {};
      const rmMapping = getActiveRmMapping(item.approvedRm, item.vendor || sale.vendor, sale.invoiceDate);
      const mbMapping = getActiveMbMapping(item.vendor || sale.vendor, sale.invoiceDate);

      // 1. Exact Baseline Spec as evaluated in Costing Engine
      const baseSpec = {
        vendor: item.vendor || sale.vendor,
        rmBase: Number(rmMapping.approvedPrice || item.approvedRmRate || 130.00),
        rmRate: Number(rmMapping.approvedPrice || item.approvedRmRate || 130.00),
        mbBase: Number(mbMapping.approvedMbPrice || item.masterbatchRate || 240.00),
        masterbatchRate: Number(mbMapping.approvedMbPrice || item.masterbatchRate || 240.00),
        mbPct: Number((item.masterbatchPct ?? params.masterbatchPct ?? 0.0) / 100),
        masterbatchPct: Number(item.masterbatchPct ?? params.masterbatchPct ?? 0.0),
        partWt: Number(item.netWeight ?? params.netWeightApproved ?? 197),
        netWeight: Number(item.netWeight ?? params.netWeightApproved ?? 197),
        runnerWt: Number(item.runnerWeight ?? params.runnerWeight ?? 40),
        runnerWeight: Number(item.runnerWeight ?? params.runnerWeight ?? 40),
        bopCost: Number(item.bopCost || params.bopCost || 0.0),
        tonnage: Number(item.machineTonnage ?? params.machineTonnage ?? 450),
        machineTonnage: Number(item.machineTonnage ?? params.machineTonnage ?? 450),
        shiftTariff: Number(item.hourlyRate ? item.hourlyRate * 8 : (params.shiftTariff ?? 4600)),
        cycleTime: Number(item.cycleTimeApproved ?? item.cycleTime ?? 48),
        cavity: Number(item.cavity ?? params.cavity ?? 2)
      };
      const baselineCalc = calculateDetailedCost(baseSpec, true);

      // 2. Exact Simulated Actual Spec as evaluated in Costing Engine
      const runningSpec = {
        vendor: item.vendor || sale.vendor,
        rmBase: Number(rmMapping.activeWaPrice || baseSpec.rmBase),
        rmRate: Number(rmMapping.activeWaPrice || baseSpec.rmRate),
        mbBase: Number(mbMapping.activeMbPrice || baseSpec.mbBase),
        masterbatchRate: Number(mbMapping.activeMbPrice || baseSpec.masterbatchRate),
        mbPct: Number((params.runningMbPct !== undefined ? params.runningMbPct : baseSpec.masterbatchPct) / 100),
        masterbatchPct: Number(params.runningMbPct ?? baseSpec.masterbatchPct),
        partWt: Number(params.runningNetWeight ?? baseSpec.partWt),
        netWeight: Number(params.runningNetWeight ?? baseSpec.netWeight),
        runnerWt: Number(params.runningRunnerWeight ?? baseSpec.runnerWt),
        runnerWeight: Number(params.runningRunnerWeight ?? baseSpec.runnerWeight),
        bopCost: Number(params.runningBopCost ?? baseSpec.bopCost),
        tonnage: Number(params.runningTonnage ?? baseSpec.tonnage),
        machineTonnage: Number(params.runningTonnage ?? baseSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? baseSpec.shiftTariff),
        cycleTime: Number(params.runningCycleTime ?? baseSpec.cycleTime),
        cavity: Number(params.runningCavity ?? baseSpec.cavity)
      };
      const runningCalc = calculateDetailedCost(runningSpec, false);

      const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
      const actualUnitCost = Number(runningCalc.totalCost.toFixed(2));
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
              <option value="Haier">Haier Appliances</option>
              <option value="Atomberg">Atomberg Technologies</option>
              <option value="All Vendors Combined">All Vendors Combined</option>
              {vendors.filter(v => v.vendorId !== 'Haier' && v.vendorId !== 'Atomberg').map(v => (
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
MIS_EOF

echo "==> 2. Clearing Vite cache and restarting dev server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! MIS Intelligence is now an exact mathematical extension of Costing Engine."
