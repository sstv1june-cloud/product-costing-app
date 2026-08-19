#!/usr/bin/env bash
set -e

echo "==> 1. Updating RMPriceMatrixPage.xlsx with Purchase & Sales Template download and Excel upload..."
cat << 'MATRIX_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Layers, Lock, Unlock, Calendar, History, 
  ArrowRightLeft, FileSpreadsheet, Download, Upload, CheckCircle2, AlertCircle 
} from 'lucide-react';
import { 
  globalStore, subscribeStore, toggleVendorLockStatus, 
  updateVendorScheduleBulk, uploadBulkPurchases, uploadBulkSales, notifyStore 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [activeTab, setActiveTab] = useState('schedule'); // 'schedule' | 'purchases' | 'sales' | 'audit'

  const [validFrom, setValidFrom] = useState('2026-08-01');
  const [validTo, setValidTo] = useState('2026-08-31');
  const [uploadStatus, setUploadStatus] = useState(null);

  const isLocked = globalStore.vendorLockStatus?.[selectedVendor] ?? true;

  const vendorMatrixRows = (globalStore.rmMatrix || []).filter(r => r.vendor === selectedVendor);
  const vendorPurchases = (globalStore.purchaseMaster || []).filter(p => true);
  const vendorSales = (globalStore.salesData || []).filter(s => selectedVendor === 'ALL' || s.vendor === selectedVendor);
  const auditLogs = (globalStore.rmPriceHistoryLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  const [editableRows, setEditableRows] = useState(vendorMatrixRows);
  useEffect(() => {
    setEditableRows(globalStore.rmMatrix.filter(r => r.vendor === selectedVendor));
  }, [selectedVendor, globalStore.rmMatrix]);

  const handleToggleLock = () => {
    toggleVendorLockStatus(selectedVendor, !isLocked);
  };

  const handleRateChange = (rowId, newRate) => {
    setEditableRows(prev => prev.map(r => r.id === rowId ? { ...r, approvedPrice: Number(newRate) } : r));
  };

  const handleAltChange = (rowId, selKey) => {
    setEditableRows(prev => prev.map(r => r.id === rowId ? { ...r, activeSelection: selKey } : r));
  };

  const handleSaveSchedule = () => {
    updateVendorScheduleBulk(selectedVendor, validFrom, validTo, editableRows);
    setUploadStatus({ type: 'success', text: `Schedule locked & pricing updated successfully for ${selectedVendor}!` });
    setTimeout(() => setUploadStatus(null), 4000);
  };

  // --- DOWNLOAD TEMPLATES ---
  const downloadTemplate = (type) => {
    let csvContent = "data:text/csv;charset=utf-8,";
    if (type === 'purchase') {
      csvContent += "code,invoiceNo,name,polymer,supplier,waPrice,inwardDate,qtyKg\r\n";
      csvContent += "PUR-PP-02,INV-PUR-9001,PP H110MA Prime Inward,PP,Reliance Industries,135.83,2026-08-18,5000\r\n";
      csvContent += "PUR-MB-02,INV-PUR-9002,White Masterbatch Grade,MB,Clariant,258.54,2026-08-18,1000\r\n";
    } else {
      csvContent += "invoiceNo,itemCode,componentName,vendor,saleUnit,invoiceDate,sellingPrice\r\n";
      csvContent += "INV-SLS-101,A101701,Aris Top Canopy- Gloss White,Atomberg,1500,2026-08-18,14.50\r\n";
    }

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `${type}_template_cpc.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // --- UPLOAD DATA ---
  const handleFileUpload = (e, type) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const text = event.target.result;
        const lines = text.split(/\r\n|\n/).filter(l => l.trim() !== '');
        if (lines.length < 2) {
          alert("Uploaded file is empty or formatted incorrectly.");
          return;
        }

        const headers = lines[0].split(',').map(h => h.trim());
        const parsedRows = [];

        for (let i = 1; i < lines.length; i++) {
          const vals = lines[i].split(',').map(v => v.trim());
          if (vals.length >= headers.length) {
            if (type === 'purchase') {
              parsedRows.log({
                code: vals[0] || `PUR-${Date.now()}-${i}`,
                invoiceNo: vals[1] || `INV-PUR-${i}`,
                name: vals[2] || 'Raw Material Inward',
                polymer: vals[3] || 'PP',
                supplier: vals[4] || 'Supplier Name',
                waPrice: Number(vals[5]) || 135.0,
                inwardDate: vals[6] || '2026-08-18',
                qtyKg: Number(vals[7]) || 1000
              });
            } else {
              parsedRows.push({
                id: `INV-SLS-${Date.now()}-${i}`,
                invoiceNo: vals[0] || `INV-${i}`,
                itemCode: vals[1] || 'A101701',
                componentName: vals[2] || 'Component Name',
                vendor: vals[3] || selectedVendor,
                saleUnit: Number(vals[4]) || 1000,
                invoiceDate: vals[5] || '2026-08-18',
                sellingPrice: Number(vals[6]) || 15.00
              });
            }
          }
        }

        // Fallback robust parser if CSV lines don't match commas directly
        const cleanRows = [];
        for (let i = 1; i < lines.length; i++) {
          const parts = lines[i].split(',');
          if (type === 'purchase') {
            cleanRows.push({
              code: parts[0]?.trim() || `PUR-${Date.now()}-${i}`,
              invoiceNo: parts[1]?.trim() || `INV-PUR-${i}`,
              name: parts[2]?.trim() || 'Polymer Inward',
              polymer: parts[3]?.trim() || 'PP',
              supplier: parts[4]?.trim() || 'Supplier',
              waPrice: Number(parts[5]) || 135.0,
              inwardDate: parts[6]?.trim() || '2026-08-18',
              qtyKg: Number(parts[7]) || 1000
            });
          } else {
            cleanRows.push({
              id: `INV-SLS-${Date.now()}-${i}`,
              invoiceNo: parts[0]?.trim() || `INV-${i}`,
              itemCode: parts[1]?.trim() || 'A101701',
              componentName: parts[2]?.trim() || 'Component',
              vendor: parts[3]?.trim() || selectedVendor,
              saleUnit: Number(parts[4]) || 1000,
              invoiceDate: parts[5]?.trim() || '2026-08-18',
              sellingPrice: Number(parts[6]) || 15.00
            });
          }
        }

        if (type === 'purchase') {
          uploadBulkPurchases(cleanRows);
          setUploadStatus({ type: 'success', text: `Successfully uploaded ${cleanRows.length} purchase records!` });
        } else {
          uploadBulkSales(cleanRows);
          setUploadStatus({ type: 'success', text: `Successfully uploaded ${cleanRows.length} sales records!` });
        }
        notifyStore();
        setTimeout(() => setUploadStatus(null), 4000);
      } catch (err) {
        alert("Error parsing CSV file: " + err.message);
      }
    };
    reader.readAsText(file);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Layers className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">2. RM & MB Tariff & Alternate Weighted Average (WA) Matrix</h1>
            <p className="text-[11px] text-slate-300">
              Active Scope: <span className="font-bold text-amber-300">{selectedVendor}</span> | Status: <span className={isLocked ? "text-emerald-400 font-bold" : "text-amber-400 font-bold"}>{isLocked ? "LOCKED & ACTIVE" : "UNLOCKED FOR EDITING"}</span>
            </p>
          </div>
        </div>

        <div className="flex bg-slate-800 p-1 rounded-xl border border-slate-700">
          <button onClick={() => setActiveTab('schedule')} className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'schedule' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}>RM & MB Schedule</button>
          <button onClick={() => setActiveTab('purchases')} className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'purchases' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}>Purchases ({vendorPurchases.length})</button>
          <button onClick={() => setActiveTab('sales')} className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'sales' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}>Sales ({vendorSales.length})</button>
          <button onClick={() => setActiveTab('audit')} className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'audit' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}>Audit Trail ({auditLogs.length})</button>
        </div>
      </div>

      {uploadStatus && (
        <div className={`p-3 rounded-xl border flex items-center gap-2 font-bold ${uploadStatus.type === 'success' ? 'bg-emerald-50 border-emerald-300 text-emerald-800' : 'bg-rose-50 border-rose-300 text-rose-800'}`}>
          <CheckCircle2 className="w-4 h-4 text-emerald-600" /> {uploadStatus.text}
        </div>
      )}

      {/* Selector & Validity Bar */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700">SELECT VENDOR:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 border rounded-xl px-3 py-1 text-slate-700">
            <Calendar className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-[11px]">VALIDITY:</span>
            <input type="date" value={validFrom} disabled={isLocked} onChange={e => setValidFrom(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs disabled:bg-slate-100" />
            <span>&rarr;</span>
            <input type="date" value={validTo} disabled={isLocked} onChange={e => setToDate(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs disabled:bg-slate-100" />
          </div>
        </div>

        <div>
          <button
            onClick={handleToggleLock}
            className={`px-4 py-1.5 rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-xs ${isLocked ? 'bg-amber-600 hover:bg-amber-700 text-white' : 'bg-emerald-600 hover:bg-emerald-700 text-white'}`}
          >
            {isLocked ? <Unlock className="w-3.5 h-3.5" /> : <Lock className="w-3.5 h-3.5" />}
            {isLocked ? 'Unlock Schedule to Edit' : 'Lock Schedule & Confirm'}
          </button>
        </div>
      </div>

      {/* TAB 1: SCHEDULE */}
      {activeTab === 'schedule' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <FileSpreadsheet className="w-4 h-4 text-blue-400" /> Approved Raw Material & Masterbatch Tariff Matrix
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{editableRows.length} Active Specs</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">APPROVED RM / MB SPECIFICATION</th>
                  <th className="p-3 text-right bg-amber-50">APPROVED RATE (₹/KG)</th>
                  <th className="p-3">ALTERNATE INWARD LOT 1 (DROPDOWN)</th>
                  <th className="p-3 text-right bg-blue-50">WA PRICE</th>
                  <th className="p-3">ALTERNATE INWARD LOT 2 (DROPDOWN)</th>
                  <th className="p-3 text-right">WA PRICE</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {editableRows.map((row) => (
                  <tr key={row.id} className="hover:bg-slate-50">
                    <td className="p-3">
                      <span className="font-bold text-slate-900 block">{row.approvedRm}</span>
                      <span className="text-[10px] text-purple-700 font-bold uppercase">{row.polymer} Polymer Group</span>
                    </td>
                    <td className="p-3 text-right font-mono font-bold bg-amber-50/50">
                      {isLocked ? (
                        <span>₹{Number(row.approvedPrice).toFixed(2)}</span>
                      ) : (
                        <input
                          type="number"
                          step="0.1"
                          value={row.approvedPrice}
                          onChange={e => handleRateChange(row.id, e.target.value)}
                          className="w-24 border border-blue-500 rounded px-2 py-0.5 font-mono text-right font-bold bg-white"
                        />
                      )}
                    </td>
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <input
                          type="radio"
                          name={`sel-${row.id}`}
                          checked={row.activeSelection === 'alt1'}
                          disabled={isLocked}
                          onChange={() => handleAltChange(row.id, 'alt1')}
                          className="cursor-pointer"
                        />
                        <select
                          disabled={isLocked}
                          value={row.alt1?.code || ''}
                          onChange={e => {
                            const found = globalStore.purchaseMaster.find(p => p.code === e.target.value);
                            if (found) {
                              setEditableRows(prev => prev.map(r => r.id === row.id ? { ...r, alt1: { code: found.code, name: found.name, waPrice: found.waPrice } } : r));
                            }
                          }}
                          className="border border-slate-300 rounded-lg px-2 py-1 bg-white font-semibold outline-none flex-1 disabled:bg-slate-50"
                        >
                          {globalStore.purchaseMaster.filter(p => p.polymer === row.polymer || row.polymer === 'MB').map(p => (
                            <option key={p.code} value={p.code}>{p.name} (₹{p.waPrice})</option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-blue-900 bg-blue-50/50">
                      ₹{Number(row.alt1?.waPrice || row.approvedPrice).toFixed(2)}/kg
                    </td>
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <input
                          type="radio"
                          name={`sel-${row.id}`}
                          checked={row.activeSelection === 'alt2'}
                          disabled={isLocked}
                          onChange={() => handleAltChange(row.id, 'alt2')}
                          className="cursor-pointer"
                        />
                        <select
                          disabled={isLocked}
                          value={row.alt2?.code || ''}
                          onChange={e => {
                            const found = globalStore.purchaseMaster.find(p => p.code === e.target.value);
                            if (found) {
                              setEditableRows(prev => prev.map(r => r.id === row.id ? { ...r, alt2: { code: found.code, name: found.name, waPrice: found.waPrice } } : r));
                            }
                          }}
                          className="border border-slate-300 rounded-lg px-2 py-1 bg-white font-semibold outline-none flex-1 disabled:bg-slate-50"
                        >
                          <option value="">-- Select Alternate Lot 2 --</option>
                          {globalStore.purchaseMaster.filter(p => p.polymer === row.polymer || row.polymer === 'MB').map(p => (
                            <option key={p.code} value={p.code}>{p.name} (₹{p.waPrice})</option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold">
                      ₹{Number(row.alt2?.waPrice || 0).toFixed(2)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {!isLocked && (
            <div className="p-4 bg-slate-50 border-t flex justify-end">
              <button
                onClick={handleSaveSchedule}
                className="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl shadow cursor-pointer flex items-center gap-1.5"
              >
                <CheckCircle2 className="w-4 h-4" /> Save & Lock Schedule
              </button>
            </div>
          )}
        </div>
      )}

      {/* TAB 2: PURCHASES (WITH TEMPLATE & UPLOAD) */}
      {activeTab === 'purchases' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden space-y-4 p-4">
          <div className="flex flex-wrap justify-between items-center gap-3 bg-slate-900 text-white p-4 rounded-xl">
            <div>
              <h2 className="text-sm font-bold flex items-center gap-2">
                <FileSpreadsheet className="w-4 h-4 text-blue-400" /> Purchase Inward Master & Material Lot Repository
              </h2>
              <p className="text-[11px] text-slate-300">Upload bulk inward lots or download template for offline preparation.</p>
            </div>
            <div className="flex items-center gap-3">
              <button
                onClick={() => downloadTemplate('purchase')}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 border border-slate-600 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm"
              >
                <Download className="w-4 h-4 text-blue-400" /> Download Purchase Template
              </button>
              <label className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm">
                <Upload className="w-4 h-4" /> Upload Purchase CSV/Excel
                <input type="file" accept=".csv, .txt" onChange={e => handleFileUpload(e, 'purchase')} className="hidden" />
              </label>
            </div>
          </div>

          <div className="overflow-x-auto border border-slate-200 rounded-xl">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b">
                <tr>
                  <th className="p-3">Inward Code</th>
                  <th className="p-3">Invoice No</th>
                  <th className="p-3">Material Name</th>
                  <th className="p-3">Polymer</th>
                  <th className="p-3">Supplier</th>
                  <th className="p-3 text-right">WA Price (₹/kg)</th>
                  <th className="p-3">Inward Date</th>
                  <th className="p-3 text-right">Qty (Kg)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {globalStore.purchaseMaster.map((p, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="p-3 font-mono font-bold text-blue-700">{p.code}</td>
                    <td className="p-3 font-mono text-slate-600">{p.invoiceNo}</td>
                    <td className="p-3 font-semibold text-slate-900">{p.name}</td>
                    <td className="p-3"><span className="bg-purple-100 text-purple-900 font-bold px-2 py-0.5 rounded text-[10px]">{p.polymer}</span></td>
                    <td className="p-3 text-slate-700">{p.supplier}</td>
                    <td className="p-3 text-right font-mono font-bold text-blue-900">₹{p.waPrice.toFixed(2)}</td>
                    <td className="p-3 font-mono text-slate-500">{p.inwardDate}</td>
                    <td className="p-3 text-right font-mono font-bold">{p.qtyKg?.toLocaleString()} kg</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 3: SALES (WITH TEMPLATE & UPLOAD) */}
      {activeTab === 'sales' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden space-y-4 p-4">
          <div className="flex flex-wrap justify-between items-center gap-3 bg-slate-900 text-white p-4 rounded-xl">
            <div>
              <h2 className="text-sm font-bold flex items-center gap-2">
                <FileSpreadsheet className="w-4 h-4 text-blue-400" /> Sales & Dispatch Invoices Master Repository
              </h2>
              <p className="text-[11px] text-slate-300">Upload bulk sales orders or download template for offline preparation.</p>
            </div>
            <div className="flex items-center gap-3">
              <button
                onClick={() => downloadTemplate('sales')}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 border border-slate-600 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm"
              >
                <Download className="w-4 h-4 text-blue-400" /> Download Sales Template
              </button>
              <label className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm">
                <Upload className="w-4 h-4" /> Upload Sales CSV/Excel
                <input type="file" accept=".csv, .txt" onChange={e => handleFileUpload(e, 'sales')} className="hidden" />
              </label>
            </div>
          </div>

          <div className="overflow-x-auto border border-slate-200 rounded-xl">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b">
                <tr>
                  <th className="p-3">Invoice No</th>
                  <th className="p-3">Part Code</th>
                  <th className="p-3">Component Name</th>
                  <th className="p-3 text-center">Vendor</th>
                  <th className="p-3 text-right">Qty Sold (pcs)</th>
                  <th className="p-3 font-mono">Invoice Date</th>
                  <th className="p-3 text-right">Selling Price (₹)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {globalStore.salesData.map((s, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="p-3 font-mono font-bold text-blue-700">{s.invoiceNo}</td>
                    <td className="p-3 font-mono font-bold text-slate-800">{s.itemCode}</td>
                    <td className="p-3 font-semibold text-slate-900">{s.componentName}</td>
                    <td className="p-3 text-center"><span className="bg-slate-100 border px-2 py-0.5 rounded font-bold text-[10px]">{s.vendor}</span></td>
                    <td className="p-3 text-right font-mono font-bold">{s.saleUnit?.toLocaleString()}</td>
                    <td className="p-3 font-mono text-slate-500">{s.invoiceDate}</td>
                    <td className="p-3 text-right font-mono font-bold text-emerald-800">₹{s.sellingPrice?.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 4: AUDIT TRAIL */}
      {activeTab === 'audit' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden p-4 space-y-3">
          <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2">
            <History className="w-4 h-4 text-blue-600" /> RM & Tariff Price Lock Audit Trail Log
          </h2>
          <div className="overflow-x-auto border rounded-xl">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b">
                <tr>
                  <th className="p-3">Timestamp</th>
                  <th className="p-3">Vendor</th>
                  <th className="p-3">RM / MB Grade</th>
                  <th className="p-3">Action</th>
                  <th className="p-3">Period</th>
                  <th className="p-3 text-right">Previous Rate</th>
                  <th className="p-3 text-right font-bold">New Rate</th>
                  <th className="p-3">Reason / Note</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {auditLogs.length === 0 ? (
                  <tr><td colSpan="8" className="p-6 text-center text-slate-400">No tariff changes or locks recorded for this vendor yet.</td></tr>
                ) : (
                  auditLogs.map((log) => (
                    <tr key={log.id} className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-slate-500">{log.timestamp}</td>
                      <td className="p-3 font-bold text-slate-800">{log.vendor}</td>
                      <td className="p-3 font-semibold text-blue-900">{log.rmGrade}</td>
                      <td className="p-3"><span className="bg-blue-100 text-blue-800 px-2 py-0.5 rounded font-bold text-[10px]">{log.action}</span></td>
                      <td className="p-3 font-mono">{log.period}</td>
                      <td className="p-3 text-right font-mono">₹{Number(log.previousRate || 0).toFixed(2)}</td>
                      <td className="p-3 text-right font-mono font-black text-emerald-700">₹{Number(log.newRate || 0).toFixed(2)}</td>
                      <td className="p-3 text-slate-600">{log.reason}</td>
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
MATRIX_EOF

echo "==> 2. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Purchase & Sales template download and upload successfully deployed."
