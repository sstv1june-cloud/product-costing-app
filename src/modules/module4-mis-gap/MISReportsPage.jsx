import React, { useState, useMemo } from 'react';
import { Upload, Filter, TrendingDown, DollarSign, BarChart3, ChevronRight, X, Calendar, CheckSquare, Square } from 'lucide-react';
import * as XLSX from 'xlsx';
import { getStoredSalesData, saveSalesData } from '../../shared/salesData';

export default function MISReportsPage() {
  const [salesRecords, setSalesRecords] = useState(getStoredSalesData);
  const [startDate, setStartDate] = useState('2026-07-01');
  const [endDate, setEndDate] = useState('2026-08-31');
  const [selectedVendors, setSelectedVendors] = useState(['ALL']);
  const [selectedParts, setSelectedParts] = useState(['ALL']);
  const [selectedDrilldownPart, setSelectedDrilldownPart] = useState(null);

  const vendorList = useMemo(() => Array.from(new Set(salesRecords.map(r => r.vendor || 'Haier'))), [salesRecords]);
  const partList = useMemo(() => {
    const map = new Map();
    salesRecords.forEach(r => {
      if (r.itemCode && !map.has(r.itemCode)) map.set(r.itemCode, { itemCode: r.itemCode, componentName: r.componentName });
    });
    return Array.from(map.values());
  }, [salesRecords]);

  const handleFileUpload = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const data = new Uint8Array(evt.target.result);
        const workbook = XLSX.read(data, { type: 'array' });
        const firstSheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[firstSheetName];
        const rawRows = XLSX.utils.sheet_to_json(worksheet);

        const parsedRecords = rawRows.map((row, idx) => {
          const itemCode = String(row["Part Number"] || row["Item Code"] || "").trim();
          const quantitySold = parseFloat(row["Quantity"] || row["Volume"]) || 0;
          const sellingPrice = parseFloat(row["Unit Price"] || row["Selling Price"]) || 0;
          return {
            id: `SLS-${Date.now()}-${idx}`,
            invoiceDate: String(row["Date"] || "2026-08-01").trim(),
            vendor: String(row["Vendor"] || "Haier").trim(),
            itemCode,
            componentName: String(row["Component Name"] || itemCode).trim(),
            model: String(row["Model"] || "Standard").trim(),
            quantitySold,
            sellingPricePerUnit: sellingPrice,
            approvedCostPerUnit: sellingPrice * 0.85,
            actualCostPerUnit: sellingPrice * 0.82
          };
        }).filter(r => r.itemCode.length > 0 && r.quantitySold > 0);

        if (parsedRecords.length > 0) {
          const combined = [...salesRecords, ...parsedRecords];
          setSalesRecords(combined);
          saveSalesData(combined);
          alert(`Successfully imported ${parsedRecords.length} records!`);
        }
      } catch (err) {
        alert("Upload error: " + err.message);
      }
    };
    reader.readAsArrayBuffer(file);
  };

  const filteredSales = useMemo(() => {
    return salesRecords.filter(r => {
      const withinDate = (!startDate || r.invoiceDate >= startDate) && (!endDate || r.invoiceDate <= endDate);
      const matchesVendor = selectedVendors.includes('ALL') || selectedVendors.includes(r.vendor);
      const matchesPart = selectedParts.includes('ALL') || selectedParts.includes(r.itemCode);
      return withinDate && matchesVendor && matchesPart;
    });
  }, [salesRecords, startDate, endDate, selectedVendors, selectedParts]);

  const pnlSummary = useMemo(() => {
    let totalRev = 0, totalApp = 0, totalAct = 0, totalVol = 0;
    filteredSales.forEach(r => {
      totalRev += r.quantitySold * r.sellingPricePerUnit;
      totalApp += r.quantitySold * r.approvedCostPerUnit;
      totalAct += r.quantitySold * r.actualCostPerUnit;
      totalVol += r.quantitySold;
    });
    return {
      totalVol,
      revenue: totalRev.toFixed(2),
      actualProfit: (totalRev - totalAct).toFixed(2),
      actualMargin: totalRev > 0 ? (((totalRev - totalAct) / totalRev) * 100).toFixed(1) : "0.0",
      varianceGain: (totalApp - totalAct).toFixed(2)
    };
  }, [filteredSales]);

  return (
    <div className="space-y-5 text-xs">
      <div className="bg-slate-900 text-white rounded-2xl p-5 shadow-md flex justify-between items-center flex-wrap gap-4">
        <div>
          <h1 className="text-base font-bold">Vendor & Product Sales P&L MIS Intelligence</h1>
          <p className="text-xs text-slate-300">Sales volume, gross margin realization, and contract variance</p>
        </div>
        <label className="px-4 py-2 bg-gradient-to-r from-purple-600 to-indigo-600 text-white font-bold rounded-xl flex items-center gap-2 cursor-pointer shadow-xs">
          <Upload className="w-3.5 h-3.5" /> Upload Sales Data (.xlsx)
          <input type="file" accept=".xlsx,.xls,.csv" onChange={handleFileUpload} className="hidden" />
        </label>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-xl border border-slate-200">
          <span className="text-slate-500 font-semibold block text-[10px] uppercase">Period Sales Volume</span>
          <span className="text-lg font-bold text-slate-900 mt-1 block">{pnlSummary.totalVol.toLocaleString()} pcs</span>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200">
          <span className="text-slate-500 font-semibold block text-[10px] uppercase">Total Sales Revenue</span>
          <span className="text-lg font-bold text-blue-700 mt-1 block">₹{Number(pnlSummary.revenue).toLocaleString()}</span>
        </div>
        <div className="bg-emerald-50 p-4 rounded-xl border border-emerald-200">
          <span className="text-emerald-700 font-bold block text-[10px] uppercase">Gross Profit & Margin</span>
          <span className="text-lg font-bold text-emerald-900 mt-1 block">₹{Number(pnlSummary.actualProfit).toLocaleString()} ({pnlSummary.actualMargin}%)</span>
        </div>
        <div className="bg-slate-900 text-white p-4 rounded-xl">
          <span className="text-slate-400 font-semibold block text-[10px] uppercase">Cost Variance Gain</span>
          <span className="text-lg font-bold text-emerald-400 mt-1 block">₹{Number(pnlSummary.varianceGain).toLocaleString()}</span>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs p-5 space-y-4">
        <div className="border border-slate-200 rounded-xl overflow-hidden">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold text-[10px] uppercase">
              <tr>
                <th className="p-3">Date</th>
                <th className="p-3">Part Code</th>
                <th className="p-3">Component Name</th>
                <th className="p-3">Vendor</th>
                <th className="p-3 text-right">Qty Sold</th>
                <th className="p-3 text-right">Selling Price</th>
                <th className="p-3 text-right">Contract Baseline</th>
                <th className="p-3 text-right">Actual Unit Cost</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filteredSales.map((r) => (
                <tr key={r.id} className="hover:bg-slate-50">
                  <td className="p-3 font-mono text-slate-500">{r.invoiceDate}</td>
                  <td className="p-3 font-mono font-bold text-blue-700">{r.itemCode}</td>
                  <td className="p-3 font-semibold text-slate-900">{r.componentName}</td>
                  <td className="p-3 text-slate-700">{r.vendor}</td>
                  <td className="p-3 text-right font-mono font-semibold">{r.quantitySold.toLocaleString()}</td>
                  <td className="p-3 text-right font-mono font-bold text-slate-900">₹{r.sellingPricePerUnit.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono text-slate-500">₹{r.approvedCostPerUnit.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-bold text-emerald-700">₹{r.actualCostPerUnit.toFixed(2)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
