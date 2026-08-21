export const globalStore = {
  isGlobalLocked: true, // Default locked for protection
  vendors: [
    { vendorId: 'Haier', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg', vendorName: 'Atomberg Technologies' }
  ],

  baselineProducts: [
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
      postOpCost: 0.0,
      parameters: {
        runningCavity: 2,
        runningNetWeight: 197.0,
        runningRunnerWeight: 40.0,
        runningCycleTime: 48.0,
        runningTonnage: 450,
        runningMbPct: 0.0,
        runningBopCost: 0.14
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
      postOpCost: 0.0,
      parameters: {
        runningCavity: 1,
        runningNetWeight: 485.0,
        runningRunnerWeight: 22.0,
        runningCycleTime: 58.0,
        runningTonnage: 650,
        runningMbPct: 3.5,
        runningBopCost: 0.14
      }
    },
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
    }
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
      approvedPrice: 150.00,
      alt1Code: 'Smoke Grey Masterbatch Lot A',
      alt1Price: 148.00,
      alt2Code: 'Smoke Grey Masterbatch Lot B',
      alt2Price: 149.50,
      alt3Code: 'Smoke Grey Masterbatch Lot C',
      alt3Price: 150.00,
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

  purchases: [
    { id: 'pur-101', date: '2026-05-04', vendor: 'Haier', grade: 'ABS 300-B Red (Prime Inward)', qty: 4500, rate: 135.50, invoiceNo: 'INV-HR-MAY01' },
    { id: 'pur-102', date: '2026-05-12', vendor: 'Haier', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 3000, rate: 99.20, invoiceNo: 'INV-HR-MAY02' },
    { id: 'pur-103', date: '2026-05-18', vendor: 'Atomberg', grade: 'PP H110MA Prime Inward', qty: 4000, rate: 132.50, invoiceNo: 'INV-AT-MAY01' },
    { id: 'pur-201', date: '2026-06-03', vendor: 'Haier', grade: 'ABS 300-B Red (Prime Inward)', qty: 5000, rate: 135.00, invoiceNo: 'INV-HR-JUN01' },
    { id: 'pur-202', date: '2026-06-15', vendor: 'Haier', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 2800, rate: 98.90, invoiceNo: 'INV-HR-JUN02' },
    { id: 'pur-203', date: '2026-06-20', vendor: 'Atomberg', grade: 'PP H110MA Prime Inward', qty: 4500, rate: 133.80, invoiceNo: 'INV-AT-JUN01' },
    { id: 'pur-301', date: '2026-07-05', vendor: 'Haier', grade: 'ABS 300-B Red (Prime Inward)', qty: 5200, rate: 134.90, invoiceNo: 'INV-HR-JUL01' },
    { id: 'pur-302', date: '2026-07-16', vendor: 'Haier', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 3200, rate: 98.60, invoiceNo: 'INV-HR-JUL02' },
    { id: 'pur-303', date: '2026-07-22', vendor: 'Atomberg', grade: 'PP H110MA Prime Inward', qty: 5000, rate: 134.50, invoiceNo: 'INV-AT-JUL01' },
    { id: 'pur-401', date: '2026-08-01', vendor: 'Haier', grade: 'ABS 300-B Red (Prime Inward)', qty: 6000, rate: 134.80, invoiceNo: 'INV-HR-AUG01' },
    { id: 'pur-402', date: '2026-08-08', vendor: 'Haier', grade: 'GPPS SC201LV + 3.5% Smoke Grey Blend', qty: 3500, rate: 98.40, invoiceNo: 'INV-HR-AUG02' },
    { id: 'pur-403', date: '2026-08-12', vendor: 'Atomberg', grade: 'PP H110MA Prime Inward', qty: 5500, rate: 135.83, invoiceNo: 'INV-AT-AUG01' },
    { id: 'pur-404', date: '2026-08-14', vendor: 'Atomberg', grade: 'Universal Inward MB Lot 1', qty: 800, rate: 258.54, invoiceNo: 'INV-AT-MB01' }
  ],

  sales: [
    { id: 'disp-101', date: '2026-05-10', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 3800, sellingPrice: 42.00, vendor: 'Haier' },
    { id: 'disp-102', date: '2026-05-15', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1500, sellingPrice: 85.00, vendor: 'Haier' },
    { id: 'disp-103', date: '2026-05-20', itemCode: 'A101701', componentName: 'Aris Top Canopy- Gloss White', qty: 3000, sellingPrice: 14.50, vendor: 'Atomberg' },
    { id: 'disp-104', date: '2026-05-25', itemCode: 'A101703', componentName: 'Aris Top Canopy- Gloss Black', qty: 900, sellingPrice: 15.96, vendor: 'Atomberg' },
    { id: 'disp-201', date: '2026-06-11', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4000, sellingPrice: 42.00, vendor: 'Haier' },
    { id: 'disp-202', date: '2026-06-18', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1600, sellingPrice: 85.00, vendor: 'Haier' },
    { id: 'disp-203', date: '2026-06-22', itemCode: 'A101701', componentName: 'Aris Top Canopy- Gloss White', qty: 3200, sellingPrice: 14.50, vendor: 'Atomberg' },
    { id: 'disp-204', date: '2026-06-28', itemCode: 'A101703', componentName: 'Aris Top Canopy- Gloss Black', qty: 950, sellingPrice: 15.96, vendor: 'Atomberg' },
    { id: 'disp-301', date: '2026-07-10', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4100, sellingPrice: 42.00, vendor: 'Haier' },
    { id: 'disp-302', date: '2026-07-15', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1700, sellingPrice: 85.00, vendor: 'Haier' },
    { id: 'disp-303', date: '2026-07-20', itemCode: 'A101701', componentName: 'Aris Top Canopy- Gloss White', qty: 3400, sellingPrice: 14.50, vendor: 'Atomberg' },
    { id: 'disp-304', date: '2026-07-25', itemCode: 'A101703', componentName: 'Aris Top Canopy- Gloss Black', qty: 980, sellingPrice: 15.96, vendor: 'Atomberg' },
    { id: 'disp-401', date: '2026-08-10', itemCode: '0060217989D', componentName: 'End cap Bottom Ref-ABS-DC-195,220', qty: 4200, sellingPrice: 42.00, vendor: 'Haier' },
    { id: 'disp-402', date: '2026-08-12', itemCode: '0060217978E', componentName: 'CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX', qty: 1800, sellingPrice: 85.00, vendor: 'Haier' },
    { id: 'disp-403', date: '2026-08-15', itemCode: 'A101701', componentName: 'Aris Top Canopy- Gloss White', qty: 3500, sellingPrice: 14.50, vendor: 'Atomberg' },
    { id: 'disp-404', date: '2026-08-01', itemCode: 'A101703', componentName: 'Aris Top Canopy- Gloss Black', qty: 1000, sellingPrice: 15.96, vendor: 'Atomberg' }
  ],

  parameterChangeLogs: []
};

let listeners = [];
export function subscribeStore(fn) {
  listeners.push(fn);
  return () => { listeners = listeners.filter(l => l !== fn); };
}

export function notifyStore() {
  listeners.forEach(fn => fn());
}

export function addAuditLog(entry) {
  if (!globalStore.parameterChangeLogs) globalStore.parameterChangeLogs = [];
  globalStore.parameterChangeLogs.unshift({
    id: `log-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
    timestamp: new Date().toLocaleString(),
    partCode: entry.partCode || 'RM Matrix',
    componentName: entry.componentName || 'Raw Material Spec',
    vendor: entry.vendor || 'Haier',
    modifications: entry.modifications || 'Updated Values',
    costImpact: entry.costImpact || 'Updated',
    authorizedBy: entry.authorizedBy || 'Costing Lead',
    reason: entry.reason || 'Matrix Modification'
  });
}

export function toggleGlobalLock() {
  globalStore.isGlobalLocked = !globalStore.isGlobalLocked;
  addAuditLog({
    partCode: 'Security Lock',
    componentName: 'Page Protection Status',
    vendor: 'System',
    modifications: `Page switched to ${globalStore.isGlobalLocked ? 'LOCKED (Protected)' : 'UNLOCKED (Active Editing)'}`,
    costImpact: '-',
    reason: globalStore.isGlobalLocked ? 'Lock Applied' : 'Unlocked for Editing'
  });
  notifyStore();
}

export function updateRmMappingRow(rowId, updatedFields, reason = 'Price / Alternate Update') {
  const row = (globalStore.rmMappingsData || []).find(r => r.id === rowId);
  if (row) {
    const modParts = [];
    if (updatedFields.approvedPrice !== undefined) {
      modParts.push(`Approved Price: ₹${row.approvedPrice} ➔ ₹${updatedFields.approvedPrice}`);
      // Also sync to matching baseline product
      (globalStore.baselineProducts || []).forEach(p => {
        if (p.approvedRm === row.approvedCode && p.vendor.toLowerCase() === row.vendor.toLowerCase()) {
          p.approvedRmRate = Number(updatedFields.approvedPrice);
        }
      });
    }
    if (updatedFields.activeAlt !== undefined) {
      modParts.push(`Active Alternate: ${row.activeAlt ? row.activeAlt.toUpperCase() : 'ALT1'} ➔ ${updatedFields.activeAlt.toUpperCase()}`);
    }
    if (updatedFields.alt1Code !== undefined) modParts.push(`Alt-1 Grade: ${updatedFields.alt1Code}`);
    if (updatedFields.alt1Price !== undefined) modParts.push(`Alt-1 Price: ₹${updatedFields.alt1Price}`);
    if (updatedFields.alt2Code !== undefined) modParts.push(`Alt-2 Grade: ${updatedFields.alt2Code}`);
    if (updatedFields.alt2Price !== undefined) modParts.push(`Alt-2 Price: ₹${updatedFields.alt2Price}`);
    if (updatedFields.alt3Code !== undefined) modParts.push(`Alt-3 Grade: ${updatedFields.alt3Code}`);
    if (updatedFields.alt3Price !== undefined) modParts.push(`Alt-3 Price: ₹${updatedFields.alt3Price}`);

    Object.assign(row, updatedFields);

    addAuditLog({
      partCode: row.approvedCode,
      componentName: `${row.type} (${row.vendor})`,
      vendor: row.vendor,
      modifications: modParts.join(' | ') || 'Fields Updated',
      costImpact: updatedFields.approvedPrice ? `₹${updatedFields.approvedPrice}/kg` : 'Simulated',
      reason: reason
    });

    notifyStore();
  }
}

export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  
  // Persist all top-level baseline costing fields
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

  // Persist running shopfloor parameters
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
      const newProd = {
        ...staged,
        id: `prod-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
        vendor: vendor || staged.vendor || 'Haier'
      };
      globalStore.baselineProducts.push(newProd);
    }
  });
  notifyStore();
}

export function addDayWisePurchase(record) {
  if (!globalStore.purchases) globalStore.purchases = [];
  globalStore.purchases.unshift(record);
  addAuditLog({
    partCode: record.grade,
    componentName: `Inward Purchase (Inv #${record.invoiceNo || '-'})`,
    vendor: record.vendor,
    modifications: `Qty: ${record.qty} kg @ ₹${record.rate}/kg`,
    costImpact: `₹${record.rate}/kg`,
    reason: 'New Purchase Lot Added'
  });
  notifyStore();
}

export function addDayWiseSales(record) {
  if (!globalStore.sales) globalStore.sales = [];
  globalStore.sales.unshift(record);
  addAuditLog({
    partCode: record.itemCode,
    componentName: record.componentName || 'Dispatch Part',
    vendor: record.vendor,
    modifications: `Dispatch: ${record.qty} pcs @ ₹${record.sellingPrice}`,
    costImpact: `₹${record.sellingPrice}/pc`,
    reason: 'New Dispatch Record Added'
  });
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

export function onboardVendorWithBlueprint({ vendorId, vendorName }) {
  if (!globalStore.vendors.find(v => v.vendorId === vendorId)) {
    globalStore.vendors.push({ vendorId, vendorName });
  }
  notifyStore();
}
