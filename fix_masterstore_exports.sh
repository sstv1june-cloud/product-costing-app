#!/usr/bin/env bash
set -e

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

  vendorBlueprints: {
    Atomberg: [],
    Haier: []
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

echo "==> MasterStore exports and full vendor sync completed."
