#!/usr/bin/env bash
set -e

mkdir -p src/modules/module0-dashboard src/modules/module4-mis

# 1. Create DashboardPage.jsx
cat << 'DASH_EOF' > src/modules/module0-dashboard/DashboardPage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Layers, ShoppingCart, 
  Truck, Building2, Calendar, Filter, ArrowUpRight, DollarSign,
  Sliders
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function DashboardPage({ onNavigate }) {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');

  const vendors = globalStore.vendors || [];
  const baselineList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const purchaseMaster = globalStore.purchaseMaster || [];

  const vendorParts = baselineList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const calculatedItems = useMemo(() => {
    return vendorParts.map(part => {
      const params = part.parameters || {};
      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor, periodFrom);
      const approvedRmRate = rmMapping.approvedPrice || part.approvedRmRate || 136.20;
      const activeWaRate = rmMapping.activeWaPrice || approvedRmRate;

      const baselineSpec = {
        cavity: Number(part.cavity ?? params.cavity ?? 2),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 197),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 40),
        rmRate: approvedRmRate,
        masterbatchPct: Number(part.masterbatchPct ?? 0),
        masterbatchRate: Number(part.masterbatchRate ?? 0),
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 450),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 3600)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 48)
      };
      const baselineCalc = calculateDetailedCost(baselineSpec, true);

      const runningSpec = {
        cavity: Number(params.runningCavity ?? baselineSpec.cavity),
        netWeight: Number(params.runningNetWeight ?? baselineSpec.netWeight),
        runnerWeight: Number(params.runningRunnerWeight ?? baselineSpec.runnerWeight),
        rmRate: activeWaRate,
        masterbatchPct: Number(params.runningMbPct ?? baselineSpec.masterbatchPct),
        masterbatchRate: baselineSpec.masterbatchRate,
        machineTonnage: Number(params.runningTonnage ?? baselineSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? (params.runningTonnage >= 600 ? 4800 : baselineSpec.shiftTariff)),
        cycleTime: Number(params.runningCycleTime ?? baselineSpec.cycleTime)
      };
      const runningCalc = calculateDetailedCost(runningSpec, false);

      const unitProfitLoss = Number((baselineCalc.totalCost - runningCalc.totalCost).toFixed(2));

      const matchedSales = salesData.filter(s => {
        const vendorMatch = selectedVendor === 'ALL' || s.vendor === part.vendor;
        const itemMatch = s.itemCode === part.itemCode;
        const dateMatch = s.invoiceDate >= periodFrom && s.invoiceDate <= periodTo;
        return vendorMatch && itemMatch && dateMatch;
      });

      const periodUnits = matchedSales.reduce((sum, s) => sum + Number(s.saleUnit || 0), 0);
      const totalPnL = Number((unitProfitLoss * periodUnits).toFixed(2));

      return {
        itemCode: part.itemCode,
        componentName: part.componentName,
        vendor: part.vendor || selectedVendor,
        approvedRm: part.approvedRm,
        baselineCost: baselineCalc.totalCost,
        actualCost: runningCalc.totalCost,
        unitProfitLoss,
        periodUnits,
        totalPnL
      };
    });
  }, [vendorParts, salesData, selectedVendor, periodFrom, periodTo]);

  const totalDispatchedVolume = calculatedItems.reduce((acc, r) => acc + r.periodUnits, 0);
  const netRealizedPnL = Number(calculatedItems.reduce((acc, r) => acc + r.totalPnL, 0).toFixed(2));

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <BarChart3 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">Executive MIS & Costing Intelligence Dashboard</h1>
            <p className="text-[11px] text-slate-300">Live multi-vendor costing consolidation & sales realization.</p>
          </div>
        </div>

        <div className="flex items-center gap-3 bg-slate-800 p-2 rounded-xl border border-slate-700">
          <div className="flex items-center gap-1.5">
            <Filter className="w-3.5 h-3.5 text-slate-400" />
            <span className="font-bold text-slate-300">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="bg-slate-900 border border-slate-600 text-white font-bold px-2 py-1 rounded text-xs outline-none"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Combined</option>
            </select>
          </div>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className={`p-4 rounded-2xl border ${netRealizedPnL >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
          <span className="text-[10px] font-bold uppercase text-slate-600 block">Net Realized P & L</span>
          <span className={`text-2xl font-black font-mono mt-1 block ${netRealizedPnL >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {netRealizedPnL >= 0 ? `+₹${netRealizedPnL.toFixed(2)}` : `-₹${Math.abs(netRealizedPnL).toFixed(2)}`}
          </span>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-300">
          <span className="text-[10px] font-bold text-slate-500 uppercase block">Total Sales Dispatched</span>
          <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">
            {totalDispatchedVolume.toLocaleString()} pcs
          </span>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-300">
          <span className="text-[10px] font-bold text-slate-500 uppercase block">Purchase WA Batches</span>
          <span className="text-2xl font-black text-amber-950 font-mono mt-1 block">
            {purchaseMaster.length} batches
          </span>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-300">
          <span className="text-[10px] font-bold text-slate-500 uppercase block">Onboarded Vendors</span>
          <span className="text-2xl font-black text-purple-950 font-mono mt-1 block">
            {vendors.length} OEMs
          </span>
        </div>
      </div>
    </div>
  );
}
DASH_EOF

# 2. Update Unified MIS Page with top filter bar + 3 highlighted extra columns + drilldown modal
cat << 'MIS_PAGE_EOF' > src/modules/module4-mis/MISVariancePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, Filter, Calendar, Eye, X, CheckCircle2, TrendingUp, TrendingDown 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISVariancePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const vendors = globalStore.vendors || [];

  // Top Filter State
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [drilldownItem, setDrilldownItem] = useState(null);

  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const misRows = useMemo(() => {
    return vendorProducts.map(part => {
      const params = part.parameters || {};

      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor, periodFrom);
      const approvedRmRate = rmMapping.approvedPrice || part.approvedRmRate || 136.20;
      const activeWaRate = rmMapping.activeWaPrice || approvedRmRate;

      const baselineSpec = {
        cavity: Number(part.cavity ?? params.cavity ?? 2),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 197),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 40),
        rmRate: approvedRmRate,
        masterbatchPct: Number(part.masterbatchPct ?? 0),
        masterbatchRate: Number(part.masterbatchRate ?? 0),
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 450),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 3600)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 48)
      };
      const baselineCalc = calculateDetailedCost(baselineSpec, true);

      const runningSpec = {
        cavity: Number(params.runningCavity ?? baselineSpec.cavity),
        netWeight: Number(params.runningNetWeight ?? baselineSpec.netWeight),
        runnerWeight: Number(params.runningRunnerWeight ?? baselineSpec.runnerWeight),
        rmRate: activeWaRate,
        masterbatchPct: Number(params.runningMbPct ?? baselineSpec.masterbatchPct),
        masterbatchRate: baselineSpec.masterbatchRate,
        machineTonnage: Number(params.runningTonnage ?? baselineSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? (params.runningTonnage >= 600 ? 4800 : baselineSpec.shiftTariff)),
        cycleTime: Number(params.runningCycleTime ?? baselineSpec.cycleTime)
      };
      const runningCalc = calculateDetailedCost(runningSpec, false);

      const contractBaseline = Number(part.approvedTotalCost ?? baselineCalc.totalCost.toFixed(2));
      const actualUnitCost = Number(runningCalc.totalCost.toFixed(2));
      const unitProfitLoss = Number((contractBaseline - actualUnitCost).toFixed(2));

      const matchedSales = salesData.filter(s => {
        const vendorMatch = selectedVendor === 'ALL' || s.vendor === part.vendor;
        const itemMatch = s.itemCode === part.itemCode;
        const dateMatch = s.invoiceDate >= periodFrom && s.invoiceDate <= periodTo;
        return vendorMatch && itemMatch && dateMatch;
      });

      const qtySold = matchedSales.reduce((acc, s) => acc + Number(s.saleUnit || 0), 0);
      const latestSale = matchedSales[0] || {};
      const latestInvoiceDate = latestSale.invoiceDate || '2026-08-05';
      const sellingPrice = Number(latestSale.sellingPrice || (contractBaseline * 1.18).toFixed(2));

      const totalProfitLoss = Number((unitProfitLoss * qtySold).toFixed(2));
      const totalSales = Number((sellingPrice * qtySold).toFixed(2));
      const totalActualCost = Number((actualUnitCost * qtySold).toFixed(2));
      const grossProfit = Number((totalSales - totalActualCost).toFixed(2));

      return {
        part,
        date: latestInvoiceDate,
        itemCode: part.itemCode,
        componentName: part.componentName,
        vendor: part.vendor || selectedVendor,
        qtySold,
        sellingPrice,
        contractBaseline,
        actualUnitCost,
        unitProfitLoss,
        totalProfitLoss,
        totalSales,
        grossProfit,
        salesRecords: matchedSales,
        baselineCalc,
        runningCalc
      };
    });
  }, [vendorProducts, salesData, selectedVendor, periodFrom, periodTo]);

  const totalVolume = misRows.reduce((acc, r) => acc + r.qtySold, 0);
  const totalRevenue = misRows.reduce((acc, r) => acc + r.totalSales, 0);
  const totalGrossProfit = misRows.reduce((acc, r) => acc + r.grossProfit, 0);
  const grossMarginPct = totalRevenue > 0 ? ((totalGrossProfit / totalRevenue) * 100).toFixed(1) : 0;
  const totalCostVarianceGain = misRows.reduce((acc, r) => acc + r.totalProfitLoss, 0);

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex justify-between items-center">
        <div>
          <h1 className="text-sm font-bold flex items-center gap-2">
            <BarChart3 className="w-4 h-4 text-blue-400" /> Vendor & Product Sales P&L MIS Intelligence
          </h1>
          <p className="text-[11px] text-slate-300">Sales volume, gross margin realization, and contract variance</p>
        </div>
      </div>

      {/* 1. TOP FILTER BAR ABOVE SUMMARY */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-300 shadow-xs flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-4 flex-wrap">
          
          <div className="flex items-center gap-2">
            <Filter className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-slate-800 text-xs uppercase tracking-wider">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="bg-white border-2 border-blue-600 text-blue-950 font-bold px-3 py-1 rounded-xl text-xs outline-none cursor-pointer"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors Combined</option>
            </select>
          </div>

          <div className="h-5 w-px bg-slate-300"></div>

          <div className="flex items-center gap-2">
            <Calendar className="w-3.5 h-3.5 text-amber-600" />
            <span className="font-bold text-slate-800 text-xs uppercase tracking-wider">Period:</span>
            <div className="flex items-center gap-1">
              <span className="text-[10px] font-bold text-slate-500 uppercase">From</span>
              <input
                type="date"
                value={periodFrom}
                onChange={e => setPeriodFrom(e.target.value)}
                className="bg-slate-50 border border-slate-300 font-mono font-bold text-blue-950 px-2 py-1 rounded-lg text-xs outline-none"
              />
            </div>
            <div className="flex items-center gap-1">
              <span className="text-[10px] font-bold text-slate-500 uppercase">To</span>
              <input
                type="date"
                value={periodTo}
                onChange={e => setPeriodTo(e.target.value)}
                className="bg-slate-50 border border-slate-300 font-mono font-bold text-blue-950 px-2 py-1 rounded-lg text-xs outline-none"
              />
            </div>
          </div>

        </div>

        <div className="text-[11px] font-semibold text-slate-500">
          Showing data for <span className="font-bold text-slate-900">{selectedVendor}</span> ({periodFrom} to {periodTo})
        </div>
      </div>

      {/* 2. SYNCED SUMMARY SECTION */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Period Sales Volume</span>
          <span className="text-xl font-black text-slate-900 font-mono mt-1 block">
            {totalVolume.toLocaleString()} <span className="text-xs font-sans font-medium text-slate-500">pcs</span>
          </span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Total Sales Revenue</span>
          <span className="text-xl font-black text-blue-900 font-mono mt-1 block">
            ₹{totalRevenue.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
          </span>
        </div>

        <div className="bg-emerald-50/70 border border-emerald-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-emerald-800 uppercase tracking-wider block">Gross Profit & Margin</span>
          <span className="text-xl font-black text-emerald-700 font-mono mt-1 block">
            ₹{totalGrossProfit.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}{' '}
            <span className="text-xs font-sans font-bold">({grossMarginPct}%)</span>
          </span>
        </div>

        <div className="bg-slate-900 text-white border border-slate-800 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-emerald-400 uppercase tracking-wider block">Cost Variance Gain</span>
          <span className="text-xl font-black text-emerald-400 font-mono mt-1 block">
            ₹{totalCostVarianceGain.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
          </span>
        </div>
      </div>

      {/* 3. MAIN TABLE WITH 3 EXTRA COLUMNS */}
      <div className="bg-white border border-slate-300 rounded-2xl shadow-sm overflow-hidden p-4 space-y-3">
        <div className="flex justify-between items-center border-b pb-2">
          <h2 className="font-bold text-slate-900 text-sm">Product Sales Realization & Costing Analysis</h2>
          <span className="text-[11px] text-slate-500 italic">Click on any row for sales drilldown</span>
        </div>

        <div className="overflow-x-auto border border-slate-300 rounded-xl">
          <table className="min-w-full text-xs text-left border-collapse">
            <thead>
              <tr className="bg-slate-100 text-slate-800 font-bold uppercase text-[10px] border-b border-slate-300">
                <th className="p-3">Date</th>
                <th className="p-3">Part Code</th>
                <th className="p-3 min-w-[220px]">Component Name</th>
                <th className="p-3">Vendor</th>
                <th className="p-3 text-right">Qty Sold</th>
                <th className="p-3 text-right">Selling Price</th>
                <th className="p-3 text-right">Contract Baseline</th>
                <th className="p-3 text-right">Actual Unit Cost</th>
                
                {/* 3 Extra Highlighted Columns */}
                <th className="p-3 text-right bg-amber-200 text-amber-950 font-black border-l border-amber-300">
                  Profit / Loss (Δ)
                </th>
                <th className="p-3 text-right bg-amber-200 text-amber-950 font-black">
                  Total Profit / Loss (Δ)
                </th>
                <th className="p-3 text-right bg-amber-200 text-amber-950 font-black border-r border-amber-300">
                  Total Sales
                </th>
                
                <th className="p-3 text-center w-12">Action</th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-200 font-medium">
              {misRows.map((row) => (
                <tr
                  key={row.itemCode}
                  onClick={() => setDrilldownItem(row)}
                  className="hover:bg-blue-50/50 cursor-pointer transition"
                >
                  <td className="p-3 font-mono text-slate-500">{row.date}</td>
                  
                  <td className="p-3 font-mono font-bold text-blue-700">
                    {row.itemCode}
                  </td>

                  <td className="p-3 font-semibold text-slate-900">
                    {row.componentName}
                  </td>

                  <td className="p-3 font-semibold text-slate-700">
                    {row.vendor}
                  </td>

                  <td className="p-3 text-right font-mono font-black text-slate-900">
                    {row.qtySold.toLocaleString()}
                  </td>

                  <td className="p-3 text-right font-mono font-bold text-slate-800">
                    ₹ {row.sellingPrice.toFixed(2)}
                  </td>

                  <td className="p-3 text-right font-mono text-slate-600">
                    ₹ {row.contractBaseline.toFixed(2)}
                  </td>

                  <td className="p-3 text-right font-mono font-bold text-emerald-800">
                    ₹ {row.actualUnitCost.toFixed(2)}
                  </td>

                  {/* 1. Profit / Loss (Δ) */}
                  <td className="p-3 text-right font-mono font-black bg-amber-50/50 text-slate-900 border-l border-amber-200">
                    ₹ {row.unitProfitLoss.toFixed(2)}
                  </td>

                  {/* 2. Total Profit / Loss (Δ) */}
                  <td className="p-3 text-right font-mono font-black bg-amber-50/50 text-slate-900">
                    ₹ {row.totalProfitLoss.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>

                  {/* 3. Total Sales */}
                  <td className="p-3 text-right font-mono font-black bg-amber-50/50 text-slate-900 border-r border-amber-200">
                    ₹ {row.totalSales.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>

                  <td className="p-3 text-center">
                    <button className="p-1 text-blue-600 hover:text-blue-900 hover:bg-blue-100 rounded-lg">
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* 4. SALES BATCH DRILLDOWN MODAL */}
      {drilldownItem && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full p-5 space-y-4 border border-slate-300 animate-in fade-in duration-100">
            
            <div className="flex justify-between items-start border-b pb-3">
              <div>
                <span className="px-2.5 py-0.5 bg-blue-600 text-white font-bold rounded-md font-mono text-[11px]">
                  {drilldownItem.itemCode}
                </span>
                <h3 className="font-bold text-sm text-slate-900 mt-1">{drilldownItem.componentName}</h3>
                <p className="text-slate-500 text-[11px]">
                  Vendor: <span className="font-bold text-slate-800">{drilldownItem.vendor}</span> | Period: <span className="font-mono font-bold text-amber-800">{periodFrom} to {periodTo}</span>
                </p>
              </div>
              <button onClick={() => setDrilldownItem(null)} className="p-1.5 text-slate-400 hover:text-slate-700 cursor-pointer">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-4 gap-3 text-center">
              <div className="bg-slate-100 p-3 rounded-xl border">
                <span className="text-[10px] text-slate-500 uppercase font-bold block">Contract Baseline</span>
                <span className="text-base font-black font-mono text-slate-900">₹{drilldownItem.contractBaseline.toFixed(2)}</span>
              </div>
              <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
                <span className="text-[10px] text-blue-700 uppercase font-bold block">Actual Unit Cost</span>
                <span className="text-base font-black font-mono text-blue-950">₹{drilldownItem.actualUnitCost.toFixed(2)}</span>
              </div>
              <div className="bg-slate-100 p-3 rounded-xl border">
                <span className="text-[10px] text-slate-500 uppercase font-bold block">Period Qty Sold</span>
                <span className="text-base font-black font-mono text-slate-900">{drilldownItem.qtySold.toLocaleString()} pcs</span>
              </div>
              <div className="bg-amber-50 p-3 rounded-xl border border-amber-300">
                <span className="text-[10px] font-bold uppercase block text-amber-900">Total Profit / Loss</span>
                <span className="text-base font-black font-mono text-amber-900">
                  ₹{drilldownItem.totalProfitLoss.toLocaleString('en-IN', { minimumFractionDigits: 2 })}
                </span>
              </div>
            </div>

            <div className="space-y-1.5">
              <span className="font-bold text-slate-800 block text-[11px]">Period Invoiced Sales Batches:</span>
              <div className="border border-slate-200 rounded-xl overflow-hidden">
                <table className="min-w-full text-xs text-left">
                  <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                    <tr>
                      <th className="p-2.5">Invoice ID</th>
                      <th className="p-2.5">Invoice Date</th>
                      <th className="p-2.5 text-right">Dispatched Qty</th>
                      <th className="p-2.5 text-right">Selling Price</th>
                      <th className="p-2.5 text-right">Batch Revenue</th>
                      <th className="p-2.5 text-right">Batch Profit/Loss (Δ)</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-200 font-medium">
                    {drilldownItem.salesRecords.map(s => (
                      <tr key={s.id}>
                        <td className="p-2.5 font-mono text-blue-700 font-bold">{s.invoiceNo || s.id}</td>
                        <td className="p-2.5 font-mono text-slate-600">{s.invoiceDate}</td>
                        <td className="p-2.5 text-right font-mono font-bold text-slate-900">{s.saleUnit?.toLocaleString()} pcs</td>
                        <td className="p-2.5 text-right font-mono text-slate-700">₹{s.sellingPrice?.toFixed(2)}</td>
                        <td className="p-2.5 text-right font-mono font-bold text-blue-900">
                          ₹{(s.saleUnit * s.sellingPrice).toLocaleString('en-IN', { minimumFractionDigits: 2 })}
                        </td>
                        <td className="p-2.5 text-right font-mono font-bold text-emerald-700">
                          ₹{(s.saleUnit * drilldownItem.unitProfitLoss).toLocaleString('en-IN', { minimumFractionDigits: 2 })}
                        </td>
                      </tr>
                    ))}
                    {drilldownItem.salesRecords.length === 0 && (
                      <tr>
                        <td colSpan="6" className="p-4 text-center text-slate-400 italic">No sales invoices found within selected period.</td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="flex justify-end pt-2 border-t">
              <button
                onClick={() => setDrilldownItem(null)}
                className="px-4 py-1.5 bg-slate-900 text-white font-bold rounded-xl cursor-pointer"
              >
                Close Drilldown
              </button>
            </div>

          </div>
        </div>
      )}

    </div>
  );
}
MIS_PAGE_EOF

# 3. Synchronize across all possible paths
[ -f src/modules/module4-mis/MISReportPage.jsx ] && cp src/modules/module4-mis/MISVariancePage.jsx src/modules/module4-mis/MISReportPage.jsx || true
[ -d src/modules/module1-mis ] && cp src/modules/module4-mis/MISVariancePage.jsx src/modules/module1-mis/MISVariancePage.jsx || true
[ -d src/modules/module4-mis-gap ] && cp src/modules/module4-mis/MISVariancePage.jsx src/modules/module4-mis-gap/MISGapPage.jsx || true

echo "==> Dashboard & MIS files compiled and synced."
