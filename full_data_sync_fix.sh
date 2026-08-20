#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js to enforce uniform baseline and running specs..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// Centralized Master Store for Multi-Vendor Costing System

export const globalStore = {
  vendors: [
    { vendorId: 'Atomberg', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Haier', vendorName: 'Haier Appliances' }
  ],

  rawMaterials: [
    { id: 'rm-1', vendor: 'Atomberg', grade: 'PP H110MA', approvedPrice: 131.00, activeGrade: 'PP H110MA Prime Inward', activeWaPrice: 135.83 },
    { id: 'rm-2', vendor: 'Haier', grade: 'ABS 300 Pre Colour', approvedPrice: 136.20, activeGrade: 'ABS 300-B Red (Prime Inward)', activeWaPrice: 134.80 },
    { id: 'rm-3', vendor: 'Haier', grade: 'GPPS SC201LV', approvedPrice: 100.00, activeGrade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', activeWaPrice: 98.40 }
  ],

  masterbatches: [
    { id: 'mb-1', vendor: 'Atomberg', color: 'Black MB', approvedMbPrice: 250.00, activeMbWaPrice: 258.54 },
    { id: 'mb-2', vendor: 'Atomberg', color: 'White MB', approvedMbPrice: 250.00, activeMbWaPrice: 258.54 },
    { id: 'mb-3', vendor: 'Haier', color: 'Standard MB', approvedMbPrice: 0.00, activeMbWaPrice: 0.00 }
  ],

  baselineProducts: [
    {
      id: 'prod-atom-1',
      vendor: 'Atomberg',
      itemCode: 'A101703',
      componentName: 'Aris Top Canopy- Gloss Black',
      model: 'Aris 1200mm',
      approvedRm: 'PP H110MA',
      approvedRmRate: 131.00,
      masterbatchPct: 4.0,
      masterbatchRate: 250.00,
      cavity: 2,
      netWeight: 37.0,
      runnerWeight: 1.0,
      cycleTimeApproved: 47.0,
      cycleTime: 47.0,
      machineTonnage: 200,
      shiftTariff: 2000,
      bopCost: 0.0,
      parameters: {
        runningCavity: 2,
        runningNetWeight: 37.0,
        runningRunnerWeight: 1.0,
        runningCycleTime: 47.0,
        runningTonnage: 200,
        runningMbPct: 4.0,
        runningBopCost: 0.0
      }
    },
    {
      id: 'prod-atom-2',
      vendor: 'Atomberg',
      itemCode: 'A101701',
      componentName: 'Aris Top Canopy- Gloss White',
      model: 'Aris 1200mm',
      approvedRm: 'PP H110MA',
      approvedRmRate: 131.00,
      masterbatchPct: 4.0,
      masterbatchRate: 250.00,
      cavity: 2,
      netWeight: 37.0,
      runnerWeight: 1.0,
      cycleTimeApproved: 47.0,
      cycleTime: 47.0,
      machineTonnage: 200,
      shiftTariff: 2000,
      bopCost: 0.0,
      parameters: {
        runningCavity: 2,
        runningNetWeight: 37.0,
        runningRunnerWeight: 1.0,
        runningCycleTime: 47.0,
        runningTonnage: 200,
        runningMbPct: 4.0,
        runningBopCost: 0.0
      }
    },
    {
      id: 'prod-haier-1',
      vendor: 'Haier',
      itemCode: '0060217989D',
      componentName: 'End cap Bottom Ref-ABS-DC-195,220',
      model: 'OLD DC- 195,220',
      approvedRm: 'ABS 300 Pre Colour',
      approvedRmRate: 136.20,
      masterbatchPct: 0.0,
      masterbatchRate: 0.0,
      cavity: 2,
      netWeight: 197.0,
      runnerWeight: 40.0,
      cycleTimeApproved: 48.0,
      cycleTime: 48.0,
      machineTonnage: 450,
      shiftTariff: 3600,
      bopCost: 0.14,
      parameters: {
        runningCavity: 2,
        runningNetWeight: 197.0,
        runningRunnerWeight: 40.0,
        runningCycleTime: 48.0,
        runningTonnage: 450,
        runningMbPct: 0.0,
        runningBopCost: 0.0
      }
    },
    {
      id: 'prod-haier-2',
      vendor: 'Haier',
      itemCode: '0060217978E',
      componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX',
      model: 'DC 195, 220',
      approvedRm: 'GPPS SC201LV',
      approvedRmRate: 100.00,
      masterbatchPct: 3.5,
      masterbatchRate: 0.0,
      cavity: 1,
      netWeight: 485.0,
      runnerWeight: 22.0,
      cycleTimeApproved: 58.0,
      cycleTime: 58.0,
      machineTonnage: 650,
      shiftTariff: 5760,
      bopCost: 0.14,
      parameters: {
        runningCavity: 1,
        runningNetWeight: 485.0,
        runningRunnerWeight: 22.0,
        runningCycleTime: 58.0,
        runningTonnage: 650,
        runningMbPct: 3.5,
        runningBopCost: 0.0
      }
    }
  ],

  parameterChangeLogs: []
};

let listeners = [];
export function subscribeStore(fn) {
  listeners.push(fn);
  return () => {
    listeners = listeners.filter(l => l !== fn);
  };
}

export function notifyStore() {
  listeners.forEach(fn => fn());
}

export function getVendorBaselineData(vendorId) {
  if (!vendorId || vendorId === 'ALL' || vendorId === 'All Vendors Combined') {
    return globalStore.baselineProducts;
  }
  return globalStore.baselineProducts.filter(p => 
    p.vendor.toLowerCase().includes(vendorId.toLowerCase())
  );
}

export function getActiveRmMapping(gradeName, vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase();
  const list = globalStore.rawMaterials.filter(r => r.vendor.toLowerCase().includes(vClean));
  const found = list.find(r => r.grade === gradeName) || list[0] || {
    approvedPrice: 131.00,
    activeWaPrice: 135.83,
    activeGrade: gradeName || 'Standard RM'
  };
  return found;
}

export function getActiveMbMapping(vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase();
  const list = globalStore.masterbatches.filter(m => m.vendor.toLowerCase().includes(vClean));
  return list[0] || {
    approvedMbPrice: 250.00,
    activeMbWaPrice: 258.54
  };
}

export function updateBaselineParameters({ itemId, updatedItem, changeType, reason }) {
  const prod = globalStore.baselineProducts.find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;

  if (updatedItem.parameters) {
    prod.parameters = { ...prod.parameters, ...updatedItem.parameters };
  }
  if (updatedItem.cycleTimeApproved !== undefined) prod.cycleTimeApproved = updatedItem.cycleTimeApproved;
  if (updatedItem.netWeight !== undefined) prod.netWeight = updatedItem.netWeight;
  if (updatedItem.runnerWeight !== undefined) prod.runnerWeight = updatedItem.runnerWeight;
  if (updatedItem.cavity !== undefined) prod.cavity = updatedItem.cavity;
  if (updatedItem.machineTonnage !== undefined) {
    prod.machineTonnage = updatedItem.machineTonnage;
    prod.shiftTariff = updatedItem.machineTonnage * 8;
  }
  if (updatedItem.bopCost !== undefined) prod.bopCost = updatedItem.bopCost;

  notifyStore();
}

export function addStagedProductsToBaseline(stagedList, vendor) {
  stagedList.forEach(staged => {
    const existingIdx = globalStore.baselineProducts.findIndex(p => p.itemCode === staged.itemCode);
    if (existingIdx >= 0) {
      globalStore.baselineProducts[existingIdx] = { ...globalStore.baselineProducts[existingIdx], ...staged };
    } else {
      globalStore.baselineProducts.push({ ...staged, vendor: vendor || 'Haier' });
    }
  });
  notifyStore();
}
STORE_EOF

echo "==> 2. Updating CostingEngine.jsx to call calculatePieceCostUnified directly..."
cat << 'CE_EOF' > src/modules/module3-costing-engine/CostingEngine.jsx
import React, { useState, useEffect } from 'react';
import { 
  DollarSign, Search, ShieldCheck, TrendingUp, TrendingDown, Activity 
} from 'lucide-react';
import { globalStore, subscribeStore, getVendorBaselineData, getActiveRmMapping } from '../../shared/masterStore';
import { calculatePieceCostUnified } from '../../shared/costCalculationService';

export default function CostingEngine() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [searchQuery, setSearchQuery] = useState('');

  const rawList = getVendorBaselineData(selectedVendor === 'ALL' ? 'ALL' : selectedVendor);

  const filteredItems = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <DollarSign className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">3. Dynamic Costing Run Engine</h1>
            <p className="text-[11px] text-slate-300">Live simulation of product piece costing matching contract baselines against active material inward rates.</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-emerald-950/80 border border-emerald-500/30 text-emerald-300 text-xs rounded-xl font-bold font-mono">
            <ShieldCheck className="w-4 h-4 text-emerald-400" /> Engine Active & Linked to RM Matrix
          </span>
        </div>
      </div>

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search components by name or part number..."
            className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-700">Filter Vendor:</span>
          <select
            value={selectedVendor}
            onChange={(e) => setSelectedVendor(e.target.value)}
            className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
          >
            <option value="ALL">All Vendors Combined</option>
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
          <h2 className="text-sm font-bold flex items-center gap-2">
            <Activity className="w-4 h-4 text-blue-400" /> Live Product Cost Simulation Matrix
          </h2>
          <span className="text-[11px] text-slate-300 font-mono">{filteredItems.length} Products</span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
              <tr>
                <th className="p-3">ITEM CODE / COMPONENT</th>
                <th className="p-3 text-center">VENDOR</th>
                <th className="p-3">APPROVED RM</th>
                <th className="p-3 text-right">APPROVED RM RATE</th>
                <th className="p-3">ACTIVE ALTERNATE RM (INWARD)</th>
                <th className="p-3 text-right">ACTIVE WA RATE</th>
                <th className="p-3 text-center bg-amber-50 font-bold text-amber-950">APPROVED BASELINE</th>
                <th className="p-3 text-center bg-blue-50 font-bold text-blue-950">SIMULATED ACTUAL</th>
                <th className="p-3 text-center">PROFIT / LOSS (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {filteredItems.map((item) => {
                const vendor = item.vendor || 'Haier';
                const isCrisper = item.itemCode === '0060217978E';
                const defaultRm = isCrisper ? 'GPPS SC201LV' : (vendor.toLowerCase().includes('haier') ? 'ABS 300 Pre Colour' : 'PP H110MA');
                const rmMapping = getActiveRmMapping(item.approvedRm || defaultRm, vendor);
                
                const baselineCalc = calculatePieceCostUnified({ item, isBaseline: true });
                const actualCalc = calculatePieceCostUnified({ item, isBaseline: false });

                const baselineCost = baselineCalc.totalCost || baselineCalc.finalLanded || 0;
                const actualCost = actualCalc.totalCost || actualCalc.finalLanded || 0;
                const delta = baselineCost - actualCost;

                return (
                  <tr key={item.id} className="hover:bg-slate-50">
                    <td className="p-3">
                      <span className="font-mono font-bold text-blue-700 block">{item.itemCode}</span>
                      <span className="font-semibold text-slate-900">{item.componentName}</span>
                    </td>
                    <td className="p-3 text-center">
                      <span className="px-2 py-0.5 bg-slate-100 border border-slate-300 rounded font-bold text-[10px] text-slate-700">
                        {vendor}
                      </span>
                    </td>
                    <td className="p-3 font-semibold text-slate-800">
                      {item.approvedRm || defaultRm}
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">
                      ₹{Number(rmMapping.approvedPrice || item.approvedRmRate || 130).toFixed(2)}/kg
                    </td>
                    <td className="p-3">
                      <span className="font-bold text-blue-900 block">{rmMapping.activeGrade || item.approvedRm}</span>
                      <span className="text-[10px] text-slate-500 italic">Linked to RM Matrix</span>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-blue-700">
                      ₹{Number(rmMapping.activeWaPrice || rmMapping.approvedPrice || item.approvedRmRate || 130).toFixed(2)}/kg
                    </td>
                    <td className="p-3 text-center bg-amber-50/70 font-mono font-bold text-slate-900 text-sm">
                      ₹{baselineCost.toFixed(2)}
                    </td>
                    <td className="p-3 text-center bg-blue-50/70 font-mono font-bold text-slate-900 text-sm">
                      ₹{actualCost.toFixed(2)}
                    </td>
                    <td className="p-3 text-center">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-xl text-xs font-mono font-bold ${delta >= 0 ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-rose-100 text-rose-800 border border-rose-300'}`}>
                        {delta >= 0 ? <TrendingUp className="w-3.5 h-3.5 text-emerald-600" /> : <TrendingDown className="w-3.5 h-3.5 text-rose-600" />}
                        {delta >= 0 ? `+₹${delta.toFixed(2)}` : `-₹${Math.abs(delta).toFixed(2)}`}
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
CE_EOF

echo "==> 3. Updating MisIntelligencePage.jsx to ensure exact match with Edit Spec..."
cat << 'MIS_EOF' > src/modules/module4-mis/MisIntelligencePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  BarChart3, Calendar, FileText, TrendingUp, TrendingDown 
} from 'lucide-react';
import { globalStore, subscribeStore, getVendorBaselineData } from '../../shared/masterStore';
import { calculatePieceCostUnified } from '../../shared/costCalculationService';

export default function MisIntelligencePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [startDate, setStartDate] = useState('2026-08-01');
  const [endDate, setEndDate] = useState('2026-08-31');

  const rawList = getVendorBaselineData(selectedVendor === 'ALL' ? 'ALL' : selectedVendor);

  const salesDispatches = [
    { date: '2026-08-10', itemCode: '0060217989D', qty: 4200, sellingPrice: 42.00 },
    { date: '2026-08-12', itemCode: '0060217978E', qty: 1800, sellingPrice: 85.00 },
    { date: '2026-08-15', itemCode: 'A101701', qty: 3500, sellingPrice: 14.50 },
    { date: '2026-08-01', itemCode: 'A101703', qty: 1000, sellingPrice: 15.96 }
  ];

  const filteredDispatches = salesDispatches.filter(disp => {
    const product = rawList.find(p => p.itemCode === disp.itemCode);
    return !!product;
  });

  let totalSalesVolume = 0;
  let totalSalesRevenue = 0;
  let totalGrossProfit = 0;
  let totalCostVariance = 0;

  const rows = filteredDispatches.map(disp => {
    const product = rawList.find(p => p.itemCode === disp.itemCode);
    const vendor = product?.vendor || 'Haier';

    const baselineCalc = calculatePieceCostUnified({ item: product, isBaseline: true });
    const actualCalc = calculatePieceCostUnified({ item: product, isBaseline: false });

    const contractBaseline = baselineCalc.totalCost || baselineCalc.finalLanded || 0;
    const actualUnitCost = actualCalc.totalCost || actualCalc.finalLanded || 0;
    const delta = contractBaseline - actualUnitCost;

    const totalSales = disp.qty * disp.sellingPrice;
    const totalActualCost = disp.qty * actualUnitCost;
    const grossProfit = totalSales - totalActualCost;
    const totalProfitLossDelta = disp.qty * delta;

    totalSalesVolume += disp.qty;
    totalSalesRevenue += totalSales;
    totalGrossProfit += grossProfit;
    totalCostVariance += totalProfitLossDelta;

    return {
      ...disp,
      componentName: product?.componentName || disp.itemCode,
      vendor,
      contractBaseline,
      actualUnitCost,
      delta,
      totalProfitLossDelta,
      totalSales
    };
  });

  const grossMarginPct = totalSalesRevenue > 0 ? ((totalGrossProfit / totalSalesRevenue) * 100).toFixed(1) : 0;

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

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-700">VENDOR:</span>
          <select
            value={selectedVendor}
            onChange={(e) => setSelectedVendor(e.target.value)}
            className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
          >
            <option value="ALL">All Vendors Combined</option>
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>
        </div>

        <div className="flex items-center gap-2 bg-slate-50 px-3 py-1.5 rounded-xl border">
          <Calendar className="w-4 h-4 text-slate-500" />
          <span className="font-bold text-slate-600">PERIOD:</span>
          <input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} className="border px-2 py-0.5 rounded text-xs bg-white" />
          <span className="text-slate-400">&rarr;</span>
          <input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} className="border px-2 py-0.5 rounded text-xs bg-white" />
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <span className="text-[10px] font-bold uppercase text-slate-500 block">PERIOD SALES VOLUME</span>
          <span className="text-xl font-black text-slate-900 font-mono mt-1 block">{totalSalesVolume.toLocaleString()} pcs</span>
        </div>
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <span className="text-[10px] font-bold uppercase text-slate-500 block">TOTAL SALES REVENUE</span>
          <span className="text-xl font-black text-blue-900 font-mono mt-1 block">₹{totalSalesRevenue.toLocaleString()}</span>
        </div>
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <span className="text-[10px] font-bold uppercase text-slate-500 block">GROSS PROFIT & MARGIN</span>
          <span className="text-xl font-black text-emerald-800 font-mono mt-1 block">
            ₹{Math.round(totalGrossProfit).toLocaleString()} <span className="text-xs font-semibold text-emerald-600">({grossMarginPct}%)</span>
          </span>
        </div>
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <span className="text-[10px] font-bold uppercase text-slate-500 block">COST VARIANCE GAIN / LOSS</span>
          <span className={`text-xl font-black font-mono mt-1 block ${totalCostVariance >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {totalCostVariance >= 0 ? `+ ₹${Math.round(totalCostVariance).toLocaleString()}` : `- ₹${Math.abs(Math.round(totalCostVariance)).toLocaleString()}`}
          </span>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
          <h2 className="text-sm font-bold flex items-center gap-2">
            <FileText className="w-4 h-4 text-blue-400" /> Product Sales Realization & Costing Analysis
          </h2>
          <span className="text-[11px] text-slate-300 font-mono">{rows.length} Dispatch Invoices</span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
              <tr>
                <th className="p-3">DATE</th>
                <th className="p-3">PART CODE</th>
                <th className="p-3">COMPONENT NAME</th>
                <th className="p-3 text-center">VENDOR</th>
                <th className="p-3 text-right">QTY SOLD</th>
                <th className="p-3 text-right">SELLING PRICE</th>
                <th className="p-3 text-center bg-amber-50 font-bold text-amber-950">CONTRACT BASELINE</th>
                <th className="p-3 text-center bg-blue-50 font-bold text-blue-950">ACTUAL UNIT COST</th>
                <th className="p-3 text-center bg-yellow-50/70 font-bold text-slate-900">PROFIT / LOSS (Δ)</th>
                <th className="p-3 text-center font-bold">TOTAL PROFIT / LOSS (Δ)</th>
                <th className="p-3 text-right">TOTAL SALES</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {rows.map((r, idx) => (
                <tr key={idx} className="hover:bg-slate-50">
                  <td className="p-3 font-mono text-slate-500">{r.date}</td>
                  <td className="p-3 font-mono font-bold text-blue-700">{r.itemCode}</td>
                  <td className="p-3 font-semibold text-slate-900">{r.componentName}</td>
                  <td className="p-3 text-center">
                    <span className="px-2 py-0.5 bg-slate-100 border border-slate-300 rounded font-bold text-[10px] text-slate-700">
                      {r.vendor}
                    </span>
                  </td>
                  <td className="p-3 text-right font-mono font-bold">{r.qty.toLocaleString()}</td>
                  <td className="p-3 text-right font-mono">₹{r.sellingPrice.toFixed(2)}</td>
                  <td className="p-3 text-center bg-amber-50/70 font-mono font-bold text-slate-900">
                    ₹{r.contractBaseline.toFixed(2)}
                  </td>
                  <td className="p-3 text-center bg-blue-50/70 font-mono font-bold text-slate-900">
                    ₹{r.actualUnitCost.toFixed(2)}
                  </td>
                  <td className="p-3 text-center bg-yellow-50/70">
                    <span className={`inline-flex items-center gap-0.5 font-mono font-bold ${r.delta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                      {r.delta >= 0 ? `+ ₹${r.delta.toFixed(2)}` : `- ₹${Math.abs(r.delta).toFixed(2)}`}
                    </span>
                  </td>
                  <td className="p-3 text-center">
                    <span className={`font-mono font-bold ${r.totalProfitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                      {r.totalProfitLossDelta >= 0 ? `+ ₹${Math.round(r.totalProfitLossDelta).toLocaleString()}` : `- ₹${Math.abs(Math.round(r.totalProfitLossDelta)).toLocaleString()}`}
                    </span>
                  </td>
                  <td className="p-3 text-right font-mono font-bold text-slate-900">₹{r.totalSales.toLocaleString()}</td>
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

echo "==> Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Unification Complete!"
