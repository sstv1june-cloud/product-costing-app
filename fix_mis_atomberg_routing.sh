#!/usr/bin/env bash
set -e

# Update MISIntelligencePage.jsx to explicitly route to Atomberg's calculation engine
cat << 'MIS_PAGE_EOF' > src/modules/module4-mis/MISIntelligencePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Search, Calendar, 
  Eye, FileSpreadsheet, Layers, ShieldCheck, CheckCircle2 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';
import { calculateDetailedCost, calculateAtombergCost, calculateHaierCost } from '../module1-baseline/InlineEditModal';

export default function MISIntelligencePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [fromDate, setFromDate] = useState('2026-08-01');
  const [toDate, setToDate] = useState('2026-08-31');

  const salesData = (globalStore.salesData || []).filter(s => {
    const vMatch = selectedVendor === 'ALL' || s.vendor === selectedVendor;
    const dMatch = (!fromDate || s.invoiceDate >= fromDate) && (!toDate || s.invoiceDate <= toDate);
    return vMatch && dMatch;
  });

  const baselineList = globalStore.baselineList || [];

  const analyzedRows = useMemo(() => {
    return salesData.map(sale => {
      const part = baselineList.find(p => p.itemCode === sale.itemCode) || {};
      const params = part.parameters || {};
      const isAtomberg = (sale.vendor || part.vendor || selectedVendor).toLowerCase().includes('atomberg');

      const rmMapping = getActiveRmMapping(part.approvedRm || 'PP H110MA', sale.vendor, sale.invoiceDate);
      const mbMapping = getActiveMbMapping(sale.vendor, sale.invoiceDate);

      let contractBaseline = 0;
      let actualUnitCost = 0;

      if (isAtomberg) {
        // Atomberg Approved Baseline
        const baseAtomberg = {
          rmBase: Number(rmMapping.approvedPrice || part.approvedRmRate || 150.00),
          mbBase: Number(mbMapping.approvedMbPrice || part.masterbatchRate || 250.00),
          rmFreight: 1.50,
          mbFreight: 2.00,
          mbPct: 0.04,
          partWt: Number(part.netWeight || 37.0),
          runnerWt: Number(part.runnerWeight || 1.0),
          bopCost: Number(part.bopCost || 0.0),
          tonnage: Number(part.machineTonnage || 200.0),
          cycleTime: Number(part.cycleTimeApproved || 47.0),
          efficiency: 0.90,
          cavity: Number(part.cavity || 2),
          postOpCost: 1.73,
          packingCost: 0.86,
          transportCost: 0.62
        };
        const baseCalc = calculateAtombergCost(baseAtomberg);
        contractBaseline = Number(baseCalc.finalLanded.toFixed(2));

        // Atomberg Actual Running
        const runAtomberg = {
          ...baseAtomberg,
          rmBase: Number(rmMapping.activeWaPrice || 135.83),
          mbBase: Number(mbMapping.activeMbPrice || 258.54),
          partWt: Number(params.runningNetWeight ?? baseAtomberg.partWt),
          runnerWt: Number(params.runningRunnerWeight ?? baseAtomberg.runnerWt),
          mbPct: Number((params.runningMbPct !== undefined ? params.runningMbPct : 4.0) / 100),
          bopCost: Number(params.runningBopCost ?? baseAtomberg.bopCost),
          cycleTime: Number(params.runningCycleTime ?? baseAtomberg.cycleTime),
          cavity: Number(params.runningCavity ?? baseAtomberg.cavity),
          tonnage: Number(params.runningTonnage ?? baseAtomberg.tonnage)
        };
        const runCalc = calculateAtombergCost(runAtomberg);
        actualUnitCost = Number(runCalc.finalLanded.toFixed(2));
      } else {
        // Haier Standard Engine
        const baseHaier = {
          cavity: Number(part.cavity || 2),
          netWeight: Number(part.netWeight || 197),
          runnerWeight: Number(part.runnerWeight || 40),
          rmRate: Number(rmMapping.approvedPrice || part.approvedRmRate || 140.00),
          masterbatchPct: Number(part.masterbatchPct || 0),
          masterbatchRate: Number(part.masterbatchRate || 0),
          machineTonnage: Number(part.machineTonnage || 450),
          shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : 4600),
          cycleTime: Number(part.cycleTimeApproved || part.cycleTime || 48)
        };
        const baseCalc = calculateHaierCost(baseHaier);
        contractBaseline = Number(baseCalc.totalCost.toFixed(2));

        const runHaier = {
          cavity: Number(params.runningCavity ?? baseHaier.cavity),
          netWeight: Number(params.runningNetWeight ?? baseHaier.netWeight),
          runnerWeight: Number(params.runningRunnerWeight ?? baseHaier.runnerWeight),
          rmRate: Number(rmMapping.activeWaPrice || baseHaier.rmRate),
          masterbatchPct: Number(params.runningMbPct ?? baseHaier.masterbatchPct),
          masterbatchRate: baseHaier.masterbatchRate,
          machineTonnage: Number(params.runningTonnage ?? baseHaier.machineTonnage),
          shiftTariff: Number(params.runningShiftTariff ?? baseHaier.shiftTariff),
          cycleTime: Number(params.runningCycleTime ?? baseHaier.cycleTime)
        };
        const runCalc = calculateHaierCost(runHaier);
        actualUnitCost = Number(runCalc.totalCost.toFixed(2));
      }

      const unitDelta = Number((contractBaseline - actualUnitCost).toFixed(2));
      const totalDelta = Number((unitDelta * sale.saleUnit).toFixed(2));
      const totalSales = Number((sale.sellingPrice * sale.saleUnit).toFixed(2));

      return {
        ...sale,
        contractBaseline,
        actualUnitCost,
        unitDelta,
        totalDelta,
        totalSales
      };
    });
  }, [salesData, baselineList, selectedVendor]);

  const summary = useMemo(() => {
    const totalVolume = analyzedRows.reduce((a, b) => a + (b.saleUnit || 0), 0);
    const totalRevenue = analyzedRows.reduce((a, b) => a + (b.totalSales || 0), 0);
    const totalCostDelta = analyzedRows.reduce((a, b) => a + (b.totalDelta || 0), 0);
    return {
      totalVolume,
      totalRevenue,
      totalCostDelta
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
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors Combined</option>
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
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Gross Realization</span>
          <span className="text-2xl font-black text-emerald-900 font-mono mt-1 block">
            ₹{(summary.totalRevenue * 0.12).toLocaleString('en-IN', { maximumFractionDigits: 0 })}
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
                    <span className={row.unitDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}>
                      {row.unitDelta >= 0 ? `₹ +${row.unitDelta.toFixed(2)}` : `₹ -${Math.abs(row.unitDelta).toFixed(2)}`}
                    </span>
                  </td>
                  <td className="p-3 text-right font-mono font-black bg-cyan-50">
                    <span className={row.totalDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}>
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
MIS_PAGE_EOF

echo "==> MIS Page synchronized with exact Atomberg 38-line costing engine."
