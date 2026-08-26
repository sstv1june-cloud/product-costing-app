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
