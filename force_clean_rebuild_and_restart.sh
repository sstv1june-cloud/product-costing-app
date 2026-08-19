#!/usr/bin/env bash
set -e

echo "==> 1. Writing Unified Master Store..."
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';

const initialData = Array.isArray(initialBaselineData) ? initialBaselineData : [];

export const globalStore = {
  vendors: [
    { vendorId: "Atomberg", vendorName: "Atomberg Technologies", code: "ATOM", paymentTerms: "45 Days", active: true, lineCount: 38 },
    { vendorId: "Haier", vendorName: "Haier Appliances", code: "HAIER", paymentTerms: "60 to 45 Days", active: true, lineCount: 38 },
    { vendorId: "LG", vendorName: "LG Electronics", code: "LG", paymentTerms: "45 Days", active: true, lineCount: 9 },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India", code: "WHIRLPOOL", paymentTerms: "60 Days", active: true, lineCount: 7 }
  ],

  vendorLockStatus: {
    Atomberg: true,
    Haier: true,
    LG: false,
    Whirlpool: false
  },

  vendorBaselines: {
    Atomberg: [
      {
        id: "BL-ATOM-001",
        vendor: "Atomberg",
        itemCode: "A101701",
        componentName: "Aris Top Canopy- Gloss White",
        model: "Aris",
        mouldSize: "950*600*450",
        approvedRm: "PP H110MA",
        approvedRmRate: 140.00,
        masterbatchPct: 4.0,
        masterbatchRate: 254.00,
        bopCost: 0.0,
        cavity: 2,
        netWeight: 37.0,
        runnerWeight: 1.0,
        cycleTimeApproved: 47.0,
        cycleTime: 47.0,
        machineTonnage: 200,
        hourlyRate: 250,
        validFrom: "2026-08-01",
        parameters: {
          cavity: 2,
          netWeightApproved: 37.0,
          runnerWeight: 1.0,
          cycleTimeApproved: 47.0,
          machineTonnage: 200,
          shiftTariff: 2000,
          bopCost: 0.0,
          masterbatchPct: 4.0
        }
      }
    ],
    Haier: initialData.filter(d => (d.vendor || 'Haier') === 'Haier'),
    LG: initialData.filter(d => d.vendor === 'LG'),
    Whirlpool: initialData.filter(d => d.vendor === 'Whirlpool')
  },

  baselineList: [],

  purchaseMaster: [
    { code: "PUR-PP-01", invoiceNo: "INV-PUR-8830", name: "PP H110MA Prime Inward", polymer: "PP", supplier: "Reliance Industries", waPrice: 135.83, inwardDate: "2026-08-02", qtyKg: 10000 },
    { code: "PUR-MB-01", invoiceNo: "INV-PUR-8831", name: "White Masterbatch 258 Grade", polymer: "MB", supplier: "Clariant Masterbatches", waPrice: 258.54, inwardDate: "2026-08-02", qtyKg: 1500 },
    { code: "PUR-ABS-01", invoiceNo: "INV-PUR-8821", name: "ABS 300-B Red (Prime Inward)", polymer: "ABS", supplier: "Supreme Petrochem", waPrice: 134.80, inwardDate: "2026-08-01", qtyKg: 12500 },
    { code: "PUR-ABS-02", invoiceNo: "INV-PUR-8822", name: "ABS 300-Blue (Imported)", polymer: "ABS", supplier: "Chi Mei", waPrice: 131.25, inwardDate: "2026-08-05", qtyKg: 8200 },
    { code: "PUR-GPPS-01", invoiceNo: "INV-PUR-8824", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", polymer: "GPPS", supplier: "Supreme", waPrice: 98.40, inwardDate: "2026-08-03", qtyKg: 9000 }
  ],

  salesData: [
    { id: "INV-SLS-004", invoiceNo: "INV-SLS-004", itemCode: "A101701", componentName: "Aris Top Canopy- Gloss White", vendor: "Atomberg", saleUnit: 3500, invoiceDate: "2026-08-15", sellingPrice: 14.50 },
    { id: "INV-SLS-001", invoiceNo: "INV-SLS-001", itemCode: "0060226713H", componentName: "End Cap Top Ref (without Screen Painting )", vendor: "Haier", saleUnit: 4500, invoiceDate: "2026-08-05", sellingPrice: 38.50 },
    { id: "INV-SLS-002", invoiceNo: "INV-SLS-002", itemCode: "0060217989D", componentName: "End cap Bottom Ref-ABS-DC-195,220", vendor: "Haier", saleUnit: 4200, invoiceDate: "2026-08-10", sellingPrice: 42.00 },
    { id: "INV-SLS-003", invoiceNo: "INV-SLS-003", itemCode: "0060217978E", componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX", vendor: "Haier", saleUnit: 1800, invoiceDate: "2026-08-12", sellingPrice: 85.00 }
  ],

  rmMatrix: [
    {
      id: "RM-ATOM-PP-P1",
      vendor: "Atomberg",
      approvedRm: "PP H110MA",
      polymer: "PP",
      approvedPrice: 140.00,
      validFrom: "2026-08-01",
      validTo: "2026-08-31",
      activeSelection: "alt1",
      alt1: { code: "PUR-PP-01", name: "PP H110MA Prime Inward", waPrice: 135.83 }
    },
    {
      id: "RM-ATOM-MB-P1",
      vendor: "Atomberg",
      approvedRm: "MB White Grade",
      polymer: "MB",
      approvedPrice: 254.00,
      validFrom: "2026-08-01",
      validTo: "2026-08-31",
      activeSelection: "alt1",
      alt1: { code: "PUR-MB-01", name: "White Masterbatch 258 Grade", waPrice: 258.54 }
    },
    {
      id: "RM-HAIER-ABS-P1",
      vendor: "Haier",
      approvedRm: "ABS 300 Pre Colour",
      polymer: "ABS",
      approvedPrice: 140.00,
      validFrom: "2026-08-01",
      validTo: "2026-08-31",
      activeSelection: "alt1",
      alt1: { code: "PUR-ABS-01", name: "ABS 300-B Red (Prime Inward)", waPrice: 134.80 }
    },
    {
      id: "RM-HAIER-GPPS-P1",
      vendor: "Haier",
      approvedRm: "GPPS SC201LV",
      polymer: "GPPS",
      approvedPrice: 103.08,
      validFrom: "2026-08-01",
      validTo: "2026-08-31",
      activeSelection: "alt1",
      alt1: { code: "PUR-GPPS-01", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", waPrice: 98.40 }
    }
  ],

  parameterChangeLogs: [],
  rmPriceHistoryLogs: []
};

const listeners = new Set();
export const subscribeStore = (fn) => { listeners.add(fn); return () => listeners.delete(fn); };
export const notifyStore = () => listeners.forEach(fn => fn());

export const syncMasterBaselineList = () => {
  let all = [];
  Object.keys(globalStore.vendorBaselines || {}).forEach(v => {
    all = [...all, ...(globalStore.vendorBaselines[v] || [])];
  });
  globalStore.baselineList = all;
};
syncMasterBaselineList();

export const getVendorBaselineData = (vendor) => {
  if (vendor === 'ALL') {
    syncMasterBaselineList();
    return globalStore.baselineList;
  }
  return globalStore.vendorBaselines[vendor] || [];
};

export const getActiveRmMapping = (approvedRmName, vendor = "Atomberg", targetDate = null) => {
  const vKey = (vendor || "Atomberg").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey &&
    ((approvedRmName && r.approvedRm.toLowerCase().includes(approvedRmName.toLowerCase())) ||
     (approvedRmName && approvedRmName.toLowerCase().includes(r.approvedRm.toLowerCase())) ||
     (approvedRmName && approvedRmName.toLowerCase().includes(r.polymer?.toLowerCase())))
  );

  let row = rows[0];
  if (!row) {
    return {
      vendor: vendor || "Atomberg",
      approvedRm: approvedRmName || "PP H110MA",
      approvedPrice: 140.00,
      activeRmName: "PP H110MA Prime Inward",
      activeWaPrice: 135.83,
      validFrom: "2026-08-01",
      validTo: "2026-08-31"
    };
  }

  let activeRmName = row.approvedRm;
  let activeWaPrice = Number(row.approvedPrice);

  if (row.activeSelection === 'alt1' && row.alt1) {
    activeRmName = row.alt1.name;
    activeWaPrice = Number(row.alt1.waPrice);
  } else if (row.activeSelection === 'alt2' && row.alt2) {
    activeRmName = row.alt2.name;
    activeWaPrice = Number(row.alt2.waPrice);
  }

  return {
    vendor: row.vendor,
    approvedRm: row.approvedRm,
    approvedPrice: Number(row.approvedPrice),
    validFrom: row.validFrom,
    validTo: row.validTo,
    activeSelection: row.activeSelection,
    activeRmName,
    activeWaPrice: Number(activeWaPrice),
    alt1: row.alt1,
    alt2: row.alt2
  };
};

export const getActiveMbMapping = (vendor = "Atomberg", targetDate = null) => {
  const vKey = (vendor || "Atomberg").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey && r.polymer === 'MB'
  );

  let row = rows[0];
  if (!row) {
    return {
      approvedMbPrice: 254.00,
      activeMbName: "White Masterbatch 258 Grade",
      activeMbPrice: 258.54
    };
  }

  let activeMbPrice = Number(row.approvedPrice);
  let activeMbName = row.approvedRm;

  if (row.activeSelection === 'alt1' && row.alt1) {
    activeMbName = row.alt1.name;
    activeMbPrice = Number(row.alt1.waPrice);
  } else if (row.activeSelection === 'alt2' && row.alt2) {
    activeMbName = row.alt2.name;
    activeMbPrice = Number(row.alt2.waPrice);
  }

  return {
    approvedMbPrice: Number(row.approvedPrice),
    activeMbName,
    activeMbPrice: Number(activeMbPrice)
  };
};

export const toggleVendorLockStatus = (vendor, isLocked) => {
  globalStore.vendorLockStatus[vendor] = isLocked;
  notifyStore();
};

export const updateVendorScheduleBulk = (vendor, validFrom, validTo, updatedRows) => {
  const previousRows = (globalStore.rmMatrix || []).filter(r => r.vendor === vendor);

  globalStore.rmMatrix = globalStore.rmMatrix.map(row => {
    if (row.vendor === vendor) {
      const match = updatedRows.find(u => u.id === row.id);
      return match ? { ...match, validFrom, validTo, approvedPrice: Number(match.approvedPrice) } : { ...row, validFrom, validTo };
    }
    return row;
  });

  globalStore.vendorLockStatus[vendor] = true;

  if (globalStore.vendorBaselines[vendor]) {
    globalStore.vendorBaselines[vendor] = globalStore.vendorBaselines[vendor].map(prod => {
      const rmMatch = updatedRows.find(u => u.approvedRm === prod.approvedRm || prod.approvedRm.includes(u.polymer));
      const mbMatch = updatedRows.find(u => u.polymer === 'MB');
      return {
        ...prod,
        approvedRmRate: rmMatch ? Number(rmMatch.approvedPrice) : prod.approvedRmRate,
        masterbatchRate: mbMatch ? Number(mbMatch.approvedPrice) : prod.masterbatchRate,
        validFrom,
        validTo
      };
    });
  }
  syncMasterBaselineList();

  updatedRows.forEach(uRow => {
    const prev = previousRows.find(p => p.id === uRow.id);
    let altText = uRow.activeSelection === 'alt1' ? `Alternate 1 (${uRow.alt1?.name || ''})` : 
                  uRow.activeSelection === 'alt2' ? `Alternate 2 (${uRow.alt2?.name || ''})` : 'Primary Approved';

    const priceChanged = Math.abs((prev?.approvedPrice || 0) - (Number(uRow.approvedPrice) || 0)) >= 0.01;
    const note = priceChanged 
      ? `Approved price updated from ₹${(prev?.approvedPrice || uRow.approvedPrice).toFixed(2)} to ₹${Number(uRow.approvedPrice).toFixed(2)} for period (${validFrom} to ${validTo})`
      : `Locked period (${validFrom} to ${validTo}) with ${altText}`;

    globalStore.rmPriceHistoryLogs.unshift({
      id: `LOG-RM-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      vendor,
      rmGrade: uRow.approvedRm,
      action: priceChanged ? "Approved Price & Period Updated" : "Schedule Locked",
      period: `${validFrom} to ${validTo}`,
      previousRate: prev?.approvedPrice || uRow.approvedPrice,
      newRate: Number(uRow.approvedPrice),
      activeAlternate: altText,
      changedBy: "Engineering Head",
      reason: note
    });
  });

  notifyStore();
};

export const updateBaselineParameters = ({ itemId, updatedItem, changeType, newValidFrom, reason } = {}) => {
  const list = globalStore.baselineList || [];
  const idx = list.findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
  if (idx !== -1) {
    const prev = list[idx];
    const prevParams = prev.parameters || {};
    const newParams = updatedItem?.parameters || {};

    const changesList = [];
    const oldCycle = Number(prev.cycleTimeApproved ?? prev.cycleTime ?? 47);
    const newCycle = Number(newParams.runningCycleTime ?? updatedItem.cycleTimeApproved ?? updatedItem.cycleTime ?? oldCycle);
    if (Math.abs(oldCycle - newCycle) >= 0.01) {
      const d = Number((newCycle - oldCycle).toFixed(1));
      changesList.push({ parameter: "Cycle Time", oldVal: `${oldCycle} s`, newVal: `${newCycle} s`, diff: `${d > 0 ? '+' : ''}${d} s` });
    }

    const oldRunner = Number(prev.runnerWeight ?? prevParams.runnerWeight ?? 1);
    const newRunner = Number(newParams.runningRunnerWeight ?? updatedItem.runnerWeight ?? oldRunner);
    if (Math.abs(oldRunner - newRunner) >= 0.01) {
      const d = Number((newRunner - oldRunner).toFixed(1));
      changesList.push({ parameter: "Runner Weight", oldVal: `${oldRunner} g`, newVal: `${newRunner} g`, diff: `${d > 0 ? '+' : ''}${d} g` });
    }

    const oldNet = Number(prev.netWeight ?? prevParams.netWeightApproved ?? 37);
    const newNet = Number(newParams.runningNetWeight ?? updatedItem.netWeight ?? oldNet);
    if (Math.abs(oldNet - newNet) >= 0.01) {
      const d = Number((newNet - oldNet).toFixed(1));
      changesList.push({ parameter: "Net Weight", oldVal: `${oldNet} g`, newVal: `${newNet} g`, diff: `${d > 0 ? '+' : ''}${d} g` });
    }

    globalStore.baselineList[idx] = {
      ...prev,
      ...updatedItem,
      parameters: { ...prevParams, ...newParams },
      validFrom: newValidFrom || prev.validFrom
    };

    const v = prev.vendor || 'Atomberg';
    if (globalStore.vendorBaselines[v]) {
      const vIdx = globalStore.vendorBaselines[v].findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
      if (vIdx !== -1) {
        globalStore.vendorBaselines[v][vIdx] = globalStore.baselineList[idx];
      }
    }

    globalStore.parameterChangeLogs.unshift({
      id: `LOG-PARAM-${Date.now()}`,
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      itemCode: updatedItem?.itemCode || prev.itemCode,
      componentName: updatedItem?.componentName || prev.componentName,
      vendor: v,
      changedBy: "Engineering Head",
      field: changeType || "Shopfloor Parameter Tuning",
      changesList: changesList.length > 0 ? changesList : [{ parameter: "Spec Update", oldVal: "Base", newVal: "Running", diff: "Updated" }],
      costImpact: { oldCost: 11.84, newCost: 11.84, diff: 0.00 },
      reason: reason || "Internal parameter optimization"
    });

    notifyStore();
  }
};

export const onboardVendorWithBlueprint = ({ vendorName, vendorCode, paymentTerms, blueprintLines, initialProduct }) => {
  const vId = vendorName.trim();
  if (!globalStore.vendors.find(v => v.vendorId.toLowerCase() === vId.toLowerCase())) {
    globalStore.vendors.push({
      vendorId: vId,
      vendorName,
      code: (vendorCode || vId.substring(0, 4)).toUpperCase(),
      paymentTerms: paymentTerms || "45 Days",
      active: true,
      lineCount: (blueprintLines || []).length
    });
  }

  globalStore.vendorBlueprints[vId] = blueprintLines || [];
  if (!globalStore.vendorBaselines[vId]) {
    globalStore.vendorBaselines[vId] = [];
  }

  if (initialProduct) {
    const formatted = {
      id: `BL-${vId.toUpperCase()}-${Date.now()}`,
      vendor: vId,
      itemCode: initialProduct.itemCode || 'PART-001',
      componentName: initialProduct.componentName || 'Sample Component',
      model: initialProduct.model || 'Platform Standard',
      mouldSize: initialProduct.mouldSize || '950*600*450',
      approvedRm: initialProduct.approvedRm || 'PP H110MA',
      approvedRmRate: Number(initialProduct.approvedRmRate || 140.00),
      masterbatchPct: Number(initialProduct.masterbatchPct || 4.0),
      masterbatchRate: Number(initialProduct.masterbatchRate || 254.00),
      bopCost: Number(initialProduct.bopCost || 0.0),
      cavity: Number(initialProduct.cavity || 2),
      netWeight: Number(initialProduct.netWeight || 37.0),
      runnerWeight: Number(initialProduct.runnerWeight || 1.0),
      cycleTimeApproved: Number(initialProduct.cycleTimeApproved || 47.0),
      cycleTime: Number(initialProduct.cycleTimeApproved || 47.0),
      machineTonnage: Number(initialProduct.machineTonnage || 200),
      hourlyRate: Number(initialProduct.hourlyRate || 250),
      validFrom: initialProduct.validFrom || "2026-08-01",
      parameters: {
        cavity: Number(initialProduct.cavity || 2),
        netWeightApproved: Number(initialProduct.netWeight || 37.0),
        runnerWeight: Number(initialProduct.runnerWeight || 1.0),
        cycleTimeApproved: Number(initialProduct.cycleTimeApproved || 47.0),
        machineTonnage: Number(initialProduct.machineTonnage || 200),
        shiftTariff: 2000,
        bopCost: Number(initialProduct.bopCost || 0.0),
        masterbatchPct: Number(initialProduct.masterbatchPct || 4.0)
      }
    };

    const existingIdx = globalStore.vendorBaselines[vId].findIndex(p => p.itemCode === formatted.itemCode);
    if (existingIdx >= 0) {
      globalStore.vendorBaselines[vId][existingIdx] = formatted;
    } else {
      globalStore.vendorBaselines[vId].push(formatted);
    }
  }

  syncMasterBaselineList();
  notifyStore();
};

export const addVendorBaselineProducts = (vendor, newProducts) => {
  if (!globalStore.vendorBaselines[vendor]) globalStore.vendorBaselines[vendor] = [];
  globalStore.vendorBaselines[vendor] = [...newProducts, ...globalStore.vendorBaselines[vendor]];
  syncMasterBaselineList();
  notifyStore();
};

export const addManualPurchaseRecord = (record) => {
  globalStore.purchaseMaster.unshift({ code: `PUR-${Date.now()}`, ...record });
  notifyStore();
};

export const addManualSaleRecord = (record) => {
  globalStore.salesData.unshift({ id: `INV-SLS-${Date.now()}`, ...record });
  notifyStore();
};

export const uploadBulkPurchases = (newPurchases) => {
  globalStore.purchaseMaster = [...newPurchases, ...(globalStore.purchaseMaster || [])];
  notifyStore();
};

export const uploadBulkSales = (newSales) => {
  globalStore.salesData = [...newSales, ...(globalStore.salesData || [])];
  notifyStore();
};

export default globalStore;
STORE_EOF

echo "==> 2. Writing Central Costing Calculation Service..."
cat << 'SERVICE_EOF' > src/shared/costCalculationService.js
import { getActiveRmMapping, getActiveMbMapping } from './masterStore';

export function calculateAtombergCost(p) {
  const rmBase = Number(p.rmBase ?? p.rmRate ?? 140.0);
  const rmIcc = rmBase * 0.01;
  const rmFreight = Number(p.rmFreight ?? 1.50);
  const rmLanded = rmBase + rmIcc + rmFreight;

  const mbBase = Number(p.mbBase ?? p.masterbatchRate ?? 254.0);
  const mbIcc = mbBase * 0.01;
  const mbFreight = Number(p.mbFreight ?? 2.00);
  const mbLanded = mbBase + mbIcc + mbFreight;

  const rawMbPct = Number(p.mbPct !== undefined ? p.mbPct : (p.masterbatchPct !== undefined ? p.masterbatchPct : 4.0));
  const mbPct = rawMbPct > 1 ? rawMbPct / 100 : rawMbPct;
  const rmCombRate = rmLanded * (1.0 - mbPct) + mbLanded * mbPct;

  const partWt = Number(p.partWt ?? p.netWeight ?? 37.0);
  const runnerWt = Number(p.runnerWt ?? p.runnerWeight ?? 1.0);
  const grossWt = partWt + runnerWt;

  const rmCost = (grossWt / 1000.0) * rmCombRate;
  const bopCost = Number(p.bopCost ?? 0.0);
  const rmBopCost = rmCost + bopCost;

  const tonnage = Number(p.tonnage ?? p.machineTonnage ?? 200.0);
  const shiftRate = 10.0 * tonnage;
  const cycleTime = Math.max(1, Number(p.cycleTime ?? p.cycleTimeApproved ?? 47.0));
  const efficiency = Number(p.efficiency ?? 0.90);
  const cavity = Math.max(1, Number(p.cavity ?? 2));

  const partsPerShift = (28800.0 / cycleTime) * efficiency * cavity;
  const processCost = partsPerShift > 0 ? (shiftRate / partsPerShift) : 0;

  const bopHandling = 0.03 * bopCost;
  const postOpCost = Number(p.postOpCost ?? 1.73);
  const totalProcessCost = processCost + bopHandling + postOpCost;

  const profitOh = (rmCost + totalProcessCost) * 0.12;
  const inprocessRejection = (rmBopCost + totalProcessCost) * 0.04;
  const runnerRecovery = -25.0 * (runnerWt / 1000.0);
  const icc = 0.0;
  const packingCost = Number(p.packingCost ?? 0.86);
  const transportCost = Number(p.transportCost ?? 0.62);
  const mouldMaint = 0.02 * totalProcessCost;

  const otherCost = profitOh + inprocessRejection + runnerRecovery + icc + packingCost + transportCost + mouldMaint;
  const finalLanded = rmBopCost + totalProcessCost + otherCost;

  return {
    rmBase, rmIcc, rmFreight, rmLanded,
    mbBase, mbIcc, mbFreight, mbLanded,
    mbPct, rmCombRate, partWt, runnerWt, grossWt,
    rmCost, bopCost, rmBopCost, tonnage, shiftRate,
    cycleTime, efficiency, cavity, partsPerShift,
    processCost, bopHandling, postOpCost, totalProcessCost,
    profitOh, inprocessRejection, runnerRecovery, icc,
    packingCost, transportCost, mouldMaint, otherCost,
    finalLanded, totalCost: finalLanded
  };
}

export function calculateHaierCost(params) {
  const cavity = Math.max(1, Number(params.cavity) || 1);
  const netWeight = Number(params.netWeight ?? params.partWt) || 0;
  const runnerWeight = Number(params.runnerWeight ?? params.runnerWt) || 0;
  const rmRate = Number(params.rmRate ?? params.rmBase) || 140.00;
  const mbPct = Number(params.masterbatchPct ?? params.mbPct) || 0;
  const mbRate = Number(params.masterbatchRate ?? params.mbBase) || (rmRate * 1.9);
  const cycleTime = Math.max(1, Number(params.cycleTime ?? params.cycleTimeApproved) || 48);
  const machineTonnage = Number(params.machineTonnage ?? params.tonnage) || 450;
  const shiftTariff = Number(params.shiftTariff || (machineTonnage >= 650 ? 5760 : (machineTonnage <= 200 ? 2000 : 4600)));

  const shotWeightPerPiece = ((netWeight * cavity) + runnerWeight) / cavity;
  const reconciliationWeight = shotWeightPerPiece * 1.01;

  const pureRmFraction = Math.max(0, 1 - (mbPct / 100));
  const mbFraction = mbPct / 100;
  const rawMaterialCost = (reconciliationWeight / 1000) * rmRate * pureRmFraction;
  const masterbatchCost = (reconciliationWeight / 1000) * mbRate * mbFraction;
  const runnerCredit = (runnerWeight / cavity / 1000) * (rmRate * 0.25);
  const totalRmCost = (rawMaterialCost + masterbatchCost) - runnerCredit;

  const partsPerShift = ((28800 / cycleTime) * cavity) * 0.90;
  const conversionCost = partsPerShift > 0 ? (shiftTariff / partsPerShift) : 0;
  const totalCost = totalRmCost + conversionCost;

  return {
    cavity, netWeight, runnerWeight, shotWeightPerPiece, reconciliationWeight,
    rawMaterialCost, masterbatchCost, runnerCredit, totalRmCost,
    shiftTariff, conversionCost, totalCost, finalLanded: totalCost
  };
}

export function calculatePieceCostUnified({ item, isBaseline = false, targetDate = null }) {
  const vendor = (item.vendor || 'Atomberg').trim();
  const isAtomberg = vendor.toLowerCase().includes('atomberg');
  const params = item.parameters || {};

  const rmMapping = getActiveRmMapping(item.approvedRm || 'PP H110MA', vendor, targetDate);
  const mbMapping = getActiveMbMapping(vendor, targetDate);

  if (isAtomberg) {
    if (isBaseline) {
      return calculateAtombergCost({
        vendor: 'Atomberg',
        rmBase: Number(rmMapping.approvedPrice || item.approvedRmRate || 140.00),
        mbBase: Number(mbMapping.approvedMbPrice || item.masterbatchRate || 254.00),
        rmFreight: 1.50,
        mbFreight: 2.00,
        mbPct: Number(item.masterbatchPct ?? params.masterbatchPct ?? 4.0),
        partWt: Number(item.netWeight ?? params.netWeightApproved ?? 37.0),
        runnerWt: Number(item.runnerWeight ?? params.runnerWeight ?? 1.0),
        bopCost: Number(item.bopCost || params.bopCost || 0.0),
        tonnage: Number(item.machineTonnage ?? params.machineTonnage ?? 200.0),
        cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 47.0),
        efficiency: 0.90,
        cavity: Number(item.cavity ?? params.cavity ?? 2),
        postOpCost: 1.73,
        packingCost: 0.86,
        transportCost: 0.62
      });
    } else {
      return calculateAtombergCost({
        vendor: 'Atomberg',
        rmBase: Number(rmMapping.activeWaPrice || 135.83),
        mbBase: Number(mbMapping.activeMbPrice || 258.54),
        rmFreight: 1.50,
        mbFreight: 2.00,
        mbPct: Number(params.runningMbPct !== undefined ? params.runningMbPct : (item.masterbatchPct ?? 4.0)),
        partWt: Number(params.runningNetWeight ?? item.netWeight ?? 37.0),
        runnerWt: Number(params.runningRunnerWeight ?? item.runnerWeight ?? 1.0),
        bopCost: Number(params.runningBopCost ?? item.bopCost ?? 0.0),
        tonnage: Number(params.runningTonnage ?? item.machineTonnage ?? 200.0),
        cycleTime: Number(params.runningCycleTime ?? item.cycleTimeApproved ?? 47.0),
        efficiency: 0.90,
        cavity: Number(params.runningCavity ?? item.cavity ?? 2),
        postOpCost: 1.73,
        packingCost: 0.86,
        transportCost: 0.62
      });
    }
  } else {
    if (isBaseline) {
      return calculateHaierCost({
        cavity: Number(item.cavity || 2),
        netWeight: Number(item.netWeight || 197),
        runnerWeight: Number(item.runnerWeight || 40),
        rmRate: Number(rmMapping.approvedPrice || item.approvedRmRate || 140.00),
        masterbatchPct: Number(item.masterbatchPct || 0),
        masterbatchRate: Number(item.masterbatchRate || 0),
        machineTonnage: Number(item.machineTonnage || 450),
        shiftTariff: Number(item.hourlyRate ? item.hourlyRate * 8 : 4600),
        cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 48)
      });
    } else {
      return calculateHaierCost({
        cavity: Number(params.runningCavity ?? item.cavity ?? 2),
        netWeight: Number(params.runningNetWeight ?? item.netWeight ?? 197),
        runnerWeight: Number(params.runningRunnerWeight ?? item.runnerWeight ?? 40),
        rmRate: Number(rmMapping.activeWaPrice || 134.80),
        masterbatchPct: Number(params.runningMbPct ?? item.masterbatchPct ?? 0),
        masterbatchRate: Number(item.masterbatchRate || 0),
        machineTonnage: Number(params.runningTonnage ?? item.machineTonnage ?? 450),
        shiftTariff: Number(params.runningShiftTariff ?? 4600),
        cycleTime: Number(params.runningCycleTime ?? item.cycleTimeApproved ?? 48)
      });
    }
  }
}

export function calculateDetailedCost(params, isBaseline = false) {
  if ((params.vendor || '').toLowerCase().includes('atomberg')) {
    return calculateAtombergCost(params);
  }
  return calculateHaierCost(params);
}
SERVICE_EOF

echo "==> 3. Writing MIS Intelligence Page..."
cat << 'MIS_PAGE_EOF' > src/modules/module4-mis/MISIntelligencePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Search, Calendar, 
  Eye, FileSpreadsheet, Layers, ShieldCheck, CheckCircle2 
} from 'lucide-react';
import { globalStore, subscribeStore, getVendorBaselineData } from '../../shared/masterStore';
import { calculatePieceCostUnified } from '../../shared/costCalculationService';

export default function MISIntelligencePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [fromDate, setFromDate] = useState('2026-08-01');
  const [toDate, setToDate] = useState('2026-08-31');

  const rawBaselineList = getVendorBaselineData(selectedVendor === 'ALL' ? 'ALL' : selectedVendor);

  const salesData = (globalStore.salesData || []).filter(s => {
    const vMatch = selectedVendor === 'ALL' || s.vendor === selectedVendor;
    const dMatch = (!fromDate || s.invoiceDate >= fromDate) && (!toDate || s.invoiceDate <= toDate);
    return vMatch && dMatch;
  });

  const analyzedRows = useMemo(() => {
    return salesData.map(sale => {
      const part = rawBaselineList.find(p => p.itemCode === sale.itemCode) || {
        vendor: sale.vendor,
        itemCode: sale.itemCode,
        componentName: sale.componentName,
        approvedRm: sale.vendor === 'Atomberg' ? 'PP H110MA' : 'ABS 300 Pre Colour'
      };

      const baseResult = calculatePieceCostUnified({
        item: { ...part, vendor: sale.vendor },
        isBaseline: true,
        targetDate: sale.invoiceDate
      });

      const actualResult = calculatePieceCostUnified({
        item: { ...part, vendor: sale.vendor },
        isBaseline: false,
        targetDate: sale.invoiceDate
      });

      const contractBaseline = Number(baseResult.finalLanded.toFixed(2));
      const actualUnitCost = Number(actualResult.finalLanded.toFixed(2));

      const unitDelta = Number((contractBaseline - actualUnitCost).toFixed(2));
      const totalDelta = Number((unitDelta * sale.saleUnit).toFixed(2));
      const totalSales = Number((sale.sellingPrice * sale.saleUnit).toFixed(2));
      const totalActualCost = Number((actualUnitCost * sale.saleUnit).toFixed(2));
      const grossMarginAmt = Number((totalSales - totalActualCost).toFixed(2));

      return {
        ...sale,
        contractBaseline,
        actualUnitCost,
        unitDelta,
        totalDelta,
        totalSales,
        grossMarginAmt
      };
    });
  }, [salesData, rawBaselineList, selectedVendor]);

  const summary = useMemo(() => {
    const totalVolume = analyzedRows.reduce((a, b) => a + (b.saleUnit || 0), 0);
    const totalRevenue = analyzedRows.reduce((a, b) => a + (b.totalSales || 0), 0);
    const totalCostDelta = analyzedRows.reduce((a, b) => a + (b.totalDelta || 0), 0);
    const totalGrossProfit = analyzedRows.reduce((a, b) => a + (b.grossMarginAmt || 0), 0);
    const grossProfitPct = totalRevenue > 0 ? ((totalGrossProfit / totalRevenue) * 100).toFixed(1) : '0.0';

    return {
      totalVolume,
      totalRevenue,
      totalCostDelta,
      totalGrossProfit,
      grossProfitPct
    };
  }, [analyzedRows]);

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <BarChart3 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">4. Vendor & Product Sales P&L MIS Intelligence</h1>
            <p className="text-[11px] text-slate-300">Synchronized Piece Costing Variance Engine</p>
          </div>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700">VENDOR:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors Combined</option>
            </select>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 border rounded-xl px-3 py-1 text-slate-700">
            <Calendar className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-[11px]">PERIOD:</span>
            <input type="date" value={fromDate} onChange={e => setFromDate(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs" />
            <span>&rarr;</span>
            <input type="date" value={toDate} onChange={e => setToDate(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs" />
          </div>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Period Sales Volume</span>
          <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">{summary.totalVolume.toLocaleString()} pcs</span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Total Sales Revenue</span>
          <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{summary.totalRevenue.toLocaleString('en-IN')}</span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Gross Profit & Margin</span>
          <span className="text-2xl font-black text-emerald-900 font-mono mt-1 block">
            ₹{summary.totalGrossProfit.toLocaleString('en-IN')} <span className="text-xs font-bold text-emerald-700">({summary.grossProfitPct}%)</span>
          </span>
        </div>

        <div className={`border rounded-2xl p-4 shadow-xs ${summary.totalCostDelta >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
          <div className="flex justify-between items-center">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-600">Cost Variance Gain / Loss</span>
            {summary.totalCostDelta >= 0 ? <TrendingUp className="w-4 h-4 text-emerald-600" /> : <TrendingDown className="w-4 h-4 text-rose-600" />}
          </div>
          <span className={`text-2xl font-black font-mono mt-1 block ${summary.totalCostDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {summary.totalCostDelta >= 0 ? `₹ +${summary.totalCostDelta.toLocaleString('en-IN')}` : `₹ -${Math.abs(summary.totalCostDelta).toLocaleString('en-IN')}`}
          </span>
        </div>
      </div>

      {/* Product Realization Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
          <h2 className="text-sm font-bold flex items-center gap-2">
            <FileSpreadsheet className="w-4 h-4 text-blue-400" /> Product Sales Realization & Costing Analysis
          </h2>
          <span className="text-[11px] text-slate-300 font-mono">{analyzedRows.length} Dispatch Invoices</span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
              <tr>
                <th className="p-3">Date</th>
                <th className="p-3">Part Code</th>
                <th className="p-3">Component Name</th>
                <th className="p-3 text-center">Vendor</th>
                <th className="p-3 text-right">Qty Sold</th>
                <th className="p-3 text-right">Selling Price</th>
                <th className="p-3 text-right bg-amber-50 font-bold">Contract Baseline</th>
                <th className="p-3 text-right bg-blue-50 font-bold">Actual Unit Cost</th>
                <th className="p-3 text-right bg-yellow-100/70 font-black">Profit / Loss (Δ)</th>
                <th className="p-3 text-right bg-cyan-100/70 font-black">Total Profit / Loss (Δ)</th>
                <th className="p-3 text-right bg-orange-100/70 font-black">Total Sales</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {analyzedRows.map((row) => (
                <tr key={row.id} className="hover:bg-slate-50">
                  <td className="p-3 font-mono text-slate-500">{row.invoiceDate}</td>
                  <td className="p-3 font-mono font-bold text-blue-700">{row.itemCode}</td>
                  <td className="p-3 font-semibold text-slate-900">{row.componentName}</td>
                  <td className="p-3 text-center font-bold text-slate-700">{row.vendor}</td>
                  <td className="p-3 text-right font-mono font-bold">{row.saleUnit.toLocaleString()}</td>
                  <td className="p-3 text-right font-mono font-bold">₹{row.sellingPrice.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-black text-slate-900 bg-amber-50/50">₹{row.contractBaseline.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-black text-blue-950 bg-blue-50/50">₹{row.actualUnitCost.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-black bg-yellow-50">
                    <span className={row.unitDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}>
                      {row.unitDelta >= 0 ? `₹ +${row.unitDelta.toFixed(2)}` : `₹ -${Math.abs(row.unitDelta).toFixed(2)}`}
                    </span>
                  </td>
                  <td className="p-3 text-right font-mono font-black bg-cyan-50">
                    <span className={row.totalDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}>
                      {row.totalDelta >= 0 ? `₹ +${row.totalDelta.toLocaleString('en-IN')}` : `₹ -${Math.abs(row.totalDelta).toLocaleString('en-IN')}`}
                    </span>
                  </td>
                  <td className="p-3 text-right font-mono font-black text-slate-900 bg-orange-50">
                    ₹{row.totalSales.toLocaleString('en-IN')}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
MIS_PAGE_EOF

echo "==> 4. Clearing Vite Cache and Restarting Server on 5173..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true

nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 3
echo "✓ Vite Server restarted cleanly in background on port 5173."
