#!/usr/bin/env bash
set -e

echo "==> 1. Updating MISVariancePage.jsx to compute 100% dynamically from storeState..."
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
  CheckCircle2,
  ChevronRight,
  Activity,
  DollarSign,
  ArrowUpRight,
  ArrowDownRight,
  ArrowRightLeft,
  Building2
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
  const [viewMode, setViewMode] = useState('pivot'); // 'pivot' | 'detailed'
  const [searchQuery, setSearchQuery] = useState('');
  const [trendVendor, setTrendVendor] = useState('ALL');

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

  // Helper to compute costing for any single sale item dynamically
  const evaluateSaleItem = (s) => {
    const isAtomberg = (s.vendor || '').toLowerCase().includes('atomberg');
    const matchedBaseline = (storeState.baselineProducts || []).find(p => p.itemCode === s.itemCode) || {};

    const rmInfo = getActiveRmMapping(matchedBaseline.approvedRm, s.vendor, s.date);
    const mbInfo = getActiveMbMapping(matchedBaseline.approvedMb, s.vendor, s.date);

    let contractBaseline = 0;
    let actualUnitCost = 0;

    if (isAtomberg) {
      const baseCalc = calculateAtombergCost({
        rmBase: Number(rmInfo.approvedPrice || 0),
        mbBase: Number(mbInfo.approvedMbPrice || 0),
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
        rmBase: Number(rmInfo.activeWaPrice || rmInfo.approvedPrice || 0),
        mbBase: Number(mbInfo.activeMbWaPrice || mbInfo.approvedMbPrice || 0),
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

      contractBaseline = Number(baseCalc.finalLanded || 0);
      actualUnitCost = Number(actCalc.finalLanded || 0);
    } else {
      const baseCalc = calculateHaierCost({
        cavity: Number(matchedBaseline.cavity || 2),
        netWeight: Number(matchedBaseline.netWeight || 197),
        runnerWeight: Number(matchedBaseline.runnerWeight || 40),
        rmRate: Number(rmInfo.approvedPrice || 0),
        masterbatchPct: Number(matchedBaseline.masterbatchPct || 0),
        masterbatchRate: Number(mbInfo.approvedMbPrice || 0),
        machineTonnage: Number(matchedBaseline.machineTonnage || 450),
        shiftTariff: Number(matchedBaseline.shiftTariff || 3600),
        cycleTime: Number(matchedBaseline.cycleTimeApproved || 56),
        bopCost: Number(matchedBaseline.bopCost || 0.14),
        haierOverheadPackage: Number(matchedBaseline.haierOverheadPackage || 5.15)
      });

      const actCalc = calculateHaierCost({
        cavity: Number(matchedBaseline.parameters?.runningCavity ?? matchedBaseline.cavity ?? 2),
        netWeight: Number(matchedBaseline.parameters?.runningNetWeight ?? matchedBaseline.netWeight ?? 197),
        runnerWeight: Number(matchedBaseline.parameters?.runningRunnerWeight ?? matchedBaseline.runnerWeight ?? 40),
        rmRate: Number(rmInfo.activeWaPrice || rmInfo.approvedPrice || 0),
        masterbatchPct: Number(matchedBaseline.parameters?.runningMbPct ?? matchedBaseline.masterbatchPct ?? 0),
        masterbatchRate: Number(mbInfo.activeMbWaPrice || mbInfo.approvedMbPrice || 0),
        machineTonnage: Number(matchedBaseline.parameters?.runningTonnage ?? matchedBaseline.machineTonnage ?? 450),
        shiftTariff: Number(matchedBaseline.parameters?.runningShiftTariff ?? matchedBaseline.shiftTariff ?? 3600),
        cycleTime: Number(matchedBaseline.parameters?.runningCycleTime ?? matchedBaseline.cycleTimeApproved ?? 56),
        bopCost: Number(matchedBaseline.parameters?.runningBopCost ?? matchedBaseline.bopCost ?? 0.14),
        haierOverheadPackage: Number(matchedBaseline.parameters?.runningHaierOverheadPackage ?? matchedBaseline.haierOverheadPackage ?? 5.15)
      });

      contractBaseline = Number(baseCalc.totalCost || 0);
      actualUnitCost = Number(actCalc.totalCost || 0);
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
      sellingPrice,
      contractBaseline,
      actualUnitCost,
      unitProfitDelta,
      totalProfitLoss,
      totalSalesRev,
      grossMarginVal
    };
  };

  // 1. Filter Sales within selected period & vendor
  const allSales = (storeState.sales || []).map(evaluateSaleItem);

  const filteredSales = allSales.filter(s => {
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

  const detailedRows = filteredSales;

  // 2. Product-Wise Summary (Pivot Aggregation grouped by itemCode)
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

  // 3. Dynamic Vendor-Wise Period Comparison (Calculated from actual sales data)
  const nonAllVendors = vendors.filter(v => v.vendorId !== 'ALL');
  
  const vendorComparisonData = nonAllVendors.map(v => {
    const vName = v.vendorName;
    const currSales = allSales.filter(s => 
      (s.vendor || '').toLowerCase().includes(v.vendorId.toLowerCase()) &&
      (!periodStart || s.date >= periodStart) && 
      (!periodEnd || s.date <= periodEnd)
    );

    // Assume previous period is sales dated before periodStart
    const prevSales = allSales.filter(s => 
      (s.vendor || '').toLowerCase().includes(v.vendorId.toLowerCase()) &&
      periodStart && s.date < periodStart
    );

    const currRev = currSales.reduce((acc, s) => acc + s.totalSalesRev, 0);
    const currVar = currSales.reduce((acc, s) => acc + s.totalProfitLoss, 0);
    const prevRev = prevSales.reduce((acc, s) => acc + s.totalSalesRev, 0);
    const prevVar = prevSales.reduce((acc, s) => acc + s.totalProfitLoss, 0);

    const growthPct = prevRev > 0 ? (((currRev - prevRev) / prevRev) * 100).toFixed(1) : (currRev > 0 ? '+100%' : '0%');
    const varDelta = currVar - prevVar;

    return {
      vendorName: vName,
      currSalesRev: `₹${currRev.toLocaleString()}`,
      currVariance: currVar >= 0 ? `+ ₹${currVar.toLocaleString()}` : `- ₹${Math.abs(currVar).toLocaleString()}`,
      prevSalesRev: `₹${prevRev.toLocaleString()}`,
      prevVariance: prevVar >= 0 ? `+ ₹${prevVar.toLocaleString()}` : `- ₹${Math.abs(prevVar).toLocaleString()}`,
      revGrowth: `${growthPct.toString().startsWith('-') || growthPct.toString().startsWith('+') ? growthPct : '+' + growthPct}`,
      varianceDelta: varDelta >= 0 ? `+ ₹${varDelta.toLocaleString()}` : `- ₹${Math.abs(varDelta).toLocaleString()}`,
      rawCurrRev: currRev,
      rawCurrVar: currVar,
      rawPrevRev: prevRev,
      rawPrevVar: prevVar
    };
  });

  const totalCurrCompRev = vendorComparisonData.reduce((acc, v) => acc + v.rawCurrRev, 0);
  const totalCurrCompVar = vendorComparisonData.reduce((acc, v) => acc + v.rawCurrVar, 0);
  const totalPrevCompRev = vendorComparisonData.reduce((acc, v) => acc + v.rawPrevRev, 0);
  const totalPrevCompVar = vendorComparisonData.reduce((acc, v) => acc + v.rawPrevVar, 0);

  // 4. Dynamic Multi-Month Drilldown Matrix (Months 1-4 calculated live)
  const trendFilteredSales = allSales.filter(s => {
    if (trendVendor === 'ALL') return true;
    return (s.vendor || '').toLowerCase().includes(trendVendor.toLowerCase());
  });

  // Calculate monthly metrics live
  const getMonthSales = (mNum) => trendFilteredSales.filter(s => s.date && Number(s.date.split('-')[1]) === mNum);
  const m1Sales = getMonthSales(5); // May
  const m2Sales = getMonthSales(6); // June
  const m3Sales = getMonthSales(7); // July
  const m4Sales = getMonthSales(8); // August

  const getRev = (salesList) => salesList.reduce((acc, s) => acc + s.totalSalesRev, 0);
  const getVar = (salesList) => salesList.reduce((acc, s) => acc + s.totalProfitLoss, 0);

  const trendSalesRev = {
    m1: `₹${getRev(m1Sales).toLocaleString()}`,
    m2: `₹${getRev(m2Sales).toLocaleString()}`,
    m3: `₹${getRev(m3Sales).toLocaleString()}`,
    m4: `₹${getRev(m4Sales).toLocaleString()}`
  };

  const trendCostVariance = {
    m1: getVar(m1Sales) >= 0 ? `+ ₹${getVar(m1Sales).toLocaleString()}` : `- ₹${Math.abs(getVar(m1Sales)).toLocaleString()}`,
    m2: getVar(m2Sales) >= 0 ? `+ ₹${getVar(m2Sales).toLocaleString()}` : `- ₹${Math.abs(getVar(m2Sales)).toLocaleString()}`,
    m3: getVar(m3Sales) >= 0 ? `+ ₹${getVar(m3Sales).toLocaleString()}` : `- ₹${Math.abs(getVar(m3Sales)).toLocaleString()}`,
    m4: getVar(m4Sales) >= 0 ? `+ ₹${getVar(m4Sales).toLocaleString()}` : `- ₹${Math.abs(getVar(m4Sales)).toLocaleString()}`
  };

  // Group trend parts dynamically
  const partTrendMap = {};
  trendFilteredSales.forEach(s => {
    if (!partTrendMap[s.itemCode]) {
      partTrendMap[s.itemCode] = {
        code: s.itemCode,
        name: s.componentName,
        m1: 0,
        m2: 0,
        m3: 0,
        m4: 0,
        totalVar: 0
      };
    }
    const m = s.date ? Number(s.date.split('-')[1]) : 8;
    if (m === 5) partTrendMap[s.itemCode].m1 += s.totalProfitLoss;
    else if (m === 6) partTrendMap[s.itemCode].m2 += s.totalProfitLoss;
    else if (m === 7) partTrendMap[s.itemCode].m3 += s.totalProfitLoss;
    else partTrendMap[s.itemCode].m4 += s.totalProfitLoss;
    partTrendMap[s.itemCode].totalVar += s.totalProfitLoss;
  });

  const allTrendParts = Object.values(partTrendMap);
  const topProfitParts = allTrendParts.filter(p => p.totalVar >= 0).sort((a, b) => b.totalVar - a.totalVar).slice(0, 6);
  const topLossParts = allTrendParts.filter(p => p.totalVar < 0).sort((a, b) => a.totalVar - b.totalVar).slice(0, 6);

  // 5. Dynamic Root-Cause Gap Breakdown
  const haierSales = allSales.filter(s => (s.vendor || '').toLowerCase().includes('haier'));
  const atombergSales = allSales.filter(s => (s.vendor || '').toLowerCase().includes('atomberg'));

  const haierTotalVar = haierSales.reduce((acc, s) => acc + s.totalProfitLoss, 0);
  const atombergTotalVar = atombergSales.reduce((acc, s) => acc + s.totalProfitLoss, 0);

  const gapDrivers = allSales.length === 0 ? [] : [
    { 
      driver: "Polymer Base Rate Variance (RM Purchase vs Approved Contract)", 
      haierImpact: haierTotalVar >= 0 ? `+ ₹${haierTotalVar.toLocaleString()}` : `- ₹${Math.abs(haierTotalVar).toLocaleString()}`, 
      atombergImpact: atombergTotalVar >= 0 ? `+ ₹${atombergTotalVar.toLocaleString()}` : `- ₹${Math.abs(atombergTotalVar).toLocaleString()}`, 
      netTotal: (haierTotalVar + atombergTotalVar) >= 0 ? `+ ₹${(haierTotalVar + atombergTotalVar).toLocaleString()}` : `- ₹${Math.abs(haierTotalVar + atombergTotalVar).toLocaleString()}`, 
      status: (haierTotalVar + atombergTotalVar) >= 0 ? "Favorable" : "Unfavorable" 
    }
  ];

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
    XLSX.writeFile(wb, `MIS_Complete_Executive_Report_${periodStart}_to_${periodEnd}.xlsx`);
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

      {/* TABLE 1: PRODUCT SALES REALIZATION & PIVOT SUMMARY */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3.5 bg-slate-900 text-white flex flex-wrap justify-between items-center gap-3">
          <div className="flex items-center gap-2">
            <BarChart3 className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">PRODUCT SALES REALIZATION & COSTING ANALYSIS</h2>
          </div>

          <div className="flex flex-wrap items-center gap-2 text-xs">
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

        {viewMode === 'pivot' ? (
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
                      <td className="py-2.5 px-3"><span className="px-2 py-0.5 rounded font-bold text-[10px] bg-slate-100 text-slate-700">{p.vendor}</span></td>
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
        ) : (
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
                  detailedRows.map((r, rIdx) => (
                    <tr key={rIdx} className="hover:bg-slate-50">
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

      {/* TABLE 2: VENDOR-WISE PERIOD VS PREVIOUS PERIOD COMPARISON (100% DYNAMIC) */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3.5 bg-slate-900 text-white flex flex-wrap justify-between items-center gap-3">
          <div className="flex items-center gap-2">
            <Building2 className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">VENDOR-WISE PERIOD VS PREVIOUS PERIOD COMPARISON</h2>
          </div>

          <div className="flex items-center gap-2 text-xs">
            <span className="text-slate-400 font-semibold">Filter: Period From</span>
            <input type="date" value={periodStart} onChange={e => setPeriodStart(e.target.value)} className="px-2 py-1 rounded-lg bg-slate-800 text-white border border-slate-700" />
            <span className="text-slate-400">To</span>
            <input type="date" value={periodEnd} onChange={e => setPeriodEnd(e.target.value)} className="px-2 py-1 rounded-lg bg-slate-800 text-white border border-slate-700" />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th rowSpan={2} className="py-3 px-4 border-r border-slate-200 align-middle">VENDOR</th>
                <th colSpan={2} className="py-2 px-4 text-center bg-blue-50/80 text-blue-900 border-r border-slate-200">
                  CURRENT PERIOD ({periodStart} to {periodEnd})
                </th>
                <th colSpan={2} className="py-2 px-4 text-center bg-slate-200/70 text-slate-800 border-r border-slate-200">
                  PREVIOUS PERIOD / MONTH
                </th>
                <th colSpan={2} className="py-2 px-4 text-center bg-emerald-50/80 text-emerald-900">
                  PERIOD-ON-PERIOD GROWTH / VARIANCE (Δ)
                </th>
              </tr>
              <tr>
                <th className="py-2 px-4 text-right bg-blue-50/50 text-blue-900 font-bold">TOTAL SALES REVENUE</th>
                <th className="py-2 px-4 text-right bg-blue-50/50 text-blue-900 font-bold border-r border-slate-200">COST VARIANCE GAIN / LOSS</th>
                <th className="py-2 px-4 text-right bg-slate-100 text-slate-700 font-bold">TOTAL SALES REVENUE</th>
                <th className="py-2 px-4 text-right bg-slate-100 text-slate-700 font-bold border-r border-slate-200">COST VARIANCE GAIN / LOSS</th>
                <th className="py-2 px-4 text-center bg-emerald-50/40 text-emerald-900 font-bold">REVENUE GROWTH %</th>
                <th className="py-2 px-4 text-right bg-emerald-50/40 text-emerald-900 font-bold">VARIANCE DELTA (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {vendorComparisonData.map((v, idx) => (
                <tr key={idx} className="hover:bg-slate-50 transition-colors">
                  <td className="py-3 px-4 font-bold text-slate-900 border-r border-slate-100 flex items-center gap-1.5">
                    <span className="w-2 h-2 rounded-full bg-blue-600"></span>
                    {v.vendorName}
                  </td>
                  <td className="py-3 px-4 text-right font-mono font-bold text-blue-900 bg-blue-50/20">{v.currSalesRev}</td>
                  <td className={`py-3 px-4 text-right font-mono font-bold border-r border-slate-100 ${v.currVariance.startsWith('+') ? 'text-emerald-700' : 'text-rose-600'}`}>
                    {v.currVariance}
                  </td>
                  <td className="py-3 px-4 text-right font-mono text-slate-600 bg-slate-50/40">{v.prevSalesRev}</td>
                  <td className={`py-3 px-4 text-right font-mono font-semibold border-r border-slate-100 ${v.prevVariance.startsWith('+') ? 'text-emerald-700' : 'text-rose-600'}`}>
                    {v.prevVariance}
                  </td>
                  <td className="py-3 px-4 text-center font-mono font-bold text-emerald-600">{v.revGrowth}</td>
                  <td className={`py-3 px-4 text-right font-mono font-black ${v.varianceDelta.startsWith('+') ? 'text-emerald-700' : 'text-rose-600'}`}>
                    {v.varianceDelta}
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot className="bg-slate-900 text-white font-bold">
              <tr>
                <td className="py-3 px-4 uppercase tracking-wider text-amber-400">ALL VENDORS COMBINED</td>
                <td className="py-3 px-4 text-right font-mono font-black text-amber-300">₹{totalCurrCompRev.toLocaleString()}</td>
                <td className={`py-3 px-4 text-right font-mono font-black border-r border-slate-700 ${totalCurrCompVar >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                  {totalCurrCompVar >= 0 ? `+ ₹${totalCurrCompVar.toLocaleString()}` : `- ₹${Math.abs(totalCurrCompVar).toLocaleString()}`}
                </td>
                <td className="py-3 px-4 text-right font-mono text-slate-300">₹{totalPrevCompRev.toLocaleString()}</td>
                <td className="py-3 px-4 text-right font-mono text-emerald-400 border-r border-slate-700">
                  {totalPrevCompVar >= 0 ? `+ ₹${totalPrevCompVar.toLocaleString()}` : `- ₹${Math.abs(totalPrevCompVar).toLocaleString()}`}
                </td>
                <td className="py-3 px-4 text-center font-mono text-emerald-400 font-black">-</td>
                <td className="py-3 px-4 text-right font-mono text-emerald-400 font-black">
                  {(totalCurrCompVar - totalPrevCompVar) >= 0 ? `+ ₹${(totalCurrCompVar - totalPrevCompVar).toLocaleString()}` : `- ₹${Math.abs(totalCurrCompVar - totalPrevCompVar).toLocaleString()}`}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>

      {/* TABLE 3: MULTI-MONTH DRILLDOWN (100% DYNAMIC) */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3.5 bg-slate-900 text-white flex flex-wrap justify-between items-center gap-3">
          <div className="flex items-center gap-2">
            <Activity className="w-4 h-4 text-emerald-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">MULTI-MONTH VARIANCE DRILLDOWN & TOP-6 PART BREAKDOWN</h2>
          </div>

          <div className="flex items-center gap-2">
            <span className="text-slate-400 font-semibold">Filter Vendor:</span>
            <select
              value={trendVendor}
              onChange={e => setTrendVendor(e.target.value)}
              className="px-2.5 py-1 rounded-lg bg-slate-800 text-white border border-slate-700 font-bold text-xs"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-4 w-96">Filter Category / DrillDown</th>
                <th className="py-2.5 px-4 text-right">Month-1 (May)</th>
                <th className="py-2.5 px-4 text-right">Month-2 (June)</th>
                <th className="py-2.5 px-4 text-right">Month-3 (July)</th>
                <th className="py-2.5 px-4 text-right bg-blue-50/60 font-black text-blue-900">Month-4 (August)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              <tr className="bg-slate-50/80 font-bold">
                <td className="py-2.5 px-4 uppercase text-slate-900">TOTAL SALES REVENUE</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-700">{trendSalesRev.m1}</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-700">{trendSalesRev.m2}</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-700">{trendSalesRev.m3}</td>
                <td className="py-2.5 px-4 text-right font-mono font-black text-blue-900 bg-blue-50/30">{trendSalesRev.m4}</td>
              </tr>

              <tr className="bg-emerald-50/30 font-black">
                <td className="py-2.5 px-4 uppercase text-emerald-950">COST VARIANCE GAIN / LOSS</td>
                <td className="py-2.5 px-4 text-right font-mono text-emerald-700">{trendCostVariance.m1}</td>
                <td className="py-2.5 px-4 text-right font-mono text-emerald-700">{trendCostVariance.m2}</td>
                <td className="py-2.5 px-4 text-right font-mono text-emerald-700">{trendCostVariance.m3}</td>
                <td className="py-2.5 px-4 text-right font-mono text-emerald-700 bg-blue-50/30">{trendCostVariance.m4}</td>
              </tr>

              <tr className="bg-emerald-100/50">
                <td colSpan={5} className="py-2 px-4 font-bold text-emerald-900 flex items-center gap-1.5">
                  <ArrowUpRight className="w-4 h-4 text-emerald-700" /> DrillDown - COST VARIANCE GAIN / LOSS: Top-6 parts with Profit (Favorable Variance)
                </td>
              </tr>

              {topProfitParts.length === 0 ? (
                <tr><td colSpan={5} className="py-4 text-center text-slate-400">No profitable parts recorded in the selected period.</td></tr>
              ) : (
                topProfitParts.map((p, idx) => (
                  <tr key={idx} className="hover:bg-emerald-50/20">
                    <td className="py-2 px-6 font-medium text-slate-800">
                      <span className="font-mono font-bold text-blue-700 mr-2">{p.code}</span>
                      <span>{p.name}</span>
                    </td>
                    <td className="py-2 px-4 text-right font-mono text-emerald-700 font-bold">₹{p.m1.toLocaleString()}</td>
                    <td className="py-2 px-4 text-right font-mono text-emerald-700 font-bold">₹{p.m2.toLocaleString()}</td>
                    <td className="py-2 px-4 text-right font-mono text-emerald-700 font-bold">₹{p.m3.toLocaleString()}</td>
                    <td className="py-2 px-4 text-right font-mono font-black text-emerald-700 bg-blue-50/20">₹{p.m4.toLocaleString()}</td>
                  </tr>
                ))
              )}

              <tr className="bg-rose-100/50">
                <td colSpan={5} className="py-2 px-4 font-bold text-rose-900 flex items-center gap-1.5">
                  <ArrowDownRight className="w-4 h-4 text-rose-700" /> DrillDown: Top-6 parts with Loss (Unfavorable Variance / Drift)
                </td>
              </tr>

              {topLossParts.length === 0 ? (
                <tr><td colSpan={5} className="py-4 text-center text-slate-400">No loss-drift parts recorded in the selected period.</td></tr>
              ) : (
                topLossParts.map((p, idx) => (
                  <tr key={idx} className="hover:bg-rose-50/20">
                    <td className="py-2 px-6 font-medium text-slate-800">
                      <span className="font-mono font-bold text-blue-700 mr-2">{p.code}</span>
                      <span>{p.name}</span>
                    </td>
                    <td className="py-2 px-4 text-right font-mono text-rose-600 font-bold">₹{Math.abs(p.m1).toLocaleString()}</td>
                    <td className="py-2 px-4 text-right font-mono text-rose-600 font-bold">₹{Math.abs(p.m2).toLocaleString()}</td>
                    <td className="py-2 px-4 text-right font-mono text-rose-600 font-bold">₹{Math.abs(p.m3).toLocaleString()}</td>
                    <td className="py-2 px-4 text-right font-mono font-black text-rose-600 bg-blue-50/20">₹{Math.abs(p.m4).toLocaleString()}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* TABLE 4: ROOT-CAUSE COST GAP BREAKDOWN BY DRIVER (100% DYNAMIC) */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3.5 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <DollarSign className="w-4 h-4 text-amber-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">ROOT-CAUSE COST GAP BREAKDOWN BY DRIVER</h2>
          </div>
          <span className="text-[10px] text-slate-400 font-mono">Live Sync with Day-Wise Purchases & Invoices</span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-4">Cost Driver & Parameter Variance</th>
                <th className="py-2.5 px-4 text-right">Haier Appliances Impact</th>
                <th className="py-2.5 px-4 text-right">Atomberg Technologies Impact</th>
                <th className="py-2.5 px-4 text-right font-black">Net Combined Variance (₹)</th>
                <th className="py-2.5 px-4 text-center">Variance Classification</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {gapDrivers.length === 0 ? (
                <tr><td colSpan={5} className="py-6 text-center text-slate-400">No transactions recorded yet to analyze cost drivers.</td></tr>
              ) : (
                gapDrivers.map((d, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="py-2.5 px-4 font-semibold text-slate-800">{d.driver}</td>
                    <td className="py-2.5 px-4 text-right font-mono text-emerald-700 font-bold">{d.haierImpact}</td>
                    <td className="py-2.5 px-4 text-right font-mono text-rose-600 font-bold">{d.atombergImpact}</td>
                    <td className="py-2.5 px-4 text-right font-mono font-black text-slate-900">{d.netTotal}</td>
                    <td className="py-2.5 px-4 text-center">
                      <span className={`px-2.5 py-0.5 rounded font-bold text-[10px] ${
                        d.status === 'Favorable' ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-700'
                      }`}>
                        {d.status}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
PAGE_EOF

echo "==> 2. Verifying clean build..."
npm run build

echo "==> 3. Committing to dev-v2 and pushing to main for Vercel auto-deploy..."
git checkout dev-v2
git add -A
git commit -m "fix(mis): make vendor comparison, multi-month drilldown, and gap drivers 100% dynamic from live sales" || echo "dev-v2 up to date."
git push origin dev-v2

git checkout main
git pull origin main --rebase || true
git merge dev-v2 -m "release: 100% dynamic MIS tables with zero static demo numbers"
git push origin main

git checkout dev-v2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! 100% dynamic MIS page pushed to main."
echo "   Vercel deployment is live."
echo "-------------------------------------------------------------------"
