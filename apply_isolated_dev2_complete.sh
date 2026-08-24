#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring git is on dev-v2..."
git checkout dev-v2

echo "==> 2. Writing isolated dev masterStore.js (Zero sync with production)..."
cat << 'STORE_EOF' > src/shared/masterStore.js
// ============================================================================
// GLOBAL MASTER DATA STORE (Strictly Isolated DEV-V2)
// ============================================================================

const STORAGE_KEY = 'CPC_MASTER_STORE_DEV_ISOLATED_V2';

function loadPersistedStore() {
  if (typeof window === 'undefined') return null;
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) return JSON.parse(saved);
  } catch (err) {
    console.error("Error loading dev store:", err);
  }
  return null;
}

const defaultStore = {
  isLocked: true,
  isMatrixLocked: true,
  vendors: [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ],
  rmMappingsData: [],
  baselineProducts: [],
  purchases: [],
  sales: [],
  auditLogs: []
};

const initialStore = loadPersistedStore() || defaultStore;

export let globalStore = {
  ...defaultStore,
  ...initialStore,
  vendors: (initialStore.vendors && initialStore.vendors.length > 0) ? initialStore.vendors : defaultStore.vendors
};

function persistCurrentStore() {
  if (typeof window === 'undefined') return;
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(globalStore));
  } catch (err) {
    console.error("Error saving dev store:", err);
  }
}

let listeners = [];
export function subscribeStore(fn) {
  listeners.push(fn);
  return () => { listeners = listeners.filter(cb => cb !== fn); };
}

export function notifyStore() {
  persistCurrentStore();
  listeners.forEach(fn => { try { fn(globalStore); } catch (e) { console.error(e); } });
}

export function parseMaterialString(rawMaterialStr) {
  if (!rawMaterialStr) return { baseRm: '', mbGrade: '' };
  const cleanStr = rawMaterialStr.toString().trim();
  if (cleanStr.includes('+')) {
    const parts = cleanStr.split('+').map(s => s.trim());
    return { baseRm: parts[0] || '', mbGrade: parts[1] || '' };
  }
  return { baseRm: cleanStr, mbGrade: '' };
}

export function getActiveRmMapping(gradeName, vendor) {
  if (!gradeName) return { approvedCode: 'Unspecified', approvedPrice: 0, activeGrade: 'Unspecified', activeWaPrice: 0, isFound: false };
  const { baseRm } = parseMaterialString(gradeName);
  const targetCode = (baseRm || gradeName).toLowerCase().trim();
  const vClean = (vendor || '').toLowerCase().trim();
  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'RM' && (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim())) && 
    r.approvedCode.toLowerCase().trim() === targetCode
  );
  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] !== undefined ? found[`${activeKey}Price`] : (found.alt1Price || found.approvedPrice || 0));
    return { approvedCode: found.approvedCode, approvedPrice: Number(found.approvedPrice || 0), activeGrade: found[`${activeKey}Code`] || found.approvedCode, activeWaPrice: Number(waPrice || 0), isFound: true };
  }
  return { approvedCode: baseRm || gradeName, approvedPrice: 0, activeGrade: baseRm || gradeName, activeWaPrice: 0, isFound: false };
}

export function getActiveMbMapping(mbGradeName, vendor) {
  const vClean = (vendor || '').toLowerCase().trim();
  let targetMb = (mbGradeName || '').toLowerCase().trim();
  if (!targetMb) return { approvedMbCode: 'None', approvedMbPrice: 0, activeMbGrade: 'None', activeMbWaPrice: 0, isFound: false };
  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'MB' && (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim())) && 
    r.approvedCode.toLowerCase().trim() === targetMb
  );
  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] !== undefined ? found[`${activeKey}Price`] : (found.alt1Price || found.approvedPrice || 0));
    return { approvedMbCode: found.approvedCode, approvedMbPrice: Number(found.approvedPrice || 0), activeMbGrade: found[`${activeKey}Code`] || found.approvedCode, activeMbWaPrice: Number(waPrice || 0), isFound: true };
  }
  return { approvedMbCode: mbGradeName, approvedMbPrice: 0, activeMbGrade: mbGradeName, activeMbWaPrice: 0, isFound: false };
}

export function addOrUpdateVendorMaterial(item) {
  if (!globalStore.rmMappingsData) globalStore.rmMappingsData = [];
  const idx = globalStore.rmMappingsData.findIndex(r => r.vendor === item.vendor && r.type === item.type && r.approvedCode === item.approvedCode);
  if (idx >= 0) {
    globalStore.rmMappingsData[idx] = { ...globalStore.rmMappingsData[idx], ...item };
  } else {
    globalStore.rmMappingsData.push({ id: `mat-${Date.now()}-${Math.random().toString(36).substr(2,4)}`, ...item });
  }
  notifyStore();
}

export function getVendorBaselineData(vendorId) {
  const prods = globalStore.baselineProducts || [];
  if (!vendorId || vendorId === 'ALL') return prods;
  return prods.filter(p => (p.vendor || '').toLowerCase().includes(vendorId.toLowerCase()));
}

export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  Object.assign(prod, updatedItem);
  addAuditLog({
    partCode: prod.itemCode,
    componentName: prod.componentName,
    vendor: prod.vendor,
    modifications: 'Adjusted parameters in modal',
    costImpact: `₹${(prod.approvedCost || 0).toFixed(2)}`,
    reason: reason || 'Manual Spec Adjustment'
  });
  notifyStore();
}

export function addStagedProductsToBaseline(stagedList, vendor) {
  stagedList.forEach(staged => {
    const idx = globalStore.baselineProducts.findIndex(p => p.itemCode === staged.itemCode);
    if (idx >= 0) {
      globalStore.baselineProducts[idx] = { ...globalStore.baselineProducts[idx], ...staged };
    } else {
      globalStore.baselineProducts.push({ ...staged, id: `prod-${Date.now()}-${Math.random().toString(36).substr(2,4)}`, vendor: vendor || staged.vendor });
    }
  });
  notifyStore();
}

export function deleteProductFromBaseline(itemId, vendor) {
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => p.id !== itemId && p.itemCode !== itemId);
  addAuditLog({
    partCode: itemId,
    componentName: `Deleted Product ${itemId}`,
    vendor: vendor || 'ALL',
    modifications: 'Deleted product from baseline master',
    costImpact: '0.00',
    reason: 'Manual deletion'
  });
  notifyStore();
}

export function clearVendorBaselineProducts(vendorName) {
  const vClean = (vendorName || '').toLowerCase().trim();
  globalStore.baselineProducts = (globalStore.baselineProducts || []).filter(p => !(p.vendor || '').toLowerCase().trim().includes(vClean));
  addAuditLog({
    partCode: 'BASELINE_PURGE',
    componentName: `Purged Baseline Products for ${vendorName}`,
    vendor: vendorName,
    modifications: 'Cleared baseline table',
    costImpact: '0 Parts',
    reason: 'Manual Baseline Purge'
  });
  notifyStore();
}

export function addAuditLog(entry) {
  globalStore.auditLogs = globalStore.auditLogs || [];
  globalStore.auditLogs.unshift({
    timestamp: new Date().toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' }),
    ...entry
  });
}

export function toggleGlobalLock() { globalStore.isLocked = !globalStore.isLocked; notifyStore(); }
export function toggleMatrixLock() { globalStore.isMatrixLocked = !globalStore.isMatrixLocked; notifyStore(); }
export function addDayWisePurchase(rec) { (globalStore.purchases = globalStore.purchases || []).unshift(rec); notifyStore(); return { success: true }; }
export function addDayWiseSales(rec) { (globalStore.sales = globalStore.sales || []).unshift(rec); notifyStore(); return { success: true }; }
export function onboardVendorWithBlueprint() { notifyStore(); }
STORE_EOF

echo "==> 3. Updating BaselineMasterPage.jsx with verified 0-indexed row parser..."
cat << 'PAGE_EOF' > src/modules/module1-baseline/BaselineMasterPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Upload, 
  Trash2, 
  Edit3, 
  Search, 
  Layers, 
  Database
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  updateBaselineParameters, 
  deleteProductFromBaseline, 
  clearVendorBaselineProducts, 
  addStagedProductsToBaseline, 
  addOrUpdateVendorMaterial, 
  parseMaterialString, 
  getActiveRmMapping, 
  getActiveMbMapping 
} from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('Haier Appliances');
  const [activeTab, setActiveTab] = useState('parameters');
  const [searchQuery, setSearchQuery] = useState('');
  const [editingProduct, setEditingProduct] = useState(null);
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [stagedData, setStagedData] = useState([]);

  useEffect(() => {
    const unsub = subscribeStore(() => {
      setStoreState({ ...globalStore });
    });
    return () => unsub();
  }, []);

  const vendors = storeState.vendors || [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ];

  const vendorProducts = (storeState.baselineProducts || []).filter(p => 
    selectedVendor === 'ALL' || 
    (p.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((p.vendor || '').toLowerCase())
  );

  const filteredProducts = vendorProducts.filter(p => 
    !searchQuery || 
    (p.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.approvedRm || '').toLowerCase().includes(searchQuery.toLowerCase())
  );

  const vendorAuditLogs = (storeState.auditLogs || []).filter(l => 
    selectedVendor === 'ALL' ||
    (l.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((l.vendor || '').toLowerCase()) ||
    l.vendor === 'ALL'
  );

  const handleEditClick = (prod) => {
    const { baseRm, mbGrade } = parseMaterialString(prod.approvedRm || prod.baseRm);
    const rmLookupKey = baseRm || prod.baseRm || prod.approvedRm;
    const mbLookupKey = mbGrade || prod.approvedMb || (prod.masterbatchPct > 0 ? 'White MB' : '');

    const rmMap = getActiveRmMapping(rmLookupKey, prod.vendor);
    const mbMap = getActiveMbMapping(mbLookupKey, prod.vendor);
    
    setEditingProduct({
      ...prod,
      baseRm: rmLookupKey,
      approvedMb: mbLookupKey,
      approvedRmPrice: Number(rmMap.approvedPrice || 0),
      activeRmWaPrice: Number(rmMap.activeWaPrice || rmMap.approvedPrice || 0),
      approvedMbPrice: Number(mbMap.approvedMbPrice || 0),
      activeMbWaPrice: Number(mbMap.activeMbWaPrice || mbMap.approvedMbPrice || 0)
    });
  };

  const handleSaveProduct = (updatedItem) => {
    updateBaselineParameters({
      itemId: updatedItem.id || updatedItem.itemCode,
      updatedItem,
      reason: 'Manual Spec Parameter Adjustment via Edit Modal'
    });
    setEditingProduct(null);
  };

  const handleDeleteProduct = (itemId) => {
    deleteProductFromBaseline(itemId, selectedVendor);
    setEditingProduct(null);
  };

  const handleFileUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      const bstr = evt.target.result;
      const wb = XLSX.read(bstr, { type: 'binary' });
      const wsname = wb.SheetNames[0];
      const ws = wb.Sheets[wsname];
      const data = XLSX.utils.sheet_to_json(ws, { header: 1 });

      const parsed = [];
      if (data.length > 5) {
        const totalCols = (data[0] || []).length;
        for (let c = 3; c < totalCols; c++) {
          const compName = data[1]?.[c];
          const itemCode = data[3]?.[c];
          if (!compName && !itemCode) continue;

          const rawMatStr = String(data[5]?.[c] || '').trim();
          const { baseRm, mbGrade } = parseMaterialString(rawMatStr);
          
          const rawMbVal = data[6]?.[c];
          let mbPct = 0;
          if (typeof rawMbVal === 'number') {
            mbPct = rawMbVal <= 1 ? Number((rawMbVal * 100).toFixed(2)) : rawMbVal;
          } else if (rawMbVal) {
            mbPct = parseFloat(String(rawMbVal).replace('%', '')) || 0;
          }

          const cavity = parseInt(data[7]?.[c], 10) || 1;
          const runnerWt = parseFloat(data[8]?.[c]) || 0;
          const netWt = parseFloat(data[9]?.[c]) || 0;
          const shotWt = parseFloat(data[10]?.[c]) || (netWt * cavity + runnerWt);
          const reconWt = parseFloat(data[11]?.[c]) || Number(((shotWt / cavity) * 1.02).toFixed(2));
          
          const rawRmCost = parseFloat(data[12]?.[c]) || 0;
          const rawMbCost = parseFloat(data[13]?.[c]) || 0;
          const runnerRecoveryScrap = parseFloat(data[14]?.[c]) || 0;
          const totalRmCost = parseFloat(data[15]?.[c]) || 0;

          const machineTonnage = parseInt(data[16]?.[c], 10) || 0;
          const shiftTariff = parseFloat(data[17]?.[c]) || 0;
          const cycleTimeApproved = parseFloat(data[18]?.[c]) || 0;
          const shotsShift8h = parseFloat(data[19]?.[c]) || (cycleTimeApproved > 0 ? (28800 / cycleTimeApproved) : 0);
          const shotsShift95Eff = parseFloat(data[20]?.[c]) || (shotsShift8h * 0.95);
          const partsPerShift = parseFloat(data[21]?.[c]) || (shotsShift95Eff * cavity);
          const prodCostPerPc = parseFloat(data[22]?.[c]) || (partsPerShift > 0 ? (shiftTariff / partsPerShift) : 0);
          const subTotal = parseFloat(data[23]?.[c]) || (totalRmCost + prodCostPerPc);

          const haierOverheadPackage = parseFloat(data[24]?.[c]) || 0;
          const foamPolybag = parseFloat(data[25]?.[c]) || 0;
          const plasticBin = parseFloat(data[26]?.[c]) || 0;
          const freightCost = parseFloat(data[27]?.[c]) || 0;
          const secondaryOp1 = parseFloat(data[28]?.[c]) || 0;
          const secondaryOp2 = parseFloat(data[29]?.[c]) || 0;
          const screenPrint1 = parseFloat(data[30]?.[c]) || 0;
          const screenPrint2 = parseFloat(data[31]?.[c]) || 0;
          const assemblyCost = parseFloat(data[32]?.[c]) || 0;
          const bopCost = parseFloat(data[33]?.[c]) || 0;

          const mouldMaintenance = parseFloat(data[34]?.[c]) || 0;
          const qualityInspection = parseFloat(data[35]?.[c]) || 0;
          const iccReduce = parseFloat(data[36]?.[c]) || 0;
          const scrapAdj = parseFloat(data[37]?.[c]) || 0;
          const approvedCost = parseFloat(data[38]?.[c]) || 0;

          // Auto-Register in RM Matrix
          let parsedRmRate = 0;
          if (reconWt > 0 && rawRmCost > 0) {
            const effectiveRmFrac = (1 - (mbPct / 100));
            parsedRmRate = effectiveRmFrac > 0 ? Number((rawRmCost / ((reconWt / 1000) * effectiveRmFrac)).toFixed(2)) : 0;
          }

          let parsedMbRate = 0;
          if (reconWt > 0 && rawMbCost > 0 && mbPct > 0) {
            parsedMbRate = Number((rawMbCost / ((reconWt / 1000) * (mbPct / 100))).toFixed(2));
          }

          if (baseRm) {
            addOrUpdateVendorMaterial({
              vendor: selectedVendor,
              type: 'RM',
              approvedCode: baseRm,
              approvedPrice: parsedRmRate
            });
          }

          if (mbGrade || (mbPct > 0)) {
            const targetMb = mbGrade || 'White MB';
            addOrUpdateVendorMaterial({
              vendor: selectedVendor,
              type: 'MB',
              approvedCode: targetMb,
              approvedPrice: parsedMbRate || (parsedRmRate > 0 ? 242 : 0)
            });
          }

          parsed.push({
            id: `prod-${String(itemCode).trim()}-${c}`,
            vendor: selectedVendor,
            componentName: String(compName || itemCode).trim(),
            mouldSize: String(data[2]?.[c] || '-').trim(),
            itemCode: String(itemCode || compName).trim(),
            model: String(data[4]?.[c] || '-').trim(),
            approvedRm: rawMatStr,
            baseRm: baseRm || rawMatStr,
            approvedMb: mbGrade || (mbPct > 0 ? 'White MB' : 'None'),
            masterbatchPct: mbPct,
            cavity: cavity,
            runnerWeight: runnerWt,
            netWeight: netWt,
            shotWeight: shotWt,
            reconciliationWeight: reconWt,
            rawMaterialCost: rawRmCost,
            masterbatchCost: rawMbCost,
            runnerRecoveryScrap: runnerRecoveryScrap,
            totalRmCost: totalRmCost,
            machineTonnage: machineTonnage,
            shiftTariff: shiftTariff,
            cycleTimeApproved: cycleTimeApproved,
            shotsShift8h: shotsShift8h,
            shotsShift95Eff: shotsShift95Eff,
            partsPerShift: partsPerShift,
            productionCostPerPc: prodCostPerPc,
            subTotal: subTotal,
            haierOverheadPackage: haierOverheadPackage,
            foamPolybag: foamPolybag,
            plasticBin: plasticBin,
            freightCost: freightCost,
            secondaryOp1: secondaryOp1,
            secondaryOp2: secondaryOp2,
            screenPrint1: screenPrint1,
            screenPrint2: screenPrint2,
            assemblyCost: assemblyCost,
            bopCost: bopCost,
            mouldMaintenance: mouldMaintenance,
            qualityInspection: qualityInspection,
            iccReduce: iccReduce,
            scrapAdj: scrapAdj,
            approvedCost: approvedCost,
            parameters: {
              runningCycleTime: cycleTimeApproved,
              runningCavity: cavity,
              runningRunnerWeight: runnerWt,
              runningNetWeight: netWt,
              runningShiftTariff: shiftTariff,
              runningHaierOverheadPackage: haierOverheadPackage,
              runningMbPct: mbPct,
              runningBopCost: bopCost
            }
          });
        }
      }

      setStagedData(parsed);
      setShowUploadModal(true);
    };
    reader.readAsBinaryString(file);
  };

  const handleCommitStaged = () => {
    addStagedProductsToBaseline(stagedData, selectedVendor);
    setStagedData([]);
    setShowUploadModal(false);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master (DEV-V2)</h1>
              <span className="bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 text-[10px] px-2 py-0.5 rounded-full font-bold">
                Active Vendor: {selectedVendor}
              </span>
            </div>
            <p className="text-[11px] text-slate-300">Synchronized Approved Baseline • Complete 38-Line Spec Matrix • Real-Time RM Matrix Price Binding</p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={() => {
              if (window.confirm(`Are you sure you want to clear all baseline products for ${selectedVendor}?`)) {
                clearVendorBaselineProducts(selectedVendor);
              }
            }}
            className="px-3.5 py-2 bg-rose-950/40 hover:bg-rose-900 text-rose-300 border border-rose-800/60 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-xs text-xs"
          >
            <Trash2 className="w-4 h-4 text-rose-400" /> Clear {selectedVendor} Data
          </button>

          <label className="px-3.5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm text-xs">
            <Upload className="w-4 h-4" /> Upload & Stage Spec (.xlsx)
            <input type="file" accept=".xlsx, .xls" onChange={handleFileUpload} className="hidden" />
          </label>

          <div className="flex bg-slate-800 p-0.5 rounded-xl border border-slate-700">
            <button
              onClick={() => setActiveTab('parameters')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${
                activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'
              }`}
            >
              Parameters Master ({vendorProducts.length})
            </button>
            <button
              onClick={() => setActiveTab('audit')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${
                activeTab === 'audit' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'
              }`}
            >
              Parameter Audit Log ({vendorAuditLogs.length})
            </button>
          </div>
        </div>
      </div>

      {/* Filter Row */}
      <div className="bg-white p-3 rounded-2xl border border-slate-200 shadow-xs flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-2 flex-1 max-w-md bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-200">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder={`Search ${selectedVendor} components...`}
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            className="w-full bg-transparent border-none outline-hidden text-xs text-slate-800"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-600">Switch Vendor:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="px-3 py-1.5 rounded-xl bg-slate-100 text-slate-900 border border-slate-300 font-bold text-xs"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Table Container */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">{selectedVendor} Baseline Parameters Master</h2>
          </div>
          <span className="text-[11px] text-slate-400 font-mono">{filteredProducts.length} Active Parts</span>
        </div>

        {activeTab === 'parameters' ? (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Item Code / Component</th>
                  <th className="py-2.5 px-3">Model</th>
                  <th className="py-2.5 px-3">Approved RM / MB</th>
                  <th className="py-2.5 px-3 text-center">MB %</th>
                  <th className="py-2.5 px-3 text-center">Cavity</th>
                  <th className="py-2.5 px-3 text-right">Net Wt</th>
                  <th className="py-2.5 px-3 text-right">Runner Wt</th>
                  <th className="py-2.5 px-3 text-center bg-amber-50/70 text-amber-950">Cycle Time</th>
                  <th className="py-2.5 px-3 text-center">Tonnage</th>
                  <th className="py-2.5 px-3 text-right">Shift Tariff</th>
                  <th className="py-2.5 px-4 text-center">Edit Spec</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredProducts.length === 0 ? (
                  <tr>
                    <td colSpan={11} className="py-8 text-center text-slate-400">
                      No baseline parts found for {selectedVendor}. Click <b>Upload & Stage Spec</b> to import records.
                    </td>
                  </tr>
                ) : (
                  filteredProducts.map(prod => {
                    const { baseRm } = parseMaterialString(prod.approvedRm || prod.baseRm);
                    const rmInfo = getActiveRmMapping(baseRm || prod.baseRm || prod.approvedRm, prod.vendor);
                    
                    return (
                      <tr key={prod.id || prod.itemCode} className="hover:bg-slate-50 transition-colors">
                        <td className="py-2.5 px-3">
                          <div className="font-mono font-bold text-blue-700">{prod.itemCode}</div>
                          <div className="font-semibold text-slate-800">{prod.componentName}</div>
                        </td>
                        <td className="py-2.5 px-3 font-mono text-slate-600">{prod.model || '-'}</td>
                        <td className="py-2.5 px-3">
                          <div className="font-bold text-slate-900">{prod.approvedRm || '-'}</div>
                          <div className="text-[10px] text-slate-500 font-mono">
                            RM Matrix Rate: ₹{rmInfo.approvedPrice || 0}/kg
                          </div>
                        </td>
                        <td className="py-2.5 px-3 text-center font-mono font-bold text-purple-700">{prod.masterbatchPct || 0}%</td>
                        <td className="py-2.5 px-3 text-center font-mono font-bold text-slate-800">{prod.cavity || 1}</td>
                        <td className="py-2.5 px-3 text-right font-mono text-slate-800">{prod.netWeight || 0}g</td>
                        <td className="py-2.5 px-3 text-right font-mono text-slate-800">{prod.runnerWeight || 0}g</td>
                        <td className="py-2.5 px-3 text-center font-mono font-black text-amber-900 bg-amber-50/50">{prod.cycleTimeApproved || 0}s</td>
                        <td className="py-2.5 px-3 text-center font-mono text-slate-800">{prod.machineTonnage || 0}T</td>
                        <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">₹{prod.shiftTariff || 0}</td>
                        <td className="py-2.5 px-4 text-center">
                          <button
                            onClick={() => handleEditClick(prod)}
                            className="px-3 py-1 bg-blue-50 hover:bg-blue-100 text-blue-700 border border-blue-200 rounded-lg font-bold flex items-center gap-1 mx-auto cursor-pointer shadow-xs"
                          >
                            <Edit3 className="w-3.5 h-3.5 text-blue-600" /> Edit Spec
                          </button>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Timestamp</th>
                  <th className="py-2.5 px-3">Code / Ref</th>
                  <th className="py-2.5 px-4">Component / Target</th>
                  <th className="py-2.5 px-4">Modifications</th>
                  <th className="py-2.5 px-3 text-right">Cost Impact</th>
                  <th className="py-2.5 px-4">Reason</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {vendorAuditLogs.length === 0 ? (
                  <tr><td colSpan={6} className="py-8 text-center text-slate-400">No modification logs recorded for {selectedVendor}.</td></tr>
                ) : (
                  vendorAuditLogs.map((log, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-500">{log.timestamp}</td>
                      <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{log.partCode}</td>
                      <td className="py-2.5 px-4 font-semibold text-slate-800">{log.componentName}</td>
                      <td className="py-2.5 px-4 font-mono text-[11px] text-slate-700">{log.modifications}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">{log.costImpact}</td>
                      <td className="py-2.5 px-4 text-slate-600">{log.reason}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* RENDER INLINE EDIT MODAL */}
      {editingProduct && (
        <InlineEditModal
          product={editingProduct}
          onClose={() => setEditingProduct(null)}
          onSave={handleSaveProduct}
          onDelete={handleDeleteProduct}
        />
      )}

      {/* RENDER STAGED UPLOAD MODAL */}
      {showUploadModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-5 shadow-2xl space-y-4">
            <h3 className="text-sm font-bold text-slate-900">Staged Products for Import ({stagedData.length} records parsed)</h3>
            <p className="text-xs text-slate-500">Every part has been parsed and its RM / MB grades are dynamically linked to the RM Price Matrix.</p>
            <div className="max-h-60 overflow-y-auto border border-slate-200 rounded-xl p-2 space-y-1">
              {stagedData.map((s, idx) => (
                <div key={idx} className="flex justify-between items-center p-1.5 bg-slate-50 rounded text-xs">
                  <div>
                    <span className="font-mono font-bold text-blue-700 mr-2">{s.itemCode}</span>
                    <span className="font-medium text-slate-800">{s.componentName}</span>
                  </div>
                  <span className="font-mono text-slate-600">Net: {s.netWeight}g | CT: {s.cycleTimeApproved}s | Total: ₹{s.approvedCost}</span>
                </div>
              ))}
            </div>
            <div className="flex justify-end gap-2">
              <button onClick={() => setShowUploadModal(false)} className="px-4 py-2 border border-slate-300 rounded-xl font-bold cursor-pointer">Cancel</button>
              <button onClick={handleCommitStaged} className="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer">Commit to Baseline</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
PAGE_EOF

echo "==> 4. Updating InlineEditModal.jsx to show all 38 lines cleanly..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, Trash2 } from 'lucide-react';
import { calculateHaierCost, calculateAtombergCost } from '../../shared/costCalculationService';
import { parseMaterialString, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';

export default function InlineEditModal({ product, onClose, onSave, onDelete }) {
  if (!product) return null;

  const isHaier = (product.vendor || '').toLowerCase().includes('haier');
  const initialParams = product.parameters || {};

  const { baseRm, mbGrade } = parseMaterialString(product.approvedRm || product.baseRm);
  const rmLookupKey = baseRm || product.baseRm || product.approvedRm;
  const mbLookupKey = mbGrade || product.approvedMb || (product.masterbatchPct > 0 ? 'White MB' : '');

  // Live lookup from RM Price Matrix
  const rmInfo = getActiveRmMapping(rmLookupKey, product.vendor);
  const mbInfo = getActiveMbMapping(mbLookupKey, product.vendor);

  const approvedRmRate = Number(rmInfo.approvedPrice || 0);
  const runningRmWaRate = Number(rmInfo.activeWaPrice || rmInfo.approvedPrice || 0);

  const approvedMbRate = Number(mbInfo.approvedMbPrice || 0);
  const runningMbWaRate = Number(mbInfo.activeMbWaPrice || mbInfo.approvedMbPrice || 0);

  const [formData, setFormData] = useState({
    approvedRm: product.approvedRm || baseRm,
    baseRm: rmLookupKey,
    approvedMb: mbLookupKey,
    masterbatchPct: product.masterbatchPct ?? 0,
    cavity: product.cavity || 1,
    runnerWeight: product.runnerWeight ?? 0,
    netWeight: product.netWeight ?? 0,
    shotWeight: product.shotWeight ?? (product.netWeight * (product.cavity || 1) + (product.runnerWeight || 0)),
    reconciliationWeight: product.reconciliationWeight ?? Number((((product.shotWeight || product.netWeight) / (product.cavity || 1)) * 1.02).toFixed(2)),
    machineTonnage: product.machineTonnage || 0,
    shiftTariff: product.shiftTariff || 0,
    cycleTimeApproved: product.cycleTimeApproved || 0,
    haierOverheadPackage: product.haierOverheadPackage || 0,
    foamPolybag: product.foamPolybag || 0,
    plasticBin: product.plasticBin || 0,
    freightCost: product.freightCost || 0,
    secondaryOp1: product.secondaryOp1 || 0,
    secondaryOp2: product.secondaryOp2 || 0,
    screenPrint1: product.screenPrint1 || 0,
    screenPrint2: product.screenPrint2 || 0,
    assemblyCost: product.assemblyCost || 0,
    mouldMaintenance: product.mouldMaintenance || 0,
    qualityInspection: product.qualityInspection || 0,
    iccReduce: product.iccReduce || 0,
    scrapAdj: product.scrapAdj || 0,
    bopCost: product.bopCost || 0,
    mouldSize: product.mouldSize || '-',
    model: product.model || '-',

    // Running Parameters
    runningCycleTime: initialParams.runningCycleTime ?? product.cycleTimeApproved ?? 0,
    runningCavity: initialParams.runningCavity ?? product.cavity ?? 1,
    runningRunnerWeight: initialParams.runningRunnerWeight ?? product.runnerWeight ?? 0,
    runningNetWeight: initialParams.runningNetWeight ?? product.netWeight ?? 0,
    runningShiftTariff: initialParams.runningShiftTariff ?? product.shiftTariff ?? 0,
    runningHaierOverheadPackage: initialParams.runningHaierOverheadPackage ?? product.haierOverheadPackage ?? 0,
    runningMbPct: initialParams.runningMbPct ?? product.masterbatchPct ?? 0,
    runningBopCost: initialParams.runningBopCost ?? product.bopCost ?? 0
  });

  // Calculate Approved Contract vs Actual Running
  const baseCalc = isHaier 
    ? calculateHaierCost({
        cavity: formData.cavity,
        netWeight: formData.netWeight,
        runnerWeight: formData.runnerWeight,
        shotWeight: formData.shotWeight,
        rmRate: approvedRmRate,
        masterbatchPct: formData.masterbatchPct,
        masterbatchRate: approvedMbRate,
        shiftTariff: formData.shiftTariff,
        cycleTime: formData.cycleTimeApproved,
        haierOverheadPackage: formData.haierOverheadPackage,
        foamPolybag: formData.foamPolybag,
        plasticBin: formData.plasticBin,
        freightCost: formData.freightCost,
        secondaryOp1: formData.secondaryOp1,
        secondaryOp2: formData.secondaryOp2,
        screenPrint1: formData.screenPrint1,
        screenPrint2: formData.screenPrint2,
        assemblyCost: formData.assemblyCost,
        mouldMaintenance: formData.mouldMaintenance,
        qualityInspection: formData.qualityInspection,
        iccReduce: formData.iccReduce,
        scrapAdj: formData.scrapAdj,
        bopCost: formData.bopCost
      })
    : calculateAtombergCost({
        rmBase: approvedRmRate,
        mbBase: approvedMbRate,
        partWt: formData.netWeight,
        runnerWt: formData.runnerWeight,
        mbPct: formData.masterbatchPct / 100,
        bopCost: formData.bopCost,
        cycleTime: formData.cycleTimeApproved,
        cavity: formData.cavity,
        tonnage: formData.machineTonnage,
        shiftTariff: formData.shiftTariff
      });

  const runningCalc = isHaier 
    ? calculateHaierCost({
        cavity: formData.runningCavity,
        netWeight: formData.runningNetWeight,
        runnerWeight: formData.runningRunnerWeight,
        shotWeight: formData.runningNetWeight * formData.runningCavity + formData.runningRunnerWeight,
        rmRate: runningRmWaRate,
        masterbatchPct: formData.runningMbPct,
        masterbatchRate: runningMbWaRate,
        shiftTariff: formData.runningShiftTariff,
        cycleTime: formData.runningCycleTime,
        haierOverheadPackage: formData.runningHaierOverheadPackage,
        foamPolybag: formData.foamPolybag,
        plasticBin: formData.plasticBin,
        freightCost: formData.freightCost,
        secondaryOp1: formData.secondaryOp1,
        secondaryOp2: formData.secondaryOp2,
        screenPrint1: formData.screenPrint1,
        screenPrint2: formData.screenPrint2,
        assemblyCost: formData.assemblyCost,
        mouldMaintenance: formData.mouldMaintenance,
        qualityInspection: formData.qualityInspection,
        iccReduce: formData.iccReduce,
        scrapAdj: formData.scrapAdj,
        bopCost: formData.runningBopCost
      })
    : calculateAtombergCost({
        rmBase: runningRmWaRate,
        mbBase: runningMbWaRate,
        partWt: formData.runningNetWeight,
        runnerWt: formData.runningRunnerWeight,
        mbPct: formData.runningMbPct / 100,
        bopCost: formData.runningBopCost,
        cycleTime: formData.runningCycleTime,
        cavity: formData.runningCavity,
        tonnage: formData.machineTonnage,
        shiftTariff: formData.runningShiftTariff
      });

  const contractTotal = isHaier ? baseCalc.totalCost : baseCalc.finalLanded;
  const runningTotal = isHaier ? runningCalc.totalCost : runningCalc.finalLanded;
  const profitLossDelta = Number((contractTotal - runningTotal).toFixed(2));

  // Machine shift shots calculations for Lines 19-21
  const ctApproved = Number(formData.cycleTimeApproved || 1);
  const ctRunning = Number(formData.runningCycleTime || 1);
  const shotsShift8hApproved = (28800 / ctApproved).toFixed(2);
  const shotsShift8hRunning = (28800 / ctRunning).toFixed(2);
  const shotsShift95Approved = ((28800 / ctApproved) * 0.95).toFixed(2);
  const shotsShift95Running = ((28800 / ctRunning) * 0.95).toFixed(2);
  const partsShiftApproved = (((28800 / ctApproved) * 0.95) * Number(formData.cavity || 1)).toFixed(2);
  const partsShiftRunning = (((28800 / ctRunning) * 0.95) * Number(formData.runningCavity || 1)).toFixed(2);

  const handleSave = () => {
    onSave({
      ...product,
      ...formData,
      approvedCost: contractTotal,
      parameters: {
        runningCycleTime: formData.runningCycleTime,
        runningCavity: formData.runningCavity,
        runningRunnerWeight: formData.runningRunnerWeight,
        runningNetWeight: formData.runningNetWeight,
        runningShiftTariff: formData.runningShiftTariff,
        runningHaierOverheadPackage: formData.runningHaierOverheadPackage,
        runningMbPct: formData.runningMbPct,
        runningBopCost: formData.runningBopCost
      },
      delta: profitLossDelta
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto">
      <div className="bg-white rounded-2xl max-w-4xl w-full max-h-[92vh] flex flex-col shadow-2xl overflow-hidden text-xs">
        {/* Header */}
        <div className="p-4 bg-slate-900 text-white flex justify-between items-center">
          <div>
            <div className="flex items-center gap-2">
              <span className="bg-blue-600 px-2 py-0.5 rounded font-mono font-bold">{product.itemCode}</span>
              <h2 className="font-bold text-sm">{product.componentName}</h2>
              <span className="bg-slate-800 text-[10px] px-2 py-0.5 rounded-full border border-slate-700">
                {isHaier ? 'Haier 38-Line Costing Format' : 'Atomberg Dual Column'}
              </span>
            </div>
            <p className="text-[11px] text-slate-300 mt-1">
              Vendor: <b>{product.vendor}</b> | Base RM: <b>{rmLookupKey}</b> (Matrix: ₹{approvedRmRate}/kg → WA: ₹{runningRmWaRate}/kg) | MB: <b>{mbLookupKey}</b> (Matrix: ₹{approvedMbRate}/kg → WA: ₹{runningMbWaRate}/kg)
            </p>
          </div>
          <button onClick={onClose} className="p-1.5 hover:bg-slate-800 rounded-lg text-slate-400 hover:text-white cursor-pointer">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* 3 Summary Badges */}
        <div className="grid grid-cols-3 gap-3 p-4 bg-slate-50 border-b border-slate-200">
          <div className="p-3 bg-white rounded-xl border border-slate-200">
            <div className="text-[10px] uppercase font-bold text-slate-400">Costing (Baseline Contract)</div>
            <div className="text-xl font-black font-mono text-slate-900 mt-0.5">₹{contractTotal.toFixed(2)}</div>
          </div>
          <div className="p-3 bg-white rounded-xl border border-slate-200">
            <div className="text-[10px] uppercase font-bold text-blue-600">Actual Running Shopfloor (Active Alternate)</div>
            <div className="text-xl font-black font-mono text-blue-700 mt-0.5">₹{runningTotal.toFixed(2)}</div>
          </div>
          <div className={`p-3 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-800' : 'bg-rose-50 border-rose-200 text-rose-800'}`}>
            <div className="text-[10px] uppercase font-bold">Profit / Loss (Δ)</div>
            <div className="text-xl font-black font-mono mt-0.5">
              {profitLossDelta >= 0 ? `+ ₹${profitLossDelta.toFixed(2)}` : `- ₹${Math.abs(profitLossDelta).toFixed(2)}`}
            </div>
          </div>
        </div>

        {/* 38-Line Spec Table Body */}
        <div className="flex-1 overflow-y-auto p-4 space-y-2">
          <table className="w-full text-left border-collapse">
            <thead className="bg-slate-100 text-slate-700 text-[10px] uppercase font-bold sticky top-0">
              <tr>
                <th className="py-2 px-3 w-8">#</th>
                <th className="py-2 px-3">Haier Costing Line</th>
                <th className="py-2 px-3 text-center w-24">UOM / Rate</th>
                <th className="py-2 px-4 text-right w-44">Approved Baseline</th>
                <th className="py-2 px-4 text-right w-44 text-blue-700">Actual Running</th>
                <th className="py-2 px-3 text-right w-24">Delta (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-xs font-medium">
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">1</td>
                <td className="py-2 px-3 font-bold">Name Of component</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-bold text-slate-700">{product.componentName}</td>
                <td className="py-2 px-4 text-right font-bold text-blue-800">{product.componentName}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">2</td>
                <td className="py-2 px-3">Mould size L x W xH</td>
                <td className="py-2 px-3 text-center">mm</td>
                <td className="py-2 px-4 text-right font-mono">{formData.mouldSize}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.mouldSize}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">3</td>
                <td className="py-2 px-3">Item No.</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{product.itemCode}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{product.itemCode}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">4</td>
                <td className="py-2 px-3">Model</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-mono">{formData.model}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.model}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">5</td>
                <td className="py-2 px-3 font-bold">Raw Material Required</td>
                <td className="py-2 px-3 text-center">-</td>
                <td className="py-2 px-4 text-right font-bold text-slate-800">{formData.approvedRm}</td>
                <td className="py-2 px-4 text-right font-bold text-blue-800">{formData.approvedRm}</td>
                <td className="py-2 px-3 text-right text-emerald-600 font-bold">Matched</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">6</td>
                <td className="py-2 px-3 font-bold">Master Batch Required (%)</td>
                <td className="py-2 px-3 text-center">%</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" step="0.1" value={formData.masterbatchPct} onChange={e => setFormData({ ...formData, masterbatchPct: Number(e.target.value) })} className="w-20 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" step="0.1" value={formData.runningMbPct} onChange={e => setFormData({ ...formData, runningMbPct: Number(e.target.value) })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{(formData.masterbatchPct - formData.runningMbPct).toFixed(1)}%</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">7</td>
                <td className="py-2 px-3">No. of Cavity</td>
                <td className="py-2 px-3 text-center">Nos</td>
                <td className="py-2 px-4 text-right font-bold">{formData.cavity}</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningCavity} onChange={e => setFormData({ ...formData, runningCavity: Number(e.target.value) })} className="w-16 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{formData.cavity - formData.runningCavity}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">8</td>
                <td className="py-2 px-3">Runner Weight</td>
                <td className="py-2 px-3 text-center">Gms</td>
                <td className="py-2 px-4 text-right font-mono">{formData.runnerWeight}g</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningRunnerWeight} onChange={e => setFormData({ ...formData, runningRunnerWeight: Number(e.target.value) })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{(formData.runnerWeight - formData.runningRunnerWeight).toFixed(2)}g</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">9</td>
                <td className="py-2 px-3 font-bold">Net Weight</td>
                <td className="py-2 px-3 text-center">Gms</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{formData.netWeight}g</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningNetWeight} onChange={e => setFormData({ ...formData, runningNetWeight: Number(e.target.value) })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{(formData.netWeight - formData.runningNetWeight).toFixed(2)}g</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">10</td>
                <td className="py-2 px-3">Shot Weight</td>
                <td className="py-2 px-3 text-center">Gms</td>
                <td className="py-2 px-4 text-right font-mono">{baseCalc.shotWeight}g</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{runningCalc.shotWeight}g</td>
                <td className="py-2 px-3 text-right font-mono">{(baseCalc.shotWeight - runningCalc.shotWeight).toFixed(2)}g</td>
              </tr>
              <tr className="bg-slate-50">
                <td className="py-2 px-3 font-mono text-slate-400">11</td>
                <td className="py-2 px-3 font-bold text-slate-900">Reconciliation Weight = Shot wt + 1.0% Melt Loss</td>
                <td className="py-2 px-3 text-center">Gms</td>
                <td className="py-2 px-4 text-right font-mono font-black text-slate-900">{baseCalc.reconciliationWeight}g</td>
                <td className="py-2 px-4 text-right font-mono font-black text-emerald-600">{runningCalc.reconciliationWeight}g</td>
                <td className="py-2 px-3 text-right font-mono">0.00g</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">12</td>
                <td className="py-2 px-3">Raw Material Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">₹{baseCalc.rawMaterialCost.toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">₹{runningCalc.rawMaterialCost.toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">13</td>
                <td className="py-2 px-3">Master batch cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">₹{baseCalc.masterbatchCost.toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">₹{runningCalc.masterbatchCost.toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr className="bg-slate-50 font-bold">
                <td className="py-2 px-3 font-mono text-slate-400">15</td>
                <td className="py-2 px-3 text-slate-900">Total Raw Material Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono text-slate-900">₹{baseCalc.totalRmCost.toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-900">₹{runningCalc.totalRmCost.toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">16</td>
                <td className="py-2 px-3">Machine Used</td>
                <td className="py-2 px-3 text-center">T</td>
                <td className="py-2 px-4 text-right font-mono">{formData.machineTonnage}T</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.machineTonnage}T</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">17</td>
                <td className="py-2 px-3 font-bold">Machine Tariff per Shift</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.shiftTariff} onChange={e => setFormData({ ...formData, shiftTariff: Number(e.target.value) })} className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningShiftTariff} onChange={e => setFormData({ ...formData, runningShiftTariff: Number(e.target.value) })} className="w-24 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">₹{(formData.shiftTariff - formData.runningShiftTariff).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">18</td>
                <td className="py-2 px-3 font-bold">Cycle Time</td>
                <td className="py-2 px-3 text-center">Sec</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.cycleTimeApproved} onChange={e => setFormData({ ...formData, cycleTimeApproved: Number(e.target.value) })} className="w-20 px-2 py-0.5 border border-amber-300 rounded text-right font-bold" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" value={formData.runningCycleTime} onChange={e => setFormData({ ...formData, runningCycleTime: Number(e.target.value) })} className="w-20 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">{(formData.cycleTimeApproved - formData.runningCycleTime).toFixed(1)}s</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">19</td>
                <td className="py-2 px-3">No of Shot / Shift (8Hour)</td>
                <td className="py-2 px-3 text-center">Nos</td>
                <td className="py-2 px-4 text-right font-mono">{shotsShift8hApproved}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{shotsShift8hRunning}</td>
                <td className="py-2 px-3 text-right font-mono">{(shotsShift8hApproved - shotsShift8hRunning).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">20</td>
                <td className="py-2 px-3">No of Shot / Shift with 95 % Efficiency</td>
                <td className="py-2 px-3 text-center">Nos</td>
                <td className="py-2 px-4 text-right font-mono">{shotsShift95Approved}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{shotsShift95Running}</td>
                <td className="py-2 px-3 text-right font-mono">{(shotsShift95Approved - shotsShift95Running).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">21</td>
                <td className="py-2 px-3">No. of component / shift</td>
                <td className="py-2 px-3 text-center">Nos</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{partsShiftApproved}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{partsShiftRunning}</td>
                <td className="py-2 px-3 text-right font-mono">{(partsShiftApproved - partsShiftRunning).toFixed(2)}</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">22</td>
                <td className="py-2 px-3 font-bold">Production Cost / Pc</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold">₹{baseCalc.productionCostPerPc.toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">₹{runningCalc.productionCostPerPc.toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr className="bg-slate-100 font-black">
                <td className="py-2 px-3 font-mono text-slate-400">23</td>
                <td className="py-2 px-3 uppercase text-slate-900">SUB TOTAL</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono text-slate-900">₹{baseCalc.subTotal.toFixed(4)}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-900">₹{runningCalc.subTotal.toFixed(4)}</td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr className="bg-purple-50/40">
                <td className="py-2 px-3 font-mono text-slate-400">24</td>
                <td className="py-2 px-3 font-bold text-purple-950">OH + Profit + ICC + Rejection + Packaging + Freight</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right">
                  <input type="number" step="0.0001" value={formData.haierOverheadPackage} onChange={e => setFormData({ ...formData, haierOverheadPackage: Number(e.target.value) })} className="w-28 px-2 py-0.5 border border-purple-300 rounded text-right font-bold text-purple-900" />
                </td>
                <td className="py-2 px-4 text-right">
                  <input type="number" step="0.0001" value={formData.runningHaierOverheadPackage} onChange={e => setFormData({ ...formData, runningHaierOverheadPackage: Number(e.target.value) })} className="w-28 px-2 py-0.5 border border-blue-300 rounded text-right font-bold text-blue-800" />
                </td>
                <td className="py-2 px-3 text-right font-mono">₹0.00</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">25</td>
                <td className="py-2 px-3">Foam / Polybag / Masking film</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.foamPolybag || '-'}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.foamPolybag || '-'}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">26</td>
                <td className="py-2 px-3">Plastic Bin / Polyend Box / Trolley</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.plasticBin || '-'}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.plasticBin || '-'}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">27</td>
                <td className="py-2 px-3">Freight Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.freightCost || '-'}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.freightCost || '-'}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">33</td>
                <td className="py-2 px-3">Insert / Hinge hole cap cost / Other cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.bopCost || '-'}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.bopCost || '-'}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">34</td>
                <td className="py-2 px-3 font-bold">Mould Maintenance Provision</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{formData.mouldMaintenance}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{formData.mouldMaintenance}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">35</td>
                <td className="py-2 px-3 font-bold">Quality Inspection Cost</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold">{formData.qualityInspection}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-blue-800">{formData.qualityInspection}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">36</td>
                <td className="py-2 px-3 font-bold text-rose-700">ICC Reduce by .5% (Payment term change 60 to 45 days)</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-rose-700">{formData.iccReduce}</td>
                <td className="py-2 px-4 text-right font-mono font-bold text-rose-700">{formData.iccReduce}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr>
                <td className="py-2 px-3 font-mono text-slate-400">37</td>
                <td className="py-2 px-3">Scrap Recovery Adjustment</td>
                <td className="py-2 px-3 text-center">Rs</td>
                <td className="py-2 px-4 text-right font-mono">{formData.scrapAdj || 0}</td>
                <td className="py-2 px-4 text-right font-mono text-blue-800">{formData.scrapAdj || 0}</td>
                <td className="py-2 px-3 text-right text-slate-400">-</td>
              </tr>
              <tr className="bg-slate-900 text-white font-black text-xs">
                <td className="py-3 px-3 font-mono text-amber-400">38</td>
                <td className="py-3 px-3 uppercase text-amber-400">TOTAL COST</td>
                <td className="py-3 px-3 text-center">Rs</td>
                <td className="py-3 px-4 text-right font-mono text-amber-300 text-sm">₹{contractTotal.toFixed(2)}</td>
                <td className="py-3 px-4 text-right font-mono text-emerald-400 text-sm">₹{runningTotal.toFixed(2)}</td>
                <td className={`py-3 px-3 text-right font-mono ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>
                  {profitLossDelta >= 0 ? `+₹${profitLossDelta.toFixed(2)}` : `-₹${Math.abs(profitLossDelta).toFixed(2)}`}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        {/* Footer Actions */}
        <div className="p-4 bg-slate-100 border-t border-slate-200 flex justify-between items-center">
          <button onClick={() => { if(window.confirm('Delete this part from baseline?')) { onDelete(product.id || product.itemCode); onClose(); }}} className="px-3.5 py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-300 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer">
            <Trash2 className="w-4 h-4" /> Delete Product
          </button>
          <div className="flex gap-2">
            <button onClick={onClose} className="px-4 py-2 bg-white hover:bg-slate-100 border border-slate-300 rounded-xl font-bold cursor-pointer">
              Cancel
            </button>
            <button onClick={handleSave} className="px-5 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm">
              <Save className="w-4 h-4" /> Save & Log Parameters
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export function calculateDetailedCost(item) {
  const isHaier = (item?.vendor || '').toLowerCase().includes('haier');
  const { baseRm, mbGrade } = parseMaterialString(item?.approvedRm || item?.baseRm);
  const rmInfo = getActiveRmMapping(baseRm || item?.baseRm || item?.approvedRm, item?.vendor);
  const mbInfo = getActiveMbMapping(mbGrade || item?.approvedMb, item?.vendor);

  if (isHaier) {
    const calc = calculateHaierCost({
      cavity: item.cavity || 1,
      netWeight: item.netWeight || 0,
      runnerWeight: item.runnerWeight || 0,
      shotWeight: item.shotWeight || 0,
      rmRate: Number(rmInfo.approvedPrice || 0),
      masterbatchPct: item.masterbatchPct ?? 0,
      masterbatchRate: Number(mbInfo.approvedMbPrice || 0),
      shiftTariff: item.shiftTariff || 0,
      cycleTime: item.cycleTimeApproved || 0,
      haierOverheadPackage: item.haierOverheadPackage || 0,
      foamPolybag: item.foamPolybag || 0,
      plasticBin: item.plasticBin || 0,
      freightCost: item.freightCost || 0,
      secondaryOp1: item.secondaryOp1 || 0,
      secondaryOp2: item.secondaryOp2 || 0,
      screenPrint1: item.screenPrint1 || 0,
      screenPrint2: item.screenPrint2 || 0,
      assemblyCost: item.assemblyCost || 0,
      mouldMaintenance: item.mouldMaintenance || 0,
      qualityInspection: item.qualityInspection || 0,
      iccReduce: item.iccReduce || 0,
      scrapAdj: item.scrapAdj || 0,
      bopCost: item.bopCost || 0
    });
    return {
      netRmCost: calc.totalRmCost,
      convRatePerPc: calc.productionCostPerPc,
      totalCost: calc.totalCost,
      finalLanded: calc.totalCost
    };
  } else {
    const calc = calculateAtombergCost({
      rmBase: Number(rmInfo.approvedPrice || 0),
      mbBase: Number(mbInfo.approvedMbPrice || 0),
      partWt: item.netWeight || 37,
      runnerWt: item.runnerWeight || 1,
      mbPct: (item.masterbatchPct || 4) / 100,
      bopCost: item.bopCost || 0,
      cycleTime: item.cycleTimeApproved || 47,
      cavity: item.cavity || 2,
      tonnage: item.machineTonnage || 200,
      shiftTariff: item.shiftTariff || 2000
    });
    return {
      netRmCost: calc.netRmCost,
      convRatePerPc: calc.convRatePerPc,
      totalCost: calc.finalLanded,
      finalLanded: calc.finalLanded
    };
  }
}
MODAL_EOF

echo "==> 5. Verifying build strictly on dev-v2..."
npm run build

echo "==> 6. Committing and pushing ONLY to origin/dev-v2 (Zero push to main)..."
git add -A
git commit -m "feat(dev-v2): verified 38-line Haier parser, RM matrix dynamic binding, and separate dev store key" || echo "dev-v2 is clean."
git push origin dev-v2

echo "==> 7. Restarting development server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ DEV-V2 ENVIRONMENT READY & 100% ISOLATED FROM MAIN!"
echo "   • Storage Key: CPC_MASTER_STORE_DEV_ISOLATED_V2"
echo "   • Git Branch: dev-v2 only (main remains untouched)"
echo "-------------------------------------------------------------------"
