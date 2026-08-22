#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js to support adding vendor materials and dynamic registration..."
cat << 'STORE_EOF' > patch_store_helpers.py
with open("src/shared/masterStore.js", "r") as f:
    content = f.read()

helper_code = """
// Helper to add or update vendor material in RM Master Matrix
export function addOrUpdateVendorMaterial({ vendor, type, approvedCode, approvedPrice }) {
  if (!approvedCode || !vendor) return;
  if (!globalStore.rmMappingsData) globalStore.rmMappingsData = [];

  const vClean = vendor.toLowerCase().trim();
  const cClean = approvedCode.toLowerCase().trim();

  const existingIdx = globalStore.rmMappingsData.findIndex(r => 
    r.vendor.toLowerCase().trim() === vClean && 
    r.type === type && 
    r.approvedCode.toLowerCase().trim() === cClean
  );

  if (existingIdx >= 0) {
    globalStore.rmMappingsData[existingIdx].approvedPrice = Number(approvedPrice || 0);
  } else {
    globalStore.rmMappingsData.push({
      id: `mat-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
      vendor,
      type: type || 'RM',
      approvedCode,
      approvedPrice: Number(approvedPrice || 0),
      activeAlt: 'alt1',
      alt1Code: approvedCode,
      alt1Price: Number(approvedPrice || 0),
      alt2Code: '',
      alt2Price: 0,
      alt3Code: '',
      alt3Price: 0
    });
  }

  addAuditLog({
    partCode: approvedCode,
    componentName: `${type} Material Master Entry (${vendor})`,
    vendor,
    modifications: `Approved Base Price: ₹${Number(approvedPrice || 0).toFixed(2)}/kg`,
    costImpact: `₹${Number(approvedPrice || 0).toFixed(2)}/kg`,
    reason: 'Vendor RM/MB Master Registration'
  });

  notifyStore();
}
"""

if "addOrUpdateVendorMaterial" not in content:
    content += helper_code
    with open("src/shared/masterStore.js", "w") as f:
        f.write(content)
    print("masterStore.js patched with addOrUpdateVendorMaterial!")
else:
    print("masterStore.js already has addOrUpdateVendorMaterial.")
STORE_EOF
python3 patch_store_helpers.py

echo "==> 2. Updating RMPriceMatrixPage.jsx with Add Vendor RM modal, Bulk Uploads & Template Downloads..."
cat << 'PAGE_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Plus, 
  Trash2, 
  Save, 
  Lock, 
  Unlock, 
  Search, 
  Filter, 
  TrendingUp, 
  Layers, 
  Upload, 
  Download,
  AlertCircle,
  CheckCircle2,
  PackagePlus,
  Table,
  ShoppingCart,
  TrendingDown,
  History,
  X,
  FileSpreadsheet
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { 
  globalStore, 
  subscribeStore, 
  updateRmMappingRow, 
  addDayWisePurchase, 
  addDayWiseSales, 
  toggleGlobalLock,
  saveVendorPeriodSchedule,
  addOrUpdateVendorMaterial
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('Haier Appliances');
  const [activeSubTab, setActiveSubTab] = useState('matrix'); // 'matrix' | 'purchases' | 'sales' | 'audit'
  const [searchQuery, setSearchQuery] = useState('');
  const [periodStart, setPeriodStart] = useState('2026-08-01');
  const [periodEnd, setPeriodEnd] = useState('2026-08-31');

  // Add Vendor RM/MB Modal
  const [showAddMatModal, setShowAddMatModal] = useState(false);
  const [newMatType, setNewMatType] = useState('RM');
  const [newMatCode, setNewMatCode] = useState('');
  const [newMatApprovedPrice, setNewMatApprovedPrice] = useState('');

  // Single Inward Purchase Form
  const [newPurchaseDate, setNewPurchaseDate] = useState('2026-08-15');
  const [newPurchaseGrade, setNewPurchaseGrade] = useState('');
  const [newPurchaseQty, setNewPurchaseQty] = useState('');
  const [newPurchaseRate, setNewPurchaseRate] = useState('');
  const [newPurchaseInvoice, setNewPurchaseInvoice] = useState('');

  // Single Sales Form
  const [newSaleDate, setNewSaleDate] = useState('2026-08-15');
  const [newSaleItemCode, setNewSaleItemCode] = useState('');
  const [newSaleCompName, setNewSaleCompName] = useState('');
  const [newSaleQty, setNewSaleQty] = useState('');
  const [newSalePrice, setNewSalePrice] = useState('');

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

  // Match vendor cleanly
  const filteredMaterials = (storeState.rmMappingsData || []).filter(r => {
    const vMatch = (r.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
                   selectedVendor.toLowerCase().includes((r.vendor || '').toLowerCase());
    const qMatch = (r.approvedCode || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
                   (r.type || '').toLowerCase().includes(searchQuery.toLowerCase());
    return vMatch && qMatch;
  });

  const vendorPurchases = (storeState.purchases || []).filter(p => 
    (p.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((p.vendor || '').toLowerCase())
  );

  const vendorSales = (storeState.sales || []).filter(s => 
    (s.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((s.vendor || '').toLowerCase())
  );

  const vendorLogs = (storeState.auditLogs || []).filter(l => 
    (l.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((l.vendor || '').toLowerCase()) ||
    l.vendor === 'ALL'
  );

  // Dynamic unique list of purchase grades for alternate selection
  const purchaseGradeOptions = Array.from(new Set(vendorPurchases.map(p => p.grade).filter(Boolean)));

  // Add Material Handler
  const handleAddNewMaterial = (e) => {
    e.preventDefault();
    if (!newMatCode || !newMatApprovedPrice) {
      alert("Please provide both Material Code and Approved Base Price.");
      return;
    }

    addOrUpdateVendorMaterial({
      vendor: selectedVendor,
      type: newMatType,
      approvedCode: newMatCode.trim(),
      approvedPrice: Number(newMatApprovedPrice)
    });

    setNewMatCode('');
    setNewMatApprovedPrice('');
    setShowAddMatModal(false);
  };

  // Add Single Purchase Handler
  const handleAddPurchase = (e) => {
    e.preventDefault();
    if (!newPurchaseGrade || !newPurchaseQty || !newPurchaseRate) {
      alert("Please fill Date, Grade, Qty, and Purchase Rate.");
      return;
    }

    addDayWisePurchase({
      date: newPurchaseDate,
      vendor: selectedVendor,
      invoiceNo: newPurchaseInvoice || `INV-${Math.floor(1000 + Math.random() * 9000)}`,
      grade: newPurchaseGrade.trim(),
      qty: Number(newPurchaseQty),
      rate: Number(newPurchaseRate)
    });

    setNewPurchaseGrade('');
    setNewPurchaseQty('');
    setNewPurchaseRate('');
    setNewPurchaseInvoice('');
  };

  // Add Single Sales Handler
  const handleAddSale = (e) => {
    e.preventDefault();
    if (!newSaleItemCode || !newSaleQty) {
      alert("Please fill Date, Item Code, and Dispatch Qty.");
      return;
    }

    addDayWiseSales({
      date: newSaleDate,
      vendor: selectedVendor,
      itemCode: newSaleItemCode.trim(),
      componentName: newSaleCompName.trim() || 'Dispatched Component',
      qty: Number(newSaleQty),
      sellingPrice: newSalePrice ? Number(newSalePrice) : 0
    });

    setNewSaleItemCode('');
    setNewSaleCompName('');
    setNewSaleQty('');
    setNewSalePrice('');
  };

  // Download Purchase Template (.xlsx)
  const downloadPurchaseTemplate = () => {
    const aoa = [
      ["Date", "Vendor", "Invoice #", "Grade", "Inward Qty (kg)", "Purchase Rate (₹/kg)"],
      ["2026-08-01", selectedVendor, "INV-001", "PP H110MA Prime Inward", 5000, 134.50],
      ["2026-08-05", selectedVendor, "INV-002", "White MB Grade A", 300, 258.00],
      ["2026-08-10", selectedVendor, "INV-003", "HIPS-SH03 Prime Lot", 4000, 156.00]
    ];
    const ws = XLSX.utils.aoa_to_sheet(aoa);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Purchase_Inward_Template");
    XLSX.writeFile(wb, `${selectedVendor.replace(/\s+/g, '_')}_Purchase_Inward_Template.xlsx`);
  };

  // Download Sales Template (.xlsx)
  const downloadSalesTemplate = () => {
    const aoa = [
      ["Date", "Vendor", "Item Code", "Component Name", "Dispatch Qty", "Selling Price (₹)"],
      ["2026-08-01", selectedVendor, "A1017031_tt2", "Aris Top Canopy- Gloss Black", 2500, 15.96],
      ["2026-08-05", selectedVendor, "0060217989D", "End cap Bottom Ref-ABS-DC-195,220", 3000, 42.00]
    ];
    const ws = XLSX.utils.aoa_to_sheet(aoa);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Sales_Dispatch_Template");
    XLSX.writeFile(wb, `${selectedVendor.replace(/\s+/g, '_')}_Sales_Dispatch_Template.xlsx`);
  };

  // Bulk Purchase Upload
  const handlePurchaseFileUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const bstr = evt.target.result;
        const wb = XLSX.read(bstr, { type: 'binary' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const data = XLSX.utils.sheet_to_json(ws);

        let count = 0;
        data.forEach(row => {
          const grade = row['Grade'] || row['RM Grade'] || row['Material'] || row['Item'];
          const qty = Number(row['Inward Qty (kg)'] || row['Qty'] || row['Quantity'] || 0);
          const rate = Number(row['Purchase Rate (₹/kg)'] || row['Rate'] || row['Price'] || 0);
          const invoiceNo = row['Invoice #'] || row['Invoice No'] || row['Inv No'];
          const date = row['Date'] || newPurchaseDate;
          const vendor = row['Vendor'] || selectedVendor;

          if (grade && qty > 0 && rate > 0) {
            addDayWisePurchase({
              date,
              vendor,
              invoiceNo: invoiceNo || `INV-BULK-${count + 1}`,
              grade: grade.toString().trim(),
              qty,
              rate
            });
            count++;
          }
        });
        alert(`Successfully imported ${count} purchase records for ${selectedVendor}!`);
      } catch (err) {
        console.error(err);
        alert("Error parsing purchase Excel file.");
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
  };

  // Bulk Sales Upload
  const handleSalesFileUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const bstr = evt.target.result;
        const wb = XLSX.read(bstr, { type: 'binary' });
        const ws = wb.Sheets[wb.SheetNames[0]];
        const data = XLSX.utils.sheet_to_json(ws);

        let count = 0;
        data.forEach(row => {
          const itemCode = row['Item Code'] || row['Part Code'] || row['Product Code'];
          const compName = row['Component Name'] || row['Description'] || 'Dispatched Component';
          const qty = Number(row['Dispatch Qty'] || row['Qty'] || row['Quantity'] || 0);
          const sellingPrice = Number(row['Selling Price (₹)'] || row['Price'] || 0);
          const date = row['Date'] || newSaleDate;
          const vendor = row['Vendor'] || selectedVendor;

          if (itemCode && qty > 0) {
            addDayWiseSales({
              date,
              vendor,
              itemCode: itemCode.toString().trim(),
              componentName: compName.toString().trim(),
              qty,
              sellingPrice
            });
            count++;
          }
        });
        alert(`Successfully imported ${count} sales dispatch records for ${selectedVendor}!`);
      } catch (err) {
        console.error(err);
        alert("Error parsing sales Excel file.");
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = null;
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
            <h1 className="text-sm font-bold">RM Mapping & Inward Registry</h1>
            <p className="text-[11px] text-slate-300">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowAddMatModal(true)}
            className="px-3.5 py-1.5 bg-purple-600 hover:bg-purple-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm text-xs"
          >
            <PackagePlus className="w-4 h-4" /> + Add Vendor RM / MB
          </button>

          <button
            onClick={toggleGlobalLock}
            className={`flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl font-bold text-xs cursor-pointer transition-all ${
              storeState.isLocked 
                ? 'bg-amber-500 hover:bg-amber-600 text-white shadow-md' 
                : 'bg-emerald-600 hover:bg-emerald-700 text-white shadow-md'
            }`}
          >
            {storeState.isLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4" />}
            {storeState.isLocked ? 'Page Locked (Click to Unlock & Edit)' : 'Page Unlocked (Editing Active)'}
          </button>
        </div>
      </div>

      {/* Sub-Tabs Navigation */}
      <div className="flex items-center gap-2">
        <button
          onClick={() => setActiveSubTab('matrix')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl font-bold cursor-pointer transition-all ${
            activeSubTab === 'matrix' ? 'bg-blue-600 text-white shadow-md' : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
          }`}
        >
          <Table className="w-4 h-4" /> RM Price Matrix
        </button>

        <button
          onClick={() => setActiveSubTab('purchases')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl font-bold cursor-pointer transition-all ${
            activeSubTab === 'purchases' ? 'bg-blue-600 text-white shadow-md' : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
          }`}
        >
          <ShoppingCart className="w-4 h-4" /> Day-wise Purchases ({vendorPurchases.length})
        </button>

        <button
          onClick={() => setActiveSubTab('sales')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl font-bold cursor-pointer transition-all ${
            activeSubTab === 'sales' ? 'bg-blue-600 text-white shadow-md' : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
          }`}
        >
          <TrendingUp className="w-4 h-4" /> Day-wise Sales ({vendorSales.length})
        </button>

        <button
          onClick={() => setActiveSubTab('audit')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-xl font-bold cursor-pointer transition-all ${
            activeSubTab === 'audit' ? 'bg-blue-600 text-white shadow-md' : 'bg-white text-slate-700 border border-slate-200 hover:bg-slate-50'
          }`}
        >
          <History className="w-4 h-4" /> Baseline & RM Change Log ({vendorLogs.length})
        </button>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="flex items-center gap-1.5 font-bold text-slate-700">
            <Filter className="w-3.5 h-3.5 text-blue-600" /> FILTER: Vendor:
          </div>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="px-3 py-1.5 border border-slate-300 rounded-xl font-bold bg-white text-slate-800 text-xs min-w-[200px]"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>

          <span className="text-slate-500 font-semibold ml-2">Period: From</span>
          <input type="date" value={periodStart} onChange={e => setPeriodStart(e.target.value)} className="px-2 py-1 border rounded-lg text-xs" />
          <span className="text-slate-500 font-semibold">To</span>
          <input type="date" value={periodEnd} onChange={e => setPeriodEnd(e.target.value)} className="px-2 py-1 border rounded-lg text-xs" />
        </div>

        <button
          onClick={() => {
            saveVendorPeriodSchedule();
            alert(`Schedule and Price Matrix saved for ${selectedVendor}!`);
          }}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"
        >
          <Save className="w-4 h-4" /> Save for Vendor + period
        </button>
      </div>

      {/* Protected State Notice */}
      {storeState.isLocked && (
        <div className="bg-amber-50 border border-amber-200 text-amber-800 px-4 py-2.5 rounded-xl text-xs flex items-center gap-2">
          <Lock className="w-4 h-4 text-amber-600 shrink-0" />
          <span><strong>Protected State:</strong> This page is locked. Click "Page Locked (Click to Unlock & Edit)" above to edit Approved Price, change Alternate Materials, or modify WA prices.</span>
        </div>
      )}

      {/* ========================================================================= */}
      {/* 1. RM PRICE MATRIX TABLE (EXACT MATCH TO ATTACHED SCREENSHOT)            */}
      {/* ========================================================================= */}
      {activeSubTab === 'matrix' && (
        <div className="bg-white rounded-2xl border border-slate-200 overflow-x-auto shadow-sm">
          <table className="w-full text-left border-collapse text-xs min-w-[1000px]">
            <thead className="bg-slate-900 text-white uppercase text-[10px] font-bold">
              <tr>
                <th className="py-3 px-4 w-48">APPROVED RM/MB CODE</th>
                <th className="py-3 px-4 text-center w-36">APPROVED PRICE (₹/KG)</th>
                <th className="py-3 px-4 w-60">ALTERNATE RM-1</th>
                <th className="py-3 px-4 text-center w-32">PRICE (WA)</th>
                <th className="py-3 px-4 w-60">ALTERNATE RM-2</th>
                <th className="py-3 px-4 text-center w-32">PRICE (WA)</th>
                <th className="py-3 px-4 w-60">ALTERNATE RM-3</th>
                <th className="py-3 px-4 text-center w-32">PRICE (WA)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredMaterials.length === 0 ? (
                <tr>
                  <td colSpan={8} className="py-8 text-center text-slate-400">
                    No RM/MB mappings registered under {selectedVendor}. Click <strong>"+ Add Vendor RM / MB"</strong> to add materials.
                  </td>
                </tr>
              ) : (
                filteredMaterials.map(mat => {
                  return (
                    <tr key={mat.id} className="hover:bg-slate-50 transition-colors">
                      {/* Approved Code */}
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          <span className={`px-2 py-0.5 rounded font-bold text-[10px] ${
                            mat.type === 'MB' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                          }`}>
                            {mat.type === 'MB' ? 'MASTERBATCH' : 'RM CODE'}
                          </span>
                          <span className="font-bold text-slate-900">{mat.approvedCode}</span>
                        </div>
                      </td>

                      {/* Approved Price */}
                      <td className="py-3 px-4 text-center">
                        <div className="inline-flex items-center justify-center px-3 py-1 bg-slate-100 border border-slate-300 rounded-lg font-mono font-bold text-slate-900">
                          ₹ {Number(mat.approvedPrice || 0).toFixed(2)}
                        </div>
                      </td>

                      {/* Alternate 1 */}
                      <td className="py-3 px-4">
                        <div className={`p-2 rounded-xl border ${mat.activeAlt === 'alt1' || !mat.activeAlt ? 'bg-blue-50/50 border-blue-400' : 'border-slate-200'}`}>
                          <select
                            disabled={storeState.isLocked}
                            value={mat.alt1Code || mat.approvedCode}
                            onChange={e => updateRmMappingRow(mat.id, { alt1Code: e.target.value })}
                            className="w-full px-2 py-1 border border-slate-300 rounded-lg text-xs bg-white font-medium"
                          >
                            <option value={mat.approvedCode}>{mat.approvedCode} (Prime Inward)</option>
                            {purchaseGradeOptions.filter(g => g !== mat.approvedCode).map(g => (
                              <option key={g} value={g}>{g}</option>
                            ))}
                          </select>
                          <div className="flex items-center justify-between mt-1.5 pt-1 border-t border-slate-200">
                            <label className="flex items-center gap-1.5 cursor-pointer text-[11px] font-semibold text-slate-700">
                              <input
                                type="radio"
                                name={`active-${mat.id}`}
                                disabled={storeState.isLocked}
                                checked={mat.activeAlt === 'alt1' || !mat.activeAlt}
                                onChange={() => updateRmMappingRow(mat.id, { activeAlt: 'alt1' })}
                              />
                              Set Active
                            </label>
                            <span className={`text-[10px] px-2 py-0.5 rounded font-bold ${
                              mat.activeAlt === 'alt1' || !mat.activeAlt ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-600'
                            }`}>
                              {mat.activeAlt === 'alt1' || !mat.activeAlt ? 'ACTIVE' : 'STANDBY'}
                            </span>
                          </div>
                        </div>
                      </td>

                      {/* Alternate 1 Price */}
                      <td className="py-3 px-4 text-center font-mono font-bold text-blue-700 text-xs">
                        ₹{Number(mat.alt1Price || mat.approvedPrice || 0).toFixed(2)}
                      </td>

                      {/* Alternate 2 */}
                      <td className="py-3 px-4">
                        <div className={`p-2 rounded-xl border ${mat.activeAlt === 'alt2' ? 'bg-blue-50/50 border-blue-400' : 'border-slate-200'}`}>
                          <select
                            disabled={storeState.isLocked}
                            value={mat.alt2Code || ''}
                            onChange={e => updateRmMappingRow(mat.id, { alt2Code: e.target.value })}
                            className="w-full px-2 py-1 border border-slate-300 rounded-lg text-xs bg-white font-medium"
                          >
                            <option value="">Select Alternate Lot 2...</option>
                            {purchaseGradeOptions.map(g => (
                              <option key={g} value={g}>{g}</option>
                            ))}
                          </select>
                          <div className="flex items-center justify-between mt-1.5 pt-1 border-t border-slate-200">
                            <label className="flex items-center gap-1.5 cursor-pointer text-[11px] font-semibold text-slate-700">
                              <input
                                type="radio"
                                name={`active-${mat.id}`}
                                disabled={storeState.isLocked}
                                checked={mat.activeAlt === 'alt2'}
                                onChange={() => updateRmMappingRow(mat.id, { activeAlt: 'alt2' })}
                              />
                              Set Active
                            </label>
                            <span className={`text-[10px] px-2 py-0.5 rounded font-bold ${
                              mat.activeAlt === 'alt2' ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-600'
                            }`}>
                              {mat.activeAlt === 'alt2' ? 'ACTIVE' : 'STANDBY'}
                            </span>
                          </div>
                        </div>
                      </td>

                      {/* Alternate 2 Price */}
                      <td className="py-3 px-4 text-center font-mono font-bold text-slate-700 text-xs">
                        ₹{Number(mat.alt2Price || 0).toFixed(2)}
                      </td>

                      {/* Alternate 3 */}
                      <td className="py-3 px-4">
                        <div className={`p-2 rounded-xl border ${mat.activeAlt === 'alt3' ? 'bg-blue-50/50 border-blue-400' : 'border-slate-200'}`}>
                          <select
                            disabled={storeState.isLocked}
                            value={mat.alt3Code || ''}
                            onChange={e => updateRmMappingRow(mat.id, { alt3Code: e.target.value })}
                            className="w-full px-2 py-1 border border-slate-300 rounded-lg text-xs bg-white font-medium"
                          >
                            <option value="">Select Alternate Lot 3...</option>
                            {purchaseGradeOptions.map(g => (
                              <option key={g} value={g}>{g}</option>
                            ))}
                          </select>
                          <div className="flex items-center justify-between mt-1.5 pt-1 border-t border-slate-200">
                            <label className="flex items-center gap-1.5 cursor-pointer text-[11px] font-semibold text-slate-700">
                              <input
                                type="radio"
                                name={`active-${mat.id}`}
                                disabled={storeState.isLocked}
                                checked={mat.activeAlt === 'alt3'}
                                onChange={() => updateRmMappingRow(mat.id, { activeAlt: 'alt3' })}
                              />
                              Set Active
                            </label>
                            <span className={`text-[10px] px-2 py-0.5 rounded font-bold ${
                              mat.activeAlt === 'alt3' ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-600'
                            }`}>
                              {mat.activeAlt === 'alt3' ? 'ACTIVE' : 'STANDBY'}
                            </span>
                          </div>
                        </div>
                      </td>

                      {/* Alternate 3 Price */}
                      <td className="py-3 px-4 text-center font-mono font-bold text-slate-700 text-xs">
                        ₹{Number(mat.alt3Price || 0).toFixed(2)}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* ========================================================================= */}
      {/* 2. DAY-WISE PURCHASES (WITH BULK UPLOAD & TEMPLATE DOWNLOAD)              */}
      {/* ========================================================================= */}
      {activeSubTab === 'purchases' && (
        <div className="space-y-4">
          {/* Top Form + Action Buttons */}
          <div className="bg-white p-4 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
            <form onSubmit={handleAddPurchase} className="flex flex-wrap items-center gap-2 flex-1">
              <span className="font-bold text-slate-700">Add Purchase Inward:</span>
              <input type="date" value={newPurchaseDate} onChange={e => setNewPurchaseDate(e.target.value)} className="px-2 py-1.5 border rounded-lg text-xs" />
              <input type="text" placeholder="Inward RM Grade" value={newPurchaseGrade} onChange={e => setNewPurchaseGrade(e.target.value)} className="px-2.5 py-1.5 border rounded-lg font-mono text-xs w-48" />
              <input type="number" step="0.1" placeholder="Qty (kg)" value={newPurchaseQty} onChange={e => setNewPurchaseQty(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-24 text-right" />
              <input type="number" step="0.01" placeholder="Rate (₹/kg)" value={newPurchaseRate} onChange={e => setNewPurchaseRate(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-24 text-right" />
              <input type="text" placeholder="Invoice #" value={newPurchaseInvoice} onChange={e => setNewPurchaseInvoice(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-28" />
              <button type="submit" className="px-3.5 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1 cursor-pointer">
                <Plus className="w-3.5 h-3.5" /> Add Inward
              </button>
            </form>

            <div className="flex items-center gap-2">
              <button
                onClick={downloadPurchaseTemplate}
                className="px-3.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 border border-slate-300 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer text-xs"
              >
                <Download className="w-3.5 h-3.5 text-blue-600" /> Template (.xlsx)
              </button>

              <label className="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm text-xs">
                <Upload className="w-3.5 h-3.5" /> Bulk Upload (.xlsx)
                <input type="file" accept=".xlsx, .xls, .csv" onChange={handlePurchaseFileUpload} className="hidden" />
              </label>
            </div>
          </div>

          {/* Table */}
          <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Date</th>
                  <th className="py-2.5 px-3">Vendor</th>
                  <th className="py-2.5 px-3">Invoice #</th>
                  <th className="py-2.5 px-4">Grade</th>
                  <th className="py-2.5 px-4 text-right">Inward Qty (kg)</th>
                  <th className="py-2.5 px-4 text-right">Purchase Rate (₹/kg)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {vendorPurchases.length === 0 ? (
                  <tr><td colSpan={6} className="py-8 text-center text-slate-400">No inward purchase records recorded for {selectedVendor}.</td></tr>
                ) : (
                  vendorPurchases.map((p, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-600">{p.date}</td>
                      <td className="py-2.5 px-3 font-bold text-slate-800">{p.vendor}</td>
                      <td className="py-2.5 px-3 font-mono text-blue-700">{p.invoiceNo}</td>
                      <td className="py-2.5 px-4 font-mono font-bold text-slate-900">{p.grade}</td>
                      <td className="py-2.5 px-4 text-right font-mono">{p.qty?.toLocaleString()} kg</td>
                      <td className="py-2.5 px-4 text-right font-mono font-bold text-blue-700">₹{Number(p.rate || 0).toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* 3. DAY-WISE SALES (WITH BULK UPLOAD & TEMPLATE DOWNLOAD)                  */}
      {/* ========================================================================= */}
      {activeSubTab === 'sales' && (
        <div className="space-y-4">
          {/* Top Form + Action Buttons */}
          <div className="bg-white p-4 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
            <form onSubmit={handleAddSale} className="flex flex-wrap items-center gap-2 flex-1">
              <span className="font-bold text-slate-700">Add Dispatch Sale:</span>
              <input type="date" value={newSaleDate} onChange={e => setNewSaleDate(e.target.value)} className="px-2 py-1.5 border rounded-lg text-xs" />
              <input type="text" placeholder="Item Code" value={newSaleItemCode} onChange={e => setNewSaleItemCode(e.target.value)} className="px-2.5 py-1.5 border rounded-lg font-mono text-xs w-36" />
              <input type="text" placeholder="Component Description" value={newSaleCompName} onChange={e => setNewSaleCompName(e.target.value)} className="px-2.5 py-1.5 border rounded-lg text-xs w-52" />
              <input type="number" step="1" placeholder="Dispatch Qty" value={newSaleQty} onChange={e => setNewSaleQty(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-28 text-right" />
              <input type="number" step="0.01" placeholder="Selling Price (₹)" value={newSalePrice} onChange={e => setNewSalePrice(e.target.value)} className="px-2 py-1.5 border rounded-lg font-mono text-xs w-28 text-right" />
              <button type="submit" className="px-3.5 py-1.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1 cursor-pointer">
                <Plus className="w-3.5 h-3.5" /> Record Dispatch
              </button>
            </form>

            <div className="flex items-center gap-2">
              <button
                onClick={downloadSalesTemplate}
                className="px-3.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 border border-slate-300 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer text-xs"
              >
                <Download className="w-3.5 h-3.5 text-blue-600" /> Template (.xlsx)
              </button>

              <label className="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm text-xs">
                <Upload className="w-3.5 h-3.5" /> Bulk Upload (.xlsx)
                <input type="file" accept=".xlsx, .xls, .csv" onChange={handleSalesFileUpload} className="hidden" />
              </label>
            </div>
          </div>

          {/* Table */}
          <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Date</th>
                  <th className="py-2.5 px-3">Vendor</th>
                  <th className="py-2.5 px-3">Item Code</th>
                  <th className="py-2.5 px-4">Component Name</th>
                  <th className="py-2.5 px-4 text-right">Qty</th>
                  <th className="py-2.5 px-4 text-right">Selling Price (₹)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {vendorSales.length === 0 ? (
                  <tr><td colSpan={6} className="py-8 text-center text-slate-400">No dispatch records recorded for {selectedVendor}.</td></tr>
                ) : (
                  vendorSales.map((s, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-600">{s.date}</td>
                      <td className="py-2.5 px-3 font-bold text-slate-800">{s.vendor}</td>
                      <td className="py-2.5 px-3 font-mono text-blue-700 font-bold">{s.itemCode}</td>
                      <td className="py-2.5 px-4 text-slate-900">{s.componentName}</td>
                      <td className="py-2.5 px-4 text-right font-mono font-bold">{s.qty?.toLocaleString()}</td>
                      <td className="py-2.5 px-4 text-right font-mono font-bold text-emerald-700">₹{Number(s.sellingPrice || 0).toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* ========================================================================= */}
      {/* 4. BASELINE & RM CHANGE AUDIT LOG                                         */}
      {/* ========================================================================= */}
      {activeSubTab === 'audit' && (
        <div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-3">Timestamp</th>
                <th className="py-2.5 px-3">Code / Ref</th>
                <th className="py-2.5 px-3">Type / Target</th>
                <th className="py-2.5 px-3">Modifications</th>
                <th className="py-2.5 px-3 text-right">Cost Impact</th>
                <th className="py-2.5 px-3">Reason</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {vendorLogs.length === 0 ? (
                <tr><td colSpan={6} className="py-6 text-center text-slate-400">No modifications logged yet for {selectedVendor}.</td></tr>
              ) : (
                vendorLogs.map((log, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="py-2.5 px-3 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{log.partCode}</td>
                    <td className="py-2.5 px-3 font-semibold text-slate-800">{log.componentName}</td>
                    <td className="py-2.5 px-3 text-slate-600">{log.modifications}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">{log.costImpact}</td>
                    <td className="py-2.5 px-3 text-slate-500">{log.reason}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* ========================================================================= */}
      {/* ADD VENDOR RM / MB POPUP MODAL                                            */}
      {/* ========================================================================= */}
      {showAddMatModal && (
        <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-5 space-y-4 border border-slate-300 relative">
            <div className="flex justify-between items-center border-b pb-3">
              <div>
                <h3 className="text-sm font-bold text-slate-900 flex items-center gap-1.5">
                  <PackagePlus className="w-4 h-4 text-purple-600" /> Register Material: {selectedVendor}
                </h3>
                <p className="text-[11px] text-slate-500">Add a new approved Polymer (RM) or Masterbatch (MB) code.</p>
              </div>
              <button onClick={() => setShowAddMatModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer"><X className="w-5 h-5" /></button>
            </div>

            <form onSubmit={handleAddNewMaterial} className="space-y-3">
              <div>
                <label className="block font-bold text-slate-700 mb-1">Material Type</label>
                <select
                  value={newMatType}
                  onChange={e => setNewMatType(e.target.value)}
                  className="w-full px-3 py-2 border rounded-xl font-bold bg-white text-slate-800"
                >
                  <option value="RM">Raw Material / Base Polymer (RM)</option>
                  <option value="MB">Masterbatch (MB)</option>
                </select>
              </div>

              <div>
                <label className="block font-bold text-slate-700 mb-1">Approved Material Code</label>
                <input
                  type="text"
                  placeholder="e.g. HIPS-SH03 or White MB"
                  value={newMatCode}
                  onChange={e => setNewMatCode(e.target.value)}
                  className="w-full px-3 py-2 border rounded-xl font-mono font-bold text-slate-900"
                  required
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 mb-1">Approved Base Price (₹/kg)</label>
                <input
                  type="number"
                  step="0.01"
                  placeholder="e.g. 147.87"
                  value={newMatApprovedPrice}
                  onChange={e => setNewMatApprovedPrice(e.target.value)}
                  className="w-full px-3 py-2 border border-amber-400 bg-amber-50 rounded-xl font-mono font-bold text-amber-900"
                  required
                />
              </div>

              <div className="flex justify-end gap-2 pt-2 border-t">
                <button type="button" onClick={() => setShowAddMatModal(false)} className="px-4 py-2 border rounded-xl font-bold hover:bg-slate-50">Cancel</button>
                <button type="submit" className="px-5 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl flex items-center gap-1.5 shadow-sm">
                  <Plus className="w-4 h-4" /> Save Material to Matrix
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
PAGE_EOF

echo "==> 3. Running npm run build verification..."
npm run build

echo "==> 4. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Ready with '+ Add Vendor RM / MB', Bulk Uploads & Templates."
echo "-------------------------------------------------------------------"
