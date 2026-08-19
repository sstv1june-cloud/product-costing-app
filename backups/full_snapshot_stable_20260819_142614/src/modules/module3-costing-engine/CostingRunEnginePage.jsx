import React, { useState, useEffect } from 'react';
import { 
  DollarSign, Sliders, Search, TrendingUp, TrendingDown, 
  CheckCircle2 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping, getVendorBaselineData } from '../../shared/masterStore';
import { calculatePieceCostUnified } from '../../shared/costCalculationService';

export default function CostingRunEnginePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const vendors = globalStore.vendors || [];
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [searchQuery, setSearchQuery] = useState('');

  const rawList = getVendorBaselineData(selectedVendor);

  const filteredItems = rawList.filter(item => {
    return (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) ||
           (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
  });

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <DollarSign className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">3. Dynamic Costing Run Engine</h1>
            <p className="text-[11px] text-slate-300">Live simulation of product piece costing matching contract baselines against active material inward rates.</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[10px] bg-emerald-500/20 text-emerald-300 border border-emerald-500/40 px-2.5 py-1 rounded-full font-bold flex items-center gap-1.5">
            <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" /> Engine Active & Linked to RM Matrix
          </span>
        </div>
      </div>

      <div className="bg-white p-3 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search components by name or part number..."
            className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="font-bold text-slate-700">Filter Vendor:</span>
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

      <div className="bg-white rounded-2xl shadow-sm border border-slate-300 overflow-hidden">
        <div className="px-5 py-3 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
          <h2 className="text-sm font-bold flex items-center gap-2">
            <Sliders className="w-4 h-4 text-blue-400" /> Live Product Cost Simulation Matrix
          </h2>
          <span className="text-[11px] text-slate-300 font-mono">{filteredItems.length} Products</span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
              <tr>
                <th className="p-3">ITEM CODE / COMPONENT</th>
                <th className="p-3 text-center">VENDOR</th>
                <th className="p-3">APPROVED RM</th>
                <th className="p-3 text-right bg-amber-50">APPROVED RM RATE</th>
                <th className="p-3">ACTIVE ALTERNATE RM (INWARD)</th>
                <th className="p-3 text-right bg-blue-50">ACTIVE WA RATE</th>
                <th className="p-3 text-right bg-amber-50 font-bold">APPROVED BASELINE</th>
                <th className="p-3 text-right bg-blue-50 font-bold">SIMULATED ACTUAL</th>
                <th className="p-3 text-right">PROFIT / LOSS (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 font-medium">
              {filteredItems.map((item) => {
                const vName = item.vendor || selectedVendor;
                const rmMapping = getActiveRmMapping(item.approvedRm, vName, '2026-08-01');

                const baselineCalc = calculatePieceCostUnified({
                  item: { ...item, vendor: vName },
                  isBaseline: true,
                  targetDate: '2026-08-01'
                });

                const runningCalc = calculatePieceCostUnified({
                  item: { ...item, vendor: vName },
                  isBaseline: false,
                  targetDate: '2026-08-01'
                });

                const contractBaseline = Number(baselineCalc.finalLanded.toFixed(2));
                const actualCost = Number(runningCalc.finalLanded.toFixed(2));
                const unitProfitLoss = Number((contractBaseline - actualCost).toFixed(2));

                return (
                  <tr key={item.id} className="hover:bg-slate-50">
                    <td className="p-3">
                      <span className="font-mono font-bold text-blue-700 block">{item.itemCode}</span>
                      <span className="font-semibold text-slate-900">{item.componentName}</span>
                    </td>
                    <td className="p-3 text-center">
                      <span className="bg-slate-100 border border-slate-300 font-bold px-2 py-0.5 rounded text-[10px]">
                        {vName}
                      </span>
                    </td>
                    <td className="p-3 font-semibold text-slate-800">{item.approvedRm}</td>
                    <td className="p-3 text-right font-mono font-bold text-slate-900 bg-amber-50/50">
                      ₹{Number(rmMapping.approvedPrice || item.approvedRmRate).toFixed(2)}/kg
                    </td>
                    <td className="p-3">
                      <span className="font-bold text-blue-900 block">{rmMapping.activeRmName}</span>
                      <span className="text-[10px] text-slate-500 font-mono">Linked to RM Matrix</span>
                    </td>
                    <td className="p-3 text-right font-mono font-bold text-blue-900 bg-blue-50/50">
                      ₹{Number(rmMapping.activeWaPrice).toFixed(2)}/kg
                    </td>
                    <td className="p-3 text-right font-mono font-black text-slate-900 bg-amber-50/50 text-xs">
                      ₹{contractBaseline.toFixed(2)}
                    </td>
                    <td className="p-3 text-right font-mono font-black text-blue-950 bg-blue-50/50 text-xs">
                      ₹{actualCost.toFixed(2)}
                    </td>
                    <td className="p-3 text-right font-mono font-black">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded text-[11px] ${
                        unitProfitLoss >= 0 ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' : 'bg-rose-100 text-rose-800 border border-rose-300'
                      }`}>
                        {unitProfitLoss >= 0 ? <TrendingUp className="w-3.5 h-3.5 text-emerald-600" /> : <TrendingDown className="w-3.5 h-3.5 text-rose-600" />}
                        {unitProfitLoss >= 0 ? `₹ +${unitProfitLoss.toFixed(2)}` : `₹ -${Math.abs(unitProfitLoss).toFixed(2)}`}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
