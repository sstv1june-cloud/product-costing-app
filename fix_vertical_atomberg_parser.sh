#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring branch is dev-v2..."
git checkout dev-v2

echo "==> 2. Updating BaselineMasterPage.jsx with universal vertical & horizontal sheet parser..."
cat << 'PAGE_EOF' > src/modules/module1-baseline/BaselineMasterPage.jsx
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
  const [selectedVendor, setSelectedVendor] = useState('Haier Appliances');
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
    const mbLookupKey = mbGrade || prod.approvedMb || (prod.masterbatchPct > 0 ? 'White MB' : '');

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

      // Check if sheet is VERTICAL (labels in Column A/B and parts in Column C, D, E...)
      let isVerticalSheet = false;
      const colA_B_text = rawMatrix.slice(0, 25).map(r => `${r[0] || ''} ${r[1] || ''}`).join(' ').toLowerCase();
      
      if (
        colA_B_text.includes('part name') || 
        colA_B_text.includes('name of component') || 
        colA_B_text.includes('description') || 
        colA_B_text.includes('rm grade') || 
        colA_B_text.includes('cycle time') || 
        colA_B_text.includes('net weight') || 
        colA_B_text.includes('mould size')
      ) {
        isVerticalSheet = true;
      }

      if (isVerticalSheet) {
        // Find row index mapping in column A/B
        const rowMap = {};
        rawMatrix.forEach((r, idx) => {
          const rowLabel = `${r[0] || ''} ${r[1] || ''}`.toLowerCase().replace(/[^a-z0-9]/g, '');
          if (rowLabel.includes('name') || rowLabel.includes('component') || rowLabel.includes('description')) {
            if (rowMap.name === undefined) rowMap.name = idx;
          }
          if (rowLabel.includes('mouldsize') || rowLabel.includes('moldsize') || rowLabel.includes('dimension')) rowMap.mould = idx;
          if (rowLabel.includes('itemno') || rowLabel.includes('partno') || rowLabel.includes('partcode') || rowLabel.includes('itemcode')) rowMap.itemCode = idx;
          if (rowLabel.includes('model')) rowMap.model = idx;
          if (rowLabel.includes('rawmaterial') || rowLabel.includes('rmgrade') || rowLabel.includes('basepolymer') || rowLabel.includes('material')) rowMap.rm = idx;
          if (rowLabel.includes('masterbatch') || rowLabel.includes('mb') || rowLabel.includes('mbpercentage')) rowMap.mbPct = idx;
          if (rowLabel.includes('cavity') || rowLabel.includes('cavities')) rowMap.cavity = idx;
          if (rowLabel.includes('runnerweight') || rowLabel.includes('runnerwt')) rowMap.runnerWt = idx;
          if (rowLabel.includes('netweight') || rowLabel.includes('partweight') || rowLabel.includes('netwt') || rowLabel.includes('partwt')) rowMap.netWt = idx;
          if (rowLabel.includes('shotweight') || rowLabel.includes('shotwt')) rowMap.shotWt = idx;
          if (rowLabel.includes('reconciliation')) rowMap.reconWt = idx;
          if (rowLabel.includes('rawmaterialcost') || rowLabel.includes('rmbaserate') || rowLabel.includes('rmrate')) rowMap.rmCost = idx;
          if (rowLabel.includes('masterbatchcost') || rowLabel.includes('mbrate')) rowMap.mbCost = idx;
          if (rowLabel.includes('tonnage') || rowLabel.includes('machineused')) rowMap.tonnage = idx;
          if (rowLabel.includes('machinetariff') || rowLabel.includes('tariff')) rowMap.tariff = idx;
          if (rowLabel.includes('cycletime') || rowLabel.includes('ct')) rowMap.ct = idx;
          if (rowLabel.includes('overhead') || rowLabel.includes('ohprofit')) rowMap.overhead = idx;
          if (rowLabel.includes('totalcost') || rowLabel.includes('landedcost')) rowMap.totalCost = idx;
        });

        // Fallbacks for standard Haier / Atomberg indexes if rowMap missed any
        const nameRow = rowMap.name !== undefined ? rowMap.name : (isHaierVendor ? 1 : 0);
        const itemCodeRow = rowMap.itemCode !== undefined ? rowMap.itemCode : (isHaierVendor ? 3 : 2);
        const rmRow = rowMap.rm !== undefined ? rowMap.rm : (isHaierVendor ? 5 : 4);
        const mbRow = rowMap.mbPct !== undefined ? rowMap.mbPct : (isHaierVendor ? 6 : 5);
        const cavityRow = rowMap.cavity !== undefined ? rowMap.cavity : (isHaierVendor ? 7 : 6);
        const runnerRow = rowMap.runnerWt !== undefined ? rowMap.runnerWt : (isHaierVendor ? 8 : 7);
        const netWtRow = rowMap.netWt !== undefined ? rowMap.netWt : (isHaierVendor ? 9 : 8);
        const tonnageRow = rowMap.tonnage !== undefined ? rowMap.tonnage : (isHaierVendor ? 16 : 15);
        const tariffRow = rowMap.tariff !== undefined ? rowMap.tariff : (isHaierVendor ? 17 : 16);
        const ctRow = rowMap.ct !== undefined ? rowMap.ct : (isHaierVendor ? 18 : 17);
        const totalCostRow = rowMap.totalCost !== undefined ? rowMap.totalCost : (isHaierVendor ? 38 : 35);

        // Find starting data column (usually column 2 or 3)
        let startCol = 2;
        if (rawMatrix[0] && rawMatrix[0][3] !== undefined && rawMatrix[0][3] !== null && String(rawMatrix[0][3]).trim() !== '') {
          startCol = 3;
        }

        const totalCols = (rawMatrix[nameRow] || rawMatrix[0] || []).length;

        for (let c = startCol; c < totalCols; c++) {
          const compNameRaw = rawMatrix[nameRow]?.[c];
          const itemCodeRaw = rawMatrix[itemCodeRow]?.[c] || compNameRaw;
          if (!compNameRaw && !itemCodeRaw) continue;

          const compName = String(compNameRaw || itemCodeRaw).trim();
          const itemCode = String(itemCodeRaw || compName).trim();
          const mouldSize = String(rawMatrix[rowMap.mould || 2]?.[c] || '450x450x380').trim();
          const modelName = String(rawMatrix[rowMap.model || 4]?.[c] || (isHaierVendor ? 'TM 258/278' : 'Aris Ceiling Fan')).trim();

          const rawMatStr = String(rawMatrix[rmRow]?.[c] || (isHaierVendor ? 'HIPS SH303 + White MB' : 'PP H110MA + Gloss White')).trim();
          const { baseRm, mbGrade } = parseMaterialString(rawMatStr);

          const rawMbVal = rawMatrix[mbRow]?.[c];
          let mbPct = isHaierVendor ? 4.0 : 2.0;
          if (typeof rawMbVal === 'number') {
            mbPct = rawMbVal <= 1 ? Number((rawMbVal * 100).toFixed(2)) : rawMbVal;
          } else if (rawMbVal) {
            mbPct = parseFloat(String(rawMbVal).replace('%', '')) || mbPct;
          }

          const cavity = parseInt(rawMatrix[cavityRow]?.[c], 10) || (isHaierVendor ? 1 : 2);
          const runnerWt = parseFloat(rawMatrix[runnerRow]?.[c]) || 0;
          const netWt = parseFloat(rawMatrix[netWtRow]?.[c]) || 0;
          const shotWt = parseFloat(rawMatrix[rowMap.shotWt || 10]?.[c]) || (netWt * cavity + runnerWt);
          const reconWt = parseFloat(rawMatrix[rowMap.reconWt || 11]?.[c]) || Number(((shotWt / cavity) * 1.02).toFixed(2));

          const machineTonnage = parseInt(rawMatrix[tonnageRow]?.[c], 10) || (isHaierVendor ? 600 : 150);
          const shiftTariff = parseFloat(rawMatrix[tariffRow]?.[c]) || (isHaierVendor ? 4800 : 2800);
          const cycleTimeApproved = parseFloat(rawMatrix[ctRow]?.[c]) || (isHaierVendor ? 70 : 38);
          const approvedCost = parseFloat(rawMatrix[totalCostRow]?.[c]) || 0;

          // Auto-Register in RM Matrix
          if (baseRm) {
            addOrUpdateVendorMaterial({
              vendor: selectedVendor,
              type: 'RM',
              approvedCode: baseRm,
              approvedPrice: isHaierVendor ? 154 : 131
            });
          }

          parsed.push({
            id: `prod-${itemCode}-${c}`,
            vendor: selectedVendor,
            componentName: compName,
            mouldSize: mouldSize,
            itemCode: itemCode,
            model: modelName,
            approvedRm: rawMatStr,
            baseRm: baseRm || rawMatStr,
            approvedMb: mbGrade || (mbPct > 0 ? 'White MB' : 'None'),
            masterbatchPct: mbPct,
            cavity: cavity,
            runnerWeight: runnerWt,
            netWeight: netWt,
            shotWeight: shotWt,
            reconciliationWeight: reconWt,
            machineTonnage: machineTonnage,
            shiftTariff: shiftTariff,
            cycleTimeApproved: cycleTimeApproved,
            approvedCost: approvedCost,
            parameters: {
              runningCycleTime: cycleTimeApproved,
              runningCavity: cavity,
              runningRunnerWeight: runnerWt,
              runningNetWeight: netWt,
              runningShiftTariff: shiftTariff,
              runningMbPct: mbPct
            }
          });
        }
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

  // Computed live cost for staged item
  let computedStagedTotal = 0;
  if (activeStaged) {
    if (isHaierVendor) {
      const hCalc = calculateHaierCost({
        cavity: activeStaged.cavity,
        netWeight: activeStaged.netWeight,
        runnerWeight: activeStaged.runnerWeight,
        shotWeight: activeStaged.shotWeight,
        rmRate: 154,
        masterbatchPct: activeStaged.masterbatchPct,
        masterbatchRate: 242,
        shiftTariff: activeStaged.shiftTariff,
        cycleTime: activeStaged.cycleTimeApproved,
        haierOverheadPackage: activeStaged.haierOverheadPackage || 8.71
      });
      computedStagedTotal = Number(activeStaged.approvedCost || hCalc.totalCost || 0);
    } else {
      const aCalc = calculateAtombergCost({
        rmBase: 131,
        mbBase: 242,
        partWt: activeStaged.netWeight,
        runnerWt: activeStaged.runnerWeight,
        mbPct: (activeStaged.masterbatchPct || 2) / 100,
        bopCost: activeStaged.bopCost || 0,
        cycleTime: activeStaged.cycleTimeApproved || 38,
        cavity: activeStaged.cavity || 2,
        tonnage: activeStaged.machineTonnage || 150,
        shiftTariff: activeStaged.shiftTariff || 2800,
        postOpCost: 1.73,
        packingCost: 0.86,
        transportCost: 0.62,
        scrapRate: 25
      });
      computedStagedTotal = Number(activeStaged.approvedCost || aCalc.finalLanded || 0);
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
            <p className="text-[11px] text-slate-300">Dual Engine: Atomberg Dual Column & Haier 38-Line Costing</p>
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

      {/* Main Parameters Table */}
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

      {/* RENDER STAGING & VERIFICATION MODAL */}
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
                  Review complete specification parameters and make inline corrections before final baseline confirmation.
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
                      className={`px-3 py-2 rounded-xl text-left border transition-all shrink-0 w-44 cursor-pointer ${
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

            {/* Full Vertical Specification Table */}
            <div className="flex-1 overflow-y-auto p-4 space-y-1">
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
                    <td className="py-2 px-3 font-mono text-slate-400">2</td>
                    <td className="py-2 px-3">Mould size L x W x H</td>
                    <td className="py-2 px-3 text-center">mm</td>
                    <td className="py-2 px-4 text-right font-mono">{activeStaged.mouldSize}</td>
                  </tr>
                  <tr>
                    <td className="py-2 px-3 font-mono text-slate-400">3</td>
                    <td className="py-2 px-3 font-bold text-blue-700">Item No. / Part Code</td>
                    <td className="py-2 px-3 text-center">-</td>
                    <td className="py-2 px-4 text-right font-mono font-bold text-blue-700">{activeStaged.itemCode}</td>
                  </tr>
                  <tr>
                    <td className="py-2 px-3 font-mono text-slate-400">4</td>
                    <td className="py-2 px-3">Model</td>
                    <td className="py-2 px-3 text-center">-</td>
                    <td className="py-2 px-4 text-right font-mono">{activeStaged.model}</td>
                  </tr>
                  <tr>
                    <td className="py-2 px-3 font-mono text-slate-400">5</td>
                    <td className="py-2 px-3 font-bold">Raw Material Required</td>
                    <td className="py-2 px-3 text-center">-</td>
                    <td className="py-2 px-4 text-right font-bold text-slate-800">{activeStaged.approvedRm}</td>
                  </tr>
                  <tr className="bg-purple-50/40">
                    <td className="py-2 px-3 font-mono text-slate-400">6</td>
                    <td className="py-2 px-3 font-bold text-purple-900">Master Batch Required (%)</td>
                    <td className="py-2 px-3 text-center">%</td>
                    <td className="py-2 px-4 text-right">
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
                    <td className="py-2 px-3 font-mono text-slate-400">7</td>
                    <td className="py-2 px-3 font-bold text-amber-950">No. of Cavity</td>
                    <td className="py-2 px-3 text-center">Nos</td>
                    <td className="py-2 px-4 text-right">
                      <input 
                        type="number" 
                        value={activeStaged.cavity} 
                        onChange={e => handleUpdateActiveStaged('cavity', parseInt(e.target.value, 10) || 1)} 
                        className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold bg-white" 
                      />
                    </td>
                  </tr>
                  <tr className="bg-amber-50/30">
                    <td className="py-2 px-3 font-mono text-slate-400">8</td>
                    <td className="py-2 px-3 font-bold text-amber-950">Runner Weight</td>
                    <td className="py-2 px-3 text-center">Gms</td>
                    <td className="py-2 px-4 text-right">
                      <input 
                        type="number" 
                        step="0.01"
                        value={activeStaged.runnerWeight} 
                        onChange={e => handleUpdateActiveStaged('runnerWeight', parseFloat(e.target.value) || 0)} 
                        className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold bg-white" 
                      />
                    </td>
                  </tr>
                  <tr className="bg-amber-50/30">
                    <td className="py-2 px-3 font-mono text-slate-400">9</td>
                    <td className="py-2 px-3 font-bold text-amber-950">Net Weight</td>
                    <td className="py-2 px-3 text-center">Gms</td>
                    <td className="py-2 px-4 text-right">
                      <input 
                        type="number" 
                        step="0.01"
                        value={activeStaged.netWeight} 
                        onChange={e => handleUpdateActiveStaged('netWeight', parseFloat(e.target.value) || 0)} 
                        className="w-24 px-2 py-0.5 border border-amber-300 rounded text-right font-bold bg-white" 
                      />
                    </td>
                  </tr>
                  <tr>
                    <td className="py-2 px-3 font-mono text-slate-400">10</td>
                    <td className="py-2 px-3">Shot Weight</td>
                    <td className="py-2 px-3 text-center">Gms</td>
                    <td className="py-2 px-4 text-right font-mono font-bold">{Number(activeStaged.shotWeight || (activeStaged.netWeight * activeStaged.cavity + activeStaged.runnerWeight)).toFixed(2)}g</td>
                  </tr>
                  <tr>
                    <td className="py-2 px-3 font-mono text-slate-400">16</td>
                    <td className="py-2 px-3">Machine Used (Tonnage)</td>
                    <td className="py-2 px-3 text-center">T</td>
                    <td className="py-2 px-4 text-right">
                      <input 
                        type="number" 
                        value={activeStaged.machineTonnage} 
                        onChange={e => handleUpdateActiveStaged('machineTonnage', parseInt(e.target.value, 10) || 0)} 
                        className="w-24 px-2 py-0.5 border border-slate-300 rounded text-right font-bold bg-white" 
                      />
                    </td>
                  </tr>
                  <tr>
                    <td className="py-2 px-3 font-mono text-slate-400">17</td>
                    <td className="py-2 px-3 font-bold">Machine Tariff per Shift</td>
                    <td className="py-2 px-3 text-center">Rs</td>
                    <td className="py-2 px-4 text-right">
                      <input 
                        type="number" 
                        value={activeStaged.shiftTariff} 
                        onChange={e => handleUpdateActiveStaged('shiftTariff', parseFloat(e.target.value) || 0)} 
                        className="w-24 px-2 py-0.5 border border-slate-300 rounded text-right font-bold bg-white" 
                      />
                    </td>
                  </tr>
                  <tr className="bg-amber-50/50">
                    <td className="py-2 px-3 font-mono text-slate-400">18</td>
                    <td className="py-2 px-3 font-black text-amber-950">Cycle Time</td>
                    <td className="py-2 px-3 text-center">Sec</td>
                    <td className="py-2 px-4 text-right">
                      <input 
                        type="number" 
                        value={activeStaged.cycleTimeApproved} 
                        onChange={e => handleUpdateActiveStaged('cycleTimeApproved', parseFloat(e.target.value) || 0)} 
                        className="w-24 px-2 py-0.5 border border-amber-400 rounded text-right font-black text-amber-950 bg-white" 
                      />
                    </td>
                  </tr>
                  <tr className="bg-slate-900 text-white font-black">
                    <td className="py-2.5 px-3 font-mono text-amber-400">38</td>
                    <td className="py-2.5 px-3 uppercase text-amber-400">TOTAL COST</td>
                    <td className="py-2.5 px-3 text-center">Rs</td>
                    <td className="py-2.5 px-4 text-right font-mono text-amber-300 text-sm">₹{computedStagedTotal.toFixed(2)}</td>
                  </tr>
                </tbody>
              </table>
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
PAGE_EOF

echo "==> 3. Verifying build strictly on dev-v2..."
npm run build

echo "==> 4. Committing and pushing ONLY to origin/dev-v2 (Zero push to main)..."
git add -A
git commit -m "fix(staging): universal vertical & horizontal column detector for Atomberg & Haier" || echo "dev-v2 clean."
git push origin dev-v2

echo "==> 5. Restarting local dev server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Universal vertical parser restored on dev-v2."
echo "-------------------------------------------------------------------"
