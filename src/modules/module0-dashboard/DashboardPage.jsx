import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, TrendingUp, TrendingDown, Layers, ShoppingCart, 
  Truck, Building2, Calendar, Filter, ArrowUpRight, DollarSign,
  Sliders
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function DashboardPage({ onNavigate }) {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');

  const vendors = globalStore.vendors || [];
  const baselineList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const purchaseMaster = globalStore.purchaseMaster || [];

  const vendorParts = baselineList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const calculatedItems = useMemo(() => {
    return vendorParts.map(part => {
      const params = part.parameters || {};
      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor, periodFrom);
      const approvedRmRate = rmMapping.approvedPrice || part.approvedRmRate || 136.20;
      const activeWaRate = rmMapping.activeWaPrice || approvedRmRate;

      const baselineSpec = {
        cavity: Number(part.cavity ?? params.cavity ?? 2),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 197),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 40),
        rmRate: approvedRmRate,
        masterbatchPct: Number(part.masterbatchPct ?? 0),
        masterbatchRate: Number(part.masterbatchRate ?? 0),
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 450),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 3600)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 48)
      };
      const baselineCalc = calculateDetailedCost(baselineSpec, true);

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

      const unitProfitLoss = Number((baselineCalc.totalCost - runningCalc.totalCost).toFixed(2));

      const matchedSales = salesData.filter(s => {
        const vendorMatch = selectedVendor === 'ALL' || s.vendor === part.vendor;
        const itemMatch = s.itemCode === part.itemCode;
        const dateMatch = s.invoiceDate >= periodFrom && s.invoiceDate <= periodTo;
        return vendorMatch && itemMatch && dateMatch;
      });

      const periodUnits = matchedSales.reduce((sum, s) => sum + Number(s.saleUnit || 0), 0);
      const totalPnL = Number((unitProfitLoss * periodUnits).toFixed(2));

      return {
        itemCode: part.itemCode,
        componentName: part.componentName,
        vendor: part.vendor || selectedVendor,
        approvedRm: part.approvedRm,
        baselineCost: baselineCalc.totalCost,
        actualCost: runningCalc.totalCost,
        unitProfitLoss,
        periodUnits,
        totalPnL
      };
    });
  }, [vendorParts, salesData, selectedVendor, periodFrom, periodTo]);

  const totalDispatchedVolume = calculatedItems.reduce((acc, r) => acc + r.periodUnits, 0);
  const netRealizedPnL = Number(calculatedItems.reduce((acc, r) => acc + r.totalPnL, 0).toFixed(2));

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-4">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <BarChart3 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">Executive MIS & Costing Intelligence Dashboard</h1>
            <p className="text-[11px] text-slate-300">Live multi-vendor costing consolidation & sales realization.</p>
          </div>
        </div>

        <div className="flex items-center gap-3 bg-slate-800 p-2 rounded-xl border border-slate-700">
          <div className="flex items-center gap-1.5">
            <Filter className="w-3.5 h-3.5 text-slate-400" />
            <span className="font-bold text-slate-300">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="bg-slate-900 border border-slate-600 text-white font-bold px-2 py-1 rounded text-xs outline-none"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Combined</option>
            </select>
          </div>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className={`p-4 rounded-2xl border ${netRealizedPnL >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
          <span className="text-[10px] font-bold uppercase text-slate-600 block">Net Realized P & L</span>
          <span className={`text-2xl font-black font-mono mt-1 block ${netRealizedPnL >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {netRealizedPnL >= 0 ? `+₹${netRealizedPnL.toFixed(2)}` : `-₹${Math.abs(netRealizedPnL).toFixed(2)}`}
          </span>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-300">
          <span className="text-[10px] font-bold text-slate-500 uppercase block">Total Sales Dispatched</span>
          <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">
            {totalDispatchedVolume.toLocaleString()} pcs
          </span>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-300">
          <span className="text-[10px] font-bold text-slate-500 uppercase block">Purchase WA Batches</span>
          <span className="text-2xl font-black text-amber-950 font-mono mt-1 block">
            {purchaseMaster.length} batches
          </span>
        </div>

        <div className="bg-white p-4 rounded-2xl border border-slate-300">
          <span className="text-[10px] font-bold text-slate-500 uppercase block">Onboarded Vendors</span>
          <span className="text-2xl font-black text-purple-950 font-mono mt-1 block">
            {vendors.length} OEMs
          </span>
        </div>
      </div>
    </div>
  );
}
