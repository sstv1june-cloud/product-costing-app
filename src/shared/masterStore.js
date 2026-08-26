// ============================================================================
// GLOBAL MASTER DATA STORE (Strictly Isolated DEV-V2 - Multi-Vendor Scoped)
// ============================================================================

const STORAGE_KEY = 'CPC_MASTER_STORE_DEV_V2_VENDOR_PERIOD_ISOLATED_04';

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

export function normalizeVendorId(vendor) {
  if (!vendor) return 'haier';
  const v = vendor.toString().toLowerCase().trim();
  if (v.includes('atomberg')) return 'atomberg';
  if (v.includes('atharva')) return 'atharva';
  if (v.includes('haier')) return 'haier';
  return v;
}

const defaultStore = {
  isLocked: true,
  isMatrixLocked: true,
  vendors: [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ],
  vendorSchedules: {
    'Haier Appliances': { periodFrom: '2026-08-01', periodTo: '2026-08-31' },
    'Atomberg Technologies': { periodFrom: '2026-08-01', periodTo: '2026-08-31' },
    'Atharva Polymer': { periodFrom: '2026-08-01', periodTo: '2026-08-31' }
  },
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
  isLocked: initialStore.isLocked !== undefined ? initialStore.isLocked : true,
  isMatrixLocked: initialStore.isMatrixLocked !== undefined ? initialStore.isMatrixLocked : true,
  vendors: (initialStore.vendors && initialStore.vendors.length > 0) ? initialStore.vendors : defaultStore.vendors,
  vendorSchedules: initialStore.vendorSchedules || defaultStore.vendorSchedules,
  baselineProducts: initialStore.baselineProducts || [],
  rmMappingsData: initialStore.rmMappingsData || [],
  purchases: initialStore.purchases || [],
  sales: initialStore.sales || [],
  auditLogs: initialStore.auditLogs || []
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

export function computeGradeWeightedAverage(gradeOrCode, vendor) {
  const purchases = globalStore.purchases || [];
  if (!gradeOrCode) return 0;
  const gClean = gradeOrCode.toString().toLowerCase().trim();
  const vNorm = normalizeVendorId(vendor);

  const matching = purchases.filter(p => {
    const pGrade = (p.grade || p.itemCode || p.rawMaterial || p.supplier || '').toString().toLowerCase().trim();
    const pNorm = normalizeVendorId(p.vendor);
    const matchGrade = pGrade === gClean || pGrade.includes(gClean) || gClean.includes(pGrade);
    const matchVendor = !vendor || vNorm === 'all' || pNorm === vNorm;
    return matchGrade && matchVendor;
  });

  let totalQty = 0;
  let totalCost = 0;
  matching.forEach(m => {
    const qty = Number(m.qty || m.quantity || 0);
    const rate = Number(m.rate || m.netRate || m.price || 0);
    if (qty > 0 && rate > 0) {
      totalQty += qty;
      totalCost += (qty * rate);
    }
  });

  if (totalQty > 0) {
    return Number((totalCost / totalQty).toFixed(2));
  }
  return 0;
}

// Strictly Scoped by Vendor + RM Code
export function getActiveRmMapping(gradeName, vendor, period) {
  if (!gradeName) return { approvedCode: 'Unspecified', approvedPrice: 0, activeGrade: 'Unspecified', activeWaPrice: 0, isFound: false };
  const { baseRm } = parseMaterialString(gradeName);
  const targetCode = (baseRm || gradeName).toLowerCase().trim();
  const vNorm = normalizeVendorId(vendor);

  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'RM' && 
    normalizeVendorId(r.vendor) === vNorm && 
    (r.approvedCode.toLowerCase().trim() === targetCode || targetCode.includes(r.approvedCode.toLowerCase().trim()) || r.approvedCode.toLowerCase().trim().includes(targetCode))
  );

  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] !== undefined ? found[`${activeKey}Price`] : (found.alt1Price || found.approvedPrice || 0));
    return { 
      approvedCode: found.approvedCode, 
      approvedPrice: Number(found.approvedPrice || 0), 
      activeGrade: found[`${activeKey}Code`] || found.approvedCode, 
      activeWaPrice: Number(waPrice || 0), 
      isFound: true 
    };
  }

  // Fallback defaults if not registered yet
  const defaultRate = vNorm === 'atomberg' ? 131.00 : 154.00;
  return { approvedCode: baseRm || gradeName, approvedPrice: defaultRate, activeGrade: baseRm || gradeName, activeWaPrice: defaultRate, isFound: false };
}

// Strictly Scoped by Vendor + MB Code
export function getActiveMbMapping(mbGradeName, vendor, period) {
  const vNorm = normalizeVendorId(vendor);
  let targetMb = (mbGradeName || '').toLowerCase().trim();
  if (!targetMb || targetMb === 'none') {
    return { approvedMbCode: 'None', approvedMbPrice: 0, activeMbGrade: 'None', activeMbWaPrice: 0, isFound: false };
  }

  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'MB' && 
    normalizeVendorId(r.vendor) === vNorm && 
    (r.approvedCode.toLowerCase().trim() === targetMb || targetMb.includes(r.approvedCode.toLowerCase().trim()) || r.approvedCode.toLowerCase().trim().includes(targetMb))
  );

  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] !== undefined ? found[`${activeKey}Price`] : (found.alt1Price || found.approvedPrice || 0));
    return { 
      approvedMbCode: found.approvedCode, 
      approvedMbPrice: Number(found.approvedPrice || 0), 
      activeMbGrade: found[`${activeKey}Code`] || found.approvedCode, 
      activeMbWaPrice: Number(waPrice || 0), 
      isFound: true 
    };
  }

  const defaultMbRate = vNorm === 'atomberg' ? 242.00 : 242.00;
  return { approvedMbCode: mbGradeName, approvedMbPrice: defaultMbRate, activeMbGrade: mbGradeName, activeMbWaPrice: defaultMbRate, isFound: false };
}

// Adds or Updates Material for Specific Vendor + RM Code + Period
export function addOrUpdateVendorMaterial(item) {
  if (!globalStore.rmMappingsData) globalStore.rmMappingsData = [];
  const vNorm = normalizeVendorId(item.vendor);
  const codeClean = (item.approvedCode || '').toLowerCase().trim();

  const idx = globalStore.rmMappingsData.findIndex(r => 
    normalizeVendorId(r.vendor) === vNorm && 
    r.type === item.type && 
    r.approvedCode.toLowerCase().trim() === codeClean
  );

  if (idx >= 0) {
    globalStore.rmMappingsData[idx] = { 
      ...globalStore.rmMappingsData[idx], 
      ...item,
      vendor: item.vendor || globalStore.rmMappingsData[idx].vendor 
    };
  } else {
    globalStore.rmMappingsData.push({ 
      id: `mat-${vNorm}-${Date.now()}-${Math.random().toString(36).substr(2,4)}`, 
      ...item 
    });
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

// Saves for Specific Vendor + Period and Syncs to that Vendor's baseline
export function saveVendorPeriodSchedule({ vendor, periodFrom, periodTo }) {
  if (!globalStore.vendorSchedules) globalStore.vendorSchedules = {};
  const vNorm = normalizeVendorId(vendor);

  globalStore.vendorSchedules[vendor] = {
    periodFrom,
    periodTo,
    savedAt: new Date().toISOString()
  };

  // Tag all RM records of this vendor with period
  (globalStore.rmMappingsData || []).forEach(r => {
    if (normalizeVendorId(r.vendor) === vNorm) {
      r.periodFrom = periodFrom;
      r.periodTo = periodTo;
    }
  });

  // Sync to registered baseline products belonging to this vendor
  const vendorMaterials = (globalStore.rmMappingsData || []).filter(r => 
    normalizeVendorId(r.vendor) === vNorm
  );

  (globalStore.baselineProducts || []).forEach(prod => {
    if (normalizeVendorId(prod.vendor) === vNorm) {
      const { baseRm, mbGrade } = parseMaterialString(prod.approvedRm || prod.baseRm);
      const matchedRm = vendorMaterials.find(m => m.type === 'RM' && m.approvedCode.toLowerCase().trim() === (baseRm || '').toLowerCase().trim());
      const matchedMb = vendorMaterials.find(m => m.type === 'MB' && m.approvedCode.toLowerCase().trim() === (mbGrade || '').toLowerCase().trim());

      if (matchedRm) {
        const activeKey = matchedRm.activeAlt || 'alt1';
        prod.approvedRmPrice = Number(matchedRm.approvedPrice || prod.approvedRmPrice || 0);
        prod.activeRmWaPrice = Number(matchedRm[`${activeKey}Price`] !== undefined ? matchedRm[`${activeKey}Price`] : matchedRm.approvedPrice);
      }
      if (matchedMb) {
        const activeKey = matchedMb.activeAlt || 'alt1';
        prod.approvedMbPrice = Number(matchedMb.approvedPrice || prod.approvedMbPrice || 0);
        prod.activeMbWaPrice = Number(matchedMb[`${activeKey}Price`] !== undefined ? matchedMb[`${activeKey}Price`] : matchedMb.approvedPrice);
      }
    }
  });

  addAuditLog({
    partCode: 'RM_MATRIX',
    componentName: `Saved Matrix Schedule for ${vendor}`,
    vendor: vendor,
    modifications: `Period: ${periodFrom} to ${periodTo} • ${vendorMaterials.length} Materials Saved`,
    costImpact: 'Matrix Synced',
    reason: 'Save for Vendor + Period'
  });

  notifyStore();
  return { success: true, count: vendorMaterials.length };
}

export function deleteVendorMaterial(id) {
  globalStore.rmMappingsData = (globalStore.rmMappingsData || []).filter(r => r.id !== id);
  notifyStore();
}

export function getVendorBaselineData(vendorId) {
  const prods = globalStore.baselineProducts || [];
  if (!vendorId || vendorId === 'ALL') return prods;
  const vNorm = normalizeVendorId(vendorId);
  return prods.filter(p => normalizeVendorId(p.vendor) === vNorm);
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
    const idx = globalStore.baselineProducts.findIndex(p => p.itemCode === staged.itemCode && normalizeVendorId(p.vendor) === normalizeVendorId(vendor));
    if (idx >= 0) {
      globalStore.baselineProducts[idx] = { ...globalStore.baselineProducts[idx], ...staged, vendor: vendor || staged.vendor };
    } else {
      globalStore.baselineProducts.push({ ...staged, id: `prod-${Date.now()}-${Math.random().toString(36).substr(2,4)}`, vendor: vendor || staged.vendor });
    }
  });
  notifyStore();
}

export function deleteProductFromBaseline(itemId, vendor) {
  const vNorm = normalizeVendorId(vendor);
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => !( (p.id === itemId || p.itemCode === itemId) && (vendor === 'ALL' || normalizeVendorId(p.vendor) === vNorm) ));
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
  const vNorm = normalizeVendorId(vendorName);
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => normalizeVendorId(p.vendor) !== vNorm);
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

export function toggleGlobalLock() { 
  globalStore.isLocked = !globalStore.isLocked; 
  notifyStore(); 
}

export function toggleMatrixLock() { 
  globalStore.isMatrixLocked = !globalStore.isMatrixLocked; 
  notifyStore(); 
}

export function addDayWisePurchase(rec) { (globalStore.purchases = globalStore.purchases || []).unshift(rec); notifyStore(); return { success: true }; }
export function addDayWiseSales(rec) { (globalStore.sales = globalStore.sales || []).unshift(rec); notifyStore(); return { success: true }; }
export function onboardVendorWithBlueprint() { notifyStore(); }
