#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js with full default arrays, named exports, and helper getters..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// Centralized Master Store for Multi-Vendor Costing System

const initialRawMaterials = [
  { id: 'rm-1', vendor: 'Atomberg', grade: 'PP H110MA', approvedPrice: 131.00, activeGrade: 'PP H110MA Prime Inward', activeWaPrice: 135.83, uom: 'kg' },
  { id: 'rm-2', vendor: 'Haier', grade: 'ABS 300 Pre Colour', approvedPrice: 136.20, activeGrade: 'ABS 300-B Red (Prime Inward)', activeWaPrice: 134.80, uom: 'kg' },
  { id: 'rm-3', vendor: 'Haier', grade: 'GPPS SC201LV', approvedPrice: 100.00, activeGrade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', activeWaPrice: 98.40, uom: 'kg' }
];

const initialMasterbatches = [
  { id: 'mb-1', vendor: 'Atomberg', color: 'Black MB', grade: 'Black MB', approvedMbPrice: 250.00, activeMbWaPrice: 258.54, approvedPrice: 250.00, activeWaPrice: 258.54 },
  { id: 'mb-2', vendor: 'Atomberg', color: 'White MB', grade: 'White MB', approvedMbPrice: 250.00, activeMbWaPrice: 258.54, approvedPrice: 250.00, activeWaPrice: 258.54 },
  { id: 'mb-3', vendor: 'Haier', color: 'Standard MB', grade: 'Standard MB', approvedMbPrice: 0.00, activeMbWaPrice: 0.00, approvedPrice: 0.00, activeWaPrice: 0.00 }
];

const initialBaselineProducts = [
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
];

const initialVendors = [
  { vendorId: 'Atomberg', vendorName: 'Atomberg Technologies', isLocked: false },
  { vendorId: 'Haier', vendorName: 'Haier Appliances', isLocked: false }
];

const initialPurchases = [
  { id: 'pur-1', date: '2026-08-01', vendor: 'Atomberg', grade: 'PP H110MA', qty: 5000, rate: 135.83, invoiceNo: 'INV-AT-01' },
  { id: 'pur-2', date: '2026-08-01', vendor: 'Haier', grade: 'ABS 300 Pre Colour', qty: 4000, rate: 134.80, invoiceNo: 'INV-HR-01' },
  { id: 'pur-3', date: '2026-08-01', vendor: 'Haier', grade: 'GPPS SC201LV', qty: 2500, rate: 98.40, invoiceNo: 'INV-HR-02' }
];

const initialSales = [
  { date: '2026-08-10', itemCode: '0060217989D', qty: 4200, sellingPrice: 42.00, vendor: 'Haier' },
  { date: '2026-08-12', itemCode: '0060217978E', qty: 1800, sellingPrice: 85.00, vendor: 'Haier' },
  { date: '2026-08-15', itemCode: 'A101701', qty: 3500, sellingPrice: 14.50, vendor: 'Atomberg' },
  { date: '2026-08-01', itemCode: 'A101703', qty: 1000, sellingPrice: 15.96, vendor: 'Atomberg' }
];

export const rawMaterials = initialRawMaterials;
export const masterbatches = initialMasterbatches;
export const baselineProducts = initialBaselineProducts;
export const vendors = initialVendors;
export const purchases = initialPurchases;
export const sales = initialSales;
export const vendorPriceSchedules = [];
export const priceChangeLogs = [];
export const parameterChangeLogs = [];

export const globalStore = {
  vendors: initialVendors,
  rawMaterials: initialRawMaterials,
  rmMappings: initialRawMaterials,
  rawMaterialMatrix: initialRawMaterials,
  matrixData: initialRawMaterials,
  masterbatches: initialMasterbatches,
  mbMappings: initialMasterbatches,
  baselineProducts: initialBaselineProducts,
  products: initialBaselineProducts,
  purchases: initialPurchases,
  rmPurchases: initialPurchases,
  sales: initialSales,
  vendorPriceSchedules: [],
  vendorSchedules: {},
  schedules: {},
  priceSchedules: [],
  parameterChangeLogs: [],
  priceChangeLogs: [],
  auditLogs: [],
  changeLogs: []
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
  const found = list.find(r => r.grade === gradeName) || list[0] || {
    approvedPrice: 131.00,
    activeWaPrice: 135.83,
    activeGrade: gradeName || 'Standard RM'
  };
  return found;
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

export function toggleVendorLockStatus(vendorId) {
  if (!globalStore.vendors) return;
  const v = globalStore.vendors.find(item => item.vendorId === vendorId);
  if (v) {
    v.isLocked = !v.isLocked;
    notifyStore();
  }
}

export function updateVendorScheduleBulk(vendorId, scheduleData) {
  if (!globalStore.vendorSchedules) globalStore.vendorSchedules = {};
  globalStore.vendorSchedules[vendorId] = scheduleData;
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

export function addRawMaterialInward(inwardData) {
  if (!globalStore.purchases) globalStore.purchases = [];
  globalStore.purchases.push(inwardData);
  notifyStore();
}

export function addSalesDispatch(dispatchData) {
  if (!globalStore.sales) globalStore.sales = [];
  globalStore.sales.push(dispatchData);
  notifyStore();
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
STORE_EOF

echo "==> 2. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Store state repaired."
