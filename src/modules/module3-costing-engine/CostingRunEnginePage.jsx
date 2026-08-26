import React, { useState, useEffect } from 'react';
import { 
  Calculator, 
  Download, 
  Search, 
  Filter, 
  TrendingUp, 
  TrendingDown,
  Layers,
  ArrowRight
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping, parseMaterialString } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function CostingRunEnginePage() {
  const [storeState, setStoreState] = useState(globalStore);
  const [selectedVendor, setSelectedVendor] = useState('ALL');
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const unsub = subscribeStore(() => {
      setStoreState({ ...globalStore });
    });
    return () => unsub();
  }, []);

  const vendors = storeState.vendors || [
    { vendorId: 'Haier Appliances', vendorName: 'Haier Appliances' },
    { vendorId: 'Atomberg Technologies', vendorName: 'Atomberg Technologies' },
    { vendorId: 'Atharva Polymer', vendorName: 'Atharva Polymer (Haier)' }
  ];

  const products = (storeState.baselineProducts || []).filter(p => 
    selectedVendor === 'ALL' || 
    (p.vendor || '').toLowerCase().includes(selectedVendor.toLowerCase()) ||
    selectedVendor.toLowerCase().includes((p.vendor || '').toLowerCase())
  );

  const filteredProducts = products.filter(p => 
    !searchQuery || 
    (p.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
    (p.approvedRm || '').toLowerCase().includes(searchQuery.toLowerCase())
  );

  const simulationRows = filteredProducts.map(prod => {
    const { baseRm, mbGrade } = parseMaterialString(prod.approvedRm || prod.baseRm);
    const rmLookupKey = baseRm || prod.baseRm || prod.approvedRm;
    const mbLookupKey = mbGrade || prod.approvedMb || ((prod.masterbatchPct || 0) > 0 ? 'White MB' : '');

    const rmMap = getActiveRmMapping(rmLookupKey, prod.vendor);
    const mbMap = getActiveMbMapping(mbLookupKey, prod.vendor);

    const detailed = calculateDetailedCost(prod);
    const approvedBaselineCost = Number(prod.approvedCost || detailed.totalCost || 0);
    const simulatedActualCost = Number(detailed.finalLanded || prod.approvedCost || 0);
    const delta = Number((approvedBaselineCost - simulatedActualCost).toFixed(2));

    return {
      ...prod,
      rmLookupKey,
      approvedRmRate: rmMap.approvedPrice || prod.approvedRmPrice || 0,
      activeWaRate: rmMap.activeWaPrice || rmMap.approvedPrice || prod.approvedRmPrice || 0,
      approvedBaselineCost,
      simulatedActualCost,
      delta
    };
  });

  const handleDownloadCostMatrix = () => {
    const exportData = simulationRows.map(r => ({
      "Item Code": r.itemCode,
      "Component Name": r.componentName,
      "Vendor": r.vendor,
      "Approved RM": r.approvedRm,
      "Approved RM Rate (₹/kg)": r.approvedRmRate,
      "Active WA Rate (₹/kg)": r.activeWaRate,
      "Approved Baseline Cost (₹)": r.approvedBaselineCost,
      "Simulated Actual Cost (₹)": r.simulatedActualCost,
      "Profit / Loss Delta (₹)": r.delta
    }));
    const ws = XLSX.utils.json_to_sheet(exportData);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Simulation_Matrix");
    XLSX.writeFile(wb, `Cost_Simulation_Matrix_${selectedVendor}_${new Date().toISOString().slice(0,10)}.xlsx`);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Calculator className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">3. Dynamic Costing Run Engine</h1>
            <p className="text-[11px] text-slate-300">Live simulation matching contract baselines against active material inward rates.</p>
          </div>
        </div>
        <button 
          onClick={handleDownloadCostMatrix}
          className="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-bold flex items-center gap-1.5 cursor-pointer shadow-sm transition"
        >
          <Download className="w-4 h-4" /> Export Simulation (.xlsx)
        </button>
      </div>

      {/* Filter Row */}
      <div className="bg-white p-3 rounded-2xl border border-slate-200 shadow-xs flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-2 flex-1 max-w-md bg-slate-50 px-3 py-1.5 rounded-xl border border-slate-200">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search components by name or part number..."
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            className="w-full bg-transparent border-none outline-hidden text-xs text-slate-800"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-600">Filter Vendor:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="px-3 py-1.5 rounded-xl bg-slate-100 text-slate-900 border border-slate-300 font-bold text-xs"
          >
            <option value="ALL">All Vendors Combined</option>
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Simulation Table with Red Box Download Button on Header */}
      <div className="bg-white rounded-2xl border border-slate-300 overflow-hidden shadow-sm">
        <div className="p-3 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-blue-400" />
            <h2 className="text-xs font-bold uppercase tracking-wider">Live Product Cost Simulation Matrix</h2>
          </div>
          
          <div className="flex items-center gap-3">
            {/* Red Box Target on Costing Page Header */}
            <button
              onClick={handleDownloadCostMatrix}
              className="px-3 py-1 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold flex items-center gap-1.5 cursor-pointer text-xs shadow-sm transition"
            >
              <Download className="w-3.5 h-3.5" /> Download Cost Matrix (.xlsx)
            </button>
            <span className="text-[11px] text-slate-400 font-mono">{filteredProducts.length} Products</span>
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase font-bold text-[10px]">
              <tr>
                <th className="py-2.5 px-3">Item Code / Component</th>
                <th className="py-2.5 px-3 text-center">Vendor</th>
                <th className="py-2.5 px-3">Approved RM</th>
                <th className="py-2.5 px-3 text-center">Approved RM Rate</th>
                <th className="py-2.5 px-3 text-center">Active Material Link</th>
                <th className="py-2.5 px-3 text-center text-blue-700">Active WA Rate</th>
                <th className="py-2.5 px-3 text-right bg-amber-50 text-amber-950 font-bold">Approved Baseline</th>
                <th className="py-2.5 px-3 text-right">Simulated Actual</th>
                <th className="py-2.5 px-4 text-center">Profit / Loss (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {simulationRows.length === 0 ? (
                <tr>
                  <td colSpan={9} className="py-12 text-center text-slate-400">
                    No products found for {selectedVendor}. Upload baseline data in <b>1. Baseline Master</b> to run live simulations.
                  </td>
                </tr>
              ) : (
                simulationRows.map(r => (
                  <tr key={r.id || r.itemCode} className="hover:bg-slate-50 transition">
                    <td className="py-2.5 px-3">
                      <div className="font-mono font-bold text-blue-700">{r.itemCode}</div>
                      <div className="font-semibold text-slate-800">{r.componentName}</div>
                    </td>
                    <td className="py-2.5 px-3 text-center">
                      <span className="bg-slate-100 text-slate-700 px-2 py-0.5 rounded text-[10px] font-bold">
                        {r.vendor}
                      </span>
                    </td>
                    <td className="py-2.5 px-3 font-medium text-slate-800">{r.approvedRm}</td>
                    <td className="py-2.5 px-3 text-center font-mono font-bold">₹{Number(r.approvedRmRate).toFixed(2)}/kg</td>
                    <td className="py-2.5 px-3 text-center text-[10px] font-mono text-slate-500">Linked to RM Matrix</td>
                    <td className="py-2.5 px-3 text-center font-mono font-bold text-blue-700">₹{Number(r.activeWaRate).toFixed(2)}/kg</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold bg-amber-50/40">₹{r.approvedBaselineCost.toFixed(2)}</td>
                    <td className="py-2.5 px-3 text-right font-mono font-bold text-slate-900">₹{r.simulatedActualCost.toFixed(2)}</td>
                    <td className="py-2.5 px-4 text-center">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full font-mono font-bold text-xs ${
                        r.delta >= 0 ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                      }`}>
                        {r.delta >= 0 ? <TrendingUp className="w-3.5 h-3.5" /> : <TrendingDown className="w-3.5 h-3.5" />}
                        {r.delta >= 0 ? `+ ₹${r.delta.toFixed(2)}` : `- ₹${Math.abs(r.delta).toFixed(2)}`}
                      </span>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
