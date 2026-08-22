#!/usr/bin/env bash
set -e

echo "==> 1. Writing rich multi-scenario demo dataset into masterStore.js..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// ============================================================================
// GLOBAL MASTER DATA STORE (Multi-Scenario Test Dataset & Dynamic Linking)
// ============================================================================

export let globalStore = {
  isLocked: false,       // Default Unlocked for immediate testing
  isMatrixLocked: false, // Default Unlocked for immediate testing

  vendors: [
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ],

  // RM & MB Master Matrix with Alternates 1, 2, 3
  rmMappingsData: [
    // Atomberg Technologies RMs & MBs
    { id: 'rm-at-1', vendor: 'Atomberg Technologies', type: 'RM', approvedCode: 'PP H110MA', approvedPrice: 131.00, activeAlt: 'alt1', alt1Code: 'PP H110MA Prime Inward', alt1Price: 133.80, alt2Code: 'PP H240mn', alt2Price: 135.00, alt3Code: 'PP H220mn', alt3Price: 130.00 },
    { id: 'rm-at-2', vendor: 'Atomberg Technologies', type: 'RM', approvedCode: 'PP Mi3530', approvedPrice: 180.00, activeAlt: 'alt2', alt1Code: 'PP Mi3530 Prime Inward', alt1Price: 180.00, alt2Code: 'PP H240mn (Supreme Lot)', alt2Price: 176.00, alt3Code: 'PP H220mn', alt3Price: 130.00 },
    { id: 'mb-at-1', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'Black MB', approvedPrice: 254.00, activeAlt: 'alt1', alt1Code: 'Black MB (Standard)', alt1Price: 258.54, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-2', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'White MB', approvedPrice: 260.00, activeAlt: 'alt1', alt1Code: 'White MB Grade A', alt1Price: 265.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-3', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'Gray MB', approvedPrice: 150.00, activeAlt: 'alt1', alt1Code: 'Gray MB Prime Inward', alt1Price: 150.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-at-4', vendor: 'Atomberg Technologies', type: 'MB', approvedCode: 'GOLDEN MB', approvedPrice: 450.00, activeAlt: 'alt2', alt1Code: 'GOLDEN MB (Contract Base)', alt1Price: 450.00, alt2Code: 'GOLDEN MB Inward Lot 1', alt2Price: 190.00, alt3Code: '', alt3Price: 0.00 },

    // Haier Appliances RMs & MBs
    { id: 'rm-ha-1', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'ABS 300 Pre Colour', approvedPrice: 136.20, activeAlt: 'alt1', alt1Code: 'ABS 300-B Red (Prime Inward)', alt1Price: 134.80, alt2Code: 'ABS 300-B Alt Pre-mix (Supreme)', alt2Price: 135.20, alt3Code: 'ABS 300-B Spot Lot C', alt3Price: 136.00 },
    { id: 'rm-ha-2', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'GPPS SC201LV', approvedPrice: 100.00, activeAlt: 'alt1', alt1Code: 'GPPS SC201LV + 3.5% Smoke Grey Blend', alt1Price: 98.40, alt2Code: 'GPPS SC206 Virgin Lot', alt2Price: 99.10, alt3Code: 'GPPS SC200 Inward Lot 3', alt3Price: 98.90 },
    { id: 'rm-ha-3', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'HIPS-SH03', approvedPrice: 147.87, activeAlt: 'alt1', alt1Code: 'HIPS-SH03 Prime Lot', alt1Price: 157.46, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'rm-ha-4', vendor: 'Haier Appliances', type: 'RM', approvedCode: 'PP B-400MN', approvedPrice: 132.76, activeAlt: 'alt1', alt1Code: 'PP B-400MN (IOCL)', alt1Price: 135.00, alt2Code: '', alt2Price: 0.00, alt3Code: '', alt3Price: 0.00 },
    { id: 'mb-ha-1', vendor: 'Haier Appliances', type: 'MB', approvedCode: 'Smoke Grey MB (3.5%)', approvedPrice: 150.00, activeAlt: 'alt1', alt1Code: 'Smoke Grey Masterbatch Grade A', alt1Price: 148.00, alt2Code: 'Smoke Grey Masterbatch Lot B', alt2Price: 149.50, alt3Code: 'Smoke Grey Masterbatch Spot', alt3Price: 150.00 },
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
      componentName: 'Aris Top Canopy- Gloss Black (Mi3530)',
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
      componentName: 'Aris Top Canopy- Gloss White (Golden MB)',
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
      haierOverheadPackage: 5.15,
      machineTonnage: 450,
      shiftTariff: 3600,
      cycleTimeApproved: 56,
      packingCost: 0.00,
      transportCost: 0.00,
      parameters: {
        runningNetWeight: 197.0,
        runningRunnerWeight: 40.0,
        runningMbPct: 0.0,
        runningBopCost: 0.14,
        runningHaierOverheadPackage: 5.15,
        runningCycleTime: 56,
        runningCavity: 2,
        runningTonnage: 450,
        runningShiftTariff: 3600
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
      haierOverheadPackage: 5.15,
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
        runningHaierOverheadPackage: 5.15,
        runningCycleTime: 62,
        runningCavity: 1,
        runningTonnage: 650,
        runningShiftTariff: 6200
      }
    },
    {
      id: 'prod-ha-3',
      vendor: 'Haier Appliances',
      itemCode: '0060226713D_t1',
      componentName: 'End Cap Top Ref (without Screen Painting)',
      approvedRm: 'ABS 300 Pre Colour',
      baseRm: 'ABS 300 Pre Colour',
      approvedMb: 'White MB',
      masterbatchPct: 0.0,
      cavity: 2,
      netWeight: 197.0,
      runnerWeight: 40.0,
      bopCost: 0.14,
      haierOverheadPackage: 5.15,
      machineTonnage: 450,
      shiftTariff: 3600,
      cycleTimeApproved: 56,
      packingCost: 0.00,
      transportCost: 0.00,
      parameters: {
        runningNetWeight: 197.0,
        runningRunnerWeight: 40.0,
        runningMbPct: 0.0,
        runningBopCost: 0.14,
        runningHaierOverheadPackage: 5.15,
        runningCycleTime: 56,
        runningCavity: 2,
        runningTonnage: 450,
        runningShiftTariff: 3600
      }
    }
  ],

  // Comprehensive Inward Purchases with Multi-Lot Weighted Averages
  purchases: [
    { date: '2026-08-12', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-0015', itemCode: 'MB-GOLDEN-01', grade: 'GOLDEN MB Inward Lot 1', qty: 200, rate: 190.00 },
    { date: '2026-08-10', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-0014', itemCode: 'RM-PP-MI3530', grade: 'PP H240mn (Supreme Lot)', qty: 1500, rate: 176.00 },
    { date: '2026-08-05', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-0013', itemCode: 'RM-PP-B240MN', grade: 'PP H240mn', qty: 2500, rate: 135.00 },
    { date: '2026-08-01', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-0012', itemCode: 'RM-PP-B220MN', grade: 'PP H220mn', qty: 3000, rate: 130.00 },
    { date: '2026-08-12', supplier: 'IOCL Petrochemicals', invoiceNo: 'INV-ATH-001', itemCode: 'RM-HIPS-01', grade: 'HIPS-SH03 Prime Lot', qty: 4000, rate: 157.46 },
    { date: '2026-08-10', supplier: 'Reliance Industries Ltd', invoiceNo: 'INV-AT-001', itemCode: 'RM-PP-01', grade: 'PP H110MA Prime Inward', qty: 4500, rate: 133.80 },
    { date: '2026-08-05', supplier: 'LG Polymers India', invoiceNo: 'INV-HR-002', itemCode: 'MB-WHT-01', grade: 'White MB Grade A', qty: 300, rate: 250.00 },
    { date: '2026-08-01', supplier: 'Supreme Petrochem Ltd', invoiceNo: 'INV-HR-001', itemCode: 'RM-ABS-01', grade: 'ABS 300-B Red (Prime Inward)', qty: 5000, rate: 134.80 },
    { date: '2026-07-16', supplier: 'LG Polymers India', invoiceNo: 'INV-HR-JUL02', itemCode: 'RM-GPPS-01', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 3200, rate: 98.40 }
  ],

  // Comprehensive Sales Dispatches
  sales: [
    { date: '2026-08-01', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-001', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4200, sellingPrice: 42.00 },
    { date: '2026-08-05', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-002', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1800, sellingPrice: 85.00 },
    { date: '2026-08-10', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-001', itemCode: 'A1017031_tt2', componentName: 'Aris Top Canopy- Gloss Black', qty: 3000, sellingPrice: 15.96 },
    { date: '2026-08-10', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-002', itemCode: 'A1017011_tt2', componentName: 'Aris Top Canopy- Gloss White', qty: 2500, sellingPrice: 18.00 },
    { date: '2026-08-11', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-0011', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4200, sellingPrice: 42.00 },
    { date: '2026-08-12', vendor: 'Atharva Polymer', invoiceNo: 'DISP-ATH-001', itemCode: '0060235291A', componentName: 'FRZ DUCT-FRONT COVER-HIPS-TM-258/278', qty: 2200, sellingPrice: 81.98 },
    { date: '2026-08-13', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-0022', itemCode: 'A1017011_tt2', componentName: 'Aris Top Canopy- Gloss White', qty: 3000, sellingPrice: 18.00 },
    { date: '2026-08-14', vendor: 'Atomberg Technologies', invoiceNo: 'DISP-AT-00112', itemCode: 'A1017031_tt2', componentName: 'Aris Top Canopy- Gloss Black', qty: 1500, sellingPrice: 15.96 },
    { date: '2026-08-15', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-0023', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1800, sellingPrice: 85.00 },
    { date: '2026-08-16', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-00112', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4200, sellingPrice: 42.00 },
    { date: '2026-08-16', vendor: 'Haier Appliances', invoiceNo: 'DISP-HR-00232', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1800, sellingPrice: 85.00 }
  ],

  auditLogs: [
    { timestamp: '10:15:20 AM', partCode: 'SYSTEM_LOCK', componentName: 'Global Baseline & RM Page Lock', vendor: 'ALL', modifications: 'Status: UNLOCKED', costImpact: 'Editable', reason: 'Administrator Init' },
    { timestamp: '10:18:45 AM', partCode: 'PP Mi3530', componentName: 'RM Material Entry (Atomberg Technologies)', vendor: 'Atomberg Technologies', modifications: 'Approved Price: ₹180.00/kg', costImpact: '₹180.00/kg', reason: 'Vendor RM/MB Master Updated' },
    { timestamp: '10:20:10 AM', partCode: 'GOLDEN MB', componentName: 'MB Material Entry (Atomberg Technologies)', vendor: 'Atomberg Technologies', modifications: 'Approved Price: ₹450.00/kg', costImpact: '₹450.00/kg', reason: 'Vendor RM/MB Master Updated' }
  ]
};

let listeners = [];
export function subscribeStore(fn) {
  listeners.push(fn);
  return () => { listeners = listeners.filter(cb => cb !== fn); };
}
export function notifyStore() {
  listeners.forEach(fn => { try { fn(globalStore); } catch (e) { console.error(e); } });
}

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
  if (updatedItem.haierOverheadPackage !== undefined) prod.haierOverheadPackage = Number(updatedItem.haierOverheadPackage);
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

echo "==> 2. Verifying complete production build with npm run build..."
npm run build

echo "==> 3. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Complete multi-scenario demo dataset loaded and verified."
echo "-------------------------------------------------------------------"
