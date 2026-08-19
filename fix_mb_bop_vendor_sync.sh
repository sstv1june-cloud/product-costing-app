#!/usr/bin/env bash
set -e

# 1. Update masterStore.js with unified vendor lists, MB matrices, and BOP parameter fields
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';
import { calculateDetailedCost } from '../modules/module1-baseline/InlineEditModal';

const initialData = Array.isArray(initialBaselineData) ? initialBaselineData : [];

export const haierBlueprint = [
  { lineNo: 1, description: "Name Of Component", uom: "-", type: "text", mapping: "componentName", classification: "HEADER" },
  { lineNo: 2, description: "Mould Size L * W * H", uom: "mm", type: "text", mapping: "mouldSize", classification: "HEADER" },
  { lineNo: 3, description: "Item No. / Code", uom: "-", type: "text", mapping: "itemCode", classification: "HEADER" },
  { lineNo: 4, description: "Model", uom: "-", type: "text", mapping: "model", classification: "HEADER" },
  { lineNo: 5, description: "Raw Material Required (Locked & Linked to RM Sheet)", uom: "-", type: "text", mapping: "approvedRm", classification: "RM LINKED" },
  { lineNo: 6, description: "Master Batch Required", uom: "%", type: "number", mapping: "masterbatchPct", classification: "PARAMETER" },
  { lineNo: 7, description: "MB Approved Rate", uom: "₹/kg", type: "number", mapping: "masterbatchRate", classification: "MB RM LINKED" },
  { lineNo: 8, description: "Inserts / BOP Cost", uom: "₹/pc", type: "number", mapping: "bopCost", classification: "PARAMETER" },
  { lineNo: 9, description: "No. of Cavity", uom: "Nos", type: "number", mapping: "cavity", classification: "PARAMETER" },
  { lineNo: 10, description: "Runner Weight", uom: "Gms", type: "number", mapping: "runnerWeight", classification: "PARAMETER" },
  { lineNo: 11, description: "Net Weight", uom: "Gms", type: "number", mapping: "netWeight", classification: "PARAMETER" },
  { lineNo: 12, description: "Cycle Time Approved", uom: "Sec", type: "number", mapping: "cycleTimeApproved", classification: "PARAMETER" },
  { lineNo: 13, description: "Machine Tonnage", uom: "T", type: "number", mapping: "machineTonnage", classification: "PARAMETER" },
  { lineNo: 14, description: "Hourly Shift Machine Tariff", uom: "₹/hr", type: "number", mapping: "hourlyRate", classification: "PARAMETER" },
  { lineNo: 15, description: "TOTAL COMPONENT BASELINE COST", uom: "₹", type: "total", classification: "TOTAL COST" }
];

export const globalStore = {
  vendors: [
    { vendorId: "Haier", vendorName: "Haier Appliances", code: "HAIER", paymentTerms: "60 to 45 Days", active: true, lineCount: 38 },
    { vendorId: "LG", vendorName: "LG Electronics", code: "LG", paymentTerms: "45 Days", active: true, lineCount: 9 },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India", code: "WHIRLPOOL", paymentTerms: "60 Days", active: true, lineCount: 7 },
    { vendorId: "Atomberg", vendorName: "Atomberg Technologies", code: "ATOM", paymentTerms: "45 Days", active: true, lineCount: 39 }
  ],

  vendorBlueprints: {
    Haier: haierBlueprint,
    Atomberg: []
  },

  vendorBaselines: {
    Haier: initialData.filter(d => (d.vendor || 'Haier') === 'Haier'),
    LG: initialData.filter(d => d.vendor === 'LG'),
    Whirlpool: initialData.filter(d => d.vendor === 'Whirlpool'),
    Atomberg: [
      {
        id: "BL-ATOM-001",
        vendor: "Atomberg",
        itemCode: "A101701",
        componentName: "Aris Top Canopy- Gloss White",
        model: "Aris",
        mouldSize: "950*600*450",
        approvedRm: "PP H110MA",
        approvedRmRate: 135.83,
        masterbatchPct: 4.0,
        masterbatchRate: 258.54,
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
    ]
  },

  baselineList: initialData,

  purchaseMaster: [
    { code: "PUR-ABS-01", invoiceNo: "INV-PUR-8821", name: "ABS 300-B Red (Prime Inward)", polymer: "ABS", supplier: "Supreme Petrochem", waPrice: 134.80, inwardDate: "2026-08-01", qtyKg: 12500 },
    { code: "PUR-ABS-02", invoiceNo: "INV-PUR-8822", name: "ABS 300-Blue (Imported)", polymer: "ABS", supplier: "Chi Mei", waPrice: 131.25, inwardDate: "2026-08-05", qtyKg: 8200 },
    { code: "PUR-GPPS-01", invoiceNo: "INV-PUR-8824", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", polymer: "GPPS", supplier: "Supreme", waPrice: 98.40, inwardDate: "2026-08-03", qtyKg: 9000 },
    { code: "PUR-PP-01", invoiceNo: "INV-PUR-8830", name: "PP H110MA Prime Inward", polymer: "PP", supplier: "Reliance Industries", waPrice: 135.83, inwardDate: "2026-08-02", qtyKg: 10000 },
    { code: "PUR-MB-01", invoiceNo: "INV-PUR-8831", name: "White Masterbatch 258 Grade", polymer: "MB", supplier: "Clariant Masterbatches", waPrice: 258.54, inwardDate: "2026-08-02", qtyKg: 1500 }
  ],

  salesData: [
    { id: "INV-SLS-001", invoiceNo: "INV-SLS-001", itemCode: "0060226713H", componentName: "End Cap Top Ref (without Screen Painting )", vendor: "Haier", saleUnit: 4500, invoiceDate: "2026-08-05", sellingPrice: 38.50 },
    { id: "INV-SLS-002", invoiceNo: "INV-SLS-002", itemCode: "0060217989D", componentName: "End cap Bottom Ref-ABS-DC-195,220", vendor: "Haier", saleUnit: 4200, invoiceDate: "2026-08-10", sellingPrice: 42.00 },
    { id: "INV-SLS-003", invoiceNo: "INV-SLS-003", itemCode: "0060217978E", componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX", vendor: "Haier", saleUnit: 1800, invoiceDate: "2026-08-12", sellingPrice: 85.00 },
    { id: "INV-SLS-004", invoiceNo: "INV-SLS-004", itemCode: "A101701", componentName: "Aris Top Canopy- Gloss White", vendor: "Atomberg", saleUnit: 3500, invoiceDate: "2026-08-15", sellingPrice: 14.50 }
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
    },
    {
      id: "RM-ATOM-PP-P1",
      vendor: "Atomberg",
      approvedRm: "PP H110MA",
      polymer: "PP",
      approvedPrice: 135.83,
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
      approvedPrice: 258.54,
      validFrom: "2026-08-01",
      validTo: "2026-08-31",
      activeSelection: "alt1",
      alt1: { code: "PUR-MB-01", name: "White Masterbatch 258 Grade", waPrice: 258.54 }
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
      id: `BL-${vId.toUpperCase()}-${Date.now()}`,
      vendor: vId,
      itemCode: initialProduct.itemCode || 'PART-001',
      componentName: initialProduct.componentName || 'Sample Component',
      model: initialProduct.model || 'Platform Standard',
      mouldSize: initialProduct.mouldSize || '950*600*450',
      approvedRm: initialProduct.approvedRm || 'PP H110MA',
      approvedRmRate: Number(initialProduct.approvedRmRate || 135.83),
      masterbatchPct: Number(initialProduct.masterbatchPct || 4.0),
      masterbatchRate: Number(initialProduct.masterbatchRate || 258.54),
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
        shiftTariff: (Number(initialProduct.machineTonnage || 200) >= 600 ? 4800 : 2000),
        bopCost: Number(initialProduct.bopCost || 0.0),
        masterbatchPct: Number(initialProduct.masterbatchPct || 4.0)
      }
    };
    
    // Check if item already exists to update
    const existingIdx = globalStore.vendorBaselines[vId].findIndex(p => p.itemCode === formatted.itemCode);
    if (existingIdx >= 0) {
      globalStore.vendorBaselines[vId][existingIdx] = formatted;
    } else {
      globalStore.vendorBaselines[vId].push(formatted);
    }

    // Register RM Matrix item
    if (!globalStore.rmMatrix.find(r => r.vendor === vId && r.approvedRm === formatted.approvedRm)) {
      globalStore.rmMatrix.push({
        id: `RM-${vId}-P1`,
        vendor: vId,
        approvedRm: formatted.approvedRm,
        polymer: formatted.approvedRm.split(' ')[0] || "PP",
        approvedPrice: Number(formatted.approvedRmRate),
        validFrom: "2026-08-01",
        validTo: "2026-08-31",
        activeSelection: "alt1",
        alt1: { code: "PUR-PP-01", name: `${formatted.approvedRm} Inward Standard`, waPrice: Number(formatted.approvedRmRate) }
      });
    }

    // Register MB Matrix item
    if (!globalStore.rmMatrix.find(r => r.vendor === vId && r.polymer === 'MB')) {
      globalStore.rmMatrix.push({
        id: `RM-${vId}-MB1`,
        vendor: vId,
        approvedRm: "MB Grade " + (formatted.approvedRm || ''),
        polymer: "MB",
        approvedPrice: Number(formatted.masterbatchRate || 258.54),
        validFrom: "2026-08-01",
        validTo: "2026-08-31",
        activeSelection: "alt1",
        alt1: { code: "PUR-MB-01", name: "White Masterbatch 258 Grade", waPrice: Number(formatted.masterbatchRate || 258.54) }
      });
    }
  }

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
      approvedPrice: 135.83,
      activeRmName: approvedRmName || "Standard Polymer",
      activeWaPrice: 135.83,
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

    const oldMbPct = Number(prev.masterbatchPct ?? prevParams.masterbatchPct ?? 4);
    const newMbPct = Number(newParams.runningMbPct ?? updatedItem.masterbatchPct ?? oldMbPct);
    if (Math.abs(oldMbPct - newMbPct) >= 0.01) {
      const d = Number((newMbPct - oldMbPct).toFixed(2));
      changesList.push({ parameter: "MB %", oldVal: `${oldMbPct}%`, newVal: `${newMbPct}%`, diff: `${d > 0 ? '+' : ''}${d}%` });
    }

    const oldBop = Number(prev.bopCost ?? prevParams.bopCost ?? 0);
    const newBop = Number(newParams.runningBopCost ?? updatedItem.bopCost ?? oldBop);
    if (Math.abs(oldBop - newBop) >= 0.01) {
      const d = Number((newBop - oldBop).toFixed(2));
      changesList.push({ parameter: "BOP Cost", oldVal: `₹${oldBop}`, newVal: `₹${newBop}`, diff: `${d > 0 ? '+' : ''}₹${d}` });
    }

    globalStore.baselineList[idx] = {
      ...prev,
      ...updatedItem,
      masterbatchPct: newMbPct,
      bopCost: newBop,
      parameters: {
        ...prevParams,
        ...newParams,
        masterbatchPct: newMbPct,
        bopCost: newBop
      },
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

# 2. Update BaselineMasterPage.jsx with VERTICAL TEMPLATE EXPORT & Dynamic Blueprint Support
cat << 'BASE_PAGE_EOF' > src/modules/module1-baseline/BaselineMasterPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Layers, Download, Upload, Plus, History, Search, CheckCircle2, 
  Building2, Sliders, X, FileSpreadsheet, Edit3, ArrowRight 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, subscribeStore, getVendorBaselineData, 
  addVendorBaselineProducts, updateBaselineParameters 
} from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [activeTab, setActiveTab] = useState('parameters');
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);

  const vendorList = globalStore.vendors || [];
  const rawList = getVendorBaselineData(selectedVendor);
  const currentBlueprint = (globalStore.vendorBlueprints && globalStore.vendorBlueprints[selectedVendor]) || [];

  const filteredList = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  const changeLogs = (globalStore.parameterChangeLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  // Vertical Excel (.xlsx) Template Exporter matching Vendor Costing Sheet Layout
  const handleDownloadVerticalTemplate = () => {
    const defaultVerticalLines = [
      ["", "Vendor", "", selectedVendor],
      ["", "Part Code", "", "A101701"],
      ["", "Part name", "", "Aris Top Canopy- Gloss White"],
      ["", "RM grade", "", "PP H110MA"],
      ["", "RM Base Rate", "", 133],
      ["", "ICC Cost @ 1% of RM", "", 1.33],
      ["", "Fright Cost", "", 1.5],
      ["", "RM Landed Cost", "", 135.83],
      ["", "MB Base Cost", "", 254],
      ["", "MB-ICC Cost @ 1% of MB", "", 2.54],
      ["", "Fright Cost", "", 2],
      ["", "MB Landed Cost", "", 258.54],
      ["", "MB %", "", 0.04],
      ["", "RM cost( PP + MB) /KG", "", 140.7384],
      ["", "part weight grams", "", 37],
      ["", "Runner weight grams", "", 1],
      ["", "Gross weight", "", 38],
      ["", "RM cost", "", 5.3481],
      ["", "Inserts/BOP cost", "", 0.00],
      ["", "RM + BOP Cost", "", 5.3481],
      ["", "M/c tonnage", "", 200],
      ["", "shift rate", 10.00, 2000],
      ["", "cycle time( seconds)", "", 47],
      ["", "Efficiency", 0.90, 0.9],
      ["", "No of cavity", "", 2],
      ["", "No. of parts/shift", "", 1102.98],
      ["", "Process cost", "", 1.8133],
      ["", "Handling cost for BOP", 0.03, 0],
      ["", "Post operation cost", "", 1.73],
      ["", "Total Process Cost", "", 3.5433],
      ["", "Profit & OH", 0.12, 1.0670],
      ["", "Inprocess Rejection", 0.03, 0.3557],
      ["", "Runner recovery cost", 25.00, -0.025],
      ["", "ICC", 0.02, 0],
      ["", "Packing cost", "", 0.86],
      ["", "Transpost cost", 10.00, 0.62],
      ["", "Mould maintanance cost", 0.02, 0.0709],
      ["", "Other Cost", "", 2.9485],
      ["", "Final Landed cost", "", 11.8398]
    ];

    const ws = XLSX.utils.aoa_to_sheet(defaultVerticalLines);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Standard_Format");
    XLSX.writeFile(wb, `${selectedVendor}_Approved_Costing_Format.xlsx`);
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
              Active Vendor: <span className="text-amber-300 font-mono font-bold">{selectedVendor}</span> | Format: <span className="font-mono text-emerald-300">Vertical OEM Specification Sheet</span>
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {/* Download Vertical Format Excel */}
          <button
            onClick={handleDownloadVerticalTemplate}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl transition cursor-pointer shadow-xs"
          >
            <Download className="w-3.5 h-3.5" /> Download {selectedVendor} Vertical Format (.xlsx)
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

      {/* Switch Vendor Strip */}
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
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 text-xs font-bold bg-white text-blue-950 outline-none cursor-pointer"
            >
              {vendorList.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors Combined</option>
            </select>
          </div>
        </div>
      </div>

      {/* PARAMETERS MASTER TABLE */}
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
                  <th className="p-3 min-w-[190px]">Item Code / Component</th>
                  <th className="p-3">Model</th>
                  <th className="p-3">Approved RM / MB</th>
                  <th className="p-3 text-center">MB %</th>
                  <th className="p-3 text-right">BOP Cost</th>
                  <th className="p-3 text-center">Cavity</th>
                  <th className="p-3 text-right">Net Wt</th>
                  <th className="p-3 text-right">Runner Wt</th>
                  <th className="p-3 text-center">Cycle Time</th>
                  <th className="p-3 text-center">Tonnage</th>
                  <th className="p-3 text-right">Shift Tariff</th>
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
                    <td className="p-3 text-slate-700 font-semibold">{item.model || 'Standard'}</td>
                    <td className="p-3">
                      <span className="font-semibold text-slate-900 block">{item.approvedRm}</span>
                      <span className="text-[10px] text-slate-500 font-mono">₹{item.approvedRmRate || 135.83}/kg</span>
                    </td>
                    <td className="p-3 text-center font-mono font-bold text-purple-700">
                      {(item.masterbatchPct || 0).toFixed(2)}%
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-700">
                      ₹{(item.bopCost || 0).toFixed(2)}
                    </td>
                    <td className="p-3 text-center font-bold font-mono text-slate-900">{item.cavity || 1}</td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">{item.netWeight || 37}g</td>
                    <td className="p-3 text-right font-mono text-slate-600">{item.runnerWeight || 1}g</td>
                    <td className="p-3 text-center">
                      <span className="bg-amber-100 text-amber-900 font-mono font-bold px-2 py-0.5 rounded text-[11px]">
                        {item.cycleTimeApproved || item.cycleTime || 47}s
                      </span>
                    </td>
                    <td className="p-3 text-center font-mono font-bold text-slate-700">{item.machineTonnage || 200}T</td>
                    <td className="p-3 text-right font-mono font-semibold text-slate-700">
                      ₹{item.hourlyRate ? (item.hourlyRate * 8) : 2000}
                    </td>
                    <td className="p-3 text-center">
                      <button
                        type="button"
                        onClick={() => setEditingItem(item)}
                        className="p-1.5 bg-blue-50 hover:bg-blue-600 text-blue-600 hover:text-white rounded-lg transition cursor-pointer border border-blue-200 shadow-xs inline-flex items-center justify-center"
                        title="Edit Baseline & Running Parameters"
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

      {/* PARAMETER AUDIT LOG */}
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
            setSuccessMsg(`Parameter change saved and logged for ${editingItem.itemCode}`);
            setTimeout(() => setSuccessMsg(null), 3000);
          }}
        />
      )}

    </div>
  );
}
BASE_PAGE_EOF

# 3. Update InlineEditModal.jsx with MB %, MB Approved Rate, and BOP Parameter editing
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState, useEffect } from 'react';
import { X, Check, Save, RotateCcw, AlertTriangle, ShieldCheck, HelpCircle } from 'lucide-react';
import { getActiveRmMapping } from '../../shared/masterStore';

export function calculateDetailedCost(params, isBaseline = false) {
  const cavity = Math.max(1, Number(params.cavity) || 1);
  const netWeight = Number(params.netWeight) || 0;
  const runnerWeight = Number(params.runnerWeight) || 0;
  const rmRate = Number(params.rmRate) || 0;
  const mbPct = Number(params.masterbatchPct) || 0;
  const mbRate = Number(params.masterbatchRate) || (rmRate * 1.9);
  const bopCost = Number(params.bopCost) || 0;
  const cycleTime = Number(params.cycleTime) || 1;
  const hourlyRate = Number(params.shiftTariff ? params.shiftTariff / 8 : (params.hourlyRate || 250));

  const totalShotWeight = (netWeight * cavity) + runnerWeight;
  const shotWeightPerPiece = totalShotWeight / cavity;
  const meltLossMultiplier = 1.01;
  const grossReconciledWeight = shotWeightPerPiece * meltLossMultiplier;

  // Raw Material Cost & MB calculations
  const pureRmFraction = Math.max(0, 1 - (mbPct / 100));
  const mbFraction = mbPct / 100;

  const pureRmCost = (grossReconciledWeight / 1000) * rmRate * pureRmFraction;
  const masterbatchCost = (grossReconciledWeight / 1000) * mbRate * mbFraction;
  const runnerCredit = (runnerWeight / cavity / 1000) * (rmRate * 0.25);

  const netRmCost = Math.max(0, (pureRmCost + masterbatchCost) - runnerCredit);

  // Machine Conversion Calculation
  const shotsPerHour = 3600 / cycleTime;
  const partsPerHour = shotsPerHour * cavity;
  const conversionCost = partsPerHour > 0 ? (hourlyRate / partsPerHour) : 0;

  const totalCost = netRmCost + conversionCost + bopCost;

  return {
    cavity,
    netWeight,
    runnerWeight,
    shotWeightPerPiece,
    grossReconciledWeight,
    pureRmCost,
    masterbatchCost,
    runnerCredit,
    netRmCost,
    conversionCost,
    bopCost,
    totalCost,
    partsPerHour
  };
}

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const rmInfo = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');

  // Baseline initial state
  const baseCavity = Number(item.cavity || 1);
  const baseNetWt = Number(item.netWeight || 37);
  const baseRunnerWt = Number(item.runnerWeight || 1);
  const baseMbPct = Number(item.masterbatchPct !== undefined ? item.masterbatchPct : 4.0);
  const baseMbRate = Number(item.masterbatchRate || 258.54);
  const baseBopCost = Number(item.bopCost || 0.0);
  const baseCycle = Number(item.cycleTimeApproved || item.cycleTime || 47);
  const baseTonnage = Number(item.machineTonnage || 200);
  const baseHourly = Number(item.hourlyRate || 250);
  const baseRmRate = Number(item.approvedRmRate || rmInfo.approvedPrice || 135.83);

  // Actual Running Editable Form State
  const [runningCavity, setRunningCavity] = useState(item.parameters?.runningCavity ?? baseCavity);
  const [runningNetWeight, setRunningNetWeight] = useState(item.parameters?.runningNetWeight ?? baseNetWt);
  const [runningRunnerWeight, setRunningRunnerWeight] = useState(item.parameters?.runningRunnerWeight ?? baseRunnerWt);
  const [runningMbPct, setRunningMbPct] = useState(item.parameters?.runningMbPct ?? baseMbPct);
  const [runningBopCost, setRunningBopCost] = useState(item.parameters?.runningBopCost ?? baseBopCost);
  const [runningCycleTime, setRunningCycleTime] = useState(item.parameters?.runningCycleTime ?? baseCycle);
  const [runningTonnage, setRunningTonnage] = useState(item.parameters?.runningTonnage ?? baseTonnage);
  const [reason, setReason] = useState("Shopfloor parameters & MB tuning");

  const baselineCalc = calculateDetailedCost({
    cavity: baseCavity,
    netWeight: baseNetWt,
    runnerWeight: baseRunnerWt,
    rmRate: baseRmRate,
    masterbatchPct: baseMbPct,
    masterbatchRate: baseMbRate,
    bopCost: baseBopCost,
    cycleTime: baseCycle,
    hourlyRate: baseHourly
  }, true);

  const runningCalc = calculateDetailedCost({
    cavity: Number(runningCavity),
    netWeight: Number(runningNetWeight),
    runnerWeight: Number(runningRunnerWeight),
    rmRate: Number(rmInfo.activeWaPrice || baseRmRate),
    masterbatchPct: Number(runningMbPct),
    masterbatchRate: baseMbRate,
    bopCost: Number(runningBopCost),
    cycleTime: Number(runningCycleTime),
    hourlyRate: Number(runningTonnage >= 600 ? 600 : baseHourly)
  }, false);

  const costVariance = Number((runningCalc.totalCost - baselineCalc.totalCost).toFixed(2));

  const handleSave = () => {
    onSave({
      updatedItem: {
        ...item,
        masterbatchPct: Number(runningMbPct),
        bopCost: Number(runningBopCost),
        parameters: {
          ...item.parameters,
          runningCavity: Number(runningCavity),
          runningNetWeight: Number(runningNetWeight),
          runningRunnerWeight: Number(runningRunnerWeight),
          runningMbPct: Number(runningMbPct),
          runningBopCost: Number(runningBopCost),
          runningCycleTime: Number(runningCycleTime),
          runningTonnage: Number(runningTonnage),
          runningShiftTariff: (runningTonnage >= 600 ? 4800 : 2000)
        }
      },
      changeType: "Shopfloor Spec Adjustment",
      reason
    });
  };

  return (
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
      <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full p-5 space-y-4 border border-slate-300 max-h-[92vh] overflow-y-auto">
        
        {/* Header */}
        <div className="flex justify-between items-center border-b pb-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="bg-blue-600 text-white font-mono px-2 py-0.5 rounded font-bold">{item.itemCode}</span>
              <h2 className="text-sm font-bold text-slate-900">{item.componentName}</h2>
            </div>
            <p className="text-[11px] text-slate-500 font-mono mt-0.5">
              Vendor: <span className="font-bold text-slate-700">{item.vendor}</span> | Model: {item.model}
            </p>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Cost Comparison Summary Pill */}
        <div className="grid grid-cols-3 gap-3">
          <div className="bg-slate-100 p-3 rounded-xl border border-slate-200">
            <span className="text-[10px] font-bold text-slate-500 uppercase block">Approved Baseline Contract</span>
            <span className="text-xl font-black text-slate-900 font-mono mt-1 block">₹{baselineCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-slate-500 font-mono">RM: ₹{baselineCalc.netRmCost.toFixed(2)} | Conv: ₹{baselineCalc.conversionCost.toFixed(2)}</span>
          </div>

          <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
            <span className="text-[10px] font-bold text-blue-700 uppercase block">Actual Running Shopfloor</span>
            <span className="text-xl font-black text-blue-900 font-mono mt-1 block">₹{runningCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-blue-600 font-mono">RM: ₹{runningCalc.netRmCost.toFixed(2)} | Conv: ₹{runningCalc.conversionCost.toFixed(2)}</span>
          </div>

          <div className={`p-3 rounded-xl border ${costVariance <= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
            <span className="text-[10px] font-bold text-slate-600 uppercase block">Cost Variance (Δ)</span>
            <span className={`text-xl font-black font-mono mt-1 block ${costVariance <= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
              ₹ {costVariance <= 0 ? `${costVariance.toFixed(2)}` : `+${costVariance.toFixed(2)}`}
            </span>
            <span className="text-[10px] font-semibold">{costVariance <= 0 ? 'Cost Optimization (Profit)' : 'Cost Escalation (Loss)'}</span>
          </div>
        </div>

        {/* Dynamic Dual-Column Spec Tuning Grid */}
        <div className="border border-slate-200 rounded-xl overflow-hidden">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
              <tr>
                <th className="p-2.5">Parameter / Spec Line</th>
                <th className="p-2.5 w-16 text-center">UOM</th>
                <th className="p-2.5 text-right w-36 bg-slate-200/60">Approved Baseline</th>
                <th className="p-2.5 text-left w-48 bg-blue-100/50">Actual Running (Shopfloor)</th>
                <th className="p-2.5 text-right w-24">Delta (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              
              {/* Raw Material Grade */}
              <tr>
                <td className="p-2.5 font-bold text-slate-900">Approved RM Grade (Locked & Linked)</td>
                <td className="p-2.5 text-center font-mono">-</td>
                <td className="p-2.5 text-right font-mono bg-slate-50 font-bold">{item.approvedRm} (₹{baseRmRate.toFixed(2)})</td>
                <td className="p-2.5 bg-blue-50/40 font-mono text-blue-900 font-bold">{rmInfo.activeRmName} (₹{rmInfo.activeWaPrice?.toFixed(2)})</td>
                <td className="p-2.5 text-right font-mono text-slate-500">{(rmInfo.activeWaPrice - baseRmRate).toFixed(2)}</td>
              </tr>

              {/* Masterbatch Percentage */}
              <tr className="bg-purple-50/30">
                <td className="p-2.5 font-bold text-purple-950">Masterbatch % (MB Rate: ₹{baseMbRate.toFixed(2)}/kg)</td>
                <td className="p-2.5 text-center font-mono">%</td>
                <td className="p-2.5 text-right font-mono font-bold bg-slate-50">{baseMbPct.toFixed(2)}%</td>
                <td className="p-2.5 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.1"
                    value={runningMbPct}
                    onChange={e => setRunningMbPct(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-1 rounded text-xs"
                  />
                </td>
                <td className="p-2.5 text-right font-mono font-bold text-purple-700">
                  {(Number(runningMbPct) - baseMbPct).toFixed(2)}%
                </td>
              </tr>

              {/* BOP Cost */}
              <tr>
                <td className="p-2.5 font-bold text-slate-900">Inserts / BOP Component Cost</td>
                <td className="p-2.5 text-center font-mono">₹/pc</td>
                <td className="p-2.5 text-right font-mono bg-slate-50">₹{baseBopCost.toFixed(2)}</td>
                <td className="p-2.5 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.01"
                    value={runningBopCost}
                    onChange={e => setRunningBopCost(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-1 rounded text-xs"
                  />
                </td>
                <td className="p-2.5 text-right font-mono font-bold text-slate-700">
                  ₹{(Number(runningBopCost) - baseBopCost).toFixed(2)}
                </td>
              </tr>

              {/* Cavity */}
              <tr>
                <td className="p-2.5 font-bold text-slate-900">Tool Cavity</td>
                <td className="p-2.5 text-center font-mono">Nos</td>
                <td className="p-2.5 text-right font-mono bg-slate-50">{baseCavity}</td>
                <td className="p-2.5 bg-blue-50/40">
                  <input
                    type="number"
                    value={runningCavity}
                    onChange={e => setRunningCavity(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-1 rounded text-xs"
                  />
                </td>
                <td className="p-2.5 text-right font-mono">{Number(runningCavity) - baseCavity}</td>
              </tr>

              {/* Net Weight */}
              <tr>
                <td className="p-2.5 font-bold text-slate-900">Part Net Weight</td>
                <td className="p-2.5 text-center font-mono">Gms</td>
                <td className="p-2.5 text-right font-mono bg-slate-50">{baseNetWt}</td>
                <td className="p-2.5 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.1"
                    value={runningNetWeight}
                    onChange={e => setRunningNetWeight(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-1 rounded text-xs"
                  />
                </td>
                <td className="p-2.5 text-right font-mono font-bold">{(Number(runningNetWeight) - baseNetWt).toFixed(1)}g</td>
              </tr>

              {/* Runner Weight */}
              <tr>
                <td className="p-2.5 font-bold text-slate-900">Runner Scrap Weight</td>
                <td className="p-2.5 text-center font-mono">Gms</td>
                <td className="p-2.5 text-right font-mono bg-slate-50">{baseRunnerWt}</td>
                <td className="p-2.5 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.1"
                    value={runningRunnerWeight}
                    onChange={e => setRunningRunnerWeight(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-1 rounded text-xs"
                  />
                </td>
                <td className="p-2.5 text-right font-mono">{(Number(runningRunnerWeight) - baseRunnerWt).toFixed(1)}g</td>
              </tr>

              {/* Cycle Time */}
              <tr>
                <td className="p-2.5 font-bold text-slate-900">Cycle Time</td>
                <td className="p-2.5 text-center font-mono">Sec</td>
                <td className="p-2.5 text-right font-mono bg-slate-50 font-bold">{baseCycle}s</td>
                <td className="p-2.5 bg-blue-50/40">
                  <input
                    type="number"
                    step="0.5"
                    value={runningCycleTime}
                    onChange={e => setRunningCycleTime(e.target.value)}
                    className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-1 rounded text-xs"
                  />
                </td>
                <td className="p-2.5 text-right font-mono font-bold text-blue-700">{(Number(runningCycleTime) - baseCycle).toFixed(1)}s</td>
              </tr>

            </tbody>
          </table>
        </div>

        {/* Change Reason & Commit */}
        <div className="space-y-2 pt-2 border-t">
          <div>
            <label className="font-bold text-slate-700 block mb-1">Reason for Shopfloor Spec Drift / Audit Trail Record *</label>
            <input
              type="text"
              value={reason}
              onChange={e => setReason(e.target.value)}
              placeholder="e.g. Inward lot masterbatch percentage verified & cycle time tuning"
              className="w-full border p-2 rounded-xl text-xs outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div className="flex justify-between items-center pt-2">
            <button onClick={onClose} className="px-3 py-1.5 border rounded-lg hover:bg-slate-50">Cancel</button>
            <button
              onClick={handleSave}
              className="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"
            >
              <Save className="w-4 h-4" /> Save & Log Parameter Changes
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}
MODAL_EOF

# 4. Update RMPriceMatrixPage.jsx to dynamically bind all onboarded vendors (including Atomberg)
cat << 'RM_PAGE_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Sliders, Lock, History, Search, CheckCircle2, ShieldCheck, 
  Building2, Calendar, FileSpreadsheet, Plus, Upload, AlertTriangle, ArrowRight 
} from 'lucide-react';
import { 
  globalStore, subscribeStore, updateVendorScheduleBulk, 
  addManualPurchaseRecord, addManualSaleRecord, uploadBulkPurchases, uploadBulkSales 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [activeSubTab, setActiveSubTab] = useState('matrix');
  const [validFrom, setValidFrom] = useState('2026-08-01');
  const [validTo, setValidTo] = useState('2026-08-31');
  const [successMsg, setSuccessMsg] = useState(null);

  const rmMatrix = globalStore.rmMatrix || [];
  const vendorRows = rmMatrix.filter(r => r.vendor === selectedVendor);
  const purchaseMaster = globalStore.purchaseMaster || [];
  const salesData = (globalStore.salesData || []).filter(s => selectedVendor === 'ALL' || s.vendor === selectedVendor);
  const rmHistoryLogs = (globalStore.rmPriceHistoryLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  const [localRows, setLocalRows] = useState([]);
  useEffect(() => {
    setLocalRows(JSON.parse(JSON.stringify(vendorRows)));
  }, [selectedVendor, rmMatrix]);

  const handleAlternateChange = (rowId, altKey, purchaseCode) => {
    const matchedPur = purchaseMaster.find(p => p.code === purchaseCode);
    setLocalRows(prev => prev.map(r => {
      if (r.id === rowId) {
        return {
          ...r,
          [altKey]: matchedPur ? { code: matchedPur.code, name: matchedPur.name, waPrice: matchedPur.waPrice } : null
        };
      }
      return r;
    }));
  };

  const handleSelectActive = (rowId, altKey) => {
    setLocalRows(prev => prev.map(r => r.id === rowId ? { ...r, activeSelection: altKey } : r));
  };

  const handleApprovedPriceEdit = (rowId, newPrice) => {
    setLocalRows(prev => prev.map(r => r.id === rowId ? { ...r, approvedPrice: Number(newPrice) || 0 } : r));
  };

  const handleSaveAndLock = () => {
    updateVendorScheduleBulk(selectedVendor, validFrom, validTo, localRows);
    setSuccessMsg(`Period tariff schedule successfully locked for ${selectedVendor} (${validFrom} to ${validTo})`);
    setTimeout(() => setSuccessMsg(null), 3500);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Header Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Sliders className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">2. RM & MB Tariff & Alternate Weighted Average (WA) Matrix</h1>
            <p className="text-[11px] text-slate-300">
              Active Scope: <span className="text-amber-300 font-bold">{selectedVendor}</span> | Validity: <span className="text-emerald-300 font-mono">{validFrom} &rarr; {validTo}</span>
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setActiveSubTab('matrix')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeSubTab === 'matrix' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300'
            }`}
          >
            RM & MB Schedule
          </button>
          <button
            onClick={() => setActiveSubTab('purchases')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeSubTab === 'purchases' ? 'bg-amber-600 text-white shadow' : 'bg-slate-800 text-slate-300'
            }`}
          >
            Purchases ({purchaseMaster.length})
          </button>
          <button
            onClick={() => setActiveSubTab('sales')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeSubTab === 'sales' ? 'bg-indigo-600 text-white shadow' : 'bg-slate-800 text-slate-300'
            }`}
          >
            Sales ({salesData.length})
          </button>
          <button
            onClick={() => setActiveSubTab('audit')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeSubTab === 'audit' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300'
            }`}
          >
            <History className="w-3.5 h-3.5 inline mr-1" /> Audit Trail ({rmHistoryLogs.length})
          </button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2.5 rounded-xl flex items-center gap-2 font-bold shadow-xs">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      {/* Control Strip */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700">SELECT VENDOR:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 border rounded-xl px-3 py-1 text-slate-700">
            <Calendar className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-[11px]">VALIDITY:</span>
            <input
              type="date"
              value={validFrom}
              onChange={e => setValidFrom(e.target.value)}
              className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs"
            />
            <span>&rarr;</span>
            <input
              type="date"
              value={validTo}
              onChange={e => setValidTo(e.target.value)}
              className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs"
            />
          </div>
        </div>

        {activeSubTab === 'matrix' && (
          <button
            onClick={handleSaveAndLock}
            className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"
          >
            <Lock className="w-3.5 h-3.5" /> Lock & Sync Period Schedule
          </button>
        )}
      </div>

      {/* SUBTAB 1: RM & MB MATRIX */}
      {activeSubTab === 'matrix' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-900 text-white font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-3 w-56">Approved RM / MB Specification</th>
                  <th className="p-3 w-32 text-right">Approved Rate (₹/kg)</th>
                  <th className="p-3">Alternate Inward Lot 1 (Dropdown)</th>
                  <th className="p-3 text-right w-24">WA Price</th>
                  <th className="p-3">Alternate Inward Lot 2 (Dropdown)</th>
                  <th className="p-3 text-right w-24">WA Price</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {localRows.map(row => (
                  <tr key={row.id} className="hover:bg-blue-50/30">
                    <td className="p-3">
                      <div className="flex items-center gap-1.5">
                        <Lock className="w-3 h-3 text-amber-500" />
                        <span className="font-bold text-slate-900">{row.approvedRm}</span>
                      </div>
                      <span className="text-[10px] text-purple-700 font-bold block">{row.polymer} Polymer Group</span>
                    </td>
                    <td className="p-3 text-right">
                      <input
                        type="number"
                        step="0.01"
                        value={row.approvedPrice}
                        onChange={e => handleApprovedPriceEdit(row.id, e.target.value)}
                        className="w-24 text-right border border-amber-300 bg-amber-50/50 font-mono font-black text-slate-900 p-1 rounded"
                      />
                    </td>
                    
                    {/* Alternate 1 */}
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <input
                          type="radio"
                          name={`active-${row.id}`}
                          checked={row.activeSelection === 'alt1'}
                          onChange={() => handleSelectActive(row.id, 'alt1')}
                          className="cursor-pointer"
                        />
                        <select
                          value={row.alt1?.code || ''}
                          onChange={e => handleAlternateChange(row.id, 'alt1', e.target.value)}
                          className="border border-slate-300 rounded-lg p-1 text-xs w-full bg-white font-medium"
                        >
                          <option value="">-- Select Inward Material --</option>
                          {purchaseMaster.map(p => (
                            <option key={p.code} value={p.code}>{p.name} (₹{p.waPrice.toFixed(2)})</option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">
                      ₹{row.alt1?.waPrice ? row.alt1.waPrice.toFixed(2) : '0.00'}
                    </td>

                    {/* Alternate 2 */}
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <input
                          type="radio"
                          name={`active-${row.id}`}
                          checked={row.activeSelection === 'alt2'}
                          onChange={() => handleSelectActive(row.id, 'alt2')}
                          className="cursor-pointer"
                        />
                        <select
                          value={row.alt2?.code || ''}
                          onChange={e => handleAlternateChange(row.id, 'alt2', e.target.value)}
                          className="border border-slate-300 rounded-lg p-1 text-xs w-full bg-white font-medium"
                        >
                          <option value="">-- Select Alternate Lot 2 --</option>
                          {purchaseMaster.map(p => (
                            <option key={p.code} value={p.code}>{p.name} (₹{p.waPrice.toFixed(2)})</option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">
                      ₹{row.alt2?.waPrice ? row.alt2.waPrice.toFixed(2) : '0.00'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* SUBTAB 2: PURCHASES */}
      {activeSubTab === 'purchases' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 p-4 space-y-3">
          <h2 className="font-bold text-sm text-slate-900">Raw Material & Masterbatch Purchase Master (Inward Lots)</h2>
          <div className="border border-slate-200 rounded-xl overflow-hidden">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-2.5">Inward Date</th>
                  <th className="p-2.5">Invoice #</th>
                  <th className="p-2.5">Material & MB Grade</th>
                  <th className="p-2.5">Supplier</th>
                  <th className="p-2.5 text-right">Qty (Kg)</th>
                  <th className="p-2.5 text-right">Weighted Avg Price (₹/kg)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {purchaseMaster.map(p => (
                  <tr key={p.code} className="hover:bg-slate-50 font-medium">
                    <td className="p-2.5 font-mono text-slate-500">{p.inwardDate}</td>
                    <td className="p-2.5 font-mono font-bold text-blue-700">{p.invoiceNo}</td>
                    <td className="p-2.5 font-bold text-slate-900">{p.name}</td>
                    <td className="p-2.5 text-slate-700">{p.supplier}</td>
                    <td className="p-2.5 text-right font-mono font-bold">{p.qtyKg.toLocaleString()}</td>
                    <td className="p-2.5 text-right font-mono font-black text-slate-900">₹{p.waPrice.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* SUBTAB 3: SALES */}
      {activeSubTab === 'sales' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 p-4 space-y-3">
          <h2 className="font-bold text-sm text-slate-900">Dispatched Sales Data ({selectedVendor})</h2>
          <div className="border border-slate-200 rounded-xl overflow-hidden">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-2.5">Date</th>
                  <th className="p-2.5">Invoice #</th>
                  <th className="p-2.5">Part Code</th>
                  <th className="p-2.5">Component Name</th>
                  <th className="p-2.5 text-right">Qty Sold</th>
                  <th className="p-2.5 text-right">Billing Price (₹)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {salesData.map(s => (
                  <tr key={s.id} className="hover:bg-slate-50 font-medium">
                    <td className="p-2.5 font-mono text-slate-500">{s.invoiceDate}</td>
                    <td className="p-2.5 font-mono font-bold text-blue-700">{s.invoiceNo}</td>
                    <td className="p-2.5 font-mono font-bold">{s.itemCode}</td>
                    <td className="p-2.5 font-bold text-slate-900">{s.componentName}</td>
                    <td className="p-2.5 text-right font-mono font-bold">{s.saleUnit.toLocaleString()} pcs</td>
                    <td className="p-2.5 text-right font-mono font-black">₹{s.sellingPrice.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* SUBTAB 4: AUDIT TRAIL */}
      {activeSubTab === 'audit' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 p-4 space-y-3">
          <h2 className="font-bold text-sm text-slate-900">RM & MB Period Lock Audit Trail</h2>
          <div className="border border-slate-200 rounded-xl overflow-hidden">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-2.5">Timestamp</th>
                  <th className="p-2.5">Vendor</th>
                  <th className="p-2.5">RM / MB Grade</th>
                  <th className="p-2.5">Period Locked</th>
                  <th className="p-2.5 text-right">Approved Rate</th>
                  <th className="p-2.5">Active Alternate</th>
                  <th className="p-2.5">Authorized By</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {rmHistoryLogs.map(l => (
                  <tr key={l.id} className="hover:bg-slate-50 font-medium">
                    <td className="p-2.5 font-mono text-slate-500">{l.timestamp}</td>
                    <td className="p-2.5 font-bold text-slate-900">{l.vendor}</td>
                    <td className="p-2.5 font-bold text-blue-700">{l.rmGrade}</td>
                    <td className="p-2.5 font-mono">{l.period}</td>
                    <td className="p-2.5 text-right font-mono font-black">₹{l.newRate.toFixed(2)}</td>
                    <td className="p-2.5 text-slate-700">{l.activeAlternate}</td>
                    <td className="p-2.5 text-slate-700">{l.changedBy}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

    </div>
  );
}
RM_PAGE_EOF

# 5. Update CostingRunEnginePage.jsx to dynamically bind all vendors (including Atomberg)
cat << 'COST_PAGE_EOF' > src/modules/module3-costing-engine/CostingRunEnginePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  DollarSign, Sliders, Search, ArrowUpDown, TrendingUp, TrendingDown, 
  Building2, CheckCircle2, ShieldCheck, Sparkles 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping, getVendorBaselineData } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function CostingRunEnginePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [searchQuery, setSearchQuery] = useState('');

  const rawList = getVendorBaselineData(selectedVendor);

  const filteredItems = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Header Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <DollarSign className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">3. Dynamic Costing Run Engine</h1>
            <p className="text-[11px] text-slate-300">Live simulation of product piece costing matching contract baselines against active material inward rates.</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/40 px-2.5 py-1 rounded-full font-bold flex items-center gap-1.5">
            <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" /> Engine Active & Linked to RM Matrix
          </span>
        </div>
      </div>

      {/* Filter Strip */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search components by name or part number..."
            className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-700">Filter Vendor:</span>
          <select
            value={selectedVendor}
            onChange={(e) => setSelectedVendor(e.target.value)}
            className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
            <option value="ALL">All Vendors Combined</option>
          </select>
        </div>
      </div>

      {/* LIVE SIMULATION MATRIX */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
          <h2 className="text-sm font-bold flex items-center gap-2">
            <Sliders className="w-4 h-4 text-blue-400" /> Live Product Cost Simulation Matrix
          </h2>
          <span className="text-[11px] text-slate-300 font-mono">{filteredItems.length} Products</span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
              <tr>
                <th className="p-3">Item Code / Component</th>
                <th className="p-3 text-center">Vendor</th>
                <th className="p-3">Approved RM</th>
                <th className="p-3 text-right bg-amber-50">Approved RM Rate</th>
                <th className="p-3">Active Alternate RM (Inward)</th>
                <th className="p-3 text-right bg-blue-50">Active WA Rate</th>
                <th className="p-3 text-right bg-amber-50 font-bold">Approved Baseline</th>
                <th className="p-3 text-right bg-blue-50 font-bold">Simulated Actual</th>
                <th className="p-3 text-right">Profit / Loss (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {filteredItems.map((item) => {
                const params = item.parameters || {};
                const rmMapping = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');

                const baseSpec = {
                  cavity: Number(item.cavity ?? params.cavity ?? 1),
                  netWeight: Number(item.netWeight ?? params.netWeightApproved ?? 37),
                  runnerWeight: Number(item.runnerWeight ?? params.runnerWeight ?? 1),
                  rmRate: Number(item.approvedRmRate || rmMapping.approvedPrice || 135.83),
                  masterbatchPct: Number(item.masterbatchPct ?? 4.0),
                  masterbatchRate: Number(item.masterbatchRate || 258.54),
                  bopCost: Number(item.bopCost || 0.0),
                  machineTonnage: Number(item.machineTonnage ?? params.machineTonnage ?? 200),
                  shiftTariff: Number(item.hourlyRate ? item.hourlyRate * 8 : (params.shiftTariff ?? 2000)),
                  cycleTime: Number(item.cycleTimeApproved ?? item.cycleTime ?? 47)
                };
                const baselineCalc = calculateDetailedCost(baseSpec, true);

                const runningSpec = {
                  cavity: Number(params.runningCavity ?? baseSpec.cavity),
                  netWeight: Number(params.runningNetWeight ?? baseSpec.netWeight),
                  runnerWeight: Number(params.runningRunnerWeight ?? baseSpec.runnerWeight),
                  rmRate: Number(rmMapping.activeWaPrice || baseSpec.rmRate),
                  masterbatchPct: Number(params.runningMbPct ?? baseSpec.masterbatchPct),
                  masterbatchRate: baseSpec.masterbatchRate,
                  bopCost: Number(params.runningBopCost ?? baseSpec.bopCost),
                  machineTonnage: Number(params.runningTonnage ?? baseSpec.machineTonnage),
                  shiftTariff: Number(params.runningShiftTariff ?? (params.runningTonnage >= 600 ? 4800 : baseSpec.shiftTariff)),
                  cycleTime: Number(params.runningCycleTime ?? baseSpec.cycleTime)
                };
                const runningCalc = calculateDetailedCost(runningSpec, false);

                const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
                const actualCost = Number(runningCalc.totalCost.toFixed(2));
                const unitDelta = Number((actualCost - contractBaseline).toFixed(2));

                return (
                  <tr key={item.id} className="hover:bg-slate-50">
                    <td className="p-3">
                      <span className="font-mono font-bold text-blue-700 block">{item.itemCode}</span>
                      <span className="font-semibold text-slate-900">{item.componentName}</span>
                    </td>
                    <td className="p-3 text-center">
                      <span className="bg-slate-100 border border-slate-300 font-bold px-2 py-0.5 rounded text-[10px]">
                        {item.vendor || selectedVendor}
                      </span>
                    </td>
                    <td className="p-3 font-semibold text-slate-800">{item.approvedRm}</td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900 bg-amber-50/50">
                      ₹{baseSpec.rmRate.toFixed(2)}/kg
                    </td>
                    <td className="p-3">
                      <span className="font-bold text-blue-900 block">{rmMapping.activeRmName}</span>
                      <span className="text-[10px] text-slate-500 font-mono">Linked to RM Matrix</span>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-blue-900 bg-blue-50/50">
                      ₹{rmMapping.activeWaPrice?.toFixed(2)}/kg
                    </td>
                    <td className="p-3 text-right font-mono font-black text-slate-900 bg-amber-50/50 text-xs">
                      ₹{contractBaseline.toFixed(2)}
                    </td>
                    <td className="p-3 text-right font-mono font-black text-blue-950 bg-blue-50/50 text-xs">
                      ₹{actualCost.toFixed(2)}
                    </td>
                    <td className="p-3 text-right font-mono font-black">
                      <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] ${
                        unitDelta <= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                      }`}>
                        {unitDelta <= 0 ? <TrendingDown className="w-3 h-3" /> : <TrendingUp className="w-3 h-3" />}
                        ₹ {unitDelta <= 0 ? `${unitDelta.toFixed(2)}` : `+${unitDelta.toFixed(2)}`}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

    </div>
  );
}
COST_PAGE_EOF

echo "==> All 5 sync updates successfully applied."
