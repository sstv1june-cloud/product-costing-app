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
  const [activeSubTab, setActiveSubTab] = useState('matrix'); // 'matrix' | 'purchases' | 'sales' | 'changelog'

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

  const handlePriceChange = (rowId, newPrice) => {
    if (isLocked) return;
    const num = parseFloat(newPrice);
    updateRmMappingRow(rowId, { approvedPrice: isNaN(num) ? '' : num });
  };

  const handleSave = () => {
    if (isLocked) {
      alert('Cannot save: Page is LOCKED. Click "Unlock to Edit" first.');
      return;
    }
    saveVendorPeriodSchedule();
    alert(`Successfully saved RM / MB Price Mapping for ${selectedVendor} (${periodFrom} to ${periodTo})`);
  };

  // Day-wise Purchases Ingest
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

  // Day-wise Sales Ingest
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
      {/* Header bar with Always-Locked Toggle */}
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

        {/* Global Lock / Unlock */}
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

      {/* Navigation Sub-Tabs */}
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
          <ShoppingCart className="w-4 h-4 text-emerald-300" /> Day-wise Purchases ({filteredPurchases.length})
        </button>
        <button
          onClick={() => setActiveSubTab('sales')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'sales' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <Truck className="w-4 h-4 text-purple-300" /> Day-wise Sales ({filteredSales.length})
        </button>
        <button
          onClick={() => setActiveSubTab('changelog')}
          className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-2 transition-all cursor-pointer ${activeSubTab === 'changelog' ? 'bg-blue-600 text-white shadow' : 'text-slate-700 hover:bg-slate-300'}`}
        >
          <History className="w-4 h-4 text-amber-300" /> Baseline & RM Change Log ({changeLogs.length})
        </button>
      </div>

      {/* Filter / Vendor / Period Bar */}
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

      {/* Lock Notice Banner */}
      {isLocked && (
        <div className="bg-amber-50 border border-amber-300 rounded-xl p-3 flex items-center gap-2 text-amber-900 text-xs">
          <Lock className="w-4 h-4 text-amber-600 shrink-0" />
          <span><b>Protected State:</b> This page is locked against unauthorized modifications. Click <b>"Page Locked (Click to Unlock & Edit)"</b> above to adjust prices, switch active alternates, or upload transactions.</span>
        </div>
      )}

      {/* SUB-TAB 1: Matrix Layout */}
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
                <tr className="bg-slate-100 text-slate-500 text-[10px] italic border-b border-slate-300">
                  <td className="p-2 border-r border-slate-200">Contract Master Spec</td>
                  <td className="p-2 border-r border-slate-200 text-center text-amber-800 font-semibold bg-amber-50">
                    (Linked to Baseline Edit Page Approved parameter)
                  </td>
                  <td colSpan="6" className="p-2 text-center text-blue-800 font-semibold bg-blue-50">
                    On WA method from Purchase Inward Lots
                  </td>
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
                          value={row.approvedPrice}
                          disabled={isLocked}
                          onChange={(e) => handlePriceChange(row.id, e.target.value)}
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

      {/* SUB-TAB 2: Day-wise Purchases Ingest Table */}
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

      {/* SUB-TAB 3: Day-wise Sales Ingest Table */}
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

      {/* SUB-TAB 4: Baseline & RM Change Log / Audit Trail */}
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
