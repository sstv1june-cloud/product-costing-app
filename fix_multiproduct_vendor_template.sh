#!/usr/bin/env bash
set -e

echo "==> 1. Updating BaselineMasterPage.jsx template generator to export all products as columns..."
BASELINE_FILE="src/modules/module1-baseline/BaselineMasterPage.jsx"

cat << 'EOF_PAGE' > "$BASELINE_FILE"
import React, { useState, useEffect } from 'react';
import { 
  FileSpreadsheet, Upload, Download, Plus, Search, Edit3, CheckCircle2, Layers 
} from 'lucide-react';
import { globalStore, subscribeStore, getVendorBaselineData } from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';
import ParameterChangeLogPage from './ParameterChangeLogPage';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [activeTab, setActiveTab] = useState('master'); // 'master' | 'audit'
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);

  const rawList = getVendorBaselineData(selectedVendor === 'ALL' ? 'ALL' : selectedVendor);

  const filteredItems = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  const downloadTemplate = () => {
    const listToExport = filteredItems.length > 0 ? filteredItems : rawList;
    if (listToExport.length === 0) {
      alert("No products available to export for this vendor.");
      return;
    }

    let csv = "data:text/csv;charset=utf-8,";
    
    if (selectedVendor.toLowerCase().includes('haier')) {
      const headers = [
        "Vendor",
        "Name Of Component",
        "Mould Size L * W * H",
        "Item No. / Code",
        "Model",
        "Raw Material Required",
        "RM Base Rate",
        "Master Batch Required",
        "No. of Cavity",
        "Runner Weight",
        "Net Weight",
        "Cycle Time Approved",
        "Machine Tonnage",
        "Shift Tariff"
      ];

      csv += ["Specification Line", ...listToExport.map(i => i.componentName)].join(",") + "\r\n";
      csv += ["Vendor", ...listToExport.map(i => i.vendor || "Haier")].join(",") + "\r\n";
      csv += ["Name Of Component", ...listToExport.map(i => `"${i.componentName}"`)].join(",") + "\r\n";
      csv += ["Mould Size L * W * H", ...listToExport.map(i => i.mouldSize || "1070*720*650")].join(",") + "\r\n";
      csv += ["Item No. / Code", ...listToExport.map(i => i.itemCode)].join(",") + "\r\n";
      csv += ["Model", ...listToExport.map(i => `"${i.model || ''}"`)].join(",") + "\r\n";
      csv += ["Raw Material Required", ...listToExport.map(i => `"${i.approvedRm || ''}"`)].join(",") + "\r\n";
      csv += ["RM Base Rate", ...listToExport.map(i => i.approvedRmRate || 130)].join(",") + "\r\n";
      csv += ["Master Batch Required", ...listToExport.map(i => i.masterbatchPct || 0)].join(",") + "\r\n";
      csv += ["No. of Cavity", ...listToExport.map(i => i.cavity || 2)].join(",") + "\r\n";
      csv += ["Runner Weight", ...listToExport.map(i => i.runnerWeight || 40)].join(",") + "\r\n";
      csv += ["Net Weight", ...listToExport.map(i => i.netWeight || 197)].join(",") + "\r\n";
      csv += ["Cycle Time Approved", ...listToExport.map(i => i.cycleTimeApproved || i.cycleTime || 48)].join(",") + "\r\n";
      csv += ["Machine Tonnage", ...listToExport.map(i => i.machineTonnage || 450)].join(",") + "\r\n";
      csv += ["Shift Tariff", ...listToExport.map(i => i.shiftTariff || 4600)].join(",") + "\r\n";
    } else {
      csv += ["Specification Line", ...listToExport.map(i => i.componentName)].join(",") + "\r\n";
      csv += ["Vendor", ...listToExport.map(i => i.vendor || "Atomberg")].join(",") + "\r\n";
      csv += ["Part Code", ...listToExport.map(i => i.itemCode)].join(",") + "\r\n";
      csv += ["Part Name", ...listToExport.map(i => `"${i.componentName}"`)].join(",") + "\r\n";
      csv += ["Model", ...listToExport.map(i => `"${i.model || ''}"`)].join(",") + "\r\n";
      csv += ["Mould Size", ...listToExport.map(i => i.mouldSize || "950*600*450")].join(",") + "\r\n";
      csv += ["RM Grade", ...listToExport.map(i => `"${i.approvedRm || ''}"`)].join(",") + "\r\n";
      csv += ["RM Base Rate", ...listToExport.map(i => i.approvedRmRate || 140)].join(",") + "\r\n";
      csv += ["Master Batch %", ...listToExport.map(i => i.masterbatchPct || 4)].join(",") + "\r\n";
      csv += ["Master Batch Rate", ...listToExport.map(i => i.masterbatchRate || 254)].join(",") + "\r\n";
      csv += ["BOP Cost", ...listToExport.map(i => i.bopCost || 0)].join(",") + "\r\n";
      csv += ["Cavity", ...listToExport.map(i => i.cavity || 2)].join(",") + "\r\n";
      csv += ["Net Weight (g)", ...listToExport.map(i => i.netWeight || 37)].join(",") + "\r\n";
      csv += ["Runner Weight (g)", ...listToExport.map(i => i.runnerWeight || 1)].join(",") + "\r\n";
      csv += ["Cycle Time (s)", ...listToExport.map(i => i.cycleTimeApproved || i.cycleTime || 47)].join(",") + "\r\n";
      csv += ["Machine Tonnage (T)", ...listToExport.map(i => i.machineTonnage || 200)].join(",") + "\r\n";
    }

    const encodedUri = encodeURI(csv);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `${selectedVendor}_full_spec_template.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Layers className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">1. Multi-Vendor Dynamic Product Baseline Master</h1>
            <p className="text-[11px] text-slate-300">Active Vendor: <span className="font-bold text-amber-300">{selectedVendor}</span> | Registered Parts: <span className="font-bold text-emerald-400">{filteredItems.length} Active</span></p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={downloadTemplate}
            className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm transition-colors"
          >
            <Download className="w-4 h-4" /> Download Full Spec Template (.csv)
          </button>
          
          <div className="flex bg-slate-800 p-1 rounded-xl border border-slate-700">
            <button onClick={() => setActiveTab('master')} className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'master' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}>Parameters Master ({filteredItems.length})</button>
            <button onClick={() => setActiveTab('audit')} className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'audit' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}>Parameter Audit Log ({globalStore.parameterChangeLogs?.length || 0})</button>
          </div>
        </div>
      </div>

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder={`Search ${selectedVendor} components...`}
            className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-700">Switch Vendor:</span>
          <select
            value={selectedVendor}
            onChange={(e) => setSelectedVendor(e.target.value)}
            className="border-2 border-blue-600 rounded-xl px-3 py-1.5 font-bold bg-white text-blue-950 outline-none cursor-pointer"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
            <option value="ALL">All Vendors Combined</option>
          </select>
        </div>
      </div>

      {activeTab === 'master' ? (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
          <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
            <h2 className="text-sm font-bold flex items-center gap-2">
              <FileSpreadsheet className="w-4 h-4 text-blue-400" /> {selectedVendor} Baseline Parameters Master
            </h2>
            <span className="text-[11px] text-slate-300 font-mono">{filteredItems.length} Active Parts</span>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <tr>
                  <th className="p-3">ITEM CODE / COMPONENT</th>
                  <th className="p-3">MODEL</th>
                  <th className="p-3">APPROVED RM / MB</th>
                  <th className="p-3">MB %</th>
                  <th className="p-3 text-center">CAVITY</th>
                  <th className="p-3">NET WT</th>
                  <th className="p-3">RUNNER WT</th>
                  <th className="p-3">CYCLE TIME</th>
                  <th className="p-3">TONNAGE</th>
                  <th className="p-3">SHIFT TARIFF</th>
                  <th className="p-3 text-center">EDIT SPEC</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {filteredItems.map((item) => (
                  <tr key={item.id} className="hover:bg-slate-50">
                    <td className="p-3">
                      <span className="font-mono font-bold text-blue-700 block">{item.itemCode}</span>
                      <span className="font-semibold text-slate-900">{item.componentName}</span>
                    </td>
                    <td className="p-3 text-slate-700">{item.model}</td>
                    <td className="p-3">
                      <span className="font-bold text-slate-900 block">{item.approvedRm}</span>
                      <span className="text-[10px] text-slate-500 font-mono">₹{Number(item.approvedRmRate || 130).toFixed(2)}/kg</span>
                    </td>
                    <td className="p-3 font-mono font-bold text-purple-700">{(item.masterbatchPct || 0).toFixed(2)}%</td>
                    <td className="p-3 text-center font-mono font-bold">{item.cavity || 2}</td>
                    <td className="p-3 font-mono">{item.netWeight}g</td>
                    <td className="p-3 font-mono">{item.runnerWeight}g</td>
                    <td className="p-3 font-mono"><span className="bg-amber-100 text-amber-900 px-2 py-0.5 rounded font-bold">{item.cycleTimeApproved || item.cycleTime}s</span></td>
                    <td className="p-3 font-mono">{item.machineTonnage}T</td>
                    <td className="p-3 font-mono">₹{item.shiftTariff || (item.machineTonnage >= 650 ? 5760 : 4600)}</td>
                    <td className="p-3 text-center">
                      <button
                        onClick={() => setEditingItem(item)}
                        className="px-3 py-1.5 bg-blue-50 hover:bg-blue-100 text-blue-700 border border-blue-300 rounded-xl font-bold inline-flex items-center gap-1 cursor-pointer transition-colors shadow-xs"
                      >
                        <Edit3 className="w-3.5 h-3.5" /> Edit Spec
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      ) : (
        <ParameterChangeLogPage />
      )}

      {editingItem && (
        <InlineEditModal
          item={editingItem}
          isOpen={!!editingItem}
          onClose={() => setEditingItem(null)}
          onSave={({ updatedItem, changeType, reason }) => {
            import('../../shared/masterStore').then(({ updateBaselineParameters }) => {
              updateBaselineParameters({
                itemId: editingItem.id,
                updatedItem,
                changeType,
                reason
              });
              setEditingItem(null);
            });
          }}
        />
      )}
    </div>
  );
}
EOF_PAGE

echo "==> 2. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Multi-product multi-column template download deployed."
