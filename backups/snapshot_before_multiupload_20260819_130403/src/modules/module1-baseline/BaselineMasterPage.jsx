import React, { useState, useEffect } from 'react';
import { Layers, Download, History, Search, CheckCircle2, Building2, Edit3 } from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, getVendorBaselineData, updateBaselineParameters } from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [activeTab, setActiveTab] = useState('parameters');
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);

  const vendorList = globalStore.vendors || [];
  const rawList = getVendorBaselineData(selectedVendor);

  const filteredList = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  const changeLogs = (globalStore.parameterChangeLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  const handleDownloadVerticalTemplate = () => {
    const defaultVerticalLines = [
      ["", "Vendor", "", selectedVendor],
      ["", "Part Code", "", "A101701"],
      ["", "Part name", "", "Aris Top Canopy- Gloss White"],
      ["", "RM grade", "", "PP H110MA"],
      ["", "RM Base Rate", "", 133],
      ["", "ICC Cost @ 1% of RM", "", 1.33],
      ["", "Fright Cost", "", 1.5],
      ["", "RM Landed Cost", "", 135.83],
      ["", "MB Base Cost", "", 254],
      ["", "MB-ICC Cost @ 1% of MB", "", 2.54],
      ["", "Fright Cost", "", 2],
      ["", "MB Landed Cost", "", 258.54],
      ["", "MB %", "", 0.04],
      ["", "RM cost( PP + MB) /KG", "", 140.7384],
      ["", "part weight grams", "", 37],
      ["", "Runner weight grams", "", 1],
      ["", "Gross weight", "", 38],
      ["", "RM cost", "", 5.3481],
      ["", "Inserts/BOP cost", "", 0.00],
      ["", "RM + BOP Cost", "", 5.3481],
      ["", "M/c tonnage", "", 200],
      ["", "shift rate", 10.00, 2000],
      ["", "cycle time( seconds)", "", 47],
      ["", "Efficiency", 0.90, 0.9],
      ["", "No of cavity", "", 2],
      ["", "No. of parts/shift", "", 1102.98],
      ["", "Process cost", "", 1.8133],
      ["", "Handling cost for BOP", 0.03, 0],
      ["", "Post operation cost", "", 1.73],
      ["", "Total Process Cost", "", 3.5433],
      ["", "Profit & OH", 0.12, 1.0670],
      ["", "Inprocess Rejection", 0.03, 0.3557],
      ["", "Runner recovery cost", 25.00, -0.025],
      ["", "ICC", 0.02, 0],
      ["", "Packing cost", "", 0.86],
      ["", "Transpost cost", 10.00, 0.62],
      ["", "Mould maintanance cost", 0.02, 0.0709],
      ["", "Other Cost", "", 2.9485],
      ["", "Final Landed cost", "", 11.8398]
    ];

    const ws = XLSX.utils.aoa_to_sheet(defaultVerticalLines);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Standard_Format");
    XLSX.writeFile(wb, `${selectedVendor}_Approved_Costing_Format.xlsx`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Building2 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master</h1>
            <p className="text-[11px] text-slate-300">
              Active Vendor: <span className="text-amber-300 font-mono font-bold">{selectedVendor}</span> | Format: <span className="font-mono text-emerald-300">Vertical OEM Specification Sheet</span>
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button onClick={handleDownloadVerticalTemplate} className="flex items-center gap-1.5 px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl transition cursor-pointer shadow-xs">
            <Download className="w-3.5 h-3.5" /> Download {selectedVendor} Vertical Format (.xlsx)
          </button>
          <button onClick={() => setActiveTab('parameters')} className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'}`}>1. Parameters Master ({rawList.length})</button>
          <button onClick={() => setActiveTab('audit_log')} className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${activeTab === 'audit_log' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'}`}><History className="w-3.5 h-3.5" /> 2. Parameter Audit Log ({changeLogs.length})</button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2 rounded-xl flex items-center gap-2 font-semibold">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3 flex-1 min-w-[280px]">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input type="text" value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} placeholder={`Search ${selectedVendor} components...`} className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none" />
          </div>

          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700 text-xs">Switch Vendor:</span>
            <select value={selectedVendor} onChange={(e) => setSelectedVendor(e.target.value)} className="border-2 border-blue-600 rounded-xl px-3 py-1.5 text-xs font-bold bg-white text-blue-950 outline-none cursor-pointer">
              {vendorList.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors Combined</option>
            </select>
          </div>
        </div>
      </div>

      {activeTab === 'parameters' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <Layers className="w-4 h-4 text-blue-400" /> {selectedVendor} Baseline Parameters Master
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredList.length} Active Parts</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3 min-w-[190px]">Item Code / Component</th>
                  <th className="p-3">Model</th>
                  <th className="p-3">Approved RM / MB</th>
                  <th className="p-3 text-center">MB %</th>
                  <th className="p-3 text-center">Cavity</th>
                  <th className="p-3 text-right">Net Wt</th>
                  <th className="p-3 text-right">Runner Wt</th>
                  <th className="p-3 text-center">Cycle Time</th>
                  <th className="p-3 text-center">Tonnage</th>
                  <th className="p-3 text-right">Shift Tariff</th>
                  <th className="p-3 text-center min-w-[70px]">Edit Spec</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium text-slate-800">
                {filteredList.map((item) => (
                  <tr key={item.id} className="hover:bg-blue-50/40 transition">
                    <td className="p-3">
                      <span className="font-mono font-bold text-blue-700 block">{item.itemCode}</span>
                      <span className="text-[11px] text-slate-800 font-semibold">{item.componentName}</span>
                    </td>
                    <td className="p-3 text-slate-700 font-semibold">{item.model || 'Standard'}</td>
                    <td className="p-3">
                      <span className="font-semibold text-slate-900 block">{item.approvedRm}</span>
                      <span className="text-[10px] text-slate-500 font-mono">₹{item.approvedRmRate || 135.83}/kg</span>
                    </td>
                    <td className="p-3 text-center font-mono font-bold text-purple-700">{(item.masterbatchPct || 0).toFixed(2)}%</td>
                    <td className="p-3 text-center font-bold font-mono text-slate-900">{item.cavity || 1}</td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">{item.netWeight || 37}g</td>
                    <td className="p-3 text-right font-mono text-slate-600">{item.runnerWeight || 1}g</td>
                    <td className="p-3 text-center"><span className="bg-amber-100 text-amber-900 font-mono font-bold px-2 py-0.5 rounded text-[11px]">{item.cycleTimeApproved || item.cycleTime || 47}s</span></td>
                    <td className="p-3 text-center font-mono font-bold text-slate-700">{item.machineTonnage || 200}T</td>
                    <td className="p-3 text-right font-mono font-semibold text-slate-700">₹{item.hourlyRate ? (item.hourlyRate * 8) : 2000}</td>
                    <td className="p-3 text-center">
                      <button type="button" onClick={() => setEditingItem(item)} className="p-1.5 bg-blue-50 hover:bg-blue-600 text-blue-600 hover:text-white rounded-lg transition cursor-pointer border border-blue-200 shadow-xs inline-flex items-center justify-center" title="Edit Baseline & Running Parameters">
                        <Edit3 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {editingItem && (
        <InlineEditModal
          item={editingItem}
          isOpen={Boolean(editingItem)}
          onClose={() => setEditingItem(null)}
          onSave={({ updatedItem, changeType, newValidFrom, reason }) => {
            updateBaselineParameters({ itemId: editingItem?.id, updatedItem, changeType, newValidFrom, reason });
            setEditingItem(null);
            setSuccessMsg(`Parameter change saved and logged for ${editingItem.itemCode}`);
            setTimeout(() => setSuccessMsg(null), 3000);
          }}
        />
      )}
    </div>
  );
}
