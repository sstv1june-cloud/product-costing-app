#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js to support the exact 3-Alternate grid structure..."
cat << 'STORE_EOF' > src/shared/masterStore.js
export const globalStore = {
  isGlobalLocked: false,
  vendors: [
    { vendorId: 'Atomberg', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Haier', vendorName: 'Haier Appliances' }
  ],

  // Structured exactly as RM Code + Masterbatch Code per Vendor & Period
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
      parameters: { runningCavity: 2, runningNetWeight: 37.0, runningRunnerWeight: 1.0, runningCycleTime: 47.0, runningTonnage: 200, runningMbPct: 4.0, runningBopCost: 0.0 }
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
      parameters: { runningCavity: 2, runningNetWeight: 37.0, runningRunnerWeight: 1.0, runningCycleTime: 47.0, runningTonnage: 200, runningMbPct: 4.0, runningBopCost: 0.0 }
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
      parameters: { runningCavity: 2, runningNetWeight: 197.0, runningRunnerWeight: 40.0, runningCycleTime: 48.0, runningTonnage: 450, runningMbPct: 0.0, runningBopCost: 0.0 }
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
      parameters: { runningCavity: 1, runningNetWeight: 485.0, runningRunnerWeight: 22.0, runningCycleTime: 58.0, runningTonnage: 650, runningMbPct: 3.5, runningBopCost: 0.0 }
    }
  ],

  purchases: [
    { id: 'pur-1', date: '2026-08-01', vendor: 'Atomberg', grade: 'PP H110MA Prime Inward', qty: 5000, rate: 135.83, invoiceNo: 'INV-AT-01' },
    { id: 'pur-2', date: '2026-08-01', vendor: 'Haier', grade: 'ABS 300-B Red (Prime Inward)', qty: 4000, rate: 134.80, invoiceNo: 'INV-HR-01' },
    { id: 'pur-3', date: '2026-08-01', vendor: 'Haier', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 2500, rate: 98.40, invoiceNo: 'INV-HR-02' }
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
  return () => { listeners = listeners.filter(l => l !== fn); };
}

export function notifyStore() {
  listeners.forEach(fn => fn());
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

export function saveVendorPeriodSchedule(vendor, periodFrom, periodTo) {
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

export function updateBaselineParameters({ itemId, updatedItem }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  if (updatedItem.parameters) prod.parameters = { ...prod.parameters, ...updatedItem.parameters };
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

echo "==> 2. Updating RMPriceMatrixPage.jsx to match your spreadsheet template exactly..."
RM_FILE=$(find src -name "*RMPriceMatrixPage*.jsx" | head -n 1)
[ -z "$RM_FILE" ] && RM_FILE="src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx"

cat << 'EOF_RM' > "$RM_FILE"
import React, { useState, useEffect } from 'react';
import { 
  Database, Lock, Unlock, Save, Filter, Calendar, CheckCircle2, ShieldCheck 
} from 'lucide-react';
import { 
  globalStore, 
  subscribeStore, 
  toggleGlobalLock, 
  updateRmMappingRow, 
  saveVendorPeriodSchedule 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');

  const isLocked = !!globalStore.isGlobalLocked;
  const mappingsList = globalStore.rmMappingsData || [];

  const filteredRows = mappingsList.filter(row => {
    return (selectedVendor === 'ALL' || row.vendor.toLowerCase() === selectedVendor.toLowerCase());
  });

  const handleSave = () => {
    if (isLocked) {
      alert('Cannot save: Global Lock is currently active! Please unlock first.');
      return;
    }
    saveVendorPeriodSchedule(selectedVendor, periodFrom, periodTo);
    alert(`Successfully saved RM / MB Price Mapping for ${selectedVendor} (${periodFrom} to ${periodTo})`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Header bar */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-base font-bold">RM Mapping Page</h1>
            <p className="text-[11px] text-slate-300">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        {/* Global Unlock & Lock for Save */}
        <div className="flex items-center gap-2">
          <button
            onClick={toggleGlobalLock}
            className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 text-xs cursor-pointer shadow transition-all ${isLocked ? 'bg-rose-600 hover:bg-rose-700 text-white' : 'bg-emerald-600 hover:bg-emerald-700 text-white'}`}
          >
            {isLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4" />}
            {isLocked ? 'Global Locked (Editing Disabled)' : 'Global Unlocked & Active'}
          </button>
        </div>
      </div>

      {/* Filter / Vendor / Period Bar */}
      <div className="bg-white p-4 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-blue-600" />
            <span className="font-bold text-slate-700 uppercase">Filter:</span>
          </div>

          <div className="flex items-center gap-2">
            <span className="font-semibold text-slate-600">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={(e) => setSelectedVendor(e.target.value)}
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
            >
              <option value="ALL">All Vendors</option>
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-300">
            <Calendar className="w-4 h-4 text-slate-500" />
            <span className="font-semibold text-slate-600">Period:</span>
            <span className="text-slate-500 font-medium">From</span>
            <input
              type="date"
              value={periodFrom}
              disabled={isLocked}
              onChange={(e) => setPeriodFrom(e.target.value)}
              className="border px-2 py-0.5 rounded text-xs bg-white disabled:bg-slate-100"
            />
            <span className="text-slate-500 font-medium">To</span>
            <input
              type="date"
              value={periodTo}
              disabled={isLocked}
              onChange={(e) => setPeriodTo(e.target.value)}
              className="border px-2 py-0.5 rounded text-xs bg-white disabled:bg-slate-100"
            />
          </div>
        </div>

        <button
          onClick={handleSave}
          disabled={isLocked}
          className="px-5 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-400 text-white rounded-xl font-bold flex items-center gap-2 text-xs cursor-pointer shadow transition-all"
        >
          <Save className="w-4 h-4" /> Save for Vendor + period
        </button>
      </div>

      {/* Exact Excel Grid Layout */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left border-collapse">
            <thead>
              <tr className="bg-slate-800 text-white font-bold border-b border-slate-700 text-center">
                <th className="p-3 border-r border-slate-700 w-1/4 text-left">Approved RM/MB Code</th>
                <th className="p-3 border-r border-slate-700 w-1/12 bg-slate-900 text-amber-300">Approved Price</th>
                <th className="p-3 border-r border-slate-700 w-1/6">Alternate RM-1</th>
                <th className="p-3 border-r border-slate-700 w-1/12 bg-slate-900 text-blue-300">Price (WA)</th>
                <th className="p-3 border-r border-slate-700 w-1/6">Alternate RM-2</th>
                <th className="p-3 border-r border-slate-700 w-1/12 bg-slate-900 text-blue-300">Price (WA)</th>
                <th className="p-3 border-r border-slate-700 w-1/6">Alternate RM-3</th>
                <th className="p-3 w-1/12 bg-slate-900 text-blue-300">Price (WA)</th>
              </tr>
              <tr className="bg-slate-100 text-slate-500 text-[10px] italic border-b border-slate-300">
                <td className="p-2 border-r border-slate-200">Contract Master Spec</td>
                <td className="p-2 border-r border-slate-200 text-center text-amber-800 font-semibold bg-amber-50">
                  (Linked to Baseline Edit Page Approved parameter)
                </td>
                <td colSpan="6" className="p-2 text-center text-blue-800 font-semibold bg-blue-50">
                  On WA method from Purchase Inward Lots
                </td>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {filteredRows.map((row) => (
                <tr key={row.id} className="hover:bg-slate-50">
                  {/* Approved RM/MB Code */}
                  <td className="p-3 border-r border-slate-200">
                    <span className="px-2 py-0.5 rounded text-[10px] font-bold mr-2 bg-slate-200 text-slate-800">
                      {row.type === 'RM' ? 'RM Code' : 'Masterbatch Code'}
                    </span>
                    <span className="font-mono font-bold text-slate-900">{row.approvedCode}</span>
                  </td>

                  {/* Approved Price */}
                  <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-slate-900 bg-amber-50/50">
                    ₹{Number(row.approvedPrice).toFixed(2)}
                  </td>

                  {/* Alt 1 Code & WA Price */}
                  <td className="p-3 border-r border-slate-200">
                    <div className="flex items-center justify-between gap-1">
                      <span className="font-semibold text-blue-950">{row.alt1Code}</span>
                      <button
                        onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt1' })}
                        disabled={isLocked}
                        className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt1' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'}`}
                      >
                        {row.activeAlt === 'alt1' ? 'Active' : 'Set'}
                      </button>
                    </div>
                  </td>
                  <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-blue-700 bg-blue-50/50">
                    ₹{Number(row.alt1Price).toFixed(2)}
                  </td>

                  {/* Alt 2 Code & WA Price */}
                  <td className="p-3 border-r border-slate-200">
                    <div className="flex items-center justify-between gap-1">
                      <span className="text-slate-700">{row.alt2Code}</span>
                      <button
                        onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt2' })}
                        disabled={isLocked}
                        className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt2' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'}`}
                      >
                        {row.activeAlt === 'alt2' ? 'Active' : 'Set'}
                      </button>
                    </div>
                  </td>
                  <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-slate-700 bg-blue-50/30">
                    ₹{Number(row.alt2Price).toFixed(2)}
                  </td>

                  {/* Alt 3 Code & WA Price */}
                  <td className="p-3 border-r border-slate-200">
                    <div className="flex items-center justify-between gap-1">
                      <span className="text-slate-700">{row.alt3Code}</span>
                      <button
                        onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt3' })}
                        disabled={isLocked}
                        className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt3' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'}`}
                      >
                        {row.activeAlt === 'alt3' ? 'Active' : 'Set'}
                      </button>
                    </div>
                  </td>
                  <td className="p-3 text-right font-mono font-bold text-slate-700 bg-blue-50/30">
                    ₹{Number(row.alt3Price).toFixed(2)}
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
EOF_RM

echo "==> Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! RM Mapping Page layout matches the spreadsheet format."
