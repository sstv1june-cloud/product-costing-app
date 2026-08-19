import React, { useState, useEffect } from 'react';
import { 
  Layers, Download, Upload, Plus, History, Search, CheckCircle2, 
  Building2, Sliders, X, FileSpreadsheet, Edit3, ArrowRight 
} from 'lucide-react';
import { 
  globalStore, subscribeStore, getVendorBaselineData, 
  onboardNewVendor, addVendorBaselineProducts, updateBaselineParameters 
} from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [activeTab, setActiveTab] = useState('parameters'); // 'parameters' | 'audit_log'
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);

  const [showOnboardModal, setShowOnboardModal] = useState(false);
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [stagedProducts, setStagedProducts] = useState([]);
  const [successMsg, setSuccessMsg] = useState(null);

  const vendorList = globalStore.vendors || [];
  const currentSchema = (globalStore.vendorSchemas && globalStore.vendorSchemas[selectedVendor]) || (globalStore.vendorSchemas?.Haier) || [];
  const rawList = getVendorBaselineData(selectedVendor);

  const filteredList = rawList.filter(item => {
    const matchSearch = (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
                        (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
    return matchSearch;
  });

  const changeLogs = (globalStore.parameterChangeLogs || []).filter(l => selectedVendor === 'ALL' || l.vendor === selectedVendor);

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Building2 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master</h1>
            <p className="text-[11px] text-slate-300">
              Active Scope: <span className="text-amber-300 font-mono font-bold">{selectedVendor}</span> | Database: <span className="font-mono text-emerald-300">{rawList.length} Registered Parts</span>
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <button
            onClick={() => setActiveTab('parameters')}
            className={`px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            1. Parameters Master ({rawList.length})
          </button>

          <button
            onClick={() => setActiveTab('audit_log')}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
              activeTab === 'audit_log' ? 'bg-purple-600 text-white shadow' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
            }`}
          >
            <History className="w-3.5 h-3.5" /> 2. Parameter Audit Log ({changeLogs.length})
          </button>
        </div>
      </div>

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2 rounded-xl flex items-center gap-2 font-semibold">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      {/* Search & Vendor Selection Strip */}
      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3 flex-1 min-w-[280px]">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder={`Search ${selectedVendor} components...`}
              className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
            />
          </div>

          <div className="flex items-center gap-1.5">
            <span className="font-bold text-slate-700 text-xs">Switch Vendor:</span>
            <select
              value={selectedVendor}
              onChange={(e) => setSelectedVendor(e.target.value)}
              className="border-2 border-blue-600 rounded-xl px-3 py-1.5 text-xs font-bold bg-white text-blue-950 outline-none"
            >
              {vendorList.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors</option>
            </select>
          </div>
        </div>
      </div>

      {/* TAB 1: PARAMETERS MASTER */}
      {activeTab === 'parameters' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <Layers className="w-4 h-4 text-blue-400" /> Product Baseline Manufacturing Parameters Master
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredList.length} Active Parts</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3 min-w-[200px]">Item Code / Component</th>
                  <th className="p-3">Model & Tool Size</th>
                  <th className="p-3">Approved RM</th>
                  <th className="p-3 text-center">Cavity</th>
                  <th className="p-3 text-right">Net Wt</th>
                  <th className="p-3 text-right">Runner Wt</th>
                  <th className="p-3 text-center">Cycle Time</th>
                  <th className="p-3 text-center">Tonnage</th>
                  <th className="p-3 text-right">Shift Tariff</th>
                  <th className="p-3 text-center">Validity</th>
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
                    <td className="p-3 text-slate-600">
                      <span className="font-semibold block text-slate-800">{item.model || 'Standard'}</span>
                      <span className="text-[10px] font-mono text-slate-500">{item.mouldSize || '1070*720*650'}</span>
                    </td>
                    <td className="p-3 font-semibold text-slate-900">{item.approvedRm}</td>
                    <td className="p-3 text-center font-bold font-mono text-slate-900">{item.cavity || 1}</td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900">{item.netWeight || 197}g</td>
                    <td className="p-3 text-right font-mono text-slate-600">{item.runnerWeight || 40}g</td>
                    <td className="p-3 text-center">
                      <span className="bg-amber-100 text-amber-900 font-mono font-bold px-2 py-0.5 rounded text-[11px]">
                        {item.cycleTimeApproved || item.cycleTime || 48}s
                      </span>
                    </td>
                    <td className="p-3 text-center font-mono font-bold text-slate-700">{item.machineTonnage || 450}T</td>
                    <td className="p-3 text-right font-mono font-semibold text-slate-700">₹{item.hourlyRate ? (item.hourlyRate * 8) : 3600}</td>
                    <td className="p-3 text-center font-mono text-[10px] text-slate-500">{item.validFrom || '2026-08-01'} &rarr; -</td>
                    <td className="p-3 text-center">
                      <button
                        type="button"
                        onClick={() => setEditingItem(item)}
                        className="p-1.5 bg-blue-50 hover:bg-blue-600 text-blue-600 hover:text-white rounded-lg transition cursor-pointer border border-blue-200 shadow-xs inline-flex items-center justify-center"
                        title="Edit Baseline Parameters"
                      >
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

      {/* TAB 2: PARAMETER AUDIT LOG */}
      {activeTab === 'audit_log' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 p-4 space-y-3">
          <div className="flex justify-between items-center border-b pb-2">
            <h2 className="text-sm font-bold text-slate-900 flex items-center gap-1.5">
              <History className="w-4 h-4 text-purple-600" /> Parameter Modification Audit Trail
            </h2>
            <span className="text-[11px] text-slate-500 font-mono">Real-time shopfloor tuning logs</span>
          </div>

          <div className="border border-slate-200 rounded-xl overflow-hidden">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px]">
                <tr>
                  <th className="p-3">Timestamp</th>
                  <th className="p-3">Part Code</th>
                  <th className="p-3">Component Name</th>
                  <th className="p-3">Vendor</th>
                  <th className="p-3">Parameter Modifications</th>
                  <th className="p-3 text-right">Cost Impact (Δ)</th>
                  <th className="p-3">Authorized By</th>
                  <th className="p-3">Audit Reason</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {changeLogs.map(log => (
                  <tr key={log.id} className="hover:bg-slate-50">
                    <td className="p-3 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="p-3 font-mono font-bold text-blue-700">{log.itemCode}</td>
                    <td className="p-3 font-semibold text-slate-900">{log.componentName}</td>
                    <td className="p-3 font-semibold text-slate-700">{log.vendor || selectedVendor}</td>
                    <td className="p-3">
                      {(log.changesList || []).map((ch, i) => (
                        <span key={i} className="inline-block bg-slate-100 border border-slate-300 rounded px-1.5 py-0.5 text-[10px] mr-1.5 font-mono">
                          {ch.parameter}: {ch.oldVal} &rarr; <span className="font-bold text-blue-900">{ch.newVal}</span> ({ch.diff})
                        </span>
                      ))}
                    </td>
                    <td className="p-3 text-right font-mono font-black">
                      <span className={(log.costImpact?.diff || 0) <= 0 ? 'text-emerald-700' : 'text-rose-600'}>
                        ₹ {(log.costImpact?.diff || 0) <= 0 ? `${(log.costImpact?.diff || 0).toFixed(2)}` : `+${(log.costImpact?.diff || 0).toFixed(2)}`}
                      </span>
                    </td>
                    <td className="p-3 text-slate-700">{log.changedBy}</td>
                    <td className="p-3 text-slate-600 italic">{log.reason}</td>
                  </tr>
                ))}
                {changeLogs.length === 0 && (
                  <tr>
                    <td colSpan="8" className="p-4 text-center text-slate-400 italic">No parameter modification logs found.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* EDIT MODAL */}
      {editingItem && (
        <InlineEditModal
          item={editingItem}
          isOpen={Boolean(editingItem)}
          onClose={() => setEditingItem(null)}
          onSave={({ updatedItem, changeType, newValidFrom, reason }) => {
            updateBaselineParameters({
              itemId: editingItem?.id,
              updatedItem,
              changeType,
              newValidFrom,
              reason
            });
            setEditingItem(null);
            setSuccessMsg(`Parameter change logged for ${editingItem.itemCode}`);
            setTimeout(() => setSuccessMsg(null), 3000);
          }}
        />
      )}

    </div>
  );
}
