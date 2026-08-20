#!/usr/bin/env bash
set -e

echo "==> 1. Restoring full masterStore.js with multi-alternate RM matrix, contract locks, schedules & sales..."
cat << 'STORE_EOF' > src/shared/masterStore.js
export const globalStore = {
  vendors: [
    { vendorId: 'Atomberg', vendorName: 'Atomberg Technologies', isLocked: true, lockedUntil: '2026-12-31' },
    { vendorId: 'Haier', vendorName: 'Haier Appliances', isLocked: false, lockedUntil: '2026-09-30' }
  ],

  rawMaterials: [
    {
      id: 'rm-at-1',
      vendor: 'Atomberg',
      grade: 'PP H110MA',
      approvedPrice: 131.00,
      validFrom: '2026-08-01',
      validTo: '2026-08-31',
      status: 'Active',
      alternates: [
        { id: 'alt-at-1a', activeGrade: 'PP H110MA Prime Inward', source: 'RIL Inward Lot A', activeWaPrice: 135.83, isDefault: true, variance: -4.83 },
        { id: 'alt-at-1b', activeGrade: 'PP H110MA Alt Blend (IOCL)', source: 'IOCL Spot Lot B', activeWaPrice: 133.50, isDefault: false, variance: -2.50 }
      ]
    },
    {
      id: 'rm-hr-1',
      vendor: 'Haier',
      grade: 'ABS 300 Pre Colour',
      approvedPrice: 136.20,
      validFrom: '2026-08-01',
      validTo: '2026-08-31',
      status: 'Active',
      alternates: [
        { id: 'alt-hr-1a', activeGrade: 'ABS 300-B Red (Prime Inward)', source: 'LG Chem Lot #44', activeWaPrice: 134.80, isDefault: true, variance: 1.40 },
        { id: 'alt-hr-1b', activeGrade: 'ABS 300-B Alt Pre-mix (Supreme)', source: 'Supreme Lot #12', activeWaPrice: 135.20, isDefault: false, variance: 1.00 }
      ]
    },
    {
      id: 'rm-hr-2',
      vendor: 'Haier',
      grade: 'GPPS SC201LV',
      approvedPrice: 100.00,
      validFrom: '2026-08-01',
      validTo: '2026-08-31',
      status: 'Active',
      alternates: [
        { id: 'alt-hr-2a', activeGrade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', source: 'Supreme Inward Lot G1', activeWaPrice: 98.40, isDefault: true, variance: 1.60 },
        { id: 'alt-hr-2b', activeGrade: 'GPPS SC206 Virgin Lot', source: 'RIL Prime Lot G2', activeWaPrice: 99.10, isDefault: false, variance: 0.90 }
      ]
    }
  ],

  masterbatches: [
    { id: 'mb-1', vendor: 'Atomberg', color: 'Black MB', grade: 'Black MB', approvedMbPrice: 250.00, activeMbWaPrice: 258.54, validFrom: '2026-08-01', validTo: '2026-08-31' },
    { id: 'mb-2', vendor: 'Atomberg', color: 'White MB', grade: 'White MB', approvedMbPrice: 250.00, activeMbWaPrice: 258.54, validFrom: '2026-08-01', validTo: '2026-08-31' },
    { id: 'mb-3', vendor: 'Haier', color: 'Standard Smoke Grey MB', grade: 'Smoke Grey MB', approvedMbPrice: 0.00, activeMbWaPrice: 0.00, validFrom: '2026-08-01', validTo: '2026-08-31' }
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

  purchases: [
    { id: 'pur-1', date: '2026-08-01', vendor: 'Atomberg', grade: 'PP H110MA', qty: 5000, rate: 135.83, invoiceNo: 'INV-AT-01' },
    { id: 'pur-2', date: '2026-08-01', vendor: 'Haier', grade: 'ABS 300 Pre Colour', qty: 4000, rate: 134.80, invoiceNo: 'INV-HR-01' },
    { id: 'pur-3', date: '2026-08-01', vendor: 'Haier', grade: 'GPPS SC201LV', qty: 2500, rate: 98.40, invoiceNo: 'INV-HR-02' }
  ],

  sales: [
    { date: '2026-08-10', itemCode: '0060217989D', qty: 4200, sellingPrice: 42.00, vendor: 'Haier' },
    { date: '2026-08-12', itemCode: '0060217978E', qty: 1800, sellingPrice: 85.00, vendor: 'Haier' },
    { date: '2026-08-15', itemCode: 'A101701', qty: 3500, sellingPrice: 14.50, vendor: 'Atomberg' },
    { date: '2026-08-01', itemCode: 'A101703', qty: 1000, sellingPrice: 15.96, vendor: 'Atomberg' }
  ],

  vendorSchedules: {},
  parameterChangeLogs: [],
  priceChangeLogs: []
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
  const prods = globalStore.baselineProducts || [];
  if (!vendorId || vendorId === 'ALL' || vendorId === 'All Vendors Combined') {
    return prods;
  }
  return prods.filter(p => (p.vendor || '').toLowerCase().includes(vendorId.toLowerCase()));
}

export function getActiveRmMapping(gradeName, vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase();
  const list = (globalStore.rawMaterials || []).filter(r => (r.vendor || '').toLowerCase().includes(vClean));
  const found = list.find(r => r.grade === gradeName) || list[0];
  if (!found) {
    return {
      approvedPrice: 131.00,
      activeWaPrice: 135.83,
      activeGrade: gradeName || 'Standard RM',
      alternates: []
    };
  }
  const defaultAlt = (found.alternates || []).find(a => a.isDefault) || (found.alternates || [])[0] || {};
  return {
    ...found,
    activeGrade: defaultAlt.activeGrade || found.grade,
    activeWaPrice: defaultAlt.activeWaPrice || found.approvedPrice
  };
}

export function getActiveMbMapping(vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase();
  const list = (globalStore.masterbatches || []).filter(m => (m.vendor || '').toLowerCase().includes(vClean));
  return list[0] || {
    approvedMbPrice: 250.00,
    activeMbWaPrice: 258.54
  };
}

export function updateBaselineParameters({ itemId, updatedItem, changeType, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
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

export function toggleVendorLockStatus(vendorId) {
  const v = (globalStore.vendors || []).find(item => item.vendorId.toLowerCase() === vendorId.toLowerCase());
  if (v) {
    v.isLocked = !v.isLocked;
    notifyStore();
  }
}

export function setDefaultAlternateRm(rmId, alternateId) {
  const rm = (globalStore.rawMaterials || []).find(r => r.id === rmId);
  if (rm && rm.alternates) {
    rm.alternates.forEach(alt => {
      alt.isDefault = (alt.id === alternateId);
    });
    notifyStore();
  }
}

export function updateRawMaterialPrice(rmId, updatedFields) {
  const rm = (globalStore.rawMaterials || []).find(r => r.id === rmId);
  if (rm) {
    Object.assign(rm, updatedFields);
    notifyStore();
  }
}

export function updateMasterbatchPrice(mbId, updatedFields) {
  const mb = (globalStore.masterbatches || []).find(m => m.id === mbId);
  if (mb) {
    Object.assign(mb, updatedFields);
    notifyStore();
  }
}

export function addRawMaterialInward(inwardData) {
  if (!globalStore.purchases) globalStore.purchases = [];
  globalStore.purchases.push(inwardData);
  notifyStore();
}

export function uploadBulkPurchases(records) {
  if (!globalStore.purchases) globalStore.purchases = [];
  if (Array.isArray(records)) {
    globalStore.purchases.push(...records);
  }
  notifyStore();
}

export function uploadBulkSales(records) {
  if (!globalStore.sales) globalStore.sales = [];
  if (Array.isArray(records)) {
    globalStore.sales.push(...records);
  }
  notifyStore();
}

export function deleteProductFromBaseline(itemId) {
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(
    p => p.id !== itemId && p.itemCode !== itemId
  );
  notifyStore();
}

export function addStagedProductsToBaseline(stagedList, vendor) {
  if (!globalStore.baselineProducts) globalStore.baselineProducts = [];
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

export function onboardVendorWithBlueprint({ vendorId, vendorName, blueprintType, customLines = [] }) {
  if (!globalStore.vendors) globalStore.vendors = [];
  const existing = globalStore.vendors.find(v => v.vendorId === vendorId);
  if (!existing) {
    globalStore.vendors.push({ vendorId, vendorName, isLocked: false });
  }
  notifyStore();
}

export function updateVendorScheduleBulk(vendorId, scheduleData) {
  if (!globalStore.vendorSchedules) globalStore.vendorSchedules = {};
  globalStore.vendorSchedules[vendorId] = scheduleData;
  notifyStore();
}
STORE_EOF

echo "==> 2. Restoring full rich RMPriceMatrixPage.jsx with Lock/Unlock, Date Validity, and Multi-Alternates..."
RM_FILE=$(find src -name "*RMPriceMatrixPage*.jsx" | head -n 1)
[ -z "$RM_FILE" ] && RM_FILE="src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx"

cat << 'EOF_RM' > "$RM_FILE"
import React, { useState, useEffect } from 'react';
import { 
  Database, Search, Lock, Unlock, TrendingUp, TrendingDown, Layers, 
  Upload, ShieldCheck, RefreshCw, Calendar, CheckCircle2, AlertTriangle, ArrowRight 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  toggleVendorLockStatus, 
  setDefaultAlternateRm, 
  addRawMaterialInward,
  updateRawMaterialPrice 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore?.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [activeSubTab, setActiveSubTab] = useState('rm');
  const [searchQuery, setSearchQuery] = useState('');
  const [validityStart, setValidityStart] = useState('2026-08-01');
  const [validityEnd, setValidityEnd] = useState('2026-08-31');

  const rawMaterialsList = Array.isArray(globalStore?.rawMaterials) ? globalStore.rawMaterials : [];
  const masterbatchList = Array.isArray(globalStore?.masterbatches) ? globalStore.masterbatches : [];
  const purchaseList = Array.isArray(globalStore?.purchases) ? globalStore.purchases : [];

  const filteredRm = rawMaterialsList.filter(item => {
    const matchesVendor = (selectedVendor === 'ALL' || selectedVendor === 'All Vendors Combined') 
      ? true 
      : (item?.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase());
    const matchesSearch = (item?.grade || '').toLowerCase().includes(searchQuery.toLowerCase());
    return matchesVendor && matchesSearch;
  });

  const filteredMb = masterbatchList.filter(item => {
    const matchesVendor = (selectedVendor === 'ALL' || selectedVendor === 'All Vendors Combined') 
      ? true 
      : (item?.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase());
    const matchesSearch = (item?.color || item?.grade || '').toLowerCase().includes(searchQuery.toLowerCase());
    return matchesVendor && matchesSearch;
  });

  const filteredPurchases = purchaseList.filter(item => {
    const matchesVendor = (selectedVendor === 'ALL' || selectedVendor === 'All Vendors Combined') 
      ? true 
      : (item?.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase());
    const matchesSearch = (item?.grade || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
                          (item?.invoiceNo || '').toLowerCase().includes(searchQuery.toLowerCase());
    return matchesVendor && matchesSearch;
  });

  const currentVendorObj = vendors.find(v => v.vendorId.toLowerCase() === selectedVendor.toLowerCase());

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">2. Raw Material & Masterbatch Matrix</h1>
            <p className="text-[11px] text-slate-300">Multi-Vendor Inward Weighted Average, Alternate Lot Selection & Contract Validity</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="flex bg-slate-800 p-1 rounded-xl border border-slate-700">
            <button
              onClick={() => setActiveSubTab('rm')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeSubTab === 'rm' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}
            >
              Polymer RM Matrix ({filteredRm.length})
            </button>
            <button
              onClick={() => setActiveSubTab('mb')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeSubTab === 'mb' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}
            >
              Masterbatch Matrix ({filteredMb.length})
            </button>
            <button
              onClick={() => setActiveSubTab('inward')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeSubTab === 'inward' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}
            >
              Inward Transactions ({filteredPurchases.length})
            </button>
          </div>
        </div>
      </div>

      <div className="bg-white p-3.5 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search polymers, grades, alternates, or invoices..."
            className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
          />
        </div>

        <div className="flex items-center gap-2 bg-slate-50 px-3 py-1 rounded-xl border">
          <Calendar className="w-4 h-4 text-slate-500" />
          <span className="font-bold text-slate-600 text-[11px]">CONTRACT PERIOD:</span>
          <input type="date" value={validityStart} onChange={e => setValidityStart(e.target.value)} className="border px-2 py-0.5 rounded text-xs bg-white" />
          <span className="text-slate-400">&rarr;</span>
          <input type="date" value={validityEnd} onChange={e => setValidityEnd(e.target.value)} className="border px-2 py-0.5 rounded text-xs bg-white" />
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

          {currentVendorObj && (
            <button
              onClick={() => toggleVendorLockStatus(currentVendorObj.vendorId)}
              className={`px-3 py-1.5 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-xs transition-colors ${currentVendorObj.isLocked ? 'bg-amber-600 hover:bg-amber-700 text-white' : 'bg-slate-100 hover:bg-slate-200 text-slate-800 border'}`}
            >
              {currentVendorObj.isLocked ? <Lock className="w-3.5 h-3.5" /> : <Unlock className="w-3.5 h-3.5" />}
              {currentVendorObj.isLocked ? 'Contract Locked' : 'Unlocked'}
            </button>
          )}
        </div>
      </div>

      {activeSubTab === 'rm' && (
        <div className="space-y-4">
          {filteredRm.map((rm) => (
            <div key={rm.id} className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
              <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
                <div className="flex items-center gap-2">
                  <span className="px-2 py-0.5 bg-blue-600 rounded font-bold text-[11px]">{rm.vendor}</span>
                  <span className="font-mono font-bold text-sm text-amber-300">{rm.grade}</span>
                  <span className="text-[11px] text-slate-300">Approved Baseline: <b className="text-white">₹{Number(rm.approvedPrice).toFixed(2)}/kg</b></span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-[11px] text-slate-300 font-mono">Valid: {rm.validFrom} to {rm.validTo}</span>
                  <span className="px-2 py-0.5 bg-emerald-500/20 text-emerald-300 border border-emerald-500/40 rounded font-bold text-[10px]">
                    {rm.alternates?.length || 0} Alternates Active
                  </span>
                </div>
              </div>

              <div className="overflow-x-auto">
                <table className="min-w-full text-xs text-left">
                  <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b">
                    <tr>
                      <th className="p-3">INWARD ALTERNATE GRADE</th>
                      <th className="p-3">SOURCE LOT / VENDOR</th>
                      <th className="p-3 text-right">WEIGHTED AVG RATE</th>
                      <th className="p-3 text-center">PRICE VARIANCE (Δ)</th>
                      <th className="p-3 text-center">ACTIVE STATUS</th>
                      <th className="p-3 text-center">ACTION</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-200 font-medium">
                    {rm.alternates?.map((alt) => (
                      <tr key={alt.id} className={alt.isDefault ? 'bg-blue-50/40 font-semibold' : 'hover:bg-slate-50'}>
                        <td className="p-3 font-bold text-slate-900 flex items-center gap-1.5">
                          {alt.isDefault && <CheckCircle2 className="w-4 h-4 text-blue-600" />}
                          {alt.activeGrade}
                        </td>
                        <td className="p-3 text-slate-600">{alt.source}</td>
                        <td className="p-3 text-right font-mono font-bold text-blue-900">₹{Number(alt.activeWaPrice).toFixed(2)}/kg</td>
                        <td className="p-3 text-center">
                          <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-lg text-xs font-mono font-bold ${alt.variance >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                            {alt.variance >= 0 ? `+₹${alt.variance.toFixed(2)}` : `-₹${Math.abs(alt.variance).toFixed(2)}`}
                          </span>
                        </td>
                        <td className="p-3 text-center">
                          {alt.isDefault ? (
                            <span className="px-2 py-0.5 bg-blue-600 text-white rounded-md text-[10px] font-bold">Active In Costing</span>
                          ) : (
                            <span className="text-slate-400 text-[11px]">Alternate</span>
                          )}
                        </td>
                        <td className="p-3 text-center">
                          {!alt.isDefault && (
                            <button
                              onClick={() => setDefaultAlternateRm(rm.id, alt.id)}
                              className="px-2.5 py-1 bg-white border border-blue-600 text-blue-700 hover:bg-blue-50 rounded-lg font-bold text-[11px] cursor-pointer"
                            >
                              Set Active
                            </button>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          ))}
        </div>
      )}

      {activeSubTab === 'mb' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <Layers className="w-4 h-4 text-purple-400" /> Masterbatch Pricing & Shade Matrix
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredMb.length} Active Masterbatches</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b">
                <tr>
                  <th className="p-3">VENDOR</th>
                  <th className="p-3">COLOR / SHADE</th>
                  <th className="p-3 text-right">APPROVED MB RATE</th>
                  <th className="p-3 text-right">ACTIVE WA INWARD RATE</th>
                  <th className="p-3 text-center">PRICE VARIANCE (Δ)</th>
                  <th className="p-3 text-center">VALIDITY</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredMb.map((mb) => {
                  const variance = Number(mb.approvedMbPrice) - Number(mb.activeMbWaPrice);
                  return (
                    <tr key={mb.id} className="hover:bg-slate-50">
                      <td className="p-3 font-bold text-slate-900">{mb.vendor}</td>
                      <td className="p-3 font-semibold text-purple-900">{mb.color}</td>
                      <td className="p-3 text-right font-mono font-bold text-slate-900">₹{Number(mb.approvedMbPrice).toFixed(2)}/kg</td>
                      <td className="p-3 text-right font-mono font-bold text-purple-700">₹{Number(mb.activeMbWaPrice).toFixed(2)}/kg</td>
                      <td className="p-3 text-center">
                        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-lg text-xs font-mono font-bold ${variance >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                          {variance >= 0 ? `+₹${variance.toFixed(2)}` : `-₹${Math.abs(variance).toFixed(2)}`}
                        </span>
                      </td>
                      <td className="p-3 text-center font-mono text-slate-500 text-[11px]">{mb.validFrom} to {mb.validTo}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeSubTab === 'inward' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <RefreshCw className="w-4 h-4 text-emerald-400" /> Inward Purchase Registry & Graded Lots
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredPurchases.length} Purchase Lots</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b">
                <tr>
                  <th className="p-3">DATE</th>
                  <th className="p-3">INVOICE NO</th>
                  <th className="p-3">VENDOR</th>
                  <th className="p-3">POLYMER GRADE</th>
                  <th className="p-3 text-right">QUANTITY (KG)</th>
                  <th className="p-3 text-right">INVOICE RATE (₹/KG)</th>
                  <th className="p-3 text-right">TOTAL VALUE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredPurchases.map((pur) => (
                  <tr key={pur.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500">{pur.date}</td>
                    <td className="p-3 font-mono font-bold text-blue-700">{pur.invoiceNo}</td>
                    <td className="p-3 font-bold text-slate-900">{pur.vendor}</td>
                    <td className="p-3 font-semibold text-slate-800">{pur.grade}</td>
                    <td className="p-3 text-right font-mono font-bold">{Number(pur.qty).toLocaleString()} kg</td>
                    <td className="p-3 text-right font-mono font-bold text-emerald-700">₹{Number(pur.rate).toFixed(2)}</td>
                    <td className="p-3 text-right font-mono font-black text-slate-900">₹{(Number(pur.qty) * Number(pur.rate)).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
EOF_RM

echo "==> 3. Restoring full MisIntelligencePage.jsx with accurate vendor filtering..."
MIS_FILE=$(find src -name "*Mis*Page*.jsx" | head -n 1)
[ -z "$MIS_FILE" ] && MIS_FILE="src/modules/module4-mis/MisIntelligencePage.jsx"

cat << 'EOF_MIS' > "$MIS_FILE"
import React, { useState, useEffect } from 'react';
import { 
  BarChart3, Calendar, Search, TrendingUp, TrendingDown, FileText 
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

  const rawList = globalStore.baselineProducts || [];
  const allSales = globalStore.sales || [];

  const filteredDispatches = allSales.filter(disp => {
    const vMatch = (selectedVendor === 'ALL' || selectedVendor === 'All Vendors Combined')
      ? true
      : (disp.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase());
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
      componentName: disp.itemCode,
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
      componentName: product.componentName,
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

echo "==> Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Project completely restored with full logic, multi-alternates, contract locking & accurate MIS filters."
