#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js with unified parameter & RM audit logs..."
cat << 'STORE_EOF' > src/shared/masterStore.js
export const globalStore = {
  isGlobalLocked: true,

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
  ],

  purchases: [
    { id: 'pur-1', date: '2026-08-01', vendor: 'Haier', grade: 'ABS 300-B Red (Prime Inward)', qty: 4000, rate: 134.80, invoiceNo: 'INV-HR-01' },
    { id: 'pur-2', date: '2026-08-03', vendor: 'Haier', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 2500, rate: 98.40, invoiceNo: 'INV-HR-02' },
    { id: 'pur-3', date: '2026-08-05', vendor: 'Atomberg', grade: 'PP H110MA Prime Inward', qty: 5000, rate: 135.83, invoiceNo: 'INV-AT-01' }
  ],

  sales: [
    { id: 'disp-1', date: '2026-08-10', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4200, sellingPrice: 42.00, vendor: 'Haier' },
    { id: 'disp-2', date: '2026-08-12', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1800, sellingPrice: 85.00, vendor: 'Haier' },
    { id: 'disp-3', date: '2026-08-15', itemCode: 'A101701', componentName: 'Aris Top Canopy- Gloss White', qty: 3500, sellingPrice: 14.50, vendor: 'Atomberg' },
    { id: 'disp-4', date: '2026-08-01', itemCode: 'A101703', componentName: 'Aris Top Canopy- Gloss Black', qty: 1000, sellingPrice: 15.96, vendor: 'Atomberg' }
  ],

  parameterChangeLogs: [
    {
      id: 'param-log-1',
      timestamp: '2026-08-01 10:30 AM',
      partCode: '0060217989D',
      componentName: 'End cap Bottom Ref-ABS-DC-195,220',
      vendor: 'Haier',
      modifications: 'Cycle Time: 48s, Runner Wt: 40g',
      costImpact: '+ ₹0.28',
      authorizedBy: 'Plant Engineering Lead',
      reason: 'Shopfloor parameters & cost verification'
    }
  ],

  changeLogs: []
};

let listeners = [];
export function subscribeStore(fn) {
  listeners.push(fn);
  return () => { listeners = listeners.filter(l => l !== fn); };
}

export function notifyStore() {
  listeners.forEach(fn => fn());
}

export function toggleGlobalLock() {
  globalStore.isGlobalLocked = !globalStore.isGlobalLocked;
  notifyStore();
}

export function logChange({ module, entity, changeType, previousValue, newValue, reason }) {
  if (!globalStore.changeLogs) globalStore.changeLogs = [];
  globalStore.changeLogs.unshift({
    id: `log-${Date.now()}-${Math.random()}`,
    timestamp: new Date().toLocaleString(),
    user: 'Costing Lead',
    module,
    entity,
    changeType,
    previousValue: String(previousValue),
    newValue: String(newValue),
    reason: reason || 'Price Update'
  });
  notifyStore();
}

export function updateRmMappingRow(rowId, updatedFields, reason = 'Price / Alternate Update') {
  const row = (globalStore.rmMappingsData || []).find(r => r.id === rowId);
  if (row) {
    let prevVal = `₹${row.approvedPrice}`;
    if (updatedFields.activeAlt) {
      prevVal = `Active: ${row.activeAlt}`;
    }
    Object.assign(row, updatedFields);
    let newVal = updatedFields.approvedPrice !== undefined ? `₹${updatedFields.approvedPrice}` : `Active: ${updatedFields.activeAlt}`;
    
    logChange({
      module: 'RM Mapping',
      entity: `${row.vendor} - ${row.approvedCode}`,
      changeType: updatedFields.approvedPrice !== undefined ? 'Approved Price Update' : 'Alternate Selection',
      previousValue: prevVal,
      newValue: newVal,
      reason
    });
    notifyStore();
  }
}

export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  
  const p = updatedItem.parameters || {};
  if (updatedItem.parameters) prod.parameters = { ...prod.parameters, ...p };

  const summary = Object.entries(p)
    .filter(([_, v]) => v !== undefined && v !== null)
    .map(([k, v]) => `${k.replace('running', '')}: ${v}`)
    .join(', ');

  const newLog = {
    id: `param-log-${Date.now()}`,
    timestamp: new Date().toLocaleString(),
    partCode: prod.itemCode,
    componentName: prod.componentName,
    vendor: prod.vendor,
    modifications: summary || 'Shopfloor Specs Adjusted',
    costImpact: updatedItem.delta ? `₹${Number(updatedItem.delta).toFixed(2)}` : 'Live Calculated',
    authorizedBy: 'Costing Lead',
    reason: reason || 'Shopfloor parameters & cost verification'
  };

  if (!globalStore.parameterChangeLogs) globalStore.parameterChangeLogs = [];
  globalStore.parameterChangeLogs.unshift(newLog);

  logChange({
    module: 'Baseline Master',
    entity: `${prod.vendor} - ${prod.itemCode}`,
    changeType: 'Shopfloor Spec Drift Updated',
    previousValue: 'Previous Running Spec',
    newValue: summary,
    reason: reason || 'Shopfloor parameters & cost verification'
  });

  notifyStore();
}

export function getVendorBaselineData(vendorId) {
  const prods = globalStore.baselineProducts || [];
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

export function addDayWisePurchase(record) {
  if (!globalStore.purchases) globalStore.purchases = [];
  globalStore.purchases.unshift(record);
  notifyStore();
}

export function addDayWiseSales(record) {
  if (!globalStore.sales) globalStore.sales = [];
  globalStore.sales.unshift(record);
  notifyStore();
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

echo "==> 2. Synchronizing BaselineMasterPage.jsx Parameter Audit Log..."
BASELINE_PAGE=$(find src -name "*BaselineMasterPage*.jsx" | head -n 1)
if [ -n "$BASELINE_PAGE" ]; then
  cat << 'EOF_BM' > "$BASELINE_PAGE"
import React, { useState, useEffect } from 'react';
import { 
  Layers, Upload, Download, History, Search, Edit, Trash2, CheckCircle2, Sliders 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  getVendorBaselineData, 
  deleteProductFromBaseline,
  addStagedProductsToBaseline 
} from '../../shared/masterStore';
import InlineEditModal from '../../components/InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [activeTab, setActiveTab] = useState('parameters'); // 'parameters' | 'audit'
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);

  const rawProducts = getVendorBaselineData(selectedVendor);
  const paramLogs = globalStore.parameterChangeLogs || [];

  const filteredProducts = rawProducts.filter(p => {
    const q = searchQuery.toLowerCase();
    return (p.itemCode || '').toLowerCase().includes(q) || (p.componentName || '').toLowerCase().includes(q);
  });

  const filteredLogs = paramLogs.filter(log => {
    if (selectedVendor === 'ALL' || selectedVendor === 'All Vendors Combined' || !selectedVendor) return true;
    return (log.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase());
  });

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Layers className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master</h1>
            <p className="text-[11px] text-slate-300">Active Vendor: <b>{selectedVendor}</b> | Registered Parts: <b>{rawProducts.length} Active</b></p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <div className="flex bg-slate-800 p-1 rounded-xl border border-slate-700">
            <button
              onClick={() => setActiveTab('parameters')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}
            >
              Parameters Master ({rawProducts.length})
            </button>
            <button
              onClick={() => setActiveTab('audit')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'audit' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}
            >
              Parameter Audit Log ({filteredLogs.length})
            </button>
          </div>
        </div>
      </div>

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder="Search ALL components by part number or name..."
            className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-700">Switch Vendor:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
          >
            <option value="ALL">All Vendors Combined</option>
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>
        </div>
      </div>

      {activeTab === 'parameters' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">ITEM CODE</th>
                  <th className="p-3">COMPONENT NAME</th>
                  <th className="p-3 text-center">VENDOR</th>
                  <th className="p-3">APPROVED RM GRADE</th>
                  <th className="p-3 text-right">APPROVED RM RATE</th>
                  <th className="p-3 text-center">CAVITY</th>
                  <th className="p-3 text-right">NET WT (G)</th>
                  <th className="p-3 text-right">RUNNER WT (G)</th>
                  <th className="p-3 text-right">CYCLE TIME</th>
                  <th className="p-3 text-center">ACTION</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredProducts.map(p => (
                  <tr key={p.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono font-bold text-blue-700">{p.itemCode}</td>
                    <td className="p-3 font-semibold text-slate-900">{p.componentName}</td>
                    <td className="p-3 text-center">
                      <span className="px-2 py-0.5 bg-slate-100 border border-slate-300 rounded font-bold text-[10px] text-slate-700">
                        {p.vendor}
                      </span>
                    </td>
                    <td className="p-3 font-semibold text-slate-800">{p.approvedRm}</td>
                    <td className="p-3 text-right font-mono font-bold">₹{Number(p.approvedRmRate || 131).toFixed(2)}/kg</td>
                    <td className="p-3 text-center font-mono">{p.parameters?.runningCavity ?? p.cavity}</td>
                    <td className="p-3 text-right font-mono">{p.parameters?.runningNetWeight ?? p.netWeight}g</td>
                    <td className="p-3 text-right font-mono">{p.parameters?.runningRunnerWeight ?? p.runnerWeight}g</td>
                    <td className="p-3 text-right font-mono">{p.parameters?.runningCycleTime ?? p.cycleTimeApproved ?? p.cycleTime}s</td>
                    <td className="p-3 text-center">
                      <button
                        onClick={() => setEditingItem(p)}
                        className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1 mx-auto cursor-pointer shadow-xs"
                      >
                        <Edit className="w-3.5 h-3.5" /> Edit Spec
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeTab === 'audit' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <History className="w-4 h-4 text-blue-400" /> Engineering Parameter Audit Trail & Change Log ({selectedVendor})
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredLogs.length} Total Logs</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">TIMESTAMP</th>
                  <th className="p-3">PART CODE</th>
                  <th className="p-3">COMPONENT NAME</th>
                  <th className="p-3 text-center">VENDOR</th>
                  <th className="p-3">PARAMETER MODIFICATIONS</th>
                  <th className="p-3 text-center">COST IMPACT (Δ)</th>
                  <th className="p-3">AUTHORIZED BY</th>
                  <th className="p-3">AUDIT REASON / NOTE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredLogs.length === 0 ? (
                  <tr>
                    <td colSpan="8" className="text-center p-8 text-slate-400 italic">
                      No parameter modification logs recorded for {selectedVendor} yet. Use "Edit Spec" on any product to generate logs.
                    </td>
                  </tr>
                ) : (
                  filteredLogs.map(log => (
                    <tr key={log.id} className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-slate-500 text-[11px]">{log.timestamp}</td>
                      <td className="p-3 font-mono font-bold text-blue-700">{log.partCode}</td>
                      <td className="p-3 font-semibold text-slate-900">{log.componentName}</td>
                      <td className="p-3 text-center">
                        <span className="px-2 py-0.5 bg-slate-100 border border-slate-300 rounded font-bold text-[10px] text-slate-700">
                          {log.vendor}
                        </span>
                      </td>
                      <td className="p-3 font-mono text-blue-900 bg-blue-50/50">{log.modifications}</td>
                      <td className="p-3 text-center font-mono font-bold text-emerald-700">{log.costImpact}</td>
                      <td className="p-3 text-slate-700 font-bold">{log.authorizedBy}</td>
                      <td className="p-3 text-slate-600 italic">{log.reason}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {editingItem && (
        <InlineEditModal
          item={editingItem}
          onClose={() => setEditingItem(null)}
        />
      )}
    </div>
  );
}
EOF_BM
fi

echo "==> Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Parameter Audit Log & RM Change Logs are fully linked and active."
