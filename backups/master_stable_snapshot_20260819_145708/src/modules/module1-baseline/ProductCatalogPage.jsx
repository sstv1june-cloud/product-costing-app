import React, { useState, useMemo } from 'react';
import { Search, Download, Lock } from 'lucide-react';
import * as XLSX from 'xlsx';
import { baselineProducts } from './baselineData';

export default function ProductCatalogPage() {
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  const filteredCatalog = useMemo(() => {
    return baselineProducts.filter(p => {
      const matchVendor = selectedVendor === 'ALL' || p.vendor === selectedVendor;
      const matchSearch = (p.itemCode || '').toLowerCase().includes(searchTerm.toLowerCase()) || 
                          (p.componentName || '').toLowerCase().includes(searchTerm.toLowerCase());
      return matchVendor && matchSearch;
    });
  }, [selectedVendor, searchTerm]);

  const handleExportExcel = () => {
    const exportData = filteredCatalog.map(p => ({
      "Part Number": p.itemCode,
      "Component Name": p.componentName,
      "Model": p.model,
      "Vendor": p.vendor,
      "Cavities": p.parameters?.cavity || 1,
      "Cycle Time (s)": p.parameters?.cycleTimeApproved || 0,
      "Net Weight (g)": p.parameters?.netWeightApproved || 0,
      "Approved RM": p.approvedRm,
      "Approved RM Rate": p.approvedRmRate,
      "Contract Cost": p.approvedTotalCost
    }));
    const ws = XLSX.utils.json_to_sheet(exportData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Catalog");
    XLSX.writeFile(wb, `Product_Catalog_${new Date().toISOString().slice(0, 10)}.xlsx`);
  };

  return (
    <div className="space-y-4 text-xs">
      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs p-4 flex justify-between items-center flex-wrap gap-3">
        <div className="flex items-center gap-2 border border-slate-300 rounded-xl px-3 py-1.5 bg-slate-50">
          <Search className="w-3.5 h-3.5 text-slate-400" />
          <input
            type="text"
            placeholder="Search Part Number or Name..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="bg-transparent text-xs outline-none w-64"
          />
        </div>
        <button onClick={handleExportExcel} className="px-3.5 py-1.5 bg-emerald-600 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer">
          <Download className="w-3.5 h-3.5" /> Export Spec Roster (.xlsx)
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full text-left text-xs border-collapse">
            <thead className="bg-slate-100 text-slate-700 font-bold text-[10px] uppercase">
              <tr>
                <th className="p-3">Part Number</th>
                <th className="p-3">Component Description</th>
                <th className="p-3">Model</th>
                <th className="p-3">Vendor</th>
                <th className="p-3 text-center">Cavity</th>
                <th className="p-3 text-right">Cycle Time</th>
                <th className="p-3 text-right">Net Wt</th>
                <th className="p-3">Approved RM</th>
                <th className="p-3 text-right">Approved Rate</th>
                <th className="p-3 text-right">Contract Cost</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filteredCatalog.map((p) => (
                <tr key={p.itemCode} className="hover:bg-slate-50">
                  <td className="p-3 font-mono font-bold text-blue-700">{p.itemCode}</td>
                  <td className="p-3 font-semibold text-slate-900">{p.componentName}</td>
                  <td className="p-3 text-slate-500">{p.model}</td>
                  <td className="p-3 text-slate-700">{p.vendor}</td>
                  <td className="p-3 text-center font-mono">{p.parameters?.cavity}</td>
                  <td className="p-3 text-right font-mono">{p.parameters?.cycleTimeApproved}s</td>
                  <td className="p-3 text-right font-mono">{p.parameters?.netWeightApproved}g</td>
                  <td className="p-3 font-mono text-purple-700">{p.approvedRm}</td>
                  <td className="p-3 text-right font-mono">₹{p.approvedRmRate?.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-bold text-emerald-700">₹{p.approvedTotalCost?.toFixed(2)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
