#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring branch is dev-v2..."
git checkout dev-v2

echo "==> 2. Updating RMPriceMatrixPage.jsx (Template Downloads + Always Locked by Default)..."
cat << 'RM_PAGE_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Lock, 
  Unlock, 
  Upload, 
  Download, 
  Save, 
  Trash2, 
  Plus, 
  CheckCircle2, 
  Clock, 
  Database,
  Layers,
  ShoppingBag,
  TrendingUp,
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
  toggleMatrixLock, 
  saveVendorPeriodSchedule, 
  addOrUpdateVendorMaterial, 
  deleteVendorMaterial,
  computeGradeWeightedAverage 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [activeTab, setActiveTab] = useState('matrix'); // 'matrix' | 'purchases' | 'sales' | 'changelog'
  const [selectedVendor, setSelectedVendor] = useState('Haier Appliances');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');

  // Purchase Form State
  const [purchaseForm, setPurchaseForm] = useState({
    date: '2026-08-15',
    supplierName: '',
    invoiceNo: '',
    itemCode: '',
    grade: '',
    qty: '',
    rate: ''
  });

  // Sales Form State
  const [salesForm, setSalesForm] = useState({
    date: '2026-08-15',
    vendor: 'Haier Appliances',
    itemCode: '',
    invoiceNo: '',
    componentName: '',
    qty: '',
    sellingPrice: ''
  });

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

  const vendorMaterials = (storeState.rmMappingsData || []).filter(r => 
    selectedVendor === 'ALL' || 
    (r.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((r.vendor || '').toLowerCase())
  );

  const purchases = (storeState.purchases || []).filter(p => 
    selectedVendor === 'ALL' || 
    (p.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((p.vendor || '').toLowerCase())
  );

  const sales = (storeState.sales || []).filter(s => 
    selectedVendor === 'ALL' || 
    (s.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((s.vendor || '').toLowerCase())
  );

  const isLocked = storeState.isLocked !== undefined ? storeState.isLocked : true;

  // 1. Download Purchase Template (.xlsx)
  const handleDownloadPurchaseTemplate = () => {
    const templateData = [
      {
        "Date (YYYY-MM-DD)": "2026-08-15",
        "Supplier Name": "Reliance Polymers",
        "Invoice Number": "INV-2026-001",
        "Item Code": "HIPS-SH303",
        "Grade Description": "HIPS SH303 Natural",
        "Quantity (Kg)": 5000,
        "Purchase Rate (₹/Kg)": 154.00,
        "Vendor": selectedVendor
      }
    ];
    const ws = XLSX.utils.json_to_sheet(templateData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Purchase_Template");
    XLSX.writeFile(wb, `Purchase_Inward_Template_${selectedVendor.replace(/\s+/g, '_')}.xlsx`);
  };

  // 2. Download Sales Template (.xlsx)
  const handleDownloadSalesTemplate = () => {
    const templateData = [
      {
        "Dispatch Date (YYYY-MM-DD)": "2026-08-15",
        "Vendor": selectedVendor,
        "Item Code": "0060235291A",
        "Invoice Number": "SALE-2026-101",
        "Component Name": "FRZ DUCT-FRONT COVER-HIPS-TM-250/280L",
        "Dispatch Qty (Nos)": 1200,
        "Selling Price (₹/Pc)": 85.00
      }
    ];
    const ws = XLSX.utils.json_to_sheet(templateData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Sales_Template");
    XLSX.writeFile(wb, `DayWise_Sales_Template_${selectedVendor.replace(/\s+/g, '_')}.xlsx`);
  };

  // 3. Purchase Bulk Upload
  const handlePurchaseBulkUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      const bstr = evt.target.result;
      const wb = XLSX.read(bstr, { type: 'binary' });
      const ws = wb.Sheets[wb.SheetNames[0]];
      const data = XLSX.utils.sheet_to_json(ws);
      data.forEach(d => {
        addDayWisePurchase({
          date: d["Date (YYYY-MM-DD)"] || d.Date || d.date || '2026-08-15',
          supplier: d["Supplier Name"] || d.Supplier || d.supplier || '',
          invoiceNo: d["Invoice Number"] || d.Invoice || d.invoiceNo || '',
          itemCode: d["Item Code"] || d.itemCode || '',
          grade: d["Grade Description"] || d.Grade || d.grade || '',
          qty: parseFloat(d["Quantity (Kg)"] || d.Quantity || d.qty || 0),
          rate: parseFloat(d["Purchase Rate (₹/Kg)"] || d.Rate || d.rate || 0),
          vendor: d.Vendor || selectedVendor
        });
      });
      alert(`Imported ${data.length} purchase records!`);
    };
    reader.readAsBinaryString(file);
  };

  // 4. Sales Bulk Upload
  const handleSalesBulkUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      const bstr = evt.target.result;
      const wb = XLSX.read(bstr, { type: 'binary' });
      const ws = wb.Sheets[wb.SheetNames[0]];
      const data = XLSX.utils.sheet_to_json(ws);
      data.forEach(d => {
        addDayWiseSales({
          date: d["Dispatch Date (YYYY-MM-DD)"] || d.Date || d.date || '2026-08-15',
          vendor: d.Vendor || selectedVendor,
          itemCode: d["Item Code"] || d.itemCode || '',
          invoiceNo: d["Invoice Number"] || d.Invoice || d.invoiceNo || '',
          componentName: d["Component Name"] || d.componentName || '',
          qty: parseFloat(d["Dispatch Qty (Nos)"] || d.Quantity || d.qty || 0),
          rate: parseFloat(d["Selling Price (₹/Pc)"] || d.Rate || d.sellingPrice || 0),
          amount: parseFloat(d["Dispatch Qty (Nos)"] || d.qty || 0) * parseFloat(d["Selling Price (₹/Pc)"] || d.sellingPrice || 0)
        });
      });
      alert(`Imported ${data.length} sales dispatch records!`);
    };
    reader.readAsBinaryString(file);
  };

  const handleAddPurchase = (e) => {
    e.preventDefault();
    if (!purchaseForm.qty || !purchaseForm.rate) return;
    addDayWisePurchase({
      ...purchaseForm,
      qty: parseFloat(purchaseForm.qty),
      rate: parseFloat(purchaseForm.rate),
      vendor: selectedVendor
    });
    setPurchaseForm({ date: '2026-08-15', supplierName: '', invoiceNo: '', itemCode: '', grade: '', qty: '', rate: '' });
  };

  const handleAddSales = (e) => {
    e.preventDefault();
    if (!salesForm.qty || !salesForm.sellingPrice) return;
    addDayWiseSales({
      ...salesForm,
      qty: parseFloat(salesForm.qty),
      rate: parseFloat(salesForm.sellingPrice),
      amount: parseFloat(salesForm.qty) * parseFloat(salesForm.sellingPrice),
      vendor: salesForm.vendor || selectedVendor
    });
    setSalesForm({ date: '2026-08-15', vendor: selectedVendor, itemCode: '', invoiceNo: '', componentName: '', qty: '', sellingPrice: '' });
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner with Lock Status */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">2. RM Mapping & Inward Registry</h1>
            <p className="text-[11px] text-slate-300">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={toggleGlobalLock}
            className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 cursor-pointer shadow-sm transition text-xs ${
              isLocked 
                ? 'bg-rose-600 hover:bg-rose-700 text-white' 
                : 'bg-emerald-600 hover:bg-emerald-700 text-white'
            }`}
          >
            {isLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4" />}
            {isLocked ? 'Page Locked (Protected)' : 'Page Unlocked (Editing Active)'}
          </button>
        </div>
      </div>

      {/* Tabs Navigation */}
      <div className="bg-white p-2 rounded-2xl border border-slate-200 shadow-xs flex flex-wrap gap-2">
        <button
          onClick={() => setActiveTab('matrix')}
          className={`px-4 py-2 rounded-xl font-bold transition-all cursor-pointer flex items-center gap-2 ${
            activeTab === 'matrix' ? 'bg-blue-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100'
          }`}
        >
          <Layers className="w-4 h-4" /> RM Price Matrix
        </button>
        <button
          onClick={() => setActiveTab('purchases')}
          className={`px-4 py-2 rounded-xl font-bold transition-all cursor-pointer flex items-center gap-2 ${
            activeTab === 'purchases' ? 'bg-blue-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100'
          }`}
        >
          <ShoppingBag className="w-4 h-4" /> Day-wise Purchases ({purchases.length})
        </button>
        <button
          onClick={() => setActiveTab('sales')}
          className={`px-4 py-2 rounded-xl font-bold transition-all cursor-pointer flex items-center gap-2 ${
            activeTab === 'sales' ? 'bg-blue-600 text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100'
          }`}
        >
          <TrendingUp className="w-4 h-4" /> Day-wise Sales ({sales.length})
        </button>
      </div>

      {/* Filter Row */}
      <div className="bg-white p-3 rounded-2xl border border-slate-200 shadow-xs flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-600">FILTER: Vendor:</span>
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

        <div className="flex items-center gap-2">
          <span className="text-slate-500 font-bold">Period: From</span>
          <input 
            type="date" 
            value={periodFrom} 
            onChange={e => setPeriodFrom(e.target.value)} 
            className="px-2 py-1 rounded-xl bg-slate-100 border border-slate-300 text-xs font-mono" 
          />
          <span className="text-slate-500">To</span>
          <input 
            type="date" 
            value={periodTo} 
            onChange={e => setPeriodTo(e.target.value)} 
            className="px-2 py-1 rounded-xl bg-slate-100 border border-slate-300 text-xs font-mono" 
          />
          <button 
            onClick={() => saveVendorPeriodSchedule({ vendor: selectedVendor, periodFrom, periodTo })}
            disabled={isLocked}
            className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-1.5 shadow-sm text-xs ${
              isLocked ? 'bg-slate-200 text-slate-400 cursor-not-allowed' : 'bg-blue-600 hover:bg-blue-700 text-white cursor-pointer'
            }`}
          >
            <Save className="w-3.5 h-3.5" /> Save for Vendor + period
          </button>
        </div>
      </div>

      {/* TAB 1: RM PRICE MATRIX */}
      {activeTab === 'matrix' && (
        <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
          <div className="p-3 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-xs font-bold uppercase">{selectedVendor} RM & MB Approved vs Alternate Lots</h2>
            <span className="text-[11px] text-slate-400 font-mono">{vendorMaterials.length} Registered Grades</span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-4">Approved RM/MB Code</th>
                  <th className="py-2.5 px-4 text-center">Approved Price (₹/kg)</th>
                  <th className="py-2.5 px-4">Alternate RM-1</th>
                  <th className="py-2.5 px-4 text-center">Price (WA)</th>
                  <th className="py-2.5 px-4">Alternate RM-2</th>
                  <th className="py-2.5 px-4 text-center">Price (WA)</th>
                  <th className="py-2.5 px-4">Alternate RM-3</th>
                  <th className="py-2.5 px-4 text-center">Price (WA)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {vendorMaterials.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="py-12 text-center text-slate-400">
                      No material codes mapped for {selectedVendor}. Upload a baseline sheet in <b>1. Baseline Master</b> to auto-register grades.
                    </td>
                  </tr>
                ) : (
                  vendorMaterials.map(m => (
                    <tr key={m.id} className="hover:bg-slate-50">
                      <td className="py-3 px-4 font-mono font-bold text-slate-900">
                        <span className={`mr-2 px-1.5 py-0.5 rounded text-[10px] ${m.type === 'MB' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'}`}>
                          {m.type || 'RM'}
                        </span>
                        {m.approvedCode}
                      </td>
                      <td className="py-3 px-4 text-center font-mono font-bold bg-amber-50/40">
                        ₹{Number(m.approvedPrice || 0).toFixed(2)}
                      </td>
                      <td className="py-3 px-4">
                        <span className="font-mono text-slate-700">{m.alt1Code || m.approvedCode}</span>
                      </td>
                      <td className="py-3 px-4 text-center font-mono text-blue-700 font-bold">
                        ₹{Number(m.alt1Price || m.approvedPrice || 0).toFixed(2)}
                      </td>
                      <td className="py-3 px-4 font-mono text-slate-400">{m.alt2Code || 'Lot 2 (Standby)'}</td>
                      <td className="py-3 px-4 text-center font-mono text-slate-400">₹{Number(m.alt2Price || 0).toFixed(2)}</td>
                      <td className="py-3 px-4 font-mono text-slate-400">{m.alt3Code || 'Lot 3 (Standby)'}</td>
                      <td className="py-3 px-4 text-center font-mono text-slate-400">₹{Number(m.alt3Price || 0).toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 2: DAY-WISE PURCHASES */}
      {activeTab === 'purchases' && (
        <div className="space-y-4">
          {/* Purchase Inward Form + Download Template + Upload */}
          <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs space-y-3">
            <div className="flex flex-wrap justify-between items-center gap-2 border-b border-slate-100 pb-3">
              <span className="font-bold text-slate-900 text-xs uppercase">Add Purchase Inward ({selectedVendor})</span>
              <div className="flex items-center gap-2">
                <button
                  onClick={handleDownloadPurchaseTemplate}
                  className="px-3.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 border border-slate-300 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer text-xs"
                >
                  <Download className="w-4 h-4 text-blue-600" /> Download Purchase Template (.xlsx)
                </button>
                <label className="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-xs text-xs">
                  <Upload className="w-4 h-4" /> Bulk Upload (.xlsx)
                  <input type="file" accept=".xlsx, .xls" onChange={handlePurchaseBulkUpload} className="hidden" />
                </label>
              </div>
            </div>

            <form onSubmit={handleAddPurchase} className="flex flex-wrap items-center gap-2">
              <input 
                type="date" 
                value={purchaseForm.date} 
                onChange={e => setPurchaseForm({ ...purchaseForm, date: e.target.value })} 
                className="px-2.5 py-1.5 rounded-xl border border-slate-300 font-mono text-xs" 
              />
              <input 
                type="text" 
                placeholder="Supplier Name" 
                value={purchaseForm.supplierName} 
                onChange={e => setPurchaseForm({ ...purchaseForm, supplierName: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs flex-1 min-w-[120px]" 
              />
              <input 
                type="text" 
                placeholder="Invoice #" 
                value={purchaseForm.invoiceNo} 
                onChange={e => setPurchaseForm({ ...purchaseForm, invoiceNo: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs font-mono w-28" 
              />
              <input 
                type="text" 
                placeholder="Item Code" 
                value={purchaseForm.itemCode} 
                onChange={e => setPurchaseForm({ ...purchaseForm, itemCode: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs font-mono w-28" 
              />
              <input 
                type="text" 
                placeholder="Grade Description" 
                value={purchaseForm.grade} 
                onChange={e => setPurchaseForm({ ...purchaseForm, grade: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs flex-1 min-w-[140px]" 
              />
              <input 
                type="number" 
                placeholder="Qty (kg)" 
                value={purchaseForm.qty} 
                onChange={e => setPurchaseForm({ ...purchaseForm, qty: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs w-24" 
              />
              <input 
                type="number" 
                step="0.01" 
                placeholder="Rate (₹/kg)" 
                value={purchaseForm.rate} 
                onChange={e => setPurchaseForm({ ...purchaseForm, rate: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs w-24" 
              />
              <button 
                type="submit" 
                disabled={isLocked}
                className={`px-4 py-1.5 rounded-xl font-bold shadow-xs text-xs ${
                  isLocked ? 'bg-slate-200 text-slate-400 cursor-not-allowed' : 'bg-blue-600 hover:bg-blue-700 text-white cursor-pointer'
                }`}
              >
                + Add Inward
              </button>
            </form>
          </div>

          {/* Purchases Table */}
          <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Date</th>
                  <th className="py-2.5 px-3">Supplier</th>
                  <th className="py-2.5 px-3">Invoice #</th>
                  <th className="py-2.5 px-3">Item Code</th>
                  <th className="py-2.5 px-3">Grade</th>
                  <th className="py-2.5 px-3 text-right">Inward Qty (kg)</th>
                  <th className="py-2.5 px-3 text-right">Purchase Rate (₹/kg)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {purchases.length === 0 ? (
                  <tr><td colSpan={7} className="py-8 text-center text-slate-400">No inward purchase records found for {selectedVendor}.</td></tr>
                ) : (
                  purchases.map((p, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-600">{p.date}</td>
                      <td className="py-2.5 px-3 font-medium text-slate-800">{p.supplier || p.supplierName || '-'}</td>
                      <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{p.invoiceNo}</td>
                      <td className="py-2.5 px-3 font-mono">{p.itemCode || '-'}</td>
                      <td className="py-2.5 px-3 font-bold text-slate-900">{p.grade}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold">{Number(p.qty || 0).toLocaleString()} kg</td>
                      <td className="py-2.5 px-3 text-right font-mono text-slate-900 font-bold">₹{Number(p.rate || 0).toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 3: DAY-WISE SALES */}
      {activeTab === 'sales' && (
        <div className="space-y-4">
          {/* Sales Form + Download Template + Upload */}
          <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs space-y-3">
            <div className="flex flex-wrap justify-between items-center gap-2 border-b border-slate-100 pb-3">
              <span className="font-bold text-slate-900 text-xs uppercase">Add Dispatch Sale ({selectedVendor})</span>
              <div className="flex items-center gap-2">
                <button
                  onClick={handleDownloadSalesTemplate}
                  className="px-3.5 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 border border-slate-300 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer text-xs"
                >
                  <Download className="w-4 h-4 text-blue-600" /> Download Sales Template (.xlsx)
                </button>
                <label className="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-xs text-xs">
                  <Upload className="w-4 h-4" /> Bulk Upload (.xlsx)
                  <input type="file" accept=".xlsx, .xls" onChange={handleSalesBulkUpload} className="hidden" />
                </label>
              </div>
            </div>

            <form onSubmit={handleAddSales} className="flex flex-wrap items-center gap-2">
              <input 
                type="date" 
                value={salesForm.date} 
                onChange={e => setSalesForm({ ...salesForm, date: e.target.value })} 
                className="px-2.5 py-1.5 rounded-xl border border-slate-300 font-mono text-xs" 
              />
              <select
                value={salesForm.vendor}
                onChange={e => setSalesForm({ ...salesForm, vendor: e.target.value })}
                className="px-3 py-1.5 rounded-xl border border-slate-300 font-bold text-xs"
              >
                {vendors.map(v => (
                  <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
                ))}
              </select>
              <input 
                type="text" 
                placeholder="Item Code" 
                value={salesForm.itemCode} 
                onChange={e => setSalesForm({ ...salesForm, itemCode: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs font-mono w-28" 
              />
              <input 
                type="text" 
                placeholder="Invoice Number" 
                value={salesForm.invoiceNo} 
                onChange={e => setSalesForm({ ...salesForm, invoiceNo: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs font-mono w-28" 
              />
              <input 
                type="text" 
                placeholder="Component Name" 
                value={salesForm.componentName} 
                onChange={e => setSalesForm({ ...salesForm, componentName: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs flex-1 min-w-[140px]" 
              />
              <input 
                type="number" 
                placeholder="Dispatch Qty" 
                value={salesForm.qty} 
                onChange={e => setSalesForm({ ...salesForm, qty: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs w-24" 
              />
              <input 
                type="number" 
                step="0.01" 
                placeholder="Selling Price" 
                value={salesForm.sellingPrice} 
                onChange={e => setSalesForm({ ...salesForm, sellingPrice: e.target.value })} 
                className="px-3 py-1.5 rounded-xl border border-slate-300 text-xs w-24" 
              />
              <button 
                type="submit" 
                disabled={isLocked}
                className={`px-4 py-1.5 rounded-xl font-bold shadow-xs text-xs ${
                  isLocked ? 'bg-slate-200 text-slate-400 cursor-not-allowed' : 'bg-blue-600 hover:bg-blue-700 text-white cursor-pointer'
                }`}
              >
                + Record Dispatch
              </button>
            </form>
          </div>

          {/* Sales Table */}
          <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
                <tr>
                  <th className="py-2.5 px-3">Date</th>
                  <th className="py-2.5 px-3">Vendor</th>
                  <th className="py-2.5 px-3">Item Code</th>
                  <th className="py-2.5 px-3">Invoice Number</th>
                  <th className="py-2.5 px-3">Component Name</th>
                  <th className="py-2.5 px-3 text-right">Dispatch Qty</th>
                  <th className="py-2.5 px-3 text-right">Selling Price (₹)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {sales.length === 0 ? (
                  <tr><td colSpan={7} className="py-8 text-center text-slate-400">No dispatch records recorded for {selectedVendor}.</td></tr>
                ) : (
                  sales.map((s, idx) => (
                    <tr key={idx} className="hover:bg-slate-50">
                      <td className="py-2.5 px-3 font-mono text-slate-600">{s.date}</td>
                      <td className="py-2.5 px-3 font-medium text-slate-800">{s.vendor}</td>
                      <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{s.itemCode}</td>
                      <td className="py-2.5 px-3 font-mono">{s.invoiceNo}</td>
                      <td className="py-2.5 px-3 font-bold text-slate-900">{s.componentName}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold">{Number(s.qty || 0).toLocaleString()}</td>
                      <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">₹{Number(s.rate || s.sellingPrice || 0).toFixed(2)}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
RM_PAGE_EOF

echo "==> 3. Updating MISVariancePage.jsx (Section Report Download in Red Box Area)..."
cat << 'MIS_PAGE_EOF' > src/modules/module4-mis/MISVariancePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Download, 
  Layers, 
  Activity, 
  ArrowUpRight, 
  ArrowDownRight, 
  DollarSign, 
  TrendingUp, 
  Database,
  FileSpreadsheet
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISVariancePage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [drilldownVendor, setDrilldownVendor] = useState('Haier Appliances');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [activeTab, setActiveTab] = useState('summary'); // 'summary' | 'invoices'

  useEffect(() => {
    const unsub = subscribeStore(() => {
      setStoreState({ ...globalStore });
    });
    return () => unsub();
  }, []);

  const vendors = storeState.vendors || [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer' }
  ];

  const sales = storeState.sales || [];
  const purchases = storeState.purchases || [];
  const baselineProducts = storeState.baselineProducts || [];

  const filteredSales = sales.filter(s => {
    const sVendor = (s.vendor || '').toLowerCase();
    const matchVendor = selectedVendor === 'ALL' || sVendor.includes(selectedVendor.toLowerCase()) || selectedVendor.toLowerCase().includes(sVendor);
    const sDate = s.date || s.invoiceDate || '';
    const matchDate = (!periodFrom || sDate >= periodFrom) && (!periodTo || sDate <= periodTo);
    return matchVendor && matchDate;
  });

  const productSummaryMap = {};
  let totalVolume = 0;
  let totalRevenue = 0;
  let totalApprovedCost = 0;
  let totalActualCost = 0;

  filteredSales.forEach(s => {
    const code = s.itemCode || s.partCode || 'UNKNOWN';
    const qty = Number(s.qty || s.quantity || 0);
    const rev = Number(s.amount || s.totalAmount || (qty * Number(s.rate || s.price || 0)));
    const baseProd = baselineProducts.find(b => b.itemCode === code) || {};
    const detailed = calculateDetailedCost(baseProd);
    
    const approvedUnitCost = Number(baseProd.approvedCost || detailed.finalLanded || 0);
    const actualUnitCost = Number(detailed.finalLanded || baseProd.approvedCost || 0);
    const unitGainLoss = approvedUnitCost - actualUnitCost;

    totalVolume += qty;
    totalRevenue += rev;
    totalApprovedCost += (approvedUnitCost * qty);
    totalActualCost += (actualUnitCost * qty);

    if (!productSummaryMap[code]) {
      productSummaryMap[code] = {
        itemCode: code,
        componentName: s.componentName || baseProd.componentName || s.itemDescription || code,
        vendor: s.vendor || baseProd.vendor || 'Haier Appliances',
        invoicesCount: 0,
        totalQty: 0,
        totalRevenue: 0,
        approvedUnitCost: approvedUnitCost,
        actualUnitCost: actualUnitCost,
        unitGainLoss: unitGainLoss,
        totalGainLoss: 0
      };
    }

    productSummaryMap[code].invoicesCount += 1;
    productSummaryMap[code].totalQty += qty;
    productSummaryMap[code].totalRevenue += rev;
    productSummaryMap[code].totalGainLoss += (unitGainLoss * qty);
  });

  const productSummaryList = Object.values(productSummaryMap);
  const totalCostGainLoss = totalApprovedCost - totalActualCost;
  const grossProfit = totalRevenue - totalActualCost;
  const grossMarginPct = totalRevenue > 0 ? ((grossProfit / totalRevenue) * 100).toFixed(1) : '0';

  const vendorBreakdowns = vendors.map(v => {
    const vSales = sales.filter(s => {
      const sv = (s.vendor || '').toLowerCase();
      return sv.includes(v.vendorId.toLowerCase()) || v.vendorId.toLowerCase().includes(sv);
    });

    let currentRev = 0;
    let currentGainLoss = 0;

    vSales.forEach(s => {
      const q = Number(s.qty || 0);
      const r = Number(s.amount || (q * Number(s.rate || 0)));
      const bp = baselineProducts.find(b => b.itemCode === (s.itemCode || s.partCode)) || {};
      const det = calculateDetailedCost(bp);
      const appCost = Number(bp.approvedCost || det.finalLanded || 0);
      const actCost = Number(det.finalLanded || bp.approvedCost || 0);
      currentRev += r;
      currentGainLoss += ((appCost - actCost) * q);
    });

    return {
      vendorName: v.vendorName,
      currentRev,
      currentGainLoss,
      prevRev: 0,
      prevGainLoss: 0,
      growthPct: '+0%',
      varianceDelta: currentGainLoss
    };
  });

  const allVendorsRev = vendorBreakdowns.reduce((acc, v) => acc + v.currentRev, 0);
  const allVendorsGainLoss = vendorBreakdowns.reduce((acc, v) => acc + v.currentGainLoss, 0);

  const drilldownSales = sales.filter(s => {
    const sv = (s.vendor || '').toLowerCase();
    return drilldownVendor === 'ALL' || sv.includes(drilldownVendor.toLowerCase()) || drilldownVendor.toLowerCase().includes(sv);
  });

  const drilldownSummaryMap = {};
  drilldownSales.forEach(s => {
    const code = s.itemCode || s.partCode;
    const qty = Number(s.qty || 0);
    const bp = baselineProducts.find(b => b.itemCode === code) || {};
    const det = calculateDetailedCost(bp);
    const appCost = Number(bp.approvedCost || det.finalLanded || 0);
    const actCost = Number(det.finalLanded || bp.approvedCost || 0);
    const gainLoss = (appCost - actCost) * qty;

    if (!drilldownSummaryMap[code]) {
      drilldownSummaryMap[code] = {
        itemCode: code,
        componentName: s.componentName || bp.componentName || code,
        gainLoss: 0
      };
    }
    drilldownSummaryMap[code].gainLoss += gainLoss;
  });

  const drilldownParts = Object.values(drilldownSummaryMap);
  const topProfitParts = drilldownParts.filter(p => p.gainLoss > 0).sort((a,b) => b.gainLoss - a.gainLoss).slice(0, 3);
  const topLossParts = drilldownParts.filter(p => p.gainLoss < 0).sort((a,b) => a.gainLoss - b.gainLoss).slice(0, 3);

  let haierRmDelta = 0, atomRmDelta = 0;
  let haierMbDelta = 0, atomMbDelta = 0;

  purchases.forEach(p => {
    const isHaier = (p.vendor || '').toLowerCase().includes('haier');
    const isAtom = (p.vendor || '').toLowerCase().includes('atomberg');
    const rmMap = getActiveRmMapping(p.grade || p.itemCode, p.vendor);
    const appRate = Number(rmMap.approvedPrice || 0);
    const actRate = Number(p.rate || p.netRate || 0);
    const qty = Number(p.qty || 0);

    if (appRate > 0 && actRate > 0) {
      const delta = (appRate - actRate) * qty;
      const isMb = p.type === 'MB' || (p.grade || '').toLowerCase().includes('mb');
      if (isMb) {
        if (isHaier) haierMbDelta += delta;
        if (isAtom) atomMbDelta += delta;
      } else {
        if (isHaier) haierRmDelta += delta;
        if (isAtom) atomRmDelta += delta;
      }
    }
  });

  // Export Section Report (Red Box Target)
  const handleExportRealizationSection = () => {
    const dataToExport = activeTab === 'summary' ? productSummaryList : filteredSales;
    const ws = XLSX.utils.json_to_sheet(dataToExport);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, activeTab === 'summary' ? "Realization_Summary" : "Sales_Invoices");
    XLSX.writeFile(wb, `MIS_Sales_Realization_${selectedVendor}_${new Date().toISOString().slice(0,10)}.xlsx`);
  };

  const exportReport = () => {
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.json_to_sheet(productSummaryList);
    XLSX.utils.book_append_sheet(wb, ws, "Product_Sales_MIS");
    XLSX.writeFile(wb, `Complete_MIS_Report_${new Date().toISOString().slice(0,10)}.xlsx`);
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
            <h1 className="text-sm font-bold">4. Vendor & Product Sales P&L MIS Intelligence</h1>
            <p className="text-[11px] text-slate-300">Decoupled Output Store • Zero BOM Overhead • Synced Live</p>
          </div>
        </div>
        <button 
          onClick={exportReport}
          className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm transition"
        >
          <Download className="w-4 h-4" /> Download Complete MIS Report (.xlsx)
        </button>
      </div>

      {/* 4 Metric Badges */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="text-[10px] uppercase font-bold text-slate-400">Period Sales Volume</div>
          <div className="text-2xl font-black font-mono text-slate-900 mt-1">{totalVolume.toLocaleString()} <span className="text-xs font-normal text-slate-500">pcs</span></div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="text-[10px] uppercase font-bold text-slate-400">Total Sales Revenue</div>
          <div className="text-2xl font-black font-mono text-blue-700 mt-1">₹{totalRevenue.toLocaleString()}</div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="text-[10px] uppercase font-bold text-slate-400">Gross Profit & Margin</div>
          <div className="text-2xl font-black font-mono text-emerald-700 mt-1">
            ₹{grossProfit.toLocaleString()} <span className="text-xs font-bold text-emerald-600">({grossMarginPct}%)</span>
          </div>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
          <div className="text-[10px] uppercase font-bold text-slate-400">Cost Variance Gain / Loss</div>
          <div className={`text-2xl font-black font-mono mt-1 ${totalCostGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {totalCostGainLoss >= 0 ? `+ ₹${totalCostGainLoss.toLocaleString()}` : `- ₹${Math.abs(totalCostGainLoss).toLocaleString()}`}
          </div>
        </div>
      </div>

      {/* Section 1: Product Sales Realization & Costing Analysis with Section Export Button */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex flex-wrap justify-between items-center gap-3">
          <div className="flex items-center gap-3">
            <Activity className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">Product Sales Realization & Costing Analysis</h2>
            <div className="flex bg-slate-800 p-0.5 rounded-lg border border-slate-700">
              <button 
                onClick={() => setActiveTab('summary')} 
                className={`px-3 py-1 rounded font-bold cursor-pointer transition ${activeTab === 'summary' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'}`}
              >
                Product Summary ({productSummaryList.length})
              </button>
              <button 
                onClick={() => setActiveTab('invoices')} 
                className={`px-3 py-1 rounded font-bold cursor-pointer transition ${activeTab === 'invoices' ? 'bg-blue-600 text-white' : 'text-slate-400 hover:text-white'}`}
              >
                Invoices Log ({filteredSales.length})
              </button>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <span className="text-slate-400 font-bold">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="px-2.5 py-1 bg-slate-800 text-white border border-slate-700 rounded-lg text-xs font-bold"
            >
              <option value="ALL">All Vendors Combined</option>
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>

            <input 
              type="date" 
              value={periodFrom} 
              onChange={e => setPeriodFrom(e.target.value)} 
              className="px-2 py-1 bg-slate-800 text-white border border-slate-700 rounded-lg text-xs font-mono" 
            />
            <span className="text-slate-400">to</span>
            <input 
              type="date" 
              value={periodTo} 
              onChange={e => setPeriodTo(e.target.value)} 
              className="px-2 py-1 bg-slate-800 text-white border border-slate-700 rounded-lg text-xs font-mono" 
            />

            {/* Red Box Target: Section Download Button */}
            <button
              onClick={handleExportRealizationSection}
              className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1.5 cursor-pointer text-xs shadow-sm transition"
            >
              <Download className="w-3.5 h-3.5" /> Export Section (.xlsx)
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-3">Part Code</th>
                <th className="py-2.5 px-3">Component Name</th>
                <th className="py-2.5 px-3">Vendor</th>
                <th className="py-2.5 px-2 text-center">Invoices</th>
                <th className="py-2.5 px-3 text-right">Total Qty Sold</th>
                <th className="py-2.5 px-3 text-right">Avg Selling Price</th>
                <th className="py-2.5 px-3 text-right bg-amber-50 text-amber-950 font-bold">Contract Baseline</th>
                <th className="py-2.5 px-3 text-right">Actual Unit Cost</th>
                <th className="py-2.5 px-3 text-right">Profit / Loss (Δ)</th>
                <th className="py-2.5 px-3 text-right">Total Gain/Loss</th>
                <th className="py-2.5 px-4 text-right bg-blue-50 text-blue-950 font-bold">Total Sales Revenue</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {productSummaryList.length === 0 ? (
                <tr>
                  <td colSpan={11} className="py-10 text-center text-slate-400 font-medium">
                    No sales transactions recorded for the selected period.
                  </td>
                </tr>
              ) : (
                productSummaryList.map((p, idx) => (
                  <tr key={idx} className="hover:bg-slate-50 transition">
                    <td className="py-2.5 px-3 font-mono font-bold text-blue-700">{p.itemCode}</td>
                    <td className="py-2.5 px-3 font-semibold text-slate-800">{p.componentName}</td>
                    <td className="py-2.5 px-3 text-slate-600">{p.vendor}</td>
                    <td className="py-2.5 px-2 text-center font-mono">{p.invoicesCount}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold">{p.totalQty.toLocaleString()}</td>
                    <td className="py-2.5 px-3 text-right font-mono">₹{(p.totalRevenue / (p.totalQty || 1)).toFixed(2)}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold bg-amber-50/40">₹{p.approvedUnitCost.toFixed(2)}</td>
                    <td className="py-2.5 px-3 text-right font-mono">₹{p.actualUnitCost.toFixed(2)}</td>
                    <td className={`py-2.5 px-3 text-right font-mono font-bold ${p.unitGainLoss >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                      {p.unitGainLoss >= 0 ? `+₹${p.unitGainLoss.toFixed(2)}` : `-₹${Math.abs(p.unitGainLoss).toFixed(2)}`}
                    </td>
                    <td className={`py-2.5 px-3 text-right font-mono font-black ${p.totalGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                      {p.totalGainLoss >= 0 ? `+₹${p.totalGainLoss.toFixed(2)}` : `-₹${Math.abs(p.totalGainLoss).toFixed(2)}`}
                    </td>
                    <td className="py-2.5 px-4 text-right font-mono font-bold text-slate-900 bg-blue-50/30">₹{p.totalRevenue.toFixed(2)}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Section 2: Vendor-Wise Period VS Previous Period Comparison */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex flex-wrap justify-between items-center gap-3">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-blue-400" />
            <h3 className="text-xs font-bold uppercase">Vendor-Wise Period VS Previous Period Comparison</h3>
          </div>
          <div className="flex items-center gap-2 text-xs">
            <span className="text-slate-400">Filter: Period From</span>
            <input 
              type="date" 
              value={periodFrom} 
              onChange={e => setPeriodFrom(e.target.value)} 
              className="px-2 py-0.5 bg-slate-800 text-white border border-slate-700 rounded text-xs font-mono" 
            />
            <span className="text-slate-400">To</span>
            <input 
              type="date" 
              value={periodTo} 
              onChange={e => setPeriodTo(e.target.value)} 
              className="px-2 py-0.5 bg-slate-800 text-white border border-slate-700 rounded text-xs font-mono" 
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th rowSpan={2} className="py-2.5 px-4 border-r border-slate-200">Vendor</th>
                <th colSpan={2} className="py-1.5 px-3 text-center border-r border-slate-200 bg-blue-50/50">Current Period ({periodFrom} to {periodTo})</th>
                <th colSpan={2} className="py-1.5 px-3 text-center border-r border-slate-200">Previous Period / Month</th>
                <th colSpan={2} className="py-1.5 px-3 text-center bg-emerald-50/50">Period-on-Period Growth / Variance (Δ)</th>
              </tr>
              <tr className="border-t border-slate-200 text-[9px]">
                <th className="py-1.5 px-3 text-right">Total Sales Revenue</th>
                <th className="py-1.5 px-3 text-right border-r border-slate-200">Cost Variance Gain / Loss</th>
                <th className="py-1.5 px-3 text-right">Total Sales Revenue</th>
                <th className="py-1.5 px-3 text-right border-r border-slate-200">Cost Variance Gain / Loss</th>
                <th className="py-1.5 px-3 text-center">Revenue Growth %</th>
                <th className="py-1.5 px-3 text-right">Variance Delta (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {vendorBreakdowns.map((vb, idx) => (
                <tr key={idx} className="hover:bg-slate-50 font-medium">
                  <td className="py-2.5 px-4 font-bold text-slate-800 flex items-center gap-2 border-r border-slate-100">
                    <span className="w-2 h-2 rounded-full bg-blue-600"></span> {vb.vendorName}
                  </td>
                  <td className="py-2.5 px-3 text-right font-mono font-bold">₹{vb.currentRev.toLocaleString()}</td>
                  <td className={`py-2.5 px-3 text-right font-mono font-bold border-r border-slate-100 ${vb.currentGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                    {vb.currentGainLoss >= 0 ? `+ ₹${vb.currentGainLoss.toLocaleString()}` : `- ₹${Math.abs(vb.currentGainLoss).toLocaleString()}`}
                  </td>
                  <td className="py-2.5 px-3 text-right font-mono text-slate-500">₹0</td>
                  <td className="py-2.5 px-3 text-right font-mono text-slate-500 border-r border-slate-100">+ ₹0</td>
                  <td className="py-2.5 px-3 text-center font-mono font-bold text-emerald-700">+0%</td>
                  <td className={`py-2.5 px-3 text-right font-mono font-bold ${vb.varianceDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                    {vb.varianceDelta >= 0 ? `+ ₹${vb.varianceDelta.toLocaleString()}` : `- ₹${Math.abs(vb.varianceDelta).toLocaleString()}`}
                  </td>
                </tr>
              ))}
              <tr className="bg-slate-900 text-white font-bold">
                <td className="py-2.5 px-4 uppercase text-amber-400">All Vendors Combined</td>
                <td className="py-2.5 px-3 text-right font-mono text-amber-300">₹{allVendorsRev.toLocaleString()}</td>
                <td className="py-2.5 px-3 text-right font-mono text-emerald-400">
                  {allVendorsGainLoss >= 0 ? `+ ₹${allVendorsGainLoss.toLocaleString()}` : `- ₹${Math.abs(allVendorsGainLoss).toLocaleString()}`}
                </td>
                <td className="py-2.5 px-3 text-right font-mono text-slate-400">₹0</td>
                <td className="py-2.5 px-3 text-right font-mono text-slate-400">+ ₹0</td>
                <td className="py-2.5 px-3 text-center font-mono text-emerald-400">+0%</td>
                <td className="py-2.5 px-3 text-right font-mono text-emerald-400">
                  {allVendorsGainLoss >= 0 ? `+ ₹${allVendorsGainLoss.toLocaleString()}` : `- ₹${Math.abs(allVendorsGainLoss).toLocaleString()}`}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      {/* Section 3: Multi-Month Variance Drilldown */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Activity className="w-4 h-4 text-emerald-400" />
            <h3 className="text-xs font-bold uppercase">Multi-Month Variance Drilldown & Top-6 Part Breakdown</h3>
          </div>
          <div className="flex items-center gap-2 text-xs">
            <span className="text-slate-400">Filter Vendor:</span>
            <select
              value={drilldownVendor}
              onChange={e => setDrilldownVendor(e.target.value)}
              className="px-2.5 py-1 bg-slate-800 text-white border border-slate-700 rounded-lg text-xs font-bold"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-4 w-1/3">Filter Category / Drilldown</th>
                <th className="py-2.5 px-3 text-right">Month-1 (May)</th>
                <th className="py-2.5 px-3 text-right">Month-2 (June)</th>
                <th className="py-2.5 px-3 text-right">Month-3 (July)</th>
                <th className="py-2.5 px-4 text-right bg-blue-50 text-blue-950 font-bold">Month-4 (August)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium">
              <tr className="bg-slate-50/50 font-bold">
                <td className="py-2.5 px-4 uppercase text-slate-800">Total Sales Revenue</td>
                <td className="py-2.5 px-3 text-right font-mono text-slate-500">₹0</td>
                <td className="py-2.5 px-3 text-right font-mono text-slate-500">₹0</td>
                <td className="py-2.5 px-3 text-right font-mono text-slate-500">₹0</td>
                <td className="py-2.5 px-4 text-right font-mono font-black text-blue-800 bg-blue-50/40">₹{totalRevenue.toLocaleString()}</td>
              </tr>
              <tr className="bg-slate-50/50 font-bold">
                <td className="py-2.5 px-4 uppercase text-slate-800">Cost Variance Gain / Loss</td>
                <td className="py-2.5 px-3 text-right font-mono text-slate-500">+ ₹0</td>
                <td className="py-2.5 px-3 text-right font-mono text-slate-500">+ ₹0</td>
                <td className="py-2.5 px-3 text-right font-mono text-slate-500">+ ₹0</td>
                <td className={`py-2.5 px-4 text-right font-mono font-black bg-blue-50/40 ${totalCostGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {totalCostGainLoss >= 0 ? `+ ₹${totalCostGainLoss.toLocaleString()}` : `- ₹${Math.abs(totalCostGainLoss).toLocaleString()}`}
                </td>
              </tr>
              
              <tr className="bg-emerald-50/60 font-bold text-emerald-950">
                <td colSpan={5} className="py-2 px-4 flex items-center gap-1.5">
                  <ArrowUpRight className="w-4 h-4 text-emerald-600" /> DrillDown - COST VARIANCE GAIN / LOSS: Top-6 parts with Profit (Favorable Variance)
                </td>
              </tr>
              {topProfitParts.length === 0 ? (
                <tr><td colSpan={5} className="py-3 px-6 text-slate-400 italic">No favorable parts recorded for this period.</td></tr>
              ) : (
                topProfitParts.map((p, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="py-2 px-6 font-mono text-blue-700 font-bold">{p.itemCode} <span className="text-slate-600 font-sans font-normal ml-2">{p.componentName}</span></td>
                    <td className="py-2 px-3 text-right font-mono text-slate-400">+ ₹0</td>
                    <td className="py-2 px-3 text-right font-mono text-slate-400">+ ₹0</td>
                    <td className="py-2 px-3 text-right font-mono text-slate-400">+ ₹0</td>
                    <td className="py-2 px-4 text-right font-mono font-bold text-emerald-700">+ ₹{p.gainLoss.toFixed(2)}</td>
                  </tr>
                ))
              )}

              <tr className="bg-rose-50/60 font-bold text-rose-950">
                <td colSpan={5} className="py-2 px-4 flex items-center gap-1.5">
                  <ArrowDownRight className="w-4 h-4 text-rose-600" /> DrillDown: Top-6 parts with Loss (Unfavorable Variance / Drift)
                </td>
              </tr>
              {topLossParts.length === 0 ? (
                <tr><td colSpan={5} className="py-3 px-6 text-slate-400 italic">No unfavorable drift parts recorded for this period.</td></tr>
              ) : (
                topLossParts.map((p, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="py-2 px-6 font-mono text-rose-700 font-bold">{p.itemCode} <span className="text-slate-600 font-sans font-normal ml-2">{p.componentName}</span></td>
                    <td className="py-2 px-3 text-right font-mono text-slate-400">- ₹0</td>
                    <td className="py-2 px-3 text-right font-mono text-slate-400">- ₹0</td>
                    <td className="py-2 px-3 text-right font-mono text-slate-400">- ₹0</td>
                    <td className="py-2 px-4 text-right font-mono font-bold text-rose-700">- ₹{Math.abs(p.gainLoss).toFixed(2)}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Section 4: Root-Cause Cost Gap Breakdown by Driver */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <DollarSign className="w-4 h-4 text-amber-400" />
            <h3 className="text-xs font-bold uppercase">Root-Cause Cost Gap Breakdown by Driver</h3>
          </div>
          <span className="text-[11px] text-slate-400">Live Sync with Day-Wise Purchases & Invoices</span>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-4 w-1/3">Cost Driver & Parameter Variance</th>
                <th className="py-2.5 px-4 text-right">Haier Appliances Impact</th>
                <th className="py-2.5 px-4 text-right">Atomberg Technologies Impact</th>
                <th className="py-2.5 px-4 text-right">Net Combined Variance (₹)</th>
                <th className="py-2.5 px-4 text-center">Variance Classification</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 font-medium">
              <tr>
                <td className="py-2.5 px-4 font-semibold text-slate-800">Polymer Base Rate Variance (RM Purchase vs Approved Contract)</td>
                <td className={`py-2.5 px-4 text-right font-mono font-bold ${haierRmDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {haierRmDelta >= 0 ? `+ ₹${haierRmDelta.toFixed(2)}` : `- ₹${Math.abs(haierRmDelta).toFixed(2)}`}
                </td>
                <td className={`py-2.5 px-4 text-right font-mono font-bold ${atomRmDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {atomRmDelta >= 0 ? `+ ₹${atomRmDelta.toFixed(2)}` : `- ₹${Math.abs(atomRmDelta).toFixed(2)}`}
                </td>
                <td className={`py-2.5 px-4 text-right font-mono font-black ${(haierRmDelta + atomRmDelta) >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {(haierRmDelta + atomRmDelta) >= 0 ? `+ ₹${(haierRmDelta + atomRmDelta).toFixed(2)}` : `- ₹${Math.abs(haierRmDelta + atomRmDelta).toFixed(2)}`}
                </td>
                <td className="py-2.5 px-4 text-center">
                  <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold ${(haierRmDelta + atomRmDelta) >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                    {(haierRmDelta + atomRmDelta) >= 0 ? 'Favorable' : 'Unfavorable'}
                  </span>
                </td>
              </tr>
              <tr>
                <td className="py-2.5 px-4 font-semibold text-slate-800">Masterbatch Rate Variance (MB Actual Landed vs Approved)</td>
                <td className={`py-2.5 px-4 text-right font-mono font-bold ${haierMbDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {haierMbDelta >= 0 ? `+ ₹${haierMbDelta.toFixed(2)}` : `- ₹${Math.abs(haierMbDelta).toFixed(2)}`}
                </td>
                <td className={`py-2.5 px-4 text-right font-mono font-bold ${atomMbDelta >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {atomMbDelta >= 0 ? `+ ₹${atomMbDelta.toFixed(2)}` : `- ₹${Math.abs(atomMbDelta).toFixed(2)}`}
                </td>
                <td className={`py-2.5 px-4 text-right font-mono font-black ${(haierMbDelta + atomMbDelta) >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {(haierMbDelta + atomMbDelta) >= 0 ? `+ ₹${(haierMbDelta + atomMbDelta).toFixed(2)}` : `- ₹${Math.abs(haierMbDelta + atomMbDelta).toFixed(2)}`}
                </td>
                <td className="py-2.5 px-4 text-center">
                  <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold ${(haierMbDelta + atomMbDelta) >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                    {(haierMbDelta + atomMbDelta) >= 0 ? 'Favorable' : 'Unfavorable'}
                  </span>
                </td>
              </tr>
              <tr>
                <td className="py-2.5 px-4 font-semibold text-slate-800">Cycle Time & Shopfloor Machine Efficiency Variance</td>
                <td className={`py-2.5 px-4 text-right font-mono font-bold ${totalCostGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {totalCostGainLoss >= 0 ? `+ ₹${totalCostGainLoss.toFixed(2)}` : `- ₹${Math.abs(totalCostGainLoss).toFixed(2)}`}
                </td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-400">+ ₹0.00</td>
                <td className={`py-2.5 px-4 text-right font-mono font-black ${totalCostGainLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {totalCostGainLoss >= 0 ? `+ ₹${totalCostGainLoss.toFixed(2)}` : `- ₹${Math.abs(totalCostGainLoss).toFixed(2)}`}
                </td>
                <td className="py-2.5 px-4 text-center">
                  <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold ${totalCostGainLoss >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'}`}>
                    {totalCostGainLoss >= 0 ? 'Favorable' : 'Unfavorable'}
                  </span>
                </td>
              </tr>
              <tr>
                <td className="py-2.5 px-4 font-semibold text-slate-800">Runner Scrap Weight & Regrind Credit Delta</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-400">+ ₹0.00</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-400">- ₹0.00</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-400">+ ₹0.00</td>
                <td className="py-2.5 px-4 text-center">
                  <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600">Neutral</span>
                </td>
              </tr>
              <tr>
                <td className="py-2.5 px-4 font-semibold text-slate-800">BOP / Inserts & Packaging Overhead Variance</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-400">+ ₹0.00</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-400">- ₹0.00</td>
                <td className="py-2.5 px-4 text-right font-mono text-slate-400">+ ₹0.00</td>
                <td className="py-2.5 px-4 text-center">
                  <span className="px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600">Neutral</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
MIS_PAGE_EOF

echo "==> 4. Updating CostingRunEnginePage.jsx (Download Cost Matrix in Red Box Area)..."
cat << 'COSTING_PAGE_EOF' > src/modules/module3-costing-engine/CostingRunEnginePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Calculator, 
  Download, 
  Search, 
  Filter, 
  TrendingUp, 
  TrendingDown,
  Layers,
  ArrowRight
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping, parseMaterialString } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function CostingRunEnginePage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [searchQuery, setSearchQuery] = useState('');

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

  const products = (storeState.baselineProducts || []).filter(p => 
    selectedVendor === 'ALL' || 
    (p.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((p.vendor || '').toLowerCase())
  );

  const filteredProducts = products.filter(p => 
    !searchQuery || 
    (p.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.approvedRm || '').toLowerCase().includes(searchQuery.toLowerCase())
  );

  const simulationRows = filteredProducts.map(prod => {
    const { baseRm, mbGrade } = parseMaterialString(prod.approvedRm || prod.baseRm);
    const rmLookupKey = baseRm || prod.baseRm || prod.approvedRm;
    const mbLookupKey = mbGrade || prod.approvedMb || ((prod.masterbatchPct || 0) > 0 ? 'White MB' : '');

    const rmMap = getActiveRmMapping(rmLookupKey, prod.vendor);
    const mbMap = getActiveMbMapping(mbLookupKey, prod.vendor);

    const detailed = calculateDetailedCost(prod);
    const approvedBaselineCost = Number(prod.approvedCost || detailed.totalCost || 0);
    const simulatedActualCost = Number(detailed.finalLanded || prod.approvedCost || 0);
    const delta = Number((approvedBaselineCost - simulatedActualCost).toFixed(2));

    return {
      ...prod,
      rmLookupKey,
      approvedRmRate: rmMap.approvedPrice || prod.approvedRmPrice || 0,
      activeWaRate: rmMap.activeWaPrice || rmMap.approvedPrice || prod.approvedRmPrice || 0,
      approvedBaselineCost,
      simulatedActualCost,
      delta
    };
  });

  const handleDownloadCostMatrix = () => {
    const exportData = simulationRows.map(r => ({
      "Item Code": r.itemCode,
      "Component Name": r.componentName,
      "Vendor": r.vendor,
      "Approved RM": r.approvedRm,
      "Approved RM Rate (₹/kg)": r.approvedRmRate,
      "Active WA Rate (₹/kg)": r.activeWaRate,
      "Approved Baseline Cost (₹)": r.approvedBaselineCost,
      "Simulated Actual Cost (₹)": r.simulatedActualCost,
      "Profit / Loss Delta (₹)": r.delta
    }));
    const ws = XLSX.utils.json_to_sheet(exportData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Simulation_Matrix");
    XLSX.writeFile(wb, `Cost_Simulation_Matrix_${selectedVendor}_${new Date().toISOString().slice(0,10)}.xlsx`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Calculator className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">3. Dynamic Costing Run Engine</h1>
            <p className="text-[11px] text-slate-300">Live simulation matching contract baselines against active material inward rates.</p>
          </div>
        </div>
        <button 
          onClick={handleDownloadCostMatrix}
          className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm transition"
        >
          <Download className="w-4 h-4" /> Export Simulation (.xlsx)
        </button>
      </div>

      {/* Filter Row */}
      <div className="bg-white p-3 rounded-2xl border border-slate-200 shadow-xs flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-2 flex-1 max-w-md bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-200">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search components by name or part number..."
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            className="w-full bg-transparent border-none outline-hidden text-xs text-slate-800"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-600">Filter Vendor:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="px-3 py-1.5 rounded-xl bg-slate-100 text-slate-900 border border-slate-300 font-bold text-xs"
          >
            <option value="ALL">All Vendors Combined</option>
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Simulation Table with Red Box Download Button on Header */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">Live Product Cost Simulation Matrix</h2>
          </div>
          
          <div className="flex items-center gap-3">
            {/* Red Box Target on Costing Page Header */}
            <button
              onClick={handleDownloadCostMatrix}
              className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1.5 cursor-pointer text-xs shadow-sm transition"
            >
              <Download className="w-3.5 h-3.5" /> Download Cost Matrix (.xlsx)
            </button>
            <span className="text-[11px] text-slate-400 font-mono">{filteredProducts.length} Products</span>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-3">Item Code / Component</th>
                <th className="py-2.5 px-3 text-center">Vendor</th>
                <th className="py-2.5 px-3">Approved RM</th>
                <th className="py-2.5 px-3 text-center">Approved RM Rate</th>
                <th className="py-2.5 px-3 text-center">Active Material Link</th>
                <th className="py-2.5 px-3 text-center text-blue-700">Active WA Rate</th>
                <th className="py-2.5 px-3 text-right bg-amber-50 text-amber-950 font-bold">Approved Baseline</th>
                <th className="py-2.5 px-3 text-right">Simulated Actual</th>
                <th className="py-2.5 px-4 text-center">Profit / Loss (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {simulationRows.length === 0 ? (
                <tr>
                  <td colSpan={9} className="py-12 text-center text-slate-400">
                    No products found for {selectedVendor}. Upload baseline data in <b>1. Baseline Master</b> to run live simulations.
                  </td>
                </tr>
              ) : (
                simulationRows.map(r => (
                  <tr key={r.id || r.itemCode} className="hover:bg-slate-50 transition">
                    <td className="py-2.5 px-3">
                      <div className="font-mono font-bold text-blue-700">{r.itemCode}</div>
                      <div className="font-semibold text-slate-800">{r.componentName}</div>
                    </td>
                    <td className="py-2.5 px-3 text-center">
                      <span className="bg-slate-100 text-slate-700 px-2 py-0.5 rounded text-[10px] font-bold">
                        {r.vendor}
                      </span>
                    </td>
                    <td className="py-2.5 px-3 font-medium text-slate-800">{r.approvedRm}</td>
                    <td className="py-2.5 px-3 text-center font-mono font-bold">₹{Number(r.approvedRmRate).toFixed(2)}/kg</td>
                    <td className="py-2.5 px-3 text-center text-[10px] font-mono text-slate-500">Linked to RM Matrix</td>
                    <td className="py-2.5 px-3 text-center font-mono font-bold text-blue-700">₹{Number(r.activeWaRate).toFixed(2)}/kg</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold bg-amber-50/40">₹{r.approvedBaselineCost.toFixed(2)}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">₹{r.simulatedActualCost.toFixed(2)}</td>
                    <td className="py-2.5 px-4 text-center">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full font-mono font-bold text-xs ${
                        r.delta >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                      }`}>
                        {r.delta >= 0 ? <TrendingUp className="w-3.5 h-3.5" /> : <TrendingDown className="w-3.5 h-3.5" />}
                        {r.delta >= 0 ? `+ ₹${r.delta.toFixed(2)}` : `- ₹${Math.abs(r.delta).toFixed(2)}`}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
COSTING_PAGE_EOF

echo "==> 5. Verifying build strictly on dev-v2..."
npm run build

echo "==> 6. Committing and pushing ONLY to origin/dev-v2 (Zero push to main)..."
git add -A
git commit -m "feat(dev-v2): add purchase/sales template downloads, lock RM page default, and add section download buttons" || echo "dev-v2 clean."
git push origin dev-v2

echo "==> 7. Restarting local dev server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! All 3 features deployed to dev-v2."
echo "-------------------------------------------------------------------"
