import React, { useState, useEffect, useRef } from 'react';
import { 
  Upload, 
  Trash2, 
  Edit3, 
  Search, 
  Layers, 
  Database,
  CheckCircle2, 
  ChevronLeft, 
  ChevronRight,
  X
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
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';

export default function BaselineMasterPage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('Atomberg Technologies');
  const [activeTab, setActiveTab] = useState('parameters');
  const [searchQuery, setSearchQuery] = useState('');
  const [editingProduct, setEditingProduct] = useState(null);
  
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [stagedData, setStagedData] = useState([]);
  const [selectedStagedIndex, setSelectedStagedIndex] = useState(0);
  const tabsContainerRef = useRef(null);

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
    const mbLookupKey = mbGrade || prod.approvedMb || (prod.masterbatchPct > 0 ? 'Gloss White MB' : '');

    const rmMap = getActiveRmMapping(rmLookupKey, prod.vendor);
    const mbMap = getActiveMbMapping(mbLookupKey, prod.vendor);
    
    setEditingProduct({
      ...prod,
      baseRm: rmLookupKey,
      approvedMb: mbLookupKey,
      approvedRmPrice: Number(rmMap.approvedPrice || prod.approvedRmPrice || 0),
      activeRmWaPrice: Number(rmMap.activeWaPrice || rmMap.approvedPrice || prod.approvedRmPrice || 0),
      approvedMbPrice: Number(mbMap.approvedMbPrice || prod.approvedMbPrice || 0),
      activeMbWaPrice: Number(mbMap.activeMbWaPrice || mbMap.approvedMbPrice || prod.approvedMbPrice || 0)
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
      const rawMatrix = XLSX.utils.sheet_to_json(ws, { header: 1 });

      if (!rawMatrix || rawMatrix.length === 0) return;

      const parsed = [];
      const isHaierVendor = selectedVendor.toLowerCase().includes('haier');

      // Exact 38-line column scanner across row descriptions
      const totalCols = Math.max(...rawMatrix.map(r => r.length));
      let startCol = 3; // Standard Column D (Index 3)
      if (rawMatrix[0] && rawMatrix[0][3] === undefined) startCol = 2;

      for (let c = startCol; c < totalCols; c++) {
        // Find part code & part name
        let itemCode = '';
        let compName = '';
        let rmGradeStr = 'PP H110MA + Gloss White';
        let rmBaseRate = isHaierVendor ? 154 : 131;
        let mbBaseRate = isHaierVendor ? 242 : 154;
        let mbPct = isHaierVendor ? 4.0 : 4.0;
        let partWt = isHaierVendor ? 372 : 37.00;
        let runnerWt = isHaierVendor ? 0 : 1.00;
        let tonnage = isHaierVendor ? 600 : 200;
        let tariff = isHaierVendor ? 4800 : 2000;
        let cycleTime = isHaierVendor ? 70 : 47;
        let cavity = isHaierVendor ? 1 : 2;

        rawMatrix.forEach(r => {
          const label = `${r[0] || ''} ${r[1] || ''}`.toLowerCase().trim();
          const val = r[c];
          if (val === undefined || val === null || val === '') return;

          if (label.includes('part code') || label.includes('item no') || label === '2') itemCode = String(val).trim();
          if (label.includes('part name') || label.includes('name of component') || (label.includes('description') && !label.includes('grade'))) compName = String(val).trim();
          if (label.includes('rm grade') || (label.includes('raw material') && !label.includes('cost'))) rmGradeStr = String(val).trim();
          if (label.includes('rm base rate') || (label.includes('raw material cost') && label.includes('matrix'))) rmBaseRate = parseFloat(val) || rmBaseRate;
          if (label.includes('mb base cost') || label.includes('mb rate')) mbBaseRate = parseFloat(val) || mbBaseRate;
          if (label.includes('mb %') || label.includes('masterbatch %')) {
            const num = parseFloat(val);
            mbPct = num <= 1 ? num * 100 : num;
          }
          if (label.includes('part weight grams') || label.includes('net weight')) partWt = parseFloat(val) || partWt;
          if (label.includes('runner weight grams') || (label.includes('runner weight') && !label.includes('recovery'))) runnerWt = parseFloat(val) || runnerWt;
          if (label.includes('m/c tonnage') || label.includes('machine used') || label.includes('tonnage')) tonnage = parseInt(val, 10) || tonnage;
          if (label.includes('shift rate') || label.includes('shift tariff')) tariff = parseFloat(val) || tariff;
          if (label.includes('cycle time') || label.includes('ct')) cycleTime = parseFloat(val) || cycleTime;
          if (label.includes('no of cavity') || label.includes('no. of cavity')) cavity = parseInt(val, 10) || cavity;
        });

        // Fallback to top headers if not found in body
        if (!itemCode && rawMatrix[2]?.[c]) itemCode = String(rawMatrix[2][c]).trim();
        if (!compName && rawMatrix[0]?.[c]) compName = String(rawMatrix[0][c]).trim();
        if (!compName && rawMatrix[3]?.[c]) compName = String(rawMatrix[3][c]).trim();

        if (!compName && !itemCode) continue;

        itemCode = itemCode || compName || `PART-${c}`;
        compName = compName || itemCode;

        const { baseRm, mbGrade } = parseMaterialString(rmGradeStr);

        // Auto-Register in RM Matrix
        if (baseRm) {
          addOrUpdateVendorMaterial({
            vendor: selectedVendor,
            type: 'RM',
            approvedCode: baseRm,
            approvedPrice: rmBaseRate
          });
        }
        if (mbGrade) {
          addOrUpdateVendorMaterial({
            vendor: selectedVendor,
            type: 'MB',
            approvedCode: mbGrade,
            approvedPrice: mbBaseRate
          });
        }

        let calcResult = 0;
        if (isHaierVendor) {
          const h = calculateHaierCost({
            cavity,
            netWeight: partWt,
            runnerWeight: runnerWt,
            shotWeight: partWt * cavity + runnerWt,
            rmRate: rmBaseRate,
            masterbatchPct: mbPct,
            masterbatchRate: mbBaseRate,
            shiftTariff: tariff,
            cycleTime,
            haierOverheadPackage: 8.71
          });
          calcResult = h.totalCost;
        } else {
          const a = calculateAtombergCost({
            rmBase: rmBaseRate,
            mbBase: mbBaseRate,
            partWt: partWt,
            runnerWt: runnerWt,
            mbPct: mbPct / 100,
            bopCost: 0,
            cycleTime: cycleTime,
            cavity: cavity,
            tonnage: tonnage,
            shiftTariff: tariff,
            postOpCost: 1.73,
            packingCost: 0.00,
            transportCost: 0.86,
            otherCost: 0.07
          });
          calcResult = a.finalLanded;
        }

        parsed.push({
          id: `prod-${itemCode}-${c}`,
          vendor: selectedVendor,
          componentName: compName,
          mouldSize: '450x450x380',
          itemCode: itemCode,
          model: 'Aris Ceiling Fan',
          approvedRm: rmGradeStr,
          baseRm: baseRm || rmGradeStr,
          approvedMb: mbGrade || 'Gloss White MB',
          masterbatchPct: mbPct,
          cavity: cavity,
          runnerWeight: runnerWt,
          netWeight: partWt,
          shotWeight: (partWt * cavity + runnerWt),
          machineTonnage: tonnage,
          shiftTariff: tariff,
          cycleTimeApproved: cycleTime,
          approvedCost: calcResult,
          parameters: {
            runningCycleTime: cycleTime,
            runningCavity: cavity,
            runningRunnerWeight: runnerWt,
            runningNetWeight: partWt,
            runningShiftTariff: tariff,
            runningMbPct: mbPct
          }
        });
      }

      setStagedData(parsed);
      setSelectedStagedIndex(0);
      setShowUploadModal(true);
    };
    reader.readAsBinaryString(file);
  };

  const handleUpdateActiveStaged = (field, value) => {
    setStagedData(prev => {
      const copy = [...prev];
      copy[selectedStagedIndex] = {
        ...copy[selectedStagedIndex],
        [field]: value
      };
      return copy;
    });
  };

  const handleCommitStaged = () => {
    addStagedProductsToBaseline(stagedData, selectedVendor);
    setStagedData([]);
    setShowUploadModal(false);
  };

  const scrollTabs = (offset) => {
    if (tabsContainerRef.current) {
      tabsContainerRef.current.scrollBy({ left: offset, behavior: 'smooth' });
    }
  };

  const activeStaged = stagedData[selectedStagedIndex] || null;
  const isHaierVendor = (selectedVendor || '').toLowerCase().includes('haier');

  let atomStagedCalc = null;
  let haierStagedCalc = null;
  let computedStagedTotal = 0;

  if (activeStaged) {
    if (isHaierVendor) {
      haierStagedCalc = calculateHaierCost({
        cavity: activeStaged.cavity,
        netWeight: activeStaged.netWeight,
        runnerWeight: activeStaged.runnerWeight,
        shotWeight: activeStaged.shotWeight,
        rmRate: 154,
        masterbatchPct: activeStaged.masterbatchPct,
        masterbatchRate: 242,
        shiftTariff: activeStaged.shiftTariff,
        cycleTime: activeStaged.cycleTimeApproved,
        haierOverheadPackage: 8.71
      });
      computedStagedTotal = Number(activeStaged.approvedCost || haierStagedCalc.totalCost || 0);
    } else {
      atomStagedCalc = calculateAtombergCost({
        rmBase: 131,
        mbBase: 154,
        partWt: activeStaged.netWeight,
        runnerWt: activeStaged.runnerWeight,
        mbPct: (activeStaged.masterbatchPct || 4) / 100,
        bopCost: 0,
        cycleTime: activeStaged.cycleTimeApproved || 47,
        cavity: activeStaged.cavity || 2,
        tonnage: activeStaged.machineTonnage || 200,
        shiftTariff: activeStaged.shiftTariff || 2000,
        postOpCost: 1.73,
        packingCost: 0.00,
        transportCost: 0.86,
        otherCost: 0.07
      });
      computedStagedTotal = Number(activeStaged.approvedCost || atomStagedCalc.finalLanded || 0);
    }
  }

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
            <p className="text-[11px] text-slate-300">Exact 38-Line Costing Engine for Atomberg & Haier</p>
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

      {/* Main Table */}
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
                {vendorAuditLogs.map((log, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="py-2.5 px-3 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{log.partCode}</td>
                    <td className="py-2.5 px-4 font-semibold text-slate-800">{log.componentName}</td>
                    <td className="py-2.5 px-4 font-mono text-[11px] text-slate-700">{log.modifications}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">{log.costImpact}</td>
                    <td className="py-2.5 px-4 text-slate-600">{log.reason}</td>
                  </tr>
                ))}
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

      {/* RENDER STAGING MODAL (All 38 Rows) */}
      {showUploadModal && activeStaged && (
        <div className="fixed inset-0 z-50 bg-slate-900/70 backdrop-blur-xs flex items-center justify-center p-4 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-4xl w-full max-h-[92vh] flex flex-col shadow-2xl overflow-hidden text-xs">
            {/* Header */}
            <div className="p-4 bg-white border-b border-slate-200 flex justify-between items-start">
              <div>
                <div className="flex items-center gap-2">
                  <CheckCircle2 className="w-5 h-5 text-emerald-600" />
                  <h3 className="text-sm font-bold text-slate-900">
                    Staging & Verification: {selectedVendor} Product Import ({stagedData.length} Staged Parts)
                  </h3>
                </div>
                <p className="text-[11px] text-slate-500 mt-0.5">
                  Review complete 38-line specification parameters and make inline corrections before final baseline confirmation.
                </p>
              </div>
              <button onClick={() => setShowUploadModal(false)} className="p-1 hover:bg-slate-100 rounded text-slate-400 hover:text-slate-600 cursor-pointer">
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Horizontal Part Carousel */}
            <div className="bg-slate-100/70 p-2 border-b border-slate-200 flex items-center gap-1.5">
              <button 
                onClick={() => scrollTabs(-200)}
                className="p-1 bg-white hover:bg-slate-200 rounded border border-slate-300 shadow-2xs text-slate-600 cursor-pointer"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>

              <div 
                ref={tabsContainerRef}
                className="flex gap-2 overflow-x-auto no-scrollbar py-1 scroll-smooth flex-1"
                style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
              >
                {stagedData.map((st, idx) => {
                  const isSelected = idx === selectedStagedIndex;
                  return (
                    <button
                      key={idx}
                      onClick={() => setSelectedStagedIndex(idx)}
                      className={`px-3 py-2 rounded-xl text-left border transition-all shrink-0 w-48 cursor-pointer ${
                        isSelected 
                          ? 'bg-blue-600 text-white border-blue-700 shadow-md font-bold' 
                          : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
                      }`}
                    >
                      <div className="font-mono text-[10px] leading-tight truncate">{st.itemCode}</div>
                      <div className="text-[9px] mt-0.5 line-clamp-2 leading-tight opacity-90">{st.componentName}</div>
                    </button>
                  );
                })}
              </div>

              <button 
                onClick={() => scrollTabs(200)}
                className="p-1 bg-white hover:bg-slate-200 rounded border border-slate-300 shadow-2xs text-slate-600 cursor-pointer"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>

            {/* Staged Component Banner */}
            <div className="px-5 py-3 bg-slate-50/90 border-b border-slate-200 flex justify-between items-center">
              <div>
                <div className="text-[9px] uppercase font-bold text-slate-400">STAGED COMPONENT & ITEM CODE</div>
                <div className="text-xs font-bold text-slate-900 font-mono mt-0.5">
                  [{activeStaged.itemCode}] {activeStaged.componentName}
                </div>
              </div>
              <div className="text-right">
                <div className="text-[9px] uppercase font-bold text-emerald-700">COMPUTED STAGED TOTAL COST</div>
                <div className="text-base font-black font-mono text-emerald-600 mt-0.5">
                  ₹{computedStagedTotal.toFixed(2)}
                </div>
              </div>
            </div>

            {/* Full Specification Staging Table */}
            <div className="flex-1 overflow-y-auto p-4 space-y-1">
              {!isHaierVendor ? (
                <table className="w-full text-left border-collapse text-xs">
                  <thead className="bg-slate-100 text-slate-700 text-[10px] uppercase font-bold sticky top-0 border-b border-slate-200">
                    <tr>
                      <th className="py-2.5 px-3 w-8">#</th>
                      <th className="py-2.5 px-3">Atomberg Costing Line</th>
                      <th className="py-2.5 px-3 text-center w-24">UOM / Rate</th>
                      <th className="py-2.5 px-4 text-right w-64">Staged Value (Editable)</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 font-medium">
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">1</td>
                      <td className="py-1.5 px-3">Vendor</td>
                      <td className="py-1.5 px-3 text-center">-</td>
                      <td className="py-1.5 px-4 text-right font-bold text-slate-800">{activeStaged.vendor}</td>
                    </tr>
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">2</td>
                      <td className="py-1.5 px-3 font-bold text-blue-700">Part Code</td>
                      <td className="py-1.5 px-3 text-center">-</td>
                      <td className="py-1.5 px-4 text-right font-mono font-bold text-blue-700">{activeStaged.itemCode}</td>
                    </tr>
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">3</td>
                      <td className="py-1.5 px-3 font-bold">Part name</td>
                      <td className="py-1.5 px-3 text-center">-</td>
                      <td className="py-1.5 px-4 text-right font-bold text-slate-800">{activeStaged.componentName}</td>
                    </tr>
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">4</td>
                      <td className="py-1.5 px-3">RM grade (Locked & Linked)</td>
                      <td className="py-1.5 px-3 text-center">-</td>
                      <td className="py-1.5 px-4 text-right font-semibold text-slate-700">{activeStaged.approvedRm}</td>
                    </tr>
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">5</td>
                      <td className="py-1.5 px-3">RM Base Rate (From RM Matrix)</td>
                      <td className="py-1.5 px-3 text-center">₹/kg</td>
                      <td className="py-1.5 px-4 text-right font-mono">₹{atomStagedCalc?.rmBase.toFixed(2) || 131.00}</td>
                    </tr>
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">8</td>
                      <td className="py-1.5 px-3 font-bold">RM Landed Cost</td>
                      <td className="py-1.5 px-3 text-center">₹/kg</td>
                      <td className="py-1.5 px-4 text-right font-mono font-bold">₹{atomStagedCalc?.rmLanded.toFixed(2) || 133.81}</td>
                    </tr>
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">12</td>
                      <td className="py-1.5 px-3 font-bold">MB Landed Cost</td>
                      <td className="py-1.5 px-3 text-center">₹/kg</td>
                      <td className="py-1.5 px-4 text-right font-mono font-bold">₹{atomStagedCalc?.mbLanded.toFixed(2) || 157.54}</td>
                    </tr>
                    <tr className="bg-purple-50/40">
                      <td className="py-1.5 px-3 font-mono text-slate-400">13</td>
                      <td className="py-1.5 px-3 font-bold text-purple-900">MB %</td>
                      <td className="py-1.5 px-3 text-center">%</td>
                      <td className="py-1.5 px-4 text-right">
                        <input 
                          type="number" 
                          step="0.1" 
                          value={activeStaged.masterbatchPct} 
                          onChange={e => handleUpdateActiveStaged('masterbatchPct', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-purple-300 rounded text-right font-bold text-purple-900 bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-amber-50/30">
                      <td className="py-1.5 px-3 font-mono text-slate-400">15</td>
                      <td className="py-1.5 px-3 font-bold text-amber-950">Part weight grams</td>
                      <td className="py-1.5 px-3 text-center">Gms</td>
                      <td className="py-1.5 px-4 text-right">
                        <input 
                          type="number" 
                          step="0.01" 
                          value={activeStaged.netWeight} 
                          onChange={e => handleUpdateActiveStaged('netWeight', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-amber-50/30">
                      <td className="py-1.5 px-3 font-mono text-slate-400">16</td>
                      <td className="py-1.5 px-3 font-bold text-amber-950">Runner weight grams</td>
                      <td className="py-1.5 px-3 text-center">Gms</td>
                      <td className="py-1.5 px-4 text-right">
                        <input 
                          type="number" 
                          step="0.01" 
                          value={activeStaged.runnerWeight} 
                          onChange={e => handleUpdateActiveStaged('runnerWeight', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-emerald-50/40 font-bold">
                      <td className="py-1.5 px-3 font-mono text-slate-400">18</td>
                      <td className="py-1.5 px-3 text-emerald-950">RM cost</td>
                      <td className="py-1.5 px-3 text-center">₹/pc</td>
                      <td className="py-1.5 px-4 text-right font-mono text-emerald-900">₹{atomStagedCalc?.rmCostPerPc.toFixed(2) || 5.27}</td>
                    </tr>
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">22</td>
                      <td className="py-1.5 px-3 font-bold">Shift rate</td>
                      <td className="py-1.5 px-3 text-center">₹/shift</td>
                      <td className="py-1.5 px-4 text-right">
                        <input 
                          type="number" 
                          value={activeStaged.shiftTariff} 
                          onChange={e => handleUpdateActiveStaged('shiftTariff', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-slate-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-amber-50/50">
                      <td className="py-1.5 px-3 font-mono text-slate-400">23</td>
                      <td className="py-1.5 px-3 font-black text-amber-950">Cycle time</td>
                      <td className="py-1.5 px-3 text-center">Sec</td>
                      <td className="py-1.5 px-4 text-right">
                        <input 
                          type="number" 
                          value={activeStaged.cycleTimeApproved} 
                          onChange={e => handleUpdateActiveStaged('cycleTimeApproved', parseFloat(e.target.value) || 0)} 
                          className="w-24 px-2 py-0.5 border border-amber-400 rounded text-right font-black text-amber-950 bg-white" 
                        />
                      </td>
                    </tr>
                    <tr>
                      <td className="py-1.5 px-3 font-mono text-slate-400">25</td>
                      <td className="py-1.5 px-3">No of cavity</td>
                      <td className="py-1.5 px-3 text-center">Nos</td>
                      <td className="py-1.5 px-4 text-right">
                        <input 
                          type="number" 
                          value={activeStaged.cavity} 
                          onChange={e => handleUpdateActiveStaged('cavity', parseInt(e.target.value, 10) || 1)} 
                          className="w-24 px-2 py-0.5 border border-slate-300 rounded text-right font-bold bg-white" 
                        />
                      </td>
                    </tr>
                    <tr className="bg-slate-100 font-bold">
                      <td className="py-1.5 px-3 font-mono text-slate-400">30</td>
                      <td className="py-1.5 px-3">Total Process Cost</td>
                      <td className="py-1.5 px-3 text-center">₹/pc</td>
                      <td className="py-1.5 px-4 text-right font-mono font-bold">₹{atomStagedCalc?.totalProcessCost.toFixed(2) || 3.54}</td>
                    </tr>
                    <tr className="bg-slate-900 text-white font-black">
                      <td className="py-2.5 px-3 font-mono text-amber-400">38</td>
                      <td className="py-2.5 px-3 uppercase text-amber-400">Final Landed cost</td>
                      <td className="py-2.5 px-3 text-center">₹/pc</td>
                      <td className="py-2.5 px-4 text-right font-mono text-amber-300 text-sm">₹{computedStagedTotal.toFixed(2)}</td>
                    </tr>
                  </tbody>
                </table>
              ) : (
                <table className="w-full text-left border-collapse text-xs">
                  <thead className="bg-slate-100 text-slate-700 text-[10px] uppercase font-bold sticky top-0 border-b border-slate-200">
                    <tr>
                      <th className="py-2 px-3 w-8">#</th>
                      <th className="py-2 px-3">DESCRIPTION / COSTING LINE</th>
                      <th className="py-2 px-3 text-center w-24">UOM</th>
                      <th className="py-2 px-4 text-right w-64">STAGED VALUE (EDITABLE)</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 font-medium">
                    <tr>
                      <td className="py-2 px-3 font-mono text-slate-400">1</td>
                      <td className="py-2 px-3 font-bold">Name Of component</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-bold text-slate-800">{activeStaged.componentName}</td>
                    </tr>
                    <tr>
                      <td className="py-2 px-3 font-mono text-slate-400">3</td>
                      <td className="py-2 px-3 font-bold text-blue-700">Item No. / Part Code</td>
                      <td className="py-2 px-3 text-center">-</td>
                      <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{activeStaged.itemCode}</td>
                    </tr>
                    <tr className="bg-slate-900 text-white font-black">
                      <td className="py-2.5 px-3 font-mono text-amber-400">38</td>
                      <td className="py-2.5 px-3 uppercase text-amber-400">TOTAL COST</td>
                      <td className="py-2.5 px-3 text-center">Rs</td>
                      <td className="py-2.5 px-4 text-right font-mono text-amber-300 text-sm">₹{computedStagedTotal.toFixed(2)}</td>
                    </tr>
                  </tbody>
                </table>
              )}
            </div>

            {/* Modal Footer Actions */}
            <div className="p-4 bg-slate-50 border-t border-slate-200 flex justify-between items-center">
              <button 
                onClick={() => setShowUploadModal(false)} 
                className="px-5 py-2.5 bg-white hover:bg-slate-100 border border-slate-300 text-slate-700 rounded-xl font-bold cursor-pointer transition shadow-2xs"
              >
                Cancel Staging
              </button>
              <button 
                onClick={handleCommitStaged} 
                className="px-6 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-2 cursor-pointer shadow-md transition text-xs"
              >
                <CheckCircle2 className="w-4 h-4" /> Confirm & Add All Staged Products ({stagedData.length})
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
