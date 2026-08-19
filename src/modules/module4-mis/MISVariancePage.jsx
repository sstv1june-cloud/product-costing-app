import React, { useState, useEffect, useMemo } from 'react';
import { BarChart3, TrendingUp, TrendingDown, Eye, X, Filter, Calendar } from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function MISVariancePage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const rmMatrix = globalStore.rmMatrix || [];

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [drilldownItem, setDrilldownItem] = useState(null);

  const activeVendorRmRow = rmMatrix.find(r => r.vendor === selectedVendor) || rmMatrix[0];
  const [periodFrom, setPeriodFrom] = useState(activeVendorRmRow?.validFrom || '2026-01-15');
  const [periodTo, setPeriodTo] = useState(activeVendorRmRow?.validTo || '2026-02-14');

  useEffect(() => {
    if (activeVendorRmRow) {
      setPeriodFrom(activeVendorRmRow.validFrom || '2026-01-15');
      setPeriodTo(activeVendorRmRow.validTo || '2026-02-14');
    }
  }, [selectedVendor]);

  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const misRows = useMemo(() => {
    return vendorProducts.map(part => {
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

      // Filter sales strictly by invoiceDate falling between periodFrom and periodTo
      const matchedSales = salesData.filter(s => {
        const vendorMatch = selectedVendor === 'ALL' || s.vendor === part.vendor;
        const itemMatch = s.itemCode === part.itemCode;
        const dateMatch = s.invoiceDate >= periodFrom && s.invoiceDate <= periodTo;
        return vendorMatch && itemMatch && dateMatch;
      });

      const periodSaleUnits = matchedSales.reduce((sum, s) => sum + Number(s.saleUnit || 0), 0);
      const totalPnL = Number((unitProfitLoss * periodSaleUnits).toFixed(2));

      return {
        part,
        itemCode: part.itemCode,
        componentName: part.componentName,
        vendor: part.vendor || selectedVendor,
        baselineCost: baselineCalc.totalCost,
        actualCost: runningCalc.totalCost,
        unitProfitLoss,
        saleUnit: periodSaleUnits,
        totalPnL,
        salesRecords: matchedSales,
        baselineCalc,
        runningCalc
      };
    });
  }, [vendorProducts, salesData, selectedVendor, periodFrom, periodTo]);

  const totalPeriodVolume = misRows.reduce((acc, r) => acc + r.saleUnit, 0);
  const netRealizedPnL = Number(misRows.reduce((acc, r) => acc + r.totalPnL, 0).toFixed(2));

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Title Header */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex justify-between items-center">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <BarChart3 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">4. Sales Realization & Costing MIS Report</h1>
            <p className="text-[11px] text-slate-300">Period & Vendor Synced Variance Matrix</p>
          </div>
        </div>
      </div>

      {/* Exact Format Table */}
      <div className="bg-white border border-slate-300 rounded-2xl shadow-sm overflow-hidden p-4 space-y-3">
        <div className="overflow-x-auto border border-slate-400 rounded-xl">
          <table className="min-w-full text-xs text-left border-collapse">
            <tbody>
              
              {/* Row 1: Select | Vendor | Period | FROM | TO */}
              <tr className="border-b border-slate-300 bg-slate-50 font-bold text-slate-800">
                <td colSpan="2" className="p-2.5 border-r border-slate-300 text-sm">
                  Select
                </td>
                <td className="p-2.5 border-r border-slate-300 text-center uppercase tracking-wide">
                  Vendor
                </td>
                <td className="p-2.5 border-r border-slate-300 text-center uppercase">
                  Period
                </td>
                <td className="p-2.5 border-r border-slate-300 text-center uppercase bg-amber-50/70 text-amber-950">
                  <div className="flex items-center justify-center gap-1.5">
                    <span>FROM</span>
                    <input 
                      type="date" 
                      value={periodFrom} 
                      onChange={e => setPeriodFrom(e.target.value)} 
                      className="bg-white border border-amber-300 rounded p-1 font-mono text-xs font-bold text-amber-900" 
                    />
                  </div>
                </td>
                <td colSpan="2" className="p-2.5 text-center uppercase bg-amber-50/70 text-amber-950">
                  <div className="flex items-center justify-center gap-1.5">
                    <span>TO</span>
                    <input 
                      type="date" 
                      value={periodTo} 
                      onChange={e => setPeriodTo(e.target.value)} 
                      className="bg-white border border-amber-300 rounded p-1 font-mono text-xs font-bold text-amber-900" 
                    />
                  </div>
                </td>
              </tr>

              {/* Row 2: Select Dropdown | Vendor Selector | Data from Sale Header */}
              <tr className="border-b border-slate-300 bg-slate-100 font-bold text-slate-900">
                <td colSpan="2" className="p-2.5 border-r border-slate-300">
                  Select
                </td>
                <td className="p-2.5 border-r border-slate-300 text-center">
                  <select
                    value={selectedVendor}
                    onChange={e => setSelectedVendor(e.target.value)}
                    className="bg-white border-2 border-blue-600 text-blue-950 font-bold px-2 py-1 rounded text-xs"
                  >
                    <option value="Haier">Haier</option>
                    <option value="LG">LG</option>
                    <option value="Whirlpool">Whirlpool</option>
                    <option value="ALL">All</option>
                  </select>
                </td>
                <td className="p-2.5 border-r border-slate-300 bg-slate-200/50"></td>
                <td colSpan="2" className="p-2.5 border-r border-slate-300 text-center bg-blue-100/70 text-blue-950 uppercase tracking-wider">
                  Data from Sale
                </td>
                <td className="p-2.5 bg-slate-200/50"></td>
              </tr>

              {/* Row 3: Column Headers */}
              <tr className="bg-slate-800 text-white font-bold border-b border-slate-700 text-[11px]">
                <th colSpan="2" className="p-3 border-r border-slate-700 min-w-[320px]">
                  Item Code / Component
                </th>
                <th className="p-3 border-r border-slate-700 text-center min-w-[100px]">
                  Vendor
                </th>
                <th className="p-3 border-r border-slate-700 text-right min-w-[120px]">
                  Profit / Loss (Δ)
                </th>
                <th className="p-3 border-r border-slate-700 text-right min-w-[120px] bg-blue-950 text-blue-200">
                  Sale Unit
                </th>
                <th className="p-3 text-right min-w-[140px] bg-slate-900 text-amber-300">
                  Total P & L
                </th>
                <th className="p-3 text-center w-12">View</th>
              </tr>

              {/* Rows: Component Items */}
              {misRows.map((row) => (
                <tr 
                  key={row.itemCode} 
                  onClick={() => setDrilldownItem(row)}
                  className="border-b border-slate-200 hover:bg-blue-50/40 cursor-pointer font-medium"
                >
                  <td colSpan="2" className="p-3 border-r border-slate-300">
                    <span className="font-mono font-bold text-blue-700 block">{row.itemCode}</span>
                    <span className="text-[11px] text-slate-900 font-semibold">{row.componentName}</span>
                  </td>

                  <td className="p-3 border-r border-slate-300 text-center font-semibold text-slate-700">
                    {row.vendor}
                  </td>

                  <td className="p-3 border-r border-slate-300 text-right font-mono font-bold">
                    <span className={row.unitProfitLoss >= 0 ? 'text-emerald-700' : 'text-rose-600'}>
                      {row.unitProfitLoss >= 0 ? `₹ +${row.unitProfitLoss.toFixed(2)}` : `₹ -${Math.abs(row.unitProfitLoss).toFixed(2)}`}
                    </span>
                  </td>

                  <td className="p-3 border-r border-slate-300 text-right font-mono font-bold text-blue-950 bg-blue-50/30">
                    {row.saleUnit.toLocaleString()}
                  </td>

                  <td className="p-3 text-right font-mono font-black text-xs">
                    <span className={row.totalPnL >= 0 ? 'text-emerald-700' : 'text-rose-600'}>
                      {row.totalPnL >= 0 ? `₹ ${row.totalPnL.toFixed(2)}` : `₹ -${Math.abs(row.totalPnL).toFixed(2)}`}
                    </span>
                  </td>

                  <td className="p-3 text-center">
                    <button className="p-1 text-blue-600 hover:text-blue-900 hover:bg-blue-100 rounded-lg">
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}

              {/* Total Row */}
              <tr className="bg-slate-900 text-white font-black text-xs border-t-2 border-slate-700">
                <td colSpan="2" className="p-3 border-r border-slate-700 uppercase tracking-wider text-amber-400 font-bold">
                  Total
                </td>
                <td className="p-3 border-r border-slate-700 text-center text-slate-400">-</td>
                <td className="p-3 border-r border-slate-700 text-right text-slate-400">-</td>
                <td className="p-3 border-r border-slate-700 text-right font-mono text-blue-300">
                  {totalPeriodVolume.toLocaleString()}
                </td>
                <td className="p-3 text-right font-mono text-sm">
                  <span className={netRealizedPnL >= 0 ? 'text-emerald-400 font-black' : 'text-rose-400 font-black'}>
                    ₹ {netRealizedPnL.toFixed(2)}
                  </span>
                </td>
                <td className="p-3 text-center text-slate-500">-</td>
              </tr>

            </tbody>
          </table>
        </div>
      </div>

      {/* Drilldown Modal */}
      {drilldownItem && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl shadow-2xl max-w-3xl w-full p-5 space-y-4 border border-slate-300">
            <div className="flex justify-between items-start border-b pb-3">
              <div>
                <span className="px-2.5 py-0.5 bg-blue-600 text-white font-bold rounded-md font-mono text-[11px]">
                  {drilldownItem.itemCode}
                </span>
                <h3 className="font-bold text-sm text-slate-900 mt-1">{drilldownItem.componentName}</h3>
                <p className="text-slate-500 text-[11px]">Vendor: <span className="font-bold text-slate-800">{drilldownItem.vendor}</span> | Period: <span className="font-mono font-bold text-amber-800">{periodFrom} to {periodTo}</span></p>
              </div>
              <button onClick={() => setDrilldownItem(null)} className="p-1.5 text-slate-400 hover:text-slate-700 cursor-pointer">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-3 gap-3 text-center">
              <div className="bg-slate-100 p-3 rounded-xl border">
                <span className="text-[10px] text-slate-500 uppercase font-bold block">Profit / Loss (Δ)</span>
                <span className={`text-base font-black font-mono ${drilldownItem.unitProfitLoss >= 0 ? 'text-emerald-700' : 'text-rose-600'}`}>
                  {drilldownItem.unitProfitLoss >= 0 ? `+₹${drilldownItem.unitProfitLoss.toFixed(2)}` : `-₹${Math.abs(drilldownItem.unitProfitLoss).toFixed(2)}`}
                </span>
              </div>
              <div className="bg-slate-100 p-3 rounded-xl border">
                <span className="text-[10px] text-slate-500 uppercase font-bold block">Sale Unit</span>
                <span className="text-base font-black font-mono text-slate-900">{drilldownItem.saleUnit.toLocaleString()} pcs</span>
              </div>
              <div className={`p-3 rounded-xl border ${drilldownItem.totalPnL >= 0 ? 'bg-emerald-50 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
                <span className="text-[10px] font-bold uppercase block text-slate-700">Total P & L</span>
                <span className={`text-base font-black font-mono ${drilldownItem.totalPnL >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
                  {drilldownItem.totalPnL >= 0 ? `₹ +${drilldownItem.totalPnL.toFixed(2)}` : `₹ -${Math.abs(drilldownItem.totalPnL).toFixed(2)}`}
                </span>
              </div>
            </div>

            <div className="flex justify-end pt-2 border-t">
              <button onClick={() => setDrilldownItem(null)} className="px-4 py-1.5 bg-slate-900 text-white font-bold rounded-xl cursor-pointer">
                Close
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
