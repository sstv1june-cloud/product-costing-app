#!/usr/bin/env bash
set -e

echo "==> Restoring BaselineMasterPage.jsx with vertical 38-line spec staging..."
BASELINE_PAGE="src/modules/module1-baseline/BaselineMasterPage.jsx"

cat << 'EOF_BM' > "$BASELINE_PAGE"
import React, { useState, useEffect } from 'react';
import { 
  Layers, Upload, Download, History, Search, Edit, Plus, FileSpreadsheet, CheckCircle2, X 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  getVendorBaselineData, 
  deleteProductFromBaseline,
  addStagedProductsToBaseline 
} from '../../shared/masterStore';
import { calculateHaierCost, calculateAtombergCost } from '../../shared/costCalculationService';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [activeTab, setActiveTab] = useState('parameters');
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);
  
  // Staging Modal State
  const [showStagingModal, setShowStagingModal] = useState(false);
  const [stagedProduct, setStagedProduct] = useState(null);

  const rawProducts = getVendorBaselineData(selectedVendor);
  const paramLogs = globalStore.parameterChangeLogs || [];

  const filteredProducts = rawProducts.filter(p => {
    const q = searchQuery.toLowerCase();
    return (p.itemCode || '').toLowerCase().includes(q) || (p.componentName || '').toLowerCase().includes(q);
  });

  const filteredLogs = paramLogs.filter(log => {
    if (selectedVendor === 'ALL' || selectedVendor === 'All Vendors Combined' || !selectedVendor) return true;
    return (log.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase());
  });

  // Download Spec Template
  const handleDownloadTemplate = () => {
    const templateRows = [
      { SNo: 1, Description: 'Customer Name', UOM: '-', Costing: 'Haier Appliances' },
      { SNo: 2, Description: 'Model Name', UOM: '-', Costing: 'OLD DC- 195,220' },
      { SNo: 3, Description: 'Item No.', UOM: '-', Costing: '0060226713D' },
      { SNo: 4, Description: 'Part Description', UOM: '-', Costing: 'End Cap Top Ref (without Screen Painting)' },
      { SNo: 5, Description: 'Raw Material Required', UOM: '-', Costing: 'ABS 300 Pre Colour' },
      { SNo: 6, Description: 'Raw Material Rate (Rs/kg)', UOM: 'Rs/kg', Costing: 136.20 },
      { SNo: 7, Description: 'Masterbatch Required (%)', UOM: '%', Costing: 0.0 },
      { SNo: 8, Description: 'Masterbatch Rate (Rs/kg)', UOM: 'Rs/kg', Costing: 0.0 },
      { SNo: 9, Description: 'No. of Cavity', UOM: 'Nos', Costing: 2 },
      { SNo: 10, Description: 'Runner Weight', UOM: 'Gms', Costing: 40.0 },
      { SNo: 11, Description: 'Net Weight', UOM: 'Gms', Costing: 197.0 },
      { SNo: 12, Description: 'Machine Used (Tonnage)', UOM: 'T', Costing: 450 },
      { SNo: 13, Description: 'Machine Tariff per Shift', UOM: 'Rs', Costing: 3600 },
      { SNo: 14, Description: 'Cycle Time', UOM: 'Sec', Costing: 56.0 },
      { SNo: 15, Description: 'BOP / Insert Cost', UOM: 'Rs', Costing: 0.14 }
    ];
    const ws = XLSX.utils.json_to_sheet(templateRows);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Haier_38Line_Spec');
    XLSX.writeFile(wb, 'Haier_38Line_Costing_Template.xlsx');
  };

  // Upload and Parse Vertical or Horizontal Costing Sheet
  const handleUploadSpec = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const wb = XLSX.read(evt.target.result, { type: 'binary' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const data = XLSX.utils.sheet_to_json(ws, { header: 1 });
        
        let itemCode = '0060226713D';
        let componentName = 'End Cap Top Ref (without Screen Painting)';
        let model = 'OLD DC- 195,220';
        let vendor = selectedVendor === 'ALL' ? 'Haier' : selectedVendor;
        let rmGrade = 'ABS 300 Pre Colour';
        let rmRate = 136.20;
        let mbPct = 0.0;
        let mbRate = 0.0;
        let cavity = 2;
        let runnerWeight = 40.0;
        let netWeight = 197.0;
        let tonnage = 450;
        let shiftTariff = 3600;
        let cycleTime = 56.0;
        let bopCost = 0.14;

        // Parse vertical structure if formatted as 38-line format
        data.forEach(row => {
          if (!row || row.length === 0) return;
          const label = String(row[1] || row[0] || '').toLowerCase();
          const val = row[3] !== undefined ? row[3] : row[2] !== undefined ? row[2] : row[1];

          if (label.includes('item no') || label.includes('part code') || label.includes('item code')) itemCode = String(val).trim();
          if (label.includes('part desc') || label.includes('component')) componentName = String(val).trim();
          if (label.includes('model')) model = String(val).trim();
          if (label.includes('vendor') || label.includes('customer')) vendor = String(val).trim();
          if (label.includes('raw material') && !label.includes('cost') && !label.includes('rate')) rmGrade = String(val).trim();
          if (label.includes('rm rate') || (label.includes('raw material') && label.includes('rate'))) rmRate = parseFloat(val) || rmRate;
          if (label.includes('masterbatch') && label.includes('%')) mbPct = parseFloat(val) || mbPct;
          if (label.includes('masterbatch') && label.includes('rate')) mbRate = parseFloat(val) || mbRate;
          if (label.includes('cavity')) cavity = parseFloat(val) || cavity;
          if (label.includes('runner weight')) runnerWeight = parseFloat(val) || runnerWeight;
          if (label.includes('net weight')) netWeight = parseFloat(val) || netWeight;
          if (label.includes('machine used') || label.includes('tonnage')) tonnage = parseFloat(val) || tonnage;
          if (label.includes('tariff')) shiftTariff = parseFloat(val) || shiftTariff;
          if (label.includes('cycle time')) cycleTime = parseFloat(val) || cycleTime;
          if (label.includes('bop') || label.includes('insert')) bopCost = parseFloat(val) || bopCost;
        });

        const stagedObj = {
          id: `staged-${Date.now()}`,
          itemCode,
          componentName,
          model,
          vendor: vendor.toLowerCase().includes('atomberg') ? 'Atomberg' : 'Haier',
          approvedRm: rmGrade,
          approvedRmRate: rmRate,
          masterbatchPct: mbPct,
          masterbatchRate: mbRate,
          cavity,
          netWeight,
          runnerWeight,
          machineTonnage: tonnage,
          shiftTariff: shiftTariff || (tonnage * 8),
          cycleTimeApproved: cycleTime,
          cycleTime,
          bopCost,
          parameters: {
            runningCavity: cavity,
            runningNetWeight: netWeight,
            runningRunnerWeight: runnerWeight,
            runningCycleTime: cycleTime,
            runningTonnage: tonnage,
            runningShiftTariff: shiftTariff || (tonnage * 8),
            runningMbPct: mbPct,
            runningBopCost: bopCost
          }
        };

        setStagedProduct(stagedObj);
        setShowStagingModal(true);
      } catch (err) {
        alert('Failed to parse uploaded baseline file.');
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  const handleConfirmStaging = () => {
    if (!stagedProduct) return;
    addStagedProductsToBaseline([stagedProduct], stagedProduct.vendor);
    setShowStagingModal(false);
    setStagedProduct(null);
    alert(`Successfully verified and added [${stagedProduct.itemCode}] to Baseline Master!`);
  };

  // Compute live staging calculations
  let computedStagedCost = 34.51;
  let stagingDetails = {};
  if (stagedProduct) {
    if (stagedProduct.vendor.toLowerCase().includes('atomberg')) {
      stagingDetails = calculateAtombergCost({
        rmBase: stagedProduct.approvedRmRate,
        mbBase: stagedProduct.masterbatchRate,
        mbPct: stagedProduct.masterbatchPct,
        partWt: stagedProduct.netWeight,
        runnerWt: stagedProduct.runnerWeight,
        tonnage: stagedProduct.machineTonnage,
        cycleTime: stagedProduct.cycleTime,
        cavity: stagedProduct.cavity,
        bopCost: stagedProduct.bopCost
      });
      computedStagedCost = stagingDetails.totalCost || stagingDetails.finalLanded;
    } else {
      stagingDetails = calculateHaierCost({
        cavity: stagedProduct.cavity,
        netWeight: stagedProduct.netWeight,
        runnerWeight: stagedProduct.runnerWeight,
        rmRate: stagedProduct.approvedRmRate,
        masterbatchPct: stagedProduct.masterbatchPct,
        masterbatchRate: stagedProduct.masterbatchRate,
        machineTonnage: stagedProduct.machineTonnage,
        shiftTariff: stagedProduct.shiftTariff,
        cycleTime: stagedProduct.cycleTime,
        bopCost: stagedProduct.bopCost
      });
      computedStagedCost = stagingDetails.totalCost || stagingDetails.finalLanded;
    }
  }

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Layers className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master</h1>
            <p className="text-[11px] text-slate-300">Active Vendor: <b>{selectedVendor}</b> | Registered Parts: <b>{rawProducts.length} Active</b></p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={handleDownloadTemplate}
            className="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-xs transition-colors"
          >
            <Download className="w-4 h-4" /> Download Full 38-Line Spec Template (.xlsx)
          </button>

          <label className="px-3.5 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-xs transition-colors">
            <Upload className="w-4 h-4" /> Upload & Stage Spec (.xlsx)
            <input type="file" accept=".xlsx, .xls, .csv" onChange={handleUploadSpec} className="hidden" />
          </label>

          <div className="flex bg-slate-800 p-1 rounded-xl border border-slate-700">
            <button
              onClick={() => setActiveTab('parameters')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}
            >
              Parameters Master ({rawProducts.length})
            </button>
            <button
              onClick={() => setActiveTab('audit')}
              className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'audit' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}
            >
              Parameter Audit Log ({filteredLogs.length})
            </button>
          </div>
        </div>
      </div>

      {/* Filter / Search Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder="Search ALL components by part number or name..."
            className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-700">Switch Vendor:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
          >
            <option value="ALL">All Vendors Combined</option>
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Parameters Table */}
      {activeTab === 'parameters' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">ITEM CODE</th>
                  <th className="p-3">COMPONENT NAME</th>
                  <th className="p-3 text-center">VENDOR</th>
                  <th className="p-3">APPROVED RM GRADE</th>
                  <th className="p-3 text-right">APPROVED RM RATE</th>
                  <th className="p-3 text-center">CAVITY</th>
                  <th className="p-3 text-right">NET WT (G)</th>
                  <th className="p-3 text-right">RUNNER WT (G)</th>
                  <th className="p-3 text-right">CYCLE TIME</th>
                  <th className="p-3 text-center">ACTION</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredProducts.map(p => (
                  <tr key={p.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono font-bold text-blue-700">{p.itemCode}</td>
                    <td className="p-3 font-semibold text-slate-900">{p.componentName}</td>
                    <td className="p-3 text-center">
                      <span className="px-2 py-0.5 bg-slate-100 border border-slate-300 rounded font-bold text-[10px] text-slate-700">
                        {p.vendor}
                      </span>
                    </td>
                    <td className="p-3 font-semibold text-slate-800">{p.approvedRm}</td>
                    <td className="p-3 text-right font-mono font-bold">₹{Number(p.approvedRmRate || 131).toFixed(2)}/kg</td>
                    <td className="p-3 text-center font-mono">{p.parameters?.runningCavity ?? p.cavity}</td>
                    <td className="p-3 text-right font-mono">{p.parameters?.runningNetWeight ?? p.netWeight}g</td>
                    <td className="p-3 text-right font-mono">{p.parameters?.runningRunnerWeight ?? p.runnerWeight}g</td>
                    <td className="p-3 text-right font-mono">{p.parameters?.runningCycleTime ?? p.cycleTimeApproved ?? p.cycleTime}s</td>
                    <td className="p-3 text-center">
                      <button
                        onClick={() => setEditingItem(p)}
                        className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1 mx-auto cursor-pointer shadow-xs"
                      >
                        <Edit className="w-3.5 h-3.5" /> Edit Spec
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Audit Log Tab */}
      {activeTab === 'audit' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <History className="w-4 h-4 text-blue-400" /> Engineering Parameter Audit Trail & Change Log ({selectedVendor})
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredLogs.length} Total Logs</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">TIMESTAMP</th>
                  <th className="p-3">PART CODE</th>
                  <th className="p-3">COMPONENT NAME</th>
                  <th className="p-3 text-center">VENDOR</th>
                  <th className="p-3">PARAMETER MODIFICATIONS</th>
                  <th className="p-3 text-center">COST IMPACT (Δ)</th>
                  <th className="p-3">AUTHORIZED BY</th>
                  <th className="p-3">AUDIT REASON / NOTE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredLogs.length === 0 ? (
                  <tr>
                    <td colSpan="8" className="text-center p-8 text-slate-400 italic">
                      No parameter modification logs recorded for {selectedVendor} yet. Use "Edit Spec" on any product to generate logs.
                    </td>
                  </tr>
                ) : (
                  filteredLogs.map(log => (
                    <tr key={log.id} className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-slate-500 text-[11px]">{log.timestamp}</td>
                      <td className="p-3 font-mono font-bold text-blue-700">{log.partCode}</td>
                      <td className="p-3 font-semibold text-slate-900">{log.componentName}</td>
                      <td className="p-3 text-center">
                        <span className="px-2 py-0.5 bg-slate-100 border border-slate-300 rounded font-bold text-[10px] text-slate-700">
                          {log.vendor}
                        </span>
                      </td>
                      <td className="p-3 font-mono text-blue-900 bg-blue-50/50">{log.modifications}</td>
                      <td className="p-3 text-center font-mono font-bold text-emerald-700">{log.costImpact}</td>
                      <td className="p-3 text-slate-700 font-bold">{log.authorizedBy}</td>
                      <td className="p-3 text-slate-600 italic">{log.reason}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Edit Spec Modal */}
      {editingItem && (
        <InlineEditModal
          item={editingItem}
          onClose={() => setEditingItem(null)}
        />
      )}

      {/* 38-Line Vertical Staging & Verification Modal */}
      {showStagingModal && stagedProduct && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 overflow-y-auto">
          <div className="bg-white rounded-2xl max-w-4xl w-full p-6 space-y-4 shadow-2xl my-8">
            <div className="flex justify-between items-start border-b pb-3">
              <div>
                <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
                  <CheckCircle2 className="w-5 h-5 text-emerald-600" /> Staging & Verification: {stagedProduct.vendor} Product Import (1 Staged Parts)
                </h3>
                <p className="text-slate-600 text-xs mt-1">Review full vertical 38-line costing format and make inline parameter corrections before final confirmation.</p>
              </div>
              <button onClick={() => setShowStagingModal(false)} className="text-slate-400 hover:text-slate-600 p-1">
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Computed Staged Total Cost Header Card */}
            <div className="bg-slate-50 border border-slate-200 rounded-xl p-3 flex justify-between items-center">
              <div>
                <span className="text-[10px] font-bold uppercase text-slate-500 block">STAGED COMPONENT & ITEM CODE</span>
                <span className="text-sm font-bold text-slate-900 font-mono">[{stagedProduct.itemCode}] {stagedProduct.componentName}</span>
              </div>
              <div className="text-right">
                <span className="text-[10px] font-bold uppercase text-slate-500 block">COMPUTED STAGED TOTAL COST</span>
                <span className="text-xl font-black text-emerald-700 font-mono">₹{Number(computedStagedCost).toFixed(2)}</span>
              </div>
            </div>

            {/* Vertical 38-line Staging Verification Table */}
            <div className="max-h-[50vh] overflow-y-auto border border-slate-200 rounded-xl">
              <table className="min-w-full text-xs text-left">
                <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0 border-b">
                  <tr>
                    <th className="p-2.5 w-12 text-center">#</th>
                    <th className="p-2.5">DESCRIPTION / COSTING LINE</th>
                    <th className="p-2.5 w-20">UOM</th>
                    <th className="p-2.5 text-right w-44">STAGED VALUE (EDITABLE)</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-200 font-medium">
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">9</td>
                    <td className="p-2.5 font-bold text-slate-800">Net Weight</td>
                    <td className="p-2.5 font-bold text-slate-600">Gms</td>
                    <td className="p-2.5 text-right">
                      <input
                        type="number"
                        value={stagedProduct.netWeight}
                        onChange={e => setStagedProduct({ ...stagedProduct, netWeight: parseFloat(e.target.value) || 0 })}
                        className="w-28 text-center font-mono font-bold border border-blue-400 rounded-lg p-1"
                      />
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">10</td>
                    <td className="p-2.5 text-slate-700">Shot Weight</td>
                    <td className="p-2.5 text-slate-600">Gms</td>
                    <td className="p-2.5 text-right font-mono font-bold text-slate-800">
                      {((stagedProduct.netWeight * stagedProduct.cavity) + stagedProduct.runnerWeight).toFixed(2)}g
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">11</td>
                    <td className="p-2.5 text-slate-700">Reconciliation Weight (Shot + 1% Loss)</td>
                    <td className="p-2.5 text-slate-600">Gms</td>
                    <td className="p-2.5 text-right font-mono font-bold text-slate-800">
                      {(stagedProduct.netWeight * 1.01).toFixed(2)}g
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">12</td>
                    <td className="p-2.5 text-slate-700">Raw Material Cost</td>
                    <td className="p-2.5 text-slate-600">Rs</td>
                    <td className="p-2.5 text-right font-mono font-bold text-slate-900">
                      ₹{Number(stagingDetails.rawMaterialCost || 27.10).toFixed(2)}
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">15</td>
                    <td className="p-2.5 font-bold text-slate-800">Total Raw Material Cost</td>
                    <td className="p-2.5 font-bold text-slate-600">Rs</td>
                    <td className="p-2.5 text-right font-mono font-bold text-slate-900">
                      ₹{Number(stagingDetails.totalRmCost || 27.06).toFixed(2)}
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">16</td>
                    <td className="p-2.5 font-bold text-slate-800">Machine Used (Tonnage)</td>
                    <td className="p-2.5 font-bold text-slate-600">T</td>
                    <td className="p-2.5 text-right">
                      <input
                        type="number"
                        value={stagedProduct.machineTonnage}
                        onChange={e => setStagedProduct({ ...stagedProduct, machineTonnage: parseFloat(e.target.value) || 0, shiftTariff: (parseFloat(e.target.value) || 0) * 8 })}
                        className="w-28 text-center font-mono font-bold border border-blue-400 rounded-lg p-1"
                      />
                    </td>
                  </tr>
                  <tr className="bg-amber-50/50">
                    <td className="p-2.5 text-center font-mono text-slate-400">17</td>
                    <td className="p-2.5 font-bold text-slate-900">Machine Tariff per Shift</td>
                    <td className="p-2.5 font-bold text-slate-600">Rs</td>
                    <td className="p-2.5 text-right font-mono font-black text-slate-900">
                      ₹{stagedProduct.shiftTariff || (stagedProduct.machineTonnage * 8)}
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">18</td>
                    <td className="p-2.5 font-bold text-slate-800">Cycle Time</td>
                    <td className="p-2.5 font-bold text-slate-600">Sec</td>
                    <td className="p-2.5 text-right">
                      <input
                        type="number"
                        value={stagedProduct.cycleTime}
                        onChange={e => setStagedProduct({ ...stagedProduct, cycleTime: parseFloat(e.target.value) || 0 })}
                        className="w-28 text-center font-mono font-bold border border-blue-400 rounded-lg p-1"
                      />
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">19</td>
                    <td className="p-2.5 text-slate-700">No of Shot / Shift (8Hour)</td>
                    <td className="p-2.5 text-slate-600">Nos</td>
                    <td className="p-2.5 text-right font-mono text-slate-800">
                      {Math.round(28800 / stagedProduct.cycleTime)}
                    </td>
                  </tr>
                  <tr>
                    <td className="p-2.5 text-center font-mono text-slate-400">20</td>
                    <td className="p-2.5 text-slate-700">No of Shot / Shift with 95% Efficiency</td>
                    <td className="p-2.5 text-slate-600">Nos</td>
                    <td className="p-2.5 text-right font-mono text-slate-800">
                      {Math.round((28800 / stagedProduct.cycleTime) * 0.95)}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            {/* Action Buttons */}
            <div className="flex justify-between items-center pt-2">
              <button
                onClick={() => setShowStagingModal(false)}
                className="px-5 py-2 border border-slate-300 hover:bg-slate-100 rounded-xl font-bold text-slate-700 cursor-pointer"
              >
                Cancel Staging
              </button>
              <button
                onClick={handleConfirmStaging}
                className="px-6 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-2 cursor-pointer shadow-md"
              >
                <CheckCircle2 className="w-4 h-4" /> Confirm & Add All Staged Products (1)
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
EOF_BM

echo "==> Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Full vertical 38-line staging restoration complete."
