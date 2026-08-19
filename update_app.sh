#!/usr/bin/env bash
set -e

mkdir -p src/shared src/modules/module1-baseline src/modules/module2-rm-matrix src/modules/module3-costing-engine src/modules/module4-mis

# 1. Update masterStore.js
cat << 'STORE_EOF' > src/shared/masterStore.js
import { initialBaselineData } from '../modules/module1-baseline/baselineData';

const data = Array.isArray(initialBaselineData) ? initialBaselineData : [];

export const initialPurchaseMaster = [
  { code: "PUR-ABS-01", invoiceNo: "INV-PUR-8821", name: "ABS 300-B Red (Prime Inward)", polymer: "ABS", supplier: "Supreme Petrochem", waPrice: 134.80, inwardDate: "2026-01-20", qtyKg: 12500 },
  { code: "PUR-ABS-02", invoiceNo: "INV-PUR-8822", name: "ABS 300-Blue (Imported)", polymer: "ABS", supplier: "Chi Mei", waPrice: 131.25, inwardDate: "2026-02-05", qtyKg: 8200 },
  { code: "PUR-ABS-03", invoiceNo: "INV-PUR-8823", name: "ABS Recycled Compound (15% Regrind)", polymer: "ABS", supplier: "In-House Reprocess", waPrice: 122.50, inwardDate: "2026-01-10", qtyKg: 15000 },
  { code: "PUR-GPPS-01", invoiceNo: "INV-PUR-8824", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", polymer: "GPPS", supplier: "Supreme", waPrice: 98.40, inwardDate: "2026-01-18", qtyKg: 9000 },
  { code: "PUR-GPPS-02", invoiceNo: "INV-PUR-8825", name: "GPPS Formosa SC-200 Equivalent", polymer: "GPPS", supplier: "Formosa Taiwan", waPrice: 95.50, inwardDate: "2026-02-02", qtyKg: 4500 },
  { code: "PUR-PP-01", invoiceNo: "INV-PUR-8826", name: "PP Reliance H110MA Prime", polymer: "PP", supplier: "Reliance Industries", waPrice: 95.19, inwardDate: "2026-01-25", qtyKg: 20000 }
];

export const initialSalesData = [
  { id: "SALE-01", invoiceNo: "INV-SLS-101", itemCode: "0060226713H", componentName: "End Cap Top Ref (without Screen Painting )", vendor: "Haier", saleUnit: 10, invoiceDate: "2026-01-20", sellingPrice: 38.50 },
  { id: "SALE-02", invoiceNo: "INV-SLS-102", itemCode: "0060217989D", componentName: "End cap Bottom Ref-ABS-DC-195,220", vendor: "Haier", saleUnit: 290, invoiceDate: "2026-02-05", sellingPrice: 42.00 },
  { id: "SALE-03", invoiceNo: "INV-SLS-103", itemCode: "0060217978E", componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX", vendor: "Haier", saleUnit: 300, invoiceDate: "2026-01-28", sellingPrice: 85.00 }
];

export const initialRmMatrix = [
  {
    id: "RM-HAIER-ABS-P1",
    vendor: "Haier",
    approvedRm: "ABS 300 Pre Colour",
    polymer: "ABS",
    approvedPrice: 136.20,
    validFrom: "2026-01-15",
    validTo: "2026-02-14",
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
    validFrom: "2026-01-15",
    validTo: "2026-02-14",
    activeSelection: "alt1",
    alt1: { code: "PUR-GPPS-01", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", waPrice: 98.40 },
    alt2: { code: "PUR-GPPS-02", name: "GPPS Formosa SC-200 Equivalent", waPrice: 95.50 },
    alt3: { code: "PUR-GPPS-03", name: "GPPS Reprocessed Clear Blend", waPrice: 89.20 }
  },
  {
    id: "RM-HAIER-PP-P1",
    vendor: "Haier",
    approvedRm: "PP B-120MA",
    polymer: "PP",
    approvedPrice: 96.19,
    validFrom: "2026-01-15",
    validTo: "2026-02-14",
    activeSelection: "alt1",
    alt1: { code: "PUR-PP-01", name: "PP Reliance H110MA Prime", waPrice: 95.19 },
    alt2: { code: "PUR-PP-02", name: "PP IOCL 1110MAS Alternate", waPrice: 93.80 },
    alt3: { code: "PUR-PP-03", name: "PP Copolymer In-House Blend", waPrice: 88.50 }
  },
  {
    id: "RM-LG-ABS-P1",
    vendor: "LG",
    approvedRm: "ABS 300 Pre Colour",
    polymer: "ABS",
    approvedPrice: 138.50,
    validFrom: "2026-01-15",
    validTo: "2026-02-14",
    activeSelection: "alt2",
    alt1: { code: "PUR-ABS-01", name: "ABS 300-B Red (Prime Inward)", waPrice: 134.80 },
    alt2: { code: "PUR-ABS-02", name: "ABS 300-Blue (Imported)", waPrice: 131.25 },
    alt3: { code: "PUR-ABS-03", name: "ABS Recycled Compound (15% Regrind)", waPrice: 122.50 }
  }
];

export const globalStore = {
  baselineList: data,
  baselineData: data,
  baselineProducts: data,
  products: data,
  parts: data,
  items: data,
  purchaseMaster: initialPurchaseMaster,
  salesData: initialSalesData,
  rmMatrix: initialRmMatrix,
  rawMaterials: initialRmMatrix,
  parameterChangeLogs: [],
  rmPriceHistoryLogs: [],
  vendors: [
    { vendorId: "Haier", vendorName: "Haier Appliances" },
    { vendorId: "LG", vendorName: "LG Electronics" },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India" }
  ]
};

const listeners = new Set();
export const subscribeStore = (fn) => { listeners.add(fn); return () => listeners.delete(fn); };
export const notifyStore = () => listeners.forEach(fn => fn());

export const getActiveRmMapping = (approvedRmName, vendor = "Haier", targetDate = null) => {
  const vKey = (vendor || "Haier").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey &&
    (r.approvedRm.toLowerCase() === (approvedRmName || "").toLowerCase() ||
     (approvedRmName || "").toLowerCase().includes(r.polymer.toLowerCase()))
  );

  let row = rows[0];
  if (targetDate && rows.length > 0) {
    const matchedPeriodRow = rows.find(r => targetDate >= r.validFrom && targetDate <= r.validTo);
    if (matchedPeriodRow) row = matchedPeriodRow;
  }

  if (!row) {
    return {
      vendor: vendor || "Haier",
      approvedRm: approvedRmName || "Standard Polymer",
      approvedPrice: 136.20,
      activeRmName: approvedRmName || "Standard Polymer",
      activeWaPrice: 136.20,
      validFrom: "2026-01-15",
      validTo: "2026-02-14"
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

export const updateVendorScheduleBulk = (vendor, validFrom, validTo, updatedRows, logEntries = []) => {
  globalStore.rmMatrix = globalStore.rmMatrix.map(row => {
    if (row.vendor === vendor) {
      const match = updatedRows.find(u => u.id === row.id);
      return match ? { ...match, validFrom, validTo } : { ...row, validFrom, validTo };
    }
    return row;
  });

  if (logEntries && logEntries.length > 0) {
    logEntries.forEach(log => {
      globalStore.rmPriceHistoryLogs.unshift({
        id: `HIST-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
        timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
        ...log
      });
    });
  }
  notifyStore();
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
    id: `SALE-${Date.now()}`,
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

export const updateBaselineParameters = ({ itemId, updatedItem, changeType, newValidFrom, reason } = {}) => {
  const list = globalStore.baselineList || [];
  const idx = list.findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
  if (idx !== -1) {
    const prev = list[idx];
    const prevParams = prev.parameters || {};
    const newParams = updatedItem?.parameters || {};

    const changesList = [];

    const oldCycle = Number(prev.cycleTimeApproved ?? prev.cycleTime ?? 48);
    const newCycle = Number(newParams.runningCycleTime ?? updatedItem.cycleTime ?? oldCycle);
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

    if (changesList.length > 0) {
      globalStore.parameterChangeLogs.unshift({
        id: `LOG-${Date.now()}`,
        timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
        itemCode: updatedItem?.itemCode || prev.itemCode,
        componentName: updatedItem?.componentName || prev.componentName,
        changedBy: "Engineering Head",
        field: changeType || "Manufacturing Parameters",
        changesList,
        costImpact: { oldCost, newCost, diff: costDelta },
        reason: reason || "Manual shopfloor optimization tuning"
      });
    }

    notifyStore();
  }
};

export const getVendorRmCosting = (vendorCode, rmCode) => {
  const res = getActiveRmMapping(rmCode, vendorCode);
  return res.activeWaPrice;
};

export { data as baselineList, data as baselineData, data as baselineProducts };
export default globalStore;
STORE_EOF

# 2. Update RMPriceMatrixPage.jsx (with Split Part Code & Name in Sales Form + Staging Engine)
cat << 'RM_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Layers, Edit3, Lock, Check, History, Calendar, Upload, Plus, 
  CheckCircle2, ShoppingCart, Truck, X, Download 
} from 'lucide-react';
import { 
  globalStore, subscribeStore, updateVendorScheduleBulk, 
  addManualPurchaseRecord, addManualSaleRecord, uploadBulkSales, uploadBulkPurchases 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [activeTab, setActiveTab] = useState('matrix');
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
  const vendorHistory = (globalStore.rmPriceHistoryLogs || []).filter(h => h.vendor === selectedVendor);

  const [localRows, setLocalRows] = useState([]);
  const [validFrom, setValidFrom] = useState('2026-01-15');
  const [validTo, setValidTo] = useState('2026-02-14');

  useEffect(() => {
    if (vendorRows.length > 0) {
      setLocalRows(JSON.parse(JSON.stringify(vendorRows)));
      setValidFrom(vendorRows[0].validFrom || '2026-01-15');
      setValidTo(vendorRows[0].validTo || '2026-02-14');
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

  const downloadPurchaseTemplate = () => {
    const csvContent = "data:text/csv;charset=utf-8," + 
      "RM_Polymer_Code,Inward_Date,Invoice_No,Material_Description,Supplier,Inward_Qty_Kg,Purchase_Rate_INR_Per_Kg\n" +
      "ABS,2026-01-20,INV-PUR-8821,ABS 300-B Red (Prime),Supreme Petrochem,12500,134.80\n" +
      "GPPS,2026-01-22,INV-PUR-8822,GPPS SC201LV + 3.5% Smoke Grey,Supreme Petrochem,9000,98.40\n" +
      "PP,2026-01-25,INV-PUR-8823,PP Reliance H110MA Prime,Reliance Industries,20000,95.19";
    const link = document.createElement("a");
    link.setAttribute("href", encodeURI(csvContent));
    link.setAttribute("download", "Purchase_Inward_Template.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const downloadSalesTemplate = () => {
    const csvContent = "data:text/csv;charset=utf-8," + 
      "Invoice_No,Invoice_Date,Vendor,Part_Code,Part_Name,Dispatch_Qty_Pcs,Selling_Price_INR\n" +
      "INV-SLS-101,2026-01-20,Haier,0060226713H,End Cap Top Ref (without Screen Painting ),10,38.50\n" +
      "INV-SLS-102,2026-02-05,Haier,0060217989D,End cap Bottom Ref-ABS-DC-195,220,290,42.00\n" +
      "INV-SLS-103,2026-01-28,Haier,0060217978E,CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX,300,85.00";
    const link = document.createElement("a");
    link.setAttribute("href", encodeURI(csvContent));
    link.setAttribute("download", "Sales_Dispatch_Template.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handlePurchaseFileUpload = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      const text = evt.target?.result;
      const lines = text.split('\n').filter(l => l.trim().length > 0);
      const parsed = [];
      for (let i = 1; i < lines.length; i++) {
        const [polymer, inwardDate, invoiceNo, name, supplier, qtyKg, waPrice] = lines[i].split(',').map(s => s.trim());
        if (name && waPrice) {
          parsed.push({
            code: `PUR-${Date.now()}-${i}`,
            invoiceNo: invoiceNo || `INV-P-${i}`,
            polymer: polymer || 'ABS',
            inwardDate: inwardDate || new Date().toISOString().slice(0, 10),
            name,
            supplier: supplier || 'Approved Sourcing',
            qtyKg: parseFloat(qtyKg) || 0,
            waPrice: parseFloat(waPrice) || 0
          });
        }
      }
      setStagedPurchases(parsed);
      setShowPurchaseModal(true);
    };
    reader.readAsText(file);
  };

  const handleSalesFileUpload = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      const text = evt.target?.result;
      const lines = text.split('\n').filter(l => l.trim().length > 0);
      const parsed = [];
      for (let i = 1; i < lines.length; i++) {
        const [invoiceNo, invoiceDate, vendor, itemCode, componentName, saleUnit, sellingPrice] = lines[i].split(',').map(s => s.trim());
        if (itemCode && saleUnit) {
          parsed.push({
            id: `SALE-${Date.now()}-${i}`,
            invoiceNo: invoiceNo || `INV-S-${i}`,
            invoiceDate: invoiceDate || new Date().toISOString().slice(0, 10),
            vendor: vendor || selectedVendor,
            itemCode,
            componentName: componentName || itemCode,
            saleUnit: parseInt(saleUnit, 10) || 0,
            sellingPrice: parseFloat(sellingPrice) || 0
          });
        }
      }
      setStagedSales(parsed);
      setShowSalesModal(true);
    };
    reader.readAsText(file);
  };

  const handleToggleGlobalEditLock = () => {
    if (isGlobalEditing) {
      updateVendorScheduleBulk(selectedVendor, validFrom, validTo, localRows);
      setIsGlobalEditing(false);
      setSuccessMsg(`Locked schedule for ${selectedVendor} (${validFrom} to ${validTo})`);
      setTimeout(() => setSuccessMsg(null), 3000);
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
                            {(globalStore.purchaseMaster || []).filter(p => p.polymer === row.polymer).map(p => (
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
                            {(globalStore.purchaseMaster || []).filter(p => p.polymer === row.polymer).map(p => (
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
                            {(globalStore.purchaseMaster || []).filter(p => p.polymer === row.polymer).map(p => (
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
            <div className="flex gap-2">
              <button onClick={downloadPurchaseTemplate} className="px-3 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-lg cursor-pointer flex items-center gap-1">
                <Download className="w-3.5 h-3.5" /> Download Template
              </button>
              <button onClick={() => { setStagedPurchases([]); setShowPurchaseModal(true); }} className="px-3 py-1 bg-amber-600 hover:bg-amber-700 text-white font-bold rounded-lg cursor-pointer flex items-center gap-1">
                <Plus className="w-3.5 h-3.5" /> + Enter / Upload Batch
              </button>
            </div>
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
                  <td className="p-2.5 font-mono text-slate-600">{p.inwardDate || '2026-01-20'}</td>
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
            <div className="flex gap-2">
              <button onClick={downloadSalesTemplate} className="px-3 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-lg cursor-pointer flex items-center gap-1">
                <Download className="w-3.5 h-3.5" /> Download Template
              </button>
              <button onClick={() => { setStagedSales([]); setShowSalesModal(true); }} className="px-3 py-1 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg cursor-pointer flex items-center gap-1">
                <Plus className="w-3.5 h-3.5" /> + Enter / Upload Sales
              </button>
            </div>
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

      {/* POPUP 1: PURCHASE INWARD MODAL */}
      {showPurchaseModal && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl p-5 max-w-2xl w-full space-y-4 border shadow-2xl">
            <div className="flex justify-between items-center border-b pb-2">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <ShoppingCart className="w-4 h-4 text-amber-600" /> Enter / Upload Purchase Inward Data
              </h3>
              <button type="button" onClick={() => setShowPurchaseModal(false)}><X className="w-5 h-5 text-slate-400" /></button>
            </div>

            <div className="bg-amber-50/60 border border-amber-200 rounded-xl p-3 flex justify-between items-center gap-3">
              <div>
                <span className="font-bold text-amber-950 block">Upload via Excel / CSV</span>
                <span className="text-[11px] text-amber-800">Supports: RM Code, Date, Invoice No, Qty, Rate</span>
              </div>
              <div className="flex gap-2">
                <button type="button" onClick={downloadPurchaseTemplate} className="px-3 py-1.5 bg-white border border-amber-300 font-bold rounded-lg text-amber-900 hover:bg-amber-100 flex items-center gap-1 cursor-pointer">
                  <Download className="w-3.5 h-3.5" /> Template
                </button>
                <label className="px-3 py-1.5 bg-amber-600 hover:bg-amber-700 text-white font-bold rounded-lg cursor-pointer flex items-center gap-1">
                  <Upload className="w-3.5 h-3.5" /> Select File
                  <input type="file" accept=".csv,.xlsx,.xls" onChange={handlePurchaseFileUpload} className="hidden" />
                </label>
              </div>
            </div>

            {stagedPurchases.length > 0 ? (
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="font-bold text-slate-900 text-xs">Staging Validation ({stagedPurchases.length} Batches Parsed)</span>
                  <span className="text-[11px] text-amber-700 font-bold">Review records before final commit</span>
                </div>
                <div className="max-h-56 overflow-y-auto border border-slate-300 rounded-xl">
                  <table className="min-w-full text-xs text-left">
                    <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                      <tr>
                        <th className="p-2">Invoice No</th>
                        <th className="p-2">Date</th>
                        <th className="p-2">Material</th>
                        <th className="p-2 text-right">Qty (Kg)</th>
                        <th className="p-2 text-right">Rate (₹/kg)</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-200">
                      {stagedPurchases.map((p, idx) => (
                        <tr key={idx}>
                          <td className="p-2 font-mono text-blue-700">{p.invoiceNo}</td>
                          <td className="p-2 font-mono text-slate-600">{p.inwardDate}</td>
                          <td className="p-2 font-semibold text-slate-900">{p.name}</td>
                          <td className="p-2 text-right font-mono">{p.qtyKg} kg</td>
                          <td className="p-2 text-right font-mono font-bold text-amber-900">₹{p.waPrice}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="flex justify-end gap-2 pt-2 border-t">
                  <button type="button" onClick={() => setStagedPurchases([])} className="px-3 py-1.5 border rounded-lg">Clear Staging</button>
                  <button type="button" onClick={() => {
                    uploadBulkPurchases(stagedPurchases);
                    setStagedPurchases([]);
                    setShowPurchaseModal(false);
                    setSuccessMsg(`Successfully committed ${stagedPurchases.length} purchase batches.`);
                    setTimeout(() => setSuccessMsg(null), 3000);
                  }} className="px-4 py-1.5 bg-amber-600 text-white font-bold rounded-lg shadow-sm">
                    Confirm & Commit Uploaded Batches
                  </button>
                </div>
              </div>
            ) : (
              <form onSubmit={(e) => {
                e.preventDefault();
                addManualPurchaseRecord({
                  invoiceNo: newPur.invoiceNo,
                  name: newPur.name,
                  polymer: newPur.polymer,
                  supplier: newPur.supplier,
                  waPrice: parseFloat(newPur.waPrice) || 0,
                  qtyKg: parseFloat(newPur.qtyKg) || 0,
                  inwardDate: newPur.inwardDate
                });
                setShowPurchaseModal(false);
                setSuccessMsg(`Purchase batch recorded with WA ₹${newPur.waPrice}/kg`);
                setTimeout(() => setSuccessMsg(null), 3000);
              }} className="space-y-3">
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Invoice No</label>
                    <input type="text" required value={newPur.invoiceNo} onChange={e => setNewPur({...newPur, invoiceNo: e.target.value})} className="w-full border p-2 rounded-lg text-xs font-mono" />
                  </div>
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Inward Date</label>
                    <input type="date" required value={newPur.inwardDate} onChange={e => setNewPur({...newPur, inwardDate: e.target.value})} className="w-full border p-2 rounded-lg text-xs font-mono" />
                  </div>
                </div>
                <div>
                  <label className="text-[10px] font-bold text-slate-500 uppercase block">Material / Batch Name</label>
                  <input type="text" required placeholder="e.g. ABS 300 Lot Batch 5" value={newPur.name} onChange={e => setNewPur({...newPur, name: e.target.value})} className="w-full border p-2 rounded-lg text-xs" />
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Polymer Family</label>
                    <select value={newPur.polymer} onChange={e => setNewPur({...newPur, polymer: e.target.value})} className="w-full border p-2 rounded-lg text-xs font-bold">
                      <option value="ABS">ABS</option>
                      <option value="GPPS">GPPS</option>
                      <option value="PP">PP</option>
                    </select>
                  </div>
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Supplier</label>
                    <input type="text" required placeholder="e.g. Supreme Petrochem" value={newPur.supplier} onChange={e => setNewPur({...newPur, supplier: e.target.value})} className="w-full border p-2 rounded-lg text-xs" />
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Inward Qty (Kg)</label>
                    <input type="number" required placeholder="10000" value={newPur.qtyKg} onChange={e => setNewPur({...newPur, qtyKg: e.target.value})} className="w-full border p-2 rounded-lg text-xs" />
                  </div>
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Inward Rate (₹/kg)</label>
                    <input type="number" step="0.01" required placeholder="134.50" value={newPur.waPrice} onChange={e => setNewPur({...newPur, waPrice: e.target.value})} className="w-full border p-2 rounded-lg text-xs font-bold text-amber-900" />
                  </div>
                </div>
                <div className="flex justify-end gap-2 pt-2 border-t">
                  <button type="button" onClick={() => setShowPurchaseModal(false)} className="px-3 py-1.5 border rounded-lg">Cancel</button>
                  <button type="submit" className="px-4 py-1.5 bg-amber-600 text-white font-bold rounded-lg">Record Purchase Batch</button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}

      {/* POPUP 2: SALES MODAL WITH SPLIT PART CODE & PART NAME */}
      {showSalesModal && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl p-5 max-w-2xl w-full space-y-4 border shadow-2xl">
            <div className="flex justify-between items-center border-b pb-2">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <Truck className="w-4 h-4 text-emerald-600" /> Enter / Upload Component Sales Dispatch
              </h3>
              <button type="button" onClick={() => setShowSalesModal(false)}><X className="w-5 h-5 text-slate-400" /></button>
            </div>

            <div className="bg-emerald-50/60 border border-emerald-200 rounded-xl p-3 flex justify-between items-center gap-3">
              <div>
                <span className="font-bold text-emerald-950 block">Upload via Excel / CSV</span>
                <span className="text-[11px] text-emerald-800">Supports: Invoice No, Date, Vendor, Part Code, Part Name, Qty</span>
              </div>
              <div className="flex gap-2">
                <button type="button" onClick={downloadSalesTemplate} className="px-3 py-1.5 bg-white border border-emerald-300 font-bold rounded-lg text-emerald-900 hover:bg-emerald-100 flex items-center gap-1 cursor-pointer">
                  <Download className="w-3.5 h-3.5" /> Template
                </button>
                <label className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg cursor-pointer flex items-center gap-1">
                  <Upload className="w-3.5 h-3.5" /> Select File
                  <input type="file" accept=".csv,.xlsx,.xls" onChange={handleSalesFileUpload} className="hidden" />
                </label>
              </div>
            </div>

            {stagedSales.length > 0 ? (
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="font-bold text-slate-900 text-xs">Staging Validation ({stagedSales.length} Invoices Parsed)</span>
                  <span className="text-[11px] text-emerald-700 font-bold">Review records before final commit</span>
                </div>
                <div className="max-h-56 overflow-y-auto border border-slate-300 rounded-xl">
                  <table className="min-w-full text-xs text-left">
                    <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                      <tr>
                        <th className="p-2">Invoice No</th>
                        <th className="p-2">Date</th>
                        <th className="p-2">Vendor</th>
                        <th className="p-2">Part Code</th>
                        <th className="p-2">Part Name</th>
                        <th className="p-2 text-right">Qty (Pcs)</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-200">
                      {stagedSales.map((s, idx) => (
                        <tr key={idx}>
                          <td className="p-2 font-mono text-blue-700">{s.invoiceNo}</td>
                          <td className="p-2 font-mono text-slate-600">{s.invoiceDate}</td>
                          <td className="p-2 font-semibold text-slate-700">{s.vendor}</td>
                          <td className="p-2 font-mono text-slate-900">{s.itemCode}</td>
                          <td className="p-2 font-semibold text-slate-900">{s.componentName}</td>
                          <td className="p-2 text-right font-mono font-bold text-emerald-800">{s.saleUnit} pcs</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="flex justify-end gap-2 pt-2 border-t">
                  <button type="button" onClick={() => setStagedSales([])} className="px-3 py-1.5 border rounded-lg">Clear Staging</button>
                  <button type="button" onClick={() => {
                    uploadBulkSales(stagedSales);
                    setStagedSales([]);
                    setShowSalesModal(false);
                    setSuccessMsg(`Successfully committed ${stagedSales.length} sales dispatches.`);
                    setTimeout(() => setSuccessMsg(null), 3000);
                  }} className="px-4 py-1.5 bg-emerald-600 text-white font-bold rounded-lg shadow-sm">
                    Confirm & Commit Uploaded Sales
                  </button>
                </div>
              </div>
            ) : (
              <form onSubmit={(e) => {
                e.preventDefault();
                addManualSaleRecord({
                  invoiceNo: newSale.invoiceNo,
                  itemCode: newSale.itemCode,
                  componentName: newSale.componentName,
                  vendor: newSale.vendor,
                  saleUnit: parseInt(newSale.saleUnit, 10) || 0,
                  invoiceDate: newSale.invoiceDate,
                  sellingPrice: parseFloat(newSale.sellingPrice) || 0
                });
                setShowSalesModal(false);
                setSuccessMsg(`Sales entry recorded for Part Code: ${newSale.itemCode}`);
                setTimeout(() => setSuccessMsg(null), 3000);
              }} className="space-y-3">
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Invoice No</label>
                    <input type="text" required value={newSale.invoiceNo} onChange={e => setNewSale({...newSale, invoiceNo: e.target.value})} className="w-full border p-2 rounded-lg text-xs font-mono" />
                  </div>
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Invoice Date</label>
                    <input type="date" required value={newSale.invoiceDate} onChange={e => setNewSale({...newSale, invoiceDate: e.target.value})} className="w-full border p-2 rounded-lg text-xs font-mono" />
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-2">
                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Vendor Target</label>
                    <select value={newSale.vendor} onChange={e => setNewSale({...newSale, vendor: e.target.value})} className="w-full border p-2 rounded-lg text-xs font-bold">
                      <option value="Haier">Haier</option>
                      <option value="LG">LG</option>
                      <option value="Whirlpool">Whirlpool</option>
                    </select>
                  </div>

                  <div>
                    <label className="text-[10px] font-bold text-blue-700 uppercase block">Part Code (Lookup)</label>
                    <select 
                      value={newSale.itemCode} 
                      onChange={e => handlePartCodeSelect(e.target.value)} 
                      className="w-full border-2 border-blue-500 p-2 rounded-lg text-xs font-mono font-bold text-blue-900 bg-white"
                    >
                      {(globalStore.baselineList || []).map(b => (
                        <option key={b.itemCode} value={b.itemCode}>{b.itemCode}</option>
                      ))}
                    </select>
                  </div>

                  <div>
                    <label className="text-[10px] font-bold text-slate-500 uppercase block">Part Name</label>
                    <input 
                      type="text" 
                      value={newSale.componentName} 
                      onChange={e => setNewSale({...newSale, componentName: e.target.value})} 
                      className="w-full border p-2 rounded-lg text-xs font-semibold text-slate-800 bg-slate-50" 
                      placeholder="Auto-populated / Editable"
                    />
                  </div>
                </div>

                <div>
                  <label className="text-[10px] font-bold text-slate-500 uppercase block">Dispatched Units (Pcs)</label>
                  <input type="number" required placeholder="e.g. 290" value={newSale.saleUnit} onChange={e => setNewSale({...newSale, saleUnit: e.target.value})} className="w-full border p-2 rounded-lg text-xs font-bold text-emerald-900" />
                </div>

                <div className="flex justify-end gap-2 pt-2 border-t">
                  <button type="button" onClick={() => setShowSalesModal(false)} className="px-3 py-1.5 border rounded-lg">Cancel</button>
                  <button type="submit" className="px-4 py-1.5 bg-emerald-600 text-white font-bold rounded-lg">Record Sales Entry</button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}

    </div>
  );
}
RM_EOF

# Ensure sync replica
cp src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx src/modules/module2-rm-matrix/RMMasterPage.jsx

# 3. Update MISVariancePage.jsx matching your exact 2-tier spreadsheet layout
cat << 'MIS_EOF' > src/modules/module4-mis/MISVariancePage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { BarChart3, Eye, X } from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISVariancePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const rmMatrix = globalStore.rmMatrix || [];

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [drilldownItem, setDrilldownItem] = useState(null);

  const activeVendorRmRow = rmMatrix.find(r => r.vendor === selectedVendor) || rmMatrix[0];
  const [periodFrom, setPeriodFrom] = useState(activeVendorRmRow?.validFrom || '2026-01-15');
  const [periodTo, setPeriodTo] = useState(activeVendorRmRow?.validTo || '2026-02-14');

  useEffect(() => {
    if (activeVendorRmRow) {
      setPeriodFrom(activeVendorRmRow.validFrom || '2026-01-15');
      setPeriodTo(activeVendorRmRow.validTo || '2026-02-14');
    }
  }, [selectedVendor]);

  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const misRows = useMemo(() => {
    return vendorProducts.map(part => {
      const params = part.parameters || {};

      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor, periodFrom);
      const approvedRmRate = rmMapping.approvedPrice || part.approvedRmRate || 136.20;
      const activeWaRate = rmMapping.activeWaPrice || approvedRmRate;

      const baselineSpec = {
        cavity: Number(part.cavity ?? params.cavity ?? 2),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 197),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 40),
        rmRate: approvedRmRate,
        masterbatchPct: Number(part.masterbatchPct ?? 0),
        masterbatchRate: Number(part.masterbatchRate ?? 0),
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 450),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 3600)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 48)
      };
      const baselineCalc = calculateDetailedCost(baselineSpec, true);

      const runningSpec = {
        cavity: Number(params.runningCavity ?? baselineSpec.cavity),
        netWeight: Number(params.runningNetWeight ?? baselineSpec.netWeight),
        runnerWeight: Number(params.runningRunnerWeight ?? baselineSpec.runnerWeight),
        rmRate: activeWaRate,
        masterbatchPct: Number(params.runningMbPct ?? baselineSpec.masterbatchPct),
        masterbatchRate: baselineSpec.masterbatchRate,
        machineTonnage: Number(params.runningTonnage ?? baselineSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? (params.runningTonnage >= 600 ? 4800 : baselineSpec.shiftTariff)),
        cycleTime: Number(params.runningCycleTime ?? baselineSpec.cycleTime)
      };
      const runningCalc = calculateDetailedCost(runningSpec, false);

      const unitProfitLoss = Number((baselineCalc.totalCost - runningCalc.totalCost).toFixed(2));

      const matchedSales = salesData.filter(s => {
        const vendorMatch = selectedVendor === 'ALL' || s.vendor === part.vendor;
        const itemMatch = s.itemCode === part.itemCode;
        const dateMatch = s.invoiceDate >= periodFrom && s.invoiceDate <= periodTo;
        return vendorMatch && itemMatch && dateMatch;
      });

      const periodSaleUnits = matchedSales.reduce((sum, s) => sum + Number(s.saleUnit || 0), 0);
      const totalPnL = Number((unitProfitLoss * periodSaleUnits).toFixed(2));

      return {
        part,
        itemCode: part.itemCode,
        componentName: part.componentName,
        vendor: part.vendor || selectedVendor,
        baselineCost: baselineCalc.totalCost,
        actualCost: runningCalc.totalCost,
        unitProfitLoss,
        saleUnit: periodSaleUnits,
        totalPnL,
        salesRecords: matchedSales,
        baselineCalc,
        runningCalc
      };
    });
  }, [vendorProducts, salesData, selectedVendor, periodFrom, periodTo]);

  const totalPeriodVolume = misRows.reduce((acc, r) => acc + r.saleUnit, 0);
  const netRealizedPnL = Number(misRows.reduce((acc, r) => acc + r.totalPnL, 0).toFixed(2));

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Title Header */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex justify-between items-center">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <BarChart3 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">4. Sales Realization & Costing MIS Report</h1>
            <p className="text-[11px] text-slate-300">Period & Vendor Synced Variance Matrix</p>
          </div>
        </div>
      </div>

      {/* Exact Format Table */}
      <div className="bg-white border border-slate-300 rounded-2xl shadow-sm overflow-hidden p-4 space-y-3">
        <div className="overflow-x-auto border border-slate-400 rounded-xl">
          <table className="min-w-full text-xs text-left border-collapse">
            <tbody>
              
              {/* Row 1: Select | Vendor | Period | FROM | TO */}
              <tr className="border-b border-slate-300 bg-slate-50 font-bold text-slate-800">
                <td colSpan="2" className="p-2.5 border-r border-slate-300 text-sm">
                  Select
                </td>
                <td className="p-2.5 border-r border-slate-300 text-center uppercase tracking-wide">
                  Vendor
                </td>
                <td className="p-2.5 border-r border-slate-300 text-center uppercase">
                  Period
                </td>
                <td className="p-2.5 border-r border-slate-300 text-center uppercase bg-amber-50/70 text-amber-950">
                  <div className="flex items-center justify-center gap-1.5">
                    <span>FROM</span>
                    <input 
                      type="date" 
                      value={periodFrom} 
                      onChange={e => setPeriodFrom(e.target.value)} 
                      className="bg-white border border-amber-300 rounded p-1 font-mono text-xs font-bold text-amber-900" 
                    />
                  </div>
                </td>
                <td colSpan="2" className="p-2.5 text-center uppercase bg-amber-50/70 text-amber-950">
                  <div className="flex items-center justify-center gap-1.5">
                    <span>TO</span>
                    <input 
                      type="date" 
                      value={periodTo} 
                      onChange={e => setPeriodTo(e.target.value)} 
                      className="bg-white border border-amber-300 rounded p-1 font-mono text-xs font-bold text-amber-900" 
                    />
                  </div>
                </td>
              </tr>

              {/* Row 2: Select Dropdown | Vendor Selector | Data from Sale Header */}
              <tr className="border-b border-slate-300 bg-slate-100 font-bold text-slate-900">
                <td colSpan="2" className="p-2.5 border-r border-slate-300">
                  Select
                </td>
                <td className="p-2.5 border-r border-slate-300 text-center">
                  <select
                    value={selectedVendor}
                    onChange={e => setSelectedVendor(e.target.value)}
                    className="bg-white border-2 border-blue-600 text-blue-950 font-bold px-2 py-1 rounded text-xs"
                  >
                    <option value="Haier">Haier</option>
                    <option value="LG">LG</option>
                    <option value="Whirlpool">Whirlpool</option>
                    <option value="ALL">All</option>
                  </select>
                </td>
                <td className="p-2.5 border-r border-slate-300 bg-slate-200/50"></td>
                <td colSpan="2" className="p-2.5 border-r border-slate-300 text-center bg-blue-100/70 text-blue-950 uppercase tracking-wider">
                  Data from Sale
                </td>
                <td className="p-2.5 bg-slate-200/50"></td>
              </tr>

              {/* Row 3: Column Headers */}
              <tr className="bg-slate-800 text-white font-bold border-b border-slate-700 text-[11px]">
                <th colSpan="2" className="p-3 border-r border-slate-700 min-w-[320px]">
                  Item Code / Component
                </th>
                <th className="p-3 border-r border-slate-700 text-center min-w-[100px]">
                  Vendor
                </th>
                <th className="p-3 border-r border-slate-700 text-right min-w-[120px]">
                  Profit / Loss (Δ)
                </th>
                <th className="p-3 border-r border-slate-700 text-right min-w-[120px] bg-blue-950 text-blue-200">
                  Sale Unit
                </th>
                <th className="p-3 text-right min-w-[140px] bg-slate-900 text-amber-300">
                  Total P & L
                </th>
                <th className="p-3 text-center w-12">View</th>
              </tr>

              {/* Rows: Component Items */}
              {misRows.map((row) => (
                <tr 
                  key={row.itemCode} 
                  onClick={() => setDrilldownItem(row)}
                  className="border-b border-slate-200 hover:bg-blue-50/40 cursor-pointer font-medium"
                >
                  <td colSpan="2" className="p-3 border-r border-slate-300">
                    <span className="font-mono font-bold text-blue-700 block">{row.itemCode}</span>
                    <span className="text-[11px] text-slate-900 font-semibold">{row.componentName}</span>
                  </td>

                  <td className="p-3 border-r border-slate-300 text-center font-semibold text-slate-700">
                    {row.vendor}
                  </td>

                  <td className="p-3 border-r border-slate-300 text-right font-mono font-bold">
                    <span className={row.unitProfitLoss >= 0 ? 'text-emerald-700' : 'text-rose-600'}>
                      {row.unitProfitLoss >= 0 ? `₹ +${row.unitProfitLoss.toFixed(2)}` : `₹ -${Math.abs(row.unitProfitLoss).toFixed(2)}`}
                    </span>
                  </td>

                  <td className="p-3 border-r border-slate-300 text-right font-mono font-bold text-blue-950 bg-blue-50/30">
                    {row.saleUnit.toLocaleString()}
                  </td>

                  <td className="p-3 text-right font-mono font-black text-xs">
                    <span className={row.totalPnL >= 0 ? 'text-emerald-700' : 'text-rose-600'}>
                      {row.totalPnL >= 0 ? `₹ ${row.totalPnL.toFixed(2)}` : `₹ -${Math.abs(row.totalPnL).toFixed(2)}`}
                    </span>
                  </td>

                  <td className="p-3 text-center">
                    <button className="p-1 text-blue-600 hover:text-blue-900 hover:bg-blue-100 rounded-lg">
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}

              {/* Total Row */}
              <tr className="bg-slate-900 text-white font-black text-xs border-t-2 border-slate-700">
                <td colSpan="2" className="p-3 border-r border-slate-700 uppercase tracking-wider text-amber-400 font-bold">
                  Total
                </td>
                <td className="p-3 border-r border-slate-700 text-center text-slate-400">-</td>
                <td className="p-3 border-r border-slate-700 text-right text-slate-400">-</td>
                <td className="p-3 border-r border-slate-700 text-right font-mono text-blue-300">
                  {totalPeriodVolume.toLocaleString()}
                </td>
                <td className="p-3 text-right font-mono text-sm">
                  <span className={netRealizedPnL >= 0 ? 'text-emerald-400 font-black' : 'text-rose-400 font-black'}>
                    ₹ {netRealizedPnL.toFixed(2)}
                  </span>
                </td>
                <td className="p-3 text-center text-slate-500">-</td>
              </tr>

            </tbody>
          </table>
        </div>
      </div>

      {/* Drilldown Modal */}
      {drilldownItem && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl shadow-2xl max-w-3xl w-full p-5 space-y-4 border border-slate-300">
            <div className="flex justify-between items-start border-b pb-3">
              <div>
                <span className="px-2.5 py-0.5 bg-blue-600 text-white font-bold rounded-md font-mono text-[11px]">
                  {drilldownItem.itemCode}
                </span>
                <h3 className="font-bold text-sm text-slate-900 mt-1">{drilldownItem.componentName}</h3>
                <p className="text-slate-500 text-[11px]">Vendor: <span className="font-bold text-slate-800">{drilldownItem.vendor}</span> | Period: <span className="font-mono font-bold text-amber-800">{periodFrom} to {periodTo}</span></p>
              </div>
              <button onClick={() => setDrilldownItem(null)} className="p-1.5 text-slate-400 hover:text-slate-700 cursor-pointer">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-3 gap-3 text-center">
              <div className="bg-slate-100 p-3 rounded-xl border">
                <span className="text-[10px] text-slate-500 uppercase font-bold block">Profit / Loss (Δ)</span>
                <span className={`text-base font-black font-mono ${drilldownItem.unitProfitLoss >= 0 ? 'text-emerald-700' : 'text-rose-600'}`}>
                  {drilldownItem.unitProfitLoss >= 0 ? `+₹${drilldownItem.unitProfitLoss.toFixed(2)}` : `-₹${Math.abs(drilldownItem.unitProfitLoss).toFixed(2)}`}
                </span>
              </div>
              <div className="bg-slate-100 p-3 rounded-xl border">
                <span className="text-[10px] text-slate-500 uppercase font-bold block">Sale Unit</span>
                <span className="text-base font-black font-mono text-slate-900">{drilldownItem.saleUnit.toLocaleString()} pcs</span>
              </div>
              <div className={`p-3 rounded-xl border ${drilldownItem.totalPnL >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
                <span className="text-[10px] font-bold uppercase block text-slate-700">Total P & L</span>
                <span className={`text-base font-black font-mono ${drilldownItem.totalPnL >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {drilldownItem.totalPnL >= 0 ? `₹ +${drilldownItem.totalPnL.toFixed(2)}` : `₹ -${Math.abs(drilldownItem.totalPnL).toFixed(2)}`}
                </span>
              </div>
            </div>

            <div className="flex justify-end pt-2 border-t">
              <button onClick={() => setDrilldownItem(null)} className="px-4 py-1.5 bg-slate-900 text-white font-bold rounded-xl cursor-pointer">
                Close
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
MIS_EOF

echo "==> Application updated successfully."
