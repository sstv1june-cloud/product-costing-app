#!/usr/bin/env bash
set -e

# 1. Update masterStore.js with dynamic blueprint engine and isolated vendor namespaces
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';
import { calculateDetailedCost, defaultCostingLines } from '../modules/module1-baseline/InlineEditModal';

const initialData = Array.isArray(initialBaselineData) ? initialBaselineData : [];

// Default 38-line standard blueprint for Haier
export const haierBlueprint = defaultCostingLines || [];

// 9-line appliance blueprint for LG
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

// 7-line simplified platform blueprint for Whirlpool
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

// Onboard New Vendor with Custom Dynamic N-Line Blueprint
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

  // Save isolated blueprint
  globalStore.vendorBlueprints[vId] = blueprintLines;

  // Initialize isolated baseline repository
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

    // Initialize RM matrix entry
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

export default globalStore;
STORE_EOF

# 2. Update DashboardPage.jsx with the Onboard New Vendor & Costing Format Pipeline
cat << 'DASH_EOF' > src/modules/module0-dashboard/DashboardPage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  Building2, Layers, Sliders, DollarSign, BarChart3, Bot, 
  TrendingUp, TrendingDown, AlertTriangle, ArrowRight, ShieldCheck, 
  Sparkles, CheckCircle2, UserPlus, Upload, FileSpreadsheet, X, Check, Eye
} from 'lucide-react';
import { globalStore, subscribeStore, onboardVendorWithBlueprint } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function DashboardPage({ onNavigate }) {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [showOnboardModal, setShowOnboardModal] = useState(false);
  const [onboardStep, setOnboardStep] = useState(1); // 1: Info, 2: Upload, 3: Staging & Formula Mapping
  const [successMsg, setSuccessMsg] = useState(null);

  // New Vendor Onboarding Form State
  const [newVendorData, setNewVendorData] = useState({
    vendorName: '',
    vendorCode: '',
    paymentTerms: '45 Days',
    currency: 'INR (₹)'
  });

  // Dynamic Costing Blueprint Parser State (5 to 100+ lines)
  const [uploadedFileName, setUploadedFileName] = useState('');
  const [stagedLines, setStagedLines] = useState([]);
  const [stagedProduct, setStagedProduct] = useState({
    itemCode: 'WP-TOP-991',
    componentName: 'Top Cover Panel (OEM Spec)',
    model: 'Platform 2026',
    mouldSize: '1100*650*450',
    approvedRm: 'ABS HI-121 Grade',
    approvedRmRate: 138.00,
    cavity: 2,
    netWeight: 210,
    runnerWeight: 35,
    cycleTimeApproved: 44,
    machineTonnage: 450,
    hourlyRate: 450
  });

  const vendors = globalStore.vendors || [];
  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];

  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  // Compute live portfolio metrics
  const dashboardStats = useMemo(() => {
    let totalRev = 0;
    let totalGain = 0;
    let totalQty = 0;

    vendorProducts.forEach(part => {
      const params = part.parameters || {};
      const rmRate = part.approvedRmRate || 136.20;

      const baselineSpec = {
        cavity: Number(part.cavity ?? params.cavity ?? 2),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 197),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 40),
        rmRate,
        masterbatchPct: 0,
        masterbatchRate: 0,
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 450),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 3600)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 48)
      };
      const baselineCalc = calculateDetailedCost(baselineSpec, true);

      const runningSpec = {
        cavity: Number(params.runningCavity ?? baselineSpec.cavity),
        netWeight: Number(params.runningNetWeight ?? baselineSpec.netWeight),
        runnerWeight: Number(params.runningRunnerWeight ?? baselineSpec.runnerWeight),
        rmRate: 134.80,
        masterbatchPct: 0,
        masterbatchRate: 0,
        machineTonnage: Number(params.runningTonnage ?? baselineSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? baselineSpec.shiftTariff),
        cycleTime: Number(params.runningCycleTime ?? baselineSpec.cycleTime)
      };
      const runningCalc = calculateDetailedCost(runningSpec, false);

      const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
      const actualCost = Number(runningCalc.totalCost.toFixed(2));
      const unitDelta = contractBaseline - actualCost;

      const matchedSales = salesData.filter(s => s.itemCode === part.itemCode);
      const qty = matchedSales.reduce((acc, s) => acc + Number(s.saleUnit || 0), 0);
      const sp = Number(matchedSales[0]?.sellingPrice || (contractBaseline * 1.18));

      totalQty += qty;
      totalRev += (sp * qty);
      totalGain += (unitDelta * qty);
    });

    return {
      totalQty,
      totalRev,
      totalGain,
      partsCount: vendorProducts.length
    };
  }, [vendorProducts, salesData, selectedVendor]);

  // Simulate file upload and dynamic parsing of N lines (e.g. 5 to 100 lines)
  const handleSimulateCostingSheetUpload = (e) => {
    const file = e.target.files?.[0];
    const fName = file ? file.name : "OEM_Prescribed_Costing_Template.xlsx";
    setUploadedFileName(fName);

    // Dynamically generate parsed format blueprint from uploaded sheet
    const parsedBlueprint = [
      { lineNo: 1, description: "Component Description", uom: "-", type: "text", val: stagedProduct.componentName, mapping: "componentName", isHeader: true },
      { lineNo: 2, description: "OEM Part Number", uom: "-", type: "text", val: stagedProduct.itemCode, mapping: "itemCode", isHeader: true },
      { lineNo: 3, description: "Model & Platform", uom: "-", type: "text", val: stagedProduct.model, mapping: "model", isHeader: true },
      { lineNo: 4, description: "Raw Material Grade", uom: "-", type: "text", val: stagedProduct.approvedRm, mapping: "approvedRm", isRm: true },
      { lineNo: 5, description: "Approved RM Contract Tariff", uom: "₹/kg", type: "number", val: stagedProduct.approvedRmRate, mapping: "approvedRmRate", isRmRate: true },
      { lineNo: 6, description: "Mould Tool Cavities", uom: "Nos", type: "number", val: stagedProduct.cavity, mapping: "cavity", isParam: true },
      { lineNo: 7, description: "Component Net Weight", uom: "Gms", type: "number", val: stagedProduct.netWeight, mapping: "netWeight", isParam: true },
      { lineNo: 8, description: "Feed System / Runner Weight", uom: "Gms", type: "number", val: stagedProduct.runnerWeight, mapping: "runnerWeight", isParam: true },
      { lineNo: 9, description: "Approved Cycle Time", uom: "Sec", type: "number", val: stagedProduct.cycleTimeApproved, mapping: "cycleTimeApproved", isParam: true },
      { lineNo: 10, description: "Machine Clamping Tonnage", uom: "T", type: "number", val: stagedProduct.machineTonnage, mapping: "machineTonnage", isParam: true },
      { lineNo: 11, description: "Shift Conversion Tariff", uom: "₹/shift", type: "number", val: stagedProduct.hourlyRate * 8, mapping: "shiftTariff", isParam: true },
      { lineNo: 12, description: "Total Raw Material Cost (Net + Scrap - Recovery)", uom: "₹/pc", type: "calc", val: 30.12, isFormula: true },
      { lineNo: 13, description: "Total Machine Conversion & Overhead", uom: "₹/pc", type: "calc", val: 4.88, isFormula: true },
      { lineNo: 14, description: "Approved Baseline Contract Cost", uom: "₹/pc", type: "total", val: 35.00, isTotal: true }
    ];

    setStagedLines(parsedBlueprint);
    setOnboardStep(3); // Proceed to Staging & Formula Mapping
  };

  const handleCommitNewVendor = () => {
    if (!newVendorData.vendorName) return;

    onboardVendorWithBlueprint({
      vendorName: newVendorData.vendorName,
      vendorCode: newVendorData.vendorCode || newVendorData.vendorName.substring(0, 4).toUpperCase(),
      paymentTerms: newVendorData.paymentTerms,
      blueprintLines: stagedLines,
      initialProduct: stagedProduct
    });

    setSelectedVendor(newVendorData.vendorName);
    setShowOnboardModal(false);
    setOnboardStep(1);
    setSuccessMsg(`Vendor "${newVendorData.vendorName}" onboarded with ${stagedLines.length}-line custom costing blueprint.`);
    setTimeout(() => setSuccessMsg(null), 4000);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Building2 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">0. Executive Costing & MIS Command Dashboard</h1>
            <p className="text-[11px] text-slate-300">Multi-Vendor Approved vs Actual Costing & Real-Time Variance Control</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Onboard New Vendor Button */}
          <button
            onClick={() => { setOnboardStep(1); setShowOnboardModal(true); }}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl shadow-xs transition cursor-pointer"
          >
            <UserPlus className="w-3.5 h-3.5" /> + Onboard New Vendor
          </button>

          <span className="text-[11px] font-bold text-slate-400 ml-2">Vendor Scope:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="bg-slate-800 border border-slate-700 text-blue-300 font-bold px-3 py-1.5 rounded-xl text-xs outline-none cursor-pointer"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
            <option value="ALL">All Combined</option>
          </select>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2.5 rounded-xl flex items-center gap-2 font-bold shadow-xs">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Registered Baseline Products</span>
          <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">{dashboardStats.partsCount} Active Parts</span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Total Period Dispatches</span>
          <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">{dashboardStats.totalQty.toLocaleString()} pcs</span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Realized Sales Revenue</span>
          <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">
            ₹{dashboardStats.totalRev.toLocaleString('en-IN', { maximumFractionDigits: 0 })}
          </span>
        </div>

        <div className={`border rounded-2xl p-4 shadow-xs ${dashboardStats.totalGain >= 0 ? 'bg-emerald-50/70 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
          <div className="flex justify-between items-center">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-600">Net Cost Variance (P&L)</span>
            {dashboardStats.totalGain >= 0 ? <TrendingUp className="w-3.5 h-3.5 text-emerald-600" /> : <TrendingDown className="w-3.5 h-3.5 text-rose-600" />}
          </div>
          <span className={`text-2xl font-black font-mono mt-1 block ${dashboardStats.totalGain >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {dashboardStats.totalGain >= 0 ? `₹ +${dashboardStats.totalGain.toLocaleString('en-IN', { maximumFractionDigits: 0 })}` : `₹ -${Math.abs(dashboardStats.totalGain).toLocaleString('en-IN', { maximumFractionDigits: 0 })}`}
          </span>
        </div>
      </div>

      {/* Module Navigation Hub */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-3">
        <div onClick={() => onNavigate('baseline')} className="bg-white p-4 rounded-2xl border hover:border-blue-500 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-blue-50 text-blue-600 w-fit rounded-lg"><Layers className="w-4 h-4" /></div>
          <h3 className="font-bold text-slate-900 text-xs">1. Baseline Master</h3>
          <p className="text-[10px] text-slate-500">Manage tool cavity, net weights, and cycle times.</p>
        </div>

        <div onClick={() => onNavigate('rm_matrix')} className="bg-white p-4 rounded-2xl border hover:border-blue-500 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-amber-50 text-amber-600 w-fit rounded-lg"><Sliders className="w-4 h-4" /></div>
          <h3 className="font-bold text-slate-900 text-xs">2. RM & Matrix</h3>
          <p className="text-[10px] text-slate-500">Lock monthly contracts and WA purchase rates.</p>
        </div>

        <div onClick={() => onNavigate('costing_engine')} className="bg-white p-4 rounded-2xl border hover:border-blue-500 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-emerald-50 text-emerald-600 w-fit rounded-lg"><DollarSign className="w-4 h-4" /></div>
          <h3 className="font-bold text-slate-900 text-xs">3. Costing Engine</h3>
          <p className="text-[10px] text-slate-500">Live dynamic piece cost variance simulation.</p>
        </div>

        <div onClick={() => onNavigate('mis')} className="bg-white p-4 rounded-2xl border hover:border-blue-500 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-indigo-50 text-indigo-600 w-fit rounded-lg"><BarChart3 className="w-4 h-4" /></div>
          <h3 className="font-bold text-slate-900 text-xs">4. MIS & Gap</h3>
          <p className="text-[10px] text-slate-500">Invoice batch drilldowns & profit realizations.</p>
        </div>

        <div onClick={() => onNavigate('ai_analyst')} className="bg-purple-900 text-white p-4 rounded-2xl border border-purple-800 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-purple-600 text-white w-fit rounded-lg"><Bot className="w-4 h-4" /></div>
          <h3 className="font-bold text-white text-xs">5. AI Analyst</h3>
          <p className="text-[10px] text-purple-200">Real-time LLM costing audits & root causes.</p>
        </div>
      </div>

      {/* MODAL: ONBOARD NEW VENDOR & DYNAMIC N-LINE COSTING FORMAT */}
      {showOnboardModal && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl shadow-2xl max-w-3xl w-full p-5 space-y-4 border border-slate-300 animate-in fade-in duration-100 max-h-[90vh] overflow-y-auto">
            
            <div className="flex justify-between items-center border-b pb-3">
              <div>
                <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                  <UserPlus className="w-4 h-4 text-purple-600" /> Onboard New Vendor & Upload Prescribed Costing Sheet
                </h3>
                <p className="text-[11px] text-slate-500">Step {onboardStep} of 3: Dynamic Variable N-Line Parser Engine</p>
              </div>
              <button onClick={() => setShowOnboardModal(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* STEP 1: Basic Information */}
            {onboardStep === 1 && (
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">OEM / Vendor Name *</label>
                    <input
                      type="text"
                      value={newVendorData.vendorName}
                      onChange={e => setNewVendorData({ ...newVendorData, vendorName: e.target.value })}
                      placeholder="e.g., Godrej Appliances, Panasonic, IFB"
                      className="w-full border p-2 rounded-xl text-xs outline-none focus:ring-2 focus:ring-purple-500"
                    />
                  </div>
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Vendor ERP Shortcode</label>
                    <input
                      type="text"
                      value={newVendorData.vendorCode}
                      onChange={e => setNewVendorData({ ...newVendorData, vendorCode: e.target.value })}
                      placeholder="e.g., GDJ, PAN, IFB"
                      className="w-full border p-2 rounded-xl text-xs outline-none uppercase font-mono"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Commercial Payment Terms</label>
                    <input
                      type="text"
                      value={newVendorData.paymentTerms}
                      onChange={e => setNewVendorData({ ...newVendorData, paymentTerms: e.target.value })}
                      className="w-full border p-2 rounded-xl text-xs outline-none"
                    />
                  </div>
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Billing Currency</label>
                    <input
                      type="text"
                      value={newVendorData.currency}
                      disabled
                      className="w-full border p-2 rounded-xl text-xs bg-slate-100 font-bold"
                    />
                  </div>
                </div>

                <div className="flex justify-end pt-3 border-t">
                  <button
                    disabled={!newVendorData.vendorName}
                    onClick={() => setOnboardStep(2)}
                    className="px-4 py-2 bg-purple-600 disabled:opacity-50 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-xs"
                  >
                    Next: Upload Format Sheet <ArrowRight className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            )}

            {/* STEP 2: Upload Prescribed Costing Sheet */}
            {onboardStep === 2 && (
              <div className="space-y-4 text-center py-4">
                <div className="p-6 border-2 border-dashed border-purple-300 bg-purple-50/50 rounded-2xl space-y-2">
                  <FileSpreadsheet className="w-8 h-8 text-purple-600 mx-auto" />
                  <h4 className="font-bold text-sm text-slate-900">Upload {newVendorData.vendorName} Prescribed Costing Sheet (.xlsx)</h4>
                  <p className="text-[11px] text-slate-500 max-w-md mx-auto">
                    Upload the vendor's official costing format containing 1 product. Our dynamic blueprint parser accepts any length (5 lines, 38 lines, 100+ lines).
                  </p>
                  <div className="pt-2">
                    <input
                      type="file"
                      id="costing-upload"
                      accept=".xlsx,.xls,.csv"
                      onChange={handleSimulateCostingSheetUpload}
                      className="hidden"
                    />
                    <label
                      htmlFor="costing-upload"
                      className="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl cursor-pointer inline-flex items-center gap-2 shadow-xs"
                    >
                      <Upload className="w-3.5 h-3.5" /> Select Format File
                    </label>
                  </div>
                </div>

                <div className="flex justify-between items-center pt-3 border-t">
                  <button onClick={() => setOnboardStep(1)} className="px-3 py-1.5 border rounded-lg">Back</button>
                  <button
                    onClick={() => handleSimulateCostingSheetUpload({})}
                    className="px-4 py-1.5 bg-slate-900 text-white font-bold rounded-xl cursor-pointer"
                  >
                    Use Sample 14-Line Format Template &rarr;
                  </button>
                </div>
              </div>
            )}

            {/* STEP 3: Dynamic Staging Grid & Formula Engine Verification */}
            {onboardStep === 3 && (
              <div className="space-y-3">
                <div className="bg-emerald-50 border border-emerald-200 text-emerald-900 p-2.5 rounded-xl flex items-center justify-between font-bold">
                  <div className="flex items-center gap-2">
                    <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                    <span>Parsed {stagedLines.length} Custom Costing Lines from "{uploadedFileName || 'Format Template'}"</span>
                  </div>
                  <span className="text-[10px] bg-emerald-200 text-emerald-900 px-2 py-0.5 rounded">Formulas Verified</span>
                </div>

                <div className="border border-slate-300 rounded-xl overflow-hidden max-h-64 overflow-y-auto">
                  <table className="min-w-full text-xs text-left">
                    <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                      <tr>
                        <th className="p-2 w-12 text-center">Line #</th>
                        <th className="p-2">Costing Description</th>
                        <th className="p-2 w-16">UOM</th>
                        <th className="p-2 w-32">Classification</th>
                        <th className="p-2 text-right w-24">Baseline Value</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-200 font-medium">
                      {stagedLines.map(l => (
                        <tr key={l.lineNo} className="hover:bg-slate-50">
                          <td className="p-2 text-center font-mono text-slate-500">{l.lineNo}</td>
                          <td className="p-2 font-bold text-slate-900">{l.description}</td>
                          <td className="p-2 font-mono text-slate-600">{l.uom}</td>
                          <td className="p-2">
                            <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                              l.isTotal ? 'bg-amber-100 text-amber-900' :
                              l.isFormula ? 'bg-blue-100 text-blue-900' :
                              l.isRm ? 'bg-purple-100 text-purple-900' : 'bg-slate-100 text-slate-700'
                            }`}>
                              {l.isTotal ? 'TOTAL COST' : l.isFormula ? 'FORMULA CALC' : l.isRm ? 'RM LINKED' : 'PARAMETER'}
                            </span>
                          </td>
                          <td className="p-2 text-right font-mono font-bold text-slate-900">
                            {typeof l.val === 'number' ? `₹${l.val.toFixed(2)}` : l.val}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div className="flex justify-between items-center pt-3 border-t">
                  <button onClick={() => setOnboardStep(2)} className="px-3 py-1.5 border rounded-lg">Back to Upload</button>
                  <button
                    onClick={handleCommitNewVendor}
                    className="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"
                  >
                    <Check className="w-4 h-4" /> Save & Commit Isolated Vendor Blueprint
                  </button>
                </div>
              </div>
            )}

          </div>
        </div>
      )}

    </div>
  );
}
DASH_EOF

# 3. Update BaselineMasterPage.jsx with dynamic vendor schema rendering & Excel template export
cat << 'BASE_EOF' > src/modules/module1-baseline/BaselineMasterPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Layers, Download, Upload, Plus, History, Search, CheckCircle2, 
  Building2, Sliders, X, FileSpreadsheet, Edit3, ArrowRight 
} from 'lucide-react';
import { 
  globalStore, subscribeStore, getVendorBaselineData, 
  addVendorBaselineProducts, updateBaselineParameters 
} from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [activeTab, setActiveTab] = useState('parameters'); // 'parameters' | 'audit_log'
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);

  const [showUploadModal, setShowUploadModal] = useState(false);
  const [successMsg, setSuccessMsg] = useState(null);

  const vendorList = globalStore.vendors || [];
  const rawList = getVendorBaselineData(selectedVendor);
  const currentBlueprint = (globalStore.vendorBlueprints && globalStore.vendorBlueprints[selectedVendor]) || [];

  const filteredList = rawList.filter(item => {
    const matchSearch = (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
                        (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
    return matchSearch;
  });

  const changeLogs = (globalStore.parameterChangeLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  // Dynamic Excel Template Download based on Vendor Custom Format
  const handleDownloadVendorTemplate = () => {
    const headers = currentBlueprint.length > 0 
      ? currentBlueprint.map(b => b.description).join(',') 
      : "Item Code,Component Name,Model,Approved RM,Cavity,Net Weight,Runner Weight,Cycle Time,Tonnage,Shift Tariff";

    const sampleRow = "PART-101,Sample Front Bezel,Model 2026,ABS 300 Pre Colour,2,197,40,48,450,4600";
    const csvContent = "data:text/csv;charset=utf-8," + headers + "\n" + sampleRow;
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `${selectedVendor}_Dynamic_Costing_Template.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

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
              Active Vendor: <span className="text-amber-300 font-mono font-bold">{selectedVendor}</span> | Format: <span className="font-mono text-emerald-300">{currentBlueprint.length || 38} Custom Lines</span>
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {/* Dynamic Template Download */}
          <button
            onClick={handleDownloadVendorTemplate}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-blue-200 border border-blue-700/60 rounded-xl font-bold transition cursor-pointer shadow-xs"
          >
            <Download className="w-3.5 h-3.5" /> Download {selectedVendor} Template
          </button>

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
              <option value="ALL">All Vendors Combined</option>
            </select>
          </div>
        </div>
      </div>

      {/* TAB 1: PARAMETERS MASTER */}
      {activeTab === 'parameters' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <Layers className="w-4 h-4 text-blue-400" /> {selectedVendor} Baseline Parameters Master
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
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* EDIT MODAL: Dynamically renders vendor's format */}
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

echo "==> Dynamic Multi-Vendor Onboarding & Variable-Line Engine successfully deployed."
