import React, { useState, useEffect } from 'react';
import { Calculator, Play, TrendingDown, TrendingUp, Search, CheckCircle2 } from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function CostingRunEnginePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedVendor, setSelectedVendor] = useState('ALL');

  const filteredList = masterList.filter(item => {
    const matchSearch = (item.componentName || '').toLowerCase().includes(searchQuery.toLowerCase()) || 
                        (item.itemCode || '').toLowerCase().includes(searchQuery.toLowerCase());
    const matchVendor = selectedVendor === 'ALL' || item.vendor === selectedVendor;
    return matchSearch && matchVendor;
  });

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Engine Header Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-5 shadow-md flex justify-between items-center">
        <div className="flex items-center gap-3">
          <div className="p-3 bg-blue-600 rounded-xl">
            <Calculator className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-base font-bold">3. Dynamic Costing Run Engine</h1>
            <p className="text-xs text-slate-300">
              Live simulation of product piece costing matching contract baselines against active Weighted Average (WA) material inward rates.
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2 bg-slate-800 border border-slate-700 px-3.5 py-2 rounded-xl">
          <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          <span className="font-bold text-emerald-400 text-xs">Engine Active & Linked to RM Matrix</span>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-300 shadow-sm flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3 flex-1 min-w-[280px]">
          <div className="relative flex-1">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-2.5" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search components by name or part number..."
              className="w-full pl-9 pr-3 py-1.5 border border-slate-300 rounded-xl text-xs focus:ring-2 focus:ring-blue-500 outline-none"
            />
          </div>

          <select
            value={selectedVendor}
            onChange={(e) => setSelectedVendor(e.target.value)}
            className="border border-slate-300 rounded-xl px-3 py-1.5 text-xs font-semibold bg-white text-slate-800 focus:ring-2 focus:ring-blue-500 outline-none cursor-pointer"
          >
            <option value="ALL">All Vendors</option>
            <option value="Haier">Haier Appliances</option>
            <option value="LG">LG Electronics</option>
            <option value="Whirlpool">Whirlpool India</option>
          </select>
        </div>
      </div>

      {/* Simulation Matrix Table */}
      <div className="bg-white border border-slate-300 rounded-2xl shadow-sm overflow-hidden">
        <div className="px-5 py-3.5 border-b border-slate-200 bg-slate-900 text-white flex justify-between items-center">
          <div className="flex items-center gap-2">
            <Play className="w-4 h-4 text-blue-400" />
            <h2 className="text-sm font-bold">Live Product Cost Simulation Matrix</h2>
          </div>
          <span className="bg-blue-600 px-2.5 py-0.5 rounded-lg font-bold text-[11px]">
            {filteredList.length} Active Products
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full text-xs text-left border-collapse">
            <thead>
              <tr className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] border-b border-slate-300">
                <th className="p-3 min-w-[200px]">Item Code / Component</th>
                <th className="p-3">Vendor</th>
                <th className="p-3 min-w-[150px]">Approved RM</th>
                <th className="p-3 text-right bg-amber-50 text-amber-950">Approved RM Rate</th>
                <th className="p-3 min-w-[180px] bg-blue-50 text-blue-950">Active Alternate RM (Inward)</th>
                <th className="p-3 text-right bg-blue-50 text-blue-950">Active WA Rate</th>
                <th className="p-3 text-right bg-amber-100/60 text-amber-950 font-black">Approved Baseline</th>
                <th className="p-3 text-right bg-blue-100/60 text-blue-950 font-black">Simulated Actual</th>
                <th className="p-3 text-right">Profit / Loss (Δ)</th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-200 font-medium text-slate-800">
              {filteredList.map((item) => {
                const params = item.parameters || {};

                // Strict resolution from Vendor-Specific RM Matrix
                const rmMapping = getActiveRmMapping(item.approvedRm, item.vendor);
                const approvedRmRate = rmMapping.approvedPrice || item.approvedRmRate || 136.20;
                const activeWaRate = rmMapping.activeWaPrice || approvedRmRate;
                const activeAltName = rmMapping.activeRmName || item.approvedRm;

                // 1. Calculate Approved Baseline Cost
                const baselineSpec = {
                  cavity: Number(item.cavity ?? params.cavity ?? 2),
                  netWeight: Number(item.netWeight ?? params.netWeightApproved ?? 197),
                  runnerWeight: Number(item.runnerWeight ?? params.runnerWeight ?? 40),
                  rmRate: approvedRmRate,
                  masterbatchPct: Number(item.masterbatchPct ?? 0),
                  masterbatchRate: Number(item.masterbatchRate ?? 0),
                  machineTonnage: Number(item.machineTonnage ?? params.machineTonnage ?? 450),
                  shiftTariff: Number(item.hourlyRate ? item.hourlyRate * 8 : (params.shiftTariff ?? 3600)),
                  cycleTime: Number(item.cycleTimeApproved ?? item.cycleTime ?? 48)
                };
                const baselineCalc = calculateDetailedCost(baselineSpec, true);

                // 2. Calculate Actual Running Simulated Cost
                const runningSpec = {
                  cavity: Number(params.runningCavity ?? baselineSpec.cavity),
                  netWeight: Number(params.runningNetWeight ?? baselineSpec.netWeight),
                  runnerWeight: Number(params.runningRunnerWeight ?? baselineSpec.runnerWeight),
                  rmRate: activeWaRate,
                  masterbatchPct: Number(params.runningMbPct ?? baselineSpec.masterbatchPct),
                  masterbatchRate: baselineSpec.masterbatchRate,
                  machineTonnage: Number(params.runningTonnage ?? baselineSpec.machineTonnage),
                  shiftTariff: Number(params.runningShiftTariff ?? (params.runningTonnage >= 600 ? 4800 : baselineSpec.shiftTariff)),
                  cycleTime: Number(params.runningCycleTime ?? baselineSpec.cycleTime)
                };
                const runningCalc = calculateDetailedCost(runningSpec, false);

                // Profit / Loss = Approved Baseline - Simulated Actual
                // Positive = Profit / Cost Saving (+ Green)
                // Negative = Loss / Cost Escalation (- Red)
                const profitDelta = Number((baselineCalc.totalCost - runningCalc.totalCost).toFixed(2));
                const rmRateSaving = Number((approvedRmRate - activeWaRate).toFixed(2));

                return (
                  <tr key={item.id} className="hover:bg-slate-50 transition">
                    
                    {/* Item Code & Name */}
                    <td className="p-3">
                      <span className="font-mono font-bold text-blue-700 block">{item.itemCode}</span>
                      <span className="text-[11px] text-slate-900 font-semibold">{item.componentName}</span>
                    </td>

                    {/* Vendor */}
                    <td className="p-3">
                      <span className="px-2 py-0.5 bg-slate-100 border border-slate-300 rounded font-semibold text-slate-800">
                        {item.vendor || "Haier"}
                      </span>
                    </td>

                    {/* Approved RM */}
                    <td className="p-3 font-semibold text-slate-800">
                      {item.approvedRm}
                    </td>

                    {/* Approved RM Rate */}
                    <td className="p-3 text-right font-mono font-bold text-amber-950 bg-amber-50/40">
                      ₹{approvedRmRate.toFixed(2)}/kg
                    </td>

                    {/* Active Alternate RM Name */}
                    <td className="p-3 bg-blue-50/30">
                      <span className="font-semibold text-blue-950 block">{activeAltName}</span>
                      <span className="text-[10px] text-slate-500 font-mono">Linked to RM Matrix</span>
                    </td>

                    {/* Active WA Rate */}
                    <td className="p-3 text-right font-mono font-bold text-blue-950 bg-blue-50/40">
                      <div>₹{activeWaRate.toFixed(2)}/kg</div>
                      <div className={`text-[10px] font-bold ${rmRateSaving >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                        {rmRateSaving >= 0 ? `+₹${rmRateSaving.toFixed(2)}` : `-₹${Math.abs(rmRateSaving).toFixed(2)}`}
                      </div>
                    </td>

                    {/* Approved Total Cost */}
                    <td className="p-3 text-right font-mono font-black text-amber-950 bg-amber-100/40 text-xs">
                      ₹{baselineCalc.totalCost.toFixed(2)}
                    </td>

                    {/* Actual Simulated Cost */}
                    <td className="p-3 text-right font-mono font-black text-blue-950 bg-blue-100/40 text-xs">
                      ₹{runningCalc.totalCost.toFixed(2)}
                    </td>

                    {/* Profit (+) in Green / Loss (-) in Red */}
                    <td className="p-3 text-right font-mono font-bold text-xs">
                      <div className={`flex items-center justify-end gap-1 ${profitDelta >= 0 ? 'text-emerald-600 font-black' : 'text-rose-600 font-black'}`}>
                        {profitDelta >= 0 ? <TrendingUp className="w-3.5 h-3.5" /> : <TrendingDown className="w-3.5 h-3.5" />}
                        <span>{profitDelta >= 0 ? `+₹${profitDelta.toFixed(2)}` : `-₹${Math.abs(profitDelta).toFixed(2)}`}</span>
                      </div>
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
