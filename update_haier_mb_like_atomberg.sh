#!/usr/bin/env bash
set -e

echo "==> 1. Updating MasterStore with Haier MB Matrix row and purchase lots..."
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';

const initialData = Array.isArray(initialBaselineData) ? initialBaselineData : [];

const formattedHaierData = [
  {
    id: "BL-HAIER-001",
    vendor: "Haier",
    itemCode: "0060226713H",
    componentName: "End Cap Top Ref (without Screen Painting )",
    model: "OLD DC- 195,220",
    mouldSize: "1070*720*650",
    approvedRm: "ABS 300 Pre Colour",
    approvedRmRate: 130.00,
    masterbatchPct: 0.0,
    masterbatchRate: 0.0,
    bopCost: 0.0,
    cavity: 2,
    netWeight: 197.0,
    runnerWeight: 40.0,
    cycleTimeApproved: 48.0,
    cycleTime: 48.0,
    machineTonnage: 450,
    shiftTariff: 4600,
    hourlyRate: 575,
    validFrom: "2026-08-01",
    parameters: {
      cavity: 2,
      netWeightApproved: 197.0,
      runnerWeight: 40.0,
      cycleTimeApproved: 48.0,
      machineTonnage: 450,
      shiftTariff: 4600,
      bopCost: 0.0,
      masterbatchPct: 0.0
    }
  },
  {
    id: "BL-HAIER-002",
    vendor: "Haier",
    itemCode: "0060217989D",
    componentName: "End cap Bottom Ref-ABS-DC-195,220",
    model: "OLD DC- 195,220",
    mouldSize: "1070*720*650",
    approvedRm: "ABS 300 Pre Colour",
    approvedRmRate: 130.00,
    masterbatchPct: 0.0,
    masterbatchRate: 0.0,
    bopCost: 0.0,
    cavity: 2,
    netWeight: 197.0,
    runnerWeight: 40.0,
    cycleTimeApproved: 48.0,
    cycleTime: 48.0,
    machineTonnage: 450,
    shiftTariff: 4600,
    hourlyRate: 575,
    validFrom: "2026-08-01",
    parameters: {
      cavity: 2,
      netWeightApproved: 197.0,
      runnerWeight: 40.0,
      cycleTimeApproved: 48.0,
      machineTonnage: 450,
      shiftTariff: 4600,
      bopCost: 0.0,
      masterbatchPct: 0.0
    }
  },
  {
    id: "BL-HAIER-003",
    vendor: "Haier",
    itemCode: "0060217978E",
    componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX",
    model: "DC 195, 220",
    mouldSize: "1200*850*700",
    approvedRm: "GPPS SC201LV",
    approvedRmRate: 103.08,
    masterbatchPct: 3.5,
    masterbatchRate: 240.00,
    bopCost: 0.0,
    cavity: 1,
    netWeight: 485.0,
    runnerWeight: 22.0,
    cycleTimeApproved: 58.0,
    cycleTime: 58.0,
    machineTonnage: 650,
    shiftTariff: 5760,
    hourlyRate: 720,
    validFrom: "2026-08-01",
    parameters: {
      cavity: 1,
      netWeightApproved: 485.0,
      runnerWeight: 22.0,
      cycleTimeApproved: 58.0,
      machineTonnage: 650,
      shiftTariff: 5760,
      bopCost: 0.0,
      masterbatchPct: 3.5
    }
  }
];

export const globalStore = {
  vendors: [
    { vendorId: "Haier", vendorName: "Haier Appliances", code: "HAIER", paymentTerms: "60 to 45 Days", active: true, lineCount: 38 },
    { vendorId: "Atomberg", vendorName: "Atomberg Technologies", code: "ATOM", paymentTerms: "45 Days", active: true, lineCount: 38 },
    { vendorId: "LG", vendorName: "LG Electronics", code: "LG", paymentTerms: "45 Days", active: true, lineCount: 9 },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India", code: "WHIRLPOOL", paymentTerms: "60 Days", active: true, lineCount: 7 }
  ],

  vendorLockStatus: {
    Haier: true,
    Atomberg: true,
    LG: false,
    Whirlpool: false
  },

  vendorBlueprints: {
    Haier: [],
    Atomberg: []
  },

  vendorBaselines: {
    Haier: formattedHaierData,
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
    LG: initialData.filter(d => d.vendor === 'LG'),
    Whirlpool: initialData.filter(d => d.vendor === 'Whirlpool')
  },

  baselineList: [],

  purchaseMaster: [
    { code: "PUR-PP-01", invoiceNo: "INV-PUR-8830", name: "PP H110MA Prime Inward", polymer: "PP", supplier: "Reliance Industries", waPrice: 135.83, inwardDate: "2026-08-02", qtyKg: 10000 },
    { code: "PUR-MB-01", invoiceNo: "INV-PUR-8831", name: "White Masterbatch 258 Grade", polymer: "MB", supplier: "Clariant Masterbatches", waPrice: 258.54, inwardDate: "2026-08-02", qtyKg: 1500 },
    { code: "PUR-MB-02", invoiceNo: "INV-PUR-8832", name: "Smoke Grey MB 240 Grade", polymer: "MB", supplier: "Clariant Masterbatches", waPrice: 240.00, inwardDate: "2026-08-02", qtyKg: 800 },
    { code: "PUR-ABS-01", invoiceNo: "INV-PUR-8821", name: "ABS 300-B Red (Prime Inward)", polymer: "ABS", supplier: "Supreme Petrochem", waPrice: 134.80, inwardDate: "2026-08-01", qtyKg: 12500 },
    { code: "PUR-ABS-02", invoiceNo: "INV-PUR-8822", name: "ABS 300-Blue (Imported)", polymer: "ABS", supplier: "Chi Mei", waPrice: 131.25, inwardDate: "2026-08-05", qtyKg: 8200 },
    { code: "PUR-GPPS-01", invoiceNo: "INV-PUR-8824", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", polymer: "GPPS", supplier: "Supreme", waPrice: 98.40, inwardDate: "2026-08-03", qtyKg: 9000 }
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
      approvedPrice: 130.00,
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
      id: "RM-HAIER-MB-P1",
      vendor: "Haier",
      approvedRm: "MB Smoke Grey Grade",
      polymer: "MB",
      approvedPrice: 240.00,
      validFrom: "2026-08-01",
      validTo: "2026-08-31",
      activeSelection: "alt1",
      alt1: { code: "PUR-MB-02", name: "Smoke Grey MB 240 Grade", waPrice: 240.00 }
    },
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
  if (vendor === 'ALL' || vendor === 'All Vendors Combined') {
    syncMasterBaselineList();
    return globalStore.baselineList;
  }
  return globalStore.vendorBaselines[vendor] || [];
};

export const getActiveRmMapping = (approvedRmName, vendor = "Haier", targetDate = null) => {
  const vKey = (vendor || "Haier").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey &&
    ((approvedRmName && r.approvedRm.toLowerCase().includes(approvedRmName.toLowerCase())) ||
     (approvedRmName && approvedRmName.toLowerCase().includes(r.approvedRm.toLowerCase())) ||
     (approvedRmName && approvedRmName.toLowerCase().includes(r.polymer?.toLowerCase())))
  );

  let row = rows[0];
  if (!row) {
    return {
      vendor: vendor || "Haier",
      approvedRm: approvedRmName || "Standard Polymer",
      approvedPrice: 130.00,
      activeRmName: "Inward Lot Standard",
      activeWaPrice: 134.80,
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

export const getActiveMbMapping = (vendor = "Haier", targetDate = null) => {
  const vKey = (vendor || "Haier").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey && r.polymer === 'MB'
  );

  let row = rows[0];
  if (!row) {
    return {
      approvedMbPrice: vKey === 'haier' ? 240.00 : 254.00,
      activeMbName: vKey === 'haier' ? "Smoke Grey MB 240 Grade" : "White Masterbatch 258 Grade",
      activeMbPrice: vKey === 'haier' ? 240.00 : 258.54
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
  notifyStore();
};

export const updateBaselineParameters = ({ itemId, updatedItem, changeType, newValidFrom, reason } = {}) => {
  const list = globalStore.baselineList || [];
  const idx = list.findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
  if (idx !== -1) {
    const prev = list[idx];
    const prevParams = prev.parameters || {};
    const newParams = updatedItem?.parameters || {};

    globalStore.baselineList[idx] = {
      ...prev,
      ...updatedItem,
      parameters: { ...prevParams, ...newParams },
      validFrom: newValidFrom || prev.validFrom
    };

    const v = prev.vendor || 'Haier';
    if (globalStore.vendorBaselines[v]) {
      const vIdx = globalStore.vendorBaselines[v].findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
      if (vIdx !== -1) {
        globalStore.vendorBaselines[v][vIdx] = globalStore.baselineList[idx];
      }
    }
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

echo "==> 2. Updating InlineEditModal with Haier MB dynamic RM Matrix linking..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, Lock, TrendingUp, TrendingDown } from 'lucide-react';
import { getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const isAtomberg = (item.vendor || '').toLowerCase().includes('atomberg');
  const isCrisper = item.itemCode === '0060217978E';
  const rmInfo = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');
  const mbInfo = getActiveMbMapping(item.vendor, '2026-08-01');

  // ---------- ATOMBERG VIEW ----------
  if (isAtomberg) {
    const approvedRmBase = Number(rmInfo.approvedPrice || 140.00);
    const approvedMbBase = Number(mbInfo.approvedMbPrice || 254.00);
    const actualRmBase = Number(rmInfo.activeWaPrice || 135.83);
    const actualMbBase = Number(mbInfo.activeMbPrice || 258.54);

    const baseP = {
      vendor: 'Atomberg',
      rmBase: approvedRmBase,
      rmFreight: 1.50,
      mbBase: approvedMbBase,
      mbFreight: 2.00,
      mbPct: 0.04,
      partWt: Number(item.netWeight || 37.0),
      runnerWt: Number(item.runnerWeight || 1.0),
      bopCost: Number(item.bopCost || 0.0),
      tonnage: Number(item.machineTonnage || 200.0),
      cycleTime: Number(item.cycleTimeApproved || 47.0),
      efficiency: 0.90,
      cavity: Number(item.cavity || 2),
      postOpCost: 1.73,
      packingCost: 0.86,
      transportCost: 0.62
    };
    const baseCalc = calculateAtombergCost(baseP);

    const params = item.parameters || {};
    const [partWt, setPartWt] = useState(params.runningNetWeight ?? baseP.partWt);
    const [runnerWt, setRunnerWt] = useState(params.runningRunnerWeight ?? baseP.runnerWt);
    const [mbPctVal, setMbPctVal] = useState((params.runningMbPct !== undefined ? params.runningMbPct : (baseP.mbPct * 100)));
    const [bopCost, setBopCost] = useState(params.runningBopCost ?? baseP.bopCost);
    const [cycleTime, setCycleTime] = useState(params.runningCycleTime ?? baseP.cycleTime);
    const [cavity, setCavity] = useState(params.runningCavity ?? baseP.cavity);
    const [tonnage, setTonnage] = useState(params.runningTonnage ?? baseP.tonnage);
    const [reason, setReason] = useState("Atomberg shopfloor spec verification");

    const runningP = {
      ...baseP,
      rmBase: actualRmBase,
      mbBase: actualMbBase,
      partWt: Number(partWt),
      runnerWt: Number(runnerWt),
      mbPct: Number(mbPctVal) / 100,
      bopCost: Number(bopCost),
      cycleTime: Number(cycleTime),
      cavity: Number(cavity),
      tonnage: Number(tonnage)
    };
    const runCalc = calculateAtombergCost(runningP);
    const profitLossDelta = Number((baseCalc.finalLanded - runCalc.finalLanded).toFixed(2));

    const handleSaveAtomberg = () => {
      onSave({
        updatedItem: {
          ...item,
          masterbatchPct: Number(mbPctVal),
          bopCost: Number(bopCost),
          parameters: {
            ...item.parameters,
            runningNetWeight: Number(partWt),
            runningRunnerWeight: Number(runnerWt),
            runningMbPct: Number(mbPctVal),
            runningBopCost: Number(bopCost),
            runningCycleTime: Number(cycleTime),
            runningCavity: Number(cavity),
            runningTonnage: Number(tonnage)
          }
        },
        changeType: "Atomberg Spec Adjustment",
        reason
      });
    };

    return (
      <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
        <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto">
          <div className="flex justify-between items-center border-b pb-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="bg-purple-600 text-white font-mono px-2 py-0.5 rounded font-bold">{item.itemCode || 'A101701'}</span>
                <h2 className="text-sm font-bold text-slate-900">{item.componentName || 'Aris Top Canopy- Gloss White'}</h2>
                <span className="bg-purple-100 text-purple-900 font-bold px-2 py-0.5 rounded text-[10px]">Atomberg Prescribed Format</span>
              </div>
              <p className="text-[11px] text-slate-500 font-mono mt-0.5">
                Vendor: <span className="font-bold text-slate-700">Atomberg Technologies</span> | Model: Aris | RM Link: <span className="text-emerald-700 font-bold">{rmInfo.activeRmName}</span>
              </p>
            </div>
            <button onClick={onClose} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div className="bg-slate-100 p-3 rounded-xl border">
              <span className="text-[10px] font-bold text-slate-500 uppercase block">APPROVED BASELINE CONTRACT</span>
              <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">₹{baseCalc.finalLanded.toFixed(2)}</span>
              <span className="text-[10px] text-slate-500 font-mono">RM: ₹{baseCalc.rmCost.toFixed(2)} | Process: ₹{baseCalc.totalProcessCost.toFixed(2)} | OH: ₹{baseCalc.otherCost.toFixed(2)}</span>
            </div>
            <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
              <span className="text-[10px] font-bold text-blue-700 uppercase block">ACTUAL RUNNING SHOPFLOOR</span>
              <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{runCalc.finalLanded.toFixed(2)}</span>
              <span className="text-[10px] text-blue-600 font-mono">RM: ₹{runCalc.rmCost.toFixed(2)} | Process: ₹{runCalc.totalProcessCost.toFixed(2)} | OH: ₹{runCalc.otherCost.toFixed(2)}</span>
            </div>
            <div className={`p-3 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
              <div className="flex justify-between items-center">
                <span className="text-[10px] font-bold text-slate-600 uppercase block">PROFIT / LOSS (Δ)</span>
                {profitLossDelta >= 0 ? <TrendingUp className="w-4 h-4 text-emerald-600" /> : <TrendingDown className="w-4 h-4 text-rose-600" />}
              </div>
              <span className={`text-2xl font-black font-mono mt-1 block ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                {profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}
              </span>
              <span className={`text-[10px] font-bold ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                {profitLossDelta >= 0 ? 'Cost Saving (Profit)' : 'Cost Escalation (Loss)'}
              </span>
            </div>
          </div>

          <div className="border border-slate-200 rounded-xl overflow-hidden">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0">
                <tr>
                  <th className="p-2 w-10 text-center">#</th>
                  <th className="p-2">ATOMBERG COSTING LINE</th>
                  <th className="p-2 w-20 text-center">UOM / RATE</th>
                  <th className="p-2 text-right w-44 bg-slate-200/50">APPROVED BASELINE</th>
                  <th className="p-2 text-right w-48 bg-blue-100/50">ACTUAL RUNNING</th>
                  <th className="p-2 text-right w-24">DELTA (Δ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                <tr><td className="p-2 text-center text-slate-400">1</td><td className="p-2 font-bold">Vendor</td><td className="p-2 text-center">-</td><td className="p-2 text-right">Atomberg</td><td className="p-2 text-right bg-blue-50/30">Atomberg</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">2</td><td className="p-2 font-bold">Part Code</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono font-bold">A101701</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">A101701</td><td className="p-2 text-right">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">3</td><td className="p-2 font-bold">Part name</td><td className="p-2 text-center">-</td><td className="p-2 text-right">Aris Top Canopy- Gloss White</td><td className="p-2 text-right bg-blue-50/30">Aris Top Canopy- Gloss White</td><td className="p-2 text-right">-</td></tr>
                <tr className="bg-amber-50/40"><td className="p-2 text-center text-slate-400">4</td><td className="p-2 font-bold text-blue-900 flex items-center gap-1"><Lock className="w-3 h-3 text-amber-600" /> RM grade (Locked & Linked)</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-bold">{rmInfo.approvedRm}</td><td className="p-2 text-right bg-blue-50/30 font-bold text-blue-950">{rmInfo.activeRmName}</td><td className="p-2 text-right">-</td></tr>
                <tr className="bg-amber-50/60 font-bold"><td className="p-2 text-center text-slate-400">5</td><td className="p-2 font-black text-amber-950">RM Base Rate (From RM Matrix)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-amber-900 bg-amber-100/50">₹{baseCalc.rmBase.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-blue-900 bg-blue-100/50">₹{runCalc.rmBase.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.rmBase - baseCalc.rmBase).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">6</td><td className="p-2">ICC Cost @ 1% of RM</td><td className="p-2 text-center">1%</td><td className="p-2 text-right font-mono">₹{baseCalc.rmIcc.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rmIcc.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.rmIcc - baseCalc.rmIcc).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">7</td><td className="p-2">Freight Cost</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono">₹{baseCalc.rmFreight.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rmFreight.toFixed(2)}</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-emerald-50/70 font-bold border-y-2 border-emerald-200"><td className="p-2 text-center text-emerald-800">8</td><td className="p-2 font-black text-emerald-950">RM Landed Cost (Base + ICC + Freight)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-emerald-900 bg-emerald-100/60">₹{baseCalc.rmLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-emerald-900 bg-blue-100/60">₹{runCalc.rmLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-emerald-800">{(runCalc.rmLanded - baseCalc.rmLanded).toFixed(2)}</td></tr>
                <tr className="bg-purple-50/60 font-bold"><td className="p-2 text-center text-slate-400">9</td><td className="p-2 font-black text-purple-950">MB Base Cost (From RM Matrix)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-purple-900 bg-purple-100/50">₹{baseCalc.mbBase.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-blue-900 bg-blue-100/50">₹{runCalc.mbBase.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.mbBase - baseCalc.mbBase).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">10</td><td className="p-2">MB-ICC Cost @ 1% of MB</td><td className="p-2 text-center">1%</td><td className="p-2 text-right font-mono">₹{baseCalc.mbIcc.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mbIcc.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.mbIcc - baseCalc.mbIcc).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">11</td><td className="p-2">MB Freight Cost</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono">₹{baseCalc.mbFreight.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mbFreight.toFixed(2)}</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-purple-100/50 font-bold border-y-2 border-purple-200"><td className="p-2 text-center text-purple-900">12</td><td className="p-2 font-black text-purple-950">MB Landed Cost (Base + ICC + Freight)</td><td className="p-2 text-center font-mono">₹/kg</td><td className="p-2 text-right font-mono font-black text-purple-950 bg-purple-200/50">₹{baseCalc.mbLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-purple-950 bg-blue-100/60">₹{runCalc.mbLanded.toFixed(2)}</td><td className="p-2 text-right font-mono font-black text-purple-900">{(runCalc.mbLanded - baseCalc.mbLanded).toFixed(2)}</td></tr>
                <tr className="bg-purple-50/30"><td className="p-2 text-center text-slate-400">13</td><td className="p-2 font-bold text-purple-950">MB %</td><td className="p-2 text-center">%</td><td className="p-2 text-right font-mono font-bold bg-slate-50">4.00%</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.1" value={mbPctVal} onChange={e => setMbPctVal(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-purple-700">{(Number(mbPctVal) - 4).toFixed(2)}%</td></tr>
                <tr className="bg-amber-100/50 font-bold"><td className="p-2 text-center">14</td><td className="p-2 font-black">RM cost( PP + MB) /KG</td><td className="p-2 text-center">₹/kg</td><td className="p-2 text-right font-mono font-black">₹{baseCalc.rmCombRate.toFixed(4)}</td><td className="p-2 text-right bg-blue-100/60 font-mono font-black">₹{runCalc.rmCombRate.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmCombRate - baseCalc.rmCombRate).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">15</td><td className="p-2 font-bold">part weight grams</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono font-bold">37.0g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={partWt} onChange={e => setPartWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(partWt) - 37).toFixed(1)}g</td></tr>
                <tr><td className="p-2 text-center text-slate-400">16</td><td className="p-2 font-bold">Runner weight grams</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono font-bold">1.0g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runnerWt} onChange={e => setRunnerWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(runnerWt) - 1).toFixed(1)}g</td></tr>
                <tr className="bg-slate-50/50"><td className="p-2 text-center text-slate-400">17</td><td className="p-2 font-bold">Gross weight</td><td className="p-2 text-center">Gms</td><td className="p-2 text-right font-mono">{baseCalc.grossWt}g</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{runCalc.grossWt}g</td><td className="p-2 text-right font-mono">{runCalc.grossWt - baseCalc.grossWt}g</td></tr>
                <tr className="bg-amber-50 font-bold"><td className="p-2 text-center">18</td><td className="p-2 font-black">RM cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono font-bold">₹{baseCalc.rmCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50 font-mono font-bold">₹{runCalc.rmCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmCost - baseCalc.rmCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">19</td><td className="p-2 font-bold">Inserts/BOP cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.00</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.01" value={bopCost} onChange={e => setBopCost(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">₹{Number(bopCost).toFixed(2)}</td></tr>
                <tr className="bg-slate-50 font-bold"><td className="p-2 text-center">20</td><td className="p-2 font-black">RM + BOP Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.rmBopCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50 font-mono">₹{runCalc.rmBopCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.rmBopCost - baseCalc.rmBopCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">21</td><td className="p-2 font-bold">M/c tonnage</td><td className="p-2 text-center">T</td><td className="p-2 text-right font-mono">200T</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={tonnage} onChange={e => setTonnage(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(tonnage) - 200}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">22</td><td className="p-2">shift rate (Tonnage × ₹10)</td><td className="p-2 text-center">₹/shift</td><td className="p-2 text-right font-mono">₹2,000</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.shiftRate}</td><td className="p-2 text-right font-mono">{runCalc.shiftRate - 2000}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">23</td><td className="p-2 font-bold">cycle time( seconds)</td><td className="p-2 text-center">Sec</td><td className="p-2 text-right font-mono font-bold">47s</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="1" value={cycleTime} onChange={e => setCycleTime(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-blue-700">{(Number(cycleTime) - 47).toFixed(1)}s</td></tr>
                <tr><td className="p-2 text-center text-slate-400">24</td><td className="p-2">Efficiency</td><td className="p-2 text-center">-</td><td className="p-2 text-right font-mono">0.90</td><td className="p-2 text-right bg-blue-50/30 font-mono">0.90</td><td className="p-2 text-right font-mono">-</td></tr>
                <tr><td className="p-2 text-center text-slate-400">25</td><td className="p-2 font-bold">No of cavity</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono font-bold">2</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={cavity} onChange={e => setCavity(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(cavity) - 2}</td></tr>
                <tr className="bg-slate-50"><td className="p-2 text-center text-slate-400">26</td><td className="p-2">No. of parts/shift</td><td className="p-2 text-center">Nos</td><td className="p-2 text-right font-mono">{baseCalc.partsPerShift.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{runCalc.partsPerShift.toFixed(2)}</td><td className="p-2 text-right font-mono">{(runCalc.partsPerShift - baseCalc.partsPerShift).toFixed(2)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">27</td><td className="p-2 font-bold">Process cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.processCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">₹{runCalc.processCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.processCost - baseCalc.processCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">28</td><td className="p-2">Handling cost for BOP</td><td className="p-2 text-center">3%</td><td className="p-2 text-right font-mono">₹0.00</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.bopHandling.toFixed(4)}</td><td className="p-2 text-right font-mono">{runCalc.bopHandling.toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">29</td><td className="p-2 font-bold">Post operation cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹1.73</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹1.73</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-blue-100/50 font-bold"><td className="p-2 text-center">30</td><td className="p-2 font-black text-blue-950">Total Process Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono font-black">₹{baseCalc.totalProcessCost.toFixed(4)}</td><td className="p-2 bg-blue-100/70 font-mono font-black">₹{runCalc.totalProcessCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.totalProcessCost - baseCalc.totalProcessCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">31</td><td className="p-2">Profit & OH</td><td className="p-2 text-center">12%</td><td className="p-2 text-right font-mono">₹{baseCalc.profitOh.toFixed(4)}</td><td className="p-2 bg-blue-50/30 font-mono">₹{runCalc.profitOh.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.profitOh - baseCalc.profitOh).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">32</td><td className="p-2">Inprocess Rejection</td><td className="p-2 text-center">4%</td><td className="p-2 text-right font-mono">₹{baseCalc.inprocessRejection.toFixed(4)}</td><td className="p-2 bg-blue-50/30 font-mono">₹{runCalc.inprocessRejection.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.inprocessRejection - baseCalc.inprocessRejection).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">33</td><td className="p-2 font-bold text-emerald-800">Runner recovery cost</td><td className="p-2 text-center">₹25/kg</td><td className="p-2 text-right font-mono text-emerald-700">- ₹0.025</td><td className="p-2 bg-blue-50/30 font-mono text-emerald-700">- ₹{Math.abs(runCalc.runnerRecovery).toFixed(3)}</td><td className="p-2 text-right font-mono">{(runCalc.runnerRecovery - baseCalc.runnerRecovery).toFixed(3)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">34</td><td className="p-2">Packing cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.86</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹0.86</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr><td className="p-2 text-center text-slate-400">35</td><td className="p-2">Transport cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.62</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹0.62</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr><td className="p-2 text-center text-slate-400">36</td><td className="p-2">Mould maintenance cost</td><td className="p-2 text-center">2%</td><td className="p-2 text-right font-mono">₹{baseCalc.mouldMaint.toFixed(4)}</td><td className="p-2 bg-blue-50/30 font-mono">₹{runCalc.mouldMaint.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.mouldMaint - baseCalc.mouldMaint).toFixed(4)}</td></tr>
                <tr className="bg-slate-100 font-bold"><td className="p-2 text-center">37</td><td className="p-2 font-black">Other Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.otherCost.toFixed(4)}</td><td className="p-2 bg-blue-50 font-mono">₹{runCalc.otherCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.otherCost - baseCalc.otherCost).toFixed(4)}</td></tr>
                <tr className="bg-slate-900 text-white font-bold">
                  <td className="p-2.5 text-center">38</td>
                  <td className="p-2.5 font-black text-amber-300 uppercase tracking-wider">Final Landed cost</td>
                  <td className="p-2.5 text-center font-mono">₹/pc</td>
                  <td className="p-2.5 text-right font-mono font-black text-amber-300 text-sm">₹{baseCalc.finalLanded.toFixed(2)}</td>
                  <td className="p-2.5 font-mono font-black text-emerald-300 text-sm bg-slate-800 text-right">₹{runCalc.finalLanded.toFixed(2)}</td>
                  <td className={`p-2.5 text-right font-mono font-black text-sm ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                    {profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div className="space-y-2 pt-2 border-t">
            <div>
              <label className="font-bold text-slate-700 block mb-1">Reason for Shopfloor Spec Drift / Audit Trail Record *</label>
              <input type="text" value={reason} onChange={e => setReason(e.target.value)} className="w-full border p-2 rounded-xl text-xs outline-none focus:ring-2 focus:ring-blue-500" />
            </div>
            <div className="flex justify-between items-center pt-2">
              <button onClick={onClose} className="px-4 py-2 border rounded-xl hover:bg-slate-50 cursor-pointer">Cancel</button>
              <button onClick={handleSaveAtomberg} className="px-6 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"><Save className="w-4 h-4" /> Save & Log Atomberg Parameters</button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ---------- HAIER VIEW (WITH DYNAMIC MB LINKING) ----------
  const dynamicHaierApprovedRm = Number(rmInfo.approvedPrice || item.approvedRmRate || (isCrisper ? 103.08 : 130.00));
  const dynamicHaierActualRm = Number(rmInfo.activeWaPrice || (isCrisper ? 98.40 : 134.80));

  const dynamicHaierApprovedMb = isCrisper ? Number(mbInfo.approvedMbPrice || 240.00) : 0.0;
  const dynamicHaierActualMb = isCrisper ? Number(mbInfo.activeMbPrice || 240.00) : 0.0;

  const baseCavity = Number(item.cavity || (isCrisper ? 1 : 2));
  const baseNetWt = Number(item.netWeight || (isCrisper ? 485 : 197));
  const baseRunnerWt = Number(item.runnerWeight || (isCrisper ? 22 : 40));
  const baseMbPct = Number(item.masterbatchPct ?? (isCrisper ? 3.5 : 0.0));
  const baseCycle = Number(item.cycleTimeApproved || item.cycleTime || (isCrisper ? 58 : 48));
  const baseTonnage = Number(item.machineTonnage || (isCrisper ? 650 : 450));
  const baseTariff = Number(item.parameters?.shiftTariff || (baseTonnage >= 650 ? 5760 : 4600));

  const params = item.parameters || {};
  const [runningCavity, setRunningCavity] = useState(params.runningCavity ?? baseCavity);
  const [runningNetWeight, setRunningNetWeight] = useState(params.runningNetWeight ?? baseNetWt);
  const [runningRunnerWeight, setRunningRunnerWeight] = useState(params.runningRunnerWeight ?? baseRunnerWt);
  const [runningMbPct, setRunningMbPct] = useState(params.runningMbPct ?? baseMbPct);
  const [runningCycleTime, setRunningCycleTime] = useState(params.runningCycleTime ?? baseCycle);
  const [runningTonnage, setRunningTonnage] = useState(params.runningTonnage ?? baseTonnage);
  const [reason, setReason] = useState("Shopfloor parameters & MB tuning");

  const actualTariff = Number(params.runningShiftTariff ?? (runningTonnage >= 650 ? 5760 : 4600));

  const baselineCalc = calculateHaierCost({
    cavity: baseCavity, netWeight: baseNetWt, runnerWeight: baseRunnerWt,
    rmRate: dynamicHaierApprovedRm, masterbatchPct: baseMbPct, masterbatchRate: dynamicHaierApprovedMb,
    cycleTime: baseCycle, machineTonnage: baseTonnage, shiftTariff: baseTariff
  });

  const runningCalc = calculateHaierCost({
    cavity: Number(runningCavity), netWeight: Number(runningNetWeight), runnerWeight: Number(runningRunnerWeight),
    rmRate: dynamicHaierActualRm, masterbatchPct: Number(runningMbPct), masterbatchRate: dynamicHaierActualMb,
    cycleTime: Number(runningCycleTime), machineTonnage: Number(runningTonnage), shiftTariff: actualTariff
  });

  const profitLossDelta = Number((baselineCalc.totalCost - runningCalc.totalCost).toFixed(2));

  const handleSaveHaier = () => {
    onSave({
      updatedItem: {
        ...item,
        masterbatchPct: Number(runningMbPct),
        parameters: {
          ...item.parameters,
          runningCavity: Number(runningCavity),
          runningNetWeight: Number(runningNetWeight),
          runningRunnerWeight: Number(runningRunnerWeight),
          runningMbPct: Number(runningMbPct),
          runningCycleTime: Number(runningCycleTime),
          runningTonnage: Number(runningTonnage),
          runningShiftTariff: actualTariff
        }
      },
      changeType: "Shopfloor Spec Adjustment",
      reason
    });
  };

  return (
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] overflow-y-auto">
        <div className="flex justify-between items-center border-b pb-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="bg-blue-600 text-white font-mono px-2 py-0.5 rounded font-bold">{item.itemCode}</span>
              <h2 className="text-sm font-bold text-slate-900">{item.componentName}</h2>
              <span className="bg-blue-100 text-blue-900 font-bold px-2 py-0.5 rounded text-[10px]">Haier Prescribed Format</span>
            </div>
            <p className="text-[11px] text-slate-500 font-mono mt-0.5">
              Vendor: <span className="font-bold text-slate-700">{item.vendor}</span> | Model: {item.model} | RM Link: <span className="text-blue-700 font-bold">{rmInfo.activeRmName}</span>
            </p>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
        </div>

        <div className="grid grid-cols-3 gap-3">
          <div className="bg-slate-100 p-3 rounded-xl border">
            <span className="text-[10px] font-bold text-slate-500 uppercase block">APPROVED BASELINE CONTRACT</span>
            <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">₹{baselineCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-slate-500 font-mono">RM: ₹{baselineCalc.totalRmCost.toFixed(2)} | Conv: ₹{baselineCalc.conversionCost.toFixed(2)}</span>
          </div>
          <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
            <span className="text-[10px] font-bold text-blue-700 uppercase block">ACTUAL RUNNING SHOPFLOOR</span>
            <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">₹{runningCalc.totalCost.toFixed(2)}</span>
            <span className="text-[10px] text-blue-600 font-mono">RM: ₹{runningCalc.totalRmCost.toFixed(2)} | Conv: ₹{runningCalc.conversionCost.toFixed(2)}</span>
          </div>
          <div className={`p-3 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
            <div className="flex justify-between items-center">
              <span className="text-[10px] font-bold text-slate-600 uppercase block">PROFIT / LOSS (Δ)</span>
              {profitLossDelta >= 0 ? <TrendingUp className="w-4 h-4 text-emerald-600" /> : <TrendingDown className="w-4 h-4 text-rose-600" />}
            </div>
            <span className={`text-2xl font-black font-mono mt-1 block ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
              {profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}
            </span>
            <span className={`text-[10px] font-bold ${profitLossDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
              {profitLossDelta >= 0 ? 'Cost Saving (Profit)' : 'Cost Escalation (Loss)'}
            </span>
          </div>
        </div>

        <div className="border border-slate-200 rounded-xl overflow-hidden">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0">
              <tr>
                <th className="p-2.5 w-12 text-center">#</th>
                <th className="p-2.5">HAIER PARAMETER / SPEC LINE</th>
                <th className="p-2.5 w-16 text-center">UOM</th>
                <th className="p-2.5 text-right w-44 bg-slate-200/50">APPROVED BASELINE</th>
                <th className="p-2.5 text-right w-48 bg-blue-100/50">ACTUAL RUNNING</th>
                <th className="p-2.5 text-right w-24">DELTA (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              <tr><td className="p-2 text-center text-slate-400">1</td><td className="p-2 font-bold text-slate-700">Name Of Component</td><td className="p-2 text-center font-mono">-</td><td className="p-2 text-right font-semibold">{item.componentName}</td><td className="p-2 text-right bg-blue-50/30 font-semibold">{item.componentName}</td><td className="p-2 text-right font-mono text-slate-400">-</td></tr>
              <tr><td className="p-2 text-center text-slate-400">2</td><td className="p-2 font-bold text-slate-700">Mould Size L * W * H</td><td className="p-2 text-center font-mono">mm</td><td className="p-2 text-right font-mono">{item.mouldSize || '1070*720*650'}</td><td className="p-2 text-right bg-blue-50/30 font-mono">{item.mouldSize || '1070*720*650'}</td><td className="p-2 text-right font-mono text-slate-400">-</td></tr>
              <tr className="bg-amber-50/30"><td className="p-2 text-center text-slate-400">3</td><td className="p-2 font-bold text-slate-900 flex items-center gap-1"><Lock className="w-3 h-3 text-amber-600" /> Approved RM Grade (Locked & Linked)</td><td className="p-2 text-center font-mono">-</td><td className="p-2 text-right font-mono font-bold bg-slate-50 text-amber-900">{item.approvedRm} (₹{dynamicHaierApprovedRm.toFixed(2)})</td><td className="p-2 text-right bg-blue-50/40 font-mono font-bold text-blue-950">{rmInfo.activeRmName} (₹{dynamicHaierActualRm.toFixed(2)})</td><td className="p-2 text-right font-mono font-bold">{(dynamicHaierActualRm - dynamicHaierApprovedRm).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">4</td><td className="p-2 font-bold text-purple-950">Masterbatch Required {isCrisper ? `(MB Rate: ₹${dynamicHaierApprovedMb.toFixed(2)}/kg)` : ''}</td><td className="p-2 text-center font-mono">%</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseMbPct.toFixed(2)}%</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.1" value={runningMbPct} onChange={e => setRunningMbPct(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-purple-700">{(Number(runningMbPct) - baseMbPct).toFixed(2)}%</td></tr>
              <tr><td className="p-2 text-center text-slate-400">5</td><td className="p-2 font-bold text-slate-900">No. of Cavity</td><td className="p-2 text-center font-mono">Nos</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseCavity}</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={runningCavity} onChange={e => setRunningCavity(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(runningCavity) - baseCavity}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">6</td><td className="p-2 font-bold text-slate-900">Runner Weight</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baseRunnerWt}g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runningRunnerWeight} onChange={e => setRunningRunnerWeight(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(runningRunnerWeight) - baseRunnerWt).toFixed(1)}g</td></tr>
              <tr><td className="p-2 text-center text-slate-400">7</td><td className="p-2 font-bold text-slate-900">Net Weight</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseNetWt}g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runningNetWeight} onChange={e => setRunningNetWeight(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold">{(Number(runningNetWeight) - baseNetWt).toFixed(1)}g</td></tr>
              <tr className="bg-slate-50/40"><td className="p-2 text-center text-slate-400">8</td><td className="p-2 font-bold text-slate-700">Shot Weight (Calculated / pc)</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baselineCalc.shotWeightPerPiece.toFixed(2)}g</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runningCalc.shotWeightPerPiece.toFixed(2)}g</td><td className="p-2 text-right font-mono">{(runningCalc.shotWeightPerPiece - baselineCalc.shotWeightPerPiece).toFixed(2)}g</td></tr>
              <tr className="bg-slate-50/40"><td className="p-2 text-center text-slate-400">9</td><td className="p-2 font-bold text-slate-700">Reconciliation Weight (Shot wt + 1.0% Melt Loss)</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baselineCalc.reconciliationWeight.toFixed(2)}g</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runningCalc.reconciliationWeight.toFixed(2)}g</td><td className="p-2 text-right font-mono">{(runningCalc.reconciliationWeight - baselineCalc.reconciliationWeight).toFixed(2)}g</td></tr>
              <tr><td className="p-2 text-center text-slate-400">10</td><td className="p-2 font-bold text-slate-900">Raw Material Cost</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.rawMaterialCost.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">₹{runningCalc.rawMaterialCost.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runningCalc.rawMaterialCost - baselineCalc.rawMaterialCost).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">11</td><td className="p-2 font-bold text-purple-950">Master Batch Cost</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.masterbatchCost.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">₹{runningCalc.masterbatchCost.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runningCalc.masterbatchCost - baselineCalc.masterbatchCost).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">12</td><td className="p-2 font-bold text-emerald-800">Runner Recovery Credit (Scrap Credit)</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50 text-emerald-700">- ₹{baselineCalc.runnerCredit.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold text-emerald-700">- ₹{runningCalc.runnerCredit.toFixed(2)}</td><td className="p-2 text-right font-mono text-slate-500">₹{(runningCalc.runnerCredit - baselineCalc.runnerCredit).toFixed(2)}</td></tr>
              <tr className="bg-amber-100/60 font-bold"><td className="p-2 text-center">13</td><td className="p-2 font-black text-slate-900">TOTAL RAW MATERIAL COST</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono font-black bg-amber-50">₹{baselineCalc.totalRmCost.toFixed(2)}</td><td className="p-2 bg-blue-100/70 font-mono font-black text-blue-950">₹{runningCalc.totalRmCost.toFixed(2)}</td><td className="p-2 text-right font-mono font-black">₹{(runningCalc.totalRmCost - baselineCalc.totalRmCost).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">14</td><td className="p-2 font-bold text-slate-900">Cycle Time Approved</td><td className="p-2 text-center font-mono">Sec</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseCycle}s</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="1" value={runningCycleTime} onChange={e => setRunningCycleTime(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-blue-700">{(Number(runningCycleTime) - baseCycle).toFixed(1)}s</td></tr>
              <tr><td className="p-2 text-center text-slate-400">15</td><td className="p-2 font-bold text-slate-900">Shift Machine Tariff (Tonnage: {runningTonnage}T)</td><td className="p-2 text-center font-mono">₹/shift</td><td className="p-2 text-right font-mono bg-slate-50">₹{baseTariff}</td><td className="p-2 text-right bg-blue-50/40 font-mono font-bold">₹{actualTariff}</td><td className="p-2 text-right font-mono">{actualTariff - baseTariff}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">16</td><td className="p-2 font-bold text-slate-900">Machine Conversion Cost / Piece</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.conversionCost.toFixed(2)}</td><td className="p-2 bg-blue-50/30 font-mono font-bold">₹{runningCalc.conversionCost.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runningCalc.conversionCost - baselineCalc.conversionCost).toFixed(2)}</td></tr>
              <tr className="bg-slate-900 text-white font-bold">
                <td className="p-2.5 text-center">17</td>
                <td className="p-2.5 font-black text-amber-300 uppercase tracking-wider">TOTAL COMPONENT BASELINE COST</td>
                <td className="p-2.5 text-center font-mono">₹</td>
                <td className="p-2.5 text-right font-mono font-black text-amber-300 text-sm">₹{baselineCalc.totalCost.toFixed(2)}</td>
                <td className="p-2.5 font-mono font-black text-emerald-300 text-sm bg-slate-800 text-right">₹{runningCalc.totalCost.toFixed(2)}</td>
                <td className={`p-2.5 text-right font-mono font-black text-sm ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                  {profitLossDelta >= 0 ? `₹ +${profitLossDelta.toFixed(2)}` : `₹ -${Math.abs(profitLossDelta).toFixed(2)}`}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div className="space-y-2 pt-2 border-t">
          <div>
            <label className="font-bold text-slate-700 block mb-1">Reason for Shopfloor Spec Drift / Audit Trail Record *</label>
            <input type="text" value={reason} onChange={e => setReason(e.target.value)} className="w-full border p-2 rounded-xl text-xs outline-none focus:ring-2 focus:ring-blue-500" />
          </div>
          <div className="flex justify-between items-center pt-2">
            <button onClick={onClose} className="px-4 py-2 border rounded-xl hover:bg-slate-50 cursor-pointer">Cancel</button>
            <button onClick={handleSaveHaier} className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"><Save className="w-4 h-4" /> Save & Log Haier Parameters</button>
          </div>
        </div>
      </div>
    </div>
  );
}
MODAL_EOF

echo "==> 3. Clean clearing Vite cache and restarting dev server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Complete synchronization deployed successfully."
