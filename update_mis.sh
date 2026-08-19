#!/usr/bin/env bash
set -e

# 1. Update masterStore.js to supply matching sales transactions and rates
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';

const data = Array.isArray(initialBaselineData) ? initialBaselineData : [];

export const initialPurchaseMaster = [
  { code: "PUR-ABS-01", invoiceNo: "INV-PUR-8821", name: "ABS 300-B Red (Prime Inward)", polymer: "ABS", supplier: "Supreme Petrochem", waPrice: 134.80, inwardDate: "2026-08-01", qtyKg: 12500 },
  { code: "PUR-ABS-02", invoiceNo: "INV-PUR-8822", name: "ABS 300-Blue (Imported)", polymer: "ABS", supplier: "Chi Mei", waPrice: 131.25, inwardDate: "2026-08-05", qtyKg: 8200 },
  { code: "PUR-GPPS-01", invoiceNo: "INV-PUR-8824", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", polymer: "GPPS", supplier: "Supreme", waPrice: 98.40, inwardDate: "2026-08-03", qtyKg: 9000 }
];

export const initialSalesData = [
  { id: "INV-SLS-001", invoiceNo: "INV-SLS-001", itemCode: "0060226713H", componentName: "End Cap Top Ref (without Screen Painting )", vendor: "Haier", saleUnit: 4500, invoiceDate: "2026-08-05", sellingPrice: 38.50 },
  { id: "INV-SLS-002", invoiceNo: "INV-SLS-002", itemCode: "0060217989D", componentName: "End cap Bottom Ref-ABS-DC-195,220", vendor: "Haier", saleUnit: 4200, invoiceDate: "2026-08-10", sellingPrice: 42.00 },
  { id: "INV-SLS-003", invoiceNo: "INV-SLS-003", itemCode: "0060217978E", componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX", vendor: "Haier", saleUnit: 1800, invoiceDate: "2026-08-12", sellingPrice: 85.00 }
];

export const initialRmMatrix = [
  {
    id: "RM-HAIER-ABS-P1",
    vendor: "Haier",
    approvedRm: "ABS 300 Pre Colour",
    polymer: "ABS",
    approvedPrice: 136.20,
    validFrom: "2026-08-01",
    validTo: "2026-08-31",
    activeSelection: "alt1",
    alt1: { code: "PUR-ABS-01", name: "ABS 300-B Red (Prime Inward)", waPrice: 134.80 }
  },
  {
    id: "RM-HAIER-GPPS-P1",
    vendor: "Haier",
    approvedRm: "GPPS SC201LV",
    polymer: "GPPS",
    approvedPrice: 103.08,
    validFrom: "2026-08-01",
    validTo: "2026-08-31",
    activeSelection: "alt1",
    alt1: { code: "PUR-GPPS-01", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", waPrice: 98.40 }
  }
];

export const globalStore = {
  baselineList: data,
  baselineData: data,
  purchaseMaster: initialPurchaseMaster,
  salesData: initialSalesData,
  rmMatrix: initialRmMatrix,
  parameterChangeLogs: [],
  rmPriceHistoryLogs: [],
  vendors: [
    { vendorId: "Haier", vendorName: "Haier Appliances" },
    { vendorId: "LG", vendorName: "LG Electronics" },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India" }
  ]
};

const listeners = new Set();
export const subscribeStore = (fn) => { listeners.add(fn); return () => listeners.delete(fn); };
export const notifyStore = () => listeners.forEach(fn => fn());

export const getActiveRmMapping = (approvedRmName, vendor = "Haier", targetDate = null) => {
  const vKey = (vendor || "Haier").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey &&
    (r.approvedRm.toLowerCase() === (approvedRmName || "").toLowerCase() ||
     (approvedRmName || "").toLowerCase().includes(r.polymer?.toLowerCase()))
  );

  let row = rows[0];
  if (targetDate && rows.length > 0) {
    const matched = rows.find(r => targetDate >= r.validFrom && targetDate <= r.validTo);
    if (matched) row = matched;
  }

  if (!row) {
    return {
      vendor: vendor || "Haier",
      approvedRm: approvedRmName || "Standard Polymer",
      approvedPrice: 136.20,
      activeRmName: approvedRmName || "Standard Polymer",
      activeWaPrice: 136.20,
      validFrom: "2026-08-01",
      validTo: "2026-08-31"
    };
  }

  return {
    vendor: row.vendor,
    approvedRm: row.approvedRm,
    approvedPrice: row.approvedPrice,
    validFrom: row.validFrom,
    validTo: row.validTo,
    activeRmName: row.alt1?.name || row.approvedRm,
    activeWaPrice: row.alt1?.waPrice || row.approvedPrice
  };
};

export const addManualSaleRecord = (record) => {
  globalStore.salesData.unshift({
    id: `INV-SLS-${Date.now()}`,
    ...record
  });
  notifyStore();
};

export const uploadBulkSales = (newSales) => {
  globalStore.salesData = [...newSales, ...(globalStore.salesData || [])];
  notifyStore();
};
export default globalStore;
STORE_EOF

# 2. Update MISVariancePage.jsx with the exact columns and top filter
cat << 'PAGE_EOF' > src/modules/module4-mis/MISVariancePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Filter, Calendar, 
  Upload, Eye, X, CheckCircle2, Download, Layers, DollarSign 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping, uploadBulkSales } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISVariancePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const vendors = globalStore.vendors || [];

  // Top Filters placed above summary
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [drilldownItem, setDrilldownItem] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);

  // Filter products by vendor
  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  // Compute live MIS rows matching the Excel formula logic
  const misRows = useMemo(() => {
    return vendorProducts.map(part => {
      const params = part.parameters || {};

      // 1. Resolve RM Mapping
      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor, periodFrom);
      const approvedRmRate = rmMapping.approvedPrice || part.approvedRmRate || 136.20;
      const activeWaRate = rmMapping.activeWaPrice || approvedRmRate;

      // 2. Contract Baseline Unit Cost
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

      // 3. Actual Running Unit Cost
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

      // Unit Baseline vs Actual Unit Cost
      const contractBaseline = Number(part.approvedTotalCost ?? baselineCalc.totalCost.toFixed(2));
      const actualUnitCost = Number(runningCalc.totalCost.toFixed(2));

      // Unit Profit / Loss (Δ) = Contract Baseline - Actual Unit Cost
      const unitProfitLoss = Number((contractBaseline - actualUnitCost).toFixed(2));

      // Match Sales Invoices falling inside the Selected Period
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

      // Total Calculations
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

  // Aggregate KPI Calculations (100% Synced with Filters)
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

      {/* 1. TOP FILTER BAR (Placed directly above Summary) */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-300 shadow-xs flex flex-wrap items-center justify-between gap-3">
        
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5">
            <Filter className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-slate-800 text-xs uppercase tracking-wider">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="bg-white border-2 border-blue-600 text-blue-950 font-bold px-3 py-1.5 rounded-xl text-xs outline-none cursor-pointer shadow-2xs"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors Combined</option>
            </select>
          </div>

          <div className="h-4 w-px bg-slate-300"></div>

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
          Showing data filtered for <span className="font-bold text-slate-900">{selectedVendor}</span> from <span className="font-mono font-bold text-amber-900">{periodFrom}</span> to <span className="font-mono font-bold text-amber-900">{periodTo}</span>
        </div>

      </div>

      {/* 2. SYNCED KPI SUMMARY SECTION */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        
        {/* Card 1: Period Sales Volume */}
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Period Sales Volume</span>
          <span className="text-xl font-black text-slate-900 font-mono mt-1 block">
            {totalVolume.toLocaleString()} <span className="text-xs font-sans font-medium text-slate-500">pcs</span>
          </span>
        </div>

        {/* Card 2: Total Sales Revenue */}
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Total Sales Revenue</span>
          <span className="text-xl font-black text-blue-900 font-mono mt-1 block">
            ₹{totalRevenue.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
          </span>
        </div>

        {/* Card 3: Gross Profit & Margin */}
        <div className="bg-emerald-50/70 border border-emerald-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-emerald-800 uppercase tracking-wider block">Gross Profit & Margin</span>
          <span className="text-xl font-black text-emerald-700 font-mono mt-1 block">
            ₹{totalGrossProfit.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}{' '}
            <span className="text-xs font-sans font-bold">({grossMarginPct}%)</span>
          </span>
        </div>

        {/* Card 4: Cost Variance Gain */}
        <div className="bg-slate-900 text-white border border-slate-800 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-emerald-400 uppercase tracking-wider block">Cost Variance Gain</span>
          <span className="text-xl font-black text-emerald-400 font-mono mt-1 block">
            ₹{totalCostVarianceGain.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
          </span>
        </div>

      </div>

      {/* 3. MAIN MIS TABLE WITH THE 3 EXTRA COLUMNS */}
      <div className="bg-white border border-slate-300 rounded-2xl shadow-sm overflow-hidden p-4 space-y-3">
        
        <div className="flex justify-between items-center border-b pb-2">
          <h2 className="font-bold text-slate-900 text-sm">Product Sales Realization & Costing Analysis</h2>
          <span className="text-[11px] text-slate-500 italic">Click on any product row for sales batch drilldown</span>
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

                  {/* 1. Unit Profit / Loss (Δ) */}
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

            {/* Drilldown Summary Cards */}
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

            {/* Itemized Sales Dispatches Table */}
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
PAGE_EOF

echo "==> MIS Report and Sales Drilldown updated successfully."
