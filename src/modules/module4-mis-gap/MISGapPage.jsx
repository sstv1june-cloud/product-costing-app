import React, { useState, useEffect, useMemo } from 'react';
import { 
  BarChart3, Filter, Calendar, Eye, X, CheckCircle2, TrendingUp, TrendingDown 
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISVariancePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const vendors = globalStore.vendors || [];

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [drilldownItem, setDrilldownItem] = useState(null);

  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const misRows = useMemo(() => {
    return vendorProducts.map(part => {
      const params = part.parameters || {};

      // Resolve RM Mapping & Rates
      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor, periodFrom);
      const approvedRmRate = rmMapping.approvedPrice || part.approvedRmRate || 136.20;
      const activeWaRate = rmMapping.activeWaPrice || approvedRmRate;

      // 1. Contract Baseline Calculation (Matches Costing Engine & Modal 100%)
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

      // 2. Actual Running Calculation
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

      // Unified baseline and running costs
      const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
      const actualUnitCost = Number(runningCalc.totalCost.toFixed(2));
      const unitProfitLoss = Number((contractBaseline - actualUnitCost).toFixed(2));

      // Match Sales Invoices for Selected Period
      const matchedSales = salesData.filter(s => {
        const vendorMatch = selectedVendor === 'ALL' || s.vendor === part.vendor;
        const itemMatch = s.itemCode === part.itemCode;
        const dateMatch = s.invoiceDate >= periodFrom && s.invoiceDate <= periodTo;
        return vendorMatch && itemMatch && dateMatch;
      });

      const qtySold = matchedSales.reduce((acc, s) => acc + Number(s.saleUnit || 0), 0);
      const latestSale = matchedSales[0] || {};
      const latestInvoiceDate = latestSale.invoiceDate || '2026-08-05';
      const sellingPrice = Number(latestSale.sellingPrice || (contractBaseline * 1.18).toFixed(2));

      const totalProfitLoss = Number((unitProfitLoss * qtySold).toFixed(2));
      const totalSales = Number((sellingPrice * qtySold).toFixed(2));
      const totalActualCost = Number((actualUnitCost * qtySold).toFixed(2));
      const grossProfit = Number((totalSales - totalActualCost).toFixed(2));

      return {
        part,
        date: latestInvoiceDate,
        itemCode: part.itemCode,
        componentName: part.componentName,
        vendor: part.vendor || selectedVendor,
        qtySold,
        sellingPrice,
        contractBaseline,
        actualUnitCost,
        unitProfitLoss,
        totalProfitLoss,
        totalSales,
        grossProfit,
        salesRecords: matchedSales,
        baselineCalc,
        runningCalc
      };
    });
  }, [vendorProducts, salesData, selectedVendor, periodFrom, periodTo]);

  const totalVolume = misRows.reduce((acc, r) => acc + r.qtySold, 0);
  const totalRevenue = misRows.reduce((acc, r) => acc + r.totalSales, 0);
  const totalGrossProfit = misRows.reduce((acc, r) => acc + r.grossProfit, 0);
  const grossMarginPct = totalRevenue > 0 ? ((totalGrossProfit / totalRevenue) * 100).toFixed(1) : 0;
  const totalCostVarianceGain = misRows.reduce((acc, r) => acc + r.totalProfitLoss, 0);

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex justify-between items-center">
        <div>
          <h1 className="text-sm font-bold flex items-center gap-2">
            <BarChart3 className="w-4 h-4 text-blue-400" /> Vendor & Product Sales P&L MIS Intelligence
          </h1>
          <p className="text-[11px] text-slate-300">Synchronized Piece Costing Variance Engine</p>
        </div>
      </div>

      {/* 1. TOP FILTER BAR */}
      <div className="bg-white p-3.5 rounded-2xl border border-slate-300 shadow-xs flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-4 flex-wrap">
          <div className="flex items-center gap-2">
            <Filter className="w-3.5 h-3.5 text-slate-500" />
            <span className="font-bold text-slate-800 text-xs uppercase tracking-wider">Vendor:</span>
            <select
              value={selectedVendor}
              onChange={e => setSelectedVendor(e.target.value)}
              className="bg-white border-2 border-blue-600 text-blue-950 font-bold px-3 py-1 rounded-xl text-xs outline-none cursor-pointer"
            >
              {vendors.map(v => (
                <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
              ))}
              <option value="ALL">All Vendors Combined</option>
            </select>
          </div>

          <div className="h-5 w-px bg-slate-300"></div>

          <div className="flex items-center gap-2">
            <Calendar className="w-3.5 h-3.5 text-amber-600" />
            <span className="font-bold text-slate-800 text-xs uppercase tracking-wider">Period:</span>
            <div className="flex items-center gap-1">
              <span className="text-[10px] font-bold text-slate-500 uppercase">From</span>
              <input
                type="date"
                value={periodFrom}
                onChange={e => setPeriodFrom(e.target.value)}
                className="bg-slate-50 border border-slate-300 font-mono font-bold text-blue-950 px-2 py-1 rounded-lg text-xs outline-none"
              />
            </div>
            <div className="flex items-center gap-1">
              <span className="text-[10px] font-bold text-slate-500 uppercase">To</span>
              <input
                type="date"
                value={periodTo}
                onChange={e => setPeriodTo(e.target.value)}
                className="bg-slate-50 border border-slate-300 font-mono font-bold text-blue-950 px-2 py-1 rounded-lg text-xs outline-none"
              />
            </div>
          </div>
        </div>

        <div className="text-[11px] font-semibold text-slate-500">
          Showing data for <span className="font-bold text-slate-900">{selectedVendor}</span> ({periodFrom} to {periodTo})
        </div>
      </div>

      {/* 2. SYNCED SUMMARY SECTION */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Period Sales Volume</span>
          <span className="text-xl font-black text-slate-900 font-mono mt-1 block">
            {totalVolume.toLocaleString()} <span className="text-xs font-sans font-medium text-slate-500">pcs</span>
          </span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Total Sales Revenue</span>
          <span className="text-xl font-black text-blue-900 font-mono mt-1 block">
            ₹{totalRevenue.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}
          </span>
        </div>

        <div className="bg-emerald-50/70 border border-emerald-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-emerald-800 uppercase tracking-wider block">Gross Profit & Margin</span>
          <span className="text-xl font-black text-emerald-700 font-mono mt-1 block">
            ₹{totalGrossProfit.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}{' '}
            <span className="text-xs font-sans font-bold">({grossMarginPct}%)</span>
          </span>
        </div>

        {/* Cost Variance Gain card with Color coding */}
        <div className={`rounded-2xl p-4 shadow-xs border ${
          totalCostVarianceGain >= 0 ? 'bg-emerald-950/90 border-emerald-800' : 'bg-slate-900 border-rose-800/80'
        }`}>
          <div className="flex justify-between items-center">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-300">Cost Variance Gain / Loss</span>
            {totalCostVarianceGain >= 0 ? <TrendingUp className="w-3.5 h-3.5 text-emerald-400" /> : <TrendingDown className="w-3.5 h-3.5 text-rose-400" />}
          </div>
          <span className={`text-xl font-black font-mono mt-1 block ${
            totalCostVarianceGain >= 0 ? 'text-emerald-400' : 'text-rose-400'
          }`}>
            {totalCostVarianceGain >= 0 ? `₹ +${totalCostVarianceGain.toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}` : `₹ -${Math.abs(totalCostVarianceGain).toLocaleString('en-IN', { minimumFractionDigits: 0, maximumFractionDigits: 0 })}`}
          </span>
        </div>
      </div>

      {/* 3. MAIN TABLE (Synchronized 100% with Costing Engine & Modals) */}
      <div className="bg-white border border-slate-300 rounded-2xl shadow-sm overflow-hidden p-4 space-y-3">
        <div className="flex justify-between items-center border-b pb-2">
          <h2 className="font-bold text-slate-900 text-sm">Product Sales Realization & Costing Analysis</h2>
          <span className="text-[11px] text-slate-500 italic">Click on any row for sales batch drilldown</span>
        </div>

        <div className="overflow-x-auto border border-slate-300 rounded-xl">
          <table className="min-w-full text-xs text-left border-collapse">
            <thead>
              <tr className="bg-slate-100 text-slate-800 font-bold uppercase text-[10px] border-b border-slate-300">
                <th className="p-3">Date</th>
                <th className="p-3">Part Code</th>
                <th className="p-3 min-w-[220px]">Component Name</th>
                <th className="p-3">Vendor</th>
                <th className="p-3 text-right">Qty Sold</th>
                <th className="p-3 text-right">Selling Price</th>
                <th className="p-3 text-right">Contract Baseline</th>
                <th className="p-3 text-right">Actual Unit Cost</th>
                
                {/* Column 1: Amber Tint */}
                <th className="p-3 text-right bg-amber-200/90 text-amber-950 font-black border-l-2 border-amber-300">
                  Profit / Loss (Δ)
                </th>
                
                {/* Column 2: Sky Blue Tint */}
                <th className="p-3 text-right bg-sky-200/90 text-sky-950 font-black border-l border-sky-300">
                  Total Profit / Loss (Δ)
                </th>
                
                {/* Column 3: Orange Tint */}
                <th className="p-3 text-right bg-orange-200/80 text-orange-950 font-black border-l border-r-2 border-orange-300">
                  Total Sales
                </th>
                
                <th className="p-3 text-center w-12">Action</th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-200 font-medium">
              {misRows.map((row) => (
                <tr
                  key={row.itemCode}
                  onClick={() => setDrilldownItem(row)}
                  className="hover:bg-slate-50 cursor-pointer transition"
                >
                  <td className="p-3 font-mono text-slate-500">{row.date}</td>
                  
                  <td className="p-3 font-mono font-bold text-blue-700">
                    {row.itemCode}
                  </td>

                  <td className="p-3 font-semibold text-slate-900">
                    {row.componentName}
                  </td>

                  <td className="p-3 font-semibold text-slate-700">
                    {row.vendor}
                  </td>

                  <td className="p-3 text-right font-mono font-black text-slate-900">
                    {row.qtySold.toLocaleString()}
                  </td>

                  <td className="p-3 text-right font-mono font-bold text-slate-800">
                    ₹ {row.sellingPrice.toFixed(2)}
                  </td>

                  <td className="p-3 text-right font-mono text-slate-600 font-bold">
                    ₹ {row.contractBaseline.toFixed(2)}
                  </td>

                  <td className="p-3 text-right font-mono font-bold text-slate-900">
                    ₹ {row.actualUnitCost.toFixed(2)}
                  </td>

                  {/* 1. Unit Profit / Loss (Δ) with +/- Green/Red coloring */}
                  <td className="p-3 text-right font-mono font-black bg-amber-50/70 border-l-2 border-amber-300">
                    <span className={row.unitProfitLoss >= 0 ? 'text-emerald-600' : 'text-rose-600'}>
                      {row.unitProfitLoss >= 0 ? `₹ +${row.unitProfitLoss.toFixed(2)}` : `₹ -${Math.abs(row.unitProfitLoss).toFixed(2)}`}
                    </span>
                  </td>

                  {/* 2. Total Profit / Loss (Δ) */}
                  <td className="p-3 text-right font-mono font-black bg-sky-50/70 border-l border-sky-300">
                    <span className={row.totalProfitLoss >= 0 ? 'text-emerald-600' : 'text-rose-600'}>
                      {row.totalProfitLoss >= 0 ? `₹ +${row.totalProfitLoss.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}` : `₹ -${Math.abs(row.totalProfitLoss).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`}
                    </span>
                  </td>

                  {/* 3. Total Sales */}
                  <td className="p-3 text-right font-mono font-black bg-orange-50/60 text-slate-900 border-l border-r-2 border-orange-300">
                    ₹ {row.totalSales.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>

                  <td className="p-3 text-center">
                    <button className="p-1 text-blue-600 hover:text-blue-900 hover:bg-blue-100 rounded-lg">
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* 4. DRILLDOWN MODAL */}
      {drilldownItem && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl shadow-2xl max-w-4xl w-full p-5 space-y-4 border border-slate-300 animate-in fade-in duration-100">
            <div className="flex justify-between items-start border-b pb-3">
              <div>
                <span className="px-2.5 py-0.5 bg-blue-600 text-white font-bold rounded-md font-mono text-[11px]">
                  {drilldownItem.itemCode}
                </span>
                <h3 className="font-bold text-sm text-slate-900 mt-1">{drilldownItem.componentName}</h3>
                <p className="text-slate-500 text-[11px]">
                  Vendor: <span className="font-bold text-slate-800">{drilldownItem.vendor}</span> | Period: <span className="font-mono font-bold text-amber-800">{periodFrom} to {periodTo}</span>
                </p>
              </div>
              <button onClick={() => setDrilldownItem(null)} className="p-1.5 text-slate-400 hover:text-slate-700 cursor-pointer">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-4 gap-3 text-center">
              <div className="bg-slate-100 p-3 rounded-xl border">
                <span className="text-[10px] text-slate-500 uppercase font-bold block">Contract Baseline</span>
                <span className="text-base font-black font-mono text-slate-900">₹{drilldownItem.contractBaseline.toFixed(2)}</span>
              </div>
              <div className="bg-blue-50 p-3 rounded-xl border border-blue-200">
                <span className="text-[10px] text-blue-700 uppercase font-bold block">Actual Unit Cost</span>
                <span className="text-base font-black font-mono text-blue-950">₹{drilldownItem.actualUnitCost.toFixed(2)}</span>
              </div>
              <div className="bg-slate-100 p-3 rounded-xl border">
                <span className="text-[10px] text-slate-500 uppercase font-bold block">Period Qty Sold</span>
                <span className="text-base font-black font-mono text-slate-900">{drilldownItem.qtySold.toLocaleString()} pcs</span>
              </div>
              <div className={`p-3 rounded-xl border ${drilldownItem.totalProfitLoss >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
                <span className={`text-[10px] font-bold uppercase block ${drilldownItem.totalProfitLoss >= 0 ? 'text-emerald-900' : 'text-rose-900'}`}>Total Profit / Loss</span>
                <span className={`text-base font-black font-mono ${drilldownItem.totalProfitLoss >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {drilldownItem.totalProfitLoss >= 0 ? `₹ +${drilldownItem.totalProfitLoss.toLocaleString('en-IN', { minimumFractionDigits: 2 })}` : `₹ -${Math.abs(drilldownItem.totalProfitLoss).toLocaleString('en-IN', { minimumFractionDigits: 2 })}`}
                </span>
              </div>
            </div>

            <div className="flex justify-end pt-2 border-t">
              <button
                onClick={() => setDrilldownItem(null)}
                className="px-4 py-1.5 bg-slate-900 text-white font-bold rounded-xl cursor-pointer"
              >
                Close Drilldown
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
