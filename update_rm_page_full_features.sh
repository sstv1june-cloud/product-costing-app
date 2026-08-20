#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js with default-locked state and audit logging..."
cat << 'STORE_EOF' > src/shared/masterStore.js
export const globalStore = {
  // Default to LOCKED state
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

  // Full Change Log & Audit Trail
  changeLogs: [
    {
      id: 'log-1',
      timestamp: '2026-08-01 10:15 AM',
      user: 'Costing Lead',
      module: 'RM Price Matrix',
      entity: 'PP H110MA',
      changeType: 'Price Baseline Initialization',
      previousValue: '₹128.50',
      newValue: '₹131.00',
      reason: 'Contractual Q3 Index Revision'
    },
    {
      id: 'log-2',
      timestamp: '2026-08-02 02:30 PM',
      user: 'Plant Manager',
      module: 'Baseline Specs',
      entity: '0060217989D',
      changeType: 'Cycle Time Tuning',
      previousValue: '50.0s',
      newValue: '48.0s',
      reason: 'Mould cooling optimization verification'
    }
  ]
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
    id: `log-${Date.now()}`,
    timestamp: new Date().toLocaleString(),
    user: 'System User',
    module,
    entity,
    changeType,
    previousValue,
    newValue,
    reason: reason || 'Parameters Updated'
  });
  notifyStore();
}

export function updateRmMappingRow(rowId, updatedFields, reason = 'Price / Alternate Update') {
  const row = (globalStore.rmMappingsData || []).find(r => r.id === rowId);
  if (row) {
    const prev = JSON.stringify(row);
    Object.assign(row, updatedFields);
    logChange({
      module: 'RM Mapping',
      entity: `${row.vendor} - ${row.approvedCode}`,
      changeType: 'RM / Alternate Rate Modification',
      previousValue: prev,
      newValue: JSON.stringify(updatedFields),
      reason
    });
    notifyStore();
  }
}

export function addDayWisePurchase(record) {
  if (!globalStore.purchases) globalStore.purchases = [];
  globalStore.purchases.unshift(record);
  logChange({
    module: 'Day-wise Purchase',
    entity: record.invoiceNo || record.grade,
    changeType: 'Inward Lot Ingested',
    previousValue: '-',
    newValue: `${record.qty} kg @ ₹${record.rate}`,
    reason: 'Purchase Inward File Upload'
  });
  notifyStore();
}

export function addDayWiseSales(record) {
  if (!globalStore.sales) globalStore.sales = [];
  globalStore.sales.unshift(record);
  logChange({
    module: 'Day-wise Sales',
    entity: record.itemCode,
    changeType: 'Sales Dispatch Ingested',
    previousValue: '-',
    newValue: `${record.qty} pcs @ ₹${record.sellingPrice}`,
    reason: 'Sales Invoice File Upload'
  });
  notifyStore();
}

export function saveVendorPeriodSchedule() {
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

export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  if (updatedItem.parameters) prod.parameters = { ...prod.parameters, ...updatedItem.parameters };
  logChange({
    module: 'Baseline Specs',
    entity: prod.itemCode,
    changeType: 'Shopfloor Spec Drift Updated',
    previousValue: 'Baseline Baseline',
    newValue: JSON.stringify(updatedItem.parameters || {}),
    reason: reason || 'Parameter Edit'
  });
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

echo "==> 2. Rewriting RMPriceMatrixPage.jsx with Default-Locked safety, Day-wise Uploads & Change Log View..."
RM_FILE=$(find src -name "*RMPriceMatrixPage*.jsx" | head -n 1)
[ -z "$RM_FILE" ] && RM_FILE="src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx"

cat << 'EOF_RM' > "$RM_FILE"
import React, { useState, useEffect } from 'react';
import { 
  Database, Lock, Unlock, Save, Filter, Calendar, CheckCircle2, 
  Upload, FileSpreadsheet, History, ShoppingCart, Truck, Plus, AlertCircle, Edit3 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  toggleGlobalLock, 
  updateRmMappingRow, 
  saveVendorPeriodSchedule,
  addDayWisePurchase,
  addDayWiseSales 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [activeSubTab, setActiveSubTab] = useState('matrix'); // 'matrix' | 'purchases' | 'sales' | 'changelog'

  const isLocked = globalStore.isGlobalLocked ?? true;
  const mappingsList = globalStore.rmMappingsData || [];
  const purchasesList = globalStore.purchases || [];
  const salesList = globalStore.sales || [];
  const changeLogs = globalStore.changeLogs || [];

  const filteredRows = mappingsList.filter(row => {
    return (selectedVendor === 'ALL' || row.vendor.toLowerCase() === selectedVendor.toLowerCase());
  });

  const filteredPurchases = purchasesList.filter(p => {
    return (selectedVendor === 'ALL' || (p.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()));
  });

  const filteredSales = salesList.filter(s => {
    return (selectedVendor === 'ALL' || (s.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()));
  });

  const handlePriceChange = (rowId, newPrice) => {
    if (isLocked) return;
    const num = parseFloat(newPrice);
    updateRmMappingRow(rowId, { approvedPrice: isNaN(num) ? '' : num });
  };

  const handleSave = () => {
    if (isLocked) {
      alert('Cannot save: Page is LOCKED. Click "Unlock to Edit" first.');
      return;
    }
    saveVendorPeriodSchedule();
    alert(`Successfully saved RM / MB Price Mapping for ${selectedVendor} (${periodFrom} to ${periodTo})`);
  };

  // Day-wise Purchases Ingest
  const handlePurchaseUpload = (e) => {
    if (isLocked) {
      alert('Please Unlock the page before uploading purchases!');
      return;
    }
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const wb = XLSX.read(evt.target.result, { type: 'binary' });
        const data = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]]);
        data.forEach((row, i) => {
          addDayWisePurchase({
            id: `pur-up-${Date.now()}-${i}`,
            date: row['Date'] || new Date().toISOString().slice(0, 10),
            vendor: row['Vendor'] || selectedVendor,
            grade: row['Grade'] || row['Material'] || 'ABS 300-B',
            qty: Number(row['Qty'] || row['Quantity'] || 1000),
            rate: Number(row['Rate'] || row['Price'] || 130.00),
            invoiceNo: row['Invoice'] || `INV-${Math.floor(1000 + Math.random() * 9000)}`
          });
        });
        alert(`Successfully imported ${data.length} day-wise purchase records!`);
      } catch (err) {
        alert('Failed to parse purchase file.');
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  // Day-wise Sales Ingest
  const handleSalesUpload = (e) => {
    if (isLocked) {
      alert('Please Unlock the page before uploading sales!');
      return;
    }
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const wb = XLSX.read(evt.target.result, { type: 'binary' });
        const data = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]]);
        data.forEach((row, i) => {
          addDayWiseSales({
            id: `disp-up-${Date.now()}-${i}`,
            date: row['Date'] || new Date().toISOString().slice(0, 10),
            vendor: row['Vendor'] || selectedVendor,
            itemCode: row['ItemCode'] || row['PartCode'] || '0060217989D',
            componentName: row['ComponentName'] || row['ItemCode'] || 'Injected Component',
            qty: Number(row['Qty'] || row['Quantity'] || 1000),
            sellingPrice: Number(row['Price'] || row['SellingPrice'] || 45.00)
          });
        });
        alert(`Successfully imported ${data.length} day-wise sales dispatch records!`);
      } catch (err) {
        alert('Failed to parse sales file.');
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Header bar with Always-Locked Toggle */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-base font-bold">RM Mapping & Inward Registry</h1>
            <p className="text-[11px] text-slate-300">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        {/* Global Lock / Unlock */}
        <div className="flex items-center gap-2">
          <button
            onClick={toggleGlobalLock}
            className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 text-xs cursor-pointer shadow transition-all ${isLocked ? 'bg-amber-600 hover:bg-amber-700 text-white' : 'bg-emerald-600 hover:bg-emerald-700 text-white'}`}
          >
            {isLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4 text-white" />}
            {isLocked ? 'Page Locked (Click to Unlock & Edit)' : 'Page Unlocked (Editing Active)'}
          </button>
        </div>
      </div>

      {/* Navigation Sub-Tabs */}
      <div className="flex bg-slate-200 p-1.5 rounded-2xl border border-slate-300 gap-1.5 w-fit">
        <button
          onClick={() => setActiveSubTab('matrix')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'matrix' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <FileSpreadsheet className="w-4 h-4" /> RM Price Matrix
        </button>
        <button
          onClick={() => setActiveSubTab('purchases')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'purchases' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <ShoppingCart className="w-4 h-4 text-emerald-300" /> Day-wise Purchases ({filteredPurchases.length})
        </button>
        <button
          onClick={() => setActiveSubTab('sales')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'sales' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <Truck className="w-4 h-4 text-purple-300" /> Day-wise Sales ({filteredSales.length})
        </button>
        <button
          onClick={() => setActiveSubTab('changelog')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'changelog' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <History className="w-4 h-4 text-amber-300" /> Baseline & RM Change Log ({changeLogs.length})
        </button>
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
              <option value="ALL">All Vendors Combined</option>
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
              className="border px-2 py-0.5 rounded text-xs bg-white disabled:bg-slate-100 cursor-pointer"
            />
            <span className="text-slate-500 font-medium">To</span>
            <input
              type="date"
              value={periodTo}
              disabled={isLocked}
              onChange={(e) => setPeriodTo(e.target.value)}
              className="border px-2 py-0.5 rounded text-xs bg-white disabled:bg-slate-100 cursor-pointer"
            />
          </div>
        </div>

        <div className="flex items-center gap-2">
          {activeSubTab === 'purchases' && (
            <label className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 text-xs shadow transition-all cursor-pointer ${isLocked ? 'bg-slate-400 text-white cursor-not-allowed' : 'bg-emerald-600 hover:bg-emerald-700 text-white'}`}>
              <Upload className="w-4 h-4" /> Upload Day-wise Purchases (.xlsx)
              <input type="file" accept=".xlsx, .xls, .csv" disabled={isLocked} onChange={handlePurchaseUpload} className="hidden" />
            </label>
          )}
          {activeSubTab === 'sales' && (
            <label className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 text-xs shadow transition-all cursor-pointer ${isLocked ? 'bg-slate-400 text-white cursor-not-allowed' : 'bg-purple-600 hover:bg-purple-700 text-white'}`}>
              <Upload className="w-4 h-4" /> Upload Day-wise Sales (.xlsx)
              <input type="file" accept=".xlsx, .xls, .csv" disabled={isLocked} onChange={handleSalesUpload} className="hidden" />
            </label>
          )}
          {activeSubTab === 'matrix' && (
            <button
              onClick={handleSave}
              disabled={isLocked}
              className="px-5 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-400 text-white rounded-xl font-bold flex items-center gap-2 text-xs cursor-pointer shadow transition-all"
            >
              <Save className="w-4 h-4" /> Save for Vendor + period
            </button>
          )}
        </div>
      </div>

      {/* Lock Notice Banner */}
      {isLocked && (
        <div className="bg-amber-50 border border-amber-300 rounded-xl p-3 flex items-center gap-2 text-amber-900 text-xs">
          <Lock className="w-4 h-4 text-amber-600 shrink-0" />
          <span><b>Protected State:</b> This page is locked against unauthorized modifications. Click <b>"Page Locked (Click to Unlock & Edit)"</b> above to adjust prices, switch active alternates, or upload transactions.</span>
        </div>
      )}

      {/* SUB-TAB 1: Matrix Layout */}
      {activeSubTab === 'matrix' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left border-collapse">
              <thead>
                <tr className="bg-slate-800 text-white font-bold border-b border-slate-700 text-center">
                  <th className="p-3 border-r border-slate-700 w-1/4 text-left">Approved RM/MB Code</th>
                  <th className="p-3 border-r border-slate-700 w-1/10 bg-slate-900 text-amber-300">
                    <div className="flex items-center justify-center gap-1">
                      <Edit3 className="w-3.5 h-3.5" /> Approved Price (₹/kg)
                    </div>
                  </th>
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
                    <td className="p-3 border-r border-slate-200">
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold mr-2 bg-slate-200 text-slate-800">
                        {row.type === 'RM' ? 'RM Code' : 'Masterbatch Code'}
                      </span>
                      <span className="font-mono font-bold text-slate-900">{row.approvedCode}</span>
                    </td>

                    <td className="p-2 border-r border-slate-200 text-center bg-amber-50/70">
                      <div className="flex items-center justify-center gap-1">
                        <span className="font-bold text-slate-600">₹</span>
                        <input
                          type="number"
                          step="0.01"
                          value={row.approvedPrice}
                          disabled={isLocked}
                          onChange={(e) => handlePriceChange(row.id, e.target.value)}
                          className="w-20 text-center font-mono font-bold text-sm bg-white border border-amber-300 focus:border-blue-600 rounded-lg px-1.5 py-1 text-slate-900 shadow-xs outline-none disabled:bg-slate-100 disabled:border-slate-300"
                        />
                      </div>
                    </td>

                    <td className="p-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-1">
                        <span className="font-semibold text-blue-950">{row.alt1Code}</span>
                        <button
                          onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt1' })}
                          disabled={isLocked}
                          className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt1' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'} disabled:opacity-60 disabled:cursor-not-allowed`}
                        >
                          {row.activeAlt === 'alt1' ? 'Active' : 'Set'}
                        </button>
                      </div>
                    </td>
                    <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-blue-700 bg-blue-50/50">
                      ₹{Number(row.alt1Price).toFixed(2)}
                    </td>

                    <td className="p-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-1">
                        <span className="text-slate-700">{row.alt2Code}</span>
                        <button
                          onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt2' })}
                          disabled={isLocked}
                          className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt2' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'} disabled:opacity-60 disabled:cursor-not-allowed`}
                        >
                          {row.activeAlt === 'alt2' ? 'Active' : 'Set'}
                        </button>
                      </div>
                    </td>
                    <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-slate-700 bg-blue-50/30">
                      ₹{Number(row.alt2Price).toFixed(2)}
                    </td>

                    <td className="p-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-1">
                        <span className="text-slate-700">{row.alt3Code}</span>
                        <button
                          onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt3' })}
                          disabled={isLocked}
                          className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt3' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'} disabled:opacity-60 disabled:cursor-not-allowed`}
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
      )}

      {/* SUB-TAB 2: Day-wise Purchases Ingest Table */}
      {activeSubTab === 'purchases' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <ShoppingCart className="w-4 h-4 text-emerald-400" /> Day-wise Raw Material Purchase Inwards
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredPurchases.length} Purchase Records</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">DATE</th>
                  <th className="p-3">INVOICE NO</th>
                  <th className="p-3">VENDOR</th>
                  <th className="p-3">POLYMER GRADE / LOT</th>
                  <th className="p-3 text-right">QUANTITY (KG)</th>
                  <th className="p-3 text-right">RATE (₹/KG)</th>
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

      {/* SUB-TAB 3: Day-wise Sales Ingest Table */}
      {activeSubTab === 'sales' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <Truck className="w-4 h-4 text-purple-400" /> Day-wise Sales Dispatches & Invoices
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredSales.length} Sales Dispatches</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">DATE</th>
                  <th className="p-3">PART CODE</th>
                  <th className="p-3">COMPONENT NAME</th>
                  <th className="p-3">VENDOR</th>
                  <th className="p-3 text-right">DISPATCH QTY</th>
                  <th className="p-3 text-right">SELLING PRICE</th>
                  <th className="p-3 text-right">TOTAL SALES VALUE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredSales.map((s) => (
                  <tr key={s.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500">{s.date}</td>
                    <td className="p-3 font-mono font-bold text-blue-700">{s.itemCode}</td>
                    <td className="p-3 font-semibold text-slate-800">{s.componentName}</td>
                    <td className="p-3 font-bold text-slate-900">{s.vendor}</td>
                    <td className="p-3 text-right font-mono font-bold">{Number(s.qty).toLocaleString()} pcs</td>
                    <td className="p-3 text-right font-mono font-bold text-purple-700">₹{Number(s.sellingPrice).toFixed(2)}</td>
                    <td className="p-3 text-right font-mono font-black text-slate-900">₹{(Number(s.qty) * Number(s.sellingPrice)).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* SUB-TAB 4: Baseline & RM Change Log / Audit Trail */}
      {activeSubTab === 'changelog' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <History className="w-4 h-4 text-amber-400" /> Price & Parameter Change Log (Audit Trail)
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{changeLogs.length} Audit Entries</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">TIMESTAMP</th>
                  <th className="p-3">USER</th>
                  <th className="p-3">MODULE</th>
                  <th className="p-3">ENTITY / CODE</th>
                  <th className="p-3">CHANGE TYPE</th>
                  <th className="p-3">PREVIOUS VALUE</th>
                  <th className="p-3">NEW VALUE</th>
                  <th className="p-3">REASON / JUSTIFICATION</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {changeLogs.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500 text-[11px]">{log.timestamp}</td>
                    <td className="p-3 font-bold text-slate-800">{log.user}</td>
                    <td className="p-3">
                      <span className="px-2 py-0.5 bg-blue-50 text-blue-800 border border-blue-200 rounded font-bold text-[10px]">
                        {log.module}
                      </span>
                    </td>
                    <td className="p-3 font-mono font-bold text-slate-900">{log.entity}</td>
                    <td className="p-3 font-semibold text-slate-700">{log.changeType}</td>
                    <td className="p-3 font-mono text-rose-700 bg-rose-50/50">{log.previousValue}</td>
                    <td className="p-3 font-mono text-emerald-700 bg-emerald-50/50">{log.newValue}</td>
                    <td className="p-3 text-slate-600 italic">{log.reason}</td>
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

echo "==> Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Complete: RM Page is now default-locked, with Day-wise Purchase/Sales upload and full Audit Trail Change Log!"
