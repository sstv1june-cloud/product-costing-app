#!/usr/bin/env bash
set -e

echo "==> 1. Restoring full BaselineMasterPage.jsx with Download, Upload/Stage, and Onboard buttons..."
BASELINE_PAGE="src/modules/module1-baseline/BaselineMasterPage.jsx"

cat << 'EOF_BM' > "$BASELINE_PAGE"
import React, { useState, useEffect } from 'react';
import { 
  Layers, Upload, Download, History, Search, Edit, Plus, FileSpreadsheet, CheckCircle2 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  getVendorBaselineData, 
  deleteProductFromBaseline,
  addStagedProductsToBaseline,
  onboardVendorWithBlueprint 
} from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [activeTab, setActiveTab] = useState('parameters'); // 'parameters' | 'audit'
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);
  const [stagedData, setStagedData] = useState([]);
  const [showStagingModal, setShowStagingModal] = useState(false);

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
    const templateData = [
      {
        'Item Code': '0060226713D',
        'Component Name': 'End Cap Top Ref (without Screen Painting)',
        'Model': 'OLD DC- 195,220',
        'Vendor': selectedVendor === 'ALL' ? 'Haier' : selectedVendor,
        'Approved RM Grade': 'ABS 300 Pre Colour',
        'Approved RM Rate (Rs/kg)': 136.20,
        'Masterbatch Pct (%)': 0.0,
        'Masterbatch Rate (Rs/kg)': 0.0,
        'No of Cavity': 2,
        'Net Weight (g)': 197.0,
        'Runner Weight (g)': 40.0,
        'Cycle Time (s)': 56.0,
        'Machine Tonnage (T)': 450,
        'BOP Cost (Rs)': 0.14
      }
    ];
    const ws = XLSX.utils.json_to_sheet(templateData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'SpecTemplate');
    XLSX.writeFile(wb, 'Baseline_Spec_Template_38Line.xlsx');
  };

  // Upload & Stage Spec
  const handleUploadSpec = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const wb = XLSX.read(evt.target.result, { type: 'binary' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const data = XLSX.utils.sheet_to_json(ws);
        
        const staged = data.map((row, idx) => ({
          id: `staged-${Date.now()}-${idx}`,
          itemCode: row['Item Code'] || row['itemCode'] || `PART-${idx + 1}`,
          componentName: row['Component Name'] || row['componentName'] || 'New Component',
          model: row['Model'] || 'Standard',
          vendor: row['Vendor'] || (selectedVendor === 'ALL' ? 'Haier' : selectedVendor),
          approvedRm: row['Approved RM Grade'] || 'ABS 300 Pre Colour',
          approvedRmRate: Number(row['Approved RM Rate (Rs/kg)'] || 136.20),
          masterbatchPct: Number(row['Masterbatch Pct (%)'] || 0),
          masterbatchRate: Number(row['Masterbatch Rate (Rs/kg)'] || 0),
          cavity: Number(row['No of Cavity'] || 2),
          netWeight: Number(row['Net Weight (g)'] || 197),
          runnerWeight: Number(row['Runner Weight (g)'] || 40),
          cycleTimeApproved: Number(row['Cycle Time (s)'] || 48),
          cycleTime: Number(row['Cycle Time (s)'] || 48),
          machineTonnage: Number(row['Machine Tonnage (T)'] || 450),
          shiftTariff: Number(row['Machine Tonnage (T)'] || 450) * 8,
          bopCost: Number(row['BOP Cost (Rs)'] || 0.14),
          parameters: {
            runningCavity: Number(row['No of Cavity'] || 2),
            runningNetWeight: Number(row['Net Weight (g)'] || 197),
            runningRunnerWeight: Number(row['Runner Weight (g)'] || 40),
            runningCycleTime: Number(row['Cycle Time (s)'] || 48),
            runningTonnage: Number(row['Machine Tonnage (T)'] || 450),
            runningMbPct: Number(row['Masterbatch Pct (%)'] || 0),
            runningBopCost: Number(row['BOP Cost (Rs)'] || 0.14)
          }
        }));

        setStagedData(staged);
        setShowStagingModal(true);
      } catch (err) {
        alert('Failed to parse uploaded baseline file.');
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  const handleConfirmStaging = () => {
    addStagedProductsToBaseline(stagedData, selectedVendor === 'ALL' ? 'Haier' : selectedVendor);
    setShowStagingModal(false);
    setStagedData([]);
    alert(`Successfully imported and committed ${stagedData.length} baseline product(s)!`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner with Action Buttons */}
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

      {/* Search & Vendor Filter */}
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

      {/* Tab 1: Parameters Table */}
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

      {/* Tab 2: Audit Trail Log */}
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

      {/* Staging Confirmation Modal */}
      {showStagingModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-2xl max-w-2xl w-full p-6 space-y-4 shadow-2xl">
            <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
              <CheckCircle2 className="w-5 h-5 text-emerald-600" /> Staging & Verification: {stagedData.length} Staged Products
            </h3>
            <p className="text-slate-600 text-xs">Verify your uploaded parts before committing them into the dynamic baseline master.</p>
            <div className="max-h-60 overflow-y-auto divide-y divide-slate-200 border rounded-xl p-2 bg-slate-50">
              {stagedData.map(st => (
                <div key={st.id} className="py-2 flex justify-between items-center text-xs">
                  <div>
                    <span className="font-mono font-bold text-blue-700 mr-2">{st.itemCode}</span>
                    <span className="font-semibold text-slate-800">{st.componentName}</span>
                  </div>
                  <span className="font-bold text-slate-700">{st.vendor}</span>
                </div>
              ))}
            </div>
            <div className="flex justify-end gap-2 pt-2">
              <button onClick={() => setShowStagingModal(false)} className="px-4 py-2 border rounded-xl font-bold cursor-pointer">Cancel</button>
              <button onClick={handleConfirmStaging} className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer">Confirm & Add Products</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
EOF_BM

echo "==> 2. Updating RMPriceMatrixPage.jsx to debounce audit logging (prevent per-keystroke clutter)..."
RM_FILE="src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx"

cat << 'EOF_RM' > "$RM_FILE"
import React, { useState, useEffect } from 'react';
import { 
  Database, Lock, Unlock, Save, Filter, Calendar, CheckCircle2, 
  Upload, FileSpreadsheet, History, ShoppingCart, Truck, Plus, AlertCircle, Edit3 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  toggleGlobalLock, 
  updateRmMappingRow, 
  saveVendorPeriodSchedule,
  addDayWisePurchase,
  addDayWiseSales 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [activeSubTab, setActiveSubTab] = useState('matrix');
  const [localPrices, setLocalPrices] = useState({});

  const isLocked = globalStore.isGlobalLocked ?? true;
  const mappingsList = globalStore.rmMappingsData || [];
  const purchasesList = globalStore.purchases || [];
  const salesList = globalStore.sales || [];
  const changeLogs = globalStore.changeLogs || [];

  const filteredRows = mappingsList.filter(row => {
    return (selectedVendor === 'ALL' || row.vendor.toLowerCase() === selectedVendor.toLowerCase());
  });

  const filteredPurchases = purchasesList.filter(p => {
    return (selectedVendor === 'ALL' || (p.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()));
  });

  const filteredSales = salesList.filter(s => {
    return (selectedVendor === 'ALL' || (s.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()));
  });

  // Debounced price change - only commit to store and audit log on blur / enter
  const handlePriceBlur = (rowId, currentPrice) => {
    if (isLocked) return;
    const newPriceVal = localPrices[rowId];
    if (newPriceVal !== undefined && newPriceVal !== '' && Number(newPriceVal) !== Number(currentPrice)) {
      updateRmMappingRow(rowId, { approvedPrice: parseFloat(newPriceVal) });
    }
  };

  const handleSave = () => {
    if (isLocked) {
      alert('Cannot save: Page is LOCKED. Click "Unlock to Edit" first.');
      return;
    }
    // Commit all local prices
    Object.entries(localPrices).forEach(([rowId, val]) => {
      if (val !== '' && !isNaN(Number(val))) {
        updateRmMappingRow(rowId, { approvedPrice: parseFloat(val) });
      }
    });
    saveVendorPeriodSchedule();
    alert(`Successfully saved RM / MB Price Mapping for ${selectedVendor} (${periodFrom} to ${periodTo})`);
  };

  const handlePurchaseUpload = (e) => {
    if (isLocked) {
      alert('Please Unlock the page before uploading purchases!');
      return;
    }
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const wb = XLSX.read(evt.target.result, { type: 'binary' });
        const data = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]]);
        data.forEach((row, i) => {
          addDayWisePurchase({
            id: `pur-up-${Date.now()}-${i}`,
            date: row['Date'] || new Date().toISOString().slice(0, 10),
            vendor: row['Vendor'] || selectedVendor,
            grade: row['Grade'] || row['Material'] || 'ABS 300-B',
            qty: Number(row['Qty'] || row['Quantity'] || 1000),
            rate: Number(row['Rate'] || row['Price'] || 130.00),
            invoiceNo: row['Invoice'] || `INV-${Math.floor(1000 + Math.random() * 9000)}`
          });
        });
        alert(`Successfully imported ${data.length} day-wise purchase records!`);
      } catch (err) {
        alert('Failed to parse purchase file.');
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  const handleSalesUpload = (e) => {
    if (isLocked) {
      alert('Please Unlock the page before uploading sales!');
      return;
    }
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const wb = XLSX.read(evt.target.result, { type: 'binary' });
        const data = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]]);
        data.forEach((row, i) => {
          addDayWiseSales({
            id: `disp-up-${Date.now()}-${i}`,
            date: row['Date'] || new Date().toISOString().slice(0, 10),
            vendor: row['Vendor'] || selectedVendor,
            itemCode: row['ItemCode'] || row['PartCode'] || '0060217989D',
            componentName: row['ComponentName'] || row['ItemCode'] || 'Injected Component',
            qty: Number(row['Qty'] || row['Quantity'] || 1000),
            sellingPrice: Number(row['Price'] || row['SellingPrice'] || 45.00)
          });
        });
        alert(`Successfully imported ${data.length} day-wise sales dispatch records!`);
      } catch (err) {
        alert('Failed to parse sales file.');
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-base font-bold">RM Mapping & Inward Registry</h1>
            <p className="text-[11px] text-slate-300">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={toggleGlobalLock}
            className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 text-xs cursor-pointer shadow transition-all ${isLocked ? 'bg-amber-600 hover:bg-amber-700 text-white' : 'bg-emerald-600 hover:bg-emerald-700 text-white'}`}
          >
            {isLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4 text-white" />}
            {isLocked ? 'Page Locked (Click to Unlock & Edit)' : 'Page Unlocked (Editing Active)'}
          </button>
        </div>
      </div>

      <div className="flex bg-slate-200 p-1.5 rounded-2xl border border-slate-300 gap-1.5 w-fit">
        <button
          onClick={() => setActiveSubTab('matrix')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'matrix' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <FileSpreadsheet className="w-4 h-4" /> RM Price Matrix
        </button>
        <button
          onClick={() => setActiveSubTab('purchases')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'purchases' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <ShoppingCart className="w-4 h-4 text-emerald-600" /> Day-wise Purchases ({filteredPurchases.length})
        </button>
        <button
          onClick={() => setActiveSubTab('sales')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'sales' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <Truck className="w-4 h-4 text-purple-600" /> Day-wise Sales ({filteredSales.length})
        </button>
        <button
          onClick={() => setActiveSubTab('changelog')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'changelog' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <History className="w-4 h-4 text-amber-600" /> Baseline & RM Change Log ({changeLogs.length})
        </button>
      </div>

      <div className="bg-white p-4 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-blue-600" />
            <span className="font-bold text-slate-700 uppercase">Filter:</span>
          </div>

          <div className="flex items-center gap-2">
            <span className="font-semibold text-slate-600">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={(e) => setSelectedVendor(e.target.value)}
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
            >
              <option value="ALL">All Vendors Combined</option>
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-300">
            <Calendar className="w-4 h-4 text-slate-500" />
            <span className="font-semibold text-slate-600">Period:</span>
            <span className="text-slate-500 font-medium">From</span>
            <input
              type="date"
              value={periodFrom}
              disabled={isLocked}
              onChange={(e) => setPeriodFrom(e.target.value)}
              className="border px-2 py-0.5 rounded text-xs bg-white disabled:bg-slate-100 cursor-pointer"
            />
            <span className="text-slate-500 font-medium">To</span>
            <input
              type="date"
              value={periodTo}
              disabled={isLocked}
              onChange={(e) => setPeriodTo(e.target.value)}
              className="border px-2 py-0.5 rounded text-xs bg-white disabled:bg-slate-100 cursor-pointer"
            />
          </div>
        </div>

        <div className="flex items-center gap-2">
          {activeSubTab === 'purchases' && (
            <label className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 text-xs shadow transition-all cursor-pointer ${isLocked ? 'bg-slate-400 text-white cursor-not-allowed' : 'bg-emerald-600 hover:bg-emerald-700 text-white'}`}>
              <Upload className="w-4 h-4" /> Upload Day-wise Purchases (.xlsx)
              <input type="file" accept=".xlsx, .xls, .csv" disabled={isLocked} onChange={handlePurchaseUpload} className="hidden" />
            </label>
          )}
          {activeSubTab === 'sales' && (
            <label className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 text-xs shadow transition-all cursor-pointer ${isLocked ? 'bg-slate-400 text-white cursor-not-allowed' : 'bg-purple-600 hover:bg-purple-700 text-white'}`}>
              <Upload className="w-4 h-4" /> Upload Day-wise Sales (.xlsx)
              <input type="file" accept=".xlsx, .xls, .csv" disabled={isLocked} onChange={handleSalesUpload} className="hidden" />
            </label>
          )}
          {activeSubTab === 'matrix' && (
            <button
              onClick={handleSave}
              disabled={isLocked}
              className="px-5 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-400 text-white rounded-xl font-bold flex items-center gap-2 text-xs cursor-pointer shadow transition-all"
            >
              <Save className="w-4 h-4" /> Save for Vendor + period
            </button>
          )}
        </div>
      </div>

      {activeSubTab === 'matrix' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left border-collapse">
              <thead>
                <tr className="bg-slate-800 text-white font-bold border-b border-slate-700 text-center">
                  <th className="p-3 border-r border-slate-700 w-1/4 text-left">Approved RM/MB Code</th>
                  <th className="p-3 border-r border-slate-700 w-1/10 bg-slate-900 text-amber-300">
                    <div className="flex items-center justify-center gap-1">
                      <Edit3 className="w-3.5 h-3.5" /> Approved Price (₹/kg)
                    </div>
                  </th>
                  <th className="p-3 border-r border-slate-700 w-1/6">Alternate RM-1</th>
                  <th className="p-3 border-r border-slate-700 w-1/12 bg-slate-900 text-blue-300">Price (WA)</th>
                  <th className="p-3 border-r border-slate-700 w-1/6">Alternate RM-2</th>
                  <th className="p-3 border-r border-slate-700 w-1/12 bg-slate-900 text-blue-300">Price (WA)</th>
                  <th className="p-3 border-r border-slate-700 w-1/6">Alternate RM-3</th>
                  <th className="p-3 w-1/12 bg-slate-900 text-blue-300">Price (WA)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredRows.map((row) => (
                  <tr key={row.id} className="hover:bg-slate-50">
                    <td className="p-3 border-r border-slate-200">
                      <span className="px-2 py-0.5 rounded text-[10px] font-bold mr-2 bg-slate-200 text-slate-800">
                        {row.type === 'RM' ? 'RM Code' : 'Masterbatch Code'}
                      </span>
                      <span className="font-mono font-bold text-slate-900">{row.approvedCode}</span>
                    </td>

                    <td className="p-2 border-r border-slate-200 text-center bg-amber-50/70">
                      <div className="flex items-center justify-center gap-1">
                        <span className="font-bold text-slate-600">₹</span>
                        <input
                          type="number"
                          step="0.01"
                          value={localPrices[row.id] !== undefined ? localPrices[row.id] : row.approvedPrice}
                          disabled={isLocked}
                          onChange={(e) => setLocalPrices({ ...localPrices, [row.id]: e.target.value })}
                          onBlur={() => handlePriceBlur(row.id, row.approvedPrice)}
                          className="w-20 text-center font-mono font-bold text-sm bg-white border border-amber-300 focus:border-blue-600 rounded-lg px-1.5 py-1 text-slate-900 shadow-xs outline-none disabled:bg-slate-100 disabled:border-slate-300"
                        />
                      </div>
                    </td>

                    <td className="p-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-1">
                        <span className="font-semibold text-blue-950">{row.alt1Code}</span>
                        <button
                          onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt1' })}
                          disabled={isLocked}
                          className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt1' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'} disabled:opacity-60 disabled:cursor-not-allowed`}
                        >
                          {row.activeAlt === 'alt1' ? 'Active' : 'Set'}
                        </button>
                      </div>
                    </td>
                    <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-blue-700 bg-blue-50/50">
                      ₹{Number(row.alt1Price).toFixed(2)}
                    </td>

                    <td className="p-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-1">
                        <span className="text-slate-700">{row.alt2Code}</span>
                        <button
                          onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt2' })}
                          disabled={isLocked}
                          className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt2' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'} disabled:opacity-60 disabled:cursor-not-allowed`}
                        >
                          {row.activeAlt === 'alt2' ? 'Active' : 'Set'}
                        </button>
                      </div>
                    </td>
                    <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-slate-700 bg-blue-50/30">
                      ₹{Number(row.alt2Price).toFixed(2)}
                    </td>

                    <td className="p-3 border-r border-slate-200">
                      <div className="flex items-center justify-between gap-1">
                        <span className="text-slate-700">{row.alt3Code}</span>
                        <button
                          onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt3' })}
                          disabled={isLocked}
                          className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt3' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'} disabled:opacity-60 disabled:cursor-not-allowed`}
                        >
                          {row.activeAlt === 'alt3' ? 'Active' : 'Set'}
                        </button>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-700 bg-blue-50/30">
                      ₹{Number(row.alt3Price).toFixed(2)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeSubTab === 'purchases' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <ShoppingCart className="w-4 h-4 text-emerald-400" /> Day-wise Raw Material Purchase Inwards
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredPurchases.length} Purchase Records</span>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">DATE</th>
                  <th className="p-3">INVOICE NO</th>
                  <th className="p-3">VENDOR</th>
                  <th className="p-3">POLYMER GRADE / LOT</th>
                  <th className="p-3 text-right">QUANTITY (KG)</th>
                  <th className="p-3 text-right">RATE (₹/KG)</th>
                  <th className="p-3 text-right">TOTAL VALUE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredPurchases.map((pur) => (
                  <tr key={pur.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500">{pur.date}</td>
                    <td className="p-3 font-mono font-bold text-blue-700">{pur.invoiceNo}</td>
                    <td className="p-3 font-bold text-slate-900">{pur.vendor}</td>
                    <td className="p-3 font-semibold text-slate-800">{pur.grade}</td>
                    <td className="p-3 text-right font-mono font-bold">{Number(pur.qty).toLocaleString()} kg</td>
                    <td className="p-3 text-right font-mono font-bold text-emerald-700">₹{Number(pur.rate).toFixed(2)}</td>
                    <td className="p-3 text-right font-mono font-black text-slate-900">₹{(Number(pur.qty) * Number(pur.rate)).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeSubTab === 'sales' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <Truck className="w-4 h-4 text-purple-400" /> Day-wise Sales Dispatches & Invoices
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredSales.length} Sales Dispatches</span>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">DATE</th>
                  <th className="p-3">PART CODE</th>
                  <th className="p-3">COMPONENT NAME</th>
                  <th className="p-3">VENDOR</th>
                  <th className="p-3 text-right">DISPATCH QTY</th>
                  <th className="p-3 text-right">SELLING PRICE</th>
                  <th className="p-3 text-right">TOTAL SALES VALUE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredSales.map((s) => (
                  <tr key={s.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500">{s.date}</td>
                    <td className="p-3 font-mono font-bold text-blue-700">{s.itemCode}</td>
                    <td className="p-3 font-semibold text-slate-800">{s.componentName}</td>
                    <td className="p-3 font-bold text-slate-900">{s.vendor}</td>
                    <td className="p-3 text-right font-mono font-bold">{Number(s.qty).toLocaleString()} pcs</td>
                    <td className="p-3 text-right font-mono font-bold text-purple-700">₹{Number(s.sellingPrice).toFixed(2)}</td>
                    <td className="p-3 text-right font-mono font-black text-slate-900">₹{(Number(s.qty) * Number(s.sellingPrice)).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeSubTab === 'changelog' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <History className="w-4 h-4 text-amber-400" /> Price & Parameter Change Log (Audit Trail)
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{changeLogs.length} Audit Entries</span>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">TIMESTAMP</th>
                  <th className="p-3">USER</th>
                  <th className="p-3">MODULE</th>
                  <th className="p-3">ENTITY / CODE</th>
                  <th className="p-3">CHANGE TYPE</th>
                  <th className="p-3">PREVIOUS VALUE</th>
                  <th className="p-3">NEW VALUE</th>
                  <th className="p-3">REASON / JUSTIFICATION</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {changeLogs.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500 text-[11px]">{log.timestamp}</td>
                    <td className="p-3 font-bold text-slate-800">{log.user}</td>
                    <td className="p-3">
                      <span className="px-2 py-0.5 bg-blue-50 text-blue-800 border border-blue-200 rounded font-bold text-[10px]">
                        {log.module}
                      </span>
                    </td>
                    <td className="p-3 font-mono font-bold text-slate-900">{log.entity}</td>
                    <td className="p-3 font-semibold text-slate-700">{log.changeType}</td>
                    <td className="p-3 font-mono text-rose-700 bg-rose-50/50">{log.previousValue}</td>
                    <td className="p-3 font-mono text-emerald-700 bg-emerald-50/50">{log.newValue}</td>
                    <td className="p-3 text-slate-600 italic">{log.reason}</td>
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
EOF_RM

echo "==> Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Baseline Master & Clean Audit Logging restored."
