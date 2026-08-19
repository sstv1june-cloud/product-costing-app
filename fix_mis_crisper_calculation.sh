#!/usr/bin/env bash
set -e

echo "==> 1. Updating MIS Page with exact Masterbatch rate and machine conversion sync..."
cat << 'MIS_PAGE_EOF' > src/modules/module4-mis/MISIntelligencePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Search, Calendar, 
  Eye, FileSpreadsheet, Layers, ShieldCheck, CheckCircle2 
} from 'lucide-react';
import { globalStore, subscribeStore, getVendorBaselineData, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';

// Exact calculation matching Costing Engine and Edit Spec Modal
function calcMISPieceCost(item, isBaseline = false, targetDate = null) {
  const vendor = (item.vendor || 'Haier').trim();
  const isAtomberg = vendor.toLowerCase().includes('atomberg');
  const isCrisper = item.itemCode === '0060217978E';
  const params = item.parameters || {};

  const rmMapping = getActiveRmMapping(item.approvedRm || (isCrisper ? 'GPPS SC201LV' : 'ABS 300 Pre Colour'), vendor, targetDate);
  const mbMapping = getActiveMbMapping(vendor, targetDate);

  if (isAtomberg) {
    const rmBase = isBaseline 
      ? Number(rmMapping.approvedPrice || item.approvedRmRate || 140.0) 
      : Number(rmMapping.activeWaPrice || 135.83);
    const mbBase = isBaseline 
      ? Number(mbMapping.approvedMbPrice || item.masterbatchRate || 254.0) 
      : Number(mbMapping.activeMbPrice || 258.54);

    const rmLanded = rmBase + (rmBase * 0.01) + 1.50;
    const mbLanded = mbBase + (mbBase * 0.01) + 2.00;

    const mbPct = 0.04;
    const rmCombRate = rmLanded * (1.0 - mbPct) + mbLanded * mbPct;

    const partWt = Number(isBaseline ? (item.netWeight || 37) : (params.runningNetWeight ?? item.netWeight ?? 37));
    const runnerWt = Number(isBaseline ? (item.runnerWeight || 1) : (params.runningRunnerWeight ?? item.runnerWeight ?? 1));
    const grossWt = partWt + runnerWt;

    const rmCost = (grossWt / 1000.0) * rmCombRate;
    const bopCost = Number(isBaseline ? (item.bopCost || 0) : (params.runningBopCost ?? item.bopCost ?? 0));
    const rmBopCost = rmCost + bopCost;

    const tonnage = Number(isBaseline ? (item.machineTonnage || 200) : (params.runningTonnage ?? item.machineTonnage ?? 200));
    const shiftRate = 10.0 * tonnage;
    const cycleTime = Math.max(1, Number(isBaseline ? (item.cycleTimeApproved || item.cycleTime || 47) : (params.runningCycleTime ?? item.cycleTimeApproved ?? 47)));
    const efficiency = 0.90;
    const cavity = Number(isBaseline ? (item.cavity || 2) : (params.runningCavity ?? item.cavity ?? 2));

    const partsPerShift = (28800.0 / cycleTime) * efficiency * cavity;
    const processCost = partsPerShift > 0 ? (shiftRate / partsPerShift) : 0;

    const postOpCost = 1.73;
    const totalProcessCost = processCost + (0.03 * bopCost) + postOpCost;

    const profitOh = (rmCost + totalProcessCost) * 0.12;
    const inprocessRejection = (rmBopCost + totalProcessCost) * 0.04;
    const runnerRecovery = -25.0 * (runnerWt / 1000.0);
    const packingCost = 0.86;
    const transportCost = 0.62;
    const mouldMaint = 0.02 * totalProcessCost;

    const otherCost = profitOh + inprocessRejection + runnerRecovery + packingCost + transportCost + mouldMaint;
    const finalLanded = rmBopCost + totalProcessCost + otherCost;

    return Number(finalLanded.toFixed(2));
  } else {
    // Haier Engine with exact Masterbatch and 650T Conversion
    const rmRate = isBaseline 
      ? Number(rmMapping.approvedPrice || item.approvedRmRate || (isCrisper ? 103.08 : 130.00)) 
      : Number(rmMapping.activeWaPrice || (isCrisper ? 98.40 : 134.80));

    const netWeight = Number(isBaseline ? (item.netWeight || (isCrisper ? 485 : 197)) : (params.runningNetWeight ?? item.netWeight ?? (isCrisper ? 485 : 197)));
    const runnerWeight = Number(isBaseline ? (item.runnerWeight || (isCrisper ? 22 : 40)) : (params.runningRunnerWeight ?? item.runnerWeight ?? (isCrisper ? 22 : 40)));
    const cavity = Number(isBaseline ? (item.cavity || (isCrisper ? 1 : 2)) : (params.runningCavity ?? item.cavity ?? (isCrisper ? 1 : 2)));
    
    const mbPctVal = isCrisper ? 0.035 : (Number(item.masterbatchPct || 0) / 100);
    const mbRateVal = isCrisper ? 240.00 : Number(item.masterbatchRate || 0);

    const shotWeightPerPiece = ((netWeight * cavity) + runnerWeight) / cavity;
    const reconciliationWeight = shotWeightPerPiece * 1.01;

    const rawMaterialCost = (reconciliationWeight / 1000) * rmRate * Math.max(0, 1 - mbPctVal);
    const masterbatchCost = (reconciliationWeight / 1000) * mbRateVal * mbPctVal;
    const runnerCredit = (runnerWeight / cavity / 1000) * (rmRate * 0.25);
    const totalRmCost = (rawMaterialCost + masterbatchCost) - runnerCredit;

    const cycleTime = Number(isBaseline ? (item.cycleTimeApproved || item.cycleTime || (isCrisper ? 58 : 48)) : (params.runningCycleTime ?? (isCrisper ? 58 : 48)));
    const tonnage = Number(isBaseline ? (item.machineTonnage || (isCrisper ? 650 : 450)) : (params.runningTonnage ?? (isCrisper ? 650 : 450)));
    const shiftTariff = tonnage >= 650 ? 5760 : (tonnage <= 200 ? 2000 : 4600);

    const partsPerShift = ((28800 / cycleTime) * cavity) * 0.90;
    const conversionCost = partsPerShift > 0 ? (shiftTariff / partsPerShift) : 0;

    return Number((totalRmCost + conversionCost).toFixed(2));
  }
}

export default function MISIntelligencePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('All Vendors Combined');
  const [fromDate, setFromDate] = useState('2026-08-01');
  const [toDate, setToDate] = useState('2026-08-31');

  const rawBaselineList = getVendorBaselineData('ALL');

  const salesData = (globalStore.salesData || []).filter(s => {
    const vMatch = selectedVendor === 'All Vendors Combined' || selectedVendor === 'ALL' || s.vendor === selectedVendor;
    const dMatch = (!fromDate || s.invoiceDate >= fromDate) && (!toDate || s.invoiceDate <= toDate);
    return vMatch && dMatch;
  });

  const analyzedRows = useMemo(() => {
    return salesData.map(sale => {
      const part = rawBaselineList.find(p => p.itemCode === sale.itemCode) || {
        vendor: sale.vendor,
        itemCode: sale.itemCode,
        componentName: sale.componentName,
        approvedRm: sale.vendor === 'Atomberg' ? 'PP H110MA' : (sale.itemCode === '0060217978E' ? 'GPPS SC201LV' : 'ABS 300 Pre Colour'),
        masterbatchRate: sale.itemCode === '0060217978E' ? 240.00 : 0.0,
        masterbatchPct: sale.itemCode === '0060217978E' ? 3.5 : 0.0,
        machineTonnage: sale.itemCode === '0060217978E' ? 650 : (sale.vendor === 'Atomberg' ? 200 : 450)
      };

      const contractBaseline = calcMISPieceCost({ ...part, vendor: sale.vendor }, true, sale.invoiceDate);
      const actualUnitCost = calcMISPieceCost({ ...part, vendor: sale.vendor }, false, sale.invoiceDate);

      // Profit / Loss = Approved Baseline - Simulated Actual
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
  }, [salesData, rawBaselineList, selectedVendor]);

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
              <option value="All Vendors Combined">All Vendors Combined</option>
              {vendors.map(v => (
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

echo "==> 2. Restarting Vite Server cleanly..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Calculation pipeline fully synchronized across all 3 modules."
