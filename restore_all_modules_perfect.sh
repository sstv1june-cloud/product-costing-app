#!/usr/bin/env bash
set -e

# ==============================================================================
# 1. MASTER STORE: Atomberg + Haier + RM/MB Matrices + Dynamic Lock Management
# ==============================================================================
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

# ==============================================================================
# 2. INLINE EDIT MODAL: 38-Line Vertical Format for Atomberg + 18-Line for Haier
# ==============================================================================
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, Lock, TrendingUp, TrendingDown } from 'lucide-react';
import { getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';

export function calculateHaierCost(params) {
  const cavity = Math.max(1, Number(params.cavity) || 1);
  const netWeight = Number(params.netWeight ?? params.partWt) || 0;
  const runnerWeight = Number(params.runnerWeight ?? params.runnerWt) || 0;
  const rmRate = Number(params.rmRate ?? params.rmBase) || 140.00;
  const mbPct = Number(params.masterbatchPct ?? params.mbPct) || 0;
  const mbRate = Number(params.masterbatchRate ?? params.mbBase) || (rmRate * 1.9);
  const cycleTime = Math.max(1, Number(params.cycleTime) || 48);
  const machineTonnage = Number(params.machineTonnage ?? params.tonnage) || 450;
  const shiftTariff = Number(params.shiftTariff || (machineTonnage >= 650 ? 5760 : 4600));

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
    shiftTariff, conversionCost, totalCost
  };
}

export function calculateAtombergCost(p) {
  const rmBase = Number(p.rmBase ?? p.rmRate ?? 140.0);
  const rmIcc = rmBase * 0.01;
  const rmFreight = Number(p.rmFreight ?? 1.50);
  const rmLanded = rmBase + rmIcc + rmFreight;

  const mbBase = Number(p.mbBase ?? p.masterbatchRate ?? 254.0);
  const mbIcc = mbBase * 0.01;
  const mbFreight = Number(p.mbFreight ?? 2.00);
  const mbLanded = mbBase + mbIcc + mbFreight;

  const rawMbPct = Number(p.mbPct !== undefined ? p.mbPct : (p.masterbatchPct !== undefined ? (p.masterbatchPct > 1 ? p.masterbatchPct / 100 : p.masterbatchPct) : 0.04));
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

export function calculateDetailedCost(params, isBaseline = false) {
  if ((params.vendor || '').toLowerCase() === 'atomberg') {
    return calculateAtombergCost(params);
  }
  return calculateHaierCost(params);
}

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const isAtomberg = (item.vendor || '').toLowerCase() === 'atomberg';
  const rmInfo = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');
  const mbInfo = getActiveMbMapping(item.vendor, '2026-08-01');

  // ---------- ATOMBERG 38-LINE VERTICAL FORMAT ----------
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
                
                <tr className="bg-amber-50/60 font-bold">
                  <td className="p-2 text-center text-slate-400">5</td>
                  <td className="p-2 font-black text-amber-950">RM Base Rate (From RM Matrix)</td>
                  <td className="p-2 text-center font-mono">₹/kg</td>
                  <td className="p-2 text-right font-mono font-black text-amber-900 bg-amber-100/50">₹{baseCalc.rmBase.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono font-black text-blue-900 bg-blue-100/50">₹{runCalc.rmBase.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono">{(runCalc.rmBase - baseCalc.rmBase).toFixed(2)}</td>
                </tr>

                <tr>
                  <td className="p-2 text-center text-slate-400">6</td>
                  <td className="p-2">ICC Cost @ 1% of RM</td>
                  <td className="p-2 text-center">1%</td>
                  <td className="p-2 text-right font-mono">₹{baseCalc.rmIcc.toFixed(2)}</td>
                  <td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rmIcc.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono">{(runCalc.rmIcc - baseCalc.rmIcc).toFixed(2)}</td>
                </tr>

                <tr>
                  <td className="p-2 text-center text-slate-400">7</td>
                  <td className="p-2">Freight Cost</td>
                  <td className="p-2 text-center">₹/kg</td>
                  <td className="p-2 text-right font-mono">₹{baseCalc.rmFreight.toFixed(2)}</td>
                  <td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.rmFreight.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono">0.00</td>
                </tr>

                <tr className="bg-emerald-50/70 font-bold border-y-2 border-emerald-200">
                  <td className="p-2 text-center text-emerald-800">8</td>
                  <td className="p-2 font-black text-emerald-950">RM Landed Cost (Base + ICC + Freight)</td>
                  <td className="p-2 text-center font-mono">₹/kg</td>
                  <td className="p-2 text-right font-mono font-black text-emerald-900 bg-emerald-100/60">₹{baseCalc.rmLanded.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono font-black text-emerald-900 bg-blue-100/60">₹{runCalc.rmLanded.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono font-black text-emerald-800">{(runCalc.rmLanded - baseCalc.rmLanded).toFixed(2)}</td>
                </tr>

                <tr className="bg-purple-50/60 font-bold">
                  <td className="p-2 text-center text-slate-400">9</td>
                  <td className="p-2 font-black text-purple-950">MB Base Cost (From RM Matrix)</td>
                  <td className="p-2 text-center font-mono">₹/kg</td>
                  <td className="p-2 text-right font-mono font-black text-purple-900 bg-purple-100/50">₹{baseCalc.mbBase.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono font-black text-blue-900 bg-blue-100/50">₹{runCalc.mbBase.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono">{(runCalc.mbBase - baseCalc.mbBase).toFixed(2)}</td>
                </tr>

                <tr>
                  <td className="p-2 text-center text-slate-400">10</td>
                  <td className="p-2">MB-ICC Cost @ 1% of MB</td>
                  <td className="p-2 text-center">1%</td>
                  <td className="p-2 text-right font-mono">₹{baseCalc.mbIcc.toFixed(2)}</td>
                  <td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mbIcc.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono">{(runCalc.mbIcc - baseCalc.mbIcc).toFixed(2)}</td>
                </tr>

                <tr>
                  <td className="p-2 text-center text-slate-400">11</td>
                  <td className="p-2">MB Freight Cost</td>
                  <td className="p-2 text-center">₹/kg</td>
                  <td className="p-2 text-right font-mono">₹{baseCalc.mbFreight.toFixed(2)}</td>
                  <td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mbFreight.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono">0.00</td>
                </tr>

                <tr className="bg-purple-100/50 font-bold border-y-2 border-purple-200">
                  <td className="p-2 text-center text-purple-900">12</td>
                  <td className="p-2 font-black text-purple-950">MB Landed Cost (Base + ICC + Freight)</td>
                  <td className="p-2 text-center font-mono">₹/kg</td>
                  <td className="p-2 text-right font-mono font-black text-purple-950 bg-purple-200/50">₹{baseCalc.mbLanded.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono font-black text-purple-950 bg-blue-100/60">₹{runCalc.mbLanded.toFixed(2)}</td>
                  <td className="p-2 text-right font-mono font-black text-purple-900">{(runCalc.mbLanded - baseCalc.mbLanded).toFixed(2)}</td>
                </tr>

                <tr className="bg-purple-50/30">
                  <td className="p-2 text-center text-slate-400">13</td>
                  <td className="p-2 font-bold text-purple-950">MB %</td>
                  <td className="p-2 text-center">%</td>
                  <td className="p-2 text-right font-mono font-bold bg-slate-50">{(baseP.mbPct * 100).toFixed(2)}%</td>
                  <td className="p-2 text-right bg-blue-50/40">
                    <input type="number" step="0.1" value={mbPctVal} onChange={e => setMbPctVal(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" />
                  </td>
                  <td className="p-2 text-right font-mono font-bold text-purple-700">{(Number(mbPctVal) - 4).toFixed(2)}%</td>
                </tr>

                <tr className="bg-amber-100/50 font-bold">
                  <td className="p-2 text-center">14</td>
                  <td className="p-2 font-black">RM cost( PP + MB) /KG</td>
                  <td className="p-2 text-center">₹/kg</td>
                  <td className="p-2 text-right font-mono font-black">₹{baseCalc.rmCombRate.toFixed(4)}</td>
                  <td className="p-2 text-right bg-blue-100/60 font-mono font-black">₹{runCalc.rmCombRate.toFixed(4)}</td>
                  <td className="p-2 text-right font-mono">{(runCalc.rmCombRate - baseCalc.rmCombRate).toFixed(4)}</td>
                </tr>

                <tr>
                  <td className="p-2 text-center text-slate-400">15</td>
                  <td className="p-2 font-bold">part weight grams</td>
                  <td className="p-2 text-center">Gms</td>
                  <td className="p-2 text-right font-mono font-bold">37.0g</td>
                  <td className="p-2 text-right bg-blue-50/40">
                    <input type="number" step="0.5" value={partWt} onChange={e => setPartWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" />
                  </td>
                  <td className="p-2 text-right font-mono">{(Number(partWt) - 37).toFixed(1)}g</td>
                </tr>

                <tr>
                  <td className="p-2 text-center text-slate-400">16</td>
                  <td className="p-2 font-bold">Runner weight grams</td>
                  <td className="p-2 text-center">Gms</td>
                  <td className="p-2 text-right font-mono font-bold">1.0g</td>
                  <td className="p-2 text-right bg-blue-50/40">
                    <input type="number" step="0.5" value={runnerWt} onChange={e => setRunnerWt(e.target.value)} className="w-20 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" />
                  </td>
                  <td className="p-2 text-right font-mono">{(Number(runnerWt) - 1).toFixed(1)}g</td>
                </tr>

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
                <tr><td className="p-2 text-center text-slate-400">27</td><td className="p-2 font-bold">Process cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.processCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">{runCalc.processCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.processCost - baseCalc.processCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">28</td><td className="p-2">Handling cost for BOP</td><td className="p-2 text-center">3%</td><td className="p-2 text-right font-mono">₹0.00</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.bopHandling.toFixed(4)}</td><td className="p-2 text-right font-mono">{runCalc.bopHandling.toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">29</td><td className="p-2 font-bold">Post operation cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹1.73</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹1.73</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr className="bg-blue-100/50 font-bold"><td className="p-2 text-center">30</td><td className="p-2 font-black text-blue-950">Total Process Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono font-black">₹{baseCalc.totalProcessCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-100/70 font-mono font-black">₹{runCalc.totalProcessCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.totalProcessCost - baseCalc.totalProcessCost).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">31</td><td className="p-2">Profit & OH</td><td className="p-2 text-center">12%</td><td className="p-2 text-right font-mono">₹{baseCalc.profitOh.toFixed(4)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.profitOh.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.profitOh - baseCalc.profitOh).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">32</td><td className="p-2">Inprocess Rejection</td><td className="p-2 text-center">4%</td><td className="p-2 text-right font-mono">₹{baseCalc.inprocessRejection.toFixed(4)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.inprocessRejection.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.inprocessRejection - baseCalc.inprocessRejection).toFixed(4)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">33</td><td className="p-2 font-bold text-emerald-800">Runner recovery cost</td><td className="p-2 text-center">₹25/kg</td><td className="p-2 text-right font-mono text-emerald-700">- ₹0.025</td><td className="p-2 text-right bg-blue-50/30 font-mono text-emerald-700">- ₹{Math.abs(runCalc.runnerRecovery).toFixed(3)}</td><td className="p-2 text-right font-mono">{(runCalc.runnerRecovery - baseCalc.runnerRecovery).toFixed(3)}</td></tr>
                <tr><td className="p-2 text-center text-slate-400">34</td><td className="p-2">Packing cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.86</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹0.86</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr><td className="p-2 text-center text-slate-400">35</td><td className="p-2">Transport cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹0.62</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹0.62</td><td className="p-2 text-right font-mono">0.00</td></tr>
                <tr><td className="p-2 text-center text-slate-400">36</td><td className="p-2">Mould maintenance cost</td><td className="p-2 text-center">2%</td><td className="p-2 text-right font-mono">₹{baseCalc.mouldMaint.toFixed(4)}</td><td className="p-2 text-right bg-blue-50/30 font-mono">₹{runCalc.mouldMaint.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.mouldMaint - baseCalc.mouldMaint).toFixed(4)}</td></tr>
                <tr className="bg-slate-100 font-bold"><td className="p-2 text-center">37</td><td className="p-2 font-black">Other Cost</td><td className="p-2 text-center">₹/pc</td><td className="p-2 text-right font-mono">₹{baseCalc.otherCost.toFixed(4)}</td><td className="p-2 text-right bg-blue-50 font-mono">₹{runCalc.otherCost.toFixed(4)}</td><td className="p-2 text-right font-mono">{(runCalc.otherCost - baseCalc.otherCost).toFixed(4)}</td></tr>
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

  // ---------- HAIER 18-LINE FORMAT ----------
  const dynamicHaierApprovedRm = Number(rmInfo.approvedPrice || 140.00);
  const dynamicHaierActualRm = Number(rmInfo.activeWaPrice || 134.80);

  const baseCavity = Number(item.cavity || 2);
  const baseNetWt = Number(item.netWeight || 197);
  const baseRunnerWt = Number(item.runnerWeight || 40);
  const baseMbPct = Number(item.masterbatchPct ?? (item.itemCode === '0060217978E' ? 3.5 : 0.0));
  const baseMbRate = Number(item.masterbatchRate || (item.itemCode === '0060217978E' ? 240.00 : 0.0));
  const baseCycle = Number(item.cycleTimeApproved || item.cycleTime || 48);
  const baseTonnage = Number(item.machineTonnage || 450);
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
    rmRate: dynamicHaierApprovedRm, masterbatchPct: baseMbPct, masterbatchRate: baseMbRate,
    cycleTime: baseCycle, machineTonnage: baseTonnage, shiftTariff: baseTariff
  });

  const runningCalc = calculateHaierCost({
    cavity: Number(runningCavity), netWeight: Number(runningNetWeight), runnerWeight: Number(runningRunnerWeight),
    rmRate: dynamicHaierActualRm, masterbatchPct: Number(runningMbPct), masterbatchRate: baseMbRate,
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
              <tr><td className="p-2 text-center text-slate-400">4</td><td className="p-2 font-bold text-purple-950">Masterbatch Required</td><td className="p-2 text-center font-mono">%</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseMbPct.toFixed(2)}%</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.1" value={runningMbPct} onChange={e => setRunningMbPct(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-purple-700">{(Number(runningMbPct) - baseMbPct).toFixed(2)}%</td></tr>
              <tr><td className="p-2 text-center text-slate-400">5</td><td className="p-2 font-bold text-slate-900">No. of Cavity</td><td className="p-2 text-center font-mono">Nos</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseCavity}</td><td className="p-2 text-right bg-blue-50/40"><input type="number" value={runningCavity} onChange={e => setRunningCavity(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{Number(runningCavity) - baseCavity}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">6</td><td className="p-2 font-bold text-slate-900">Runner Weight</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baseRunnerWt}g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runningRunnerWeight} onChange={e => setRunningRunnerWeight(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono">{(Number(runningRunnerWeight) - baseRunnerWt).toFixed(1)}g</td></tr>
              <tr><td className="p-2 text-center text-slate-400">7</td><td className="p-2 font-bold text-slate-900">Net Weight</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseNetWt}g</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="0.5" value={runningNetWeight} onChange={e => setRunningNetWeight(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold">{(Number(runningNetWeight) - baseNetWt).toFixed(1)}g</td></tr>
              <tr className="bg-slate-50/40"><td className="p-2 text-center text-slate-400">8</td><td className="p-2 font-bold text-slate-700">Shot Weight (Calculated / pc)</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baselineCalc.shotWeightPerPiece.toFixed(2)}g</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runningCalc.shotWeightPerPiece.toFixed(2)}g</td><td className="p-2 text-right font-mono">{(runningCalc.shotWeightPerPiece - baselineCalc.shotWeightPerPiece).toFixed(2)}g</td></tr>
              <tr className="bg-slate-50/40"><td className="p-2 text-center text-slate-400">9</td><td className="p-2 font-bold text-slate-700">Reconciliation Weight (Shot wt + 1.0% Melt Loss)</td><td className="p-2 text-center font-mono">Gms</td><td className="p-2 text-right font-mono bg-slate-50">{baselineCalc.reconciliationWeight.toFixed(2)}g</td><td className="p-2 text-right bg-blue-50/30 font-mono">{runningCalc.reconciliationWeight.toFixed(2)}g</td><td className="p-2 text-right font-mono">{(runningCalc.reconciliationWeight - baselineCalc.reconciliationWeight).toFixed(2)}g</td></tr>
              <tr><td className="p-2 text-center text-slate-400">10</td><td className="p-2 font-bold text-slate-900">Raw Material Cost</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.rawMaterialCost.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">₹{runningCalc.rawMaterialCost.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runningCalc.rawMaterialCost - baselineCalc.rawMaterialCost).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">11</td><td className="p-2 font-bold text-purple-950">Master Batch Cost</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.masterbatchCost.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">₹{runningCalc.masterbatchCost.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runningCalc.masterbatchCost - baselineCalc.masterbatchCost).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">12</td><td className="p-2 font-bold text-emerald-800">Runner Recovery Credit (Scrap Credit)</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50 text-emerald-700">- ₹{baselineCalc.runnerCredit.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold text-emerald-700">- ₹{runningCalc.runnerCredit.toFixed(2)}</td><td className="p-2 text-right font-mono text-slate-500">₹{(runningCalc.runnerCredit - baselineCalc.runnerCredit).toFixed(2)}</td></tr>
              <tr className="bg-amber-100/60 font-bold"><td className="p-2 text-center">13</td><td className="p-2 font-black text-slate-900">TOTAL RAW MATERIAL COST</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono font-black bg-amber-50">₹{baselineCalc.totalRmCost.toFixed(2)}</td><td className="p-2 text-right bg-blue-100/70 font-mono font-black text-blue-950">₹{runningCalc.totalRmCost.toFixed(2)}</td><td className="p-2 text-right font-mono font-black">₹{(runningCalc.totalRmCost - baselineCalc.totalRmCost).toFixed(2)}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">14</td><td className="p-2 font-bold text-slate-900">Cycle Time Approved</td><td className="p-2 text-center font-mono">Sec</td><td className="p-2 text-right font-mono font-bold bg-slate-50">{baseCycle}s</td><td className="p-2 text-right bg-blue-50/40"><input type="number" step="1" value={runningCycleTime} onChange={e => setRunningCycleTime(e.target.value)} className="w-24 border border-blue-400 bg-white font-mono font-bold px-2 py-0.5 rounded text-right" /></td><td className="p-2 text-right font-mono font-bold text-blue-700">{(Number(runningCycleTime) - baseCycle).toFixed(1)}s</td></tr>
              <tr><td className="p-2 text-center text-slate-400">15</td><td className="p-2 font-bold text-slate-900">Shift Machine Tariff (Tonnage: {runningTonnage}T)</td><td className="p-2 text-center font-mono">₹/shift</td><td className="p-2 text-right font-mono bg-slate-50">₹{baseTariff}</td><td className="p-2 text-right bg-blue-50/40 font-mono font-bold">₹{actualTariff}</td><td className="p-2 text-right font-mono">{actualTariff - baseTariff}</td></tr>
              <tr><td className="p-2 text-center text-slate-400">16</td><td className="p-2 font-bold text-slate-900">Machine Conversion Cost / Piece</td><td className="p-2 text-center font-mono">₹</td><td className="p-2 text-right font-mono bg-slate-50">₹{baselineCalc.conversionCost.toFixed(2)}</td><td className="p-2 text-right bg-blue-50/30 font-mono font-bold">₹{runningCalc.conversionCost.toFixed(2)}</td><td className="p-2 text-right font-mono">₹{(runningCalc.conversionCost - baselineCalc.conversionCost).toFixed(2)}</td></tr>
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

# ==============================================================================
# 3. RM PRICE MATRIX: Clean Lock/Unlock Toggles & Dynamic Vendor Dropdowns
# ==============================================================================
cat << 'RM_PAGE_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { Sliders, Lock, Unlock, History, Calendar, CheckCircle2 } from 'lucide-react';
import { globalStore, subscribeStore, updateVendorScheduleBulk, toggleVendorLockStatus } from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [activeSubTab, setActiveSubTab] = useState('matrix');
  const [validFrom, setValidFrom] = useState('2026-08-01');
  const [validTo, setValidTo] = useState('2026-08-31');
  const [successMsg, setSuccessMsg] = useState(null);

  const isLocked = Boolean(globalStore.vendorLockStatus[selectedVendor]);
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
    if (isLocked) return;
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
    if (isLocked) return;
    setLocalRows(prev => prev.map(r => r.id === rowId ? { ...r, activeSelection: altKey } : r));
  };

  const handleApprovedPriceEdit = (rowId, newPrice) => {
    if (isLocked) return;
    setLocalRows(prev => prev.map(r => r.id === rowId ? { ...r, approvedPrice: Number(newPrice) || 0 } : r));
  };

  const handleSaveAndLock = () => {
    updateVendorScheduleBulk(selectedVendor, validFrom, validTo, localRows);
    setSuccessMsg(`Period schedule locked and synced across all baseline pages for ${selectedVendor}`);
    setTimeout(() => setSuccessMsg(null), 3500);
  };

  const handleToggleUnlock = () => {
    toggleVendorLockStatus(selectedVendor, !isLocked);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Sliders className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">2. RM & MB Tariff & Alternate Weighted Average (WA) Matrix</h1>
            <p className="text-[11px] text-slate-300">
              Active Scope: <span className="text-amber-300 font-bold">{selectedVendor}</span> | Status: <span className={isLocked ? "text-emerald-400 font-bold" : "text-amber-400 font-bold"}>{isLocked ? "🔒 LOCKED & ACTIVE" : "🔓 OPEN (EDITABLE)"}</span>
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button onClick={() => setActiveSubTab('matrix')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeSubTab === 'matrix' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300'}`}>RM & MB Schedule</button>
          <button onClick={() => setActiveSubTab('purchases')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeSubTab === 'purchases' ? 'bg-amber-600 text-white shadow' : 'bg-slate-800 text-slate-300'}`}>Purchases ({purchaseMaster.length})</button>
          <button onClick={() => setActiveSubTab('sales')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeSubTab === 'sales' ? 'bg-indigo-600 text-white shadow' : 'bg-slate-800 text-slate-300'}`}>Sales ({salesData.length})</button>
          <button onClick={() => setActiveSubTab('audit')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeSubTab === 'audit' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300'}`}><History className="w-3.5 h-3.5 inline mr-1" /> Audit Trail ({rmHistoryLogs.length})</button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2.5 rounded-xl flex items-center gap-2 font-bold shadow-xs">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700">SELECT VENDOR:</span>
            <select value={selectedVendor} onChange={e => setSelectedVendor(e.target.value)} className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer">
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 border rounded-xl px-3 py-1 text-slate-700">
            <Calendar className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-[11px]">VALIDITY:</span>
            <input type="date" disabled={isLocked} value={validFrom} onChange={e => setValidFrom(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs disabled:bg-slate-100" />
            <span>&rarr;</span>
            <input type="date" disabled={isLocked} value={validTo} onChange={e => setValidTo(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs disabled:bg-slate-100" />
          </div>
        </div>

        {activeSubTab === 'matrix' && (
          <div className="flex items-center gap-2">
            {isLocked ? (
              <button onClick={handleToggleUnlock} className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-amber-300 font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm">
                <Unlock className="w-3.5 h-3.5" /> Unlock Schedule to Edit
              </button>
            ) : (
              <button onClick={handleSaveAndLock} className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm">
                <Lock className="w-3.5 h-3.5" /> Lock & Sync Period Schedule
              </button>
            )}
          </div>
        )}
      </div>

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
                  <tr key={row.id} className={isLocked ? "bg-slate-50/70" : "hover:bg-blue-50/30"}>
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
                        disabled={isLocked}
                        value={row.approvedPrice}
                        onChange={e => handleApprovedPriceEdit(row.id, e.target.value)}
                        className={`w-24 text-right border font-mono font-black p-1 rounded ${
                          isLocked ? 'bg-slate-200 border-slate-300 text-slate-800' : 'bg-amber-50/50 border-amber-300 text-slate-900'
                        }`}
                      />
                    </td>
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <input
                          type="radio"
                          disabled={isLocked}
                          name={`active-${row.id}`}
                          checked={row.activeSelection === 'alt1'}
                          onChange={() => handleSelectActive(row.id, 'alt1')}
                          className="cursor-pointer"
                        />
                        <select
                          disabled={isLocked}
                          value={row.alt1?.code || ''}
                          onChange={e => handleAlternateChange(row.id, 'alt1', e.target.value)}
                          className="border border-slate-300 rounded-lg p-1 text-xs w-full bg-white font-medium disabled:bg-slate-100"
                        >
                          <option value="">-- Select Inward Material --</option>
                          {purchaseMaster.map(p => (
                            <option key={p.code} value={p.code}>{p.name} (₹{p.waPrice.toFixed(2)})</option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">₹{row.alt1?.waPrice ? Number(row.alt1.waPrice).toFixed(2) : '0.00'}</td>
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <input
                          type="radio"
                          disabled={isLocked}
                          name={`active-${row.id}`}
                          checked={row.activeSelection === 'alt2'}
                          onChange={() => handleSelectActive(row.id, 'alt2')}
                          className="cursor-pointer"
                        />
                        <select
                          disabled={isLocked}
                          value={row.alt2?.code || ''}
                          onChange={e => handleAlternateChange(row.id, 'alt2', e.target.value)}
                          className="border border-slate-300 rounded-lg p-1 text-xs w-full bg-white font-medium disabled:bg-slate-100"
                        >
                          <option value="">-- Select Alternate Lot 2 --</option>
                          {purchaseMaster.map(p => (
                            <option key={p.code} value={p.code}>{p.name} (₹{p.waPrice.toFixed(2)})</option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">₹{row.alt2?.waPrice ? Number(row.alt2.waPrice).toFixed(2) : '0.00'}</td>
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

# ==============================================================================
# 4. BASELINE MASTER: Dynamic Switch Vendor + Multi-Product Uploader
# ==============================================================================
cat << 'BASE_PAGE_EOF' > src/modules/module1-baseline/BaselineMasterPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Layers, Download, Upload, History, Search, CheckCircle2, 
  Building2, Edit3, Plus, FileSpreadsheet, X, Check, ArrowRight, Trash2
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

  const [showUploadModal, setShowUploadModal] = useState(false);
  const [uploadedFileName, setUploadedFileName] = useState('');
  const [stagedBatchProducts, setStagedBatchProducts] = useState([]);

  const vendorList = globalStore.vendors || [];
  const rawList = getVendorBaselineData(selectedVendor);

  const filteredList = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  const changeLogs = (globalStore.parameterChangeLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  const handleBulkExcelUpload = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadedFileName(file.name);
    const reader = new FileReader();

    reader.onload = (evt) => {
      try {
        const bstr = evt.target.result;
        const wb = XLSX.read(bstr, { type: 'binary' });
        const extracted = [];
        const isHaier = selectedVendor.toLowerCase().includes('haier');

        wb.SheetNames.forEach(sheetName => {
          const ws = wb.Sheets[sheetName];
          const rawRows = XLSX.utils.sheet_to_json(ws, { header: 1 });
          if (!rawRows || rawRows.length < 5) return;

          const maxCols = Math.max(...rawRows.map(r => (r ? r.length : 0)));
          const startCol = 3;

          for (let col = startCol; col < maxCols; col++) {
            let partCode = '';
            let partName = '';
            let rmGrade = isHaier ? 'ABS 300 Pre Colour' : 'PP H110MA';
            let rmBaseRate = 140.00;
            let mbBaseRate = isHaier ? 0 : 254.00;
            let mbPct = isHaier ? 0.0 : 4.0;
            let partWt = isHaier ? 197 : 37;
            let runnerWt = isHaier ? 40 : 1;
            let cavity = 2;
            let cycleTime = isHaier ? 48 : 47;
            let tonnage = isHaier ? 450 : 200;
            let shiftTariff = isHaier ? 4600 : 2000;
            let bopCost = 0;

            let colHasData = false;

            rawRows.forEach(row => {
              if (!row || row.length === 0) return;
              const label = row.find((c, i) => i < 3 && typeof c === 'string' && c.trim() !== '');
              const val = row[col] !== undefined ? row[col] : null;

              if (label && val !== null && val !== '') {
                colHasData = true;
                const lLower = label.toString().toLowerCase();

                if (lLower.includes('part code') || lLower.includes('item code') || lLower.includes('part no')) {
                  partCode = String(val).trim();
                } else if (lLower.includes('part name') || lLower.includes('component')) {
                  partName = String(val).trim();
                } else if (lLower.includes('rm grade') || lLower.includes('polymer')) {
                  rmGrade = String(val).trim();
                } else if (lLower.includes('rm base rate') || lLower.includes('rm rate')) {
                  rmBaseRate = Number(val) || 140;
                } else if (lLower.includes('mb base') || lLower.includes('masterbatch rate')) {
                  mbBaseRate = Number(val) || 254;
                } else if (lLower.includes('mb %') || lLower.includes('masterbatch %')) {
                  const n = Number(val) || 0;
                  mbPct = n < 1 ? n * 100 : n;
                } else if (lLower.includes('part weight') || lLower.includes('net wt')) {
                  partWt = Number(val) || (isHaier ? 197 : 37);
                } else if (lLower.includes('runner weight')) {
                  runnerWt = Number(val) || (isHaier ? 40 : 1);
                } else if (lLower.includes('cavity')) {
                  cavity = Number(val) || 2;
                } else if (lLower.includes('cycle time')) {
                  cycleTime = Number(val) || (isHaier ? 48 : 47);
                } else if (lLower.includes('tonnage')) {
                  tonnage = Number(val) || (isHaier ? 450 : 200);
                  shiftTariff = tonnage >= 650 ? 5760 : (tonnage <= 200 ? 2000 : 4600);
                } else if (lLower.includes('bop') || lLower.includes('insert')) {
                  bopCost = Number(val) || 0;
                }
              }
            });

            if (colHasData && (partCode || partName)) {
              extracted.push({
                id: `BL-${selectedVendor.toUpperCase()}-${partCode || Date.now()}-${col}`,
                vendor: selectedVendor,
                itemCode: partCode || `PART-${extracted.length + 101}`,
                componentName: partName || `${selectedVendor} Component ${extracted.length + 1}`,
                model: sheetName || 'Standard',
                mouldSize: isHaier ? '1070*720*650' : '950*600*450',
                approvedRm: rmGrade,
                approvedRmRate: rmBaseRate,
                masterbatchPct: mbPct,
                masterbatchRate: mbBaseRate,
                bopCost: bopCost,
                cavity: cavity,
                netWeight: partWt,
                runnerWeight: runnerWt,
                cycleTimeApproved: cycleTime,
                cycleTime: cycleTime,
                machineTonnage: tonnage,
                hourlyRate: shiftTariff / 8,
                validFrom: "2026-08-01",
                parameters: {
                  cavity,
                  netWeightApproved: partWt,
                  runnerWeight: runnerWt,
                  cycleTimeApproved: cycleTime,
                  machineTonnage: tonnage,
                  shiftTariff,
                  bopCost,
                  masterbatchPct: mbPct
                }
              });
            }
          }
        });

        if (extracted.length === 0) {
          alert(`No new product columns detected for ${selectedVendor}.`);
          return;
        }

        setStagedBatchProducts(extracted);
      } catch (err) {
        alert("Error parsing multi-product Excel file: " + err.message);
      }
    };

    reader.readAsBinaryString(file);
  };

  const handleCommitBatchUpload = () => {
    addVendorBaselineProducts(selectedVendor, stagedBatchProducts);
    setShowUploadModal(false);
    setStagedBatchProducts([]);
    setSuccessMsg(`Imported ${stagedBatchProducts.length} new products into ${selectedVendor} Baseline.`);
    setTimeout(() => setSuccessMsg(null), 4000);
  };

  const handleRemoveStagedItem = (idx) => {
    setStagedBatchProducts(prev => prev.filter((_, i) => i !== idx));
  };

  const handleDownloadVerticalTemplate = () => {
    const isHaier = selectedVendor.toLowerCase().includes('haier');
    let multiProductTemplate;
    if (isHaier) {
      multiProductTemplate = [
        ["", "Vendor", "", "Haier", "Haier", "Haier"],
        ["", "Name Of Component", "", "End Cap Top Ref", "End Cap Bottom Ref", "Crisper Veg Box"],
        ["", "Mould Size L * W * H", "", "1070*720*650", "1070*720*650", "1120*780*700"],
        ["", "Item No. / Code", "", "0060226713H", "0060217989D", "0060217978E"],
        ["", "Model", "", "DC-195", "DC-195", "DC-195"],
        ["", "Raw Material Required", "", "ABS 300 Pre Colour", "ABS 300 Pre Colour", "GPPS SC201LV"],
        ["", "RM Base Rate", "", 140.00, 140.00, 103.08],
        ["", "Master Batch Required", "", 0.00, 0.00, 3.50],
        ["", "No. of Cavity", "", 2, 2, 1],
        ["", "Runner Weight", "", 40, 40, 22],
        ["", "Net Weight", "", 197, 197, 485],
        ["", "Cycle Time Approved", "", 48, 48, 58],
        ["", "Machine Tonnage", "", 450, 450, 650],
        ["", "Shift Tariff", "", 4600, 4600, 5760]
      ];
    } else {
      multiProductTemplate = [
        ["", "Vendor", "", selectedVendor, selectedVendor, selectedVendor],
        ["", "Part Code", "", "A101701", "A101702", "A101703"],
        ["", "Part name", "", "Aris Top Canopy - White", "Aris Top Canopy - Black", "Aris Bottom Ring"],
        ["", "RM grade", "", "PP H110MA", "PP H110MA", "PP H110MA"],
        ["", "RM Base Rate", "", 140, 140, 140],
        ["", "ICC Cost @ 1% of RM", "", 1.40, 1.40, 1.40],
        ["", "Fright Cost", "", 1.5, 1.5, 1.5],
        ["", "RM Landed Cost", "", 142.90, 142.90, 142.90],
        ["", "MB Base Cost", "", 254, 254, 254],
        ["", "MB-ICC Cost @ 1% of MB", "", 2.54, 2.54, 2.54],
        ["", "Fright Cost", "", 2, 2, 2],
        ["", "MB Landed Cost", "", 258.54, 258.54, 258.54],
        ["", "MB %", "", 0.04, 0.04, 0.04],
        ["", "RM cost( PP + MB) /KG", "", 147.5256, 147.5256, 147.5256],
        ["", "part weight grams", "", 37, 37, 45],
        ["", "Runner weight grams", "", 1, 1, 2],
        ["", "Gross weight", "", 38, 38, 47],
        ["", "RM cost", "", 5.606, 5.606, 6.934],
        ["", "Inserts/BOP cost", "", 0.00, 0.00, 0.00],
        ["", "RM + BOP Cost", "", 5.606, 5.606, 6.934],
        ["", "M/c tonnage", "", 200, 200, 250],
        ["", "shift rate", 10.00, 2000, 2000, 2500],
        ["", "cycle time( seconds)", "", 47, 47, 50],
        ["", "Efficiency", 0.90, 0.90, 0.90, 0.90],
        ["", "No of cavity", "", 2, 2, 2],
        ["", "No. of parts/shift", "", 1102.98, 1102.98, 1036.80],
        ["", "Process cost", "", 1.8133, 1.8133, 2.4113],
        ["", "Handling cost for BOP", 0.03, 0, 0, 0],
        ["", "Post operation cost", "", 1.73, 1.73, 1.73],
        ["", "Total Process Cost", "", 3.5433, 3.5433, 4.1413],
        ["", "Profit & OH", 0.12, 1.0979, 1.0979, 1.3290],
        ["", "Inprocess Rejection", 0.04, 0.3660, 0.3660, 0.4430],
        ["", "Runner recovery cost", 25.00, -0.025, -0.025, -0.050],
        ["", "ICC", 0.02, 0, 0, 0],
        ["", "Packing cost", "", 0.86, 0.86, 0.95],
        ["", "Transpost cost", 10.00, 0.62, 0.62, 0.70],
        ["", "Mould maintanance cost", 0.02, 0.0709, 0.0709, 0.0828],
        ["", "Other Cost", "", 2.9898, 2.9898, 3.4548],
        ["", "Final Landed cost", "", 12.1391, 12.1391, 14.5301]
      ];
    }

    const ws = XLSX.utils.aoa_to_sheet(multiProductTemplate);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Standard_Format");
    XLSX.writeFile(wb, `${selectedVendor}_Multi_Product_Template.xlsx`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Building2 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master</h1>
            <p className="text-[11px] text-slate-300">
              Active Vendor: <span className="text-amber-300 font-mono font-bold">{selectedVendor}</span> | Registered Parts: <span className="font-mono text-emerald-300">{rawList.length} Active</span>
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={() => { setStagedBatchProducts([]); setShowUploadModal(true); }}
            className="flex items-center gap-1.5 px-3.5 py-1.5 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl transition cursor-pointer shadow-xs"
          >
            <Upload className="w-3.5 h-3.5" /> + Upload Products (.xlsx)
          </button>

          <button
            onClick={handleDownloadVerticalTemplate}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl transition cursor-pointer shadow-xs"
          >
            <Download className="w-3.5 h-3.5" /> Template (.xlsx)
          </button>

          <button onClick={() => setActiveTab('parameters')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'}`}>1. Parameters Master ({rawList.length})</button>
          <button onClick={() => setActiveTab('audit_log')} className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeTab === 'audit_log' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'}`}><History className="w-3.5 h-3.5" /> 2. Parameter Audit Log ({changeLogs.length})</button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2 rounded-xl flex items-center gap-2 font-semibold">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3 flex-1 min-w-[280px]">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input type="text" value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} placeholder={`Search ${selectedVendor} components...`} className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none" />
          </div>

          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700 text-xs">Switch Vendor:</span>
            <select value={selectedVendor} onChange={(e) => setSelectedVendor(e.target.value)} className="border-2 border-blue-600 rounded-xl px-3 py-1.5 text-xs font-bold bg-white text-blue-950 outline-none cursor-pointer">
              {vendorList.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors Combined</option>
            </select>
          </div>
        </div>
      </div>

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
                      <span className="text-[10px] text-slate-500 font-mono">₹{item.approvedRmRate || 140}/kg</span>
                    </td>
                    <td className="p-3 text-center font-mono font-bold text-purple-700">{(item.masterbatchPct || 0).toFixed(2)}%</td>
                    <td className="p-3 text-center font-bold font-mono text-slate-900">{item.cavity || 1}</td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">{item.netWeight || 37}g</td>
                    <td className="p-3 text-right font-mono text-slate-600">{item.runnerWeight || 1}g</td>
                    <td className="p-3 text-center"><span className="bg-amber-100 text-amber-900 font-mono font-bold px-2 py-0.5 rounded text-[11px]">{item.cycleTimeApproved || item.cycleTime || 47}s</span></td>
                    <td className="p-3 text-center font-mono font-bold text-slate-700">{item.machineTonnage || 200}T</td>
                    <td className="p-3 text-right font-mono font-semibold text-slate-700">₹{item.hourlyRate ? (item.hourlyRate * 8) : (item.machineTonnage >= 650 ? 5760 : (item.machineTonnage <= 200 ? 2000 : 4600))}</td>
                    <td className="p-3 text-center">
                      <button type="button" onClick={() => setEditingItem(item)} className="p-1.5 bg-blue-50 hover:bg-blue-600 text-blue-600 hover:text-white rounded-lg transition cursor-pointer border border-blue-200 shadow-xs inline-flex items-center justify-center" title="Edit Baseline & Running Parameters">
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

      {/* MULTI-PRODUCT BULK UPLOAD MODAL */}
      {showUploadModal && (
        <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
          <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full p-5 space-y-4 border border-slate-300 max-h-[92vh] overflow-y-auto">
            <div className="flex justify-between items-center border-b pb-3">
              <div>
                <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                  <Upload className="w-4 h-4 text-purple-600" /> Upload New Products for {selectedVendor}
                </h3>
                <p className="text-[11px] text-slate-500">Supports Multi-Column (Col D, E, F...) or Multi-Tab Vertical Workbooks</p>
              </div>
              <button onClick={() => setShowUploadModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer">
                <X className="w-5 h-5" />
              </button>
            </div>

            {stagedBatchProducts.length === 0 ? (
              <div className="p-8 border-2 border-dashed border-purple-300 bg-purple-50/40 rounded-2xl text-center space-y-3">
                <FileSpreadsheet className="w-10 h-10 text-purple-600 mx-auto" />
                <h4 className="font-bold text-sm text-slate-900">Select Multi-Product Excel File (.xlsx) for {selectedVendor}</h4>
                <p className="text-[11px] text-slate-500 max-w-md mx-auto">
                  Upload your specification workbook. The engine will detect all product columns in parallel and stage them for baseline registration.
                </p>
                <div>
                  <input
                    type="file"
                    id="batch-excel-upload"
                    accept=".xlsx,.xls"
                    onChange={handleBulkExcelUpload}
                    className="hidden"
                  />
                  <label
                    htmlFor="batch-excel-upload"
                    className="px-5 py-2.5 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl cursor-pointer inline-flex items-center gap-2 shadow-xs"
                  >
                    <Upload className="w-4 h-4" /> Choose Excel File (.xlsx)
                  </label>
                </div>
              </div>
            ) : (
              <div className="space-y-3">
                <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 p-3 rounded-xl flex items-center justify-between font-bold">
                  <div className="flex items-center gap-2">
                    <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                    <span>Detected {stagedBatchProducts.length} New Products from "{uploadedFileName}"</span>
                  </div>
                  <span className="text-[10px] bg-emerald-200 text-emerald-900 px-2.5 py-0.5 rounded-full">Ready to Register</span>
                </div>

                <div className="border border-slate-300 rounded-xl overflow-hidden max-h-72 overflow-y-auto">
                  <table className="min-w-full text-xs text-left">
                    <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0">
                      <tr>
                        <th className="p-2 w-10 text-center">#</th>
                        <th className="p-2">Part Code</th>
                        <th className="p-2">Component Name</th>
                        <th className="p-2">RM Grade</th>
                        <th className="p-2 text-center">Cavity</th>
                        <th className="p-2 text-right">Net Wt</th>
                        <th className="p-2 text-center">Cycle Time</th>
                        <th className="p-2 text-center">Tonnage</th>
                        <th className="p-2 text-center w-12">Action</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-200 font-medium">
                      {stagedBatchProducts.map((p, idx) => (
                        <tr key={idx} className="hover:bg-slate-50">
                          <td className="p-2 text-center font-mono text-slate-500">{idx + 1}</td>
                          <td className="p-2 font-mono font-bold text-blue-700">{p.itemCode}</td>
                          <td className="p-2 font-semibold text-slate-900">{p.componentName}</td>
                          <td className="p-2 text-purple-900 font-bold">{p.approvedRm}</td>
                          <td className="p-2 text-center font-mono">{p.cavity}</td>
                          <td className="p-2 text-right font-mono font-bold">{p.netWeight}g</td>
                          <td className="p-2 text-center font-mono">{p.cycleTimeApproved}s</td>
                          <td className="p-2 text-center font-mono">{p.machineTonnage}T</td>
                          <td className="p-2 text-center">
                            <button
                              onClick={() => handleRemoveStagedItem(idx)}
                              className="text-rose-500 hover:text-rose-700 p-1 cursor-pointer"
                              title="Remove item"
                            >
                              <Trash2 className="w-3.5 h-3.5" />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div className="flex justify-between items-center pt-3 border-t">
                  <button
                    onClick={() => setStagedBatchProducts([])}
                    className="px-3 py-1.5 border rounded-lg hover:bg-slate-50 cursor-pointer"
                  >
                    Reset File
                  </button>
                  <button
                    onClick={handleCommitBatchUpload}
                    className="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"
                  >
                    <Check className="w-4 h-4" /> Confirm & Add All {stagedBatchProducts.length} Products to {selectedVendor}
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      {editingItem && (
        <InlineEditModal
          item={editingItem}
          isOpen={Boolean(editingItem)}
          onClose={() => setEditingItem(null)}
          onSave={({ updatedItem, changeType, newValidFrom, reason }) => {
            updateBaselineParameters({ itemId: editingItem?.id, updatedItem, changeType, newValidFrom, reason });
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

# ==============================================================================
# 5. COSTING RUN ENGINE: Complete Sync with Baseline, RM Matrix, & P&L signs
# ==============================================================================
cat << 'COST_EOF' > src/modules/module3-costing-engine/CostingRunEnginePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  DollarSign, Sliders, Search, TrendingUp, TrendingDown, 
  CheckCircle2 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping, getVendorBaselineData } from '../../shared/masterStore';
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
                <th className="p-3">ITEM CODE / COMPONENT</th>
                <th className="p-3 text-center">VENDOR</th>
                <th className="p-3">APPROVED RM</th>
                <th className="p-3 text-right bg-amber-50">APPROVED RM RATE</th>
                <th className="p-3">ACTIVE ALTERNATE RM (INWARD)</th>
                <th className="p-3 text-right bg-blue-50">ACTIVE WA RATE</th>
                <th className="p-3 text-right bg-amber-50 font-bold">APPROVED BASELINE</th>
                <th className="p-3 text-right bg-blue-50 font-bold">SIMULATED ACTUAL</th>
                <th className="p-3 text-right">PROFIT / LOSS (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {filteredItems.map((item) => {
                const params = item.parameters || {};
                const rmMapping = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');
                const mbMapping = getActiveMbMapping(item.vendor, '2026-08-01');

                const baseSpec = {
                  vendor: item.vendor,
                  rmBase: Number(rmMapping.approvedPrice || item.approvedRmRate || 140.00),
                  rmRate: Number(rmMapping.approvedPrice || item.approvedRmRate || 140.00),
                  mbBase: Number(mbMapping.approvedMbPrice || item.masterbatchRate || 254.00),
                  masterbatchRate: Number(mbMapping.approvedMbPrice || item.masterbatchRate || 254.00),
                  mbPct: Number((item.masterbatchPct ?? params.masterbatchPct ?? 4.0) / 100),
                  masterbatchPct: Number(item.masterbatchPct ?? params.masterbatchPct ?? 4.0),
                  partWt: Number(item.netWeight ?? params.netWeightApproved ?? 37),
                  netWeight: Number(item.netWeight ?? params.netWeightApproved ?? 37),
                  runnerWt: Number(item.runnerWeight ?? params.runnerWeight ?? 1),
                  runnerWeight: Number(item.runnerWeight ?? params.runnerWeight ?? 1),
                  bopCost: Number(item.bopCost || params.bopCost || 0.0),
                  tonnage: Number(item.machineTonnage ?? params.machineTonnage ?? 200),
                  machineTonnage: Number(item.machineTonnage ?? params.machineTonnage ?? 200),
                  shiftTariff: Number(item.hourlyRate ? item.hourlyRate * 8 : (params.shiftTariff ?? 2000)),
                  cycleTime: Number(item.cycleTimeApproved ?? item.cycleTime ?? 47),
                  cavity: Number(item.cavity ?? params.cavity ?? 2)
                };
                const baselineCalc = calculateDetailedCost(baseSpec, true);

                const runningSpec = {
                  vendor: item.vendor,
                  rmBase: Number(rmMapping.activeWaPrice || baseSpec.rmBase),
                  rmRate: Number(rmMapping.activeWaPrice || baseSpec.rmRate),
                  mbBase: Number(mbMapping.activeMbPrice || baseSpec.mbBase),
                  masterbatchRate: Number(mbMapping.activeMbPrice || baseSpec.masterbatchRate),
                  mbPct: Number((params.runningMbPct !== undefined ? params.runningMbPct : baseSpec.masterbatchPct) / 100),
                  masterbatchPct: Number(params.runningMbPct ?? baseSpec.masterbatchPct),
                  partWt: Number(params.runningNetWeight ?? baseSpec.partWt),
                  netWeight: Number(params.runningNetWeight ?? baseSpec.netWeight),
                  runnerWt: Number(params.runningRunnerWeight ?? baseSpec.runnerWt),
                  runnerWeight: Number(params.runningRunnerWeight ?? baseSpec.runnerWeight),
                  bopCost: Number(params.runningBopCost ?? baseSpec.bopCost),
                  tonnage: Number(params.runningTonnage ?? baseSpec.tonnage),
                  machineTonnage: Number(params.runningTonnage ?? baseSpec.machineTonnage),
                  shiftTariff: Number(params.runningShiftTariff ?? baseSpec.shiftTariff),
                  cycleTime: Number(params.runningCycleTime ?? baseSpec.cycleTime),
                  cavity: Number(params.runningCavity ?? baseSpec.cavity)
                };
                const runningCalc = calculateDetailedCost(runningSpec, false);

                const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
                const actualCost = Number(runningCalc.totalCost.toFixed(2));
                const unitProfitLoss = Number((contractBaseline - actualCost).toFixed(2));

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
                      ₹{baseSpec.rmBase.toFixed(2)}/kg
                    </td>
                    <td className="p-3">
                      <span className="font-bold text-blue-900 block">{rmMapping.activeRmName}</span>
                      <span className="text-[10px] text-slate-500 font-mono">Linked to RM Matrix</span>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-blue-900 bg-blue-50/50">
                      ₹{Number(rmMapping.activeWaPrice).toFixed(2)}/kg
                    </td>
                    <td className="p-3 text-right font-mono font-black text-slate-900 bg-amber-50/50 text-xs">
                      ₹{contractBaseline.toFixed(2)}
                    </td>
                    <td className="p-3 text-right font-mono font-black text-blue-950 bg-blue-50/50 text-xs">
                      ₹{actualCost.toFixed(2)}
                    </td>
                    <td className="p-3 text-right font-mono font-black">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded text-[11px] ${
                        unitProfitLoss >= 0 ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-rose-100 text-rose-800 border border-rose-300'
                      }`}>
                        {unitProfitLoss >= 0 ? <TrendingUp className="w-3.5 h-3.5 text-emerald-600" /> : <TrendingDown className="w-3.5 h-3.5 text-rose-600" />}
                        {unitProfitLoss >= 0 ? `₹ +${unitProfitLoss.toFixed(2)}` : `₹ -${Math.abs(unitProfitLoss).toFixed(2)}`}
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
COST_EOF

# ==============================================================================
# 6. MIS INTELLIGENCE: Full Dynamic Dropdown & Sales Drilldown
# ==============================================================================
cat << 'MIS_EOF' > src/modules/module4-mis/MISIntelligencePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Search, Calendar, 
  Eye, FileSpreadsheet, Layers, ShieldCheck, CheckCircle2 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISIntelligencePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [fromDate, setFromDate] = useState('2026-08-01');
  const [toDate, setToDate] = useState('2026-08-31');

  const salesData = (globalStore.salesData || []).filter(s => {
    const vMatch = selectedVendor === 'ALL' || s.vendor === selectedVendor;
    const dMatch = (!fromDate || s.invoiceDate >= fromDate) && (!toDate || s.invoiceDate <= toDate);
    return vMatch && dMatch;
  });

  const baselineList = globalStore.baselineList || [];

  const analyzedRows = useMemo(() => {
    return salesData.map(sale => {
      const part = baselineList.find(p => p.itemCode === sale.itemCode) || {};
      const params = part.parameters || {};
      const rmMapping = getActiveRmMapping(part.approvedRm || 'PP H110MA', sale.vendor, sale.invoiceDate);
      const mbMapping = getActiveMbMapping(sale.vendor, sale.invoiceDate);

      const baseSpec = {
        vendor: sale.vendor,
        rmBase: Number(rmMapping.approvedPrice || part.approvedRmRate || 140.00),
        rmRate: Number(rmMapping.approvedPrice || part.approvedRmRate || 140.00),
        mbBase: Number(mbMapping.approvedMbPrice || part.masterbatchRate || 254.00),
        masterbatchRate: Number(mbMapping.approvedMbPrice || part.masterbatchRate || 254.00),
        mbPct: Number((part.masterbatchPct ?? params.masterbatchPct ?? 4.0) / 100),
        masterbatchPct: Number(part.masterbatchPct ?? params.masterbatchPct ?? 4.0),
        partWt: Number(part.netWeight ?? params.netWeightApproved ?? 37),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 37),
        runnerWt: Number(part.runnerWeight ?? params.runnerWeight ?? 1),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 1),
        bopCost: Number(part.bopCost || params.bopCost || 0.0),
        tonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 200),
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 200),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 2000)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 47),
        cavity: Number(part.cavity ?? params.cavity ?? 2)
      };
      const baselineCalc = calculateDetailedCost(baseSpec, true);

      const runningSpec = {
        vendor: sale.vendor,
        rmBase: Number(rmMapping.activeWaPrice || baseSpec.rmBase),
        rmRate: Number(rmMapping.activeWaPrice || baseSpec.rmRate),
        mbBase: Number(mbMapping.activeMbPrice || baseSpec.mbBase),
        masterbatchRate: Number(mbMapping.activeMbPrice || baseSpec.masterbatchRate),
        mbPct: Number((params.runningMbPct !== undefined ? params.runningMbPct : baseSpec.masterbatchPct) / 100),
        masterbatchPct: Number(params.runningMbPct ?? baseSpec.masterbatchPct),
        partWt: Number(params.runningNetWeight ?? baseSpec.partWt),
        netWeight: Number(params.runningNetWeight ?? baseSpec.netWeight),
        runnerWt: Number(params.runningRunnerWeight ?? baseSpec.runnerWt),
        runnerWeight: Number(params.runningRunnerWeight ?? baseSpec.runnerWeight),
        bopCost: Number(params.runningBopCost ?? baseSpec.bopCost),
        tonnage: Number(params.runningTonnage ?? baseSpec.tonnage),
        machineTonnage: Number(params.runningTonnage ?? baseSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? baseSpec.shiftTariff),
        cycleTime: Number(params.runningCycleTime ?? baseSpec.cycleTime),
        cavity: Number(params.runningCavity ?? baseSpec.cavity)
      };
      const runningCalc = calculateDetailedCost(runningSpec, false);

      const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
      const actualUnitCost = Number(runningCalc.totalCost.toFixed(2));
      const unitDelta = Number((contractBaseline - actualUnitCost).toFixed(2));
      const totalDelta = Number((unitDelta * sale.saleUnit).toFixed(2));
      const totalSales = Number((sale.sellingPrice * sale.saleUnit).toFixed(2));

      return {
        ...sale,
        contractBaseline,
        actualUnitCost,
        unitDelta,
        totalDelta,
        totalSales
      };
    });
  }, [salesData, baselineList]);

  const summary = useMemo(() => {
    const totalVolume = analyzedRows.reduce((a, b) => a + (b.saleUnit || 0), 0);
    const totalRevenue = analyzedRows.reduce((a, b) => a + (b.totalSales || 0), 0);
    const totalCostDelta = analyzedRows.reduce((a, b) => a + (b.totalDelta || 0), 0);
    return {
      totalVolume,
      totalRevenue,
      totalCostDelta
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
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Gross Realization</span>
          <span className="text-2xl font-black text-emerald-900 font-mono mt-1 block">
            ₹{(summary.totalRevenue * 0.12).toLocaleString('en-IN', { maximumFractionDigits: 0 })}
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
                <th className="p-3 text-right bg-amber-50">Contract Baseline</th>
                <th className="p-3 text-right bg-blue-50">Actual Unit Cost</th>
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
MIS_EOF

# ==============================================================================
# 7. DASHBOARD: Synchronized Overall Stats
# ==============================================================================
cat << 'DASH_EOF' > src/modules/module0-dashboard/DashboardPage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  Building2, Layers, Sliders, DollarSign, BarChart3, Bot, 
  TrendingUp, TrendingDown, CheckCircle2, UserPlus, Upload, FileSpreadsheet, X, Check
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, onboardVendorWithBlueprint, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function DashboardPage({ onNavigate }) {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [showOnboardModal, setShowOnboardModal] = useState(false);
  const [onboardStep, setOnboardStep] = useState(1);
  const [successMsg, setSuccessMsg] = useState(null);

  const [newVendorData, setNewVendorData] = useState({
    vendorName: '',
    vendorCode: '',
    paymentTerms: '45 Days',
    currency: 'INR (₹)'
  });

  const [uploadedFileName, setUploadedFileName] = useState('');
  const [sheetName, setSheetName] = useState('');
  const [stagedLines, setStagedLines] = useState([]);
  const [stagedProduct, setStagedProduct] = useState({});

  const vendors = globalStore.vendors || [];
  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];

  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const dashboardStats = useMemo(() => {
    let totalRev = 0;
    let totalGain = 0;
    let totalQty = 0;

    vendorProducts.forEach(part => {
      const params = part.parameters || {};
      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor || selectedVendor, '2026-08-01');
      const mbMapping = getActiveMbMapping(part.vendor || selectedVendor, '2026-08-01');

      const baseSpec = {
        vendor: part.vendor,
        rmBase: Number(rmMapping.approvedPrice || part.approvedRmRate || 140.00),
        rmRate: Number(rmMapping.approvedPrice || part.approvedRmRate || 140.00),
        mbBase: Number(mbMapping.approvedMbPrice || part.masterbatchRate || 254.00),
        masterbatchRate: Number(mbMapping.approvedMbPrice || part.masterbatchRate || 254.00),
        mbPct: Number((part.masterbatchPct ?? params.masterbatchPct ?? 4.0) / 100),
        masterbatchPct: Number(part.masterbatchPct ?? params.masterbatchPct ?? 4.0),
        partWt: Number(part.netWeight ?? params.netWeightApproved ?? 37),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 37),
        runnerWt: Number(part.runnerWeight ?? params.runnerWeight ?? 1),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 1),
        bopCost: Number(part.bopCost || params.bopCost || 0.0),
        tonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 200),
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 200),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 2000)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 47),
        cavity: Number(part.cavity ?? params.cavity ?? 2)
      };
      const baselineCalc = calculateDetailedCost(baseSpec, true);

      const runningSpec = {
        vendor: part.vendor,
        rmBase: Number(rmMapping.activeWaPrice || baseSpec.rmBase),
        rmRate: Number(rmMapping.activeWaPrice || baseSpec.rmRate),
        mbBase: Number(mbMapping.activeMbPrice || baseSpec.mbBase),
        masterbatchRate: Number(mbMapping.activeMbPrice || baseSpec.masterbatchRate),
        mbPct: Number((params.runningMbPct !== undefined ? params.runningMbPct : baseSpec.masterbatchPct) / 100),
        masterbatchPct: Number(params.runningMbPct ?? baseSpec.masterbatchPct),
        partWt: Number(params.runningNetWeight ?? baseSpec.partWt),
        netWeight: Number(params.runningNetWeight ?? baseSpec.netWeight),
        runnerWt: Number(params.runningRunnerWeight ?? baseSpec.runnerWt),
        runnerWeight: Number(params.runningRunnerWeight ?? baseSpec.runnerWeight),
        bopCost: Number(params.runningBopCost ?? baseSpec.bopCost),
        tonnage: Number(params.runningTonnage ?? baseSpec.tonnage),
        machineTonnage: Number(params.runningTonnage ?? baseSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? baseSpec.shiftTariff),
        cycleTime: Number(params.runningCycleTime ?? baseSpec.cycleTime),
        cavity: Number(params.runningCavity ?? baseSpec.cavity)
      };
      const runningCalc = calculateDetailedCost(runningSpec, false);

      const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
      const actualCost = Number(runningCalc.totalCost.toFixed(2));
      const unitDelta = Number((contractBaseline - actualCost).toFixed(2));

      const matchedSales = salesData.filter(s => {
        const vMatch = selectedVendor === 'ALL' || s.vendor === (part.vendor || selectedVendor);
        return vMatch && s.itemCode === part.itemCode;
      });

      const qty = matchedSales.reduce((acc, s) => acc + Number(s.saleUnit || 0), 0);
      const sp = Number(matchedSales[0]?.sellingPrice || (contractBaseline * 1.18));

      totalQty += qty;
      totalRev += (sp * qty);
      totalGain += (unitDelta * qty);
    });

    return {
      totalQty,
      totalRev,
      totalGain: Number(totalGain.toFixed(2)),
      partsCount: vendorProducts.length
    };
  }, [vendorProducts, salesData, selectedVendor]);

  return (
    <div className="space-y-4 text-xs font-sans">
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
          <span className="text-[11px] font-bold text-slate-400">Vendor Scope:</span>
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
    </div>
  );
}
DASH_EOF

echo "==> All 6 modules completely restored with Atomberg and exact vertical schemas."
