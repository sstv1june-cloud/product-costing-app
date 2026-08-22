#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js with clean initial seed purchases and robust WA calculator..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// ============================================================================
// GLOBAL MASTER DATA STORE (Strict RM/MB Dynamic Resolution & Clean State)
// ============================================================================

export let globalStore = {
  isLocked: true,        // Level 1: Global Page Lock
  isMatrixLocked: true,  // Level 2: Dedicated RM Price Matrix Rate Lock

  vendors: [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ],

  // RM & MB Master Matrix
  rmMappingsData: [
    // Atomberg RMs & MBs
    { id: 'rm-at-1', vendor: 'Atomberg Technologies', type: 'RM', approvedCode: 'PP H110MA', approvedPrice: 131.00, activeAlt: 'alt1', alt1Code: 'PP H110MA Prime Inward', alt1Price: 135.83, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'rm-at-2', vendor: 'Atomberg Technologies', type: 'RM', approvedCode: 'PP Mi3530', approvedPrice: 180.00, activeAlt: 'alt1', alt1Code: 'PP Mi3530 Prime Inward', alt1Price: 180.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-1', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'Black MB', approvedPrice: 254.00, activeAlt: 'alt1', alt1Code: 'Black MB (Standard)', alt1Price: 258.54, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-2', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'White MB', approvedPrice: 260.00, activeAlt: 'alt1', alt1Code: 'White MB (Standard)', alt1Price: 265.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-3', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'Gray MB', approvedPrice: 150.00, activeAlt: 'alt1', alt1Code: 'Gray MB Prime Inward', alt1Price: 150.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-4', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'GOLDEN MB', approvedPrice: 450.00, activeAlt: 'alt1', alt1Code: 'GOLDEN MB (Prime Contract)', alt1Price: 450.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },

    // Haier RMs & MBs
    { id: 'rm-ha-1', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'ABS 300 Pre Colour', approvedPrice: 136.20, activeAlt: 'alt1', alt1Code: 'ABS 300-B Red (Prime Inward)', alt1Price: 134.80, alt2Code: 'ABS 300-B Alt Pre-mix (Supreme)', alt2Price: 135.20, alt3Code: 'ABS 300-B Spot Lot C', alt3Price: 136.00 },
    { id: 'rm-ha-2', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'GPPS SC201LV', approvedPrice: 100.00, activeAlt: 'alt1', alt1Code: 'GPPS SC201LV + 3.5% Smoke Grey Blend', alt1Price: 98.40, alt2Code: 'GPPS SC206 Virgin Lot', alt2Price: 99.10, alt3Code: 'GPPS SC200 Inward Lot 3', alt3Price: 98.90 },
    { id: 'mb-ha-1', vendor: 'Haier Appliances', type: 'MB', approvedCode: 'Smoke Grey MB (3.5%)', approvedPrice: 150.00, activeAlt: 'alt1', alt1Code: 'Smoke Grey Masterbatch Grade A', alt1Price: 148.00, alt2Code: 'Smoke Grey Masterbatch Lot B', alt2Price: 149.50, alt3Code: 'Smoke Grey Masterbatch Spot', alt3Price: 150.00 },
    { id: 'rm-ha-3', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'HIPS-SH03', approvedPrice: 147.87, activeAlt: 'alt1', alt1Code: 'HIPS-SH03 Prime Lot', alt1Price: 157.46, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'rm-ha-4', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'PP B-400MN', approvedPrice: 132.76, activeAlt: 'alt1', alt1Code: 'PP B-400MN (IOCL)', alt1Price: 135.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-ha-2', vendor: 'Haier Appliances', type: 'MB', approvedCode: 'White MB', approvedPrice: 250.00, activeAlt: 'alt1', alt1Code: 'White MB Grade A', alt1Price: 250.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },

    // Atharva Polymer
    { id: 'rm-ath-1', vendor: 'Atharva Polymer', type: 'RM', approvedCode: 'HIPS-SH03', approvedPrice: 147.87, activeAlt: 'alt1', alt1Code: 'HIPS-SH03 Prime Lot', alt1Price: 157.46, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'rm-ath-2', vendor: 'Atharva Polymer', type: 'RM', approvedCode: 'PP B-400MN', approvedPrice: 132.76, activeAlt: 'alt1', alt1Code: 'PP B-400MN (IOCL)', alt1Price: 135.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-ath-1', vendor: 'Atharva Polymer', type: 'MB', approvedCode: 'White MB', approvedPrice: 250.00, activeAlt: 'alt1', alt1Code: 'White MB Grade A', alt1Price: 250.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 }
  ],

  // Products Baseline Master
  baselineProducts: [
    {
      id: 'prod-at-1',
      vendor: 'Atomberg Technologies',
      itemCode: 'A1017031_tt2',
      componentName: 'Aris Top Canopy- Gloss Black',
      approvedRm: 'PP H110MA + Black MB',
      baseRm: 'PP H110MA',
      approvedMb: 'Black MB',
      masterbatchPct: 4.0,
      cavity: 2,
      netWeight: 37.0,
      runnerWeight: 1.0,
      bopCost: 0.00,
      machineTonnage: 200,
      shiftTariff: 2000,
      cycleTimeApproved: 47,
      packingCost: 0.86,
      transportCost: 0.62,
      parameters: {
        runningNetWeight: 37.0,
        runningRunnerWeight: 1.0,
        runningMbPct: 4.0,
        runningBopCost: 0.00,
        runningCycleTime: 47,
        runningCavity: 2,
        runningTonnage: 200,
        runningShiftTariff: 2000,
        runningPackingCost: 0.86,
        runningTransportCost: 0.62
      }
    },
    {
      id: 'prod-at-2',
      vendor: 'Atomberg Technologies',
      itemCode: 'A1017011_tt2',
      componentName: 'Aris Top Canopy- Gloss White',
      approvedRm: 'PP H110MA + White MB',
      baseRm: 'PP H110MA',
      approvedMb: 'White MB',
      masterbatchPct: 4.0,
      cavity: 2,
      netWeight: 37.0,
      runnerWeight: 1.0,
      bopCost: 0.00,
      machineTonnage: 200,
      shiftTariff: 2000,
      cycleTimeApproved: 47,
      packingCost: 0.86,
      transportCost: 0.62,
      parameters: {
        runningNetWeight: 37.0,
        runningRunnerWeight: 1.0,
        runningMbPct: 4.0,
        runningBopCost: 0.00,
        runningCycleTime: 47,
        runningCavity: 2,
        runningTonnage: 200,
        runningShiftTariff: 2000,
        runningPackingCost: 0.86,
        runningTransportCost: 0.62
      }
    },
    {
      id: 'prod-at-3',
      vendor: 'Atomberg Technologies',
      itemCode: 'A1017031_tt3',
      componentName: 'Aris Top Canopy- Gloss Black',
      approvedRm: 'PP Mi3530 + Gray MB',
      baseRm: 'PP Mi3530',
      approvedMb: 'Gray MB',
      masterbatchPct: 4.0,
      cavity: 2,
      netWeight: 37.0,
      runnerWeight: 1.0,
      bopCost: 0.00,
      machineTonnage: 200,
      shiftTariff: 2000,
      cycleTimeApproved: 47,
      packingCost: 0.86,
      transportCost: 0.62,
      parameters: {
        runningNetWeight: 37.0,
        runningRunnerWeight: 1.0,
        runningMbPct: 4.0,
        runningBopCost: 0.00,
        runningCycleTime: 47,
        runningCavity: 2,
        runningTonnage: 200,
        runningShiftTariff: 2000,
        runningPackingCost: 0.86,
        runningTransportCost: 0.62
      }
    },
    {
      id: 'prod-at-4',
      vendor: 'Atomberg Technologies',
      itemCode: 'A1017011_tt4',
      componentName: 'Aris Top Canopy- Gloss White',
      approvedRm: 'PP Mi3530 + GOLDEN MB',
      baseRm: 'PP Mi3530',
      approvedMb: 'GOLDEN MB',
      masterbatchPct: 4.0,
      cavity: 2,
      netWeight: 37.0,
      runnerWeight: 1.0,
      bopCost: 0.00,
      machineTonnage: 200,
      shiftTariff: 2000,
      cycleTimeApproved: 47,
      packingCost: 0.86,
      transportCost: 0.62,
      parameters: {
        runningNetWeight: 37.0,
        runningRunnerWeight: 1.0,
        runningMbPct: 4.0,
        runningBopCost: 0.00,
        runningCycleTime: 47,
        runningCavity: 2,
        runningTonnage: 200,
        runningShiftTariff: 2000,
        runningPackingCost: 0.86,
        runningTransportCost: 0.62
      }
    },
    {
      id: 'prod-ha-1',
      vendor: 'Haier Appliances',
      itemCode: '0060217989D',
      componentName: 'End cap Bottom Ref-ABS-DC-195,220',
      approvedRm: 'ABS 300 Pre Colour',
      baseRm: 'ABS 300 Pre Colour',
      approvedMb: 'Smoke Grey MB (3.5%)',
      masterbatchPct: 0.0,
      cavity: 2,
      netWeight: 197.0,
      runnerWeight: 40.0,
      bopCost: 0.14,
      machineTonnage: 450,
      shiftTariff: 4600,
      cycleTimeApproved: 56,
      packingCost: 0.00,
      transportCost: 0.00,
      parameters: {
        runningNetWeight: 197.0,
        runningRunnerWeight: 40.0,
        runningMbPct: 0.0,
        runningBopCost: 0.14,
        runningCycleTime: 56,
        runningCavity: 2,
        runningTonnage: 450,
        runningShiftTariff: 4600,
        runningPackingCost: 0.00,
        runningTransportCost: 0.00
      }
    },
    {
      id: 'prod-ha-2',
      vendor: 'Haier Appliances',
      itemCode: '0060217978E',
      componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX',
      approvedRm: 'GPPS SC201LV',
      baseRm: 'GPPS SC201LV',
      approvedMb: 'Smoke Grey MB (3.5%)',
      masterbatchPct: 3.5,
      cavity: 1,
      netWeight: 850.0,
      runnerWeight: 25.0,
      bopCost: 0.00,
      machineTonnage: 650,
      shiftTariff: 6200,
      cycleTimeApproved: 62,
      packingCost: 0.00,
      transportCost: 0.00,
      parameters: {
        runningNetWeight: 850.0,
        runningRunnerWeight: 25.0,
        runningMbPct: 3.5,
        runningBopCost: 0.00,
        runningCycleTime: 62,
        runningCavity: 1,
        runningTonnage: 650,
        runningShiftTariff: 6200,
        runningPackingCost: 0.00,
        runningTransportCost: 0.00
      }
    }
  ],

  // Inward Purchases Table
  purchases: [
    { date: '2026-08-10', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-001', itemCode: 'RM-PP-01', grade: 'PP H110MA Prime Inward', qty: 4500, rate: 133.80 },
    { date: '2026-08-05', supplier: 'LG Polymers India', invoiceNo: 'INV-HR-002', itemCode: 'MB-WHT-01', grade: 'White MB Grade A', qty: 300, rate: 250.00 },
    { date: '2026-08-01', supplier: 'Supreme Petrochem Ltd', invoiceNo: 'INV-HR-001', itemCode: 'RM-ABS-01', grade: 'ABS 300-B Red (Prime Inward)', qty: 5000, rate: 134.80 },
    { date: '2026-05-04', supplier: 'Supreme Petrochem Ltd', invoiceNo: 'INV-HR-MAY01', itemCode: 'RM-ABS-01', grade: 'ABS 300-B Red (Prime Inward)', qty: 4500, rate: 135.50 }
  ],

  sales: [
    { date: '2026-05-10', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-001', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 3800, sellingPrice: 42.00 },
    { date: '2026-05-15', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-002', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1500, sellingPrice: 85.00 },
    { date: '2026-05-20', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-001', itemCode: 'A1017011_tt2', componentName: 'Aris Top Canopy- Gloss White', qty: 3000, sellingPrice: 14.50 },
    { date: '2026-05-25', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-002', itemCode: 'A1017031_tt2', componentName: 'Aris Top Canopy- Gloss Black', qty: 900, sellingPrice: 15.96 },
    { date: '2026-08-10', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-007', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4200, sellingPrice: 42.00 },
    { date: '2026-08-12', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-008', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1800, sellingPrice: 85.00 }
  ],

  auditLogs: []
};

let listeners = [];
export function subscribeStore(fn) {
  listeners.push(fn);
  return () => { listeners = listeners.filter(cb => cb !== fn); };
}
export function notifyStore() {
  listeners.forEach(fn => { try { fn(globalStore); } catch (e) { console.error(e); } });
}

// ----------------------------------------------------------------------------
// MATERIAL STRING PARSER
// ----------------------------------------------------------------------------
export function parseMaterialString(rawMaterialStr) {
  if (!rawMaterialStr) return { baseRm: '', mbGrade: '' };
  const cleanStr = rawMaterialStr.toString().trim();
  if (cleanStr.includes('+')) {
    const parts = cleanStr.split('+').map(s => s.trim());
    return {
      baseRm: parts[0] || '',
      mbGrade: parts[1] || ''
    };
  }
  return {
    baseRm: cleanStr,
    mbGrade: ''
  };
}

// ----------------------------------------------------------------------------
// PRICE RESOLUTION ENGINE: Returns Approved Contract & Active Alternate WA
// ----------------------------------------------------------------------------
export function getActiveRmMapping(gradeName, vendor, targetDate) {
  if (!gradeName) {
    return { 
      approvedCode: 'Unspecified',
      approvedPrice: 0.00, 
      activeGrade: 'Unspecified', 
      activeWaPrice: 0.00, 
      activeAltKey: 'alt1',
      isFound: false 
    };
  }
  
  const { baseRm } = parseMaterialString(gradeName);
  const targetCode = (baseRm || gradeName).toLowerCase().trim();
  const vClean = (vendor || '').toLowerCase().trim();

  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'RM' && 
    (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim()) || r.vendor.toLowerCase().includes(vClean)) && 
    r.approvedCode.toLowerCase().trim() === targetCode
  );

  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] !== undefined ? found[`${activeKey}Price`] : (found.alt1Price || found.approvedPrice || 0));
    const activeGradeName = found[`${activeKey}Code`] || found.alt1Code || found.approvedCode;

    return {
      approvedCode: found.approvedCode,
      approvedPrice: Number(found.approvedPrice || 0),
      activeGrade: activeGradeName,
      activeWaPrice: Number(waPrice || 0),
      activeAltKey: activeKey,
      isFound: true
    };
  }

  return { 
    approvedCode: baseRm || gradeName, 
    approvedPrice: 0.00, 
    activeGrade: baseRm || gradeName, 
    activeWaPrice: 0.00, 
    activeAltKey: 'alt1',
    isFound: false 
  };
}

export function getActiveMbMapping(mbGradeName, vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase().trim();
  let targetMb = (mbGradeName || '').toLowerCase().trim();

  if (!targetMb) {
    return { 
      approvedMbCode: 'None',
      approvedMbPrice: 0.00, 
      activeMbGrade: 'None', 
      activeMbWaPrice: 0.00, 
      activeAltKey: 'alt1',
      isFound: false 
    };
  }

  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'MB' && 
    (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim()) || r.vendor.toLowerCase().includes(vClean)) && 
    r.approvedCode.toLowerCase().trim() === targetMb
  );

  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] !== undefined ? found[`${activeKey}Price`] : (found.alt1Price || found.approvedPrice || 0));
    const activeGradeName = found[`${activeKey}Code`] || found.alt1Code || found.approvedCode;

    return {
      approvedMbCode: found.approvedCode,
      approvedMbPrice: Number(found.approvedPrice || 0),
      activeMbGrade: activeGradeName,
      activeMbWaPrice: Number(waPrice || 0),
      activeAltKey: activeKey,
      isFound: true
    };
  }

  return { 
    approvedMbCode: mbGradeName, 
    approvedMbPrice: 0.00, 
    activeMbGrade: mbGradeName, 
    activeMbWaPrice: 0.00, 
    activeAltKey: 'alt1',
    isFound: false 
  };
}

// Robust purchase WA calculation matching both grade and itemCode
export function computeGradeWeightedAverage(gradeName) {
  if (!gradeName) return 0.00;
  const gClean = gradeName.toString().toLowerCase().trim();
  const purchases = globalStore.purchases || [];

  const matched = purchases.filter(p => {
    const pGrade = (p.grade || '').toString().toLowerCase().trim();
    const pCode = (p.itemCode || '').toString().toLowerCase().trim();
    return pGrade === gClean || pCode === gClean || pGrade.includes(gClean) || gClean.includes(pGrade);
  });

  if (matched.length === 0) return 0.00;

  const totalQty = matched.reduce((acc, p) => acc + (Number(p.qty) || 0), 0);
  const totalVal = matched.reduce((acc, p) => acc + ((Number(p.qty) || 0) * (Number(p.rate) || 0)), 0);

  if (totalQty > 0) {
    return Number((totalVal / totalQty).toFixed(2));
  }
  return Number(matched[0].rate || 0);
}

// ----------------------------------------------------------------------------
// MANUAL RM & MB MATRIX MANAGEMENT
// ----------------------------------------------------------------------------
export function addOrUpdateVendorMaterial({ id, vendor, type, approvedCode, approvedPrice, alt1Code, alt1Price }) {
  if (!globalStore.rmMappingsData) globalStore.rmMappingsData = [];
  
  const existingIdx = globalStore.rmMappingsData.findIndex(r => 
    (id && r.id === id) || 
    (r.vendor.toLowerCase().trim() === vendor.toLowerCase().trim() && 
     r.type === type && 
     r.approvedCode.toLowerCase().trim() === approvedCode.toLowerCase().trim())
  );

  const initialWa = alt1Price !== undefined ? Number(alt1Price) : computeGradeWeightedAverage(approvedCode) || Number(approvedPrice || 0);

  if (existingIdx >= 0) {
    globalStore.rmMappingsData[existingIdx] = {
      ...globalStore.rmMappingsData[existingIdx],
      approvedPrice: Number(approvedPrice),
      alt1Code: alt1Code || globalStore.rmMappingsData[existingIdx].alt1Code,
      alt1Price: alt1Price !== undefined ? Number(alt1Price) : globalStore.rmMappingsData[existingIdx].alt1Price
    };
  } else {
    globalStore.rmMappingsData.push({
      id: id || `mat-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
      vendor,
      type: type || 'RM',
      approvedCode,
      approvedPrice: Number(approvedPrice || 0),
      activeAlt: 'alt1',
      alt1Code: alt1Code || approvedCode,
      alt1Price: initialWa,
      alt2Code: '',
      alt2Price: 0.00,
      alt3Code: '',
      alt3Price: 0.00
    });
  }

  addAuditLog({
    partCode: approvedCode,
    componentName: `${type} Material Entry (${vendor})`,
    vendor,
    modifications: `Approved Price: ₹${approvedPrice}/kg`,
    costImpact: `₹${approvedPrice}/kg`,
    reason: 'Vendor RM/MB Master Updated'
  });

  notifyStore();
}

export function autoRegisterVendorRM({ vendor, approvedCode, approvedPrice, type = 'RM' }) {
  if (!approvedCode || !vendor) return;
  addOrUpdateVendorMaterial({
    vendor,
    type,
    approvedCode,
    approvedPrice: Number(approvedPrice || 0)
  });
}

export function getPurchasedGradesForVendor(vendor) {
  const purchases = globalStore.purchases || [];
  const list = [];
  purchases.forEach(p => {
    if (p.grade) list.push(p.grade.toString().trim());
    if (p.itemCode) list.push(p.itemCode.toString().trim());
  });
  return Array.from(new Set(list.filter(Boolean)));
}

export function deleteVendorMaterial(id) {
  globalStore.rmMappingsData = (globalStore.rmMappingsData || []).filter(r => r.id !== id);
  notifyStore();
}

export function updateRmMappingRow(rowId, updatedFields, reason) {
  const row = (globalStore.rmMappingsData || []).find(r => r.id === rowId);
  if (row) {
    Object.assign(row, updatedFields);
    addAuditLog({
      partCode: row.approvedCode,
      componentName: `${row.type} (${row.vendor})`,
      vendor: row.vendor,
      modifications: Object.entries(updatedFields).map(([k, v]) => `${k}: ${v}`).join(', '),
      costImpact: updatedFields.approvedPrice ? `₹${updatedFields.approvedPrice}/kg` : 'Updated',
      reason: reason || 'RM Mapping Updated'
    });
    notifyStore();
  }
}

// ----------------------------------------------------------------------------
// BASELINE MASTER PERSISTENCE
// ----------------------------------------------------------------------------
export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;

  if (updatedItem.approvedRm !== undefined) prod.approvedRm = updatedItem.approvedRm;
  if (updatedItem.baseRm !== undefined) prod.baseRm = updatedItem.baseRm;
  if (updatedItem.approvedMb !== undefined) prod.approvedMb = updatedItem.approvedMb;
  if (updatedItem.shiftTariff !== undefined) prod.shiftTariff = Number(updatedItem.shiftTariff);
  if (updatedItem.shiftRate !== undefined) prod.shiftRate = Number(updatedItem.shiftRate);
  if (updatedItem.masterbatchPct !== undefined) prod.masterbatchPct = Number(updatedItem.masterbatchPct);
  if (updatedItem.bopCost !== undefined) prod.bopCost = Number(updatedItem.bopCost);
  if (updatedItem.packingCost !== undefined) prod.packingCost = Number(updatedItem.packingCost);
  if (updatedItem.transportCost !== undefined) prod.transportCost = Number(updatedItem.transportCost);
  if (updatedItem.netWeight !== undefined) prod.netWeight = Number(updatedItem.netWeight);
  if (updatedItem.runnerWeight !== undefined) prod.runnerWeight = Number(updatedItem.runnerWeight);
  if (updatedItem.cavity !== undefined) prod.cavity = Number(updatedItem.cavity);
  if (updatedItem.machineTonnage !== undefined) prod.machineTonnage = Number(updatedItem.machineTonnage);
  if (updatedItem.cycleTimeApproved !== undefined) prod.cycleTimeApproved = Number(updatedItem.cycleTimeApproved);
  if (updatedItem.approvedCost !== undefined) prod.approvedCost = Number(updatedItem.approvedCost);

  if (updatedItem.parameters) {
    prod.parameters = { ...prod.parameters, ...updatedItem.parameters };
  }

  addAuditLog({
    partCode: prod.itemCode,
    componentName: prod.componentName,
    vendor: prod.vendor,
    modifications: Object.entries(updatedItem.parameters || {}).map(([k, v]) => `${k.replace('running', '')}: ${v}`).join(', '),
    costImpact: updatedItem.delta ? `₹${Number(updatedItem.delta).toFixed(2)}` : 'Calculated',
    reason: reason || 'Parameters Updated'
  });

  notifyStore();
}

export function addStagedProductsToBaseline(stagedList, vendor) {
  stagedList.forEach(staged => {
    const idx = globalStore.baselineProducts.findIndex(p => p.itemCode === staged.itemCode);
    if (idx >= 0) {
      globalStore.baselineProducts[idx] = { ...globalStore.baselineProducts[idx], ...staged };
    } else {
      globalStore.baselineProducts.push({
        ...staged,
        id: `prod-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
        vendor: vendor || staged.vendor || 'Atomberg Technologies'
      });
    }
  });
  notifyStore();
}

export function deleteProductFromBaseline(itemId, vendor) {
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => 
    p.id !== itemId && p.itemCode !== itemId
  );
  notifyStore();
}

export function getVendorBaselineData(vendorId) {
  const prods = globalStore.baselineProducts || [];
  if (!vendorId || vendorId === 'ALL') return prods;
  return prods.filter(p => (p.vendor || '').toLowerCase().includes(vendorId.toLowerCase()));
}

// ----------------------------------------------------------------------------
// DUAL-LEVEL LOCKS & TRANSACTIONS
// ----------------------------------------------------------------------------
export function toggleGlobalLock() {
  globalStore.isLocked = !globalStore.isLocked;
  addAuditLog({
    partCode: 'SYSTEM_LOCK',
    componentName: 'Global Baseline & RM Page Lock',
    vendor: 'ALL',
    modifications: `Status: ${globalStore.isLocked ? 'LOCKED' : 'UNLOCKED'}`,
    costImpact: globalStore.isLocked ? 'Frozen' : 'Editable',
    reason: 'Page Lock toggled by Administrator'
  });
  notifyStore();
}

export function toggleMatrixLock() {
  globalStore.isMatrixLocked = !globalStore.isMatrixLocked;
  addAuditLog({
    partCode: 'MATRIX_RATE_LOCK',
    componentName: 'RM Price Matrix Rate Lock (Level 2)',
    vendor: 'ALL',
    modifications: `Status: ${globalStore.isMatrixLocked ? 'LOCKED' : 'UNLOCKED'}`,
    costImpact: globalStore.isMatrixLocked ? 'Matrix Rates Frozen' : 'Matrix Rates Editable',
    reason: 'Matrix Rate Lock toggled by Administrator'
  });
  notifyStore();
}

export function addAuditLog(entry) {
  if (!globalStore.auditLogs) globalStore.auditLogs = [];
  globalStore.auditLogs.unshift({
    ...entry,
    id: `log-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
    timestamp: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', second: '2-digit' })
  });
}

export function onboardVendorWithBlueprint({ vendorId, vendorName }) {
  if (!globalStore.vendors.find(v => v.vendorId === vendorId)) {
    globalStore.vendors.push({ vendorId, vendorName });
    notifyStore();
  }
}

export function saveVendorPeriodSchedule() {
  addAuditLog({
    partCode: 'Period Schedule',
    componentName: 'Vendor Period Sync',
    vendor: 'General',
    modifications: 'Saved current period schedule and RM mappings',
    costImpact: 'Schedule Locked',
    reason: 'Vendor + Period Sync Action'
  });
  notifyStore();
}

export function addDayWisePurchase(record) {
  if (!globalStore.purchases) globalStore.purchases = [];
  
  const sClean = (record.supplier || '').toLowerCase().trim();
  const invClean = (record.invoiceNo || '').toLowerCase().trim();
  const itemClean = (record.itemCode || record.grade || '').toLowerCase().trim();

  const isDuplicate = globalStore.purchases.some(p => 
    (p.supplier || '').toLowerCase().trim() === sClean &&
    (p.invoiceNo || '').toLowerCase().trim() === invClean &&
    ((p.itemCode || p.grade || '').toLowerCase().trim() === itemClean)
  );

  if (isDuplicate) {
    return { success: false, duplicate: true, message: `Duplicate purchase entry ignored: ${record.supplier} | ${record.invoiceNo} | ${record.itemCode || record.grade}` };
  }

  globalStore.purchases.unshift(record);
  notifyStore();
  return { success: true };
}

export function addDayWiseSales(record) {
  if (!globalStore.sales) globalStore.sales = [];

  const vClean = (record.vendor || '').toLowerCase().trim();
  const invClean = (record.invoiceNo || '').toLowerCase().trim();
  const itemClean = (record.itemCode || '').toLowerCase().trim();

  const isDuplicate = globalStore.sales.some(s => 
    (s.vendor || '').toLowerCase().trim() === vClean &&
    (s.invoiceNo || '').toLowerCase().trim() === invClean &&
    (s.itemCode || '').toLowerCase().trim() === itemClean
  );

  if (isDuplicate) {
    return { success: false, duplicate: true, message: `Duplicate sales entry ignored: ${record.vendor} | ${record.invoiceNo} | ${record.itemCode}` };
  }

  globalStore.sales.unshift(record);
  notifyStore();
  return { success: true };
}
STORE_EOF

echo "==> 2. Updating RMPriceMatrixPage.jsx to aggregate all purchases for alternate dropdowns and compute live WA rates..."
cat << 'PAGE_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Plus, 
  Trash2, 
  Save, 
  Lock, 
  Unlock, 
  Search, 
  Filter, 
  TrendingUp, 
  Layers, 
  Upload, 
  Download,
  AlertCircle,
  CheckCircle2,
  PackagePlus,
  Table,
  ShoppingCart,
  TrendingDown,
  History,
  X,
  ShieldCheck,
  ShieldAlert
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  updateRmMappingRow, 
  addDayWisePurchase, 
  addDayWiseSales, 
  toggleGlobalLock,
  toggleMatrixLock,
  saveVendorPeriodSchedule,
  addOrUpdateVendorMaterial,
  deleteVendorMaterial,
  computeGradeWeightedAverage
} from '../../shared/masterStore';

// Robust Date Parser
function parseExcelDate(val) {
  if (!val) return new Date().toISOString().split('T')[0];

  if (typeof val === 'number' || (!isNaN(val) && !val.toString().includes('-') && !val.toString().includes('/'))) {
    const serial = Number(val);
    const utcDays = Math.floor(serial - 25569);
    const utcValue = utcDays * 86400;
    const dateInfo = new Date(utcValue * 1000);
    const y = dateInfo.getFullYear();
    const m = String(dateInfo.getMonth() + 1).padStart(2, '0');
    const d = String(dateInfo.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  const str = val.toString().trim();
  if (str.includes('-')) {
    const parts = str.split('-');
    if (parts.length === 3) {
      if (parts[0].length === 2 && (parts[2].length === 2 || parts[2].length === 4)) {
        const day = parts[0].padStart(2, '0');
        const month = parts[1].padStart(2, '0');
        let year = parts[2];
        if (year.length === 2) year = `20${year}`;
        return `${year}-${month}-${day}`;
      }
      if (parts[0].length === 4) {
        return `${parts[0]}-${parts[1].padStart(2, '0')}-${parts[2].padStart(2, '0')}`;
      }
    }
  }

  if (str.includes('/')) {
    const parts = str.split('/');
    if (parts.length === 3) {
      const day = parts[0].padStart(2, '0');
      const month = parts[1].padStart(2, '0');
      let year = parts[2];
      if (year.length === 2) year = `20${year}`;
      return `${year}-${month}-${day}`;
    }
  }

  return str;
}

export default function RMPriceMatrixPage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('Atomberg Technologies');
  const [activeSubTab, setActiveSubTab] = useState('matrix');
  const [searchQuery, setSearchQuery] = useState('');
  const [periodStart, setPeriodStart] = useState('2026-08-01');
  const [periodEnd, setPeriodEnd] = useState('2026-08-31');

  // Add Vendor RM/MB Modal
  const [showAddMatModal, setShowAddMatModal] = useState(false);
  const [newMatType, setNewMatType] = useState('RM');
  const [newMatCode, setNewMatCode] = useState('');
  const [newMatApprovedPrice, setNewMatApprovedPrice] = useState('');

  // Staging Modals
  const [showPurchaseStagingModal, setShowPurchaseStagingModal] = useState(false);
  const [stagedPurchases, setStagedPurchases] = useState([]);

  const [showSalesStagingModal, setShowSalesStagingModal] = useState(false);
  const [stagedSales, setStagedSales] = useState([]);

  // Single Inward Purchase Form
  const [newPurchaseDate, setNewPurchaseDate] = useState('2026-08-15');
  const [newPurchaseSupplier, setNewPurchaseSupplier] = useState('');
  const [newPurchaseInvoice, setNewPurchaseInvoice] = useState('');
  const [newPurchaseItemCode, setNewPurchaseItemCode] = useState('');
  const [newPurchaseGrade, setNewPurchaseGrade] = useState('');
  const [newPurchaseQty, setNewPurchaseQty] = useState('');
  const [newPurchaseRate, setNewPurchaseRate] = useState('');

  // Single Sales Form
  const [newSaleDate, setNewSaleDate] = useState('2026-08-15');
  const [newSaleVendor, setNewSaleVendor] = useState('Atomberg Technologies');
  const [newSaleItemCode, setNewSaleItemCode] = useState('');
  const [newSaleInvoice, setNewSaleInvoice] = useState('');
  const [newSaleCompName, setNewSaleCompName] = useState('');
  const [newSaleQty, setNewSaleQty] = useState('');
  const [newSalePrice, setNewSalePrice] = useState('');

  useEffect(() => {
    const unsub = subscribeStore(() => {
      setStoreState({ ...globalStore });
    });
    return () => unsub();
  }, []);

  const isGlobalLocked = storeState.isLocked !== false;
  const isMatrixLocked = storeState.isMatrixLocked !== false;
  const effectiveMatrixLock = isGlobalLocked || isMatrixLocked;

  const vendors = storeState.vendors || [
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ];

  const filteredMaterials = (storeState.rmMappingsData || []).filter(r => {
    const vMatch = (r.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
                   selectedVendor.toLowerCase().includes((r.vendor || '').toLowerCase());
    const qMatch = (r.approvedCode || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
                   (r.type || '').toLowerCase().includes(searchQuery.toLowerCase());
    return vMatch && qMatch;
  });

  const allPurchases = storeState.purchases || [];

  const vendorSales = (storeState.sales || []).filter(s => 
    (s.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((s.vendor || '').toLowerCase())
  );

  const vendorLogs = (storeState.auditLogs || []).filter(l => 
    (l.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((l.vendor || '').toLowerCase()) ||
    l.vendor === 'ALL'
  );

  // Dynamic dropdown list collecting EVERY distinct grade & item code from purchases
  const purchaseGradeOptions = Array.from(new Set(
    allPurchases.flatMap(p => [
      (p.grade || '').toString().trim(),
      (p.itemCode || '').toString().trim()
    ]).filter(Boolean)
  ));

  // Add Material to Matrix
  const handleAddNewMaterial = (e) => {
    e.preventDefault();
    if (isGlobalLocked) {
      alert("Page is Locked! Please unlock first.");
      return;
    }
    if (!newMatCode || !newMatApprovedPrice) {
      alert("Please provide both Material Code and Approved Base Price.");
      return;
    }

    addOrUpdateVendorMaterial({
      vendor: selectedVendor,
      type: newMatType,
      approvedCode: newMatCode.trim(),
      approvedPrice: Number(newMatApprovedPrice)
    });

    setNewMatCode('');
    setNewMatApprovedPrice('');
    setShowAddMatModal(false);
  };

  // Add Single Purchase
  const handleAddPurchase = (e) => {
    e.preventDefault();
    if (isGlobalLocked) {
      alert("Page is Locked! Unlock before adding inward records.");
      return;
    }
    if (!newPurchaseSupplier || !newPurchaseInvoice || !newPurchaseItemCode || !newPurchaseQty || !newPurchaseRate) {
      alert("Please fill Supplier, Invoice #, Item Code, Inward Qty, and Purchase Rate.");
      return;
    }

    const res = addDayWisePurchase({
      date: newPurchaseDate,
      supplier: newPurchaseSupplier.trim(),
      invoiceNo: newPurchaseInvoice.trim(),
      itemCode: newPurchaseItemCode.trim(),
      grade: newPurchaseGrade.trim() || newPurchaseItemCode.trim(),
      qty: Number(newPurchaseQty),
      rate: Number(newPurchaseRate)
    });

    if (res?.duplicate) {
      alert(`⚠️ Duplicate Rejected: Purchase lot for Supplier "${newPurchaseSupplier}" with Invoice #${newPurchaseInvoice} and Item Code "${newPurchaseItemCode}" already exists!`);
      return;
    }

    setNewPurchaseItemCode('');
    setNewPurchaseGrade('');
    setNewPurchaseQty('');
    setNewPurchaseRate('');
    setNewPurchaseInvoice('');
  };

  // Add Single Sales
  const handleAddSale = (e) => {
    e.preventDefault();
    if (isGlobalLocked) {
      alert("Page is Locked! Unlock before recording dispatch.");
      return;
    }
    if (!newSaleInvoice || !newSaleItemCode || !newSaleQty) {
      alert("Please fill Invoice Number, Item Code, and Dispatch Qty.");
      return;
    }

    const res = addDayWiseSales({
      date: newSaleDate,
      vendor: newSaleVendor || selectedVendor,
      invoiceNo: newSaleInvoice.trim(),
      itemCode: newSaleItemCode.trim(),
      componentName: newSaleCompName.trim() || 'Dispatched Component',
      qty: Number(newSaleQty),
      sellingPrice: newSalePrice ? Number(newSalePrice) : 0
    });

    if (res?.duplicate) {
      alert(`⚠️ Duplicate Rejected: Sales entry for Vendor "${newSaleVendor}" with Invoice #${newSaleInvoice} and Item Code "${newSaleItemCode}" already exists!`);
      return;
    }

    setNewSaleItemCode('');
    setNewSaleInvoice('');
    setNewSaleCompName('');
    setNewSaleQty('');
    setNewSalePrice('');
  };

  // Purchase Staging & Import
  const handlePurchaseFileUpload = (e) => {
    if (isGlobalLocked) {
      alert("Page is Locked! Please unlock first.");
      e.target.value = null;
      return;
    }

    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const bstr = evt.target.result;
        const wb = XLSX.read(bstr, { type: 'binary' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const data = XLSX.utils.sheet_to_json(ws);

        const staged = [];
        data.forEach((row, rIdx) => {
          const supplier = row['Supplier'] || row['Sulpplier'] || row['Vendor'] || '';
          const invoiceNo = row['Invoice #'] || row['Invoice Number'] || row['Inv No'] || row['Invoice'] || '';
          const itemCode = row['Item Code'] || row['Part Code'] || row['Material Code'] || '';
          const grade = row['Grade'] || row['RM Grade'] || itemCode || '';
          const qty = Number(row['Inward Qty (kg)'] || row['Qty'] || row['Quantity'] || 0);
          const rate = Number(row['Purchase Rate (₹/kg)'] || row['Rate'] || row['Price'] || 0);
          const rawDate = row['Date (DD-MM-YY)'] || row['Date'] || newPurchaseDate;

          if (!supplier || !invoiceNo || qty <= 0 || rate <= 0) return;
          if (supplier.toString().toLowerCase().includes('total') || supplier.toString().toLowerCase().includes('count')) return;

          const cleanDate = parseExcelDate(rawDate);

          const isDuplicate = allPurchases.some(p => 
            (p.supplier || '').toLowerCase().trim() === supplier.toString().toLowerCase().trim() &&
            (p.invoiceNo || '').toLowerCase().trim() === invoiceNo.toString().toLowerCase().trim() &&
            ((p.itemCode || p.grade || '').toLowerCase().trim() === (itemCode || grade).toString().toLowerCase().trim())
          );

          staged.push({
            id: `staged-p-${rIdx}`,
            date: cleanDate,
            supplier: supplier.toString().trim(),
            invoiceNo: invoiceNo.toString().trim(),
            itemCode: itemCode.toString().trim(),
            grade: grade.toString().trim(),
            qty,
            rate,
            isDuplicate
          });
        });

        if (staged.length === 0) {
          alert("No valid purchase records found in file.");
          return;
        }

        setStagedPurchases(staged);
        setShowPurchaseStagingModal(true);
      } catch (err) {
        console.error(err);
        alert("Error parsing purchase Excel file.");
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  const confirmPurchaseImport = () => {
    let added = 0;
    stagedPurchases.forEach(p => {
      if (!p.isDuplicate) {
        addDayWisePurchase({
          date: p.date,
          supplier: p.supplier,
          invoiceNo: p.invoiceNo,
          itemCode: p.itemCode,
          grade: p.grade,
          qty: p.qty,
          rate: p.rate
        });
        added++;
      }
    });

    setShowPurchaseStagingModal(false);
    setStagedPurchases([]);
    alert(`Successfully imported ${added} purchase records! All newly added grades are available in the Alternate dropdown.`);
  };

  // Sales Staging & Import
  const handleSalesFileUpload = (e) => {
    if (isGlobalLocked) {
      alert("Page is Locked! Please unlock first.");
      e.target.value = null;
      return;
    }

    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const bstr = evt.target.result;
        const wb = XLSX.read(bstr, { type: 'binary' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const data = XLSX.utils.sheet_to_json(ws);

        const staged = [];
        data.forEach((row, rIdx) => {
          const vendor = row['Vendor'] || selectedVendor || '';
          const invoiceNo = row['Invoice Number'] || row['Invoice #'] || row['Inv No'] || '';
          const itemCode = row['Item Code'] || row['Part Code'] || '';
          const compName = row['Component Name'] || row['Description'] || 'Dispatched Component';
          const qty = Number(row['Dispatch Qty'] || row['Qty'] || row['Quantity'] || 0);
          const sellingPrice = Number(row['Selling Price (₹)'] || row['Price'] || 0);
          const rawDate = row['Date (DD-MM-YY)'] || row['Date'] || newSaleDate;

          if (!vendor || !invoiceNo || !itemCode || qty <= 0) return;
          if (vendor.toString().toLowerCase().includes('total') || compName.toString().toLowerCase().includes('invoice count')) return;

          const cleanDate = parseExcelDate(rawDate);

          const isDuplicate = (storeState.sales || []).some(s => 
            (s.vendor || '').toLowerCase().trim() === vendor.toString().toLowerCase().trim() &&
            (s.invoiceNo || '').toLowerCase().trim() === invoiceNo.toString().toLowerCase().trim() &&
            (s.itemCode || '').toLowerCase().trim() === itemCode.toString().toLowerCase().trim()
          );

          staged.push({
            id: `staged-s-${rIdx}`,
            date: cleanDate,
            vendor: vendor.toString().trim(),
            invoiceNo: invoiceNo.toString().trim(),
            itemCode: itemCode.toString().trim(),
            componentName: compName.toString().trim(),
            qty,
            sellingPrice,
            isDuplicate
          });
        });

        if (staged.length === 0) {
          alert("No valid sales records found in file.");
          return;
        }

        setStagedSales(staged);
        setShowSalesStagingModal(true);
      } catch (err) {
        console.error(err);
        alert("Error parsing sales Excel file.");
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  const confirmSalesImport = () => {
    let added = 0;
    stagedSales.forEach(s => {
      if (!s.isDuplicate) {
        addDayWiseSales({
          date: s.date,
          vendor: s.vendor,
          invoiceNo: s.invoiceNo,
          itemCode: s.itemCode,
          componentName: s.componentName,
          qty: s.qty,
          sellingPrice: s.sellingPrice
        });
        added++;
      }
    });

    setShowSalesStagingModal(false);
    setStagedSales([]);
    alert(`Successfully imported ${added} sales dispatch records!`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Layers className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">RM Mapping & Inward Registry</h1>
            <p className="text-[11px] text-slate-300">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => {
              if (isGlobalLocked) {
                alert("Page is Locked! Please unlock the page first.");
                return;
              }
              setShowAddMatModal(true);
            }}
            disabled={isGlobalLocked}
            className="px-3.5 py-1.5 bg-purple-600 hover:bg-purple-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm text-xs disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <PackagePlus className="w-4 h-4" /> + Add Vendor RM / MB
          </button>

          <button
            onClick={toggleGlobalLock}
            className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl font-bold text-xs cursor-pointer transition-all shadow-md ${
              isGlobalLocked 
                ? 'bg-amber-500 hover:bg-amber-600 text-white animate-pulse' 
                : 'bg-emerald-600 hover:bg-emerald-700 text-white'
            }`}
          >
            {isGlobalLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4" />}
            {isGlobalLocked ? 'Page Locked (Click to Unlock & Edit)' : 'Page Unlocked (Editing Active)'}
          </button>
        </div>
      </div>

      {/* Sub-Tabs Navigation */}
      <div className="flex items-center gap-2">
        <button
          onClick={() => setActiveSubTab('matrix')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl font-bold cursor-pointer transition-all ${
            activeSubTab === 'matrix' ? 'bg-blue-600 text-white shadow-md' : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
          }`}
        >
          <Table className="w-4 h-4" /> RM Price Matrix
        </button>

        <button
          onClick={() => setActiveSubTab('purchases')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl font-bold cursor-pointer transition-all ${
            activeSubTab === 'purchases' ? 'bg-blue-600 text-white shadow-md' : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
          }`}
        >
          <ShoppingCart className="w-4 h-4" /> Day-wise Purchases ({allPurchases.length})
        </button>

        <button
          onClick={() => setActiveSubTab('sales')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl font-bold cursor-pointer transition-all ${
            activeSubTab === 'sales' ? 'bg-blue-600 text-white shadow-md' : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
          }`}
        >
          <TrendingUp className="w-4 h-4" /> Day-wise Sales ({vendorSales.length})
        </button>

        <button
          onClick={() => setActiveSubTab('audit')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl font-bold cursor-pointer transition-all ${
            activeSubTab === 'audit' ? 'bg-blue-600 text-white shadow-md' : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
          }`}
        >
          <History className="w-4 h-4" /> Baseline & RM Change Log ({vendorLogs.length})
        </button>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5 font-bold text-slate-700">
            <Filter className="w-3.5 h-3.5 text-blue-600" /> FILTER: Vendor:
          </div>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="px-3 py-1.5 border border-slate-300 rounded-xl font-bold bg-white text-slate-800 text-xs min-w-[200px]"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>

          <span className="text-slate-500 font-semibold ml-2">Period: From</span>
          <input type="date" value={periodStart} onChange={e => setPeriodStart(e.target.value)} className="px-2 py-1 border rounded-lg text-xs" />
          <span className="text-slate-500 font-semibold">To</span>
          <input type="date" value={periodEnd} onChange={e => setPeriodEnd(e.target.value)} className="px-2 py-1 border rounded-lg text-xs" />
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={toggleMatrixLock}
            className={`flex items-center gap-1.5 px-3.5 py-2 rounded-xl font-bold text-xs cursor-pointer transition-all border ${
              isMatrixLocked
                ? 'bg-rose-50 text-rose-700 border-rose-300 hover:bg-rose-100 shadow-xs'
                : 'bg-emerald-50 text-emerald-700 border-emerald-300 hover:bg-emerald-100 shadow-xs'
            }`}
          >
            {isMatrixLocked ? <ShieldAlert className="w-4 h-4 text-rose-600" /> : <ShieldCheck className="w-4 h-4 text-emerald-600" />}
            {isMatrixLocked ? 'Matrix Rates Locked (Level 2)' : 'Matrix Rates Editable (Level 2)'}
          </button>

          <button
            onClick={() => {
              saveVendorPeriodSchedule();
              alert(`Schedule and Price Matrix saved for ${selectedVendor}!`);
            }}
            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"
          >
            <Save className="w-4 h-4" /> Save for Vendor + period
          </button>
        </div>
      </div>

      {/* 1. RM PRICE MATRIX TABLE */}
      {activeSubTab === 'matrix' && (
        <div className="bg-white rounded-2xl border border-slate-200 overflow-x-auto shadow-sm">
          <table className="w-full text-left border-collapse text-xs min-w-[1000px]">
            <thead className="bg-slate-900 text-white uppercase text-[10px] font-bold">
              <tr>
                <th className="py-3 px-4 w-48">APPROVED RM/MB CODE</th>
                <th className="py-3 px-4 text-center w-36">APPROVED PRICE (₹/KG)</th>
                <th className="py-3 px-4 w-60">ALTERNATE RM-1</th>
                <th className="py-3 px-4 text-center w-32">PRICE (WA)</th>
                <th className="py-3 px-4 w-60">ALTERNATE RM-2</th>
                <th className="py-3 px-4 text-center w-32">PRICE (WA)</th>
                <th className="py-3 px-4 w-60">ALTERNATE RM-3</th>
                <th className="py-3 px-4 text-center w-32">PRICE (WA)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredMaterials.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-8 text-center text-slate-400">
                    No RM/MB mappings registered under {selectedVendor}. Unlock and click <strong>"+ Add Vendor RM / MB"</strong> to add materials.
                  </td>
                </tr>
              ) : (
                filteredMaterials.map(mat => {
                  return (
                    <tr key={mat.id} className="hover:bg-slate-50 transition-colors">
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <span className={`px-2 py-0.5 rounded font-bold text-[10px] ${
                            mat.type === 'MB' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                          }`}>
                            {mat.type === 'MB' ? 'MASTERBATCH' : 'RM CODE'}
                          </span>
                          <span className="font-bold text-slate-900">{mat.approvedCode}</span>
                        </div>
                      </td>

                      {/* Editable Approved Price */}
                      <td className="py-3 px-4 text-center">
                        <div className="flex items-center justify-center">
                          <span className="text-slate-500 font-bold mr-1">₹</span>
                          <input
                            type="number"
                            step="0.01"
                            disabled={effectiveMatrixLock}
                            value={mat.approvedPrice}
                            onChange={e => updateRmMappingRow(mat.id, { approvedPrice: Number(e.target.value) }, 'Approved Base Price Updated')}
                            className="w-24 px-2 py-1 border border-amber-400 bg-amber-50 rounded-lg text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500 disabled:bg-slate-100 disabled:border-slate-300 disabled:text-slate-800"
                          />
                        </div>
                      </td>

                      {/* Alternate 1 */}
                      <td className="py-3 px-4">
                        <div className={`p-2 rounded-xl border ${mat.activeAlt === 'alt1' || !mat.activeAlt ? 'bg-blue-50/50 border-blue-400' : 'border-slate-200'}`}>
                          <select
                            disabled={effectiveMatrixLock}
                            value={mat.alt1Code || mat.approvedCode}
                            onChange={e => {
                              const chosen = e.target.value;
                              const wa = computeGradeWeightedAverage(chosen) || (mat.approvedPrice || 0);
                              updateRmMappingRow(mat.id, { 
                                alt1Code: chosen,
                                alt1Price: wa
                              });
                            }}
                            className="w-full px-2 py-1 border border-slate-300 rounded-lg text-xs bg-white font-medium disabled:bg-slate-100"
                          >
                            <option value={mat.approvedCode}>{mat.approvedCode} (Contract Default)</option>
                            {purchaseGradeOptions.filter(g => g !== mat.approvedCode).map(g => (
                              <option key={g} value={g}>{g}</option>
                            ))}
                          </select>
                          <div className="flex items-center justify-between mt-1.5 pt-1 border-t border-slate-200">
                            <label className="flex items-center gap-1.5 cursor-pointer text-[11px] font-semibold text-slate-700">
                              <input
                                type="radio"
                                name={`active-${mat.id}`}
                                disabled={effectiveMatrixLock}
                                checked={mat.activeAlt === 'alt1' || !mat.activeAlt}
                                onChange={() => updateRmMappingRow(mat.id, { activeAlt: 'alt1' })}
                              />
                              Set Active
                            </label>
                            <span className={`text-[10px] px-2 py-0.5 rounded font-bold ${
                              mat.activeAlt === 'alt1' || !mat.activeAlt ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-600'
                            }`}>
                              {mat.activeAlt === 'alt1' || !mat.activeAlt ? 'ACTIVE' : 'STANDBY'}
                            </span>
                          </div>
                        </div>
                      </td>

                      <td className="py-3 px-4 text-center font-mono font-bold text-blue-700 text-xs">
                        ₹{Number(mat.alt1Price !== undefined ? mat.alt1Price : mat.approvedPrice).toFixed(2)}
                      </td>

                      {/* Alternate 2 */}
                      <td className="py-3 px-4">
                        <div className={`p-2 rounded-xl border ${mat.activeAlt === 'alt2' ? 'bg-blue-50/50 border-blue-400' : 'border-slate-200'}`}>
                          <select
                            disabled={effectiveMatrixLock}
                            value={mat.alt2Code || ''}
                            onChange={e => {
                              const chosen = e.target.value;
                              const wa = computeGradeWeightedAverage(chosen);
                              updateRmMappingRow(mat.id, { 
                                alt2Code: chosen,
                                alt2Price: wa
                              });
                            }}
                            className="w-full px-2 py-1 border border-slate-300 rounded-lg text-xs bg-white font-medium disabled:bg-slate-100"
                          >
                            <option value="">Select Alternate Lot 2...</option>
                            {purchaseGradeOptions.map(g => (
                              <option key={g} value={g}>{g}</option>
                            ))}
                          </select>
                          <div className="flex items-center justify-between mt-1.5 pt-1 border-t border-slate-200">
                            <label className="flex items-center gap-1.5 cursor-pointer text-[11px] font-semibold text-slate-700">
                              <input
                                type="radio"
                                name={`active-${mat.id}`}
                                disabled={effectiveMatrixLock}
                                checked={mat.activeAlt === 'alt2'}
                                onChange={() => updateRmMappingRow(mat.id, { activeAlt: 'alt2' })}
                              />
                              Set Active
                            </label>
                            <span className={`text-[10px] px-2 py-0.5 rounded font-bold ${
                              mat.activeAlt === 'alt2' ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-600'
                            }`}>
                              {mat.activeAlt === 'alt2' ? 'ACTIVE' : 'STANDBY'}
                            </span>
                          </div>
                        </div>
                      </td>

                      <td className="py-3 px-4 text-center font-mono font-bold text-slate-700 text-xs">
                        ₹{Number(mat.alt2Price || 0).toFixed(2)}
                      </td>

                      {/* Alternate 3 */}
                      <td className="py-3 px-4">
                        <div className={`p-2 rounded-xl border ${mat.activeAlt === 'alt3' ? 'bg-blue-50/50 border-blue-400' : 'border-slate-200'}`}>
                          <select
                            disabled={effectiveMatrixLock}
                            value={mat.alt3Code || ''}
                            onChange={e => {
                              const chosen = e.target.value;
                              const wa = computeGradeWeightedAverage(chosen);
                              updateRmMappingRow(mat.id, { 
                                alt3Code: chosen,
                                alt3Price: wa
                              });
                            }}
                            className="w-full px-2 py-1 border border-slate-300 rounded-lg text-xs bg-white font-medium disabled:bg-slate-100"
                          >
                            <option value="">Select Alternate Lot 3...</option>
                            {purchaseGradeOptions.map(g => (
                              <option key={g} value={g}>{g}</option>
                            ))}
                          </select>
                          <div className="flex items-center justify-between mt-1.5 pt-1 border-t border-slate-200">
                            <label className="flex items-center gap-1.5 cursor-pointer text-[11px] font-semibold text-slate-700">
                              <input
                                type="radio"
                                name={`active-${mat.id}`}
                                disabled={effectiveMatrixLock}
                                checked={mat.activeAlt === 'alt3'}
                                onChange={() => updateRmMappingRow(mat.id, { activeAlt: 'alt3' })}
                              />
                              Set Active
                            </label>
                            <span className={`text-[10px] px-2 py-0.5 rounded font-bold ${
                              mat.activeAlt === 'alt3' ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-600'
                            }`}>
                              {mat.activeAlt === 'alt3' ? 'ACTIVE' : 'STANDBY'}
                            </span>
                          </div>
                        </div>
                      </td>

                      <td className="py-3 px-4 text-center font-mono font-bold text-slate-700 text-xs">
                        ₹{Number(mat.alt3Price || 0).toFixed(2)}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* 2. DAY-WISE PURCHASES */}
      {activeSubTab === 'purchases' && (
        <div className="space-y-4">
          <div className="bg-white p-4 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
            <form onSubmit={handleAddPurchase} className="flex flex-wrap items-center gap-2 flex-1">
              <span className="font-bold text-slate-700">Add Purchase Inward:</span>
              <input type="date" disabled={isGlobalLocked} value={newPurchaseDate} onChange={e => setNewPurchaseDate(e.target.value)} className="px-2 py-1.5 border rounded-lg text-xs disabled:bg-slate-100" />
              <input type="text" disabled={isGlobalLocked} placeholder="Supplier Name" value={newPurchaseSupplier} onChange={e => setNewPurchaseSupplier(e.target.value)} className="px-2.5 py-1.5 border rounded-lg text-xs w-44 disabled:bg-slate-100" />
              <input type="text" disabled={isGlobalLocked} placeholder="Invoice #" value={newPurchaseInvoice} onChange={e => setNewPurchaseInvoice(e.target.value)} className="px-2.5 py-1.5 border rounded-lg font-mono text-xs w-28 disabled:bg-slate-100" />
              <input type="text" disabled={isGlobalLocked} placeholder="Item Code" value={newPurchaseItemCode} onChange={e => setNewPurchaseItemCode(e.target.value)} className="px-2.5 py-1.5 border rounded-lg font-mono text-xs w-28 disabled:bg-slate-100" />
              <input type="text" disabled={isGlobalLocked} placeholder="Grade Description" value={newPurchaseGrade} onChange={e => setNewPurchaseGrade(e.target.value)} className="px-2.5 py-1.5 border rounded-lg font-mono text-xs w-44 disabled:bg-slate-100" />
              <input type="number" disabled={isGlobalLocked} step="0.1" placeholder="Qty (kg)" value={newPurchaseQty} onChange={e => setNewPurchaseQty(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-24 text-right disabled:bg-slate-100" />
              <input type="number" disabled={isGlobalLocked} step="0.01" placeholder="Rate (₹/kg)" value={newPurchaseRate} onChange={e => setNewPurchaseRate(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-24 text-right disabled:bg-slate-100" />
              <button type="submit" disabled={isGlobalLocked} className="px-3.5 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed">
                <Plus className="w-3.5 h-3.5" /> Add Inward
              </button>
            </form>

            <label className={`px-3.5 py-1.5 rounded-xl font-bold flex items-center gap-1.5 text-xs shadow-sm ${
              isGlobalLocked 
                ? 'bg-slate-300 text-slate-500 cursor-not-allowed' 
                : 'bg-emerald-600 hover:bg-emerald-700 text-white cursor-pointer'
            }`}>
              <Upload className="w-3.5 h-3.5" /> Bulk Upload (.xlsx)
              <input type="file" accept=".xlsx, .xls, .csv" onChange={handlePurchaseFileUpload} className="hidden" />
            </label>
          </div>

          <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Date</th>
                  <th className="py-2.5 px-3">Supplier</th>
                  <th className="py-2.5 px-3">Invoice #</th>
                  <th className="py-2.5 px-3">Item Code</th>
                  <th className="py-2.5 px-4">Grade</th>
                  <th className="py-2.5 px-4 text-right">Inward Qty (kg)</th>
                  <th className="py-2.5 px-4 text-right">Purchase Rate (₹/kg)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {allPurchases.length === 0 ? (
                  <tr><td colSpan={7} className="py-8 text-center text-slate-400">No inward purchase records found.</td></tr>
                ) : (
                  allPurchases.map((p, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-600">{p.date}</td>
                      <td className="py-2.5 px-3 font-bold text-slate-800">{p.supplier || p.vendor || 'Supplier'}</td>
                      <td className="py-2.5 px-3 font-mono text-blue-700">{p.invoiceNo}</td>
                      <td className="py-2.5 px-3 font-mono text-slate-700 font-bold">{p.itemCode || '-'}</td>
                      <td className="py-2.5 px-4 font-mono font-bold text-slate-900">{p.grade}</td>
                      <td className="py-2.5 px-4 text-right font-mono">{p.qty?.toLocaleString()} kg</td>
                      <td className="py-2.5 px-4 text-right font-mono font-bold text-blue-700">₹{Number(p.rate || 0).toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* 3. DAY-WISE SALES */}
      {activeSubTab === 'sales' && (
        <div className="space-y-4">
          <div className="bg-white p-4 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
            <form onSubmit={handleAddSale} className="flex flex-wrap items-center gap-2 flex-1">
              <span className="font-bold text-slate-700">Add Dispatch Sale:</span>
              <input type="date" disabled={isGlobalLocked} value={newSaleDate} onChange={e => setNewSaleDate(e.target.value)} className="px-2 py-1.5 border rounded-lg text-xs disabled:bg-slate-100" />
              <select disabled={isGlobalLocked} value={newSaleVendor} onChange={e => setNewSaleVendor(e.target.value)} className="px-2 py-1.5 border rounded-lg text-xs font-bold disabled:bg-slate-100">
                {vendors.map(v => <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>)}
              </select>
              <input type="text" disabled={isGlobalLocked} placeholder="Item Code" value={newSaleItemCode} onChange={e => setNewSaleItemCode(e.target.value)} className="px-2.5 py-1.5 border rounded-lg font-mono text-xs w-36 disabled:bg-slate-100" />
              <input type="text" disabled={isGlobalLocked} placeholder="Invoice Number" value={newSaleInvoice} onChange={e => setNewSaleInvoice(e.target.value)} className="px-2.5 py-1.5 border rounded-lg font-mono text-xs w-36 disabled:bg-slate-100" />
              <input type="text" disabled={isGlobalLocked} placeholder="Component Name" value={newSaleCompName} onChange={e => setNewSaleCompName(e.target.value)} className="px-2.5 py-1.5 border rounded-lg text-xs w-48 disabled:bg-slate-100" />
              <input type="number" disabled={isGlobalLocked} step="1" placeholder="Dispatch Qty" value={newSaleQty} onChange={e => setNewSaleQty(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-28 text-right disabled:bg-slate-100" />
              <input type="number" disabled={isGlobalLocked} step="0.01" placeholder="Selling Price (₹)" value={newSalePrice} onChange={e => setNewSalePrice(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-28 text-right disabled:bg-slate-100" />
              <button type="submit" disabled={isGlobalLocked} className="px-3.5 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed">
                <Plus className="w-3.5 h-3.5" /> Record Dispatch
              </button>
            </form>

            <label className={`px-3.5 py-1.5 rounded-xl font-bold flex items-center gap-1.5 text-xs shadow-sm ${
              isGlobalLocked 
                ? 'bg-slate-300 text-slate-500 cursor-not-allowed' 
                : 'bg-emerald-600 hover:bg-emerald-700 text-white cursor-pointer'
            }`}>
              <Upload className="w-3.5 h-3.5" /> Bulk Upload (.xlsx)
              <input type="file" accept=".xlsx, .xls, .csv" onChange={handleSalesFileUpload} className="hidden" />
            </label>
          </div>

          <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Date</th>
                  <th className="py-2.5 px-3">Vendor</th>
                  <th className="py-2.5 px-3">Item Code</th>
                  <th className="py-2.5 px-3">Invoice Number</th>
                  <th className="py-2.5 px-4">Component Name</th>
                  <th className="py-2.5 px-4 text-right">Dispatch Qty</th>
                  <th className="py-2.5 px-4 text-right">Selling Price (₹)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {vendorSales.length === 0 ? (
                  <tr><td colSpan={7} className="py-8 text-center text-slate-400">No dispatch records recorded for {selectedVendor}.</td></tr>
                ) : (
                  vendorSales.map((s, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-600">{s.date}</td>
                      <td className="py-2.5 px-3 font-bold text-slate-800">{s.vendor}</td>
                      <td className="py-2.5 px-3 font-mono text-blue-700 font-bold">{s.itemCode}</td>
                      <td className="py-2.5 px-3 font-mono text-slate-700 font-bold">{s.invoiceNo}</td>
                      <td className="py-2.5 px-4 text-slate-900">{s.componentName}</td>
                      <td className="py-2.5 px-4 text-right font-mono font-bold">{s.qty?.toLocaleString()}</td>
                      <td className="py-2.5 px-4 text-right font-mono font-bold text-emerald-700">₹{Number(s.sellingPrice || 0).toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* 4. AUDIT LOG */}
      {activeSubTab === 'audit' && (
        <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-3">Timestamp</th>
                <th className="py-2.5 px-3">Code / Ref</th>
                <th className="py-2.5 px-3">Type / Target</th>
                <th className="py-2.5 px-3">Modifications</th>
                <th className="py-2.5 px-3 text-right">Cost Impact</th>
                <th className="py-2.5 px-3">Reason</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {vendorLogs.length === 0 ? (
                <tr><td colSpan={6} className="py-6 text-center text-slate-400">No modifications logged yet for {selectedVendor}.</td></tr>
              ) : (
                vendorLogs.map((log, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="py-2.5 px-3 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{log.partCode}</td>
                    <td className="py-2.5 px-3 font-semibold text-slate-800">{log.componentName}</td>
                    <td className="py-2.5 px-3 text-slate-600">{log.modifications}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">{log.costImpact}</td>
                    <td className="py-2.5 px-3 text-slate-500">{log.reason}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* PURCHASE STAGING MODAL */}
      {showPurchaseStagingModal && (
        <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
          <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full p-5 space-y-4 border border-slate-300 max-h-[92vh] flex flex-col justify-between">
            <div className="flex justify-between items-center border-b pb-3">
              <div>
                <h3 className="text-sm font-bold text-slate-900 flex items-center gap-1.5">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" /> Verify & Stage Purchase Import ({stagedPurchases.length} Rows)
                </h3>
                <p className="text-[11px] text-slate-500">Dates normalized to ISO. Duplicate entries (Supplier + Invoice + Item Code) are marked in red.</p>
              </div>
              <button onClick={() => setShowPurchaseStagingModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
            </div>

            <div className="border rounded-xl overflow-x-auto max-h-[55vh] overflow-y-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px] sticky top-0">
                  <tr>
                    <th className="py-2 px-3">Date (ISO)</th>
                    <th className="py-2 px-3">Supplier</th>
                    <th className="py-2 px-3">Invoice #</th>
                    <th className="py-2 px-3">Item Code</th>
                    <th className="py-2 px-4">Grade</th>
                    <th className="py-2 px-4 text-right">Qty (kg)</th>
                    <th className="py-2 px-4 text-right">Rate (₹/kg)</th>
                    <th className="py-2 px-3 text-center">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {stagedPurchases.map((p, idx) => (
                    <tr key={idx} className={p.isDuplicate ? 'bg-rose-50/60' : 'hover:bg-slate-50'}>
                      <td className="py-2 px-3 font-mono font-bold text-slate-900">{p.date}</td>
                      <td className="py-2 px-3 font-medium text-slate-800">{p.supplier}</td>
                      <td className="py-2 px-3 font-mono text-blue-700">{p.invoiceNo}</td>
                      <td className="py-2 px-3 font-mono text-slate-700 font-bold">{p.itemCode}</td>
                      <td className="py-2 px-4 text-slate-800">{p.grade}</td>
                      <td className="py-2 px-4 text-right font-mono font-bold">{p.qty?.toLocaleString()}</td>
                      <td className="py-2 px-4 text-right font-mono text-blue-700 font-bold">₹{p.rate}</td>
                      <td className="py-2 px-3 text-center">
                        {p.isDuplicate ? (
                          <span className="px-2 py-0.5 rounded font-bold text-[10px] bg-rose-100 text-rose-700">Duplicate (Skip)</span>
                        ) : (
                          <span className="px-2 py-0.5 rounded font-bold text-[10px] bg-emerald-100 text-emerald-700">Ready</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="flex justify-between items-center pt-2 border-t">
              <button onClick={() => setShowPurchaseStagingModal(false)} className="px-4 py-2 border rounded-xl font-bold hover:bg-slate-50">Cancel</button>
              <button onClick={confirmPurchaseImport} className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl flex items-center gap-1.5 shadow-sm">
                <CheckCircle2 className="w-4 h-4" /> Confirm & Import {stagedPurchases.filter(p => !p.isDuplicate).length} Records
              </button>
            </div>
          </div>
        </div>
      )}

      {/* SALES STAGING MODAL */}
      {showSalesStagingModal && (
        <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
          <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full p-5 space-y-4 border border-slate-300 max-h-[92vh] flex flex-col justify-between">
            <div className="flex justify-between items-center border-b pb-3">
              <div>
                <h3 className="text-sm font-bold text-slate-900 flex items-center gap-1.5">
                  <CheckCircle2 className="w-4 h-4 text-emerald-600" /> Verify & Stage Sales Import ({stagedSales.length} Rows)
                </h3>
                <p className="text-[11px] text-slate-500">Dates normalized to ISO. Duplicate records (Vendor + Invoice + Item Code) are marked in red.</p>
              </div>
              <button onClick={() => setShowSalesStagingModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
            </div>

            <div className="border rounded-xl overflow-x-auto max-h-[55vh] overflow-y-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px] sticky top-0">
                  <tr>
                    <th className="py-2 px-3">Date (ISO)</th>
                    <th className="py-2 px-3">Vendor</th>
                    <th className="py-2 px-3">Item Code</th>
                    <th className="py-2 px-3">Invoice #</th>
                    <th className="py-2 px-4">Component Name</th>
                    <th className="py-2 px-4 text-right">Qty</th>
                    <th className="py-2 px-4 text-right">Price</th>
                    <th className="py-2 px-3 text-center">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {stagedSales.map((s, idx) => (
                    <tr key={idx} className={s.isDuplicate ? 'bg-rose-50/60' : 'hover:bg-slate-50'}>
                      <td className="py-2 px-3 font-mono font-bold text-slate-900">{s.date}</td>
                      <td className="py-2 px-3 font-medium text-slate-800">{s.vendor}</td>
                      <td className="py-2 px-3 font-mono font-bold text-blue-700">{s.itemCode}</td>
                      <td className="py-2 px-3 font-mono text-slate-700">{s.invoiceNo}</td>
                      <td className="py-2 px-4 text-slate-800">{s.componentName}</td>
                      <td className="py-2 px-4 text-right font-mono font-bold">{s.qty?.toLocaleString()}</td>
                      <td className="py-2 px-4 text-right font-mono">₹{s.sellingPrice}</td>
                      <td className="py-2 px-3 text-center">
                        {s.isDuplicate ? (
                          <span className="px-2 py-0.5 rounded font-bold text-[10px] bg-rose-100 text-rose-700">Duplicate (Skip)</span>
                        ) : (
                          <span className="px-2 py-0.5 rounded font-bold text-[10px] bg-emerald-100 text-emerald-700">Ready</span>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="flex justify-between items-center pt-2 border-t">
              <button onClick={() => setShowSalesStagingModal(false)} className="px-4 py-2 border rounded-xl font-bold hover:bg-slate-50">Cancel</button>
              <button onClick={confirmSalesImport} className="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl flex items-center gap-1.5 shadow-sm">
                <CheckCircle2 className="w-4 h-4" /> Confirm & Import {stagedSales.filter(s => !s.isDuplicate).length} Records
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ADD VENDOR RM / MB POPUP MODAL */}
      {showAddMatModal && (
        <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-5 space-y-4 border border-slate-300 relative">
            <div className="flex justify-between items-center border-b pb-3">
              <div>
                <h3 className="text-sm font-bold text-slate-900 flex items-center gap-1.5">
                  <PackagePlus className="w-4 h-4 text-purple-600" /> Register Material: {selectedVendor}
                </h3>
                <p className="text-[11px] text-slate-500">Add a new approved Polymer (RM) or Masterbatch (MB) code.</p>
              </div>
              <button onClick={() => setShowAddMatModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
            </div>

            <form onSubmit={handleAddNewMaterial} className="space-y-3">
              <div>
                <label className="block font-bold text-slate-700 mb-1">Material Type</label>
                <select
                  value={newMatType}
                  onChange={e => setNewMatType(e.target.value)}
                  className="w-full px-3 py-2 border rounded-xl font-bold bg-white text-slate-800"
                >
                  <option value="RM">Raw Material / Base Polymer (RM)</option>
                  <option value="MB">Masterbatch (MB)</option>
                </select>
              </div>

              <div>
                <label className="block font-bold text-slate-700 mb-1">Approved Material Code</label>
                <input
                  type="text"
                  placeholder="e.g. HIPS-SH03 or White MB"
                  value={newMatCode}
                  onChange={e => setNewMatCode(e.target.value)}
                  className="w-full px-3 py-2 border rounded-xl font-mono font-bold text-slate-900"
                  required
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 mb-1">Approved Base Price (₹/kg)</label>
                <input
                  type="number"
                  step="0.01"
                  placeholder="e.g. 147.87"
                  value={newMatApprovedPrice}
                  onChange={e => setNewMatApprovedPrice(e.target.value)}
                  className="w-full px-3 py-2 border border-amber-400 bg-amber-50 rounded-xl font-mono font-bold text-amber-900"
                  required
                />
              </div>

              <div className="flex justify-end gap-2 pt-2 border-t">
                <button type="button" onClick={() => setShowAddMatModal(false)} className="px-4 py-2 border rounded-xl font-bold hover:bg-slate-50">Cancel</button>
                <button type="submit" className="px-5 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl flex items-center gap-1.5 shadow-sm">
                  <Plus className="w-4 h-4" /> Save Material to Matrix
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
PAGE_EOF

echo "==> 3. Verifying build with npm run build..."
npm run build

echo "==> 4. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Dynamic Alternate Dropdown & Purchase WA Engine live!"
echo "-------------------------------------------------------------------"
