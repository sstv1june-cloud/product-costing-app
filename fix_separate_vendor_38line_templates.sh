#!/usr/bin/env bash
set -e

echo "==> 1. Updating BaselineMasterPage.jsx with independent Haier and Atomberg 38-line Excel export templates..."
BASELINE_FILE="src/modules/module1-baseline/BaselineMasterPage.jsx"

cat << 'EOF_PAGE' > "$BASELINE_FILE"
import React, { useState, useEffect } from 'react';
import { 
  FileSpreadsheet, Download, Search, Edit3, Layers, History 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, getVendorBaselineData } from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';

export default function BaselineMasterPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [activeTab, setActiveTab] = useState('master');
  const [searchQuery, setSearchQuery] = useState('');
  const [editingItem, setEditingItem] = useState(null);

  const rawList = getVendorBaselineData(selectedVendor === 'ALL' ? 'ALL' : selectedVendor);

  const filteredItems = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  const parameterLogs = (globalStore.parameterChangeLogs || []).filter(l => {
    if (selectedVendor === 'ALL' || selectedVendor === 'All Vendors Combined') return true;
    return (l.vendor || '').toLowerCase() === selectedVendor.toLowerCase();
  });

  const downloadTemplate = () => {
    const listToExport = filteredItems.length > 0 ? filteredItems : rawList;
    if (listToExport.length === 0) {
      alert("No products available to export for this vendor.");
      return;
    }

    let aoaData = [];
    let fileName = "";

    if (selectedVendor.toLowerCase().includes('haier')) {
      fileName = "Haier_full_38line_costing_sheet.xlsx";
      // Haier's Distinct 38-Line Plastic Molding Sheet Format
      aoaData = [
        ["S.N.", "Description", "UOM", ...listToExport.map(p => p.componentName)],
        ["1", "Name Of component", "-", ...listToExport.map(p => p.componentName)],
        ["2", "Mould size L x W xH", "mm", ...listToExport.map(p => p.mouldSize || "1070*720*650")],
        ["3", "Item No.", "-", ...listToExport.map(p => p.itemCode)],
        ["4", "Model", "-", ...listToExport.map(p => p.model || "OLD DC")],
        ["5", "Raw Material Required", "-", ...listToExport.map(p => p.approvedRm || "ABS 300 Pre Colour")],
        ["6", "Master Batch Required (%)", "%", ...listToExport.map(p => p.masterbatchPct || 0.0)],
        ["7", "No. of Cavity", "Nos", ...listToExport.map(p => p.cavity || 2)],
        ["8", "Runner Weight", "Gms", ...listToExport.map(p => p.runnerWeight || 40)],
        ["9", "Net Weight", "Gms", ...listToExport.map(p => p.netWeight || 197)],
        ["10", "Shot Weight", "Gms", ...listToExport.map(p => (((p.netWeight || 197) * (p.cavity || 2)) + (p.runnerWeight || 40)) / (p.cavity || 2))],
        ["11", "Reconciliation Weight = Shot wt + 1.0% Melt Loss", "Gms", ...listToExport.map(p => ((((p.netWeight || 197) * (p.cavity || 2)) + (p.runnerWeight || 40)) / (p.cavity || 2)) * 1.01)],
        ["12", "Raw Material Cost", "Rs", ...listToExport.map(p => 29.54)],
        ["13", "Master batch cost", "Rs", ...listToExport.map(p => 0.00)],
        ["14", "Runner recovery % (Scrap Credit)", "-", ...listToExport.map(p => 1.4)],
        ["15", "Total Raw Material Cost", "Rs", ...listToExport.map(p => 25.20)],
        ["16", "Machine Used", "T", ...listToExport.map(p => p.machineTonnage || 450)],
        ["17", "Machine Tariff per Shift", "Rs", ...listToExport.map(p => p.shiftTariff || 4600)],
        ["18", "Cycle Time", "Sec", ...listToExport.map(p => p.cycleTimeApproved || p.cycleTime || 48)],
        ["19", "No of Shot / Shift (8Hour)", "Nos", ...listToExport.map(p => 600)],
        ["20", "No of Shot / Shift with 95 % Efficiency", "Nos", ...listToExport.map(p => 570)],
        ["21", "No. of component / shift", "Nos", ...listToExport.map(p => 1140)],
        ["22", "Production Cost / Pc", "Rs", ...listToExport.map(p => 3.68)],
        ["23", "SUB TOTAL", "Rs", ...listToExport.map(p => 28.88)],
        ["24", "OH + Profit + ICC + Rejection + Packaging + Freight", "Rs", ...listToExport.map(p => 5.11)],
        ["25", "Foam / Polybag / Masking film", "Rs", ...listToExport.map(p => 0.50)],
        ["26", "Plastic Bin / Polyend Box / Trolley", "Rs", ...listToExport.map(p => 0.30)],
        ["27", "Freight Cost", "Rs", ...listToExport.map(p => 0.40)],
        ["28", "Secondary Operation 1", "Rs", ...listToExport.map(p => 0.00)],
        ["29", "Secondary Operation 2", "Rs", ...listToExport.map(p => 0.00)],
        ["30", "Screen printing - 1st stroke", "Rs", ...listToExport.map(p => 0.00)],
        ["31", "Screen printing - 2nd stroke", "Rs", ...listToExport.map(p => 0.00)],
        ["32", "Assembly Cost", "Rs", ...listToExport.map(p => 0.00)],
        ["33", "Insert / Hinge hole cap cost / Other cost", "Rs", ...listToExport.map(p => p.bopCost || 0.14)],
        ["34", "Mould Maintenance Provision", "Rs", ...listToExport.map(p => 0.10)],
        ["35", "Quality Inspection Cost", "Rs", ...listToExport.map(p => 0.05)],
        ["36", "ICC Reduce by .5% (Payment term change 60 to 45 days)", "-", ...listToExport.map(p => -0.13)],
        ["37", "Scrap Recovery Adjustment", "Rs", ...listToExport.map(p => -1.36)],
        ["38", "TOTAL COST", "Rs", ...listToExport.map(p => 32.64)]
      ];
    } else {
      fileName = "Atomberg_full_38line_costing_sheet.xlsx";
      // Atomberg's Distinct 38-Line Electrical Appliance Sheet Format
      aoaData = [
        ["#", "Atomberg Costing Line", "UOM / Rate", ...listToExport.map(p => p.componentName)],
        ["1", "Vendor", "-", ...listToExport.map(p => "Atomberg")],
        ["2", "Part Code", "-", ...listToExport.map(p => p.itemCode)],
        ["3", "Part name", "-", ...listToExport.map(p => p.componentName)],
        ["4", "RM grade (Locked & Linked)", "-", ...listToExport.map(p => p.approvedRm || 'PP H110MA')],
        ["5", "RM Base Rate (From RM Matrix)", "₹/kg", ...listToExport.map(p => p.approvedRmRate || 140)],
        ["6", "ICC Cost @ 1% of RM", "1%", ...listToExport.map(p => 1.40)],
        ["7", "Freight Cost", "₹/kg", ...listToExport.map(p => 1.50)],
        ["8", "RM Landed Cost", "₹/kg", ...listToExport.map(p => 142.90)],
        ["9", "MB Base Cost", "₹/kg", ...listToExport.map(p => p.masterbatchRate || 254)],
        ["10", "MB-ICC Cost @ 1% of MB", "1%", ...listToExport.map(p => 2.54)],
        ["11", "MB Freight Cost", "₹/kg", ...listToExport.map(p => 2.00)],
        ["12", "MB Landed Cost", "₹/kg", ...listToExport.map(p => 258.54)],
        ["13", "MB %", "%", ...listToExport.map(p => p.masterbatchPct || 4.0)],
        ["14", "RM cost (PP + MB) /KG", "₹/kg", ...listToExport.map(p => 147.52)],
        ["15", "Part weight grams", "Gms", ...listToExport.map(p => p.netWeight || 37)],
        ["16", "Runner weight grams", "Gms", ...listToExport.map(p => p.runnerWeight || 1)],
        ["17", "Gross weight", "Gms", ...listToExport.map(p => (p.netWeight || 37) + (p.runnerWeight || 1))],
        ["18", "RM cost", "₹/pc", ...listToExport.map(p => 5.60)],
        ["19", "Inserts/BOP cost", "₹/pc", ...listToExport.map(p => p.bopCost || 0)],
        ["20", "RM + BOP Cost", "₹/pc", ...listToExport.map(p => 5.60)],
        ["21", "M/c tonnage", "T", ...listToExport.map(p => p.machineTonnage || 200)],
        ["22", "Shift rate", "₹/shift", ...listToExport.map(p => (p.machineTonnage || 200) * 10)],
        ["23", "Cycle time", "Sec", ...listToExport.map(p => p.cycleTimeApproved || p.cycleTime || 47)],
        ["24", "Efficiency", "-", ...listToExport.map(p => 0.90)],
        ["25", "No of cavity", "Nos", ...listToExport.map(p => p.cavity || 2)],
        ["26", "Parts/shift", "Nos", ...listToExport.map(p => 2200)],
        ["27", "Process cost", "₹/pc", ...listToExport.map(p => 0.90)],
        ["28", "Handling cost for BOP", "3%", ...listToExport.map(p => 0)],
        ["29", "Post operation cost", "₹/pc", ...listToExport.map(p => 1.73)],
        ["30", "Total Process Cost", "₹/pc", ...listToExport.map(p => 2.63)],
        ["31", "Profit & OH", "12%", ...listToExport.map(p => 0.98)],
        ["32", "Inprocess Rejection", "4%", ...listToExport.map(p => 0.33)],
        ["33", "Runner recovery cost", "₹25/kg", ...listToExport.map(p => -0.025)],
        ["34", "Packing cost", "₹/pc", ...listToExport.map(p => 0.86)],
        ["35", "Transport cost", "₹/pc", ...listToExport.map(p => 0.62)],
        ["36", "Mould maintenance cost", "2%", ...listToExport.map(p => 0.05)],
        ["37", "Other Cost", "₹/pc", ...listToExport.map(p => 2.84)],
        ["38", "Final Landed cost", "₹/pc", ...listToExport.map(p => 11.07)]
      ];
    }

    const worksheet = XLSX.utils.aoa_to_sheet(aoaData);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "38Line_Costing_Sheet");
    XLSX.writeFile(workbook, fileName);
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
            <Download className="w-4 h-4" /> Download Full 38-Line Spec Template (.xlsx)
          </button>
          
          <div className="flex bg-slate-800 p-1 rounded-xl border border-slate-700">
            <button onClick={() => setActiveTab('master')} className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'master' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}>Parameters Master ({filteredItems.length})</button>
            <button onClick={() => setActiveTab('audit')} className={`px-3 py-1.5 rounded-lg font-bold transition-all cursor-pointer ${activeTab === 'audit' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white'}`}>Parameter Audit Log ({parameterLogs.length})</button>
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
        <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden p-4 space-y-4">
          <div className="bg-slate-900 text-white p-4 rounded-xl flex justify-between items-center">
            <div>
              <h2 className="text-sm font-bold flex items-center gap-2">
                <History className="w-4 h-4 text-blue-400" /> Engineering Parameter Audit Trail & Change Log ({selectedVendor})
              </h2>
              <p className="text-[11px] text-slate-300">Historical track of cycle time, weight, and parameter baseline modifications.</p>
            </div>
            <span className="text-xs font-mono bg-blue-600 text-white px-2.5 py-1 rounded-lg font-bold">{parameterLogs.length} Total Logs</span>
          </div>

          <div className="overflow-x-auto border rounded-xl">
            <table className="min-w-full text-xs text-left">
              <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b">
                <tr>
                  <th className="p-3">Timestamp</th>
                  <th className="p-3">Part Code</th>
                  <th className="p-3">Component Name</th>
                  <th className="p-3">Vendor</th>
                  <th className="p-3">Parameter Modifications</th>
                  <th className="p-3 text-right">Cost Impact (Δ)</th>
                  <th className="p-3">Authorized By</th>
                  <th className="p-3">Audit Reason / Note</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200 font-medium">
                {parameterLogs.length === 0 ? (
                  <tr>
                    <td colSpan="8" className="p-8 text-center text-slate-400 font-medium">
                      No parameter modification logs recorded for {selectedVendor} yet. Use "Edit Spec" on any product to generate logs.
                    </td>
                  </tr>
                ) : (
                  parameterLogs.map((log) => (
                    <tr key={log.id} className="hover:bg-slate-50">
                      <td className="p-3 font-mono text-slate-500">{log.timestamp}</td>
                      <td className="p-3 font-mono font-bold text-blue-700">{log.itemCode}</td>
                      <td className="p-3 font-semibold text-slate-900">{log.componentName}</td>
                      <td className="p-3 font-bold text-slate-700">{log.vendor}</td>
                      <td className="p-3">
                        <div className="space-y-1">
                          {log.changesList?.map((c, i) => (
                            <div key={i} className="inline-block bg-blue-50 border border-blue-200 px-2 py-0.5 rounded text-[11px] font-mono font-bold text-blue-900 mr-1 mb-1">
                              {c.parameter}: <span className="text-rose-600">{c.oldVal}</span> &rarr; <span className="text-emerald-700">{c.newVal}</span> ({c.diff})
                            </div>
                          ))}
                        </div>
                      </td>
                      <td className="p-3 text-right font-mono font-bold">
                        <span className={log.costImpact?.diff >= 0 ? 'text-emerald-700' : 'text-rose-700'}>
                          {log.costImpact?.diff >= 0 ? `₹ +${log.costImpact.diff.toFixed(2)}` : `₹ -${Math.abs(log.costImpact.diff).toFixed(2)}`}
                        </span>
                      </td>
                      <td className="p-3 font-semibold text-slate-800">{log.changedBy}</td>
                      <td className="p-3 text-slate-600 italic">{log.reason}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
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

echo "==> Done! Independent Haier and Atomberg 38-line Excel templates deployed."
