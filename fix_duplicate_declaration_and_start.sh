#!/usr/bin/env bash
set -e

echo "==> 1. Writing clean, deduplicated src/shared/masterStore.js..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// ============================================================================
// GLOBAL MASTER DATA STORE (Strict RM/MB Dynamic Resolution & 0-Fallback)
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
    { id: 'rm-at-1', vendor: 'Atomberg Technologies', type: 'RM', approvedCode: 'PP H110MA', approvedPrice: 131.00, activeAlt: 'alt1', alt1Code: 'PP H110MA Prime Inward', alt1Price: 135.83, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'rm-at-2', vendor: 'Atomberg Technologies', type: 'RM', approvedCode: 'PP Mi3530', approvedPrice: 180.00, activeAlt: 'alt1', alt1Code: 'PP Mi3530 Prime Inward', alt1Price: 180.00, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'mb-at-1', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'Black MB', approvedPrice: 254.00, activeAlt: 'alt1', alt1Code: 'Black MB (Standard)', alt1Price: 258.54, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'mb-at-2', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'White MB', approvedPrice: 260.00, activeAlt: 'alt1', alt1Code: 'White MB (Standard)', alt1Price: 265.00, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'mb-at-3', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'Gray MB', approvedPrice: 150.00, activeAlt: 'alt1', alt1Code: 'Gray MB Prime Inward', alt1Price: 150.00, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'mb-at-4', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'GOLDEN MB', approvedPrice: 450.00, activeAlt: 'alt1', alt1Code: 'GOLDEN MB Prime Inward', alt1Price: 450.00, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },

    // Haier RMs & MBs
    { id: 'rm-ha-1', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'ABS 300 Pre Colour', approvedPrice: 136.20, activeAlt: 'alt1', alt1Code: 'ABS 300-B Red (Prime Inward)', alt1Price: 134.80, alt2Code: 'ABS 300-B Alt Pre-mix (Supreme)', alt2Price: 135.20, alt3Code: 'ABS 300-B Spot Lot C', alt3Price: 136.00 },
    { id: 'rm-ha-2', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'GPPS SC201LV', approvedPrice: 100.00, activeAlt: 'alt1', alt1Code: 'GPPS SC201LV + 3.5% Smoke Grey Blend', alt1Price: 98.40, alt2Code: 'GPPS SC206 Virgin Lot', alt2Price: 99.10, alt3Code: 'GPPS SC200 Inward Lot 3', alt3Price: 98.90 },
    { id: 'mb-ha-1', vendor: 'Haier Appliances', type: 'MB', approvedCode: 'Smoke Grey MB (3.5%)', approvedPrice: 150.00, activeAlt: 'alt1', alt1Code: 'Smoke Grey Masterbatch Grade A', alt1Price: 148.00, alt2Code: 'Smoke Grey Masterbatch Lot B', alt2Price: 149.50, alt3Code: 'Smoke Grey Masterbatch Spot', alt3Price: 150.00 },
    { id: 'rm-ha-3', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'HIPS-SH03', approvedPrice: 147.87, activeAlt: 'alt1', alt1Code: 'HIPS-SH03 Prime Lot', alt1Price: 157.46, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'rm-ha-4', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'PP B-400MN', approvedPrice: 132.76, activeAlt: 'alt1', alt1Code: 'PP B-400MN (IOCL)', alt1Price: 135.00, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'mb-ha-2', vendor: 'Haier Appliances', type: 'MB', approvedCode: 'White MB', approvedPrice: 250.00, activeAlt: 'alt1', alt1Code: 'White MB Grade A', alt1Price: 250.00, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },

    // Atharva Polymer
    { id: 'rm-ath-1', vendor: 'Atharva Polymer', type: 'RM', approvedCode: 'HIPS-SH03', approvedPrice: 147.87, activeAlt: 'alt1', alt1Code: 'HIPS-SH03 Prime Lot', alt1Price: 157.46, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'rm-ath-2', vendor: 'Atharva Polymer', type: 'RM', approvedCode: 'PP B-400MN', approvedPrice: 132.76, activeAlt: 'alt1', alt1Code: 'PP B-400MN (IOCL)', alt1Price: 135.00, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 },
    { id: 'mb-ath-1', vendor: 'Atharva Polymer', type: 'MB', approvedCode: 'White MB', approvedPrice: 250.00, activeAlt: 'alt1', alt1Code: 'White MB Grade A', alt1Price: 250.00, alt2Code: '', alt2Price: 0, alt3Code: '', alt3Price: 0 }
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

  purchases: [
    { date: '2026-05-04', supplier: 'Supreme Petrochem Ltd', invoiceNo: 'INV-HR-MAY01', itemCode: 'RM-ABS-01', grade: 'ABS 300-B Red (Prime Inward)', qty: 4500, rate: 135.50 },
    { date: '2026-05-12', supplier: 'LG Polymers India', invoiceNo: 'INV-HR-MAY02', itemCode: 'RM-GPPS-01', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 3000, rate: 99.20 },
    { date: '2026-05-18', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-MAY01', itemCode: 'RM-PP-01', grade: 'PP H110MA Prime Inward', qty: 4000, rate: 132.50 },
    { date: '2026-06-03', supplier: 'Supreme Petrochem Ltd', invoiceNo: 'INV-HR-JUN01', itemCode: 'RM-ABS-01', grade: 'ABS 300-B Red (Prime Inward)', qty: 5000, rate: 135.00 },
    { date: '2026-06-15', supplier: 'LG Polymers India', invoiceNo: 'INV-HR-JUN02', itemCode: 'RM-GPPS-01', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 2800, rate: 98.90 },
    { date: '2026-06-20', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-JUN01', itemCode: 'RM-PP-01', grade: 'PP H110MA Prime Inward', qty: 4500, rate: 133.80 },
    { date: '2026-07-05', supplier: 'Supreme Petrochem Ltd', invoiceNo: 'INV-HR-JUL01', itemCode: 'RM-ABS-01', grade: 'ABS 300-B Red (Prime Inward)', qty: 5200, rate: 134.90 },
    { date: '2026-07-16', supplier: 'LG Polymers India', invoiceNo: 'INV-HR-JUL02', itemCode: 'RM-GPPS-01', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 3200, rate: 98.60 },
    { date: '2026-07-22', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-JUL01', itemCode: 'RM-PP-01', grade: 'PP H110MA Prime Inward', qty: 5000, rate: 134.50 },
    { date: '2026-08-01', supplier: 'Supreme Petrochem Ltd', invoiceNo: 'INV-HR-AUG01', itemCode: 'RM-ABS-01', grade: 'ABS 300-B Red (Prime Inward)', qty: 6000, rate: 134.80 }
  ],

  sales: [
    { date: '2026-05-10', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-001', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 3800, sellingPrice: 42.00 },
    { date: '2026-05-15', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-002', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1500, sellingPrice: 85.00 },
    { date: '2026-05-20', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-001', itemCode: 'A1017011_tt2', componentName: 'Aris Top Canopy- Gloss White', qty: 3000, sellingPrice: 14.50 },
    { date: '2026-05-25', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-002', itemCode: 'A1017031_tt2', componentName: 'Aris Top Canopy- Gloss Black', qty: 900, sellingPrice: 15.96 },
    { date: '2026-06-11', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-003', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4000, sellingPrice: 42.00 },
    { date: '2026-06-18', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-004', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1600, sellingPrice: 85.00 },
    { date: '2026-06-22', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-003', itemCode: 'A1017011_tt2', componentName: 'Aris Top Canopy- Gloss White', qty: 3200, sellingPrice: 14.50 },
    { date: '2026-06-28', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-004', itemCode: 'A1017031_tt2', componentName: 'Aris Top Canopy- Gloss Black', qty: 950, sellingPrice: 15.96 },
    { date: '2026-07-10', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-005', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4100, sellingPrice: 42.00 },
    { date: '2026-07-15', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-006', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1700, sellingPrice: 85.00 },
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
// SINGLE SOURCE OF TRUTH: Material String Parser & Price Resolution
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

export function getActiveRmMapping(gradeName, vendor, targetDate) {
  if (!gradeName) return { approvedPrice: 0.0, activeWaPrice: 0.0, activeGrade: 'Unspecified', isFound: false };
  
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
    const waPrice = Number(found[`${activeKey}Price`] || found.alt1Price || found.approvedPrice || 0);
    return {
      approvedPrice: Number(found.approvedPrice || 0),
      activeWaPrice: waPrice,
      activeGrade: found[`${activeKey}Code`] || found.alt1Code || found.approvedCode,
      isFound: true
    };
  }

  return { approvedPrice: 0.00, activeWaPrice: 0.00, activeGrade: baseRm || gradeName, isFound: false };
}

export function getActiveMbMapping(mbGradeName, vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase().trim();
  let targetMb = (mbGradeName || '').toLowerCase().trim();

  if (!targetMb) {
    return { approvedMbPrice: 0.00, activeMbWaPrice: 0.00, isFound: false };
  }

  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'MB' && 
    (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim()) || r.vendor.toLowerCase().includes(vClean)) && 
    r.approvedCode.toLowerCase().trim() === targetMb
  );

  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] || found.alt1Price || found.approvedPrice || 0);
    return {
      approvedMbPrice: Number(found.approvedPrice || 0),
      activeMbWaPrice: waPrice,
      isFound: true
    };
  }

  return { approvedMbPrice: 0.00, activeMbWaPrice: 0.00, isFound: false };
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
      alt1Price: alt1Price !== undefined ? Number(alt1Price) : Number(approvedPrice || 0),
      alt2Code: '',
      alt2Price: 0,
      alt3Code: '',
      alt3Price: 0
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

echo "==> 2. Verifying clean build with npm run build..."
npm run build

echo "==> 3. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Build passed cleanly and Vite server running on port 5173."
echo "-------------------------------------------------------------------"
