import React, { useState, useEffect } from 'react';
import { Edit3, Download, History, Search, Layers, TrendingUp, TrendingDown, ArrowRight } from 'lucide-react';
import { globalStore, subscribeStore, updateBaselineParameters } from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const auditLogs = globalStore.parameterChangeLogs || [];
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [activeTab, setActiveTab] = useState('parameters'); // 'parameters' | 'change_log'
  const [editingItem, setEditingItem] = useState(null);

  const filteredList = masterList.filter(item => {
    const matchSearch = (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
                        (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
    const matchVendor = selectedVendor === 'ALL' || item.vendor === selectedVendor;
    return matchSearch && matchVendor;
  });

  const handleSaveManualEdit = ({ updatedItem, changeType, newValidFrom, reason }) => {
    updateBaselineParameters({
      itemId: editingItem?.id,
      updatedItem,
      changeType,
      newValidFrom,
      reason
    });
    setEditingItem(null);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Filter Bar */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3 flex-1 min-w-[280px]">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by Part No or Component Name..."
              className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs focus:ring-2 focus:ring-blue-500 outline-none"
            />
          </div>

          <select
            value={selectedVendor}
            onChange={(e) => setSelectedVendor(e.target.value)}
            className="border border-slate-300 rounded-xl px-3 py-1.5 text-xs font-semibold bg-white text-slate-800 focus:ring-2 focus:ring-blue-500 outline-none cursor-pointer"
          >
            <option value="ALL">All Vendors</option>
            <option value="Haier">Haier</option>
            <option value="LG">LG</option>
            <option value="Whirlpool">Whirlpool</option>
          </select>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setActiveTab('parameters')}
            className={`px-3 py-1.5 text-xs font-bold rounded-lg transition cursor-pointer ${
              activeTab === 'parameters' ? 'bg-blue-600 text-white shadow' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
            }`}
          >
            1. Parameters Master
          </button>
          <button
            onClick={() => setActiveTab('change_log')}
            className={`flex items-center gap-1.5 px-3 py-1.5 text-xs font-bold rounded-lg transition cursor-pointer ${
              activeTab === 'change_log' ? 'bg-blue-600 text-white shadow' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'
            }`}
          >
            <History className="w-3.5 h-3.5" /> 2. Parameter Audit Log ({auditLogs.length})
          </button>
        </div>
      </div>

      {/* PARAMETERS MASTER TABLE */}
      {activeTab === 'parameters' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          
          <div className="px-5 py-3.5 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <div>
              <h2 className="text-sm font-bold flex items-center gap-2">
                <Layers className="w-4 h-4 text-blue-400" /> Product Baseline Manufacturing Parameters Master
              </h2>
              <p className="text-[11px] text-slate-300">Tooling, cavity, weights, cycle times, and machine baseline specifications</p>
            </div>
            <span className="bg-blue-600 px-2.5 py-1 rounded-lg font-bold text-[11px]">
              {filteredList.length} Active Parts
            </span>
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

                    <td className="p-3">
                      <span className="font-semibold text-slate-900 block">{item.approvedRm}</span>
                    </td>

                    <td className="p-3 text-center font-bold font-mono text-slate-900">
                      {item.cavity || item.parameters?.cavity || 1}
                    </td>

                    <td className="p-3 text-right font-mono font-bold text-slate-900">
                      {item.netWeight || item.parameters?.netWeightApproved || 197}g
                    </td>

                    <td className="p-3 text-right font-mono text-slate-600">
                      {item.runnerWeight || item.parameters?.runnerWeight || 40}g
                    </td>

                    <td className="p-3 text-center">
                      <span className="bg-amber-100 text-amber-900 font-mono font-bold px-2 py-0.5 rounded text-[11px]">
                        {item.cycleTimeApproved || item.cycleTime || 48}s
                      </span>
                    </td>

                    <td className="p-3 text-center font-mono font-bold text-slate-700">
                      {item.machineTonnage || item.parameters?.machineTonnage || 450}T
                    </td>

                    <td className="p-3 text-right font-mono font-semibold text-slate-700">
                      ₹{item.hourlyRate ? (item.hourlyRate * 8) : 3600}
                    </td>

                    <td className="p-3 text-center font-mono text-[10px] text-slate-500">
                      01/11/25 &rarr; -
                    </td>

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

      {/* PARAMETER CHANGE AUDIT LOG TABLE WITH EXACT ITEM DIFFS */}
      {activeTab === 'change_log' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 p-4 space-y-4">
          
          <div className="flex justify-between items-center border-b pb-2">
            <div>
              <h2 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                <History className="w-4 h-4 text-blue-600" /> Parameter Modification Audit Trail & Cost Impact Log
              </h2>
              <p className="text-[11px] text-slate-500">
                Detailed side-by-side parameter value transitions (Old &rarr; New) and resulting unit cost delta.
              </p>
            </div>
            <span className="bg-slate-100 text-slate-700 font-mono font-bold px-2.5 py-1 rounded-lg border text-xs">
              {auditLogs.length} Modifications Logged
            </span>
          </div>

          <div className="border border-slate-300 rounded-xl overflow-hidden shadow-xs">
            <table className="min-w-full text-xs text-left border-collapse">
              <thead className="bg-slate-800 text-white font-bold uppercase text-[10px] border-b border-slate-700">
                <tr>
                  <th className="p-3 w-36">Timestamp</th>
                  <th className="p-3 min-w-[180px]">Item Code & Component</th>
                  <th className="p-3 min-w-[340px] bg-slate-900 text-amber-200">What Changed (Exact Field Diffs)</th>
                  <th className="p-3 w-40 text-right bg-slate-900 text-blue-200">Unit Cost Impact</th>
                  <th className="p-3 w-28">Authorized By</th>
                  <th className="p-3 min-w-[180px]">Audit Reason</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {auditLogs.map((log) => (
                  <tr key={log.id} className="hover:bg-slate-50">
                    
                    {/* Timestamp */}
                    <td className="p-3 font-mono text-slate-500 align-top">
                      {log.timestamp}
                    </td>

                    {/* Item Code & Component */}
                    <td className="p-3 align-top">
                      <span className="font-mono font-bold text-blue-700 block">{log.itemCode}</span>
                      <span className="font-semibold text-slate-900 text-[11px]">{log.componentName}</span>
                    </td>

                    {/* EXACT PARAMETER DIFFS PILLS */}
                    <td className="p-3 align-top bg-slate-50/50">
                      <div className="flex flex-wrap gap-2">
                        {(log.changesList || []).map((ch, i) => (
                          <div key={i} className="bg-white border border-slate-300 rounded-lg p-1.5 px-2 shadow-2xs text-[11px] font-sans">
                            <span className="font-bold text-slate-700 block text-[10px] uppercase">{ch.parameter}:</span>
                            <div className="flex items-center gap-1 font-mono mt-0.5">
                              <span className="text-slate-500 line-through">{ch.oldVal}</span>
                              <ArrowRight className="w-3 h-3 text-slate-400" />
                              <span className="font-bold text-blue-900">{ch.newVal}</span>
                              <span className={`text-[10px] font-bold ml-1 px-1 rounded ${
                                ch.diff.startsWith('+') ? 'bg-rose-100 text-rose-800' : 'bg-emerald-100 text-emerald-800'
                              }`}>
                                {ch.diff}
                              </span>
                            </div>
                          </div>
                        ))}
                      </div>
                    </td>

                    {/* Unit Cost Delta */}
                    <td className="p-3 text-right font-mono align-top">
                      {log.costImpact ? (
                        <div>
                          <div className="text-slate-500 line-through text-[11px]">₹{log.costImpact.oldCost?.toFixed(2)}</div>
                          <div className="font-black text-slate-900 text-xs">₹{log.costImpact.newCost?.toFixed(2)}</div>
                          <div className={`text-[10px] font-bold flex items-center justify-end gap-0.5 ${
                            log.costImpact.diff <= 0 ? 'text-emerald-700' : 'text-rose-600'
                          }`}>
                            {log.costImpact.diff <= 0 ? <TrendingDown className="w-3 h-3" /> : <TrendingUp className="w-3 h-3" />}
                            {log.costImpact.diff <= 0 ? `-₹${Math.abs(log.costImpact.diff).toFixed(2)}` : `+₹${log.costImpact.diff.toFixed(2)}`}
                          </div>
                        </div>
                      ) : (
                        <span className="text-slate-400">-</span>
                      )}
                    </td>

                    {/* Authorized By */}
                    <td className="p-3 align-top text-slate-700 font-semibold">
                      {log.changedBy}
                    </td>

                    {/* Audit Reason */}
                    <td className="p-3 align-top text-slate-600 italic">
                      {log.reason}
                    </td>

                  </tr>
                ))}
              </tbody>
            </table>
          </div>

        </div>
      )}

      {/* Edit Baseline Modal */}
      {editingItem && (
        <InlineEditModal
          item={editingItem}
          isOpen={Boolean(editingItem)}
          onClose={() => setEditingItem(null)}
          onSave={handleSaveManualEdit}
        />
      )}

    </div>
  );
}
