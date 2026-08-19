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
