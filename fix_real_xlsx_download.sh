#!/usr/bin/env bash
set -e

echo "==> 1. Installing official xlsx library..."
npm install xlsx

echo "==> 2. Updating BaselineMasterPage.jsx to generate true .xlsx files..."
BASELINE_FILE="src/modules/module1-baseline/BaselineMasterPage.jsx"

cat << 'EOF_PAGE' > "$BASELINE_FILE"
import React, { useState, useEffect } from 'react';
import { 
  FileSpreadsheet, Upload, Download, Plus, Search, Edit3, CheckCircle2, Layers 
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, getVendorBaselineData } from '../../shared/masterStore';
import InlineEditModal from './InlineEditModal';
import ParameterChangeLogPage from './ParameterChangeLogPage';

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

  const downloadTemplate = () => {
    const listToExport = filteredItems.length > 0 ? filteredItems : rawList;
    if (listToExport.length === 0) {
      alert("No products available to export for this vendor.");
      return;
    }

    let aoaData = [];

    if (selectedVendor.toLowerCase().includes('haier')) {
      aoaData = [
        ["#", "Haier Parameter / Spec Line", "UOM", ...listToExport.map(p => p.componentName)],
        ["1", "Name Of Component", "-", ...listToExport.map(p => p.componentName)],
        ["2", "Mould Size L * W * H", "mm", ...listToExport.map(p => p.mouldSize || "1070*720*650")],
        ["3", "Approved RM Grade (Locked & Linked)", "-", ...listToExport.map(p => p.approvedRm || 'ABS 300 Pre Colour')],
        ["4", "Masterbatch Required", "%", ...listToExport.map(p => p.masterbatchPct || 0.0)],
        ["5", "No. of Cavity", "Nos", ...listToExport.map(p => p.cavity || 2)],
        ["6", "Runner Weight", "Gms", ...listToExport.map(p => p.runnerWeight || 40)],
        ["7", "Net Weight", "Gms", ...listToExport.map(p => p.netWeight || 197)],
        ["8", "Shot Weight (Calculated / pc)", "Gms", ...listToExport.map(p => (((p.netWeight || 197) * (p.cavity || 2)) + (p.runnerWeight || 40)) / (p.cavity || 2))],
        ["9", "Reconciliation Weight (Shot wt + 1.0% Melt Loss)", "Gms", ...listToExport.map(p => ((((p.netWeight || 197) * (p.cavity || 2)) + (p.runnerWeight || 40)) / (p.cavity || 2)) * 1.01)],
        ["10", "Raw Material Cost", "₹", ...listToExport.map(p => p.approvedRmRate || 130)],
        ["11", "Master Batch Cost", "₹", ...listToExport.map(p => p.masterbatchRate || 0)],
        ["12", "Runner Recovery Credit (Scrap Credit)", "₹", ...listToExport.map(p => 0.57)],
        ["13", "TOTAL RAW MATERIAL COST", "₹", ...listToExport.map(p => 57.54)],
        ["14", "Cycle Time Approved", "Sec", ...listToExport.map(p => p.cycleTimeApproved || p.cycleTime || 48)],
        ["15", "Shift Machine Tariff", "₹/shift", ...listToExport.map(p => p.shiftTariff || 4600)],
        ["16", "Machine Conversion Cost / Piece", "₹", ...listToExport.map(p => 12.89)],
        ["17", "Item Code", "-", ...listToExport.map(p => p.itemCode)],
        ["18", "Model", "-", ...listToExport.map(p => p.model || "")]
      ];
    } else {
      aoaData = [
        ["#", "Atomberg Costing Line", "UOM / Rate", ...listToExport.map(p => p.componentName)],
        ["1", "Vendor", "-", ...listToExport.map(p => "Atomberg")],
        ["2", "Part Code", "-", ...listToExport.map(p => p.itemCode)],
        ["3", "Part name", "-", ...listToExport.map(p => p.componentName)],
        ["4", "RM grade (Locked & Linked)", "-", ...listToExport.map(p => p.approvedRm || 'PP H110MA')],
        ["5", "RM Base Rate (From RM Matrix)", "₹/kg", ...listToExport.map(p => p.approvedRmRate || 140)],
        ["6", "ICC Cost @ 1% of RM", "1%", ...listToExport.map(p => 1.40)],
        ["7", "Freight Cost", "₹/kg", ...listToExport.map(p => 1.50)],
        ["8", "RM Landed Cost (Base + ICC + Freight)", "₹/kg", ...listToExport.map(p => 142.90)],
        ["9", "MB Base Cost (From RM Matrix)", "₹/kg", ...listToExport.map(p => p.masterbatchRate || 254)],
        ["10", "MB-ICC Cost @ 1% of MB", "1%", ...listToExport.map(p => 2.54)],
        ["11", "MB Freight Cost", "₹/kg", ...listToExport.map(p => 2.00)],
        ["12", "MB Landed Cost (Base + ICC + Freight)", "₹/kg", ...listToExport.map(p => 258.54)],
        ["13", "MB %", "%", ...listToExport.map(p => p.masterbatchPct || 4.0)],
        ["14", "RM cost( PP + MB) /KG", "₹/kg", ...listToExport.map(p => 147.52)],
        ["15", "part weight grams", "Gms", ...listToExport.map(p => p.netWeight || 37)],
        ["16", "Runner weight grams", "Gms", ...listToExport.map(p => p.runnerWeight || 1)],
        ["17", "Gross weight", "Gms", ...listToExport.map(p => (p.netWeight || 37) + (p.runnerWeight || 1))],
        ["18", "RM cost", "₹/pc", ...listToExport.map(p => 5.60)],
        ["19", "Inserts/BOP cost", "₹/pc", ...listToExport.map(p => p.bopCost || 0)],
        ["20", "RM + BOP Cost", "₹/pc", ...listToExport.map(p => 5.60)],
        ["21", "M/c tonnage", "T", ...listToExport.map(p => p.machineTonnage || 200)],
        ["22", "shift rate (Tonnage × ₹10)", "₹/shift", ...listToExport.map(p => (p.machineTonnage || 200) * 10)],
        ["23", "cycle time( seconds)", "Sec", ...listToExport.map(p => p.cycleTimeApproved || p.cycleTime || 47)],
        ["24", "Efficiency", "-", ...listToExport.map(p => 0.90)],
        ["25", "No of cavity", "Nos", ...listToExport.map(p => p.cavity || 2)],
        ["26", "No. of parts/shift", "Nos", ...listToExport.map(p => 2200)],
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
    XLSX.utils.book_append_sheet(workbook, worksheet, "Full_Spec");
    XLSX.writeFile(workbook, `${selectedVendor}_full_spec_template.xlsx`);
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
            <Download className="w-4 h-4" /> Download Full Spec Template (.xlsx)
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

echo "==> 3. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! True .xlsx workbook export successfully deployed."
