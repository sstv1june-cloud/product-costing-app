#!/usr/bin/env bash
set -e

echo "==> Updating RMPriceMatrixPage.jsx to make Approved Price editable with input & sync..."
RM_FILE=$(find src -name "*RMPriceMatrixPage*.jsx" | head -n 1)
[ -z "$RM_FILE" ] && RM_FILE="src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx"

cat << 'EOF_RM' > "$RM_FILE"
import React, { useState, useEffect } from 'react';
import { 
  Database, Lock, Unlock, Save, Filter, Calendar, CheckCircle2, ShieldCheck, Edit3 
} from 'lucide-react';
import { 
  globalStore, 
  subscribeStore, 
  toggleGlobalLock, 
  updateRmMappingRow, 
  saveVendorPeriodSchedule 
} from '../../shared/masterStore';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');

  const isLocked = !!globalStore.isGlobalLocked;
  const mappingsList = globalStore.rmMappingsData || [];

  const filteredRows = mappingsList.filter(row => {
    return (selectedVendor === 'ALL' || row.vendor.toLowerCase() === selectedVendor.toLowerCase());
  });

  const handlePriceChange = (rowId, newPrice) => {
    if (isLocked) return;
    const num = parseFloat(newPrice);
    updateRmMappingRow(rowId, { approvedPrice: isNaN(num) ? '' : num });
  };

  const handleSave = () => {
    if (isLocked) {
      alert('Cannot save: Global Lock is currently active! Please unlock first.');
      return;
    }
    saveVendorPeriodSchedule(selectedVendor, periodFrom, periodTo);
    alert(`Successfully saved RM / MB Price Mapping for ${selectedVendor} (${periodFrom} to ${periodTo})`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Header bar */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Database className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-base font-bold">RM Mapping Page</h1>
            <p className="text-[11px] text-slate-300">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        {/* Global Unlock & Lock for Save */}
        <div className="flex items-center gap-2">
          <button
            onClick={toggleGlobalLock}
            className={`px-4 py-2 rounded-xl font-bold flex items-center gap-2 text-xs cursor-pointer shadow transition-all ${isLocked ? 'bg-rose-600 hover:bg-rose-700 text-white' : 'bg-emerald-600 hover:bg-emerald-700 text-white'}`}
          >
            {isLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4" />}
            {isLocked ? 'Global Locked (Editing Disabled)' : 'Global Unlocked & Active'}
          </button>
        </div>
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
              <option value="ALL">All Vendors</option>
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
              className="border px-2 py-0.5 rounded text-xs bg-white disabled:bg-slate-100"
            />
            <span className="text-slate-500 font-medium">To</span>
            <input
              type="date"
              value={periodTo}
              disabled={isLocked}
              onChange={(e) => setPeriodTo(e.target.value)}
              className="border px-2 py-0.5 rounded text-xs bg-white disabled:bg-slate-100"
            />
          </div>
        </div>

        <button
          onClick={handleSave}
          disabled={isLocked}
          className="px-5 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-400 text-white rounded-xl font-bold flex items-center gap-2 text-xs cursor-pointer shadow transition-all"
        >
          <Save className="w-4 h-4" /> Save for Vendor + period
        </button>
      </div>

      {/* Grid Layout with Editable Approved Price */}
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
                  {/* Approved RM/MB Code */}
                  <td className="p-3 border-r border-slate-200">
                    <span className="px-2 py-0.5 rounded text-[10px] font-bold mr-2 bg-slate-200 text-slate-800">
                      {row.type === 'RM' ? 'RM Code' : 'Masterbatch Code'}
                    </span>
                    <span className="font-mono font-bold text-slate-900">{row.approvedCode}</span>
                  </td>

                  {/* Editable Approved Price */}
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

                  {/* Alt 1 Code & WA Price */}
                  <td className="p-3 border-r border-slate-200">
                    <div className="flex items-center justify-between gap-1">
                      <span className="font-semibold text-blue-950">{row.alt1Code}</span>
                      <button
                        onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt1' })}
                        disabled={isLocked}
                        className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt1' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'}`}
                      >
                        {row.activeAlt === 'alt1' ? 'Active' : 'Set'}
                      </button>
                    </div>
                  </td>
                  <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-blue-700 bg-blue-50/50">
                    ₹{Number(row.alt1Price).toFixed(2)}
                  </td>

                  {/* Alt 2 Code & WA Price */}
                  <td className="p-3 border-r border-slate-200">
                    <div className="flex items-center justify-between gap-1">
                      <span className="text-slate-700">{row.alt2Code}</span>
                      <button
                        onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt2' })}
                        disabled={isLocked}
                        className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt2' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'}`}
                      >
                        {row.activeAlt === 'alt2' ? 'Active' : 'Set'}
                      </button>
                    </div>
                  </td>
                  <td className="p-3 border-r border-slate-200 text-right font-mono font-bold text-slate-700 bg-blue-50/30">
                    ₹{Number(row.alt2Price).toFixed(2)}
                  </td>

                  {/* Alt 3 Code & WA Price */}
                  <td className="p-3 border-r border-slate-200">
                    <div className="flex items-center justify-between gap-1">
                      <span className="text-slate-700">{row.alt3Code}</span>
                      <button
                        onClick={() => updateRmMappingRow(row.id, { activeAlt: 'alt3' })}
                        disabled={isLocked}
                        className={`px-1.5 py-0.5 rounded text-[10px] font-bold cursor-pointer ${row.activeAlt === 'alt3' ? 'bg-blue-600 text-white' : 'bg-slate-200 text-slate-700 hover:bg-slate-300'}`}
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
    </div>
  );
}
EOF_RM

rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Approved price is now editable with automatic linkage!"
