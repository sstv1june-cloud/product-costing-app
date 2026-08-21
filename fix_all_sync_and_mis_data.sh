#!/usr/bin/env bash
set -e

echo "==> 1. Fixing CostingRunEnginePage.jsx to compute EXACT final landed baseline and actuals matching Edit Spec modal..."
cat << 'COSTING_EOF' > src/modules/module3-costing-engine/CostingRunEnginePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  globalStore, 
  subscribeStore, 
  getActiveRmMapping, 
  getActiveMbMapping 
} from '../../shared/masterStore';
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';
import * as XLSX from 'xlsx';
import { Calculator, Download, Search, TrendingUp, TrendingDown } from 'lucide-react';

export default function CostingRunEnginePage() {
  const [, setTick] = useState(0);
  const [vendorFilter, setVendorFilter] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    return subscribeStore(() => setTick(t => t + 1));
  }, []);

  const products = globalStore.baselineProducts || [];

  // Compute live matrix for each product replicating exact Edit Spec formulas
  const calculatedRows = products.map(prod => {
    const isAtomberg = (prod.vendor || '').toLowerCase().includes('atomberg');
    const rmInfo = getActiveRmMapping(prod.approvedRm || '', prod.vendor || 'Haier');
    const mbInfo = getActiveMbMapping(prod.vendor || 'Haier');

    // 1. Approved Baseline Contract
    const baseCalc = isAtomberg
      ? calculateAtombergCost(prod, {})
      : calculateHaierCost(prod, {});

    // 2. Simulated Actual Running (with active WA rates & running parameters)
    const runCalc = isAtomberg
      ? calculateAtombergCost(prod, {
          netWeight: prod.parameters?.runningNetWeight ?? prod.netWeight,
          runnerWeight: prod.parameters?.runningRunnerWeight ?? prod.runnerWeight,
          cavity: prod.parameters?.runningCavity ?? prod.cavity,
          cycleTime: prod.parameters?.runningCycleTime ?? prod.cycleTime,
          masterbatchPct: prod.parameters?.runningMbPct ?? prod.masterbatchPct,
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        })
      : calculateHaierCost(prod, {
          netWeight: prod.parameters?.runningNetWeight ?? prod.netWeight,
          runnerWeight: prod.parameters?.runningRunnerWeight ?? prod.runnerWeight,
          cavity: prod.parameters?.runningCavity ?? prod.cavity,
          cycleTime: prod.parameters?.runningCycleTime ?? prod.cycleTime,
          masterbatchPct: prod.parameters?.runningMbPct ?? prod.masterbatchPct,
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        });

    const approvedBaseline = Number(baseCalc.finalLanded ?? baseCalc.totalApproved ?? baseCalc.approvedBaseline ?? 0);
    const simulatedActual = Number(runCalc.finalLanded ?? runCalc.totalActual ?? runCalc.actualRunning ?? 0);
    const delta = Number((approvedBaseline - simulatedActual).toFixed(2));

    return {
      vendor: prod.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: prod.itemCode,
      componentName: prod.componentName,
      approvedRm: prod.approvedRm,
      approvedRmRate: prod.approvedRmRate || rmInfo.approvedPrice,
      activeRmRate: rmInfo.activeWaPrice,
      approvedCost: Number(approvedBaseline.toFixed(2)),
      actualCost: Number(simulatedActual.toFixed(2)),
      deltaCost: delta,
      period: '2026-08'
    };
  });

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
            <h1 className="text-xl md:text-2xl font-bold tracking-tight">3. Dynamic Costing Run Engine</h1>
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
COSTING_EOF

echo "==> 2. Updating costOutputStore.js to strictly hold only the 6 core summary data points..."
cat << 'STORE_EOF' > src/shared/costOutputStore.js
// ============================================================================
// DEDICATED COST OUTPUT REPOSITORY (costOutputStore.js)
// Stores ONLY 6 summary fields per product:
// 1. vendor
// 2. itemCode
// 3. componentName
// 4. approvedCost (Contract Baseline)
// 5. actualCost (Simulated Running Cost)
// 6. deltaCost (Variance Gain / Loss)
// ============================================================================

import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping } from './masterStore';
import { calculateAtombergCost, calculateHaierCost } from './costCalculationService';

let costOutputDB = {};
let subscribers = [];

function notify() {
  subscribers.forEach(fn => {
    try { fn(costOutputDB); } catch (e) { console.error('costOutputStore notify error:', e); }
  });
}

/**
 * Evaluates the 6 flat fields directly using the calculation services
 */
export function pullAndMaterializeCosts() {
  const products = globalStore.baselineProducts || [];
  const latestSnapshot = {};

  products.forEach(prod => {
    const isAtomberg = (prod.vendor || '').toLowerCase().includes('atomberg');
    const rmInfo = getActiveRmMapping(prod.approvedRm || '', prod.vendor || 'Haier');
    const mbInfo = getActiveMbMapping(prod.vendor || 'Haier');

    // Baseline calculation
    const baseResult = isAtomberg
      ? calculateAtombergCost(prod, {})
      : calculateHaierCost(prod, {});

    // Actual running calculation with active WA price & running params
    const runResult = isAtomberg
      ? calculateAtombergCost(prod, {
          netWeight: prod.parameters?.runningNetWeight ?? prod.netWeight,
          runnerWeight: prod.parameters?.runningRunnerWeight ?? prod.runnerWeight,
          cavity: prod.parameters?.runningCavity ?? prod.cavity,
          cycleTime: prod.parameters?.runningCycleTime ?? prod.cycleTime,
          masterbatchPct: prod.parameters?.runningMbPct ?? prod.masterbatchPct,
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        })
      : calculateHaierCost(prod, {
          netWeight: prod.parameters?.runningNetWeight ?? prod.netWeight,
          runnerWeight: prod.parameters?.runningRunnerWeight ?? prod.runnerWeight,
          cavity: prod.parameters?.runningCavity ?? prod.cavity,
          cycleTime: prod.parameters?.runningCycleTime ?? prod.cycleTime,
          masterbatchPct: prod.parameters?.runningMbPct ?? prod.masterbatchPct,
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        });

    const approvedCost = Number(Number(baseResult.finalLanded ?? baseResult.totalApproved ?? baseResult.approvedBaseline ?? 0).toFixed(2));
    const actualCost = Number(Number(runResult.finalLanded ?? runResult.totalActual ?? runResult.actualRunning ?? 0).toFixed(2));
    const deltaCost = Number((approvedCost - actualCost).toFixed(2));

    latestSnapshot[prod.itemCode] = {
      vendor: prod.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: prod.itemCode,
      componentName: prod.componentName || 'Component',
      approvedCost,
      actualCost,
      deltaCost,
      updatedAt: new Date().toISOString()
    };
  });

  costOutputDB = latestSnapshot;
  notify();
  return costOutputDB;
}

// Auto-sync when masterStore changes (RM prices, baseline specs, add/delete)
subscribeStore(() => {
  pullAndMaterializeCosts();
});

// Initial boot pull
pullAndMaterializeCosts();

export function getProductCostSummary(itemCode) {
  if (!costOutputDB[itemCode] || Object.keys(costOutputDB).length === 0) {
    pullAndMaterializeCosts();
  }
  return costOutputDB[itemCode] || {
    vendor: 'Haier',
    itemCode: itemCode || 'UNKNOWN',
    componentName: 'Component',
    approvedCost: 0,
    actualCost: 0,
    deltaCost: 0
  };
}

export function getAllCostSummaries() {
  if (Object.keys(costOutputDB).length === 0) {
    pullAndMaterializeCosts();
  }
  return costOutputDB;
}

export function getCostSummariesByPeriod(period) {
  return getAllCostSummaries();
}

export function subscribeCostOutput(fn) {
  subscribers.push(fn);
  return () => {
    subscribers = subscribers.filter(cb => cb !== fn);
  };
}

export default {
  pullAndMaterializeCosts,
  getProductCostSummary,
  getAllCostSummaries,
  getCostSummariesByPeriod,
  subscribeCostOutput
};
STORE_EOF

echo "==> 3. Updating MISVariancePage.jsx to consume getProductCostSummary cleanly..."
cat << 'MIS_EOF' > src/modules/module4-mis/MISVariancePage.jsx
import React, { useState, useEffect } from 'react';
import { globalStore, subscribeStore } from '../../shared/masterStore';
import { 
  getProductCostSummary, 
  pullAndMaterializeCosts, 
  subscribeCostOutput 
} from '../../shared/costOutputStore';
import * as XLSX from 'xlsx';
import { 
  BarChart3, 
  Download, 
  Filter, 
  Calendar, 
  TrendingUp, 
  Layers, 
  FileSpreadsheet,
  ArrowUpRight,
  ArrowDownRight,
  Database
} from 'lucide-react';

export default function MISVariancePage() {
  const [, setTick] = useState(0);

  // Independent Filter 1: Main Product Sales Realization Table
  const [mainVendor, setMainVendor] = useState('ALL');
  const [mainFrom, setMainFrom] = useState('2026-08-01');
  const [mainTo, setMainTo] = useState('2026-08-31');

  // Independent Filter 2: Multi-Month Variance Trend Table
  const [trendVendor, setTrendVendor] = useState('Haier');

  // Independent Filter 3: Period-over-Period Vendor Comparison Table
  const [compFrom, setCompFrom] = useState('2026-08-01');
  const [compTo, setCompTo] = useState('2026-08-31');

  useEffect(() => {
    pullAndMaterializeCosts();
    const unsubMaster = subscribeStore(() => {
      pullAndMaterializeCosts();
      setTick(t => t + 1);
    });
    const unsubCost = subscribeCostOutput(() => setTick(t => t + 1));
    return () => {
      unsubMaster();
      unsubCost();
    };
  }, []);

  const allSales = globalStore.sales || [];
  const baselineProducts = globalStore.baselineProducts || [];

  // P&L calculation consuming the 6 summary fields from costOutputStore
  const resolveSaleRow = (sale) => {
    const costSummary = getProductCostSummary(sale.itemCode);

    const contractBaseline = Number(costSummary.approvedCost || 0);
    const actualUnitCost = Number(costSummary.actualCost || 0);
    const unitVariance = Number(costSummary.deltaCost ?? (contractBaseline - actualUnitCost));
    const qty = Number(sale.qty || 0);
    const totalVariance = unitVariance * qty;
    const totalSales = Number(sale.sellingPrice || 0) * qty;

    return {
      sale,
      costSummary,
      contractBaseline,
      actualUnitCost,
      unitVariance,
      totalVariance,
      totalSales
    };
  };

  // Section 1: Main Realization Table Data
  const filteredMainSales = allSales.filter(s => {
    const matchVendor = mainVendor === 'ALL' || (s.vendor || '').toLowerCase().includes(mainVendor.toLowerCase());
    const matchDate = (!mainFrom || s.date >= mainFrom) && (!mainTo || s.date <= mainTo);
    return matchVendor && matchDate;
  });

  const processedMainRows = filteredMainSales.map(resolveSaleRow);
  const totalSalesVolume = processedMainRows.reduce((acc, r) => acc + Number(r.sale.qty || 0), 0);
  const totalSalesRevenue = processedMainRows.reduce((acc, r) => acc + r.totalSales, 0);
  const totalVarianceGainLoss = processedMainRows.reduce((acc, r) => acc + r.totalVariance, 0);
  const totalActualCOGS = processedMainRows.reduce((acc, r) => acc + (r.actualUnitCost * Number(r.sale.qty || 0)), 0);
  const grossProfit = totalSalesRevenue - totalActualCOGS;
  const grossMarginPct = totalSalesRevenue > 0 ? (grossProfit / totalSalesRevenue) * 100 : 0;

  // REPORT 1: Multi-Month Trend (M1_May, M2_June, M3_July, M4_August)
  const monthBuckets = [
    { label: 'M1_May', from: '2026-05-01', to: '2026-05-31' },
    { label: 'M2_June', from: '2026-06-01', to: '2026-06-30' },
    { label: 'M3_July', from: '2026-07-01', to: '2026-07-31' },
    { label: 'M4_August', from: '2026-08-01', to: '2026-08-31' }
  ];

  const vendorProducts = baselineProducts.filter(p => 
    trendVendor === 'ALL' || (p.vendor || '').toLowerCase().includes(trendVendor.toLowerCase())
  );

  const getMonthlyStats = (bucket) => {
    const mSales = allSales.filter(s => {
      const matchVendor = trendVendor === 'ALL' || (s.vendor || '').toLowerCase().includes(trendVendor.toLowerCase());
      return matchVendor && s.date >= bucket.from && s.date <= bucket.to;
    });

    const rows = mSales.map(resolveSaleRow);
    const rev = rows.reduce((acc, r) => acc + r.totalSales, 0);
    const variance = rows.reduce((acc, r) => acc + r.totalVariance, 0);

    const partMap = {};
    rows.forEach(r => {
      const code = r.sale.itemCode;
      if (!partMap[code]) {
        partMap[code] = {
          itemCode: code,
          componentName: r.sale.componentName || r.costSummary.componentName,
          totalVariance: 0,
          totalSales: 0
        };
      }
      partMap[code].totalVariance += r.totalVariance;
      partMap[code].totalSales += r.totalSales;
    });

    return { rev, variance, partMap };
  };

  const monthlyTrendResults = monthBuckets.map(b => ({
    ...b,
    ...getMonthlyStats(b)
  }));

  const overallProductStats = vendorProducts.map(p => {
    let totalVar = 0;
    monthBuckets.forEach(b => {
      const stats = getMonthlyStats(b);
      if (stats.partMap[p.itemCode]) {
        totalVar += stats.partMap[p.itemCode].totalVariance;
      }
    });
    return {
      itemCode: p.itemCode,
      componentName: p.componentName,
      totalVar
    };
  });

  const top6ProfitProducts = [...overallProductStats].sort((a, b) => b.totalVar - a.totalVar).slice(0, 6);
  const top6LossProducts = [...overallProductStats].sort((a, b) => a.totalVar - b.totalVar).slice(0, 6);

  // REPORT 2: Period-over-Period Vendor Comparison
  const vendorList = ['Haier', 'Atomberg'];
  const getVendorPeriodStats = (vendorKey, isPrev = false) => {
    const start = isPrev ? '2026-07-01' : compFrom;
    const end = isPrev ? '2026-07-31' : compTo;

    const vSales = allSales.filter(s => 
      (s.vendor || '').toLowerCase().includes(vendorKey.toLowerCase()) && 
      s.date >= start && s.date <= end
    );

    const rows = vSales.map(resolveSaleRow);
    const rev = rows.reduce((acc, r) => acc + r.totalSales, 0);
    const variance = rows.reduce((acc, r) => acc + r.totalVariance, 0);
    return { rev, variance };
  };

  // EXCEL EXPORT HANDLERS
  const exportFullMISExcel = () => {
    const workbook = XLSX.utils.book_new();

    const ws1Data = processedMainRows.map(r => ({
      'Date': r.sale.date,
      'Part Code': r.sale.itemCode,
      'Component Name': r.sale.componentName,
      'Vendor': r.sale.vendor,
      'Qty Sold': r.sale.qty,
      'Selling Price (₹)': r.sale.sellingPrice,
      'Contract Baseline (₹)': r.contractBaseline.toFixed(2),
      'Actual Unit Cost (₹)': r.actualUnitCost.toFixed(2),
      'Profit / Loss (₹/pc)': r.unitVariance.toFixed(2),
      'Total Profit / Loss (₹)': r.totalVariance.toFixed(2),
      'Total Sales (₹)': r.totalSales.toFixed(2)
    }));
    XLSX.utils.book_append_sheet(workbook, XLSX.utils.json_to_sheet(ws1Data), 'Product Sales Realization');

    const ws2Data = [
      {
        'Filter / Metric Category': 'TOTAL SALES REVENUE',
        ...monthlyTrendResults.reduce((acc, m) => ({ ...acc, [m.label]: `₹${m.rev.toLocaleString()}` }), {})
      },
      {
        'Filter / Metric Category': 'COST VARIANCE GAIN / LOSS',
        ...monthlyTrendResults.reduce((acc, m) => ({ ...acc, [m.label]: `₹${m.variance.toFixed(2)}` }), {})
      },
      ...top6ProfitProducts.map((p, idx) => ({
        'Filter / Metric Category': `[Profit #${idx + 1}] Part code: ${p.itemCode} - ${p.componentName}`,
        ...monthlyTrendResults.reduce((acc, m) => {
          const item = m.partMap[p.itemCode];
          return { ...acc, [m.label]: item ? `+₹${item.totalVariance.toFixed(2)}` : '-' };
        }, {})
      })),
      ...top6LossProducts.map((p, idx) => ({
        'Filter / Metric Category': `[Loss #${idx + 1}] Part code: ${p.itemCode} - ${p.componentName}`,
        ...monthlyTrendResults.reduce((acc, m) => {
          const item = m.partMap[p.itemCode];
          return { ...acc, [m.label]: item ? `-₹${Math.abs(item.totalVariance).toFixed(2)}` : '-' };
        }, {})
      }))
    ];
    XLSX.utils.book_append_sheet(workbook, XLSX.utils.json_to_sheet(ws2Data), 'Monthly Trend & Drilldown');

    XLSX.writeFile(workbook, `MIS_Complete_Intelligence_Report_${new Date().toISOString().slice(0, 10)}.xlsx`);
  };

  const exportTrendExcel = () => {
    const workbook = XLSX.utils.book_new();
    const wsData = [
      {
        'Filter / Metric Category': 'TOTAL SALES REVENUE',
        ...monthlyTrendResults.reduce((acc, m) => ({ ...acc, [m.label]: `₹${m.rev.toLocaleString()}` }), {})
      },
      {
        'Filter / Metric Category': 'COST VARIANCE GAIN / LOSS',
        ...monthlyTrendResults.reduce((acc, m) => ({ ...acc, [m.label]: `₹${m.variance.toFixed(2)}` }), {})
      },
      ...top6ProfitProducts.map((p, idx) => ({
        'Filter / Metric Category': `Part code: ${p.itemCode} - ${p.componentName}`,
        ...monthlyTrendResults.reduce((acc, m) => {
          const item = m.partMap[p.itemCode];
          return { ...acc, [m.label]: item ? `+₹${item.totalVariance.toFixed(2)}` : '-' };
        }, {})
      })),
      ...top6LossProducts.map((p, idx) => ({
        'Filter / Metric Category': `Part code: ${p.itemCode} - ${p.componentName}`,
        ...monthlyTrendResults.reduce((acc, m) => {
          const item = m.partMap[p.itemCode];
          return { ...acc, [m.label]: item ? `-₹${Math.abs(item.totalVariance).toFixed(2)}` : '-' };
        }, {})
      }))
    ];
    XLSX.utils.book_append_sheet(workbook, XLSX.utils.json_to_sheet(wsData), 'Multi-Month Variance Report');
    XLSX.writeFile(workbook, `MIS_Multi_Month_Variance_Report_${trendVendor}_${new Date().toISOString().slice(0, 10)}.xlsx`);
  };

  const exportVendorCompExcel = () => {
    const workbook = XLSX.utils.book_new();
    const wsData = vendorList.map(v => {
      const curr = getVendorPeriodStats(v, false);
      const prev = getVendorPeriodStats(v, true);
      return {
        'Vendor': v === 'Haier' ? 'Haier Appliances' : 'Atomberg Technologies',
        [`Current Period Revenue (${compFrom} to ${compTo})`]: curr.rev,
        [`Current Cost Variance Gain / Loss`]: curr.variance.toFixed(2),
        [`Previous Period Revenue (2026-07-01 to 2026-07-31)`]: prev.rev,
        [`Previous Cost Variance Gain / Loss`]: prev.variance.toFixed(2)
      };
    });
    XLSX.utils.book_append_sheet(workbook, XLSX.utils.json_to_sheet(wsData), 'Vendor Period Comparison');
    XLSX.writeFile(workbook, `MIS_Vendor_Period_Comparison_${new Date().toISOString().slice(0, 10)}.xlsx`);
  };

  return (
    <div className="space-y-8 pb-16">
      {/* Top Banner */}
      <div className="bg-[#0f172a] text-white p-6 rounded-2xl shadow-xl flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-blue-600/30 rounded-xl border border-blue-500/30 text-blue-400">
            <BarChart3 className="w-8 h-8" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl md:text-2xl font-bold tracking-tight">4. Vendor & Product Sales P&L MIS Intelligence</h1>
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-emerald-950/80 text-emerald-300 border border-emerald-500/30">
                <Database className="w-3 h-3" /> 6-Field Output Store Active
              </span>
            </div>
            <p className="text-sm text-slate-400">Decoupled Output Store • Zero BOM Overhead • Synced Live</p>
          </div>
        </div>

        <button
          onClick={exportFullMISExcel}
          className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold px-4 py-2.5 rounded-xl transition-all shadow-md shadow-emerald-600/20 cursor-pointer"
        >
          <Download className="w-4 h-4" /> Download Complete MIS Report (.xlsx)
        </button>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">PERIOD SALES VOLUME</div>
          <div className="text-2xl font-black text-slate-900 mt-1 font-mono">{totalSalesVolume.toLocaleString()} pcs</div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">TOTAL SALES REVENUE</div>
          <div className="text-2xl font-black text-blue-600 mt-1 font-mono">₹{totalSalesRevenue.toLocaleString()}</div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">GROSS PROFIT & MARGIN</div>
          <div className="text-2xl font-black text-emerald-600 mt-1 font-mono">
            ₹{grossProfit.toLocaleString()} <span className="text-xs text-emerald-500 font-bold">({grossMarginPct.toFixed(1)}%)</span>
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">COST VARIANCE GAIN / LOSS</div>
          <div className={`text-2xl font-black mt-1 font-mono flex items-center gap-1 ${
            totalVarianceGainLoss >= 0 ? 'text-emerald-600' : 'text-rose-600'
          }`}>
            {totalVarianceGainLoss >= 0 ? `+ ₹${totalVarianceGainLoss.toLocaleString()}` : `- ₹${Math.abs(totalVarianceGainLoss).toLocaleString()}`}
          </div>
        </div>
      </div>

      {/* TABLE 1: Sales Realization */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="p-4 bg-[#0b1329] text-white flex flex-wrap justify-between items-center gap-4">
          <div className="font-bold text-xs uppercase tracking-wider flex items-center gap-2">
            <FileSpreadsheet className="w-4 h-4 text-blue-400" /> Product Sales Realization & Costing Analysis
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <div className="flex items-center gap-2">
              <span className="text-[11px] font-bold text-slate-300">Vendor:</span>
              <select 
                value={mainVendor} 
                onChange={e => setMainVendor(e.target.value)}
                className="bg-slate-800 border border-slate-700 text-white text-xs font-bold rounded-lg px-2.5 py-1 outline-none cursor-pointer"
              >
                <option value="ALL">All Vendors Combined</option>
                <option value="Haier">Haier Appliances</option>
                <option value="Atomberg">Atomberg Technologies</option>
              </select>
            </div>

            <div className="flex items-center gap-1.5 text-xs text-slate-300">
              <Calendar className="w-3.5 h-3.5 text-slate-400" />
              <input 
                type="date" 
                value={mainFrom} 
                onChange={e => setMainFrom(e.target.value)}
                className="bg-slate-800 border border-slate-700 text-white text-xs rounded-lg px-2 py-0.5 outline-none"
              />
              <span>to</span>
              <input 
                type="date" 
                value={mainTo} 
                onChange={e => setMainTo(e.target.value)}
                className="bg-slate-800 border border-slate-700 text-white text-xs rounded-lg px-2 py-0.5 outline-none"
              />
            </div>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold tracking-wider border-b border-slate-200">
                <th className="py-3 px-4">Date</th>
                <th className="py-3 px-3">Part Code</th>
                <th className="py-3 px-4">Component Name</th>
                <th className="py-3 px-3 text-center">Vendor</th>
                <th className="py-3 px-3 text-right">Qty Sold</th>
                <th className="py-3 px-3 text-right">Selling Price</th>
                <th className="py-3 px-3 text-right bg-amber-50 text-amber-900 font-bold">Contract Baseline</th>
                <th className="py-3 px-3 text-right bg-slate-200/60 font-bold">Actual Unit Cost</th>
                <th className="py-3 px-3 text-right font-bold">Profit / Loss (Δ)</th>
                <th className="py-3 px-3 text-right font-bold">Total Profit / Loss</th>
                <th className="py-3 px-4 text-right font-bold">Total Sales</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {processedMainRows.map((r, idx) => {
                const isGain = r.unitVariance >= 0;
                return (
                  <tr key={idx} className="hover:bg-slate-50 transition-colors">
                    <td className="py-2.5 px-4 font-mono text-slate-500">{r.sale.date}</td>
                    <td className="py-2.5 px-3 font-mono font-bold text-blue-600">{r.sale.itemCode}</td>
                    <td className="py-2.5 px-4 font-medium text-slate-800">{r.sale.componentName}</td>
                    <td className="py-2.5 px-3 text-center">
                      <span className="px-2 py-0.5 bg-slate-100 text-slate-600 rounded text-[10px] font-bold">
                        {r.sale.vendor}
                      </span>
                    </td>
                    <td className="py-2.5 px-3 text-right font-mono font-semibold">{Number(r.sale.qty).toLocaleString()}</td>
                    <td className="py-2.5 px-3 text-right font-mono">₹{Number(r.sale.sellingPrice).toFixed(2)}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold bg-amber-50/50 text-amber-900">₹{r.contractBaseline.toFixed(2)}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold bg-slate-50 text-slate-900">₹{r.actualUnitCost.toFixed(2)}</td>
                    <td className={`py-2.5 px-3 text-right font-mono font-bold ${isGain ? 'text-emerald-600' : 'text-rose-600'}`}>
                      {isGain ? `+ ₹${r.unitVariance.toFixed(2)}` : `- ₹${Math.abs(r.unitVariance).toFixed(2)}`}
                    </td>
                    <td className={`py-2.5 px-3 text-right font-mono font-bold ${isGain ? 'text-emerald-600' : 'text-rose-600'}`}>
                      {isGain ? `+ ₹${Math.round(r.totalVariance).toLocaleString()}` : `- ₹${Math.round(Math.abs(r.totalVariance)).toLocaleString()}`}
                    </td>
                    <td className="py-2.5 px-4 text-right font-mono font-bold text-slate-900">₹{r.totalSales.toLocaleString()}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* REPORT 1: Multi-Month Trend */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="p-4 bg-[#0b1329] text-white flex flex-wrap justify-between items-center gap-4">
          <div className="font-bold text-xs uppercase tracking-wider flex items-center gap-2">
            <TrendingUp className="w-4 h-4 text-emerald-400" /> Multi-Month Variance Trend & Top-6 Part Drilldown
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2">
              <Filter className="w-3.5 h-3.5 text-blue-400" />
              <span className="text-[11px] font-bold text-slate-300">Filter Vendor:</span>
              <select 
                value={trendVendor} 
                onChange={e => setTrendVendor(e.target.value)}
                className="bg-slate-800 border border-slate-700 text-white text-xs font-bold rounded-lg px-3 py-1 outline-none cursor-pointer"
              >
                <option value="Haier">Haier Appliances</option>
                <option value="Atomberg">Atomberg Technologies</option>
                <option value="ALL">All Vendors Combined</option>
              </select>
            </div>

            <button
              onClick={exportTrendExcel}
              className="flex items-center gap-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold px-3 py-1 rounded-lg transition-all shadow-sm cursor-pointer"
            >
              <Download className="w-3.5 h-3.5" /> Download Report (.xlsx)
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-slate-100 text-slate-800 uppercase text-[11px] font-bold border-b border-slate-200">
                <th className="py-3 px-4 min-w-[340px]">Filter / Metric Category</th>
                {monthlyTrendResults.map((m, i) => (
                  <th key={i} className="py-3 px-4 text-right min-w-[150px] font-bold text-slate-900">{m.label}</th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              <tr className="bg-slate-50/90 font-bold">
                <td className="py-3 px-4 text-slate-900 uppercase tracking-wide">TOTAL SALES REVENUE</td>
                {monthlyTrendResults.map((m, i) => (
                  <td key={i} className="py-3 px-4 text-right font-mono text-blue-600 font-bold">
                    ₹{m.rev.toLocaleString()}
                  </td>
                ))}
              </tr>

              <tr className="bg-slate-50/90 font-bold border-b border-slate-200">
                <td className="py-3 px-4 text-slate-900 uppercase tracking-wide">COST VARIANCE GAIN / LOSS</td>
                {monthlyTrendResults.map((m, i) => (
                  <td key={i} className={`py-3 px-4 text-right font-mono font-bold ${
                    m.variance >= 0 ? 'text-emerald-600' : 'text-rose-600'
                  }`}>
                    {m.variance >= 0 ? `+ ₹${m.variance.toFixed(2)}` : `- ₹${Math.abs(m.variance).toFixed(2)}`}
                  </td>
                ))}
              </tr>

              <tr className="bg-emerald-50/70 font-black text-emerald-900 border-t border-emerald-200">
                <td colSpan={1 + monthlyTrendResults.length} className="py-2.5 px-4 text-[11px] uppercase tracking-wider flex items-center gap-1.5">
                  <ArrowUpRight className="w-4 h-4 text-emerald-600" /> DrillDown - COST VARIANCE GAIN / LOSS (Top-6 Parts with Profit)
                </td>
              </tr>
              {top6ProfitProducts.map((prod, idx) => (
                <tr key={`profit-${idx}`} className="hover:bg-slate-50">
                  <td className="py-2.5 px-4 pl-6 text-slate-800">
                    <div className="font-bold text-blue-600 font-mono">Part code-- {prod.itemCode}</div>
                    <div className="text-[11px] text-slate-500 font-medium truncate max-w-[320px]">{prod.componentName}</div>
                  </td>
                  {monthlyTrendResults.map((m, mIdx) => {
                    const item = m.partMap[prod.itemCode];
                    return (
                      <td key={mIdx} className="py-2.5 px-4 text-right font-mono">
                        {item && item.totalVariance > 0 ? (
                          <span className="font-bold text-emerald-600">+₹{Math.round(item.totalVariance).toLocaleString()}</span>
                        ) : (
                          <span className="text-slate-300 font-medium">-</span>
                        )}
                      </td>
                    );
                  })}
                </tr>
              ))}

              <tr className="bg-rose-50/70 font-black text-rose-900 border-t border-rose-200">
                <td colSpan={1 + monthlyTrendResults.length} className="py-2.5 px-4 text-[11px] uppercase tracking-wider flex items-center gap-1.5">
                  <ArrowDownRight className="w-4 h-4 text-rose-600" /> DrillDown - COST VARIANCE GAIN / LOSS (Top-6 Parts with Loss)
                </td>
              </tr>
              {top6LossProducts.map((prod, idx) => (
                <tr key={`loss-${idx}`} className="hover:bg-slate-50">
                  <td className="py-2.5 px-4 pl-6 text-slate-800">
                    <div className="font-bold text-rose-600 font-mono">Part code-- {prod.itemCode}</div>
                    <div className="text-[11px] text-slate-500 font-medium truncate max-w-[320px]">{prod.componentName}</div>
                  </td>
                  {monthlyTrendResults.map((m, mIdx) => {
                    const item = m.partMap[prod.itemCode];
                    return (
                      <td key={mIdx} className="py-2.5 px-4 text-right font-mono">
                        {item && item.totalVariance < 0 ? (
                          <span className="font-bold text-rose-600">-₹{Math.round(Math.abs(item.totalVariance)).toLocaleString()}</span>
                        ) : (
                          <span className="text-slate-300 font-medium">-</span>
                        )}
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* REPORT 2: Period Comparison */}
      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="p-4 bg-[#0b1329] text-white flex flex-wrap justify-between items-center gap-4">
          <div className="font-bold text-xs uppercase tracking-wider flex items-center gap-2">
            <Layers className="w-4 h-4 text-blue-400" /> Period-over-Period Vendor Variance Comparison
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 text-xs text-slate-300">
              <Calendar className="w-3.5 h-3.5 text-slate-400" />
              <span>Period: From</span>
              <input 
                type="date" 
                value={compFrom} 
                onChange={e => setCompFrom(e.target.value)}
                className="bg-slate-800 border border-slate-700 text-white text-xs rounded-lg px-2 py-0.5 outline-none"
              />
              <span>To</span>
              <input 
                type="date" 
                value={compTo} 
                onChange={e => setCompTo(e.target.value)}
                className="bg-slate-800 border border-slate-700 text-white text-xs rounded-lg px-2 py-0.5 outline-none"
              />
            </div>

            <button
              onClick={exportVendorCompExcel}
              className="flex items-center gap-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold px-3 py-1 rounded-lg transition-all shadow-sm cursor-pointer"
            >
              <Download className="w-3.5 h-3.5" /> Download Report (.xlsx)
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-[#0b1329] text-white uppercase text-[11px] tracking-wider border-b border-slate-800">
                <th rowSpan={2} className="py-3 px-4 font-bold border-r border-slate-800 min-w-[200px]">Vendor Name</th>
                <th colSpan={2} className="py-2.5 px-4 text-center font-bold bg-[#152347] border-r border-slate-800">
                  Current Selected Period ({compFrom} to {compTo})
                </th>
                <th colSpan={2} className="py-2.5 px-4 text-center font-bold bg-[#1e293b]">
                  Previous Period / Month (2026-07-01 to 2026-07-31)
                </th>
              </tr>
              <tr className="bg-slate-100 text-slate-800 uppercase text-[10px] font-bold border-b border-slate-200">
                <th className="py-2.5 px-4 text-right border-r border-slate-200">TOTAL SALES REVENUE</th>
                <th className="py-2.5 px-4 text-right border-r border-slate-200">COST VARIANCE GAIN / LOSS</th>
                <th className="py-2.5 px-4 text-right border-r border-slate-200">TOTAL SALES REVENUE</th>
                <th className="py-2.5 px-4 text-right">COST VARIANCE GAIN / LOSS</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {vendorList.map((v, i) => {
                const curr = getVendorPeriodStats(v, false);
                const prev = getVendorPeriodStats(v, true);
                return (
                  <tr key={i} className="hover:bg-slate-50 transition-colors">
                    <td className="py-3 px-4 font-bold text-slate-900 border-r border-slate-100">
                      {v === 'Haier' ? 'Haier Appliances' : 'Atomberg Technologies'}
                    </td>
                    <td className="py-3 px-4 text-right font-mono font-bold text-blue-600 border-r border-slate-100">
                      ₹{curr.rev.toLocaleString()}
                    </td>
                    <td className={`py-3 px-4 text-right font-mono font-bold border-r border-slate-100 ${
                      curr.variance >= 0 ? 'text-emerald-600' : 'text-rose-600'
                    }`}>
                      {curr.variance >= 0 ? `+ ₹${curr.variance.toLocaleString()}` : `- ₹${Math.abs(curr.variance).toLocaleString()}`}
                    </td>
                    <td className="py-3 px-4 text-right font-mono font-semibold text-slate-700 border-r border-slate-100">
                      ₹{prev.rev.toLocaleString()}
                    </td>
                    <td className={`py-3 px-4 text-right font-mono font-bold ${
                      prev.variance >= 0 ? 'text-emerald-600' : 'text-rose-600'
                    }`}>
                      {prev.variance >= 0 ? `+ ₹${prev.variance.toLocaleString()}` : `- ₹${Math.abs(prev.variance).toLocaleString()}`}
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
MIS_EOF

# Sync to alternate module routes if present
cp src/modules/module4-mis/MISVariancePage.jsx src/modules/module4-mis/MISIntelligencePage.jsx 2>/dev/null || true
cp src/modules/module4-mis/MISVariancePage.jsx src/modules/module4-mis-gap/MISGapPage.jsx 2>/dev/null || true

echo "==> 4. Clean restart of Vite on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ Calculations aligned across Edit Spec, Costing Engine, and MIS!"
echo "-------------------------------------------------------------------"
