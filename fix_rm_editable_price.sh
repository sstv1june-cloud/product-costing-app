#!/usr/bin/env bash
set -e

cat << 'RM_EOF' > src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx
import React, { useState, useEffect } from 'react';
import { 
  Layers, Edit3, Lock, Check, History, Calendar, Upload, Plus, 
  CheckCircle2, ShoppingCart, Truck, X, Download, ShieldCheck, AlertCircle 
} from 'lucide-react';
import { 
  globalStore, subscribeStore, updateVendorScheduleBulk, 
  addManualPurchaseRecord, addManualSaleRecord, uploadBulkSales, uploadBulkPurchases 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [activeTab, setActiveTab] = useState('matrix'); // 'matrix' | 'purchases' | 'sales' | 'history'
  const [isGlobalEditing, setIsGlobalEditing] = useState(false);
  const [successMsg, setSuccessMsg] = useState(null);

  const [showPurchaseModal, setShowPurchaseModal] = useState(false);
  const [showSalesModal, setShowSalesModal] = useState(false);
  const [stagedPurchases, setStagedPurchases] = useState([]);
  const [stagedSales, setStagedSales] = useState([]);

  const [newPur, setNewPur] = useState({
    invoiceNo: 'INV-PUR-901',
    polymer: 'ABS',
    name: '',
    supplier: '',
    qtyKg: '',
    waPrice: '',
    inwardDate: new Date().toISOString().slice(0, 10)
  });

  const defaultPart = (globalStore.baselineList || [])[0] || {};
  const [newSale, setNewSale] = useState({
    invoiceNo: 'INV-SLS-301',
    itemCode: defaultPart.itemCode || '0060226713H',
    componentName: defaultPart.componentName || 'End Cap Top Ref (without Screen Painting )',
    vendor: selectedVendor,
    saleUnit: '',
    invoiceDate: new Date().toISOString().slice(0, 10),
    sellingPrice: ''
  });

  const vendorRows = (globalStore.rmMatrix || []).filter(r => r.vendor === selectedVendor);
  const vendorHistory = (globalStore.rmPriceHistoryLogs || []).filter(h => h.vendor === selectedVendor || selectedVendor === 'ALL');

  const [localRows, setLocalRows] = useState([]);
  const [validFrom, setValidFrom] = useState('2026-08-01');
  const [validTo, setValidTo] = useState('2026-08-31');

  useEffect(() => {
    if (vendorRows.length > 0) {
      setLocalRows(JSON.parse(JSON.stringify(vendorRows)));
      setValidFrom(vendorRows[0].validFrom || '2026-08-01');
      setValidTo(vendorRows[0].validTo || '2026-08-31');
      setIsGlobalEditing(false);
    }
  }, [selectedVendor]);

  const handleToggleGlobalEditLock = () => {
    if (isGlobalEditing) {
      // Commit all changes including updated approvedPrice
      updateVendorScheduleBulk(selectedVendor, validFrom, validTo, localRows);
      setIsGlobalEditing(false);
      setSuccessMsg(`Locked schedule & saved contract pricing for ${selectedVendor} (${validFrom} to ${validTo})`);
      setTimeout(() => setSuccessMsg(null), 3500);
    } else {
      setLocalRows(JSON.parse(JSON.stringify(vendorRows)));
      setIsGlobalEditing(true);
    }
  };

  // Helper for alternate select change
  const handleAlternateSelect = (rowId, altKey, code) => {
    const matchedPur = (globalStore.purchaseMaster || []).find(p => p.code === code);
    setLocalRows(prev => prev.map(r => {
      if (r.id === rowId) {
        return {
          ...r,
          [altKey]: {
            code,
            name: matchedPur ? matchedPur.name : code,
            waPrice: matchedPur ? matchedPur.waPrice : 0
          }
        };
      }
      return r;
    }));
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
            <h1 className="text-sm font-bold">2. RM Tariff & Alternate Weighted Average (WA) Matrix</h1>
            <p className="text-[11px] text-slate-300">
              Synced Scope: <span className="text-amber-300 font-mono font-bold">{selectedVendor} + Period ({validFrom} to {validTo})</span>
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={() => { setStagedPurchases([]); setShowPurchaseModal(true); }}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-amber-600 hover:bg-amber-700 text-white font-bold rounded-lg cursor-pointer shadow-xs"
          >
            <Plus className="w-3.5 h-3.5" /> + Enter / Upload Purchase
          </button>

          <button
            onClick={() => { setStagedSales([]); setShowSalesModal(true); }}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-lg cursor-pointer shadow-xs"
          >
            <Plus className="w-3.5 h-3.5" /> + Enter / Upload Sales
          </button>

          <div className="h-4 w-px bg-slate-700"></div>

          <button
            onClick={() => setActiveTab('matrix')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'matrix' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            RM Schedule
          </button>

          <button
            onClick={() => setActiveTab('purchases')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'purchases' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            Purchases ({(globalStore.purchaseMaster || []).length})
          </button>

          <button
            onClick={() => setActiveTab('sales')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'sales' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            Sales ({(globalStore.salesData || []).length})
          </button>

          <button
            onClick={() => setActiveTab('history')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'history' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            <History className="w-3.5 h-3.5" /> Audit Trail ({vendorHistory.length})
          </button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2 rounded-xl flex items-center gap-2 font-semibold">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      {/* TAB 1: RM SCHEDULE */}
      {activeTab === 'matrix' && (
        <div className="bg-white border border-slate-300 rounded-2xl shadow-sm overflow-hidden p-4 space-y-4">
          <div className="flex flex-wrap items-center justify-between gap-4 bg-slate-50 border border-slate-300 rounded-xl p-3.5">
            <div className="flex items-center gap-2">
              <span className="font-bold text-slate-800 uppercase text-[11px] tracking-wider">Select Vendor:</span>
              <select
                value={selectedVendor}
                disabled={isGlobalEditing}
                onChange={(e) => setSelectedVendor(e.target.value)}
                className="bg-white border-2 border-blue-600 text-blue-950 font-bold px-3 py-1.5 rounded-lg text-xs shadow-xs"
              >
                <option value="Haier">Haier Appliances</option>
                <option value="LG">LG Electronics</option>
                <option value="Whirlpool">Whirlpool India</option>
              </select>
            </div>

            <div className="flex items-center gap-3">
              <span className="font-bold text-slate-800 uppercase text-[11px] tracking-wider flex items-center gap-1">
                <Calendar className="w-3.5 h-3.5 text-amber-600" /> Validity Period:
              </span>
              <div className="flex items-center gap-1.5">
                <span className="text-[10px] font-bold text-slate-500 uppercase">From</span>
                <input
                  type="date"
                  value={validFrom}
                  disabled={!isGlobalEditing}
                  onChange={(e) => setValidFrom(e.target.value)}
                  className={`border rounded-lg p-1 px-2 font-mono font-bold text-xs ${
                    isGlobalEditing ? 'bg-white border-blue-500 text-blue-900 ring-2 ring-blue-200' : 'bg-slate-200/70 border-slate-300 text-slate-600'
                  }`}
                />
              </div>
              <div className="flex items-center gap-1.5">
                <span className="text-[10px] font-bold text-slate-500 uppercase">To</span>
                <input
                  type="date"
                  value={validTo}
                  disabled={!isGlobalEditing}
                  onChange={(e) => setValidTo(e.target.value)}
                  className={`border rounded-lg p-1 px-2 font-mono font-bold text-xs ${
                    isGlobalEditing ? 'bg-white border-blue-500 text-blue-900 ring-2 ring-blue-200' : 'bg-slate-200/70 border-slate-300 text-slate-600'
                  }`}
                />
              </div>
            </div>

            <div>
              <button
                onClick={handleToggleGlobalEditLock}
                className={`px-4 py-2 rounded-xl font-bold transition flex items-center gap-2 cursor-pointer shadow-sm ${
                  isGlobalEditing ? 'bg-emerald-600 hover:bg-emerald-700 text-white animate-pulse' : 'bg-blue-600 hover:bg-blue-700 text-white'
                }`}
              >
                {isGlobalEditing ? <><Check className="w-4 h-4" /> Save & Lock for {selectedVendor} & Period</> : <><Edit3 className="w-4 h-4" /> Global Edit & Lock for Vendor & Period</>}
              </button>
            </div>
          </div>

          <div className="overflow-x-auto border border-slate-300 rounded-xl">
            <table className="min-w-full text-xs text-left border-collapse">
              <thead>
                <tr className="bg-slate-800 text-white font-bold border-b border-slate-700 text-[11px]">
                  <th className="p-3 border-r border-slate-700 min-w-[160px] bg-amber-950/80 text-amber-200">Approved RM</th>
                  <th className="p-3 border-r border-slate-700 text-right min-w-[130px] bg-amber-950/80 text-amber-200">
                    Approved Price (₹/kg)
                  </th>
                  <th className="p-3 border-r border-slate-700 min-w-[220px] bg-blue-950/80 text-blue-200">Alternate RM-1 (Dropdown)</th>
                  <th className="p-3 border-r border-slate-700 text-right min-w-[90px] bg-slate-900 text-slate-300">WA Price</th>
                  <th className="p-3 border-r border-slate-700 min-w-[220px] bg-blue-950/80 text-blue-200">Alternate RM-2 (Dropdown)</th>
                  <th className="p-3 border-r border-slate-700 text-right min-w-[90px] bg-slate-900 text-slate-300">WA Price</th>
                  <th className="p-3 border-r border-slate-700 min-w-[220px] bg-blue-950/80 text-blue-200">Alternate RM-3 (Dropdown)</th>
                  <th className="p-3 border-r border-slate-700 text-right min-w-[90px] bg-slate-900 text-slate-300">WA Price</th>
                  <th className="p-3 text-center min-w-[120px] bg-slate-900 uppercase tracking-wider text-amber-400">Active Effective</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {(isGlobalEditing ? localRows : vendorRows).map((row) => {
                  let activePrice = row.approvedPrice;
                  if (row.activeSelection === 'alt1') activePrice = row.alt1?.waPrice;
                  else if (row.activeSelection === 'alt2') activePrice = row.alt2?.waPrice;
                  else if (row.activeSelection === 'alt3') activePrice = row.alt3?.waPrice;

                  return (
                    <tr key={row.id} className="hover:bg-slate-50">
                      <td className="p-3 border-r border-slate-300 font-bold text-slate-900 bg-amber-50/30">
                        <div className="flex items-center gap-1.5">
                          <Lock className="w-3 h-3 text-amber-600" />
                          <span>{row.approvedRm}</span>
                        </div>
                      </td>

                      {/* EDITABLE APPROVED PRICE FIELD */}
                      <td className="p-2.5 border-r border-slate-300 text-right font-mono font-bold bg-amber-50/40">
                        {isGlobalEditing ? (
                          <div className="flex items-center justify-end gap-1">
                            <span className="text-amber-800 font-bold text-xs">₹</span>
                            <input
                              type="number"
                              step="0.01"
                              value={row.approvedPrice}
                              onChange={(e) => {
                                const val = parseFloat(e.target.value) || 0;
                                setLocalRows(prev => prev.map(r => r.id === row.id ? { ...r, approvedPrice: val } : r));
                              }}
                              className="w-24 border-2 border-amber-500 bg-white text-right px-2 py-1 rounded-lg text-xs font-mono font-black text-amber-950 outline-none ring-2 ring-amber-200"
                            />
                          </div>
                        ) : (
                          <span className="font-mono font-black text-amber-950 text-xs">
                            ₹{row.approvedPrice?.toFixed(2)}
                          </span>
                        )}
                      </td>

                      {/* Alternate 1 */}
                      <td className={`p-2.5 border-r border-slate-300 ${row.activeSelection === 'alt1' ? 'bg-blue-50/90' : ''}`}>
                        <div className="flex items-center gap-1.5">
                          <input type="radio" checked={row.activeSelection === 'alt1'} disabled={!isGlobalEditing} onChange={() => setLocalRows(prev => prev.map(r => r.id === row.id ? { ...r, activeSelection: 'alt1' } : r))} />
                          <select disabled={!isGlobalEditing} value={row.alt1?.code || ''} onChange={(e) => handleAlternateSelect(row.id, 'alt1', e.target.value)} className="w-full bg-white border border-slate-300 rounded p-1 text-xs">
                            {(globalStore.purchaseMaster || []).map(p => (
                              <option key={p.code} value={p.code}>{p.name}</option>
                            ))}
                          </select>
                        </div>
                      </td>
                      <td className="p-3 border-r border-slate-300 text-right font-mono font-bold bg-slate-100/70">₹{row.alt1?.waPrice?.toFixed(2) || '0.00'}</td>

                      {/* Alternate 2 */}
                      <td className={`p-2.5 border-r border-slate-300 ${row.activeSelection === 'alt2' ? 'bg-blue-50/90' : ''}`}>
                        <div className="flex items-center gap-1.5">
                          <input type="radio" checked={row.activeSelection === 'alt2'} disabled={!isGlobalEditing} onChange={() => setLocalRows(prev => prev.map(r => r.id === row.id ? { ...r, activeSelection: 'alt2' } : r))} />
                          <select disabled={!isGlobalEditing} value={row.alt2?.code || ''} onChange={(e) => handleAlternateSelect(row.id, 'alt2', e.target.value)} className="w-full bg-white border border-slate-300 rounded p-1 text-xs">
                            <option value="">-- Select Alternate RM-2 --</option>
                            {(globalStore.purchaseMaster || []).map(p => (
                              <option key={p.code} value={p.code}>{p.name}</option>
                            ))}
                          </select>
                        </div>
                      </td>
                      <td className="p-3 border-r border-slate-300 text-right font-mono font-bold bg-slate-100/70">₹{row.alt2?.waPrice?.toFixed(2) || '0.00'}</td>

                      {/* Alternate 3 */}
                      <td className={`p-2.5 border-r border-slate-300 ${row.activeSelection === 'alt3' ? 'bg-blue-50/90' : ''}`}>
                        <div className="flex items-center gap-1.5">
                          <input type="radio" checked={row.activeSelection === 'alt3'} disabled={!isGlobalEditing} onChange={() => setLocalRows(prev => prev.map(r => r.id === row.id ? { ...r, activeSelection: 'alt3' } : r))} />
                          <select disabled={!isGlobalEditing} value={row.alt3?.code || ''} onChange={(e) => handleAlternateSelect(row.id, 'alt3', e.target.value)} className="w-full bg-white border border-slate-300 rounded p-1 text-xs">
                            <option value="">-- Select Alternate RM-3 --</option>
                            {(globalStore.purchaseMaster || []).map(p => (
                              <option key={p.code} value={p.code}>{p.name}</option>
                            ))}
                          </select>
                        </div>
                      </td>
                      <td className="p-3 border-r border-slate-300 text-right font-mono font-bold bg-slate-100/70">₹{row.alt3?.waPrice?.toFixed(2) || '0.00'}</td>

                      <td className="p-3 text-center bg-slate-100">
                        <span className="font-mono font-black text-blue-900 bg-white border border-blue-300 px-2 py-0.5 rounded shadow-xs block text-xs">
                          ₹{activePrice?.toFixed(2)}/kg
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 2: PURCHASES */}
      {activeTab === 'purchases' && (
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-sm space-y-3">
          <div className="flex justify-between items-center border-b pb-2">
            <h2 className="font-bold text-slate-900 text-sm flex items-center gap-1.5">
              <ShoppingCart className="w-4 h-4 text-amber-600" /> Recorded Purchase Inward Batches (WA Source)
            </h2>
          </div>
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
              <tr>
                <th className="p-2.5">Invoice No</th>
                <th className="p-2.5">Inward Date</th>
                <th className="p-2.5">Polymer Material</th>
                <th className="p-2.5">Supplier</th>
                <th className="p-2.5 text-right">Inward Qty (Kg)</th>
                <th className="p-2.5 text-right font-bold text-blue-950">Purchase Rate (₹/kg)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {(globalStore.purchaseMaster || []).map(p => (
                <tr key={p.code}>
                  <td className="p-2.5 font-mono text-blue-700 font-bold">{p.invoiceNo || p.code}</td>
                  <td className="p-2.5 font-mono text-slate-600">{p.inwardDate}</td>
                  <td className="p-2.5 font-semibold text-slate-900">{p.name}</td>
                  <td className="p-2.5 text-slate-600">{p.supplier}</td>
                  <td className="p-2.5 text-right font-mono">{p.qtyKg?.toLocaleString()} kg</td>
                  <td className="p-2.5 text-right font-mono font-black text-amber-900">₹{p.waPrice?.toFixed(2)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* TAB 3: SALES */}
      {activeTab === 'sales' && (
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-sm space-y-3">
          <div className="flex justify-between items-center border-b pb-2">
            <h2 className="font-bold text-slate-900 text-sm flex items-center gap-1.5">
              <Truck className="w-4 h-4 text-emerald-600" /> Recorded Sales Dispatches
            </h2>
          </div>
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
              <tr>
                <th className="p-2.5">Invoice No</th>
                <th className="p-2.5">Invoice Date</th>
                <th className="p-2.5">Vendor</th>
                <th className="p-2.5">Part Code</th>
                <th className="p-2.5">Part Name</th>
                <th className="p-2.5 text-right">Dispatched Qty</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {(globalStore.salesData || []).map(s => (
                <tr key={s.id}>
                  <td className="p-2.5 font-mono text-blue-700 font-bold">{s.invoiceNo || s.id}</td>
                  <td className="p-2.5 font-mono text-slate-600">{s.invoiceDate}</td>
                  <td className="p-2.5 font-semibold text-slate-700">{s.vendor}</td>
                  <td className="p-2.5 font-mono text-slate-900">{s.itemCode}</td>
                  <td className="p-2.5 font-semibold text-slate-900">{s.componentName}</td>
                  <td className="p-2.5 text-right font-mono font-bold text-emerald-800">{s.saleUnit?.toLocaleString()} pcs</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* TAB 4: AUDIT TRAIL */}
      {activeTab === 'history' && (
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-sm space-y-3">
          <div className="flex justify-between items-center border-b pb-2">
            <h2 className="font-bold text-slate-900 text-sm flex items-center gap-1.5">
              <History className="w-4 h-4 text-purple-600" /> RM Contract & Price Locking Audit Trail
            </h2>
            <span className="text-[11px] text-slate-500 font-mono">Showing history for {selectedVendor}</span>
          </div>

          <div className="overflow-x-auto border border-slate-200 rounded-xl">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-3">Timestamp</th>
                  <th className="p-3">Vendor</th>
                  <th className="p-3">RM Grade</th>
                  <th className="p-3">Validity Period</th>
                  <th className="p-3 text-right">Previous Price</th>
                  <th className="p-3 text-right">New Approved Price</th>
                  <th className="p-3">Active Alternate</th>
                  <th className="p-3">Authorized By</th>
                  <th className="p-3">Change Note</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {vendorHistory.map(log => (
                  <tr key={log.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="p-3 font-semibold text-slate-700">{log.vendor}</td>
                    <td className="p-3 font-bold text-blue-900">{log.rmGrade}</td>
                    <td className="p-3 font-mono text-amber-800">{log.period}</td>
                    <td className="p-3 text-right font-mono text-slate-500">₹{log.previousRate?.toFixed(2)}</td>
                    <td className="p-3 text-right font-mono font-black text-amber-950">₹{log.newRate?.toFixed(2)}</td>
                    <td className="p-3 font-semibold text-purple-900">{log.activeAlternate}</td>
                    <td className="p-3 text-slate-700">{log.changedBy}</td>
                    <td className="p-3 text-slate-600 italic">{log.reason}</td>
                  </tr>
                ))}
                {vendorHistory.length === 0 && (
                  <tr>
                    <td colSpan="9" className="p-4 text-center text-slate-400 italic">No RM contract modification logs for {selectedVendor} yet.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

    </div>
  );
}
RM_EOF

# 2. Update updateVendorScheduleBulk in masterStore.js to accurately record price shifts
cat << 'STORE_UPDATE_EOF' > /tmp/update_store.js
import fs from 'fs';

let content = fs.readFileSync('src/shared/masterStore.js', 'utf8');

// Replace updateVendorScheduleBulk with precise logger
const newFunc = `export const updateVendorScheduleBulk = (vendor, validFrom, validTo, updatedRows) => {
  const previousRows = (globalStore.rmMatrix || []).filter(r => r.vendor === vendor);

  globalStore.rmMatrix = globalStore.rmMatrix.map(row => {
    if (row.vendor === vendor) {
      const match = updatedRows.find(u => u.id === row.id);
      return match ? { ...match, validFrom, validTo } : { ...row, validFrom, validTo };
    }
    return row;
  });

  // Log each RM update to rmPriceHistoryLogs
  updatedRows.forEach(uRow => {
    const prev = previousRows.find(p => p.id === uRow.id);
    let altText = uRow.activeSelection === 'alt1' ? \`Alternate 1 (\${uRow.alt1?.name || ''})\` : 
                  uRow.activeSelection === 'alt2' ? \`Alternate 2 (\${uRow.alt2?.name || ''})\` : 
                  uRow.activeSelection === 'alt3' ? \`Alternate 3 (\${uRow.alt3?.name || ''})\` : 'Primary Approved';

    const priceChanged = Math.abs((prev?.approvedPrice || 0) - (uRow.approvedPrice || 0)) >= 0.01;
    const note = priceChanged 
      ? \`Approved price updated from ₹\${(prev?.approvedPrice || uRow.approvedPrice).toFixed(2)} to ₹\${uRow.approvedPrice.toFixed(2)} for period (\${validFrom} to \${validTo})\`
      : \`Locked period (\${validFrom} to \${validTo}) with \${altText}\`;

    globalStore.rmPriceHistoryLogs.unshift({
      id: \`LOG-RM-\${Date.now()}-\${Math.random().toString(36).substr(2, 4)}\`,
      timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
      vendor,
      rmGrade: uRow.approvedRm,
      action: priceChanged ? "Approved Price & Period Updated" : "Schedule Locked",
      period: \`\${validFrom} to \${validTo}\`,
      previousRate: prev?.approvedPrice || uRow.approvedPrice,
      newRate: uRow.approvedPrice,
      activeAlternate: altText,
      changedBy: "Engineering Head",
      reason: note
    });
  });

  notifyStore();
};`;

content = content.replace(/export const updateVendorScheduleBulk = [\s\S]*?\n\};/, newFunc);
fs.writeFileSync('src/shared/masterStore.js', content, 'utf8');
STORE_UPDATE_EOF

node /tmp/update_store.js

echo "==> Editable Approved Price and RM Audit Trail deployed successfully."
