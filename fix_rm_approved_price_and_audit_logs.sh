#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js to record complete audit change logs for all RM edits..."
cat << 'STORE_EOF' > src/shared/masterStore.js
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
STORE_EOF

echo "==> 2. Writing enhanced RMPriceMatrixPage with Editable Approved Price and full change logging..."
cat << 'PAGE_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  globalStore, 
  subscribeStore, 
  updateRmMappingRow, 
  addDayWisePurchase, 
  addDayWiseSales,
  toggleGlobalLock,
  saveVendorPeriodSchedule
} from '../../shared/masterStore';
import { 
  Lock, 
  Unlock, 
  Save, 
  FileSpreadsheet, 
  ShoppingCart, 
  Truck, 
  History, 
  CheckCircle2, 
  Calendar, 
  Filter, 
  Plus, 
  ChevronDown 
} from 'lucide-react';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  const [activeTab, setActiveTab] = useState('matrix');
  const [selectedVendor, setSelectedVendor] = useState('Haier Appliances');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [saveSuccess, setSaveSuccess] = useState(false);

  const [newPur, setNewPur] = useState({ date: '2026-08-15', grade: '', qty: '', rate: '', invoiceNo: '' });
  const [newSale, setNewSale] = useState({ date: '2026-08-15', itemCode: '', componentName: '', qty: '', sellingPrice: '' });

  useEffect(() => {
    return subscribeStore(() => setTick(t => t + 1));
  }, []);

  const isLocked = globalStore.isGlobalLocked;
  const rawVendorKey = selectedVendor.toLowerCase().includes('haier') ? 'Haier' : 'Atomberg';

  const currentMappings = (globalStore.rmMappingsData || []).filter(
    m => (m.vendor || '').toLowerCase().includes(rawVendorKey.toLowerCase())
  );

  const availablePurchaseGrades = Array.from(new Set(
    (globalStore.purchases || [])
      .filter(p => (p.vendor || '').toLowerCase().includes(rawVendorKey.toLowerCase()))
      .map(p => p.grade)
  )).filter(Boolean);

  const handleActiveAltChange = (rowId, altKey) => {
    if (isLocked) return;
    updateRmMappingRow(rowId, { activeAlt: altKey }, `Active alternate switched to ${altKey.toUpperCase()}`);
  };

  const handleDropdownSelect = (rowId, altSlot, selectedGrade) => {
    if (isLocked) return;
    const purMatch = (globalStore.purchases || []).find(
      p => (p.vendor || '').toLowerCase().includes(rawVendorKey.toLowerCase()) && p.grade === selectedGrade
    );
    const updates = { [`${altSlot}Code`]: selectedGrade };
    if (purMatch && purMatch.rate) {
      updates[`${altSlot}Price`] = Number(purMatch.rate);
    }
    updateRmMappingRow(rowId, updates, `Updated ${altSlot.toUpperCase()} to ${selectedGrade}`);
  };

  const handlePriceChange = (rowId, altSlot, newPrice) => {
    if (isLocked) return;
    updateRmMappingRow(rowId, { [`${altSlot}Price`]: Number(newPrice) || 0 }, `Updated ${altSlot.toUpperCase()} price`);
  };

  const handleApprovedPriceChange = (rowId, newPrice) => {
    if (isLocked) return;
    updateRmMappingRow(rowId, { approvedPrice: Number(newPrice) || 0 }, 'Updated Contract Approved Price');
  };

  const handleSavePeriod = () => {
    saveVendorPeriodSchedule();
    setSaveSuccess(true);
    setTimeout(() => setSaveSuccess(false), 3000);
  };

  const handleAddPurchase = (e) => {
    e.preventDefault();
    if (!newPur.grade || !newPur.qty || !newPur.rate) return;
    addDayWisePurchase({
      id: `pur-${Date.now()}`,
      date: newPur.date,
      vendor: rawVendorKey,
      grade: newPur.grade,
      qty: Number(newPur.qty),
      rate: Number(newPur.rate),
      invoiceNo: newPur.invoiceNo || `INV-${Date.now().toString().slice(-4)}`
    });
    setNewPur({ date: '2026-08-15', grade: '', qty: '', rate: '', invoiceNo: '' });
  };

  const handleAddSale = (e) => {
    e.preventDefault();
    if (!newSale.itemCode || !newSale.qty || !newSale.sellingPrice) return;
    addDayWiseSales({
      id: `sale-${Date.now()}`,
      date: newSale.date,
      vendor: rawVendorKey,
      itemCode: newSale.itemCode,
      componentName: newSale.componentName || 'Molded Component',
      qty: Number(newSale.qty),
      sellingPrice: Number(newSale.sellingPrice)
    });
    setNewSale({ date: '2026-08-15', itemCode: '', componentName: '', qty: '', sellingPrice: '' });
  };

  const getDropdownOptions = (row, currentVal) => {
    const list = new Set([
      currentVal,
      row.approvedCode,
      row.alt1Code,
      row.alt2Code,
      row.alt3Code,
      ...availablePurchaseGrades
    ]);
    return Array.from(list).filter(Boolean);
  };

  const renderAltCell = (row, altSlot) => {
    const altCodeKey = `${altSlot}Code`;
    const isActive = (row.activeAlt || 'alt1') === altSlot;
    const currentVal = row[altCodeKey] || '';
    const options = getDropdownOptions(row, currentVal);

    return (
      <td className="py-2.5 px-3">
        <div className={`p-2 rounded-xl border transition-all flex flex-col gap-2 ${
          isActive 
            ? 'border-blue-500 bg-blue-50/70 shadow-sm ring-1 ring-blue-400/40' 
            : 'border-slate-200 bg-slate-50/50 hover:border-slate-300'
        }`}>
          {/* Dropdown Material Selector */}
          <div className="relative flex items-center">
            <select
              disabled={isLocked}
              value={currentVal}
              onChange={(e) => handleDropdownSelect(row.id, altSlot, e.target.value)}
              className="w-full appearance-none bg-white border border-slate-300 rounded-lg pl-2.5 pr-7 py-1.5 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-100 disabled:text-slate-700 disabled:cursor-not-allowed shadow-sm truncate cursor-pointer"
            >
              {options.map((opt, idx) => (
                <option key={idx} value={opt}>{opt}</option>
              ))}
            </select>
            <ChevronDown className="w-3.5 h-3.5 text-slate-400 absolute right-2 pointer-events-none" />
          </div>

          {/* Radio Button Selector */}
          <div className="flex items-center justify-between pt-1 border-t border-slate-200/70">
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="radio"
                name={`activeAlt-${row.id}`}
                checked={isActive}
                disabled={isLocked}
                onChange={() => handleActiveAltChange(row.id, altSlot)}
                className="w-4 h-4 text-blue-600 focus:ring-blue-500 cursor-pointer disabled:cursor-not-allowed"
              />
              <span className="text-[11px] font-bold text-slate-700">Set Active</span>
            </label>
            <span className={`px-2 py-0.5 rounded text-[10px] font-black uppercase tracking-wider ${
              isActive ? 'bg-blue-600 text-white shadow-xs' : 'bg-slate-200 text-slate-600'
            }`}>
              {isActive ? 'Active' : 'Standby'}
            </span>
          </div>
        </div>
      </td>
    );
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Header Banner */}
      <div className="bg-[#0f172a] text-white p-6 rounded-2xl shadow-xl flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-blue-600/30 rounded-xl border border-blue-500/30 text-blue-400">
            <FileSpreadsheet className="w-8 h-8" />
          </div>
          <div>
            <h1 className="text-xl md:text-2xl font-bold tracking-tight">RM Mapping & Inward Registry</h1>
            <p className="text-sm text-slate-400">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        {/* Dynamic Global Lock / Unlock Button */}
        <button 
          onClick={toggleGlobalLock}
          className={`flex items-center gap-2 px-5 py-2.5 rounded-xl font-bold text-sm shadow-md transition-all cursor-pointer ${
            isLocked 
              ? 'bg-amber-500 hover:bg-amber-600 text-white shadow-amber-500/20' 
              : 'bg-emerald-600 hover:bg-emerald-700 text-white shadow-emerald-600/20'
          }`}
        >
          {isLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4" />}
          {isLocked ? 'Page Locked (Click to Unlock & Edit)' : 'Page Unlocked (Editing Active)'}
        </button>
      </div>

      {/* Sub Tabs */}
      <div className="flex flex-wrap gap-2 border-b border-slate-200 pb-2">
        <button
          onClick={() => setActiveTab('matrix')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all cursor-pointer ${
            activeTab === 'matrix' ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' : 'bg-white text-slate-600 hover:bg-slate-100'
          }`}
        >
          <FileSpreadsheet className="w-4 h-4" /> RM Price Matrix
        </button>
        <button
          onClick={() => setActiveTab('purchases')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all cursor-pointer ${
            activeTab === 'purchases' ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' : 'bg-white text-slate-600 hover:bg-slate-100'
          }`}
        >
          <ShoppingCart className="w-4 h-4" /> Day-wise Purchases ({(globalStore.purchases || []).length})
        </button>
        <button
          onClick={() => setActiveTab('sales')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all cursor-pointer ${
            activeTab === 'sales' ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' : 'bg-white text-slate-600 hover:bg-slate-100'
          }`}
        >
          <Truck className="w-4 h-4" /> Day-wise Sales ({(globalStore.sales || []).length})
        </button>
        <button
          onClick={() => setActiveTab('logs')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all cursor-pointer ${
            activeTab === 'logs' ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' : 'bg-white text-slate-600 hover:bg-slate-100'
          }`}
        >
          <History className="w-4 h-4" /> Baseline & RM Change Log ({(globalStore.parameterChangeLogs || []).length})
        </button>
      </div>

      {/* Filter Scope Toolbar */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-sm flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-blue-600 font-bold" />
            <span className="text-xs font-black uppercase tracking-wider text-slate-500">FILTER:</span>
            <span className="text-xs font-bold text-slate-700">Vendor:</span>
            <select 
              value={selectedVendor} 
              onChange={e => setSelectedVendor(e.target.value)}
              className="bg-slate-50 border border-slate-300 text-slate-800 text-sm font-bold rounded-lg px-3 py-1.5 focus:ring-2 focus:ring-blue-500 outline-none cursor-pointer"
            >
              <option value="Haier Appliances">Haier Appliances</option>
              <option value="Atomberg Technologies">Atomberg Technologies</option>
            </select>
          </div>

          <div className="flex items-center gap-2">
            <Calendar className="w-4 h-4 text-slate-400" />
            <span className="text-xs font-bold text-slate-600">Period:</span>
            <span className="text-xs text-slate-400">From</span>
            <input 
              type="date" 
              value={periodFrom} 
              onChange={e => setPeriodFrom(e.target.value)}
              className="bg-slate-50 border border-slate-300 text-slate-700 text-xs font-medium rounded-lg px-2 py-1 outline-none"
            />
            <span className="text-xs text-slate-400">To</span>
            <input 
              type="date" 
              value={periodTo} 
              onChange={e => setPeriodTo(e.target.value)}
              className="bg-slate-50 border border-slate-300 text-slate-700 text-xs font-medium rounded-lg px-2 py-1 outline-none"
            />
          </div>
        </div>

        <button 
          onClick={handleSavePeriod}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-4 py-2 rounded-xl transition-all shadow-sm cursor-pointer"
        >
          <Save className="w-4 h-4" /> Save for Vendor + period
        </button>
      </div>

      {saveSuccess && (
        <div className="p-3 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl text-xs font-bold flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" /> Vendor and period schedule saved successfully.
        </div>
      )}

      {/* Lock Protected State Banner */}
      {isLocked && (
        <div className="p-3.5 bg-amber-50/80 border border-amber-200 text-amber-900 rounded-xl text-xs font-medium flex items-center gap-2">
          <Lock className="w-4 h-4 text-amber-600 flex-shrink-0" />
          <span><b>Protected State:</b> This page is locked. Click <b>"Page Locked (Click to Unlock & Edit)"</b> above to edit Approved Price, change Alternate Materials, or modify WA prices.</span>
        </div>
      )}

      {/* TAB 1: RM PRICE MATRIX TABLE */}
      {activeTab === 'matrix' && (
        <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-[#0b1329] text-white uppercase text-[11px] tracking-wider font-semibold border-b border-slate-800">
                  <th className="py-3.5 px-4 font-bold min-w-[200px]">Approved RM/MB Code</th>
                  <th className="py-3.5 px-3 font-bold text-center bg-[#152347] min-w-[130px]">Approved Price (₹/kg)</th>
                  <th className="py-3.5 px-3 font-bold min-w-[230px]">Alternate RM-1</th>
                  <th className="py-3.5 px-3 font-bold text-center bg-[#152347] min-w-[90px]">Price (WA)</th>
                  <th className="py-3.5 px-3 font-bold min-w-[230px]">Alternate RM-2</th>
                  <th className="py-3.5 px-3 font-bold text-center bg-[#152347] min-w-[90px]">Price (WA)</th>
                  <th className="py-3.5 px-3 font-bold min-w-[230px]">Alternate RM-3</th>
                  <th className="py-3.5 px-3 font-bold text-center bg-[#152347] min-w-[90px]">Price (WA)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {currentMappings.map((row) => (
                  <tr key={row.id} className="hover:bg-slate-50/80 transition-colors">
                    {/* Approved RM/MB Code */}
                    <td className="py-3 px-4">
                      <div className="flex items-center gap-2">
                        <span className={`px-2 py-0.5 rounded text-[10px] font-black uppercase ${
                          row.type === 'MB' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                        }`}>
                          {row.type === 'MB' ? 'Masterbatch' : 'RM Code'}
                        </span>
                        <span className="font-bold text-slate-900">{row.approvedCode}</span>
                      </div>
                    </td>

                    {/* Approved Price (Now Fully Editable when Unlocked) */}
                    <td className="py-3 px-3 text-center bg-slate-50/50">
                      {isLocked ? (
                        <div className="inline-flex items-center justify-center font-bold text-slate-900 bg-white border border-slate-200 px-3 py-1.5 rounded-lg text-xs shadow-sm">
                          ₹ {Number(row.approvedPrice || 0).toFixed(2)}
                        </div>
                      ) : (
                        <div className="inline-flex items-center gap-1 bg-amber-50/80 border border-amber-300 rounded-lg px-2 py-1 shadow-sm">
                          <span className="text-xs font-bold text-amber-800">₹</span>
                          <input 
                            type="number"
                            step="0.01"
                            value={row.approvedPrice ?? 0}
                            onChange={(e) => handleApprovedPriceChange(row.id, e.target.value)}
                            className="w-20 text-center font-bold text-slate-900 bg-white border border-amber-400 rounded px-1.5 py-0.5 text-xs outline-none focus:ring-2 focus:ring-blue-500"
                          />
                        </div>
                      )}
                    </td>

                    {/* Alt 1 */}
                    {renderAltCell(row, 'alt1')}
                    <td className="py-3 px-3 text-center bg-slate-50/50">
                      {isLocked ? (
                        <span className="font-bold text-blue-600">₹{Number(row.alt1Price || 0).toFixed(2)}</span>
                      ) : (
                        <input 
                          type="number"
                          step="0.01"
                          value={row.alt1Price ?? 0}
                          onChange={(e) => handlePriceChange(row.id, 'alt1', e.target.value)}
                          className="w-20 text-center font-bold text-blue-700 bg-white border border-blue-300 rounded-lg px-2 py-1 text-xs shadow-sm outline-none focus:ring-2 focus:ring-blue-500"
                        />
                      )}
                    </td>

                    {/* Alt 2 */}
                    {renderAltCell(row, 'alt2')}
                    <td className="py-3 px-3 text-center bg-slate-50/50">
                      {isLocked ? (
                        <span className="font-bold text-slate-800">₹{Number(row.alt2Price || 0).toFixed(2)}</span>
                      ) : (
                        <input 
                          type="number"
                          step="0.01"
                          value={row.alt2Price ?? 0}
                          onChange={(e) => handlePriceChange(row.id, 'alt2', e.target.value)}
                          className="w-20 text-center font-bold text-slate-800 bg-white border border-slate-300 rounded-lg px-2 py-1 text-xs shadow-sm outline-none focus:ring-2 focus:ring-blue-500"
                        />
                      )}
                    </td>

                    {/* Alt 3 */}
                    {renderAltCell(row, 'alt3')}
                    <td className="py-3 px-3 text-center bg-slate-50/50">
                      {isLocked ? (
                        <span className="font-bold text-slate-800">₹{Number(row.alt3Price || 0).toFixed(2)}</span>
                      ) : (
                        <input 
                          type="number"
                          step="0.01"
                          value={row.alt3Price ?? 0}
                          onChange={(e) => handlePriceChange(row.id, 'alt3', e.target.value)}
                          className="w-20 text-center font-bold text-slate-800 bg-white border border-slate-300 rounded-lg px-2 py-1 text-xs shadow-sm outline-none focus:ring-2 focus:ring-blue-500"
                        />
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 2: DAY-WISE PURCHASES */}
      {activeTab === 'purchases' && (
        <div className="space-y-4">
          <form onSubmit={handleAddPurchase} className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-wrap items-center gap-3">
            <span className="text-xs font-bold text-slate-700">Add Purchase Inward:</span>
            <input 
              type="date" 
              value={newPur.date} 
              onChange={e => setNewPur({...newPur, date: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none"
              required
            />
            <input 
              type="text" 
              placeholder="Inward RM Grade" 
              value={newPur.grade} 
              onChange={e => setNewPur({...newPur, grade: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none min-w-[200px]"
              required
            />
            <input 
              type="number" 
              placeholder="Qty (kg)" 
              value={newPur.qty} 
              onChange={e => setNewPur({...newPur, qty: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-24"
              required
            />
            <input 
              type="number" 
              step="0.01"
              placeholder="Rate (₹/kg)" 
              value={newPur.rate} 
              onChange={e => setNewPur({...newPur, rate: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-24"
              required
            />
            <input 
              type="text" 
              placeholder="Invoice #" 
              value={newPur.invoiceNo} 
              onChange={e => setNewPur({...newPur, invoiceNo: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-28"
            />
            <button type="submit" className="bg-blue-600 text-white px-4 py-1.5 rounded-lg text-xs font-bold hover:bg-blue-700 flex items-center gap-1 cursor-pointer">
              <Plus className="w-3.5 h-3.5" /> Add Inward
            </button>
          </form>

          <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-100 text-slate-700 font-bold border-b border-slate-200">
                  <th className="py-2.5 px-4">Date</th>
                  <th className="py-2.5 px-4">Vendor</th>
                  <th className="py-2.5 px-4">Invoice #</th>
                  <th className="py-2.5 px-4">Grade</th>
                  <th className="py-2.5 px-4 text-right">Inward Qty (kg)</th>
                  <th className="py-2.5 px-4 text-right">Purchase Rate (₹/kg)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {(globalStore.purchases || []).map((p, i) => (
                  <tr key={i} className="hover:bg-slate-50">
                    <td className="py-2 px-4 font-mono">{p.date}</td>
                    <td className="py-2 px-4">{p.vendor}</td>
                    <td className="py-2 px-4 font-mono">{p.invoiceNo || '-'}</td>
                    <td className="py-2 px-4 font-bold text-slate-800">{p.grade}</td>
                    <td className="py-2 px-4 text-right font-mono">{Number(p.qty).toLocaleString()} kg</td>
                    <td className="py-2 px-4 text-right font-bold text-blue-600">₹{Number(p.rate).toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 3: DAY-WISE SALES */}
      {activeTab === 'sales' && (
        <div className="space-y-4">
          <form onSubmit={handleAddSale} className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-wrap items-center gap-3">
            <span className="text-xs font-bold text-slate-700">Add Dispatch Sale:</span>
            <input 
              type="date" 
              value={newSale.date} 
              onChange={e => setNewSale({...newSale, date: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none"
              required
            />
            <input 
              type="text" 
              placeholder="Item Code" 
              value={newSale.itemCode} 
              onChange={e => setNewSale({...newSale, itemCode: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-32"
              required
            />
            <input 
              type="text" 
              placeholder="Component Description" 
              value={newSale.componentName} 
              onChange={e => setNewSale({...newSale, componentName: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none min-w-[200px]"
            />
            <input 
              type="number" 
              placeholder="Dispatch Qty" 
              value={newSale.qty} 
              onChange={e => setNewSale({...newSale, qty: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-28"
              required
            />
            <input 
              type="number" 
              step="0.01"
              placeholder="Selling Price (₹)" 
              value={newSale.sellingPrice} 
              onChange={e => setNewSale({...newSale, sellingPrice: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-28"
              required
            />
            <button type="submit" className="bg-blue-600 text-white px-4 py-1.5 rounded-lg text-xs font-bold hover:bg-blue-700 flex items-center gap-1 cursor-pointer">
              <Plus className="w-3.5 h-3.5" /> Record Dispatch
            </button>
          </form>

          <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-100 text-slate-700 font-bold border-b border-slate-200">
                  <th className="py-2.5 px-4">Date</th>
                  <th className="py-2.5 px-4">Vendor</th>
                  <th className="py-2.5 px-4">Item Code</th>
                  <th className="py-2.5 px-4">Component Name</th>
                  <th className="py-2.5 px-4 text-right">Qty</th>
                  <th className="py-2.5 px-4 text-right">Selling Price (₹)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {(globalStore.sales || []).map((s, i) => (
                  <tr key={i} className="hover:bg-slate-50">
                    <td className="py-2 px-4 font-mono">{s.date}</td>
                    <td className="py-2 px-4">{s.vendor}</td>
                    <td className="py-2 px-4 font-mono font-bold text-blue-600">{s.itemCode}</td>
                    <td className="py-2 px-4">{s.componentName}</td>
                    <td className="py-2 px-4 text-right font-mono font-semibold">{Number(s.qty).toLocaleString()}</td>
                    <td className="py-2 px-4 text-right font-bold text-emerald-600">₹{Number(s.sellingPrice).toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 4: AUDIT CHANGE LOGS */}
      {activeTab === 'logs' && (
        <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-sm">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-slate-100 text-slate-700 font-bold border-b border-slate-200">
                <th className="py-2.5 px-4">Timestamp</th>
                <th className="py-2.5 px-4">Part / Grade Code</th>
                <th className="py-2.5 px-4">Vendor</th>
                <th className="py-2.5 px-4">Modifications / Log Details</th>
                <th className="py-2.5 px-4">Cost Impact / Value</th>
                <th className="py-2.5 px-4">Authorized By</th>
                <th className="py-2.5 px-4">Reason</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {(globalStore.parameterChangeLogs || []).length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-6 text-center text-slate-400 italic">No parameter or RM mapping changes recorded yet.</td>
                </tr>
              ) : (
                globalStore.parameterChangeLogs.map((log, idx) => (
                  <tr key={idx} className="hover:bg-slate-50 transition-colors">
                    <td className="py-2.5 px-4 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="py-2.5 px-4 font-bold text-slate-800">{log.partCode}</td>
                    <td className="py-2.5 px-4">{log.vendor}</td>
                    <td className="py-2.5 px-4 text-slate-700 font-medium">{log.modifications}</td>
                    <td className="py-2.5 px-4 font-bold text-blue-600">{log.costImpact}</td>
                    <td className="py-2.5 px-4 font-semibold text-slate-600">{log.authorizedBy}</td>
                    <td className="py-2.5 px-4 text-slate-500 italic">{log.reason}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
PAGE_EOF

echo "==> 3. Restarting Vite cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Refresh your browser now."
