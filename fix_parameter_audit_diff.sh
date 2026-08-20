#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js with dynamic parameter diff engine..."
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';
import { calculatePieceCostUnified } from './costCalculationService';

const STORAGE_KEY = 'CPC_PRODUCT_COSTING_STATE_V1';
const initialData = Array.isArray(initialBaselineData) ? initialBaselineData : [];

const defaultHaierData = [
  {
    id: "BL-HAIER-001",
    vendor: "Haier",
    itemCode: "0060226713H",
    componentName: "End Cap Top Ref (without Screen Painting )",
    model: "OLD DC- 195,220",
    mouldSize: "1070*720*650",
    approvedRm: "ABS 300 Pre Colour",
    approvedRmRate: 130.00,
    masterbatchPct: 0.0,
    masterbatchRate: 0.0,
    bopCost: 0.0,
    cavity: 2,
    netWeight: 197.0,
    runnerWeight: 40.0,
    cycleTimeApproved: 48.0,
    cycleTime: 48.0,
    machineTonnage: 450,
    shiftTariff: 4600,
    hourlyRate: 575,
    validFrom: "2026-08-01",
    parameters: {
      cavity: 2,
      netWeightApproved: 197.0,
      runnerWeight: 40.0,
      cycleTimeApproved: 48.0,
      machineTonnage: 450,
      shiftTariff: 4600,
      bopCost: 0.0,
      masterbatchPct: 0.0
    }
  },
  {
    id: "BL-HAIER-002",
    vendor: "Haier",
    itemCode: "0060217989D",
    componentName: "End cap Bottom Ref-ABS-DC-195,220",
    model: "OLD DC- 195,220",
    mouldSize: "1070*720*650",
    approvedRm: "ABS 300 Pre Colour",
    approvedRmRate: 130.00,
    masterbatchPct: 0.0,
    masterbatchRate: 0.0,
    bopCost: 0.0,
    cavity: 2,
    netWeight: 197.0,
    runnerWeight: 40.0,
    cycleTimeApproved: 48.0,
    cycleTime: 48.0,
    machineTonnage: 450,
    shiftTariff: 4600,
    hourlyRate: 575,
    validFrom: "2026-08-01",
    parameters: {
      cavity: 2,
      netWeightApproved: 197.0,
      runnerWeight: 40.0,
      cycleTimeApproved: 48.0,
      machineTonnage: 450,
      shiftTariff: 4600,
      bopCost: 0.0,
      masterbatchPct: 0.0
    }
  },
  {
    id: "BL-HAIER-003",
    vendor: "Haier",
    itemCode: "0060217978E",
    componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX",
    model: "DC 195, 220",
    mouldSize: "1200*850*700",
    approvedRm: "GPPS SC201LV",
    approvedRmRate: 103.08,
    masterbatchPct: 3.5,
    masterbatchRate: 240.00,
    bopCost: 0.0,
    cavity: 1,
    netWeight: 485.0,
    runnerWeight: 22.0,
    cycleTimeApproved: 58.0,
    cycleTime: 58.0,
    machineTonnage: 650,
    shiftTariff: 5760,
    hourlyRate: 720,
    validFrom: "2026-08-01",
    parameters: {
      cavity: 1,
      netWeightApproved: 485.0,
      runnerWeight: 22.0,
      cycleTimeApproved: 58.0,
      machineTonnage: 650,
      shiftTariff: 5760,
      bopCost: 0.0,
      masterbatchPct: 3.5
    }
  }
];

const defaultAtombergData = [
  {
    id: "BL-ATOM-001",
    vendor: "Atomberg",
    itemCode: "A101701",
    componentName: "Aris Top Canopy- Gloss White",
    model: "Aris",
    mouldSize: "950*600*450",
    approvedRm: "PP H110MA",
    approvedRmRate: 140.00,
    masterbatchPct: 4.0,
    masterbatchRate: 254.00,
    bopCost: 0.0,
    cavity: 2,
    netWeight: 37.0,
    runnerWeight: 1.0,
    cycleTimeApproved: 47.0,
    cycleTime: 47.0,
    machineTonnage: 200,
    hourlyRate: 250,
    validFrom: "2026-08-01",
    parameters: {
      cavity: 2,
      netWeightApproved: 37.0,
      runnerWeight: 1.0,
      cycleTimeApproved: 47.0,
      machineTonnage: 200,
      shiftTariff: 2000,
      bopCost: 0.0,
      masterbatchPct: 4.0
    }
  }
];

const defaultSalesData = [
  { id: "INV-SLS-001", invoiceNo: "INV-SLS-001", itemCode: "0060226713H", componentName: "End Cap Top Ref (without Screen Painting )", vendor: "Haier", saleUnit: 4500, invoiceDate: "2026-08-05", sellingPrice: 38.50 },
  { id: "INV-SLS-002", invoiceNo: "INV-SLS-002", itemCode: "0060217989D", componentName: "End cap Bottom Ref-ABS-DC-195,220", vendor: "Haier", saleUnit: 4200, invoiceDate: "2026-08-10", sellingPrice: 42.00 },
  { id: "INV-SLS-003", invoiceNo: "INV-SLS-003", itemCode: "0060217978E", componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX", vendor: "Haier", saleUnit: 1800, invoiceDate: "2026-08-12", sellingPrice: 85.00 },
  { id: "INV-SLS-004", invoiceNo: "INV-SLS-004", itemCode: "A101701", componentName: "Aris Top Canopy- Gloss White", vendor: "Atomberg", saleUnit: 3500, invoiceDate: "2026-08-15", sellingPrice: 14.50 }
];

const defaultRmMatrix = [
  {
    id: "RM-HAIER-ABS-P1",
    vendor: "Haier",
    approvedRm: "ABS 300 Pre Colour",
    polymer: "ABS",
    approvedPrice: 130.00,
    validFrom: "2026-08-01",
    validTo: "2026-08-31",
    activeSelection: "alt1",
    alt1: { code: "PUR-ABS-01", name: "ABS 300-B Red (Prime Inward)", waPrice: 134.80 }
  },
  {
    id: "RM-HAIER-GPPS-P1",
    vendor: "Haier",
    approvedRm: "GPPS SC201LV",
    polymer: "GPPS",
    approvedPrice: 103.08,
    validFrom: "2026-08-01",
    validTo: "2026-08-31",
    activeSelection: "alt1",
    alt1: { code: "PUR-GPPS-01", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", waPrice: 98.40 }
  },
  {
    id: "RM-HAIER-MB-P1",
    vendor: "Haier",
    approvedRm: "MB Smoke Grey Grade",
    polymer: "MB",
    approvedPrice: 240.00,
    validFrom: "2026-08-01",
    validTo: "2026-08-31",
    activeSelection: "alt1",
    alt1: { code: "PUR-MB-02", name: "Smoke Grey MB 240 Grade", waPrice: 240.00 }
  },
  {
    id: "RM-ATOM-PP-P1",
    vendor: "Atomberg",
    approvedRm: "PP H110MA",
    polymer: "PP",
    approvedPrice: 140.00,
    validFrom: "2026-08-01",
    validTo: "2026-08-31",
    activeSelection: "alt1",
    alt1: { code: "PUR-PP-01", name: "PP H110MA Prime Inward", waPrice: 135.83 }
  },
  {
    id: "RM-ATOM-MB-P1",
    vendor: "Atomberg",
    approvedRm: "MB White Grade",
    polymer: "MB",
    approvedPrice: 254.00,
    validFrom: "2026-08-01",
    validTo: "2026-08-31",
    activeSelection: "alt1",
    alt1: { code: "PUR-MB-01", name: "White Masterbatch 258 Grade", waPrice: 258.54 }
  }
];

function loadState() {
  try {
    if (typeof window !== 'undefined' && window.localStorage) {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) return JSON.parse(raw);
    }
  } catch (e) {
    console.error("Failed to load state from localStorage:", e);
  }
  return null;
}

const saved = loadState();

export const globalStore = {
  vendors: saved?.vendors || [
    { vendorId: "Atomberg", vendorName: "Atomberg Technologies", code: "ATOM", paymentTerms: "45 Days", active: true, lineCount: 38 },
    { vendorId: "Haier", vendorName: "Haier Appliances", code: "HAIER", paymentTerms: "60 to 45 Days", active: true, lineCount: 38 },
    { vendorId: "LG", vendorName: "LG Electronics", code: "LG", paymentTerms: "45 Days", active: true, lineCount: 9 },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India", code: "WHIRLPOOL", paymentTerms: "60 Days", active: true, lineCount: 7 }
  ],
  vendorLockStatus: saved?.vendorLockStatus || { Haier: true, Atomberg: true, LG: false, Whirlpool: false },
  vendorBlueprints: saved?.vendorBlueprints || { Haier: [], Atomberg: [] },
  vendorBaselines: saved?.vendorBaselines || {
    Atomberg: defaultAtombergData,
    Haier: defaultHaierData,
    LG: initialData.filter(d => d.vendor === 'LG'),
    Whirlpool: initialData.filter(d => d.vendor === 'Whirlpool')
  },
  baselineList: [],
  purchaseMaster: saved?.purchaseMaster || [
    { code: "PUR-PP-01", invoiceNo: "INV-PUR-8830", name: "PP H110MA Prime Inward", polymer: "PP", supplier: "Reliance Industries", waPrice: 135.83, inwardDate: "2026-08-02", qtyKg: 10000 },
    { code: "PUR-MB-01", invoiceNo: "INV-PUR-8831", name: "White Masterbatch 258 Grade", polymer: "MB", supplier: "Clariant Masterbatches", waPrice: 258.54, inwardDate: "2026-08-02", qtyKg: 1500 },
    { code: "PUR-MB-02", invoiceNo: "INV-PUR-8832", name: "Smoke Grey MB 240 Grade", polymer: "MB", supplier: "Clariant Masterbatches", waPrice: 240.00, inwardDate: "2026-08-02", qtyKg: 800 },
    { code: "PUR-ABS-01", invoiceNo: "INV-PUR-8821", name: "ABS 300-B Red (Prime Inward)", polymer: "ABS", supplier: "Supreme Petrochem", waPrice: 134.80, inwardDate: "2026-08-01", qtyKg: 12500 },
    { code: "PUR-ABS-02", invoiceNo: "INV-PUR-8822", name: "ABS 300-Blue (Imported)", polymer: "ABS", supplier: "Chi Mei", waPrice: 131.25, inwardDate: "2026-08-05", qtyKg: 8200 },
    { code: "PUR-GPPS-01", invoiceNo: "INV-PUR-8824", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", polymer: "GPPS", supplier: "Supreme", waPrice: 98.40, inwardDate: "2026-08-03", qtyKg: 9000 }
  ],
  salesData: saved?.salesData || defaultSalesData,
  rmMatrix: saved?.rmMatrix || defaultRmMatrix,
  parameterChangeLogs: saved?.parameterChangeLogs || [],
  rmPriceHistoryLogs: saved?.rmPriceHistoryLogs || []
};

export function persistStore() {
  try {
    if (typeof window !== 'undefined' && window.localStorage) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify({
        vendors: globalStore.vendors,
        vendorLockStatus: globalStore.vendorLockStatus,
        vendorBlueprints: globalStore.vendorBlueprints,
        vendorBaselines: globalStore.vendorBaselines,
        purchaseMaster: globalStore.purchaseMaster,
        salesData: globalStore.salesData,
        rmMatrix: globalStore.rmMatrix,
        parameterChangeLogs: globalStore.parameterChangeLogs,
        rmPriceHistoryLogs: globalStore.rmPriceHistoryLogs
      }));
    }
  } catch (e) {
    console.error("Failed to persist state:", e);
  }
}

const listeners = new Set();
export const subscribeStore = (fn) => { listeners.add(fn); return () => listeners.delete(fn); };
export const notifyStore = () => { persistStore(); listeners.forEach(fn => fn()); };

export const syncMasterBaselineList = () => {
  let all = [];
  Object.keys(globalStore.vendorBaselines || {}).forEach(v => {
    all = [...all, ...(globalStore.vendorBaselines[v] || [])];
  });
  globalStore.baselineList = all;
};
syncMasterBaselineList();

export const getVendorBaselineData = (vendor) => {
  if (vendor === 'ALL' || vendor === 'All Vendors Combined') {
    syncMasterBaselineList();
    return globalStore.baselineList;
  }
  return globalStore.vendorBaselines[vendor] || [];
};

export const deleteProductFromBaseline = (itemCode, vendor) => {
  const v = vendor || 'Atomberg';
  if (globalStore.vendorBaselines[v]) {
    globalStore.vendorBaselines[v] = globalStore.vendorBaselines[v].filter(p => p.itemCode !== itemCode);
  }
  globalStore.baselineList = (globalStore.baselineList || []).filter(p => p.itemCode !== itemCode);
  globalStore.salesData = (globalStore.salesData || []).filter(s => s.itemCode !== itemCode);
  syncMasterBaselineList();
  notifyStore();
};

export const addVendorBaselineProducts = (vendor, newProducts) => {
  const v = vendor || 'Atomberg';
  if (!globalStore.vendorBaselines[v]) globalStore.vendorBaselines[v] = [];
  newProducts.forEach(np => {
    const exists = globalStore.vendorBaselines[v].some(p => p.itemCode === np.itemCode);
    if (!exists) {
      globalStore.vendorBaselines[v].unshift(np);
      const saleExists = globalStore.salesData.some(s => s.itemCode === np.itemCode);
      if (!saleExists) {
        globalStore.salesData.push({
          id: `INV-SLS-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
          invoiceNo: `INV-${np.itemCode}`,
          itemCode: np.itemCode,
          componentName: np.componentName,
          vendor: v,
          saleUnit: 1000,
          invoiceDate: np.validFrom || "2026-08-15",
          sellingPrice: Number(np.approvedRmRate ? (np.approvedRmRate * 0.12).toFixed(2) : 15.00)
        });
      }
    }
  });
  syncMasterBaselineList();
  notifyStore();
};

export const getActiveRmMapping = (approvedRmName, vendor = "Haier", targetDate = null) => {
  const vKey = (vendor || "Haier").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey &&
    ((approvedRmName && r.approvedRm.toLowerCase().includes(approvedRmName.toLowerCase())) ||
     (approvedRmName && approvedRmName.toLowerCase().includes(r.approvedRm.toLowerCase())) ||
     (approvedRmName && approvedRmName.toLowerCase().includes(r.polymer?.toLowerCase())))
  );

  let row = rows[0];
  if (!row) {
    return {
      vendor: vendor || "Haier",
      approvedRm: approvedRmName || "Standard Polymer",
      approvedPrice: 130.00,
      activeRmName: "Inward Lot Standard",
      activeWaPrice: 134.80,
      validFrom: "2026-08-01",
      validTo: "2026-08-31"
    };
  }
  let activeRmName = row.approvedRm;
  let activeWaPrice = Number(row.approvedPrice);
  if (row.activeSelection === 'alt1' && row.alt1) {
    activeRmName = row.alt1.name;
    activeWaPrice = Number(row.alt1.waPrice);
  } else if (row.activeSelection === 'alt2' && row.alt2) {
    activeRmName = row.alt2.name;
    activeWaPrice = Number(row.alt2.waPrice);
  }
  return { vendor: row.vendor, approvedRm: row.approvedRm, approvedPrice: Number(row.approvedPrice), validFrom: row.validFrom, validTo: row.validTo, activeSelection: row.activeSelection, activeRmName, activeWaPrice: Number(activeWaPrice), alt1: row.alt1, alt2: row.alt2 };
};

export const getActiveMbMapping = (vendor = "Haier", targetDate = null) => {
  const vKey = (vendor || "Haier").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => r.vendor.toLowerCase() === vKey && r.polymer === 'MB');
  let row = rows[0];
  if (!row) return { approvedMbPrice: vKey === 'haier' ? 240.00 : 254.00, activeMbName: vKey === 'haier' ? "Smoke Grey MB 240 Grade" : "White Masterbatch 258 Grade", activeMbPrice: vKey === 'haier' ? 240.00 : 258.54 };
  let activeMbPrice = Number(row.approvedPrice);
  let activeMbName = row.approvedRm;
  if (row.activeSelection === 'alt1' && row.alt1) { activeMbName = row.alt1.name; activeMbPrice = Number(row.alt1.waPrice); } 
  else if (row.activeSelection === 'alt2' && row.alt2) { activeMbName = row.alt2.name; activeMbPrice = Number(row.alt2.waPrice); }
  return { approvedMbPrice: Number(row.approvedPrice), activeMbName, activeMbPrice: Number(activeMbPrice) };
};

export const toggleVendorLockStatus = (vendor, isLocked) => { globalStore.vendorLockStatus[vendor] = isLocked; notifyStore(); };

export const updateVendorScheduleBulk = (vendor, validFrom, validTo, updatedRows) => {
  const previousRows = (globalStore.rmMatrix || []).filter(r => r.vendor.toLowerCase() === vendor.toLowerCase());
  globalStore.rmMatrix = globalStore.rmMatrix.map(row => {
    if (row.vendor.toLowerCase() === vendor.toLowerCase()) {
      const match = updatedRows.find(u => u.id === row.id);
      return match ? { ...match, validFrom, validTo, approvedPrice: Number(match.approvedPrice) } : { ...row, validFrom, validTo };
    }
    return row;
  });
  globalStore.vendorLockStatus[vendor] = true;
  if (globalStore.vendorBaselines[vendor]) {
    globalStore.vendorBaselines[vendor] = globalStore.vendorBaselines[vendor].map(prod => {
      const rmMatch = updatedRows.find(u => u.approvedRm === prod.approvedRm || prod.approvedRm.includes(u.polymer));
      const mbMatch = updatedRows.find(u => u.polymer === 'MB');
      return {
        ...prod,
        approvedRmRate: rmMatch ? Number(rmMatch.approvedPrice) : prod.approvedRmRate,
        masterbatchRate: mbMatch ? Number(mbMatch.approvedPrice) : prod.masterbatchRate,
        validFrom, validTo
      };
    });
  }
  syncMasterBaselineList();

  updatedRows.forEach(uRow => {
    const prev = previousRows.find(p => p.id === uRow.id);
    let altText = uRow.activeSelection === 'alt1' ? `Alternate 1 (${uRow.alt1?.name || ''})` : uRow.activeSelection === 'alt2' ? `Alternate 2 (${uRow.alt2?.name || ''})` : 'Primary Approved';
    const priceChanged = Math.abs((prev?.approvedPrice || 0) - (Number(uRow.approvedPrice) || 0)) >= 0.01;
    const note = priceChanged ? `Approved price updated from ₹${(prev?.approvedPrice || uRow.approvedPrice).toFixed(2)} to ₹${Number(uRow.approvedPrice).toFixed(2)}` : `Schedule locked with ${altText}`;
    globalStore.rmPriceHistoryLogs.unshift({
      id: `LOG-RM-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      vendor, rmGrade: uRow.approvedRm, action: priceChanged ? "Approved Price & Period Updated" : "Schedule Locked", period: `${validFrom} to ${validTo}`,
      previousRate: prev?.approvedPrice || uRow.approvedPrice, newRate: Number(uRow.approvedPrice), activeAlternate: altText, changedBy: "Engineering Head", reason: note
    });
  });
  notifyStore();
};

export const updateBaselineParameters = ({ itemId, updatedItem, changeType, newValidFrom, reason } = {}) => {
  const list = globalStore.baselineList || [];
  const idx = list.findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
  if (idx !== -1) {
    const prev = list[idx];
    const oldParams = prev.parameters || {};
    const newParams = updatedItem?.parameters || {};
    
    // Dynamic universal diff engine
    const changesList = [];
    const fieldsToTrack = [
      { key: 'runningNetWeight', fallbackKey: 'netWeight', label: 'Net Weight', uom: 'g' },
      { key: 'runningRunnerWeight', fallbackKey: 'runnerWeight', label: 'Runner Weight', uom: 'g' },
      { key: 'runningCycleTime', fallbackKey: 'cycleTimeApproved', fallbackKey2: 'cycleTime', label: 'Cycle Time', uom: 's' },
      { key: 'runningMbPct', fallbackKey: 'masterbatchPct', label: 'MB Required', uom: '%' },
      { key: 'runningCavity', fallbackKey: 'cavity', label: 'No. of Cavity', uom: '' },
      { key: 'runningTonnage', fallbackKey: 'machineTonnage', label: 'Machine Tonnage', uom: 'T' },
      { key: 'runningBopCost', fallbackKey: 'bopCost', label: 'BOP Cost', uom: '₹/pc' }
    ];

    fieldsToTrack.forEach(field => {
      const oldVal = Number(oldParams[field.key] ?? prev[field.fallbackKey] ?? prev[field.fallbackKey2] ?? 0);
      const newVal = Number(newParams[field.key] ?? updatedItem[field.fallbackKey] ?? updatedItem[field.fallbackKey2] ?? oldVal);
      
      if (Math.abs(oldVal - newVal) >= 0.01) {
        changesList.push({ 
          parameter: field.label, 
          oldVal: `${oldVal}${field.uom}`, 
          newVal: `${newVal}${field.uom}`, 
          diff: `${newVal - oldVal > 0 ? '+' : ''}${Number(newVal - oldVal).toFixed(2)}${field.uom}` 
        });
      }
    });

    // Capture overall cost impact (Baseline vs New Running)
    const v = prev.vendor || 'Haier';
    const oldCalc = calculatePieceCostUnified({ item: prev, isBaseline: false });
    const newCalc = calculatePieceCostUnified({ item: { ...prev, parameters: newParams }, isBaseline: false });
    const costDiff = Number(newCalc.totalCost || newCalc.finalLanded) - Number(oldCalc.totalCost || oldCalc.finalLanded);

    globalStore.baselineList[idx] = {
      ...prev,
      ...updatedItem,
      parameters: { ...oldParams, ...newParams },
      validFrom: newValidFrom || prev.validFrom
    };

    if (globalStore.vendorBaselines[v]) {
      const vIdx = globalStore.vendorBaselines[v].findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
      if (vIdx !== -1) {
        globalStore.vendorBaselines[v][vIdx] = globalStore.baselineList[idx];
      }
    }

    // Push explicitly to the parameter change audit trail
    globalStore.parameterChangeLogs.unshift({
      id: `LOG-PARAM-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      itemCode: updatedItem?.itemCode || prev.itemCode,
      componentName: updatedItem?.componentName || prev.componentName,
      vendor: v,
      changedBy: "Engineering Head",
      field: changeType || "Shopfloor Parameter Tuning",
      changesList: changesList.length > 0 ? changesList : [{ parameter: "Spec Record Resaved", oldVal: "Base", newVal: "Running", diff: "Verified" }],
      costImpact: { 
        oldCost: Number(oldCalc.totalCost || oldCalc.finalLanded), 
        newCost: Number(newCalc.totalCost || newCalc.finalLanded), 
        diff: costDiff 
      },
      reason: reason || "Internal parameter optimization"
    });

    syncMasterBaselineList();
    notifyStore();
  }
};

export const onboardVendorWithBlueprint = ({ vendorName, vendorCode, paymentTerms, blueprintLines, initialProduct }) => {
  const vId = vendorName.trim();
  if (!globalStore.vendors.find(v => v.vendorId.toLowerCase() === vId.toLowerCase())) {
    globalStore.vendors.push({ vendorId: vId, vendorName, code: (vendorCode || vId.substring(0, 4)).toUpperCase(), paymentTerms: paymentTerms || "45 Days", active: true, lineCount: (blueprintLines || []).length });
  }
  globalStore.vendorBlueprints[vId] = blueprintLines || [];
  if (!globalStore.vendorBaselines[vId]) globalStore.vendorBaselines[vId] = [];
  syncMasterBaselineList();
  notifyStore();
};
export const addManualPurchaseRecord = (record) => { globalStore.purchaseMaster.unshift({ code: `PUR-${Date.now()}`, ...record }); notifyStore(); };
export const addManualSaleRecord = (record) => { globalStore.salesData.unshift({ id: `INV-SLS-${Date.now()}`, ...record }); notifyStore(); };
export const uploadBulkPurchases = (newPurchases) => { globalStore.purchaseMaster = [...newPurchases, ...(globalStore.purchaseMaster || [])]; notifyStore(); };
export const uploadBulkSales = (newSales) => { globalStore.salesData = [...newSales, ...(globalStore.salesData || [])]; notifyStore(); };

export default globalStore;
STORE_EOF

echo "==> 2. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Dynamic parameter diff logging fully established."
