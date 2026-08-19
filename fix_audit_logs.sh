#!/usr/bin/env bash
set -e

# 1. Update masterStore.js with initial audit trails and active change-logging logic
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';

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

// Seed initial audit log entries
export const initialParameterChangeLogs = [
  {
    id: "LOG-PARAM-001",
    timestamp: "2026-08-18 14:32:10",
    itemCode: "0060226713H",
    componentName: "End Cap Top Ref (without Screen Painting )",
    vendor: "Haier",
    changedBy: "Senior Process Engineer",
    field: "Cycle Time Tuning",
    changesList: [
      { parameter: "Cycle Time", oldVal: "48.0 s", newVal: "46.5 s", diff: "-1.5 s" },
      { parameter: "Hourly Rate", oldVal: "₹450/hr", newVal: "₹450/hr", diff: "0" }
    ],
    costImpact: { oldCost: 32.64, newCost: 31.80, diff: -0.84 },
    reason: "Cooling channel efficiency enhancement on Line 4."
  },
  {
    id: "LOG-PARAM-002",
    timestamp: "2026-08-17 11:15:40",
    itemCode: "0060217989D",
    componentName: "End cap Bottom Ref-ABS-DC-195,220",
    vendor: "Haier",
    changedBy: "Tooling Manager",
    field: "Runner Optimization",
    changesList: [
      { parameter: "Runner Weight", oldVal: "40.0 g", newVal: "38.0 g", diff: "-2.0 g" }
    ],
    costImpact: { oldCost: 36.85, newCost: 35.90, diff: -0.95 },
    reason: "Runner gate bushing trimmed to minimize scrap generation."
  }
];

export const initialRmPriceHistoryLogs = [
  {
    id: "LOG-RM-001",
    timestamp: "2026-08-01 09:30:00",
    vendor: "Haier",
    rmGrade: "ABS 300 Pre Colour",
    action: "Contract Period Lock & Alternate Activation",
    period: "2026-08-01 to 2026-08-31",
    previousRate: 138.50,
    newRate: 136.20,
    activeAlternate: "Alternate 1: ABS 300-B Red (Prime Inward) @ ₹134.80/kg",
    changedBy: "Commercial Head",
    reason: "Monthly contractual tariff adjustment aligned with Supreme Petrochem index."
  },
  {
    id: "LOG-RM-002",
    timestamp: "2026-08-01 09:35:00",
    vendor: "Haier",
    rmGrade: "GPPS SC201LV",
    action: "Contract Period Lock",
    period: "2026-08-01 to 2026-08-31",
    previousRate: 104.50,
    newRate: 103.08,
    activeAlternate: "Alternate 1: GPPS SC201LV + 3.5% Smoke Grey @ ₹98.40/kg",
    changedBy: "Commercial Head",
    reason: "Q3 supplier agreement renewal."
  }
];

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
      alt1: { code: "PUR-ABS-01", name: "ABS 300-B Red (Prime Inward)", waPrice: 134.80 },
      alt2: { code: "PUR-ABS-02", name: "ABS 300-Blue (Imported)", waPrice: 131.25 },
      alt3: { code: "PUR-ABS-03", name: "ABS Recycled Compound (15% Regrind)", waPrice: 122.50 }
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
      alt1: { code: "PUR-GPPS-01", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", waPrice: 98.40 },
      alt2: { code: "PUR-GPPS-02", name: "GPPS Formosa SC-200 Equivalent", waPrice: 95.50 },
      alt3: { code: "PUR-GPPS-03", name: "GPPS Reprocessed Clear Blend", waPrice: 89.20 }
    }
  ],

  parameterChangeLogs: initialParameterChangeLogs,
  rmPriceHistoryLogs: initialRmPriceHistoryLogs
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

  // Log each RM update to rmPriceHistoryLogs
  updatedRows.forEach(uRow => {
    const prev = previousRows.find(p => p.id === uRow.id);
    let altText = uRow.activeSelection === 'alt1' ? `Alternate 1 (${uRow.alt1?.name})` : 
                  uRow.activeSelection === 'alt2' ? `Alternate 2 (${uRow.alt2?.name})` : 
                  uRow.activeSelection === 'alt3' ? `Alternate 3 (${uRow.alt3?.name})` : 'Primary Approved';

    globalStore.rmPriceHistoryLogs.unshift({
      id: `LOG-RM-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      vendor,
      rmGrade: uRow.approvedRm,
      action: "Schedule Modified & Locked",
      period: `${validFrom} to ${validTo}`,
      previousRate: prev?.approvedPrice || uRow.approvedPrice,
      newRate: uRow.approvedPrice,
      activeAlternate: altText,
      changedBy: "Engineering Head",
      reason: `Locked period (${validFrom} to ${validTo}) with ${altText}`
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

    const oldCost = Number(prev.approvedTotalCost ?? 32.64);
    const newCost = Number(updatedItem.actualSimulatedCost ?? oldCost);
    const costDelta = Number((newCost - oldCost).toFixed(2));

    globalStore.baselineList[idx] = {
      ...prev,
      ...updatedItem,
      validFrom: newValidFrom || prev.validFrom
    };

    const v = prev.vendor || 'Haier';
    if (globalStore.vendorBaselines[v]) {
      const vIdx = globalStore.vendorBaselines[v].findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
      if (vIdx !== -1) {
        globalStore.vendorBaselines[v][vIdx] = globalStore.baselineList[idx];
      }
    }

    // Always push audit log
    globalStore.parameterChangeLogs.unshift({
      id: `LOG-PARAM-${Date.now()}`,
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      itemCode: updatedItem?.itemCode || prev.itemCode,
      componentName: updatedItem?.componentName || prev.componentName,
      vendor: v,
      changedBy: "Engineering Head",
      field: changeType || "Manufacturing Parameters",
      changesList: changesList.length > 0 ? changesList : [{ parameter: "Shopfloor Spec", oldVal: "Base", newVal: "Optimized", diff: "Updated" }],
      costImpact: { oldCost, newCost, diff: costDelta },
      reason: reason || "Manual shopfloor optimization tuning"
    });

    notifyStore();
  }
};

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

export const getVendorRmCosting = (vendorCode, rmCode) => {
  const res = getActiveRmMapping(rmCode, vendorCode);
  return res.activeWaPrice;
};

export { initialData as baselineList, initialData as baselineData, initialData as baselineProducts };
export default globalStore;
STORE_EOF

# 2. Update RMPriceMatrixPage.jsx to add the 4th tab: "Audit Trail & Logs"
cat << 'RM_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Layers, Edit3, Lock, Check, History, Calendar, Upload, Plus, 
  CheckCircle2, ShoppingCart, Truck, X, Download, ShieldCheck, AlertCircle 
} from 'lucide-react';
import { 
  globalStore, subscribeStore, updateVendorScheduleBulk, 
  addManualPurchaseRecord, addManualSaleRecord, uploadBulkSales, uploadBulkPurchases 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [activeTab, setActiveTab] = useState('matrix'); // 'matrix' | 'purchases' | 'sales' | 'history'
  const [isGlobalEditing, setIsGlobalEditing] = useState(false);
  const [successMsg, setSuccessMsg] = useState(null);

  const [showPurchaseModal, setShowPurchaseModal] = useState(false);
  const [showSalesModal, setShowSalesModal] = useState(false);
  const [stagedPurchases, setStagedPurchases] = useState([]);
  const [stagedSales, setStagedSales] = useState([]);

  const [newPur, setNewPur] = useState({
    invoiceNo: 'INV-PUR-901',
    polymer: 'ABS',
    name: '',
    supplier: '',
    qtyKg: '',
    waPrice: '',
    inwardDate: new Date().toISOString().slice(0, 10)
  });

  const defaultPart = (globalStore.baselineList || [])[0] || {};
  const [newSale, setNewSale] = useState({
    invoiceNo: 'INV-SLS-301',
    itemCode: defaultPart.itemCode || '0060226713H',
    componentName: defaultPart.componentName || 'End Cap Top Ref (without Screen Painting )',
    vendor: selectedVendor,
    saleUnit: '',
    invoiceDate: new Date().toISOString().slice(0, 10),
    sellingPrice: ''
  });

  const vendorRows = (globalStore.rmMatrix || []).filter(r => r.vendor === selectedVendor);
  const vendorHistory = (globalStore.rmPriceHistoryLogs || []).filter(h => h.vendor === selectedVendor || selectedVendor === 'ALL');

  const [localRows, setLocalRows] = useState([]);
  const [validFrom, setValidFrom] = useState('2026-08-01');
  const [validTo, setValidTo] = useState('2026-08-31');

  useEffect(() => {
    if (vendorRows.length > 0) {
      setLocalRows(JSON.parse(JSON.stringify(vendorRows)));
      setValidFrom(vendorRows[0].validFrom || '2026-08-01');
      setValidTo(vendorRows[0].validTo || '2026-08-31');
      setIsGlobalEditing(false);
    }
  }, [selectedVendor]);

  const handlePartCodeSelect = (code) => {
    const matched = (globalStore.baselineList || []).find(b => b.itemCode === code);
    setNewSale(prev => ({
      ...prev,
      itemCode: code,
      componentName: matched ? matched.componentName : prev.componentName
    }));
  };

  const handleToggleGlobalEditLock = () => {
    if (isGlobalEditing) {
      updateVendorScheduleBulk(selectedVendor, validFrom, validTo, localRows);
      setIsGlobalEditing(false);
      setSuccessMsg(`Locked schedule & logged audit trail for ${selectedVendor} (${validFrom} to ${validTo})`);
      setTimeout(() => setSuccessMsg(null), 3500);
    } else {
      setLocalRows(JSON.parse(JSON.stringify(vendorRows)));
      setIsGlobalEditing(true);
    }
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
            <h1 className="text-sm font-bold">2. RM Tariff & Alternate Weighted Average (WA) Matrix</h1>
            <p className="text-[11px] text-slate-300">
              Synced Scope: <span className="text-amber-300 font-mono font-bold">{selectedVendor} + Period ({validFrom} to {validTo})</span>
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={() => { setStagedPurchases([]); setShowPurchaseModal(true); }}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-amber-600 hover:bg-amber-700 text-white font-bold rounded-lg cursor-pointer shadow-xs"
          >
            <Plus className="w-3.5 h-3.5" /> + Enter / Upload Purchase
          </button>

          <button
            onClick={() => { setStagedSales([]); setShowSalesModal(true); }}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg cursor-pointer shadow-xs"
          >
            <Plus className="w-3.5 h-3.5" /> + Enter / Upload Sales
          </button>

          <div className="h-4 w-px bg-slate-700"></div>

          <button
            onClick={() => setActiveTab('matrix')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'matrix' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            RM Schedule
          </button>

          <button
            onClick={() => setActiveTab('purchases')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'purchases' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            Purchases ({(globalStore.purchaseMaster || []).length})
          </button>

          <button
            onClick={() => setActiveTab('sales')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'sales' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            Sales ({(globalStore.salesData || []).length})
          </button>

          {/* Restored 4th Tab */}
          <button
            onClick={() => setActiveTab('history')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'history' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            <History className="w-3.5 h-3.5" /> Audit Trail ({vendorHistory.length})
          </button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2 rounded-xl flex items-center gap-2 font-semibold">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      {/* TAB 1: RM SCHEDULE */}
      {activeTab === 'matrix' && (
        <div className="bg-white border border-slate-300 rounded-2xl shadow-sm overflow-hidden p-4 space-y-4">
          <div className="flex flex-wrap items-center justify-between gap-4 bg-slate-50 border border-slate-300 rounded-xl p-3.5">
            <div className="flex items-center gap-2">
              <span className="font-bold text-slate-800 uppercase text-[11px] tracking-wider">Select Vendor:</span>
              <select
                value={selectedVendor}
                disabled={isGlobalEditing}
                onChange={(e) => setSelectedVendor(e.target.value)}
                className="bg-white border-2 border-blue-600 text-blue-950 font-bold px-3 py-1.5 rounded-lg text-xs shadow-xs"
              >
                <option value="Haier">Haier Appliances</option>
                <option value="LG">LG Electronics</option>
                <option value="Whirlpool">Whirlpool India</option>
              </select>
            </div>

            <div className="flex items-center gap-3">
              <span className="font-bold text-slate-800 uppercase text-[11px] tracking-wider flex items-center gap-1">
                <Calendar className="w-3.5 h-3.5 text-amber-600" /> Validity Period:
              </span>
              <div className="flex items-center gap-1.5">
                <span className="text-[10px] font-bold text-slate-500 uppercase">From</span>
                <input
                  type="date"
                  value={validFrom}
                  disabled={!isGlobalEditing}
                  onChange={(e) => setValidFrom(e.target.value)}
                  className={`border rounded-lg p-1 px-2 font-mono font-bold text-xs ${
                    isGlobalEditing ? 'bg-white border-blue-500 text-blue-900' : 'bg-slate-200/70 border-slate-300 text-slate-600'
                  }`}
                />
              </div>
              <div className="flex items-center gap-1.5">
                <span className="text-[10px] font-bold text-slate-500 uppercase">To</span>
                <input
                  type="date"
                  value={validTo}
                  disabled={!isGlobalEditing}
                  onChange={(e) => setValidTo(e.target.value)}
                  className={`border rounded-lg p-1 px-2 font-mono font-bold text-xs ${
                    isGlobalEditing ? 'bg-white border-blue-500 text-blue-900' : 'bg-slate-200/70 border-slate-300 text-slate-600'
                  }`}
                />
              </div>
            </div>

            <div>
              <button
                onClick={handleToggleGlobalEditLock}
                className={`px-4 py-2 rounded-xl font-bold transition flex items-center gap-2 cursor-pointer shadow-sm ${
                  isGlobalEditing ? 'bg-emerald-600 text-white animate-pulse' : 'bg-blue-600 hover:bg-blue-700 text-white'
                }`}
              >
                {isGlobalEditing ? <><Check className="w-4 h-4" /> Save & Lock for {selectedVendor} & Period</> : <><Edit3 className="w-4 h-4" /> Global Edit & Lock for Vendor & Period</>}
              </button>
            </div>
          </div>

          <div className="overflow-x-auto border border-slate-300 rounded-xl">
            <table className="min-w-full text-xs text-left border-collapse">
              <thead>
                <tr className="bg-slate-800 text-white font-bold border-b border-slate-700 text-[11px]">
                  <th className="p-3 border-r border-slate-700 min-w-[160px] bg-amber-950/80 text-amber-200">Approved RM</th>
                  <th className="p-3 border-r border-slate-700 text-right min-w-[120px] bg-amber-950/80 text-amber-200">Approved Price (₹/kg)</th>
                  <th className="p-3 border-r border-slate-700 min-w-[220px] bg-blue-950/80 text-blue-200">Alternate RM-1 (Dropdown)</th>
                  <th className="p-3 border-r border-slate-700 text-right min-w-[90px] bg-slate-900 text-slate-300">WA Price</th>
                  <th className="p-3 border-r border-slate-700 min-w-[220px] bg-blue-950/80 text-blue-200">Alternate RM-2 (Dropdown)</th>
                  <th className="p-3 border-r border-slate-700 text-right min-w-[90px] bg-slate-900 text-slate-300">WA Price</th>
                  <th className="p-3 border-r border-slate-700 min-w-[220px] bg-blue-950/80 text-blue-200">Alternate RM-3 (Dropdown)</th>
                  <th className="p-3 border-r border-slate-700 text-right min-w-[90px] bg-slate-900 text-slate-300">WA Price</th>
                  <th className="p-3 text-center min-w-[120px] bg-slate-900 uppercase tracking-wider text-amber-400">Active Effective</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {(isGlobalEditing ? localRows : vendorRows).map((row) => {
                  let activePrice = row.approvedPrice;
                  if (row.activeSelection === 'alt1') activePrice = row.alt1?.waPrice;
                  else if (row.activeSelection === 'alt2') activePrice = row.alt2?.waPrice;
                  else if (row.activeSelection === 'alt3') activePrice = row.alt3?.waPrice;

                  return (
                    <tr key={row.id} className="hover:bg-slate-50">
                      <td className="p-3 border-r border-slate-300 font-bold text-slate-900 bg-amber-50/30">
                        <div className="flex items-center gap-1.5">
                          <Lock className="w-3 h-3 text-amber-600" />
                          <span>{row.approvedRm}</span>
                        </div>
                      </td>
                      <td className="p-3 border-r border-slate-300 text-right font-mono font-bold text-amber-950 bg-amber-50/30">
                        ₹{row.approvedPrice.toFixed(2)}
                      </td>
                      <td className={`p-2.5 border-r border-slate-300 ${row.activeSelection === 'alt1' ? 'bg-blue-50/90' : ''}`}>
                        <div className="flex items-center gap-1.5">
                          <input type="radio" checked={row.activeSelection === 'alt1'} disabled={!isGlobalEditing} onChange={() => setLocalRows(prev => prev.map(r => r.id === row.id ? { ...r, activeSelection: 'alt1' } : r))} />
                          <select disabled={!isGlobalEditing} value={row.alt1?.code || ''} className="w-full bg-white border border-slate-300 rounded p-1 text-xs">
                            {(globalStore.purchaseMaster || []).map(p => (
                              <option key={p.code} value={p.code}>{p.name}</option>
                            ))}
                          </select>
                        </div>
                      </td>
                      <td className="p-3 border-r border-slate-300 text-right font-mono font-bold bg-slate-100/70">₹{row.alt1?.waPrice?.toFixed(2)}</td>

                      <td className={`p-2.5 border-r border-slate-300 ${row.activeSelection === 'alt2' ? 'bg-blue-50/90' : ''}`}>
                        <div className="flex items-center gap-1.5">
                          <input type="radio" checked={row.activeSelection === 'alt2'} disabled={!isGlobalEditing} onChange={() => setLocalRows(prev => prev.map(r => r.id === row.id ? { ...r, activeSelection: 'alt2' } : r))} />
                          <select disabled={!isGlobalEditing} value={row.alt2?.code || ''} className="w-full bg-white border border-slate-300 rounded p-1 text-xs">
                            {(globalStore.purchaseMaster || []).map(p => (
                              <option key={p.code} value={p.code}>{p.name}</option>
                            ))}
                          </select>
                        </div>
                      </td>
                      <td className="p-3 border-r border-slate-300 text-right font-mono font-bold bg-slate-100/70">₹{row.alt2?.waPrice?.toFixed(2)}</td>

                      <td className={`p-2.5 border-r border-slate-300 ${row.activeSelection === 'alt3' ? 'bg-blue-50/90' : ''}`}>
                        <div className="flex items-center gap-1.5">
                          <input type="radio" checked={row.activeSelection === 'alt3'} disabled={!isGlobalEditing} onChange={() => setLocalRows(prev => prev.map(r => r.id === row.id ? { ...r, activeSelection: 'alt3' } : r))} />
                          <select disabled={!isGlobalEditing} value={row.alt3?.code || ''} className="w-full bg-white border border-slate-300 rounded p-1 text-xs">
                            {(globalStore.purchaseMaster || []).map(p => (
                              <option key={p.code} value={p.code}>{p.name}</option>
                            ))}
                          </select>
                        </div>
                      </td>
                      <td className="p-3 border-r border-slate-300 text-right font-mono font-bold bg-slate-100/70">₹{row.alt3?.waPrice?.toFixed(2)}</td>

                      <td className="p-3 text-center bg-slate-100">
                        <span className="font-mono font-black text-blue-900 bg-white border border-blue-300 px-2 py-0.5 rounded shadow-xs block text-xs">
                          ₹{activePrice?.toFixed(2)}/kg
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 2: PURCHASES */}
      {activeTab === 'purchases' && (
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-sm space-y-3">
          <div className="flex justify-between items-center border-b pb-2">
            <h2 className="font-bold text-slate-900 text-sm flex items-center gap-1.5">
              <ShoppingCart className="w-4 h-4 text-amber-600" /> Recorded Purchase Inward Batches (WA Source)
            </h2>
          </div>
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
              <tr>
                <th className="p-2.5">Invoice No</th>
                <th className="p-2.5">Inward Date</th>
                <th className="p-2.5">Polymer Material</th>
                <th className="p-2.5">Supplier</th>
                <th className="p-2.5 text-right">Inward Qty (Kg)</th>
                <th className="p-2.5 text-right font-bold text-blue-950">Purchase Rate (₹/kg)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {(globalStore.purchaseMaster || []).map(p => (
                <tr key={p.code}>
                  <td className="p-2.5 font-mono text-blue-700 font-bold">{p.invoiceNo || p.code}</td>
                  <td className="p-2.5 font-mono text-slate-600">{p.inwardDate}</td>
                  <td className="p-2.5 font-semibold text-slate-900">{p.name}</td>
                  <td className="p-2.5 text-slate-600">{p.supplier}</td>
                  <td className="p-2.5 text-right font-mono">{p.qtyKg?.toLocaleString()} kg</td>
                  <td className="p-2.5 text-right font-mono font-black text-amber-900">₹{p.waPrice?.toFixed(2)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* TAB 3: SALES */}
      {activeTab === 'sales' && (
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-sm space-y-3">
          <div className="flex justify-between items-center border-b pb-2">
            <h2 className="font-bold text-slate-900 text-sm flex items-center gap-1.5">
              <Truck className="w-4 h-4 text-emerald-600" /> Recorded Sales Dispatches
            </h2>
          </div>
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
              <tr>
                <th className="p-2.5">Invoice No</th>
                <th className="p-2.5">Invoice Date</th>
                <th className="p-2.5">Vendor</th>
                <th className="p-2.5">Part Code</th>
                <th className="p-2.5">Part Name</th>
                <th className="p-2.5 text-right">Dispatched Qty</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {(globalStore.salesData || []).map(s => (
                <tr key={s.id}>
                  <td className="p-2.5 font-mono text-blue-700 font-bold">{s.invoiceNo || s.id}</td>
                  <td className="p-2.5 font-mono text-slate-600">{s.invoiceDate}</td>
                  <td className="p-2.5 font-semibold text-slate-700">{s.vendor}</td>
                  <td className="p-2.5 font-mono text-slate-900">{s.itemCode}</td>
                  <td className="p-2.5 font-semibold text-slate-900">{s.componentName}</td>
                  <td className="p-2.5 text-right font-mono font-bold text-emerald-800">{s.saleUnit?.toLocaleString()} pcs</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* TAB 4: AUDIT TRAIL & HISTORY LOGS (RESTORED) */}
      {activeTab === 'history' && (
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-sm space-y-3">
          <div className="flex justify-between items-center border-b pb-2">
            <h2 className="font-bold text-slate-900 text-sm flex items-center gap-1.5">
              <History className="w-4 h-4 text-purple-600" /> RM Contract & Price Locking Audit Trail
            </h2>
            <span className="text-[11px] text-slate-500 font-mono">Showing history for {selectedVendor}</span>
          </div>

          <div className="overflow-x-auto border border-slate-200 rounded-xl">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-3">Timestamp</th>
                  <th className="p-3">Vendor</th>
                  <th className="p-3">RM Grade</th>
                  <th className="p-3">Validity Period</th>
                  <th className="p-3 text-right">Contract Rate</th>
                  <th className="p-3">Active Alternate</th>
                  <th className="p-3">Authorized By</th>
                  <th className="p-3">Change Note</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {vendorHistory.map(log => (
                  <tr key={log.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="p-3 font-semibold text-slate-700">{log.vendor}</td>
                    <td className="p-3 font-bold text-blue-900">{log.rmGrade}</td>
                    <td className="p-3 font-mono text-amber-800">{log.period}</td>
                    <td className="p-3 text-right font-mono font-black text-slate-900">₹{log.newRate?.toFixed(2)}</td>
                    <td className="p-3 font-semibold text-purple-900">{log.activeAlternate}</td>
                    <td className="p-3 text-slate-700">{log.changedBy}</td>
                    <td className="p-3 text-slate-600 italic">{log.reason}</td>
                  </tr>
                ))}
                {vendorHistory.length === 0 && (
                  <tr>
                    <td colSpan="8" className="p-4 text-center text-slate-400 italic">No RM contract modification logs for {selectedVendor} yet.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

    </div>
  );
}
RM_EOF

# 3. Update BaselineMasterPage.jsx ensuring parameter edit logs and tab rendering are active
cat << 'BASE_EOF' > src/modules/module1-baseline/BaselineMasterPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Layers, Download, Upload, Plus, History, Search, CheckCircle2, 
  Building2, Sliders, X, FileSpreadsheet, Edit3, ArrowRight 
} from 'lucide-react';
import { 
  globalStore, subscribeStore, getVendorBaselineData, 
  onboardNewVendor, addVendorBaselineProducts, updateBaselineParameters 
} from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [activeTab, setActiveTab] = useState('parameters'); // 'parameters' | 'audit_log'
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);

  const [showOnboardModal, setShowOnboardModal] = useState(false);
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [stagedProducts, setStagedProducts] = useState([]);
  const [successMsg, setSuccessMsg] = useState(null);

  const vendorList = globalStore.vendors || [];
  const currentSchema = (globalStore.vendorSchemas && globalStore.vendorSchemas[selectedVendor]) || (globalStore.vendorSchemas?.Haier) || [];
  const rawList = getVendorBaselineData(selectedVendor);

  const filteredList = rawList.filter(item => {
    const matchSearch = (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
                        (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
    return matchSearch;
  });

  const changeLogs = (globalStore.parameterChangeLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Building2 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master</h1>
            <p className="text-[11px] text-slate-300">
              Active Scope: <span className="text-amber-300 font-mono font-bold">{selectedVendor}</span> | Database: <span className="font-mono text-emerald-300">{rawList.length} Registered Parts</span>
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={() => setActiveTab('parameters')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            1. Parameters Master ({rawList.length})
          </button>

          <button
            onClick={() => setActiveTab('audit_log')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'audit_log' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            <History className="w-3.5 h-3.5" /> 2. Parameter Audit Log ({changeLogs.length})
          </button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2 rounded-xl flex items-center gap-2 font-semibold">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      {/* Search & Vendor Selection Strip */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3 flex-1 min-w-[280px]">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={`Search ${selectedVendor} components...`}
              className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
            />
          </div>

          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700 text-xs">Switch Vendor:</span>
            <select
              value={selectedVendor}
              onChange={(e) => setSelectedVendor(e.target.value)}
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 text-xs font-bold bg-white text-blue-950 outline-none"
            >
              {vendorList.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors</option>
            </select>
          </div>
        </div>
      </div>

      {/* TAB 1: PARAMETERS MASTER */}
      {activeTab === 'parameters' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <Layers className="w-4 h-4 text-blue-400" /> Product Baseline Manufacturing Parameters Master
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredList.length} Active Parts</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3 min-w-[200px]">Item Code / Component</th>
                  <th className="p-3">Model & Tool Size</th>
                  <th className="p-3">Approved RM</th>
                  <th className="p-3 text-center">Cavity</th>
                  <th className="p-3 text-right">Net Wt</th>
                  <th className="p-3 text-right">Runner Wt</th>
                  <th className="p-3 text-center">Cycle Time</th>
                  <th className="p-3 text-center">Tonnage</th>
                  <th className="p-3 text-right">Shift Tariff</th>
                  <th className="p-3 text-center">Validity</th>
                  <th className="p-3 text-center min-w-[70px]">Edit Spec</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium text-slate-800">
                {filteredList.map((item) => (
                  <tr key={item.id} className="hover:bg-blue-50/40 transition">
                    <td className="p-3">
                      <span className="font-mono font-bold text-blue-700 block">{item.itemCode}</span>
                      <span className="text-[11px] text-slate-800 font-semibold">{item.componentName}</span>
                    </td>
                    <td className="p-3 text-slate-600">
                      <span className="font-semibold block text-slate-800">{item.model || 'Standard'}</span>
                      <span className="text-[10px] font-mono text-slate-500">{item.mouldSize || '1070*720*650'}</span>
                    </td>
                    <td className="p-3 font-semibold text-slate-900">{item.approvedRm}</td>
                    <td className="p-3 text-center font-bold font-mono text-slate-900">{item.cavity || 1}</td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">{item.netWeight || 197}g</td>
                    <td className="p-3 text-right font-mono text-slate-600">{item.runnerWeight || 40}g</td>
                    <td className="p-3 text-center">
                      <span className="bg-amber-100 text-amber-900 font-mono font-bold px-2 py-0.5 rounded text-[11px]">
                        {item.cycleTimeApproved || item.cycleTime || 48}s
                      </span>
                    </td>
                    <td className="p-3 text-center font-mono font-bold text-slate-700">{item.machineTonnage || 450}T</td>
                    <td className="p-3 text-right font-mono font-semibold text-slate-700">₹{item.hourlyRate ? (item.hourlyRate * 8) : 3600}</td>
                    <td className="p-3 text-center font-mono text-[10px] text-slate-500">{item.validFrom || '2026-08-01'} &rarr; -</td>
                    <td className="p-3 text-center">
                      <button
                        type="button"
                        onClick={() => setEditingItem(item)}
                        className="p-1.5 bg-blue-50 hover:bg-blue-600 text-blue-600 hover:text-white rounded-lg transition cursor-pointer border border-blue-200 shadow-xs inline-flex items-center justify-center"
                        title="Edit Baseline Parameters"
                      >
                        <Edit3 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 2: PARAMETER AUDIT LOG */}
      {activeTab === 'audit_log' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 p-4 space-y-3">
          <div className="flex justify-between items-center border-b pb-2">
            <h2 className="text-sm font-bold text-slate-900 flex items-center gap-1.5">
              <History className="w-4 h-4 text-purple-600" /> Parameter Modification Audit Trail
            </h2>
            <span className="text-[11px] text-slate-500 font-mono">Real-time shopfloor tuning logs</span>
          </div>

          <div className="border border-slate-200 rounded-xl overflow-hidden">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-3">Timestamp</th>
                  <th className="p-3">Part Code</th>
                  <th className="p-3">Component Name</th>
                  <th className="p-3">Vendor</th>
                  <th className="p-3">Parameter Modifications</th>
                  <th className="p-3 text-right">Cost Impact (Δ)</th>
                  <th className="p-3">Authorized By</th>
                  <th className="p-3">Audit Reason</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {changeLogs.map(log => (
                  <tr key={log.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="p-3 font-mono font-bold text-blue-700">{log.itemCode}</td>
                    <td className="p-3 font-semibold text-slate-900">{log.componentName}</td>
                    <td className="p-3 font-semibold text-slate-700">{log.vendor || selectedVendor}</td>
                    <td className="p-3">
                      {(log.changesList || []).map((ch, i) => (
                        <span key={i} className="inline-block bg-slate-100 border border-slate-300 rounded px-1.5 py-0.5 text-[10px] mr-1.5 font-mono">
                          {ch.parameter}: {ch.oldVal} &rarr; <span className="font-bold text-blue-900">{ch.newVal}</span> ({ch.diff})
                        </span>
                      ))}
                    </td>
                    <td className="p-3 text-right font-mono font-black">
                      <span className={(log.costImpact?.diff || 0) <= 0 ? 'text-emerald-700' : 'text-rose-600'}>
                        ₹ {(log.costImpact?.diff || 0) <= 0 ? `${(log.costImpact?.diff || 0).toFixed(2)}` : `+${(log.costImpact?.diff || 0).toFixed(2)}`}
                      </span>
                    </td>
                    <td className="p-3 text-slate-700">{log.changedBy}</td>
                    <td className="p-3 text-slate-600 italic">{log.reason}</td>
                  </tr>
                ))}
                {changeLogs.length === 0 && (
                  <tr>
                    <td colSpan="8" className="p-4 text-center text-slate-400 italic">No parameter modification logs found.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* EDIT MODAL */}
      {editingItem && (
        <InlineEditModal
          item={editingItem}
          isOpen={Boolean(editingItem)}
          onClose={() => setEditingItem(null)}
          onSave={({ updatedItem, changeType, newValidFrom, reason }) => {
            updateBaselineParameters({
              itemId: editingItem?.id,
              updatedItem,
              changeType,
              newValidFrom,
              reason
            });
            setEditingItem(null);
            setSuccessMsg(`Parameter change logged for ${editingItem.itemCode}`);
            setTimeout(() => setSuccessMsg(null), 3000);
          }}
        />
      )}

    </div>
  );
}
BASE_EOF

echo "==> Audit Trail & History Logs restored across RM and Baseline modules."
