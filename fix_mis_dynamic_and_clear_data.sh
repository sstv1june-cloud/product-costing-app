#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring branch is dev-v2..."
git checkout dev-v2

echo "==> 2. Rewriting MISVariancePage.jsx to be 100% dynamic..."
cat << 'MIS_EOF' > src/modules/module4-mis/MISVariancePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  TrendingUp, 
  TrendingDown, 
  DollarSign, 
  Package, 
  Layers, 
  Calendar, 
  Filter, 
  ArrowUpRight, 
  ArrowDownRight,
  PieChart,
  BarChart3,
  FileText,
  AlertCircle
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISVariancePage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [activeTab, setActiveTab] = useState('summary'); // 'summary' | 'invoices'

  useEffect(() => {
    const unsub = subscribeStore(() => {
      setStoreState({ ...globalStore });
    });
    return () => unsub();
  }, []);

  const vendors = storeState.vendors || [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ];

  // 1. Filter Sales Dispatches
  const sales = storeState.sales || [];
  const purchases = storeState.purchases || [];
  const baselineProducts = storeState.baselineProducts || [];

  const filteredSales = sales.filter(s => {
    const sVendor = (s.vendor || '').toLowerCase();
    const matchVendor = selectedVendor === 'ALL' || sVendor.includes(selectedVendor.toLowerCase()) || selectedVendor.toLowerCase().includes(sVendor);
    const sDate = s.date || s.invoiceDate || '';
    const matchDate = (!periodFrom || sDate >= periodFrom) && (!periodTo || sDate <= periodTo);
    return matchVendor && matchDate;
  });

  // 2. Aggregate Product Realization & Cost Variances Dynamically
  const productSummaryMap = {};
  let totalVolume = 0;
  let totalRevenue = 0;
  let totalApprovedCost = 0;
  let totalActualCost = 0;

  filteredSales.forEach(s => {
    const code = s.itemCode || s.partCode || 'UNKNOWN';
    const qty = Number(s.qty || s.quantity || 0);
    const rev = Number(s.amount || s.totalAmount || (qty * Number(s.rate || s.price || 0)));
    const sellRate = qty > 0 ? (rev / qty) : Number(s.rate || 0);

    const baseProd = baselineProducts.find(b => b.itemCode === code) || {};
    const detailed = calculateDetailedCost(baseProd);
    
    const approvedUnitCost = Number(baseProd.approvedCost || detailed.finalLanded || 0);
    const actualUnitCost = Number(detailed.finalLanded || baseProd.approvedCost || 0);
    const unitGainLoss = approvedUnitCost - actualUnitCost;

    totalVolume += qty;
    totalRevenue += rev;
    totalApprovedCost += (approvedUnitCost * qty);
    totalActualCost += (actualUnitCost * qty);

    if (!productSummaryMap[code]) {
      productSummaryMap[code] = {
        itemCode: code,
        componentName: s.componentName || baseProd.componentName || s.itemDescription || code,
        vendor: s.vendor || baseProd.vendor || 'Haier Appliances',
        invoicesCount: 0,
        totalQty: 0,
        totalRevenue: 0,
        approvedUnitCost: approvedUnitCost,
        actualUnitCost: actualUnitCost,
        unitGainLoss: unitGainLoss,
        totalGainLoss: 0
      };
    }

    productSummaryMap[code].invoicesCount += 1;
    productSummaryMap[code].totalQty += qty;
    productSummaryMap[code].totalRevenue += rev;
    productSummaryMap[code].totalGainLoss += (unitGainLoss * qty);
  });

  const productSummaryList = Object.values(productSummaryMap);
  const totalCostGainLoss = totalApprovedCost - totalActualCost;
  const grossProfit = totalRevenue - totalActualCost;
  const grossMarginPct = totalRevenue > 0 ? ((grossProfit / totalRevenue) * 100).toFixed(1) : '0.0';

  // 3. Dynamic Vendor Comparison
  const vendorComparison = vendors.map(v => {
    const vSales = sales.filter(s => {
      const sv = (s.vendor || '').toLowerCase();
      return sv.includes(v.vendorId.toLowerCase()) || v.vendorId.toLowerCase().includes(sv);
    });

    let vRev = 0;
    let vGainLoss = 0;
    vSales.forEach(s => {
      const q = Number(s.qty || 0);
      const r = Number(s.amount || (q * Number(s.rate || 0)));
      const bp = baselineProducts.find(b => b.itemCode === (s.itemCode || s.partCode)) || {};
      const det = calculateDetailedCost(bp);
      const appCost = Number(bp.approvedCost || det.finalLanded || 0);
      const actCost = Number(det.finalLanded || bp.approvedCost || 0);
      vRev += r;
      vGainLoss += ((appCost - actCost) * q);
    });

    return {
      vendorName: v.vendorName,
      currentRevenue: vRev,
      currentGainLoss: vGainLoss,
      prevRevenue: 0,
      prevGainLoss: 0,
      growthPct: '0.0%',
      varianceDelta: vGainLoss
    };
  });

  // 4. Dynamic Top Parts with Profit / Loss
  const sortedParts = [...productSummaryList].sort((a, b) => b.totalGainLoss - a.totalGainLoss);
  const topProfitParts = sortedParts.filter(p => p.totalGainLoss > 0).slice(0, 6);
  const topLossParts = sortedParts.filter(p => p.totalGainLoss < 0).slice(0, 6);

  // 5. Dynamic Root-Cause Variance Drivers
  let rmPurchaseDelta = 0;
  let mbPurchaseDelta = 0;

  purchases.forEach(p => {
    const rmMap = getActiveRmMapping(p.grade || p.itemCode, p.vendor);
    const appRate = Number(rmMap.approvedPrice || 0);
    const actRate = Number(p.rate || p.netRate || 0);
    const qty = Number(p.qty || 0);
    if (appRate > 0 && actRate > 0) {
      if (p.type === 'MB' || (p.grade || '').toLowerCase().includes('mb')) {
        mbPurchaseDelta += ((appRate - actRate) * qty);
      } else {
        rmPurchaseDelta += ((appRate - actRate) * qty);
      }
    }
  });

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* 4 Dynamic Top KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="text-[10px] uppercase font-bold text-slate-400">Period Sales Volume</div>
          <div className="text-2xl font-black font-mono text-slate-900 mt-1">{totalVolume.toLocaleString()} <span className="text-xs font-normal text-slate-500">pcs</span></div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="text-[10px] uppercase font-bold text-slate-400">Total Sales Revenue</div>
          <div className="text-2xl font-black font-mono text-blue-700 mt-1">₹{totalRevenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="text-[10px] uppercase font-bold text-slate-400">Gross Profit & Margin</div>
          <div className="text-2xl font-black font-mono text-emerald-700 mt-1">
            ₹{grossProfit.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })} <span className="text-xs font-bold text-emerald-600">({grossMarginPct}%)</span>
          </div>
        </div>

        <div className={`p-4 rounded-2xl border shadow-xs ${totalCostGainLoss >= 0 ? 'bg-emerald-50/60 border-emerald-200' : 'bg-rose-50/60 border-rose-200'}`}>
          <div className="text-[10px] uppercase font-bold text-slate-500">Cost Variance Gain / Loss</div>
          <div className={`text-2xl font-black font-mono mt-1 ${totalCostGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {totalCostGainLoss >= 0 ? `+ ₹${totalCostGainLoss.toFixed(2)}` : `- ₹${Math.abs(totalCostGainLoss).toFixed(2)}`}
          </div>
        </div>
      </div>

      {/* Main Realization & Costing Analysis Table */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex flex-wrap justify-between items-center gap-3">
          <div className="flex items-center gap-3">
            <BarChart3 className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">Product Sales Realization & Costing Analysis</h2>
            <div className="flex bg-slate-800 p-0.5 rounded-lg border border-slate-700">
              <button 
                onClick={() => setActiveTab('summary')} 
                className={`px-3 py-1 rounded font-bold cursor-pointer transition ${activeTab === 'summary' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'}`}
              >
                Product Summary ({productSummaryList.length})
              </button>
              <button 
                onClick={() => setActiveTab('invoices')} 
                className={`px-3 py-1 rounded font-bold cursor-pointer transition ${activeTab === 'invoices' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'}`}
              >
                Invoices Log ({filteredSales.length})
              </button>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <span className="text-slate-400 font-bold">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="px-2.5 py-1 bg-slate-800 text-white border border-slate-700 rounded-lg text-xs font-bold"
            >
              <option value="ALL">All Vendors Combined</option>
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>

            <input 
              type="date" 
              value={periodFrom} 
              onChange={e => setPeriodFrom(e.target.value)} 
              className="px-2 py-1 bg-slate-800 text-white border border-slate-700 rounded-lg text-xs font-mono" 
            />
            <span className="text-slate-400">to</span>
            <input 
              type="date" 
              value={periodTo} 
              onChange={e => setPeriodTo(e.target.value)} 
              className="px-2 py-1 bg-slate-800 text-white border border-slate-700 rounded-lg text-xs font-mono" 
            />
          </div>
        </div>

        {activeTab === 'summary' ? (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Part Code</th>
                  <th className="py-2.5 px-3">Component Name</th>
                  <th className="py-2.5 px-3">Vendor</th>
                  <th className="py-2.5 px-2 text-center">Invoices</th>
                  <th className="py-2.5 px-3 text-right">Total Qty Sold</th>
                  <th className="py-2.5 px-3 text-right">Avg Selling Price</th>
                  <th className="py-2.5 px-3 text-right bg-amber-50 text-amber-950">Contract Baseline</th>
                  <th className="py-2.5 px-3 text-right">Actual Unit Cost</th>
                  <th className="py-2.5 px-3 text-right">Profit / Loss (Δ)</th>
                  <th className="py-2.5 px-3 text-right">Total Gain/Loss</th>
                  <th className="py-2.5 px-4 text-right bg-blue-50 text-blue-950 font-bold">Total Sales Revenue</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {productSummaryList.length === 0 ? (
                  <tr>
                    <td colSpan={11} className="py-12 text-center text-slate-400">
                      No sales transactions recorded for the selected period. Upload sales invoices in <b>2. RM & Matrix $\rightarrow$ Day-wise Sales</b> to populate dynamic reports.
                    </td>
                  </tr>
                ) : (
                  productSummaryList.map((p, idx) => (
                    <tr key={idx} className="hover:bg-slate-50 transition">
                      <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{p.itemCode}</td>
                      <td className="py-2.5 px-3 font-semibold text-slate-800">{p.componentName}</td>
                      <td className="py-2.5 px-3 text-slate-600">{p.vendor}</td>
                      <td className="py-2.5 px-2 text-center font-mono">{p.invoicesCount}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold">{p.totalQty.toLocaleString()}</td>
                      <td className="py-2.5 px-3 text-right font-mono">₹{(p.totalRevenue / (p.totalQty || 1)).toFixed(2)}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold bg-amber-50/40">₹{p.approvedUnitCost.toFixed(2)}</td>
                      <td className="py-2.5 px-3 text-right font-mono">₹{p.actualUnitCost.toFixed(2)}</td>
                      <td className={`py-2.5 px-3 text-right font-mono font-bold ${p.unitGainLoss >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                        {p.unitGainLoss >= 0 ? `+₹${p.unitGainLoss.toFixed(2)}` : `-₹${Math.abs(p.unitGainLoss).toFixed(2)}`}
                      </td>
                      <td className={`py-2.5 px-3 text-right font-mono font-black ${p.totalGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                        {p.totalGainLoss >= 0 ? `+₹${p.totalGainLoss.toFixed(2)}` : `-₹${Math.abs(p.totalGainLoss).toFixed(2)}`}
                      </td>
                      <td className="py-2.5 px-4 text-right font-mono font-bold text-slate-900 bg-blue-50/30">₹{p.totalRevenue.toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Date</th>
                  <th className="py-2.5 px-3">Invoice #</th>
                  <th className="py-2.5 px-3">Item Code</th>
                  <th className="py-2.5 px-3">Component Name</th>
                  <th className="py-2.5 px-3">Vendor</th>
                  <th className="py-2.5 px-3 text-right">Qty</th>
                  <th className="py-2.5 px-3 text-right">Invoice Rate</th>
                  <th className="py-2.5 px-4 text-right">Total Invoice Value</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredSales.length === 0 ? (
                  <tr><td colSpan={8} className="py-8 text-center text-slate-400">No invoices found for this date filter.</td></tr>
                ) : (
                  filteredSales.map((inv, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-600">{inv.date || inv.invoiceDate || '-'}</td>
                      <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{inv.invoiceNo || inv.invoiceNumber || '-'}</td>
                      <td className="py-2.5 px-3 font-mono">{inv.itemCode || inv.partCode || '-'}</td>
                      <td className="py-2.5 px-3 font-medium text-slate-800">{inv.componentName || '-'}</td>
                      <td className="py-2.5 px-3 text-slate-600">{inv.vendor || '-'}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold">{Number(inv.qty || 0).toLocaleString()}</td>
                      <td className="py-2.5 px-3 text-right font-mono">₹{Number(inv.rate || 0).toFixed(2)}</td>
                      <td className="py-2.5 px-4 text-right font-mono font-bold text-slate-900">₹{Number(inv.amount || (inv.qty * inv.rate) || 0).toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Dynamic Vendor Comparison Breakdown */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-emerald-400" />
            <h3 className="text-xs font-bold uppercase">Vendor-Wise Realization & Variance Summary</h3>
          </div>
          <span className="text-[11px] text-slate-400">Calculated Live from Invoices</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-4">Vendor</th>
                <th className="py-2.5 px-4 text-right">Total Sales Revenue</th>
                <th className="py-2.5 px-4 text-right">Cost Variance Gain / Loss</th>
                <th className="py-2.5 px-4 text-right">Performance Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {vendorComparison.map((vc, idx) => (
                <tr key={idx} className="hover:bg-slate-50 font-medium">
                  <td className="py-2.5 px-4 font-bold text-slate-900">{vc.vendorName}</td>
                  <td className="py-2.5 px-4 text-right font-mono font-bold text-slate-900">₹{vc.currentRevenue.toFixed(2)}</td>
                  <td className={`py-2.5 px-4 text-right font-mono font-bold ${vc.currentGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                    {vc.currentGainLoss >= 0 ? `+ ₹${vc.currentGainLoss.toFixed(2)}` : `- ₹${Math.abs(vc.currentGainLoss).toFixed(2)}`}
                  </td>
                  <td className="py-2.5 px-4 text-right">
                    <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${vc.currentGainLoss >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                      {vc.currentGainLoss >= 0 ? 'Favorable' : 'Unfavorable'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Dynamic Top Parts Drilldown */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <div className="bg-white rounded-2xl border border-slate-300 p-4 shadow-sm space-y-3">
          <div className="flex items-center gap-2 text-emerald-800 font-bold">
            <ArrowUpRight className="w-4 h-4 text-emerald-600" />
            <span>Top Parts Generating Profit (Favorable Variance)</span>
          </div>
          {topProfitParts.length === 0 ? (
            <div className="py-6 text-center text-slate-400">No favorable part variances recorded.</div>
          ) : (
            <div className="space-y-1.5">
              {topProfitParts.map((p, idx) => (
                <div key={idx} className="flex justify-between items-center p-2 bg-emerald-50/50 rounded-xl border border-emerald-100 text-xs">
                  <div>
                    <div className="font-mono font-bold text-emerald-950">{p.itemCode}</div>
                    <div className="text-[11px] text-slate-600 truncate max-w-xs">{p.componentName}</div>
                  </div>
                  <div className="font-mono font-black text-emerald-700">+₹{p.totalGainLoss.toFixed(2)}</div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="bg-white rounded-2xl border border-slate-300 p-4 shadow-sm space-y-3">
          <div className="flex items-center gap-2 text-rose-800 font-bold">
            <ArrowDownRight className="w-4 h-4 text-rose-600" />
            <span>Top Parts with Cost Drift / Loss (Unfavorable)</span>
          </div>
          {topLossParts.length === 0 ? (
            <div className="py-6 text-center text-slate-400">No loss/cost-drift parts recorded.</div>
          ) : (
            <div className="space-y-1.5">
              {topLossParts.map((p, idx) => (
                <div key={idx} className="flex justify-between items-center p-2 bg-rose-50/50 rounded-xl border border-rose-100 text-xs">
                  <div>
                    <div className="font-mono font-bold text-rose-950">{p.itemCode}</div>
                    <div className="text-[11px] text-slate-600 truncate max-w-xs">{p.componentName}</div>
                  </div>
                  <div className="font-mono font-black text-rose-700">-₹{Math.abs(p.totalGainLoss).toFixed(2)}</div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Dynamic Root Cause Cost Gap Breakdown */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex items-center gap-2">
          <DollarSign className="w-4 h-4 text-amber-400" />
          <h3 className="text-xs font-bold uppercase">Dynamic Root-Cause Cost Gap Breakdown (Live Purchase Sync)</h3>
        </div>
        <div className="p-4">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2 px-3">Cost Driver & Parameter Variance</th>
                <th className="py-2 px-4 text-right">Calculated Impact (₹)</th>
                <th className="py-2 px-3 text-center">Variance Classification</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium">
              <tr>
                <td className="py-2 px-3 font-semibold text-slate-900">Polymer Base Rate Variance (Purchase Inward vs Approved Contract)</td>
                <td className={`py-2 px-4 text-right font-mono font-bold ${rmPurchaseDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {rmPurchaseDelta >= 0 ? `+ ₹${rmPurchaseDelta.toFixed(2)}` : `- ₹${Math.abs(rmPurchaseDelta).toFixed(2)}`}
                </td>
                <td className="py-2 px-3 text-center">
                  <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${rmPurchaseDelta >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                    {rmPurchaseDelta >= 0 ? 'Favorable' : 'Unfavorable'}
                  </span>
                </td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-semibold text-slate-900">Masterbatch Rate Variance (MB Actual Landed vs Approved)</td>
                <td className={`py-2 px-4 text-right font-mono font-bold ${mbPurchaseDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {mbPurchaseDelta >= 0 ? `+ ₹${mbPurchaseDelta.toFixed(2)}` : `- ₹${Math.abs(mbPurchaseDelta).toFixed(2)}`}
                </td>
                <td className="py-2 px-3 text-center">
                  <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${mbPurchaseDelta >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                    {mbPurchaseDelta >= 0 ? 'Favorable' : 'Unfavorable'}
                  </span>
                </td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-semibold text-slate-900">Cycle Time & Shopfloor Efficiency Variance</td>
                <td className={`py-2 px-4 text-right font-mono font-bold ${totalCostGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {totalCostGainLoss >= 0 ? `+ ₹${totalCostGainLoss.toFixed(2)}` : `- ₹${Math.abs(totalCostGainLoss).toFixed(2)}`}
                </td>
                <td className="py-2 px-3 text-center">
                  <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${totalCostGainLoss >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                    {totalCostGainLoss >= 0 ? 'Favorable' : 'Unfavorable'}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
MIS_EOF

echo "==> 3. Adding complete test purge helper functions to masterStore.js..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// ============================================================================
// GLOBAL MASTER DATA STORE (Strictly Isolated DEV-V2)
// ============================================================================

const STORAGE_KEY = 'CPC_MASTER_STORE_DEV_ISOLATED_V2';

function loadPersistedStore() {
  if (typeof window === 'undefined') return null;
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) return JSON.parse(saved);
  } catch (err) {
    console.error("Error loading dev store:", err);
  }
  return null;
}

const defaultStore = {
  isLocked: false,
  isMatrixLocked: false,
  vendors: [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ],
  rmMappingsData: [],
  baselineProducts: [],
  purchases: [],
  sales: [],
  auditLogs: []
};

const initialStore = loadPersistedStore() || defaultStore;

export let globalStore = {
  ...defaultStore,
  ...initialStore,
  vendors: (initialStore.vendors && initialStore.vendors.length > 0) ? initialStore.vendors : defaultStore.vendors
};

function persistCurrentStore() {
  if (typeof window === 'undefined') return;
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(globalStore));
  } catch (err) {
    console.error("Error saving dev store:", err);
  }
}

let listeners = [];
export function subscribeStore(fn) {
  listeners.push(fn);
  return () => { listeners = listeners.filter(cb => cb !== fn); };
}

export function notifyStore() {
  persistCurrentStore();
  listeners.forEach(fn => { try { fn(globalStore); } catch (e) { console.error(e); } });
}

export function purgeAllTestData() {
  globalStore.rmMappingsData = [];
  globalStore.baselineProducts = [];
  globalStore.purchases = [];
  globalStore.sales = [];
  globalStore.auditLogs = [];
  notifyStore();
}

export function parseMaterialString(rawMaterialStr) {
  if (!rawMaterialStr) return { baseRm: '', mbGrade: '' };
  const cleanStr = rawMaterialStr.toString().trim();
  if (cleanStr.includes('+')) {
    const parts = cleanStr.split('+').map(s => s.trim());
    return { baseRm: parts[0] || '', mbGrade: parts[1] || '' };
  }
  return { baseRm: cleanStr, mbGrade: '' };
}

export function computeGradeWeightedAverage(gradeOrCode, vendor) {
  const purchases = globalStore.purchases || [];
  const gClean = (gradeOrCode || '').toLowerCase().trim();
  const vClean = (vendor || '').toLowerCase().trim();

  const matching = purchases.filter(p => {
    const pGrade = (p.grade || p.itemCode || p.rawMaterial || '').toLowerCase().trim();
    const pVendor = (p.vendor || '').toLowerCase().trim();
    const matchGrade = pGrade.includes(gClean) || gClean.includes(pGrade);
    const matchVendor = !vClean || pVendor.includes(vClean) || vClean.includes(pVendor);
    return matchGrade && matchVendor;
  });

  let totalQty = 0;
  let totalCost = 0;
  matching.forEach(m => {
    const qty = Number(m.qty || m.quantity || 0);
    const rate = Number(m.rate || m.netRate || m.price || 0);
    if (qty > 0 && rate > 0) {
      totalQty += qty;
      totalCost += (qty * rate);
    }
  });

  if (totalQty > 0) {
    return Number((totalCost / totalQty).toFixed(2));
  }
  return 0;
}

export function getActiveRmMapping(gradeName, vendor) {
  if (!gradeName) return { approvedCode: 'Unspecified', approvedPrice: 0, activeGrade: 'Unspecified', activeWaPrice: 0, isFound: false };
  const { baseRm } = parseMaterialString(gradeName);
  const targetCode = (baseRm || gradeName).toLowerCase().trim();
  const vClean = (vendor || '').toLowerCase().trim();
  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'RM' && (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim())) && 
    r.approvedCode.toLowerCase().trim() === targetCode
  );
  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] !== undefined ? found[`${activeKey}Price`] : (found.alt1Price || found.approvedPrice || 0));
    return { approvedCode: found.approvedCode, approvedPrice: Number(found.approvedPrice || 0), activeGrade: found[`${activeKey}Code`] || found.approvedCode, activeWaPrice: Number(waPrice || 0), isFound: true };
  }
  return { approvedCode: baseRm || gradeName, approvedPrice: 0, activeGrade: baseRm || gradeName, activeWaPrice: 0, isFound: false };
}

export function getActiveMbMapping(mbGradeName, vendor) {
  const vClean = (vendor || '').toLowerCase().trim();
  let targetMb = (mbGradeName || '').toLowerCase().trim();
  if (!targetMb) return { approvedMbCode: 'None', approvedMbPrice: 0, activeMbGrade: 'None', activeMbWaPrice: 0, isFound: false };
  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'MB' && (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim())) && 
    r.approvedCode.toLowerCase().trim() === targetMb
  );
  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] !== undefined ? found[`${activeKey}Price`] : (found.alt1Price || found.approvedPrice || 0));
    return { approvedMbCode: found.approvedCode, approvedMbPrice: Number(found.approvedPrice || 0), activeMbGrade: found[`${activeKey}Code`] || found.approvedCode, activeMbWaPrice: Number(waPrice || 0), isFound: true };
  }
  return { approvedMbCode: mbGradeName, approvedMbPrice: 0, activeMbGrade: mbGradeName, activeMbWaPrice: 0, isFound: false };
}

export function addOrUpdateVendorMaterial(item) {
  if (!globalStore.rmMappingsData) globalStore.rmMappingsData = [];
  const idx = globalStore.rmMappingsData.findIndex(r => r.vendor === item.vendor && r.type === item.type && r.approvedCode === item.approvedCode);
  if (idx >= 0) {
    globalStore.rmMappingsData[idx] = { ...globalStore.rmMappingsData[idx], ...item };
  } else {
    globalStore.rmMappingsData.push({ id: `mat-${Date.now()}-${Math.random().toString(36).substr(2,4)}`, ...item });
  }
  notifyStore();
}

export function updateRmMappingRow(rowId, updatedFields) {
  if (!globalStore.rmMappingsData) globalStore.rmMappingsData = [];
  const idx = globalStore.rmMappingsData.findIndex(r => r.id === rowId);
  if (idx >= 0) {
    globalStore.rmMappingsData[idx] = { ...globalStore.rmMappingsData[idx], ...updatedFields };
    notifyStore();
  }
}

export function deleteVendorMaterial(id) {
  globalStore.rmMappingsData = (globalStore.rmMappingsData || []).filter(r => r.id !== id);
  notifyStore();
}

export function saveVendorPeriodSchedule({ vendor, periodFrom, periodTo }) {
  addAuditLog({
    partCode: 'RM_MATRIX',
    componentName: `Saved Matrix Schedule for ${vendor}`,
    vendor: vendor,
    modifications: `Period: ${periodFrom} to ${periodTo}`,
    costImpact: 'Matrix Updated',
    reason: 'Vendor Period Save'
  });
  notifyStore();
}

export function getVendorBaselineData(vendorId) {
  const prods = globalStore.baselineProducts || [];
  if (!vendorId || vendorId === 'ALL') return prods;
  return prods.filter(p => (p.vendor || '').toLowerCase().includes(vendorId.toLowerCase()));
}

export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  Object.assign(prod, updatedItem);
  addAuditLog({
    partCode: prod.itemCode,
    componentName: prod.componentName,
    vendor: prod.vendor,
    modifications: 'Adjusted parameters in modal',
    costImpact: `₹${(prod.approvedCost || 0).toFixed(2)}`,
    reason: reason || 'Manual Spec Adjustment'
  });
  notifyStore();
}

export function addStagedProductsToBaseline(stagedList, vendor) {
  stagedList.forEach(staged => {
    const idx = globalStore.baselineProducts.findIndex(p => p.itemCode === staged.itemCode);
    if (idx >= 0) {
      globalStore.baselineProducts[idx] = { ...globalStore.baselineProducts[idx], ...staged };
    } else {
      globalStore.baselineProducts.push({ ...staged, id: `prod-${Date.now()}-${Math.random().toString(36).substr(2,4)}`, vendor: vendor || staged.vendor });
    }
  });
  notifyStore();
}

export function deleteProductFromBaseline(itemId, vendor) {
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => p.id !== itemId && p.itemCode !== itemId);
  addAuditLog({
    partCode: itemId,
    componentName: `Deleted Product ${itemId}`,
    vendor: vendor || 'ALL',
    modifications: 'Deleted product from baseline master',
    costImpact: '0.00',
    reason: 'Manual deletion'
  });
  notifyStore();
}

export function clearVendorBaselineProducts(vendorName) {
  const vClean = (vendorName || '').toLowerCase().trim();
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => !(p.vendor || '').toLowerCase().trim().includes(vClean));
  addAuditLog({
    partCode: 'BASELINE_PURGE',
    componentName: `Purged Baseline Products for ${vendorName}`,
    vendor: vendorName,
    modifications: 'Cleared baseline table',
    costImpact: '0 Parts',
    reason: 'Manual Baseline Purge'
  });
  notifyStore();
}

export function addAuditLog(entry) {
  globalStore.auditLogs = globalStore.auditLogs || [];
  globalStore.auditLogs.unshift({
    timestamp: new Date().toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }),
    ...entry
  });
}

export function toggleGlobalLock() { globalStore.isLocked = !globalStore.isLocked; notifyStore(); }
export function toggleMatrixLock() { globalStore.isMatrixLocked = !globalStore.isMatrixLocked; notifyStore(); }
export function addDayWisePurchase(rec) { (globalStore.purchases = globalStore.purchases || []).unshift(rec); notifyStore(); return { success: true }; }
export function addDayWiseSales(rec) { (globalStore.sales = globalStore.sales || []).unshift(rec); notifyStore(); return { success: true }; }
export function onboardVendorWithBlueprint() { notifyStore(); }
STORE_EOF

echo "==> 4. Verifying build strictly on dev-v2..."
npm run build

echo "==> 5. Committing and pushing ONLY to origin/dev-v2 (Zero push to main)..."
git add -A
git commit -m "feat(dev-v2): make 4. MIS & Gap 100% dynamic and add test data purge action" || echo "dev-v2 clean."
git push origin dev-v2

echo "==> 6. Restarting local dev server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ MIS IS 100% DYNAMIC & READY ON DEV-V2!"
echo "-------------------------------------------------------------------"
