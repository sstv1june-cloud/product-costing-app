#!/usr/bin/env bash
set -e

echo "==> 1. Updating MISVariancePage.jsx with Product-Wise Aggregated Pivot Summary..."
cat << 'PAGE_EOF' > src/modules/module4-mis/MISVariancePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  TrendingUp, 
  TrendingDown, 
  Download, 
  Search, 
  Filter, 
  Layers, 
  BarChart3, 
  PieChart,
  Calendar, 
  FileSpreadsheet,
  Table,
  CheckCircle2
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  getActiveRmMapping, 
  getActiveMbMapping 
} from '../../shared/masterStore';
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';

export default function MISVariancePage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [periodStart, setPeriodStart] = useState('2026-08-01');
  const [periodEnd, setPeriodEnd] = useState('2026-08-31');
  const [viewMode, setViewMode] = useState('pivot'); // 'pivot' (Product Summary) | 'detailed' (Invoice Wise)
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const unsub = subscribeStore(() => {
      setStoreState({ ...globalStore });
    });
    return () => unsub();
  }, []);

  const vendors = [
    { vendorId: 'ALL', vendorName: 'All Vendors Combined' },
    ...(storeState.vendors || [
      { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
      { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
      { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
    ])
  ];

  // 1. Filter Sales within selected period & vendor
  const filteredSales = (storeState.sales || []).filter(s => {
    const vMatch = selectedVendor === 'ALL' || 
                   (s.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
                   selectedVendor.toLowerCase().includes((s.vendor || '').toLowerCase());
    const dateMatch = (!periodStart || s.date >= periodStart) && (!periodEnd || s.date <= periodEnd);
    const qMatch = !searchQuery || 
                   (s.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
                   (s.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
                   (s.invoiceNo || '').toLowerCase().includes(searchQuery.toLowerCase());
    return vMatch && dateMatch && qMatch;
  });

  // 2. Map unit costs and variances for each individual sale
  const detailedRows = filteredSales.map((s, idx) => {
    const isAtomberg = (s.vendor || '').toLowerCase().includes('atomberg');
    const matchedBaseline = (storeState.baselineProducts || []).find(p => p.itemCode === s.itemCode) || {};

    const rmInfo = getActiveRmMapping(matchedBaseline.approvedRm, s.vendor, s.date);
    const mbInfo = getActiveMbMapping(matchedBaseline.approvedMb, s.vendor, s.date);

    let contractBaseline = 0;
    let actualUnitCost = 0;

    if (isAtomberg) {
      const baseCalc = calculateAtombergCost({
        rmBase: Number(rmInfo.approvedPrice || matchedBaseline.approvedRmRate || 131),
        mbBase: Number(mbInfo.approvedMbPrice || matchedBaseline.masterbatchRate || 254),
        partWt: Number(matchedBaseline.netWeight || 37),
        runnerWt: Number(matchedBaseline.runnerWeight || 1),
        mbPct: Number(matchedBaseline.masterbatchPct || 4.0) / 100,
        bopCost: Number(matchedBaseline.bopCost || 0),
        cycleTime: Number(matchedBaseline.cycleTimeApproved || 47),
        cavity: Number(matchedBaseline.cavity || 2),
        tonnage: Number(matchedBaseline.machineTonnage || 200),
        shiftTariff: Number(matchedBaseline.shiftTariff || 2000),
        postOpCost: 1.73,
        packingCost: Number(matchedBaseline.packingCost || 0.86),
        transportCost: Number(matchedBaseline.transportCost || 0.62)
      });

      const actCalc = calculateAtombergCost({
        rmBase: Number(rmInfo.activeWaPrice || rmInfo.approvedPrice || 135.83),
        mbBase: Number(mbInfo.activeMbWaPrice || mbInfo.approvedMbPrice || 258.54),
        partWt: Number(matchedBaseline.parameters?.runningNetWeight ?? matchedBaseline.netWeight ?? 37),
        runnerWt: Number(matchedBaseline.parameters?.runningRunnerWeight ?? matchedBaseline.runnerWeight ?? 1),
        mbPct: Number(matchedBaseline.parameters?.runningMbPct ?? matchedBaseline.masterbatchPct ?? 4.0) / 100,
        bopCost: Number(matchedBaseline.parameters?.runningBopCost ?? matchedBaseline.bopCost ?? 0),
        cycleTime: Number(matchedBaseline.parameters?.runningCycleTime ?? matchedBaseline.cycleTimeApproved ?? 47),
        cavity: Number(matchedBaseline.parameters?.runningCavity ?? matchedBaseline.cavity ?? 2),
        tonnage: Number(matchedBaseline.parameters?.runningTonnage ?? matchedBaseline.machineTonnage ?? 200),
        shiftTariff: Number(matchedBaseline.parameters?.runningShiftTariff ?? matchedBaseline.shiftTariff ?? 2000),
        postOpCost: 1.73,
        packingCost: Number(matchedBaseline.parameters?.runningPackingCost ?? matchedBaseline.packingCost ?? 0.86),
        transportCost: Number(matchedBaseline.parameters?.runningTransportCost ?? matchedBaseline.transportCost ?? 0.62)
      });

      contractBaseline = Number(baseCalc.finalLanded || 11.75);
      actualUnitCost = Number(actCalc.finalLanded || 11.97);
    } else {
      const baseCalc = calculateHaierCost({
        cavity: Number(matchedBaseline.cavity || 2),
        netWeight: Number(matchedBaseline.netWeight || 197),
        runnerWeight: Number(matchedBaseline.runnerWeight || 40),
        rmRate: Number(rmInfo.approvedPrice || 136.20),
        masterbatchPct: Number(matchedBaseline.masterbatchPct || 0),
        machineTonnage: Number(matchedBaseline.machineTonnage || 450),
        shiftTariff: Number(matchedBaseline.shiftTariff || 4600),
        cycleTime: Number(matchedBaseline.cycleTimeApproved || 56),
        bopCost: Number(matchedBaseline.bopCost || 0.14)
      });

      const actCalc = calculateHaierCost({
        cavity: Number(matchedBaseline.parameters?.runningCavity ?? matchedBaseline.cavity ?? 2),
        netWeight: Number(matchedBaseline.parameters?.runningNetWeight ?? matchedBaseline.netWeight ?? 197),
        runnerWeight: Number(matchedBaseline.parameters?.runningRunnerWeight ?? matchedBaseline.runnerWeight ?? 40),
        rmRate: Number(rmInfo.activeWaPrice || rmInfo.approvedPrice || 134.80),
        masterbatchPct: Number(matchedBaseline.parameters?.runningMbPct ?? matchedBaseline.masterbatchPct ?? 0),
        machineTonnage: Number(matchedBaseline.parameters?.runningTonnage ?? matchedBaseline.machineTonnage ?? 450),
        shiftTariff: Number(matchedBaseline.parameters?.runningShiftTariff ?? matchedBaseline.shiftTariff ?? 4600),
        cycleTime: Number(matchedBaseline.parameters?.runningCycleTime ?? matchedBaseline.cycleTimeApproved ?? 56),
        bopCost: Number(matchedBaseline.parameters?.runningBopCost ?? matchedBaseline.bopCost ?? 0.14)
      });

      contractBaseline = Number(baseCalc.totalCost || 35.06);
      actualUnitCost = Number(actCalc.totalCost || 34.05);
    }

    const sellingPrice = Number(s.sellingPrice || contractBaseline);
    const qty = Number(s.qty || 0);
    const unitProfitDelta = Number((contractBaseline - actualUnitCost).toFixed(2));
    const totalProfitLoss = Number((unitProfitDelta * qty).toFixed(2));
    const totalSalesRev = Number((sellingPrice * qty).toFixed(2));
    const totalActualCost = Number((actualUnitCost * qty).toFixed(2));
    const grossMarginVal = Number((totalSalesRev - totalActualCost).toFixed(2));

    return {
      ...s,
      rowId: `sale-row-${idx}`,
      sellingPrice,
      contractBaseline,
      actualUnitCost,
      unitProfitDelta,
      totalProfitLoss,
      totalSalesRev,
      grossMarginVal
    };
  });

  // 3. Product-Wise Summary (Pivot Aggregation grouped by itemCode)
  const productPivotMap = {};
  detailedRows.forEach(row => {
    const key = `${row.vendor}__${row.itemCode}`;
    if (!productPivotMap[key]) {
      productPivotMap[key] = {
        itemCode: row.itemCode,
        componentName: row.componentName,
        vendor: row.vendor,
        totalQty: 0,
        totalSalesRev: 0,
        contractBaseline: row.contractBaseline,
        actualUnitCost: row.actualUnitCost,
        unitProfitDelta: row.unitProfitDelta,
        totalProfitLoss: 0,
        grossMarginVal: 0,
        invoiceCount: 0
      };
    }

    productPivotMap[key].totalQty += row.qty;
    productPivotMap[key].totalSalesRev += row.totalSalesRev;
    productPivotMap[key].totalProfitLoss += row.totalProfitLoss;
    productPivotMap[key].grossMarginVal += row.grossMarginVal;
    productPivotMap[key].invoiceCount += 1;
  });

  const pivotRows = Object.values(productPivotMap).map(p => ({
    ...p,
    avgSellingPrice: p.totalQty > 0 ? Number((p.totalSalesRev / p.totalQty).toFixed(2)) : 0,
    marginPct: p.totalSalesRev > 0 ? Number(((p.grossMarginVal / p.totalSalesRev) * 100).toFixed(1)) : 0
  }));

  // Top KPIs
  const totalVolume = detailedRows.reduce((acc, r) => acc + r.qty, 0);
  const totalSalesRevenue = detailedRows.reduce((acc, r) => acc + r.totalSalesRev, 0);
  const totalGrossMargin = detailedRows.reduce((acc, r) => acc + r.grossMarginVal, 0);
  const totalCostVariance = detailedRows.reduce((acc, r) => acc + r.totalProfitLoss, 0);
  const grossMarginPercentage = totalSalesRevenue > 0 ? ((totalGrossMargin / totalSalesRevenue) * 100).toFixed(1) : 0;

  // Export MIS Report (.xlsx)
  const downloadReport = () => {
    const dataToExport = viewMode === 'pivot' 
      ? pivotRows.map(p => ({
          "Part Code": p.itemCode,
          "Component Name": p.componentName,
          "Vendor": p.vendor,
          "Invoices Combined": p.invoiceCount,
          "Total Qty Sold": p.totalQty,
          "Avg Selling Price (₹)": p.avgSellingPrice,
          "Contract Baseline (₹)": p.contractBaseline,
          "Actual Unit Cost (₹)": p.actualUnitCost,
          "Cost Variance (₹/pc)": p.unitProfitDelta,
          "Total Variance Gain/Loss (₹)": p.totalProfitLoss,
          "Total Sales Revenue (₹)": p.totalSalesRev,
          "Gross Margin (₹)": p.grossMarginVal,
          "Margin %": `${p.marginPct}%`
        }))
      : detailedRows.map(r => ({
          "Date": r.date,
          "Vendor": r.vendor,
          "Invoice #": r.invoiceNo,
          "Part Code": r.itemCode,
          "Component Name": r.componentName,
          "Qty Sold": r.qty,
          "Selling Price (₹)": r.sellingPrice,
          "Contract Baseline (₹)": r.contractBaseline,
          "Actual Unit Cost (₹)": r.actualUnitCost,
          "Cost Variance (₹/pc)": r.unitProfitDelta,
          "Total Profit/Loss (₹)": r.totalProfitLoss,
          "Total Sales Revenue (₹)": r.totalSalesRev
        }));

    const ws = XLSX.utils.json_to_sheet(dataToExport);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, viewMode === 'pivot' ? "Product_Pivot_Summary" : "Invoice_Wise_Sales");
    XLSX.writeFile(wb, `MIS_Sales_Costing_Report_${periodStart}_to_${periodEnd}.xlsx`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Layers className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">4. Vendor & Product Sales P&L MIS Intelligence</h1>
            <p className="text-[11px] text-slate-300">Decoupled Output Store • Zero BOM Overhead • Synced Live</p>
          </div>
        </div>

        <button
          onClick={downloadReport}
          className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm text-xs"
        >
          <Download className="w-4 h-4" /> Download Complete MIS Report (.xlsx)
        </button>
      </div>

      {/* 4 Summary KPI Cards */}
      <div className="grid grid-cols-4 gap-3">
        <div className="p-4 bg-white border border-slate-200 rounded-2xl shadow-xs">
          <div className="text-[10px] font-bold text-slate-400 uppercase">PERIOD SALES VOLUME</div>
          <div className="text-2xl font-black text-slate-900 font-mono mt-1">{totalVolume.toLocaleString()} <span className="text-sm font-semibold text-slate-500">pcs</span></div>
        </div>

        <div className="p-4 bg-white border border-slate-200 rounded-2xl shadow-xs">
          <div className="text-[10px] font-bold text-slate-400 uppercase">TOTAL SALES REVENUE</div>
          <div className="text-2xl font-black text-blue-700 font-mono mt-1">₹{totalSalesRevenue.toLocaleString()}</div>
        </div>

        <div className="p-4 bg-white border border-slate-200 rounded-2xl shadow-xs">
          <div className="text-[10px] font-bold text-slate-400 uppercase">GROSS PROFIT & MARGIN</div>
          <div className="text-2xl font-black text-emerald-700 font-mono mt-1">
            ₹{totalGrossMargin.toLocaleString()} <span className="text-xs font-bold text-emerald-600">({grossMarginPercentage}%)</span>
          </div>
        </div>

        <div className={`p-4 rounded-2xl border shadow-xs ${totalCostVariance >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-rose-50 border-rose-200 text-rose-700'}`}>
          <div className="text-[10px] font-bold uppercase">COST VARIANCE GAIN / LOSS</div>
          <div className="text-2xl font-black font-mono mt-1">
            {totalCostVariance >= 0 ? `+ ₹${totalCostVariance.toLocaleString()}` : `- ₹${Math.abs(totalCostVariance).toLocaleString()}`}
          </div>
        </div>
      </div>

      {/* Main Table Card */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        {/* Table Filter & View Switcher Bar */}
        <div className="p-3.5 bg-slate-900 text-white flex flex-wrap justify-between items-center gap-3">
          <div className="flex items-center gap-2">
            <BarChart3 className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">PRODUCT SALES REALIZATION & COSTING ANALYSIS</h2>
          </div>

          <div className="flex flex-wrap items-center gap-2 text-xs">
            {/* View Mode Toggle: Pivot vs Detailed */}
            <div className="flex bg-slate-800 p-0.5 rounded-xl border border-slate-700">
              <button
                onClick={() => setViewMode('pivot')}
                className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer flex items-center gap-1 ${
                  viewMode === 'pivot' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'
                }`}
              >
                <PieChart className="w-3.5 h-3.5" /> Product Summary ({pivotRows.length})
              </button>
              <button
                onClick={() => setViewMode('detailed')}
                className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer flex items-center gap-1 ${
                  viewMode === 'detailed' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'
                }`}
              >
                <Table className="w-3.5 h-3.5" /> Invoices Log ({detailedRows.length})
              </button>
            </div>

            <div className="flex items-center gap-1.5 ml-2">
              <span className="text-slate-400 font-semibold">Vendor:</span>
              <select
                value={selectedVendor}
                onChange={e => setSelectedVendor(e.target.value)}
                className="px-2.5 py-1 rounded-lg bg-slate-800 text-white border border-slate-700 font-bold"
              >
                {vendors.map(v => (
                  <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
                ))}
              </select>
            </div>

            <div className="flex items-center gap-1">
              <input type="date" value={periodStart} onChange={e => setPeriodStart(e.target.value)} className="px-2 py-1 rounded-lg bg-slate-800 text-white border border-slate-700" />
              <span className="text-slate-400">to</span>
              <input type="date" value={periodEnd} onChange={e => setPeriodEnd(e.target.value)} className="px-2 py-1 rounded-lg bg-slate-800 text-white border border-slate-700" />
            </div>
          </div>
        </div>

        {/* View Mode 1: Product Summary Pivot */}
        {viewMode === 'pivot' && (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Part Code</th>
                  <th className="py-2.5 px-4">Component Name</th>
                  <th className="py-2.5 px-3">Vendor</th>
                  <th className="py-2.5 px-3 text-center">Invoices</th>
                  <th className="py-2.5 px-3 text-right">Total Qty Sold</th>
                  <th className="py-2.5 px-3 text-right">Avg Selling Price</th>
                  <th className="py-2.5 px-3 text-right bg-amber-50/70 text-amber-950">Contract Baseline</th>
                  <th className="py-2.5 px-3 text-right">Actual Unit Cost</th>
                  <th className="py-2.5 px-3 text-right">Profit / Loss (Δ)</th>
                  <th className="py-2.5 px-3 text-right">Total Gain/Loss</th>
                  <th className="py-2.5 px-4 text-right font-black">Total Sales Revenue</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {pivotRows.length === 0 ? (
                  <tr><td colSpan={11} className="py-8 text-center text-slate-400">No sales transactions recorded for the selected period.</td></tr>
                ) : (
                  pivotRows.map(p => (
                    <tr key={`${p.vendor}-${p.itemCode}`} className="hover:bg-slate-50 transition-colors">
                      <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{p.itemCode}</td>
                      <td className="py-2.5 px-4 font-bold text-slate-900">{p.componentName}</td>
                      <td className="py-2.5 px-3">
                        <span className="px-2 py-0.5 rounded font-bold text-[10px] bg-slate-100 text-slate-700">{p.vendor}</span>
                      </td>
                      <td className="py-2.5 px-3 text-center font-mono font-bold text-slate-600">{p.invoiceCount}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-black text-slate-900">{p.totalQty.toLocaleString()}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">₹{p.avgSellingPrice.toFixed(2)}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-amber-900 bg-amber-50/40">₹{p.contractBaseline.toFixed(2)}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-800">₹{p.actualUnitCost.toFixed(2)}</td>
                      <td className={`py-2.5 px-3 text-right font-mono font-bold ${p.unitProfitDelta >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                        {p.unitProfitDelta >= 0 ? `+ ₹${p.unitProfitDelta.toFixed(2)}` : `- ₹${Math.abs(p.unitProfitDelta).toFixed(2)}`}
                      </td>
                      <td className={`py-2.5 px-3 text-right font-mono font-bold ${p.totalProfitLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                        {p.totalProfitLoss >= 0 ? `+ ₹${p.totalProfitLoss.toLocaleString()}` : `- ₹${Math.abs(p.totalProfitLoss).toLocaleString()}`}
                      </td>
                      <td className="py-2.5 px-4 text-right font-mono font-black text-slate-900">₹{p.totalSalesRev.toLocaleString()}</td>
                    </tr>
                  ))
                )}
              </tbody>
              {pivotRows.length > 0 && (
                <tfoot className="bg-slate-900 text-white font-bold">
                  <tr>
                    <td colSpan={4} className="py-3 px-3 uppercase tracking-wider text-amber-400">Total Combined Summary</td>
                    <td className="py-3 px-3 text-right font-mono font-black text-amber-300">{totalVolume.toLocaleString()}</td>
                    <td className="py-3 px-3 text-right font-mono">-</td>
                    <td className="py-3 px-3 text-right font-mono">-</td>
                    <td className="py-3 px-3 text-right font-mono">-</td>
                    <td className="py-3 px-3 text-right font-mono">-</td>
                    <td className={`py-3 px-3 text-right font-mono font-black ${totalCostVariance >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                      {totalCostVariance >= 0 ? `+ ₹${totalCostVariance.toLocaleString()}` : `- ₹${Math.abs(totalCostVariance).toLocaleString()}`}
                    </td>
                    <td className="py-3 px-4 text-right font-mono font-black text-amber-300">₹{totalSalesRevenue.toLocaleString()}</td>
                  </tr>
                </tfoot>
              )}
            </table>
          </div>
        )}

        {/* View Mode 2: Detailed Invoice-Wise Log */}
        {viewMode === 'detailed' && (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Date</th>
                  <th className="py-2.5 px-3">Part Code</th>
                  <th className="py-2.5 px-4">Component Name</th>
                  <th className="py-2.5 px-3">Vendor</th>
                  <th className="py-2.5 px-3">Invoice #</th>
                  <th className="py-2.5 px-3 text-right">Qty Sold</th>
                  <th className="py-2.5 px-3 text-right">Selling Price</th>
                  <th className="py-2.5 px-3 text-right bg-amber-50/70 text-amber-950">Contract Baseline</th>
                  <th className="py-2.5 px-3 text-right">Actual Unit Cost</th>
                  <th className="py-2.5 px-3 text-right">Profit / Loss (Δ)</th>
                  <th className="py-2.5 px-3 text-right">Total Gain/Loss</th>
                  <th className="py-2.5 px-4 text-right font-black">Total Sales</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {detailedRows.length === 0 ? (
                  <tr><td colSpan={12} className="py-8 text-center text-slate-400">No sales transactions found.</td></tr>
                ) : (
                  detailedRows.map(r => (
                    <tr key={r.rowId} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-600">{r.date}</td>
                      <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{r.itemCode}</td>
                      <td className="py-2.5 px-4 font-bold text-slate-900">{r.componentName}</td>
                      <td className="py-2.5 px-3"><span className="px-2 py-0.5 rounded font-bold text-[10px] bg-slate-100 text-slate-700">{r.vendor}</span></td>
                      <td className="py-2.5 px-3 font-mono text-slate-700">{r.invoiceNo}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">{r.qty.toLocaleString()}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold">₹{r.sellingPrice.toFixed(2)}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-amber-900 bg-amber-50/40">₹{r.contractBaseline.toFixed(2)}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-800">₹{r.actualUnitCost.toFixed(2)}</td>
                      <td className={`py-2.5 px-3 text-right font-mono font-bold ${r.unitProfitDelta >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                        {r.unitProfitDelta >= 0 ? `+ ₹${r.unitProfitDelta.toFixed(2)}` : `- ₹${Math.abs(r.unitProfitDelta).toFixed(2)}`}
                      </td>
                      <td className={`py-2.5 px-3 text-right font-mono font-bold ${r.totalProfitLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                        {r.totalProfitLoss >= 0 ? `+ ₹${r.totalProfitLoss.toLocaleString()}` : `- ₹${Math.abs(r.totalProfitLoss).toLocaleString()}`}
                      </td>
                      <td className="py-2.5 px-4 text-right font-mono font-black text-slate-900">₹{r.totalSalesRev.toLocaleString()}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
PAGE_EOF

echo "==> 2. Verifying clean build with npm run build..."
npm run build

echo "==> 3. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Product-Wise Pivot Aggregation & MIS View Switcher live!"
echo "-------------------------------------------------------------------"
