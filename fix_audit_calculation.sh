#!/usr/bin/env bash
set -e

# Update updateBaselineParameters in masterStore.js to evaluate full 38-line calculation
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';
import { calculateDetailedCost } from '../modules/module1-baseline/InlineEditModal';

const initialData = Array.isArray(initialBaselineData) ? initialBaselineData : [];

export const defaultVendorSchemas = {
  Haier: [
    { key: "itemCode", label: "Item Code / Part No", uom: "-", type: "text", required: true },
    { key: "componentName", label: "Name Of Component", uom: "-", type: "text", required: true },
    { key: "model", label: "Model", uom: "-", type: "text", required: true },
    { key: "mouldSize", label: "Mould Size L*W*H", uom: "mm", type: "text", required: false },
    { key: "approvedRm", label: "Approved RM Grade", uom: "-", type: "text", required: true },
    { key: "cavity", label: "No. of Cavity", uom: "Nos", type: "number", required: true },
    { key: "netWeight", label: "Net Weight", uom: "Gms", type: "number", required: true },
    { key: "runnerWeight", label: "Runner Weight", uom: "Gms", type: "number", required: true },
    { key: "cycleTimeApproved", label: "Cycle Time Approved", uom: "Sec", type: "number", required: true },
    { key: "machineTonnage", label: "Machine Tonnage", uom: "T", type: "number", required: true },
    { key: "hourlyRate", label: "Hourly Shift Tariff", uom: "₹/hr", type: "number", required: false }
  ],
  LG: [
    { key: "itemCode", label: "LG Part Number", uom: "-", type: "text", required: true },
    { key: "componentName", label: "Part Description", uom: "-", type: "text", required: true },
    { key: "model", label: "Appliance Model", uom: "-", type: "text", required: true },
    { key: "approvedRm", label: "Polymer Specification", uom: "-", type: "text", required: true },
    { key: "cavity", label: "Tool Cavity", uom: "Nos", type: "number", required: true },
    { key: "netWeight", label: "Part Net Wt", uom: "Gms", type: "number", required: true },
    { key: "runnerWeight", label: "Runner Wt", uom: "Gms", type: "number", required: true },
    { key: "cycleTimeApproved", label: "Cycle Time (Sec)", uom: "Sec", type: "number", required: true },
    { key: "machineTonnage", label: "Tonnage (Ton)", uom: "T", type: "number", required: true }
  ],
  Whirlpool: [
    { key: "itemCode", label: "WP Part Code", uom: "-", type: "text", required: true },
    { key: "componentName", label: "Part Name", uom: "-", type: "text", required: true },
    { key: "model", label: "Platform", uom: "-", type: "text", required: true },
    { key: "approvedRm", label: "Raw Material", uom: "-", type: "text", required: true },
    { key: "cavity", label: "Cavity Count", uom: "Nos", type: "number", required: true },
    { key: "netWeight", label: "Component Weight", uom: "Gms", type: "number", required: true },
    { key: "runnerWeight", label: "Runner Weight", uom: "Gms", type: "number", required: true },
    { key: "cycleTimeApproved", label: "Standard Cycle Time", uom: "Sec", type: "number", required: true },
    { key: "machineTonnage", label: "Machine Class", uom: "T", type: "number", required: true }
  ]
};

export const globalStore = {
  vendors: [
    { vendorId: "Haier", vendorName: "Haier Appliances", code: "HAIER", paymentTerms: "60 to 45 Days", active: true },
    { vendorId: "LG", vendorName: "LG Electronics", code: "LG", paymentTerms: "45 Days", active: true },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India", code: "WHIRLPOOL", paymentTerms: "60 Days", active: true }
  ],

  vendorSchemas: defaultVendorSchemas,

  vendorBaselines: {
    Haier: initialData.filter(d => (d.vendor || 'Haier') === 'Haier'),
    LG: initialData.filter(d => d.vendor === 'LG'),
    Whirlpool: initialData.filter(d => d.vendor === 'Whirlpool')
  },

  baselineList: initialData,
  baselineData: initialData,

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

export const onboardNewVendor = ({ vendorName, vendorCode, paymentTerms, initialFields }) => {
  const vId = vendorName.trim();
  if (!globalStore.vendors.find(v => v.vendorId.toLowerCase() === vId.toLowerCase())) {
    globalStore.vendors.push({
      vendorId: vId,
      vendorName,
      code: (vendorCode || vId.substring(0, 4)).toUpperCase(),
      paymentTerms: paymentTerms || "45 Days",
      active: true
    });
  }

  globalStore.vendorSchemas[vId] = initialFields && initialFields.length > 0 ? initialFields : defaultVendorSchemas.Haier;

  if (!globalStore.vendorBaselines[vId]) {
    globalStore.vendorBaselines[vId] = [];
  }
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

  return {
    vendor: row.vendor,
    approvedRm: row.approvedRm,
    approvedPrice: row.approvedPrice,
    validFrom: row.validFrom,
    validTo: row.validTo,
    activeRmName: row.alt1?.name || row.approvedRm,
    activeWaPrice: row.alt1?.waPrice || row.approvedPrice
  };
};

export const updateVendorScheduleBulk = (vendor, validFrom, validTo, updatedRows) => {
  globalStore.rmMatrix = globalStore.rmMatrix.map(row => {
    if (row.vendor === vendor) {
      const match = updatedRows.find(u => u.id === row.id);
      return match ? { ...match, validFrom, validTo } : { ...row, validFrom, validTo };
    }
    return row;
  });
  notifyStore();
};

// Precise Full 38-Line Cost Calculation for Audit Log
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

    // Run exact 38-line calculateDetailedCost
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

    // Record verified audit log entry
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

echo "==> Audit Log 38-line costing synchronization deployed."
