#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js to support full alternate tracking & WA calculation..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// ============================================================================
// GLOBAL MASTER DATA STORE (Strict Approved vs Alternate Dual-Column Engine)
// ============================================================================

export let globalStore = {
  isLocked: true,        // Level 1: Global Page Lock
  isMatrixLocked: true,  // Level 2: Dedicated RM Price Matrix Rate Lock

  vendors: [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ],

  // RM & MB Master Matrix with Alternates 1, 2, 3
  rmMappingsData: [
    // Atomberg RMs & MBs
    { id: 'rm-at-1', vendor: 'Atomberg Technologies', type: 'RM', approvedCode: 'PP H110MA', approvedPrice: 131.00, activeAlt: 'alt1', alt1Code: 'PP H110MA Prime Inward', alt1Price: 135.83, alt2Code: 'PP H240mn', alt2Price: 135.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'rm-at-2', vendor: 'Atomberg Technologies', type: 'RM', approvedCode: 'PP Mi3530', approvedPrice: 180.00, activeAlt: 'alt2', alt1Code: 'PP Mi3530 Prime Inward', alt1Price: 180.00, alt2Code: 'PP H240mn', alt2Price: 176.00, alt3Code: 'PP H220mn', alt3Price: 130.00 },
    { id: 'mb-at-1', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'Black MB', approvedPrice: 254.00, activeAlt: 'alt1', alt1Code: 'Black MB (Standard)', alt1Price: 258.54, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-2', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'White MB', approvedPrice: 260.00, activeAlt: 'alt1', alt1Code: 'White MB (Standard)', alt1Price: 265.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-3', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'Gray MB', approvedPrice: 150.00, activeAlt: 'alt1', alt1Code: 'Gray MB Prime Inward', alt1Price: 150.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-4', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'GOLDEN MB', approvedPrice: 450.00, activeAlt: 'alt2', alt1Code: 'GOLDEN MB (Prime Contract)', alt1Price: 450.00, alt2Code: 'GOLDEN MB', alt2Price: 190.00, alt3Code: '', alt3Price: 0.00 },

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
    { date: '2026-08-12', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-001', itemCode: 'MB- Gray MB', grade: 'GOLDEN MB', qty: 100, rate: 190.00 },
    { date: '2026-08-12', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-001', itemCode: 'MB- GOLDEN MB', grade: 'GOLDEN MB', qty: 100, rate: 190.00 },
    { date: '2026-08-10', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-0014', itemCode: 'RM-PP-MI3530', grade: 'PP H240mn', qty: 1500, rate: 176.00 },
    { date: '2026-08-05', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-0013', itemCode: 'RM-PP-B240MN', grade: 'PP H240mn', qty: 2500, rate: 135.00 },
    { date: '2026-08-01', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-0012', itemCode: 'RM-PP-B220MN', grade: 'PP H220mn', qty: 3000, rate: 130.00 },
    { date: '2026-08-12', supplier: 'IOCL Petrochemicals', invoiceNo: 'INV-ATH-001', itemCode: 'RM-HIPS-01', grade: 'HIPS-SH03 Prime Lot', qty: 4000, rate: 157.46 },
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

// Helper to compute Weighted Average Rate from purchases for any grade/lot
export function computeGradeWeightedAverage(gradeName) {
  if (!gradeName) return 0.00;
  const gClean = gradeName.toLowerCase().trim();
  const purchases = globalStore.purchases || [];

  const matched = purchases.filter(p => 
    (p.grade || '').toLowerCase().trim() === gClean ||
    (p.itemCode || '').toLowerCase().trim() === gClean
  );

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
  return Array.from(new Set(purchases.map(p => p.grade || p.itemCode).filter(Boolean)));
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

echo "==> 2. Updating RMPriceMatrixPage.jsx to automatically calculate WA rates on alternate selection..."
cat << 'MATRIX_EOF' > patch_matrix_page.py
with open("src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx", "r") as f:
    content = f.read()

# Replace Alternate dropdown handlers with automatic WA calculation
old_alt1_handler = """onChange={e => updateRmMappingRow(mat.id, { alt1Code: e.target.value })}"""
new_alt1_handler = """onChange={e => {
                            const chosenGrade = e.target.value;
                            import('../../shared/masterStore').then(({ computeGradeWeightedAverage }) => {
                              const autoWa = computeGradeWeightedAverage(chosenGrade);
                              updateRmMappingRow(mat.id, { 
                                alt1Code: chosenGrade,
                                alt1Price: autoWa > 0 ? autoWa : (mat.approvedPrice || 0)
                              });
                            });
                          }}"""

old_alt2_handler = """onChange={e => updateRmMappingRow(mat.id, { alt2Code: e.target.value })}"""
new_alt2_handler = """onChange={e => {
                            const chosenGrade = e.target.value;
                            import('../../shared/masterStore').then(({ computeGradeWeightedAverage }) => {
                              const autoWa = computeGradeWeightedAverage(chosenGrade);
                              updateRmMappingRow(mat.id, { 
                                alt2Code: chosenGrade,
                                alt2Price: autoWa
                              });
                            });
                          }}"""

old_alt3_handler = """onChange={e => updateRmMappingRow(mat.id, { alt3Code: e.target.value })}"""
new_alt3_handler = """onChange={e => {
                            const chosenGrade = e.target.value;
                            import('../../shared/masterStore').then(({ computeGradeWeightedAverage }) => {
                              const autoWa = computeGradeWeightedAverage(chosenGrade);
                              updateRmMappingRow(mat.id, { 
                                alt3Code: chosenGrade,
                                alt3Price: autoWa
                              });
                            });
                          }}"""

content = content.replace(old_alt1_handler, new_alt1_handler)
content = content.replace(old_alt2_handler, new_alt2_handler)
content = content.replace(old_alt3_handler, new_alt3_handler)

with open("src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx", "w") as f:
    f.write(content)
print("RMPriceMatrixPage.jsx patched with automatic purchase WA calculator on alternate selection!")
MATRIX_EOF
python3 patch_matrix_page.py

echo "==> 3. Updating InlineEditModal.jsx to display distinct Approved vs Actual Alternate columns..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, AlertTriangle, Trash2 } from 'lucide-react';
import { 
  getActiveRmMapping, 
  getActiveMbMapping, 
  parseMaterialString,
  deleteProductFromBaseline 
} from '../../shared/masterStore';
import { 
  calculateAtombergCost, 
  calculateHaierCost,
  calculateDetailedCost,
  calculatePieceCostUnified
} from '../../shared/costCalculationService';

export { 
  calculateDetailedCost, 
  calculateAtombergCost, 
  calculateHaierCost, 
  calculatePieceCostUnified 
};

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const isAtomberg = (item.vendor || '').toLowerCase().includes('atomberg');

  // Parse composite material string
  const initialParsed = parseMaterialString(item.approvedRm);
  const initialBaseRm = item.baseRm || initialParsed.baseRm || item.approvedRm || (isAtomberg ? 'PP H110MA' : 'ABS 300 Pre Colour');
  const initialMbGrade = item.approvedMb || initialParsed.mbGrade || (isAtomberg ? 'Black MB' : 'White MB');

  const [selectedRmGrade, setSelectedRmGrade] = useState(initialBaseRm);
  const [selectedMbGrade, setSelectedMbGrade] = useState(initialMbGrade);

  // Live lookup from RM Matrix: Returns both Approved Contract & Active Alternate WA
  const rmInfo = getActiveRmMapping(selectedRmGrade, item.vendor, '2026-08-01');
  const mbInfo = getActiveMbMapping(selectedMbGrade, item.vendor, '2026-08-01');

  const params = item.parameters || {};

  // Part Weights
  const [netWt, setNetWt] = useState(params.runningNetWeight ?? item.netWeight ?? (isAtomberg ? 37 : 197));
  const [runnerWt, setRunnerWt] = useState(params.runningRunnerWeight ?? item.runnerWeight ?? (isAtomberg ? 1 : 40));

  // Dual MB %
  const parsedBaseMb = Number(item.masterbatchPct !== undefined && item.masterbatchPct !== null ? item.masterbatchPct : 4.0);
  const cleanBaseMb = parsedBaseMb > 0 && parsedBaseMb < 1 ? parsedBaseMb * 100 : parsedBaseMb;
  const [baseMbPctVal, setBaseMbPctVal] = useState(cleanBaseMb);
  
  const parsedActMb = Number(params.runningMbPct !== undefined && params.runningMbPct !== null ? params.runningMbPct : cleanBaseMb);
  const cleanActMb = parsedActMb > 0 && parsedActMb < 1 ? parsedActMb * 100 : parsedActMb;
  const [actMbPctVal, setActMbPctVal] = useState(cleanActMb);

  // Dual BOP Cost
  const initialBaseBop = Number(item.bopCost ?? 0.00);
  const [baseBopCost, setBaseBopCost] = useState(initialBaseBop);
  const [actBopCost, setActBopCost] = useState(Number(params.runningBopCost ?? initialBaseBop));

  // Dual Packing Cost
  const initialBasePacking = Number(item.packingCost ?? (isAtomberg ? 0.86 : 0.00));
  const [basePackingCost, setBasePackingCost] = useState(initialBasePacking);
  const [actPackingCost, setActPackingCost] = useState(Number(params.runningPackingCost ?? initialBasePacking));

  // Dual Transport Cost
  const initialBaseTransport = Number(item.transportCost ?? (isAtomberg ? 0.62 : 0.00));
  const [baseTransportCost, setBaseTransportCost] = useState(initialBaseTransport);
  const [actTransportCost, setActTransportCost] = useState(Number(params.runningTransportCost ?? initialBaseTransport));

  // Cycle time, Cavity, Tonnage
  const [cycleTime, setCycleTime] = useState(params.runningCycleTime ?? item.cycleTimeApproved ?? item.cycleTime ?? (isAtomberg ? 47 : 56));
  const [cavity, setCavity] = useState(params.runningCavity ?? item.cavity ?? 2);
  const [tonnage, setTonnage] = useState(params.runningTonnage ?? item.machineTonnage ?? (isAtomberg ? 200 : 450));
  
  // Dual Shift Tariff
  const initialCostingTariff = Number(item.shiftTariff ?? item.shiftRate ?? (isAtomberg ? 2000 : 4600));
  const [costingTariff, setCostingTariff] = useState(initialCostingTariff);
  const [actualTariff, setActualTariff] = useState(Number(params.runningShiftTariff ?? initialCostingTariff));

  const [reason, setReason] = useState("Shopfloor parameters & alternate rate verification");

  const handleDelete = () => {
    deleteProductFromBaseline(item.itemCode, item.vendor);
    setShowDeleteConfirm(false);
    onClose();
  };

  if (isAtomberg) {
    // ========================================================================
    // ATOMBERG 38-LINE EXACT DUAL-COLUMN CALCULATIONS
    // ========================================================================
    // Approved Contract Baseline Rates
    const appRmBase = Number(rmInfo.approvedPrice || 0.00);
    const appMbBase = Number(mbInfo.approvedMbPrice || 0.00);

    // Active Alternate Running Rates (from Purchase WA)
    const actRmBase = Number(rmInfo.activeWaPrice || appRmBase || 0.00);
    const actMbBase = Number(mbInfo.activeMbWaPrice || appMbBase || 0.00);

    // Baseline Costing Math
    const baseRmLanded = appRmBase > 0 ? (appRmBase + (appRmBase * 0.01) + 1.50) : 0;
    const baseMbLanded = appMbBase > 0 ? (appMbBase + (appMbBase * 0.01) + 2.00) : 0;
    const baseMbFraction = Number(baseMbPctVal || 0) / 100;
    const baseRmComb = (baseRmLanded * (1.0 - baseMbFraction)) + (baseMbLanded * baseMbFraction);
    const basePartWt = Number(item.netWeight || 37.0);
    const baseRunnerWt = Number(item.runnerWeight || 1.0);
    const baseGrossWt = basePartWt + baseRunnerWt;
    const baseRmCost = (baseGrossWt / 1000.0) * baseRmComb;
    const baseBop = Number(baseBopCost || 0.0);
    const baseRmBop = baseRmCost + baseBop;
    const baseCav = Number(item.cavity || 2);
    const baseCt = Number(item.cycleTimeApproved || item.cycleTime || 47);
    const basePartsShift = (28800.0 / (baseCt > 0 ? baseCt : 1)) * 0.90 * baseCav;
    const baseProcessCost = basePartsShift > 0 ? (Number(costingTariff) / basePartsShift) : 0;
    const baseTotalProcess = baseProcessCost + (0.03 * baseBop) + 1.73;
    const baseProfitOh = (baseRmCost + baseTotalProcess) * 0.12;
    const baseInprocRej = (baseRmBop + baseTotalProcess) * 0.04;
    const baseRunnerRec = -25.0 * (baseRunnerWt / 1000.0);
    const basePacking = Number(basePackingCost !== undefined ? basePackingCost : 0.86);
    const baseTransport = Number(baseTransportCost !== undefined ? baseTransportCost : 0.62);
    const baseMouldMaint = 0.02 * baseTotalProcess;
    const baseOther = 0.00;
    const baseFinalLanded = baseRmCost + baseBop + baseTotalProcess + baseProfitOh + baseInprocRej + baseRunnerRec + basePacking + baseTransport + baseMouldMaint + baseOther;

    // Actual Running Math (Using Active Alternate WA Rates)
    const actRmLanded = actRmBase > 0 ? (actRmBase + (actRmBase * 0.01) + 1.50) : 0;
    const actMbLanded = actMbBase > 0 ? (actMbBase + (actMbBase * 0.01) + 2.00) : 0;
    const actMbFraction = Number(actMbPctVal || 0) / 100;
    const actRmComb = (actRmLanded * (1.0 - actMbFraction)) + (actMbLanded * actMbFraction);
    const actPartWt = Number(netWt);
    const actRunnerWt = Number(runnerWt);
    const actGrossWt = actPartWt + actRunnerWt;
    const actRmCost = (actGrossWt / 1000.0) * actRmComb;
    const actBop = Number(actBopCost || 0.0);
    const actRmBop = actRmCost + actBop;
    const actCav = Number(cavity);
    const actCt = Number(cycleTime);
    const actPartsShift = (28800.0 / (actCt > 0 ? actCt : 1)) * 0.90 * actCav;
    const actProcessCost = actPartsShift > 0 ? (Number(actualTariff) / actPartsShift) : 0;
    const actTotalProcess = actProcessCost + (0.03 * actBop) + 1.73;
    const actProfitOh = (actRmCost + actTotalProcess) * 0.12;
    const actInprocRej = (actRmBop + actTotalProcess) * 0.04;
    const actRunnerRec = -25.0 * (actRunnerWt / 1000.0);
    const actPacking = Number(actPackingCost !== undefined ? actPackingCost : 0.86);
    const actTransport = Number(actTransportCost !== undefined ? actTransportCost : 0.62);
    const actMouldMaint = 0.02 * actTotalProcess;
    const actOther = 0.00;
    const actFinalLanded = actRmCost + actBop + actTotalProcess + actProfitOh + actInprocRej + actRunnerRec + actPacking + actTransport + actMouldMaint + actOther;

    const profitLossDelta = Number((baseFinalLanded - actFinalLanded).toFixed(2));

    const atomberg38Rows = [
      { sn: 1, desc: 'Vendor', uom: '-', costing: item.vendor || 'Atomberg Technologies', actual: item.vendor || 'Atomberg Technologies', delta: '-' },
      { sn: 2, desc: 'Part Code', uom: '-', costing: item.itemCode, actual: item.itemCode, delta: '-' },
      { sn: 3, desc: 'Part name', uom: '-', costing: item.componentName, actual: item.componentName, delta: '-' },
      { 
        sn: 4, 
        desc: 'RM Grade (Approved vs Active Alternate)', 
        uom: '-', 
        costing: selectedRmGrade,
        actual: rmInfo.activeGrade || selectedRmGrade,
        delta: (rmInfo.activeGrade && rmInfo.activeGrade !== selectedRmGrade) ? 'Alternate Active' : 'Matched',
        isMaterialHeader: true
      },
      { sn: 5, desc: 'RM Base Rate (From RM Matrix)', uom: '₹/kg', costing: `₹${appRmBase.toFixed(2)}`, actual: `₹${actRmBase.toFixed(2)}`, delta: `₹${(appRmBase - actRmBase).toFixed(2)}` },
      { sn: 6, desc: 'ICC Cost @ 1% of RM', uom: '1%', costing: `₹${(appRmBase * 0.01).toFixed(2)}`, actual: `₹${(actRmBase * 0.01).toFixed(2)}`, delta: `₹${((appRmBase - actRmBase) * 0.01).toFixed(2)}` },
      { sn: 7, desc: 'Freight Cost', uom: '₹/kg', costing: appRmBase > 0 ? '₹1.50' : '₹0.00', actual: actRmBase > 0 ? '₹1.50' : '₹0.00', delta: '₹0.00' },
      { sn: 8, desc: 'RM Landed Cost', uom: '₹/kg', costing: `₹${baseRmLanded.toFixed(2)}`, actual: `₹${actRmLanded.toFixed(2)}`, delta: `₹${(baseRmLanded - actRmLanded).toFixed(2)}`, isHighlight: true },
      { 
        sn: 9, 
        desc: 'MB Grade (Approved vs Active Alternate)', 
        uom: '-', 
        costing: selectedMbGrade,
        actual: mbInfo.activeMbGrade || selectedMbGrade,
        delta: (mbInfo.activeMbGrade && mbInfo.activeMbGrade !== selectedMbGrade) ? 'Alternate Active' : 'Matched',
        isMaterialHeader: true
      },
      { sn: 10, desc: 'MB Base Cost (From RM Matrix)', uom: '₹/kg', costing: `₹${appMbBase.toFixed(2)}`, actual: `₹${actMbBase.toFixed(2)}`, delta: `₹${(appMbBase - actMbBase).toFixed(2)}` },
      { sn: 11, desc: 'MB-ICC Cost @ 1% of MB', uom: '1%', costing: `₹${(appMbBase * 0.01).toFixed(2)}`, actual: `₹${(actMbBase * 0.01).toFixed(2)}`, delta: `₹${((appMbBase - actMbBase) * 0.01).toFixed(2)}` },
      { sn: 12, desc: 'MB Freight Cost', uom: '₹/kg', costing: appMbBase > 0 ? '₹2.00' : '₹0.00', actual: actMbBase > 0 ? '₹2.00' : '₹0.00', delta: '₹0.00' },
      { sn: 13, desc: 'MB Landed Cost', uom: '₹/kg', costing: `₹${baseMbLanded.toFixed(2)}`, actual: `₹${actMbLanded.toFixed(2)}`, delta: `₹${(baseMbLanded - actMbLanded).toFixed(2)}`, isHighlight: true },
      { 
        sn: 14, 
        desc: 'MB %', 
        uom: '%', 
        isSpecialEdit: true,
        costingVal: baseMbPctVal,
        setCostingVal: setBaseMbPctVal,
        actualVal: actMbPctVal,
        setActualVal: setActMbPctVal,
        delta: `${(Number(baseMbPctVal || 0) - Number(actMbPctVal || 0)).toFixed(2)}%`
      },
      { sn: 15, desc: 'RM cost (PP + MB) /KG', uom: '₹/kg', costing: `₹${baseRmComb.toFixed(2)}`, actual: `₹${actRmComb.toFixed(2)}`, delta: `₹${(baseRmComb - actRmComb).toFixed(2)}` },
      { sn: 16, desc: 'Part weight grams', uom: 'Gms', costing: `${basePartWt.toFixed(2)}g`, isInput: true, inputType: 'netWt', actual: netWt, delta: `${(basePartWt - Number(netWt)).toFixed(2)}g` },
      { sn: 17, desc: 'Runner weight grams', uom: 'Gms', costing: `${baseRunnerWt.toFixed(2)}g`, isInput: true, inputType: 'runnerWt', actual: runnerWt, delta: `${(baseRunnerWt - Number(runnerWt)).toFixed(2)}g` },
      { sn: 18, desc: 'Gross weight', uom: 'Gms', costing: `${baseGrossWt.toFixed(2)}g`, actual: `${actGrossWt.toFixed(2)}g`, delta: `${(baseGrossWt - actGrossWt).toFixed(2)}g` },
      { sn: 19, desc: 'RM cost', uom: '₹/pc', costing: `₹${baseRmCost.toFixed(2)}`, actual: `₹${actRmCost.toFixed(2)}`, delta: `₹${(baseRmCost - actRmCost).toFixed(2)}`, isSubtotal: true },
      { 
        sn: 20, 
        desc: 'Inserts / BOP cost', 
        uom: '₹/pc', 
        isSpecialEdit: true,
        costingVal: baseBopCost,
        setCostingVal: setBaseBopCost,
        actualVal: actBopCost,
        setActualVal: setActBopCost,
        delta: `₹${(Number(baseBopCost || 0) - Number(actBopCost || 0)).toFixed(2)}`
      },
      { sn: 21, desc: 'RM + BOP Cost', uom: '₹/pc', costing: `₹${baseRmBop.toFixed(2)}`, actual: `₹${actRmBop.toFixed(2)}`, delta: `₹${(baseRmBop - actRmBop).toFixed(2)}`, isSubtotal: true },
      { sn: 22, desc: 'M/c tonnage', uom: 'T', costing: `${item.machineTonnage || 200}T`, isInput: true, inputType: 'tonnage', actual: tonnage, delta: (Number(item.machineTonnage || 200) - Number(tonnage)) },
      { sn: 23, desc: 'Shift rate (Manual Entry)', uom: '₹/shift', isTariffRow: true, costing: costingTariff, actual: actualTariff, delta: `₹${(Number(costingTariff) - Number(actualTariff)).toFixed(2)}` },
      { sn: 24, desc: 'Cycle time', uom: 'Sec', costing: `${baseCt}s`, isInput: true, inputType: 'cycleTime', actual: cycleTime, delta: `${(baseCt - Number(cycleTime)).toFixed(1)}s` },
      { sn: 25, desc: 'Efficiency', uom: '-', costing: '0.90', actual: '0.90', delta: '-' },
      { sn: 26, desc: 'No of cavity', uom: 'Nos', costing: baseCav, isInput: true, inputType: 'cavity', actual: cavity, delta: (baseCav - Number(cavity)) },
      { sn: 27, desc: 'Parts/shift', uom: 'Nos', costing: Math.round(basePartsShift), actual: Math.round(actPartsShift), delta: Math.round(basePartsShift - actPartsShift) },
      { sn: 28, desc: 'Process cost', uom: '₹/pc', costing: `₹${baseProcessCost.toFixed(2)}`, actual: `₹${actProcessCost.toFixed(2)}`, delta: `₹${(baseProcessCost - actProcessCost).toFixed(2)}` },
      { sn: 29, desc: 'Handling cost for BOP', uom: '3%', costing: `₹${(0.03 * baseBop).toFixed(2)}`, actual: `₹${(0.03 * actBop).toFixed(2)}`, delta: `₹${(0.03 * (baseBop - actBop)).toFixed(2)}` },
      { sn: 30, desc: 'Post operation cost', uom: '₹/pc', costing: '₹1.73', actual: '₹1.73', delta: '₹0.00' },
      { sn: 31, desc: 'Total Process Cost', uom: '₹/pc', costing: `₹${baseTotalProcess.toFixed(2)}`, actual: `₹${actTotalProcess.toFixed(2)}`, delta: `₹${(baseTotalProcess - actTotalProcess).toFixed(2)}`, isSubtotal: true },
      { sn: 32, desc: 'Profit & OH', uom: '12%', costing: `₹${baseProfitOh.toFixed(2)}`, actual: `₹${actProfitOh.toFixed(2)}`, delta: `₹${(baseProfitOh - actProfitOh).toFixed(2)}` },
      { sn: 33, desc: 'Inprocess Rejection', uom: '4%', costing: `₹${baseInprocRej.toFixed(2)}`, actual: `₹${actInprocRej.toFixed(2)}`, delta: `₹${(baseInprocRej - actInprocRej).toFixed(2)}` },
      { sn: 34, desc: 'Runner recovery cost', uom: '₹25/kg', costing: `- ₹${Math.abs(baseRunnerRec).toFixed(2)}`, actual: `- ₹${Math.abs(actRunnerRec).toFixed(2)}`, delta: `₹${(baseRunnerRec - actRunnerRec).toFixed(2)}`, isHighlight: true },
      { 
        sn: 35, 
        desc: 'Packing cost', 
        uom: '₹/pc', 
        isSpecialEdit: true,
        costingVal: basePackingCost,
        setCostingVal: setBasePackingCost,
        actualVal: actPackingCost,
        setActualVal: setActPackingCost,
        delta: `₹${(Number(basePackingCost || 0) - Number(actPackingCost || 0)).toFixed(2)}`
      },
      { 
        sn: 36, 
        desc: 'Transport cost', 
        uom: '₹/pc', 
        isSpecialEdit: true,
        costingVal: baseTransportCost,
        setCostingVal: setBaseTransportCost,
        actualVal: actTransportCost,
        setActualVal: setActTransportCost,
        delta: `₹${(Number(baseTransportCost || 0) - Number(actTransportCost || 0)).toFixed(2)}`
      },
      { sn: 37, desc: 'Mould maintenance cost', uom: '2%', costing: `₹${baseMouldMaint.toFixed(2)}`, actual: `₹${actMouldMaint.toFixed(2)}`, delta: `₹${(baseMouldMaint - actMouldMaint).toFixed(2)}` },
      { sn: 38, desc: 'FINAL LANDED COST', uom: '₹/pc', costing: `₹${baseFinalLanded.toFixed(2)}`, actual: `₹${actFinalLanded.toFixed(2)}`, delta: `₹${profitLossDelta >= 0 ? '+' : ''}${profitLossDelta.toFixed(2)}`, isTotal: true }
    ];

    const handleSaveAtomberg = () => {
      const compositeMatName = selectedMbGrade ? `${selectedRmGrade} + ${selectedMbGrade}` : selectedRmGrade;

      onSave({
        updatedItem: {
          ...item,
          approvedRm: compositeMatName,
          baseRm: selectedRmGrade,
          approvedMb: selectedMbGrade,
          shiftTariff: Number(costingTariff),
          shiftRate: Number(costingTariff),
          masterbatchPct: Number(baseMbPctVal),
          bopCost: Number(baseBopCost),
          packingCost: Number(basePackingCost),
          transportCost: Number(baseTransportCost),
          approvedCost: Number(baseFinalLanded.toFixed(2)),
          parameters: {
            ...item.parameters,
            runningNetWeight: Number(netWt),
            runningRunnerWeight: Number(runnerWt),
            runningMbPct: Number(actMbPctVal),
            runningBopCost: Number(actBopCost),
            runningPackingCost: Number(actPackingCost),
            runningTransportCost: Number(actTransportCost),
            runningCycleTime: Number(cycleTime),
            runningCavity: Number(cavity),
            runningTonnage: Number(tonnage),
            runningShiftTariff: Number(actualTariff)
          }
        },
        changeType: "Atomberg Spec Update",
        reason
      });
    };

    return (
      <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
        <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] flex flex-col justify-between relative">
          
          {/* Header */}
          <div className="flex justify-between items-start border-b border-slate-200 pb-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="px-2.5 py-0.5 bg-blue-600 text-white rounded font-mono font-bold text-xs">{item.itemCode}</span>
                <h2 className="text-base font-bold text-slate-900">{item.componentName}</h2>
                <span className="text-[10px] px-2 py-0.5 bg-slate-100 text-slate-600 rounded font-semibold border">Atomberg Prescribed Format</span>
              </div>
              <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-4">
                <span>Vendor: <strong className="text-slate-700">{item.vendor}</strong></span>
                <span>
                  RM: Contract <strong className="text-slate-800 font-mono">₹{appRmBase.toFixed(2)}</strong> → Active Alt ({rmInfo.activeGrade || selectedRmGrade}) <strong className="text-blue-700 font-mono">₹{actRmBase.toFixed(2)}/kg</strong>
                </span>
                <span>
                  MB: Contract <strong className="text-slate-800 font-mono">₹{appMbBase.toFixed(2)}</strong> → Active Alt ({mbInfo.activeMbGrade || selectedMbGrade}) <strong className="text-purple-700 font-mono">₹{actMbBase.toFixed(2)}/kg</strong>
                </span>
              </div>
            </div>
            <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-700 cursor-pointer"><X className="w-5 h-5" /></button>
          </div>

          {/* Top 3 KPI Cards */}
          <div className="grid grid-cols-3 gap-3">
            <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl">
              <div className="text-[10px] font-bold text-slate-400 uppercase">APPROVED BASELINE CONTRACT</div>
              <div className="text-2xl font-black text-slate-900 font-mono mt-1">₹{baseFinalLanded.toFixed(2)}</div>
            </div>
            <div className="p-4 bg-blue-50/60 border border-blue-200 rounded-xl">
              <div className="text-[10px] font-bold text-blue-600 uppercase">ACTUAL RUNNING SHOPFLOOR (ACTIVE ALTERNATE)</div>
              <div className="text-2xl font-black text-blue-700 font-mono mt-1">₹{actFinalLanded.toFixed(2)}</div>
            </div>
            <div className={`p-4 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-rose-50 border-rose-200 text-rose-700'}`}>
              <div className="text-[10px] font-bold uppercase">PROFIT / LOSS (Δ)</div>
              <div className="text-2xl font-black font-mono mt-1 flex items-center gap-1">
                {profitLossDelta >= 0 ? `+ ₹${profitLossDelta.toFixed(2)}` : `- ₹${Math.abs(profitLossDelta).toFixed(2)}`}
              </div>
            </div>
          </div>

          {/* 38-Line Table */}
          <div className="border border-slate-200 rounded-xl overflow-hidden max-h-[48vh] overflow-y-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold sticky top-0 z-10">
                <tr>
                  <th className="py-2.5 px-3 w-12 text-center">#</th>
                  <th className="py-2.5 px-4">ATOMBERG COSTING LINE</th>
                  <th className="py-2.5 px-3 text-center w-20">UOM / RATE</th>
                  <th className="py-2.5 px-4 text-right w-44">APPROVED BASELINE</th>
                  <th className="py-2.5 px-4 text-right w-44">ACTUAL RUNNING</th>
                  <th className="py-2.5 px-4 text-right w-28">DELTA (Δ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {atomberg38Rows.map((r) => {
                  if (r.isTotal) {
                    return (
                      <tr key={r.sn} className="bg-slate-900 text-white font-black text-sm">
                        <td className="py-3 px-3 text-center text-amber-400 font-bold">{r.sn}</td>
                        <td className="py-3 px-4 text-amber-300 uppercase tracking-wider">{r.desc}</td>
                        <td className="py-3 px-3 text-center text-slate-300 font-mono">{r.uom}</td>
                        <td className="py-3 px-4 text-right font-mono text-amber-300">{r.costing}</td>
                        <td className="py-3 px-4 text-right font-mono text-amber-300">{r.actual}</td>
                        <td className={`py-3 px-4 text-right font-mono ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>{r.delta}</td>
                      </tr>
                    );
                  }

                  if (r.isMaterialHeader) {
                    return (
                      <tr key={r.sn} className="bg-blue-50/50">
                        <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                        <td className="py-2 px-4 font-bold text-slate-900">{r.desc}</td>
                        <td className="py-2 px-3 text-center font-mono text-slate-500">{r.uom}</td>
                        <td className="py-2 px-4 text-right font-mono font-bold text-slate-900">{r.costing}</td>
                        <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{r.actual}</td>
                        <td className="py-2 px-4 text-right font-mono text-xs font-bold text-emerald-700">{r.delta}</td>
                      </tr>
                    );
                  }

                  if (r.isSpecialEdit) {
                    return (
                      <tr key={r.sn} className="bg-amber-50/40">
                        <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                        <td className="py-2 px-4 font-bold text-slate-900">{r.desc}</td>
                        <td className="py-2 px-3 text-center font-mono font-semibold text-slate-600">{r.uom}</td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            step="any"
                            value={r.costingVal} 
                            onChange={e => r.setCostingVal(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            step="any"
                            value={r.actualVal} 
                            onChange={e => r.setActualVal(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-blue-500 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 focus:ring-2 focus:ring-blue-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">{r.delta}</td>
                      </tr>
                    );
                  }

                  if (r.isTariffRow) {
                    return (
                      <tr key={r.sn} className="bg-emerald-50/40">
                        <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                        <td className="py-2 px-4 font-bold text-slate-900">{r.desc}</td>
                        <td className="py-2 px-3 text-center font-mono font-semibold text-slate-600">{r.uom}</td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            step="any"
                            value={costingTariff} 
                            onChange={e => setCostingTariff(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            step="any"
                            value={actualTariff} 
                            onChange={e => setActualTariff(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-blue-500 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 focus:ring-2 focus:ring-blue-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">{r.delta}</td>
                      </tr>
                    );
                  }

                  return (
                    <tr key={r.sn} className={`${r.isSubtotal ? 'bg-amber-50/50 font-bold' : 'hover:bg-slate-50'}`}>
                      <td className="py-2 px-3 text-center font-mono text-slate-400">{r.sn}</td>
                      <td className={`py-2 px-4 ${r.isSubtotal ? 'text-slate-900' : 'text-slate-800 font-medium'}`}>{r.desc}</td>
                      <td className="py-2 px-3 text-center font-mono text-slate-500">{r.uom}</td>
                      <td className="py-2 px-4 text-right font-mono">{r.costing}</td>
                      <td className="py-2 px-4 text-right">
                        {r.isInput ? (
                          <input 
                            type="number" 
                            step="any"
                            value={r.actual} 
                            onChange={e => {
                              const val = e.target.value;
                              if (r.inputType === 'netWt') setNetWt(val);
                              else if (r.inputType === 'runnerWt') setRunnerWt(val);
                              else if (r.inputType === 'tonnage') setTonnage(val);
                              else if (r.inputType === 'cycleTime') setCycleTime(val);
                              else if (r.inputType === 'cavity') setCavity(val);
                            }} 
                            className="w-20 px-1 py-0.5 border border-blue-400 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 outline-none focus:ring-2 focus:ring-blue-500" 
                          />
                        ) : (
                          <span className={`font-mono ${r.isSubtotal ? 'text-blue-700 font-bold' : r.isHighlight ? 'text-emerald-700 font-bold' : 'text-slate-700'}`}>
                            {r.actual}
                          </span>
                        )}
                      </td>
                      <td className={`py-2 px-4 text-right font-mono ${r.isSubtotal ? 'text-rose-600 font-bold' : 'text-slate-500'}`}>{r.delta}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* Footer */}
          <div className="flex justify-between items-center pt-2 border-t border-slate-200">
            <button
              onClick={() => setShowDeleteConfirm(true)}
              className="flex items-center gap-1.5 px-4 py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-300 rounded-xl text-xs font-bold transition-all cursor-pointer shadow-xs"
            >
              <Trash2 className="w-4 h-4 text-rose-600" /> Delete Product
            </button>

            <div className="flex items-center gap-2">
              <button onClick={onClose} className="px-4 py-2 border rounded-xl font-bold cursor-pointer hover:bg-slate-50 text-slate-700">Cancel</button>
              <button onClick={handleSaveAtomberg} className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer flex items-center gap-1.5"><Save className="w-4 h-4" /> Save & Log Parameters</button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Haier / Atharva Polymer Format
  const appRmBase = Number(rmInfo.approvedPrice || 0.00);
  const actRmBase = Number(rmInfo.activeWaPrice || appRmBase || 0.00);
  const appMbBase = Number(mbInfo.approvedMbPrice || 0.00);
  const actMbBase = Number(mbInfo.activeMbWaPrice || appMbBase || 0.00);

  const baseCalc = calculateHaierCost({
    cavity: Number(item.cavity || 2),
    netWeight: Number(item.netWeight || 197),
    runnerWeight: Number(item.runnerWeight || 40),
    rmRate: appRmBase,
    masterbatchPct: Number(baseMbPctVal || 0.0),
    masterbatchRate: appMbBase,
    machineTonnage: Number(item.machineTonnage || 450),
    shiftTariff: Number(costingTariff),
    cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 56),
    bopCost: Number(baseBopCost || 0.14)
  });

  const runCalc = calculateHaierCost({
    cavity: Number(cavity),
    netWeight: Number(netWt),
    runnerWeight: Number(runnerWt),
    rmRate: actRmBase,
    masterbatchPct: Number(actMbPctVal || 0.0),
    masterbatchRate: actMbBase,
    machineTonnage: Number(tonnage),
    shiftTariff: Number(actualTariff),
    cycleTime: Number(cycleTime),
    bopCost: Number(actBopCost || 0.14)
  });

  const profitLossDelta = Number((baseCalc.totalCost - runCalc.totalCost).toFixed(2));

  return (
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] flex flex-col justify-between relative">
        <div className="flex justify-between items-start border-b pb-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 bg-blue-600 text-white rounded font-mono font-bold text-xs">{item.itemCode}</span>
              <h2 className="text-base font-bold text-slate-900">{item.componentName}</h2>
              <span className="text-[10px] px-2 py-0.5 bg-blue-50 text-blue-700 rounded font-semibold border border-blue-200">Haier 38-Line Format</span>
            </div>
            <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-4">
              <span>Vendor: <strong className="text-slate-700">{item.vendor}</strong></span>
              <span>RM: Approved <strong className="text-slate-800 font-mono">₹{appRmBase.toFixed(2)}</strong> → Active Alt ({rmInfo.activeGrade || selectedRmGrade}) <strong className="text-blue-700 font-mono">₹{actRmBase.toFixed(2)}/kg</strong></span>
              <span>MB: Approved <strong className="text-slate-800 font-mono">₹{appMbBase.toFixed(2)}</strong> → Active Alt ({mbInfo.activeMbGrade || selectedMbGrade}) <strong className="text-purple-700 font-mono">₹{actMbBase.toFixed(2)}/kg</strong></span>
            </div>
          </div>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-700 cursor-pointer"><X className="w-5 h-5" /></button>
        </div>

        <div className="grid grid-cols-3 gap-3">
          <div className="p-4 bg-slate-50 border rounded-xl">
            <div className="text-[10px] font-bold text-slate-400 uppercase">COSTING (BASELINE)</div>
            <div className="text-2xl font-black text-slate-900 font-mono mt-1">₹{baseCalc.totalCost?.toFixed(2)}</div>
          </div>
          <div className="p-4 bg-blue-50/60 border border-blue-200 rounded-xl">
            <div className="text-[10px] font-bold text-blue-600 uppercase">ACTUAL RUNNING (ACTIVE ALTERNATE)</div>
            <div className="text-2xl font-black text-blue-700 font-mono mt-1">₹{runCalc.totalCost?.toFixed(2)}</div>
          </div>
          <div className={`p-4 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-rose-50 border-rose-200 text-rose-700'}`}>
            <div className="text-[10px] font-bold uppercase">PROFIT / LOSS (Δ)</div>
            <div className="text-2xl font-black font-mono mt-1 flex items-center gap-1">
              {profitLossDelta >= 0 ? `+ ₹${profitLossDelta.toFixed(2)}` : `- ₹${Math.abs(profitLossDelta).toFixed(2)}`}
            </div>
          </div>
        </div>

        <div className="flex justify-between items-center pt-2 border-t">
          <button onClick={onClose} className="px-4 py-2 border rounded-xl font-bold cursor-pointer hover:bg-slate-50 text-slate-700">Cancel</button>
          <button 
            onClick={() => onSave({
              updatedItem: {
                ...item,
                approvedRm: selectedMbGrade ? `${selectedRmGrade} + ${selectedMbGrade}` : selectedRmGrade,
                baseRm: selectedRmGrade,
                approvedMb: selectedMbGrade,
                parameters: { ...item.parameters, runningNetWeight: Number(netWt), runningMbPct: Number(actMbPctVal) }
              },
              changeType: "Haier Spec Update",
              reason
            })}
            className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer flex items-center gap-1.5"
          >
            <Save className="w-4 h-4" /> Save & Log Parameters
          </button>
        </div>
      </div>
    </div>
  );
}
MODAL_EOF

echo "==> 4. Verifying entire build with npm run build..."
npm run build

echo "==> 5. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Dynamic Alternate WA Calculator & Dual Columns live!"
echo "-------------------------------------------------------------------"
