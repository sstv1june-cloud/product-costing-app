import React, { useState, useEffect } from 'react';
import { Sliders, Lock, Unlock, History, Calendar, CheckCircle2 } from 'lucide-react';
import { globalStore, subscribeStore, updateVendorScheduleBulk, toggleVendorLockStatus } from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [activeSubTab, setActiveSubTab] = useState('matrix');
  const [validFrom, setValidFrom] = useState('2026-08-01');
  const [validTo, setValidTo] = useState('2026-08-31');
  const [successMsg, setSuccessMsg] = useState(null);

  const isLocked = Boolean(globalStore.vendorLockStatus[selectedVendor]);
  const rmMatrix = globalStore.rmMatrix || [];
  const vendorRows = rmMatrix.filter(r => r.vendor === selectedVendor);
  const purchaseMaster = globalStore.purchaseMaster || [];
  const salesData = (globalStore.salesData || []).filter(s => selectedVendor === 'ALL' || s.vendor === selectedVendor);
  const rmHistoryLogs = (globalStore.rmPriceHistoryLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  const [localRows, setLocalRows] = useState([]);
  useEffect(() => {
    setLocalRows(JSON.parse(JSON.stringify(vendorRows)));
  }, [selectedVendor, rmMatrix]);

  const handleAlternateChange = (rowId, altKey, purchaseCode) => {
    if (isLocked) return;
    const matchedPur = purchaseMaster.find(p => p.code === purchaseCode);
    setLocalRows(prev => prev.map(r => {
      if (r.id === rowId) {
        return {
          ...r,
          [altKey]: matchedPur ? { code: matchedPur.code, name: matchedPur.name, waPrice: matchedPur.waPrice } : null
        };
      }
      return r;
    }));
  };

  const handleSelectActive = (rowId, altKey) => {
    if (isLocked) return;
    setLocalRows(prev => prev.map(r => r.id === rowId ? { ...r, activeSelection: altKey } : r));
  };

  const handleApprovedPriceEdit = (rowId, newPrice) => {
    if (isLocked) return;
    setLocalRows(prev => prev.map(r => r.id === rowId ? { ...r, approvedPrice: Number(newPrice) || 0 } : r));
  };

  const handleSaveAndLock = () => {
    updateVendorScheduleBulk(selectedVendor, validFrom, validTo, localRows);
    setSuccessMsg(`Period schedule locked and synced across all baseline pages for ${selectedVendor}`);
    setTimeout(() => setSuccessMsg(null), 3500);
  };

  const handleToggleUnlock = () => {
    toggleVendorLockStatus(selectedVendor, !isLocked);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Sliders className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">2. RM & MB Tariff & Alternate Weighted Average (WA) Matrix</h1>
            <p className="text-[11px] text-slate-300">
              Active Scope: <span className="text-amber-300 font-bold">{selectedVendor}</span> | Status: <span className={isLocked ? "text-emerald-400 font-bold" : "text-amber-400 font-bold"}>{isLocked ? "🔒 LOCKED & ACTIVE" : "🔓 OPEN (EDITABLE)"}</span>
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button onClick={() => setActiveSubTab('matrix')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeSubTab === 'matrix' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300'}`}>RM & MB Schedule</button>
          <button onClick={() => setActiveSubTab('purchases')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeSubTab === 'purchases' ? 'bg-amber-600 text-white shadow' : 'bg-slate-800 text-slate-300'}`}>Purchases ({purchaseMaster.length})</button>
          <button onClick={() => setActiveSubTab('sales')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeSubTab === 'sales' ? 'bg-indigo-600 text-white shadow' : 'bg-slate-800 text-slate-300'}`}>Sales ({salesData.length})</button>
          <button onClick={() => setActiveSubTab('audit')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeSubTab === 'audit' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300'}`}><History className="w-3.5 h-3.5 inline mr-1" /> Audit Trail ({rmHistoryLogs.length})</button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2.5 rounded-xl flex items-center gap-2 font-bold shadow-xs">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700">SELECT VENDOR:</span>
            <select value={selectedVendor} onChange={e => setSelectedVendor(e.target.value)} className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer">
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
            </select>
          </div>

          <div className="flex items-center gap-2 bg-slate-50 border rounded-xl px-3 py-1 text-slate-700">
            <Calendar className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-[11px]">VALIDITY:</span>
            <input type="date" disabled={isLocked} value={validFrom} onChange={e => setValidFrom(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs disabled:bg-slate-100" />
            <span>&rarr;</span>
            <input type="date" disabled={isLocked} value={validTo} onChange={e => setValidTo(e.target.value)} className="bg-white border rounded px-1.5 py-0.5 font-mono text-xs disabled:bg-slate-100" />
          </div>
        </div>

        {activeSubTab === 'matrix' && (
          <div className="flex items-center gap-2">
            {isLocked ? (
              <button onClick={handleToggleUnlock} className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-amber-300 font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm">
                <Unlock className="w-3.5 h-3.5" /> Unlock Schedule to Edit
              </button>
            ) : (
              <button onClick={handleSaveAndLock} className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm">
                <Lock className="w-3.5 h-3.5" /> Lock & Sync Period Schedule
              </button>
            )}
          </div>
        )}
      </div>

      {activeSubTab === 'matrix' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-900 text-white font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-3 w-56">Approved RM / MB Specification</th>
                  <th className="p-3 w-32 text-right">Approved Rate (₹/kg)</th>
                  <th className="p-3">Alternate Inward Lot 1 (Dropdown)</th>
                  <th className="p-3 text-right w-24">WA Price</th>
                  <th className="p-3">Alternate Inward Lot 2 (Dropdown)</th>
                  <th className="p-3 text-right w-24">WA Price</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {localRows.map(row => (
                  <tr key={row.id} className={isLocked ? "bg-slate-50/70" : "hover:bg-blue-50/30"}>
                    <td className="p-3">
                      <div className="flex items-center gap-1.5">
                        <Lock className="w-3 h-3 text-amber-500" />
                        <span className="font-bold text-slate-900">{row.approvedRm}</span>
                      </div>
                      <span className="text-[10px] text-purple-700 font-bold block">{row.polymer} Polymer Group</span>
                    </td>
                    <td className="p-3 text-right">
                      <input
                        type="number"
                        step="0.01"
                        disabled={isLocked}
                        value={row.approvedPrice}
                        onChange={e => handleApprovedPriceEdit(row.id, e.target.value)}
                        className={`w-24 text-right border font-mono font-black p-1 rounded ${
                          isLocked ? 'bg-slate-200 border-slate-300 text-slate-800' : 'bg-amber-50/50 border-amber-300 text-slate-900'
                        }`}
                      />
                    </td>
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <input
                          type="radio"
                          disabled={isLocked}
                          name={`active-${row.id}`}
                          checked={row.activeSelection === 'alt1'}
                          onChange={() => handleSelectActive(row.id, 'alt1')}
                          className="cursor-pointer"
                        />
                        <select
                          disabled={isLocked}
                          value={row.alt1?.code || ''}
                          onChange={e => handleAlternateChange(row.id, 'alt1', e.target.value)}
                          className="border border-slate-300 rounded-lg p-1 text-xs w-full bg-white font-medium disabled:bg-slate-100"
                        >
                          <option value="">-- Select Inward Material --</option>
                          {purchaseMaster.map(p => (
                            <option key={p.code} value={p.code}>{p.name} (₹{p.waPrice.toFixed(2)})</option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">₹{row.alt1?.waPrice ? Number(row.alt1.waPrice).toFixed(2) : '0.00'}</td>
                    <td className="p-3">
                      <div className="flex items-center gap-2">
                        <input
                          type="radio"
                          disabled={isLocked}
                          name={`active-${row.id}`}
                          checked={row.activeSelection === 'alt2'}
                          onChange={() => handleSelectActive(row.id, 'alt2')}
                          className="cursor-pointer"
                        />
                        <select
                          disabled={isLocked}
                          value={row.alt2?.code || ''}
                          onChange={e => handleAlternateChange(row.id, 'alt2', e.target.value)}
                          className="border border-slate-300 rounded-lg p-1 text-xs w-full bg-white font-medium disabled:bg-slate-100"
                        >
                          <option value="">-- Select Alternate Lot 2 --</option>
                          {purchaseMaster.map(p => (
                            <option key={p.code} value={p.code}>{p.name} (₹{p.waPrice.toFixed(2)})</option>
                          ))}
                        </select>
                      </div>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">₹{row.alt2?.waPrice ? Number(row.alt2.waPrice).toFixed(2) : '0.00'}</td>
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
