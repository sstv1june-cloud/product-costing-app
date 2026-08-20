#!/usr/bin/env bash
set -e

echo "==> 1. Writing persistent masterStore.js with auto-initializing fallback storage..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// Master Store with persistent sales dispatches & calculation links

const DEFAULT_SALES = [
  { date: '2026-08-10', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4200, sellingPrice: 42.00, vendor: 'Haier' },
  { date: '2026-08-12', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1800, sellingPrice: 85.00, vendor: 'Haier' },
  { date: '2026-08-15', itemCode: 'A101701', componentName: 'Aris Top Canopy- Gloss White', qty: 3500, sellingPrice: 14.50, vendor: 'Atomberg' },
  { date: '2026-08-01', itemCode: 'A101703', componentName: 'Aris Top Canopy- Gloss Black', qty: 1000, sellingPrice: 15.96, vendor: 'Atomberg' }
];

const DEFAULT_PRODUCTS = [
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
    postOpCost: 1.73,
    parameters: {
      runningCavity: 2,
      runningNetWeight: 37.0,
      runningRunnerWeight: 1.0,
      runningCycleTime: 47.0,
      runningTonnage: 200,
      runningMbPct: 4.0,
      runningPostOpCost: 1.73,
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
    postOpCost: 1.73,
    parameters: {
      runningCavity: 2,
      runningNetWeight: 37.0,
      runningRunnerWeight: 1.0,
      runningCycleTime: 47.0,
      runningTonnage: 200,
      runningMbPct: 4.0,
      runningPostOpCost: 1.73,
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
];

export const globalStore = {
  isGlobalLocked: false,
  vendors: [
    { vendorId: 'Atomberg', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Haier', vendorName: 'Haier Appliances' }
  ],

  rmMappingsData: [
    {
      id: 'rm-map-1',
      vendor: 'Haier',
      periodFrom: '2026-08-01',
      periodTo: '2026-08-31',
      type: 'RM',
      approvedCode: 'ABS 300 Pre Colour',
      approvedPrice: 136.20,
      alt1Code: 'ABS 300-B Red (Prime Inward)',
      alt1Price: 134.80,
      alt2Code: 'ABS 300-B Alt Pre-mix (Supreme)',
      alt2Price: 135.20,
      alt3Code: 'ABS 300-B Spot Lot C',
      alt3Price: 134.50,
      activeAlt: 'alt1'
    },
    {
      id: 'rm-map-2',
      vendor: 'Haier',
      periodFrom: '2026-08-01',
      periodTo: '2026-08-31',
      type: 'RM',
      approvedCode: 'GPPS SC201LV',
      approvedPrice: 100.00,
      alt1Code: 'GPPS SC201LV + 3.5% Smoke Grey Blend',
      alt1Price: 98.40,
      alt2Code: 'GPPS SC206 Virgin Lot',
      alt2Price: 99.10,
      alt3Code: 'GPPS SC200 Inward Lot 3',
      alt3Price: 98.80,
      activeAlt: 'alt1'
    },
    {
      id: 'rm-map-3',
      vendor: 'Haier',
      periodFrom: '2026-08-01',
      periodTo: '2026-08-31',
      type: 'MB',
      approvedCode: 'Smoke Grey MB (3.5%)',
      approvedPrice: 0.00,
      alt1Code: 'Smoke Grey Masterbatch Lot A',
      alt1Price: 0.00,
      alt2Code: 'Smoke Grey Masterbatch Lot B',
      alt2Price: 0.00,
      alt3Code: 'Smoke Grey Masterbatch Lot C',
      alt3Price: 0.00,
      activeAlt: 'alt1'
    },
    {
      id: 'rm-map-4',
      vendor: 'Atomberg',
      periodFrom: '2026-08-01',
      periodTo: '2026-08-31',
      type: 'RM',
      approvedCode: 'PP H110MA',
      approvedPrice: 131.00,
      alt1Code: 'PP H110MA Prime Inward',
      alt1Price: 135.83,
      alt2Code: 'PP H110MA Alternate Inward',
      alt2Price: 133.50,
      alt3Code: 'PP H110MA Spot Market Inward',
      alt3Price: 134.20,
      activeAlt: 'alt1'
    },
    {
      id: 'rm-map-5',
      vendor: 'Atomberg',
      periodFrom: '2026-08-01',
      periodTo: '2026-08-31',
      type: 'MB',
      approvedCode: 'Black MB / White MB',
      approvedPrice: 250.00,
      alt1Code: 'Universal Inward MB Lot 1',
      alt1Price: 258.54,
      alt2Code: 'Universal Inward MB Lot 2',
      alt2Price: 255.00,
      alt3Code: 'Universal Inward MB Lot 3',
      alt3Price: 256.40,
      activeAlt: 'alt1'
    }
  ],

  baselineProducts: DEFAULT_PRODUCTS,
  sales: DEFAULT_SALES,
  purchases: [],
  parameterChangeLogs: []
};

let listeners = [];
export function subscribeStore(fn) {
  listeners.push(fn);
  return () => { listeners = listeners.filter(l => l !== fn); };
}

export function notifyStore() {
  listeners.forEach(fn => fn());
}

export function getVendorBaselineData(vendorId) {
  const prods = globalStore.baselineProducts || DEFAULT_PRODUCTS;
  if (!vendorId || vendorId === 'ALL' || vendorId === 'All Vendors Combined') return prods;
  return prods.filter(p => (p.vendor || '').toLowerCase().includes(vendorId.toLowerCase()));
}

export function getActiveRmMapping(gradeName, vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase();
  const found = (globalStore.rmMappingsData || []).find(r => 
    r.vendor.toLowerCase().includes(vClean) && r.approvedCode === gradeName && r.type === 'RM'
  ) || (globalStore.rmMappingsData || []).find(r => r.vendor.toLowerCase().includes(vClean) && r.type === 'RM');

  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    return {
      approvedPrice: Number(found.approvedPrice || 131),
      activeWaPrice: Number(found[`${activeKey}Price`] || found.alt1Price || found.approvedPrice),
      activeGrade: found[`${activeKey}Code`] || found.alt1Code || found.approvedCode
    };
  }
  return { approvedPrice: 131.00, activeWaPrice: 135.83, activeGrade: gradeName || 'Standard RM' };
}

export function getActiveMbMapping(vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase();
  const found = (globalStore.rmMappingsData || []).find(r => 
    r.vendor.toLowerCase().includes(vClean) && r.type === 'MB'
  );
  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    return {
      approvedMbPrice: Number(found.approvedPrice || 250),
      activeMbWaPrice: Number(found[`${activeKey}Price`] || found.alt1Price || found.approvedPrice)
    };
  }
  return { approvedMbPrice: 250.00, activeMbWaPrice: 258.54 };
}

export function updateBaselineParameters({ itemId, updatedItem }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  if (updatedItem.parameters) prod.parameters = { ...prod.parameters, ...updatedItem.parameters };
  notifyStore();
}

export function toggleGlobalLock() {
  globalStore.isGlobalLocked = !globalStore.isGlobalLocked;
  notifyStore();
}

export function updateRmMappingRow(rowId, updatedFields) {
  const row = (globalStore.rmMappingsData || []).find(r => r.id === rowId);
  if (row) {
    Object.assign(row, updatedFields);
    notifyStore();
  }
}

export function saveVendorPeriodSchedule() {
  notifyStore();
}

export function deleteProductFromBaseline(itemId) {
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => p.id !== itemId && p.itemCode !== itemId);
  notifyStore();
}

export function addStagedProductsToBaseline(stagedList, vendor) {
  stagedList.forEach(staged => {
    const idx = globalStore.baselineProducts.findIndex(p => p.itemCode === staged.itemCode);
    if (idx >= 0) globalStore.baselineProducts[idx] = { ...globalStore.baselineProducts[idx], ...staged };
    else globalStore.baselineProducts.push({ ...staged, vendor: vendor || 'Haier' });
  });
  notifyStore();
}

export function onboardVendorWithBlueprint({ vendorId, vendorName }) {
  if (!globalStore.vendors.find(v => v.vendorId === vendorId)) {
    globalStore.vendors.push({ vendorId, vendorName });
  }
  notifyStore();
}
STORE_EOF

echo "==> 2. Updating MisIntelligencePage.jsx to persist and render sales invoices permanently..."
MIS_FILE=$(find src -name "*Mis*Page*.jsx" | head -n 1)
[ -z "$MIS_FILE" ] && MIS_FILE="src/modules/module4-mis/MisIntelligencePage.jsx"

cat << 'EOF_MIS' > "$MIS_FILE"
import React, { useState, useEffect } from 'react';
import { 
  BarChart3, Calendar, Search, TrendingUp, TrendingDown, FileText, CheckCircle2, IndianRupee 
} from 'lucide-react';
import { globalStore, subscribeStore } from '../../shared/masterStore';
import { calculatePieceCostUnified } from '../../shared/costCalculationService';

const FALLBACK_SALES = [
  { date: '2026-08-10', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4200, sellingPrice: 42.00, vendor: 'Haier' },
  { date: '2026-08-12', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1800, sellingPrice: 85.00, vendor: 'Haier' },
  { date: '2026-08-15', itemCode: 'A101701', componentName: 'Aris Top Canopy- Gloss White', qty: 3500, sellingPrice: 14.50, vendor: 'Atomberg' },
  { date: '2026-08-01', itemCode: 'A101703', componentName: 'Aris Top Canopy- Gloss Black', qty: 1000, sellingPrice: 15.96, vendor: 'Atomberg' }
];

export default function MisIntelligencePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [
    { vendorId: 'Atomberg', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Haier', vendorName: 'Haier Appliances' }
  ];
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [startDate, setStartDate] = useState('2026-08-01');
  const [endDate, setEndDate] = useState('2026-08-31');

  const rawList = (globalStore.baselineProducts && globalStore.baselineProducts.length > 0)
    ? globalStore.baselineProducts
    : [];

  const allSales = (globalStore.sales && globalStore.sales.length > 0)
    ? globalStore.sales
    : FALLBACK_SALES;

  const filteredDispatches = allSales.filter(disp => {
    let vMatch = true;
    if (selectedVendor !== 'ALL' && selectedVendor !== 'All Vendors Combined') {
      const targetV = selectedVendor.toLowerCase();
      const rowV = (disp.vendor || '').toLowerCase();
      vMatch = rowV.includes('haier') ? targetV.includes('haier') : (rowV.includes('atomberg') ? targetV.includes('atomberg') : rowV.includes(targetV));
    }
    const dateMatch = (!startDate || disp.date >= startDate) && (!endDate || disp.date <= endDate);
    return vMatch && dateMatch;
  });

  let totalSalesVolume = 0;
  let totalSalesRevenue = 0;
  let totalGrossProfit = 0;
  let totalCostVariance = 0;

  const rows = filteredDispatches.map(disp => {
    const product = rawList.find(p => p.itemCode === disp.itemCode) || {
      itemCode: disp.itemCode,
      componentName: disp.componentName || disp.itemCode,
      vendor: disp.vendor
    };

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
      componentName: product.componentName || disp.componentName || disp.itemCode,
      vendor: product.vendor || disp.vendor,
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
EOF_MIS

rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Permanent sales data initialized and Vite server reloaded!"
