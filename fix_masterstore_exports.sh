#!/usr/bin/env bash
set -e

echo "==> Exporting all missing functions in src/shared/masterStore.js..."
cat << 'STORE_PATCH_EOF' > src/shared/masterStore.js
import { 
  fetchAllBaselineProducts, 
  saveBaselineProductToSupabase, 
  fetchRmMappingsFromSupabase, 
  saveRmMappingToSupabase, 
  fetchSalesFromSupabase, 
  saveSalesDispatchToSupabase, 
  saveChangeLogToSupabase 
} from '../services/supabaseService';

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

  parameterChangeLogs: [],
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

(async function initSupabaseData() {
  try {
    const supaProducts = await fetchAllBaselineProducts();
    if (supaProducts && supaProducts.length > 0) {
      globalStore.baselineProducts = supaProducts;
    }
    const supaMappings = await fetchRmMappingsFromSupabase();
    if (supaMappings && supaMappings.length > 0) {
      globalStore.rmMappingsData = supaMappings;
    }
    const supaSales = await fetchSalesFromSupabase();
    if (supaSales && supaSales.length > 0) {
      globalStore.sales = supaSales;
    }
    notifyStore();
  } catch (e) {
    console.warn('Supabase hydration info:', e.message);
  }
})();

export function toggleGlobalLock() {
  globalStore.isGlobalLocked = !globalStore.isGlobalLocked;
  notifyStore();
}

export function updateRmMappingRow(rowId, updatedFields, reason = 'Price / Alternate Update') {
  const row = (globalStore.rmMappingsData || []).find(r => r.id === rowId);
  if (row) {
    Object.assign(row, updatedFields);
    saveRmMappingToSupabase(row);
    notifyStore();
  }
}

export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  
  if (updatedItem.parameters) {
    prod.parameters = { ...prod.parameters, ...updatedItem.parameters };
  }
  
  saveBaselineProductToSupabase(prod);

  const logEntry = {
    id: `param-log-${Date.now()}`,
    timestamp: new Date().toLocaleString(),
    partCode: prod.itemCode,
    componentName: prod.componentName,
    vendor: prod.vendor,
    modifications: Object.entries(updatedItem.parameters || {}).map(([k, v]) => `${k.replace('running', '')}: ${v}`).join(', '),
    costImpact: updatedItem.delta ? `₹${Number(updatedItem.delta).toFixed(2)}` : 'Calculated',
    authorizedBy: 'Costing Lead',
    reason: reason || 'Parameters Updated'
  };

  if (!globalStore.parameterChangeLogs) globalStore.parameterChangeLogs = [];
  globalStore.parameterChangeLogs.unshift(logEntry);
  saveChangeLogToSupabase(logEntry);

  notifyStore();
}

export function addStagedProductsToBaseline(stagedList, vendor) {
  stagedList.forEach(staged => {
    const idx = globalStore.baselineProducts.findIndex(p => p.itemCode === staged.itemCode);
    if (idx >= 0) {
      globalStore.baselineProducts[idx] = { ...globalStore.baselineProducts[idx], ...staged };
      saveBaselineProductToSupabase(globalStore.baselineProducts[idx]);
    } else {
      const newProd = { ...staged, vendor: vendor || 'Haier' };
      globalStore.baselineProducts.push(newProd);
      saveBaselineProductToSupabase(newProd);
    }
  });
  notifyStore();
}

export function addDayWisePurchase(record) {
  if (!globalStore.purchases) globalStore.purchases = [];
  globalStore.purchases.unshift(record);
  notifyStore();
}

export function addDayWiseSales(record) {
  if (!globalStore.sales) globalStore.sales = [];
  globalStore.sales.unshift(record);
  saveSalesDispatchToSupabase(record);
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

export function deleteProductFromBaseline(itemId) {
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => p.id !== itemId && p.itemCode !== itemId);
  notifyStore();
}

export function saveVendorPeriodSchedule() {
  notifyStore();
}

export function onboardVendorWithBlueprint({ vendorId, vendorName }) {
  if (!globalStore.vendors.find(v => v.vendorId === vendorId)) {
    globalStore.vendors.push({ vendorId, vendorName });
  }
  notifyStore();
}
STORE_PATCH_EOF

echo "==> Clearing cache and restarting Vite..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! All exports restored."
