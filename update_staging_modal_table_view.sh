#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring branch is dev-v2..."
git checkout dev-v2

echo "==> 2. Updating BaselineMasterPage.jsx with rich structured staging table preview..."
cat << 'PAGE_EOF' > src/modules/module1-baseline/BaselineMasterPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Upload, 
  Trash2, 
  Edit3, 
  Search, 
  Layers, 
  Database,
  CheckCircle2,
  Table,
  FileSpreadsheet
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

      {/* RENDER FULL-WIDTH STRUCTURED STAGED UPLOAD MODAL */}
      {showUploadModal && (
        <div className="fixed inset-0 z-50 bg-slate-900/70 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-6xl w-full max-h-[90vh] flex flex-col shadow-2xl overflow-hidden text-xs">
            {/* Modal Header */}
            <div className="p-4 bg-slate-900 text-white flex justify-between items-center">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-blue-600 rounded-lg">
                  <FileSpreadsheet className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h3 className="text-sm font-bold flex items-center gap-2">
                    Staged Baseline Specification Preview 
                    <span className="bg-emerald-500/20 text-emerald-400 text-[10px] px-2 py-0.5 rounded-full border border-emerald-500/30">
                      {stagedData.length} Records Parsed
                    </span>
                  </h3>
                  <p className="text-[11px] text-slate-300">
                    Target Vendor: <b>{selectedVendor}</b> • Review specifications and calculated landed costs before committing to master database.
                  </p>
                </div>
              </div>
            </div>

            {/* Modal Full-Width Structured Table */}
            <div className="flex-1 overflow-auto p-4">
              <table className="w-full text-left border-collapse text-xs">
                <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px] sticky top-0 border-b border-slate-200">
                  <tr>
                    <th className="py-2.5 px-3">#</th>
                    <th className="py-2.5 px-3">Item Code</th>
                    <th className="py-2.5 px-3">Component Name</th>
                    <th className="py-2.5 px-3">Model</th>
                    <th className="py-2.5 px-3">Raw Material</th>
                    <th className="py-2.5 px-2 text-center">MB %</th>
                    <th className="py-2.5 px-2 text-center">Cavity</th>
                    <th className="py-2.5 px-3 text-right">Net Wt</th>
                    <th className="py-2.5 px-3 text-right">Runner Wt</th>
                    <th className="py-2.5 px-3 text-center bg-amber-50 text-amber-950 font-bold">Cycle Time</th>
                    <th className="py-2.5 px-3 text-center">Tonnage</th>
                    <th className="py-2.5 px-3 text-right">Shift Tariff</th>
                    <th className="py-2.5 px-4 text-right bg-blue-50 text-blue-950 font-bold">Total Cost</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {stagedData.map((s, idx) => (
                    <tr key={idx} className="hover:bg-slate-50 transition-colors">
                      <td className="py-2 px-3 font-mono text-slate-400">{idx + 1}</td>
                      <td className="py-2 px-3 font-mono font-bold text-blue-700">{s.itemCode}</td>
                      <td className="py-2 px-3 font-semibold text-slate-800">{s.componentName}</td>
                      <td className="py-2 px-3 font-mono text-slate-600">{s.model}</td>
                      <td className="py-2 px-3 text-slate-700">{s.approvedRm}</td>
                      <td className="py-2 px-2 text-center font-mono text-purple-700 font-bold">{s.masterbatchPct}%</td>
                      <td className="py-2 px-2 text-center font-mono font-bold">{s.cavity}</td>
                      <td className="py-2 px-3 text-right font-mono">{s.netWeight}g</td>
                      <td className="py-2 px-3 text-right font-mono">{s.runnerWeight}g</td>
                      <td className="py-2 px-3 text-center font-mono font-black text-amber-900 bg-amber-50/50">{s.cycleTimeApproved}s</td>
                      <td className="py-2 px-3 text-center font-mono">{s.machineTonnage}T</td>
                      <td className="py-2 px-3 text-right font-mono">₹{s.shiftTariff}</td>
                      <td className="py-2 px-4 text-right font-mono font-black text-blue-700 bg-blue-50/40">₹{Number(s.approvedCost || 0).toFixed(2)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Modal Footer Actions */}
            <div className="p-4 bg-slate-100 border-t border-slate-200 flex justify-between items-center">
              <div className="text-xs text-slate-500 font-medium">
                Showing all <b>{stagedData.length}</b> staged records ready for import.
              </div>
              <div className="flex gap-2">
                <button 
                  onClick={() => setShowUploadModal(false)} 
                  className="px-4 py-2 bg-white hover:bg-slate-200 border border-slate-300 rounded-xl font-bold cursor-pointer transition"
                >
                  Cancel
                </button>
                <button 
                  onClick={handleCommitStaged} 
                  className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm transition"
                >
                  <CheckCircle2 className="w-4 h-4" /> Commit All to Baseline
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
PAGE_EOF

echo "==> 3. Verifying build strictly on dev-v2..."
npm run build

echo "==> 4. Committing and pushing ONLY to origin/dev-v2 (Zero push to main)..."
git add -A
git commit -m "feat(dev-v2): restore full-width table staging modal for multi-product uploads" || echo "dev-v2 clean."
git push origin dev-v2

echo "==> 5. Restarting local dev server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ DEV-V2 STAGING MODAL RESTORED AS FULL STRUCTURED TABLE!"
echo "-------------------------------------------------------------------"
