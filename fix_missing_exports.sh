#!/usr/bin/env bash
set -e

cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';
import { calculateDetailedCost } from '../modules/module1-baseline/InlineEditModal';

const initialData = Array.isArray(initialBaselineData) ? initialBaselineData : [];

// 38-line standard blueprint for Haier
export const haierBlueprint = [
  { lineNo: 1, description: "Name Of Component", uom: "-", type: "text", mapping: "componentName", isHeader: true },
  { lineNo: 2, description: "Mould Size L * W * H", uom: "mm", type: "text", mapping: "mouldSize", isHeader: true },
  { lineNo: 3, description: "Item No. / Code", uom: "-", type: "text", mapping: "itemCode", isHeader: true },
  { lineNo: 4, description: "Model", uom: "-", type: "text", mapping: "model", isHeader: true },
  { lineNo: 5, description: "Raw Material Required (Locked & Linked to RM Sheet)", uom: "-", type: "text", mapping: "approvedRm", isRm: true },
  { lineNo: 6, description: "Master Batch Required", uom: "%", type: "number", mapping: "masterbatchPct", isParam: true },
  { lineNo: 7, description: "No. of Cavity", uom: "Nos", type: "number", mapping: "cavity", isParam: true },
  { lineNo: 8, description: "Runner Weight", uom: "Gms", type: "number", mapping: "runnerWeight", isParam: true },
  { lineNo: 9, description: "Net Weight", uom: "Gms", type: "number", mapping: "netWeight", isParam: true },
  { lineNo: 10, description: "Shot Weight (Calculated)", uom: "Gms", type: "calc", isFormula: true },
  { lineNo: 11, description: "Reconciliation Weight (Shot wt + 1.0% Melt Loss)", uom: "Gms", type: "calc", isFormula: true },
  { lineNo: 12, description: "Raw Material Cost", uom: "₹", type: "calc", isFormula: true },
  { lineNo: 13, description: "Master Batch Cost", uom: "₹", type: "calc", isFormula: true },
  { lineNo: 14, description: "Runner Recovery Credit", uom: "₹", type: "calc", isFormula: true },
  { lineNo: 15, description: "TOTAL RAW MATERIAL COST", uom: "₹", type: "total", isTotal: true },
  { lineNo: 16, description: "Cycle Time Approved", uom: "Sec", type: "number", mapping: "cycleTimeApproved", isParam: true },
  { lineNo: 17, description: "Hourly Shift Machine Tariff", uom: "₹/hr", type: "number", mapping: "hourlyRate", isParam: true },
  { lineNo: 18, description: "Machine Tonnage", uom: "T", type: "number", mapping: "machineTonnage", isParam: true },
  { lineNo: 19, description: "Conversion Cost / Piece", uom: "₹", type: "calc", isFormula: true },
  { lineNo: 20, description: "TOTAL COMPONENT BASELINE COST", uom: "₹", type: "total", isTotal: true }
];

export const defaultCostingLines = haierBlueprint;

export const lgBlueprint = [
  { lineNo: 1, description: "Name Of Component", uom: "-", type: "text", mapping: "componentName", isHeader: true },
  { lineNo: 2, description: "LG Part Number", uom: "-", type: "text", mapping: "itemCode", isHeader: true },
  { lineNo: 3, description: "Appliance Model", uom: "-", type: "text", mapping: "model", isHeader: true },
  { lineNo: 4, description: "Polymer Specification", uom: "-", type: "text", mapping: "approvedRm", isRm: true },
  { lineNo: 5, description: "Tool Cavity", uom: "Nos", type: "number", mapping: "cavity", isParam: true },
  { lineNo: 6, description: "Part Net Weight", uom: "Gms", type: "number", mapping: "netWeight", isParam: true },
  { lineNo: 7, description: "Runner Weight", uom: "Gms", type: "number", mapping: "runnerWeight", isParam: true },
  { lineNo: 8, description: "Cycle Time (Sec)", uom: "Sec", type: "number", mapping: "cycleTimeApproved", isParam: true },
  { lineNo: 9, description: "Machine Tonnage", uom: "T", type: "number", mapping: "machineTonnage", isParam: true }
];

export const whirlpoolBlueprint = [
  { lineNo: 1, description: "Part Name", uom: "-", type: "text", mapping: "componentName", isHeader: true },
  { lineNo: 2, description: "WP Part Code", uom: "-", type: "text", mapping: "itemCode", isHeader: true },
  { lineNo: 3, description: "Raw Material Grade", uom: "-", type: "text", mapping: "approvedRm", isRm: true },
  { lineNo: 4, description: "Cavity Count", uom: "Nos", type: "number", mapping: "cavity", isParam: true },
  { lineNo: 5, description: "Component Weight", uom: "Gms", type: "number", mapping: "netWeight", isParam: true },
  { lineNo: 6, description: "Runner Scrap Wt", uom: "Gms", type: "number", mapping: "runnerWeight", isParam: true },
  { lineNo: 7, description: "Standard Cycle Time", uom: "Sec", type: "number", mapping: "cycleTimeApproved", isParam: true }
];

export const globalStore = {
  vendors: [
    { vendorId: "Haier", vendorName: "Haier Appliances", code: "HAIER", paymentTerms: "60 to 45 Days", active: true, lineCount: 38 },
    { vendorId: "LG", vendorName: "LG Electronics", code: "LG", paymentTerms: "45 Days", active: true, lineCount: 9 },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India", code: "WHIRLPOOL", paymentTerms: "60 Days", active: true, lineCount: 7 }
  ],

  vendorBlueprints: {
    Haier: haierBlueprint,
    LG: lgBlueprint,
    Whirlpool: whirlpoolBlueprint
  },

  vendorBaselines: {
    Haier: initialData.filter(d => (d.vendor || 'Haier') === 'Haier'),
    LG: initialData.filter(d => d.vendor === 'LG'),
    Whirlpool: initialData.filter(d => d.vendor === 'Whirlpool')
  },

  baselineList: initialData,

  purchaseMaster: [
    { code: "PUR-ABS-01", invoiceNo: "INV-PUR-8821", name: "ABS 300-B Red (Prime Inward)", polymer: "ABS", supplier: "Supreme Petrochem", waPrice: 134.80, inwardDate: "2026-08-01", qtyKg: 12500 },
    { code: "PUR-ABS-02", invoiceNo: "INV-PUR-8822", name: "ABS 300-Blue (Imported)", polymer: "ABS", supplier: "Chi Mei", waPrice: 131.25, inwardDate: "2026-08-05", qtyKg: 8200 },
    { code: "PUR-GPPS-01", invoiceNo: "INV-PUR-8824", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", polymer: "GPPS", supplier: "Supreme", waPrice: 98.40, inwardDate: "2026-08-03", qtyKg: 9000 }
  ],

  salesData: [
    { id: "INV-SLS-001", invoiceNo: "INV-SLS-001", itemCode: "0060226713H", componentName: "End Cap Top Ref (without Screen Painting )", vendor: "Haier", saleUnit: 4500, invoiceDate: "2026-08-05", sellingPrice: 38.50 },
    { id: "INV-SLS-002", invoiceNo: "INV-SLS-002", itemCode: "0060217989D", componentName: "End cap Bottom Ref-ABS-DC-195,220", vendor: "Haier", saleUnit: 4200, invoiceDate: "2026-08-10", sellingPrice: 42.00 },
    { id: "INV-SLS-003", invoiceNo: "INV-SLS-003", itemCode: "0060217978E", componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX", vendor: "Haier", saleUnit: 1800, invoiceDate: "2026-08-12", sellingPrice: 85.00 }
  ],

  rmMatrix: [
    {
      id: "RM-HAIER-ABS-P1",
      vendor: "Haier",
      approvedRm: "ABS 300 Pre Colour",
      polymer: "ABS",
      approvedPrice: 136.20,
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

  parameterChangeLogs: [
    {
      id: "LOG-PARAM-001",
      timestamp: "2026-08-19 06:37:43",
      itemCode: "0060217989D",
      componentName: "End cap Bottom Ref-ABS-DC-195,220",
      vendor: "Haier",
      changedBy: "Engineering Head",
      field: "Cycle Time & Runner Tuning",
      changesList: [
        { parameter: "Cycle Time", oldVal: "48.0 s", newVal: "40.0 s", diff: "-8.0 s" },
        { parameter: "Runner Weight", oldVal: "40.0 g", newVal: "45.0 g", diff: "+5.0 g" }
      ],
      costImpact: { oldCost: 36.28, newCost: 36.14, diff: -0.14 },
      reason: "Internal parameter optimization"
    }
  ],
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

export const getVendorBaselineData = (vendor) => {
  if (vendor === 'ALL') {
    syncMasterBaselineList();
    return globalStore.baselineList;
  }
  return globalStore.vendorBaselines[vendor] || [];
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
      lineCount: blueprintLines.length
    });
  }

  globalStore.vendorBlueprints[vId] = blueprintLines;

  if (!globalStore.vendorBaselines[vId]) {
    globalStore.vendorBaselines[vId] = [];
  }

  if (initialProduct) {
    const formatted = {
      id: `PROD-${vId}-${Date.now()}`,
      vendor: vId,
      itemCode: initialProduct.itemCode || 'PART-001',
      componentName: initialProduct.componentName || 'Sample Component',
      model: initialProduct.model || 'Platform Standard',
      mouldSize: initialProduct.mouldSize || '1000*600*500',
      approvedRm: initialProduct.approvedRm || 'ABS Prime Grade',
      cavity: Number(initialProduct.cavity || 2),
      netWeight: Number(initialProduct.netWeight || 150),
      runnerWeight: Number(initialProduct.runnerWeight || 30),
      cycleTimeApproved: Number(initialProduct.cycleTimeApproved || 42),
      cycleTime: Number(initialProduct.cycleTimeApproved || 42),
      machineTonnage: Number(initialProduct.machineTonnage || 350),
      hourlyRate: Number(initialProduct.hourlyRate || 400),
      validFrom: new Date().toISOString().slice(0, 10),
      parameters: {
        cavity: Number(initialProduct.cavity || 2),
        netWeightApproved: Number(initialProduct.netWeight || 150),
        runnerWeight: Number(initialProduct.runnerWeight || 30),
        cycleTimeApproved: Number(initialProduct.cycleTimeApproved || 42),
        machineTonnage: Number(initialProduct.machineTonnage || 350),
        shiftTariff: (Number(initialProduct.machineTonnage || 350) >= 600 ? 4800 : 3600)
      }
    };
    globalStore.vendorBaselines[vId].push(formatted);

    globalStore.rmMatrix.push({
      id: `RM-${vId}-${Date.now()}`,
      vendor: vId,
      approvedRm: formatted.approvedRm,
      polymer: "ABS",
      approvedPrice: Number(initialProduct.approvedRmRate || 135.00),
      validFrom: "2026-08-01",
      validTo: "2026-08-31",
      activeSelection: "alt1",
      alt1: { code: "PUR-ABS-01", name: `${formatted.approvedRm} Inward Standard`, waPrice: Number(initialProduct.approvedRmRate || 135.00) }
    });
  }

  syncMasterBaselineList();
  notifyStore();
};

export const addVendorBaselineProducts = (vendor, newProducts) => {
  if (!globalStore.vendorBaselines[vendor]) {
    globalStore.vendorBaselines[vendor] = [];
  }
  
  const formatted = newProducts.map((p, idx) => ({
    id: p.id || `PROD-${vendor}-${Date.now()}-${idx}`,
    vendor,
    itemCode: p.itemCode,
    componentName: p.componentName,
    model: p.model || 'Standard',
    mouldSize: p.mouldSize || '1070*720*650',
    approvedRm: p.approvedRm || 'ABS 300 Pre Colour',
    cavity: Number(p.cavity || 2),
    netWeight: Number(p.netWeight || 197),
    runnerWeight: Number(p.runnerWeight || 40),
    cycleTimeApproved: Number(p.cycleTimeApproved || 48),
    cycleTime: Number(p.cycleTimeApproved || 48),
    machineTonnage: Number(p.machineTonnage || 450),
    hourlyRate: Number(p.hourlyRate || 450),
    validFrom: p.validFrom || new Date().toISOString().slice(0, 10),
    parameters: {
      cavity: Number(p.cavity || 2),
      netWeightApproved: Number(p.netWeight || 197),
      runnerWeight: Number(p.runnerWeight || 40),
      cycleTimeApproved: Number(p.cycleTimeApproved || 48),
      machineTonnage: Number(p.machineTonnage || 450),
      shiftTariff: (Number(p.machineTonnage || 450) >= 600 ? 4800 : 3600)
    }
  }));

  globalStore.vendorBaselines[vendor] = [...formatted, ...globalStore.vendorBaselines[vendor]];
  syncMasterBaselineList();
  notifyStore();
};

export const getActiveRmMapping = (approvedRmName, vendor = "Haier", targetDate = null) => {
  const vKey = (vendor || "Haier").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey &&
    (r.approvedRm.toLowerCase() === (approvedRmName || "").toLowerCase() ||
     (approvedRmName || "").toLowerCase().includes(r.polymer?.toLowerCase()))
  );

  let row = rows[0];
  if (targetDate && rows.length > 0) {
    const matched = rows.find(r => targetDate >= r.validFrom && targetDate <= r.validTo);
    if (matched) row = matched;
  }

  if (!row) {
    return {
      vendor: vendor || "Haier",
      approvedRm: approvedRmName || "Standard Polymer",
      approvedPrice: 136.20,
      activeRmName: approvedRmName || "Standard Polymer",
      activeWaPrice: 136.20,
      validFrom: "2026-08-01",
      validTo: "2026-08-31"
    };
  }

  let activeRmName = row.approvedRm;
  let activeWaPrice = row.approvedPrice;

  if (row.activeSelection === 'alt1' && row.alt1) {
    activeRmName = row.alt1.name;
    activeWaPrice = row.alt1.waPrice;
  } else if (row.activeSelection === 'alt2' && row.alt2) {
    activeRmName = row.alt2.name;
    activeWaPrice = row.alt2.waPrice;
  } else if (row.activeSelection === 'alt3' && row.alt3) {
    activeRmName = row.alt3.name;
    activeWaPrice = row.alt3.waPrice;
  }

  return {
    vendor: row.vendor,
    approvedRm: row.approvedRm,
    approvedPrice: row.approvedPrice,
    validFrom: row.validFrom,
    validTo: row.validTo,
    activeSelection: row.activeSelection,
    activeRmName,
    activeWaPrice,
    alt1: row.alt1,
    alt2: row.alt2,
    alt3: row.alt3
  };
};

export const updateVendorScheduleBulk = (vendor, validFrom, validTo, updatedRows) => {
  const previousRows = (globalStore.rmMatrix || []).filter(r => r.vendor === vendor);

  globalStore.rmMatrix = globalStore.rmMatrix.map(row => {
    if (row.vendor === vendor) {
      const match = updatedRows.find(u => u.id === row.id);
      return match ? { ...match, validFrom, validTo } : { ...row, validFrom, validTo };
    }
    return row;
  });

  updatedRows.forEach(uRow => {
    const prev = previousRows.find(p => p.id === uRow.id);
    let altText = uRow.activeSelection === 'alt1' ? `Alternate 1 (${uRow.alt1?.name || ''})` : 
                  uRow.activeSelection === 'alt2' ? `Alternate 2 (${uRow.alt2?.name || ''})` : 
                  uRow.activeSelection === 'alt3' ? `Alternate 3 (${uRow.alt3?.name || ''})` : 'Primary Approved';

    const priceChanged = Math.abs((prev?.approvedPrice || 0) - (uRow.approvedPrice || 0)) >= 0.01;
    const note = priceChanged 
      ? `Approved price updated from ₹${(prev?.approvedPrice || uRow.approvedPrice).toFixed(2)} to ₹${uRow.approvedPrice.toFixed(2)} for period (${validFrom} to ${validTo})`
      : `Locked period (${validFrom} to ${validTo}) with ${altText}`;

    globalStore.rmPriceHistoryLogs.unshift({
      id: `LOG-RM-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      vendor,
      rmGrade: uRow.approvedRm,
      action: priceChanged ? "Approved Price & Period Updated" : "Schedule Locked",
      period: `${validFrom} to ${validTo}`,
      previousRate: prev?.approvedPrice || uRow.approvedPrice,
      newRate: uRow.approvedPrice,
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

    const oldCycle = Number(prev.cycleTimeApproved ?? prev.cycleTime ?? 48);
    const newCycle = Number(newParams.runningCycleTime ?? updatedItem.cycleTimeApproved ?? updatedItem.cycleTime ?? oldCycle);
    if (Math.abs(oldCycle - newCycle) >= 0.01) {
      const d = Number((newCycle - oldCycle).toFixed(1));
      changesList.push({ parameter: "Cycle Time", oldVal: `${oldCycle} s`, newVal: `${newCycle} s`, diff: `${d > 0 ? '+' : ''}${d} s` });
    }

    const oldRunner = Number(prev.runnerWeight ?? prevParams.runnerWeight ?? 40);
    const newRunner = Number(newParams.runningRunnerWeight ?? updatedItem.runnerWeight ?? oldRunner);
    if (Math.abs(oldRunner - newRunner) >= 0.01) {
      const d = Number((newRunner - oldRunner).toFixed(1));
      changesList.push({ parameter: "Runner Weight", oldVal: `${oldRunner} g`, newVal: `${newRunner} g`, diff: `${d > 0 ? '+' : ''}${d} g` });
    }

    const oldNet = Number(prev.netWeight ?? prevParams.netWeightApproved ?? 197);
    const newNet = Number(newParams.runningNetWeight ?? updatedItem.netWeight ?? oldNet);
    if (Math.abs(oldNet - newNet) >= 0.01) {
      const d = Number((newNet - oldNet).toFixed(1));
      changesList.push({ parameter: "Net Weight", oldVal: `${oldNet} g`, newVal: `${newNet} g`, diff: `${d > 0 ? '+' : ''}${d} g` });
    }

    const oldTonnage = Number(prev.machineTonnage ?? prevParams.machineTonnage ?? 450);
    const newTonnage = Number(newParams.runningTonnage ?? updatedItem.machineTonnage ?? oldTonnage);
    if (oldTonnage !== newTonnage) {
      const d = newTonnage - oldTonnage;
      changesList.push({ parameter: "Machine Tonnage", oldVal: `${oldTonnage} T`, newVal: `${newTonnage} T`, diff: `${d > 0 ? '+' : ''}${d} T` });
    }

    const rmMapping = getActiveRmMapping(prev.approvedRm, prev.vendor, '2026-08-01');
    const baselineCalc = calculateDetailedCost({
      cavity: Number(prev.cavity ?? prevParams.cavity ?? 2),
      netWeight: oldNet,
      runnerWeight: oldRunner,
      rmRate: rmMapping.approvedPrice || 136.20,
      masterbatchPct: 0,
      masterbatchRate: 0,
      machineTonnage: oldTonnage,
      shiftTariff: Number(prev.hourlyRate ? prev.hourlyRate * 8 : 3600),
      cycleTime: oldCycle
    }, true);

    const runningCalc = calculateDetailedCost({
      cavity: Number(newParams.runningCavity ?? baselineCalc.cavity ?? 2),
      netWeight: newNet,
      runnerWeight: newRunner,
      rmRate: rmMapping.activeWaPrice || 134.80,
      masterbatchPct: 0,
      masterbatchRate: 0,
      machineTonnage: newTonnage,
      shiftTariff: Number(newParams.runningShiftTariff ?? (newTonnage >= 600 ? 4800 : 3600)),
      cycleTime: newCycle
    }, false);

    const oldCost = Number(baselineCalc.totalCost.toFixed(2));
    const newCost = Number(runningCalc.totalCost.toFixed(2));
    const costDelta = Number((newCost - oldCost).toFixed(2));

    globalStore.baselineList[idx] = {
      ...prev,
      ...updatedItem,
      parameters: {
        ...prevParams,
        ...newParams
      },
      validFrom: newValidFrom || prev.validFrom
    };

    const v = prev.vendor || 'Haier';
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
      costImpact: { oldCost, newCost, diff: costDelta },
      reason: reason || "Internal parameter optimization"
    });

    notifyStore();
  }
};

// Re-export missing helpers required by RMPriceMatrixPage
export const addManualPurchaseRecord = (record) => {
  globalStore.purchaseMaster.unshift({
    code: `PUR-${Date.now()}`,
    ...record
  });
  notifyStore();
};

export const addManualSaleRecord = (record) => {
  globalStore.salesData.unshift({
    id: `INV-SLS-${Date.now()}`,
    ...record
  });
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

echo "==> All missing exports restored."
