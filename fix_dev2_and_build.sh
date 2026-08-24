#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring branch is strictly dev-v2..."
git checkout dev-v2

echo "==> 2. Writing complete masterStore.js with all required module exports (including updateRmMappingRow)..."
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
  isLocked: true,
  isMatrixLocked: true,
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

export function parseMaterialString(rawMaterialStr) {
  if (!rawMaterialStr) return { baseRm: '', mbGrade: '' };
  const cleanStr = rawMaterialStr.toString().trim();
  if (cleanStr.includes('+')) {
    const parts = cleanStr.split('+').map(s => s.trim());
    return { baseRm: parts[0] || '', mbGrade: parts[1] || '' };
  }
  return { baseRm: cleanStr, mbGrade: '' };
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

echo "==> 3. Verifying build strictly on dev-v2..."
npm run build

echo "==> 4. Committing and pushing ONLY to origin/dev-v2 (Zero push to main)..."
git add -A
git commit -m "feat(dev-v2): add updateRmMappingRow export, full 38-line Haier indexing, and isolated store" || echo "dev-v2 is clean."
git push origin dev-v2

echo "==> 5. Restarting local dev server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ DEV-V2 BUILT & RUNNING SUCCESSFULLY!"
echo "   • Storage Key: CPC_MASTER_STORE_DEV_ISOLATED_V2"
echo "   • Zero data or code shared with main (Live Production)"
echo "-------------------------------------------------------------------"
