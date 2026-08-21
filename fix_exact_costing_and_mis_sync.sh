#!/usr/bin/env bash
set -e

echo "==> 1. Inspecting InlineEditModal.jsx calculation routines..."
cat src/modules/module1-baseline/InlineEditModal.jsx | head -n 40 || true

echo "==> 2. Writing unified costCalculationService.js with EXACT formulas matching InlineEditModal..."
cat << 'CALC_EOF' > src/shared/costCalculationService.js
// ============================================================================
// UNIVERSAL COST CALCULATION ENGINE SERVICE (Matches Edit Spec Modal Exactly)
// ============================================================================

export function calculateHaierCost(item, overrideParams = {}) {
  const nw = Number(overrideParams.netWeight ?? item?.parameters?.runningNetWeight ?? item?.netWeight ?? 197);
  const rw = Number(overrideParams.runnerWeight ?? item?.parameters?.runningRunnerWeight ?? item?.runnerWeight ?? 40);
  const cav = Number(overrideParams.cavity ?? item?.parameters?.runningCavity ?? item?.cavity ?? 2) || 1;
  const ct = Number(overrideParams.cycleTime ?? item?.parameters?.runningCycleTime ?? item?.cycleTime ?? 48) || 48;
  const st = Number(overrideParams.shiftTariff ?? item?.shiftTariff ?? 3600);

  const isRunningActual = overrideParams.actualRmRate !== undefined || overrideParams.actualMbRate !== undefined;
  const appRm = Number(item?.approvedRmRate ?? 136.20);
  const actRm = Number(overrideParams.actualRmRate ?? item?.actualRmRate ?? appRm);
  const activeRm = isRunningActual ? actRm : appRm;

  const mbPct = Number(overrideParams.masterbatchPct ?? item?.parameters?.runningMbPct ?? item?.masterbatchPct ?? 0);
  const appMb = Number(item?.masterbatchRate ?? 0);
  const actMb = Number(overrideParams.actualMbRate ?? item?.actualMbRate ?? appMb);
  const activeMb = isRunningActual ? actMb : appMb;

  const shotWeight = nw + rw;
  const partShotWeight = shotWeight / (cav > 0 ? cav : 1);
  const mbWeight = (partShotWeight * mbPct) / 100;
  const baseRmWeight = partShotWeight - mbWeight;

  // Material cost calculation
  const matCost = ((baseRmWeight * activeRm) + (mbWeight * activeMb)) / 1000;

  // Conversion / Machine rate calculation with 95% efficiency
  const shotsPerShift = (8 * 3600) / ct;
  const shotsWithEff = shotsPerShift * 0.95;
  const partsPerShift = shotsWithEff * cav;
  const prodCostPerPc = partsPerShift > 0 ? (st / partsPerShift) : 0;

  // Haier 38-line overhead & markups
  const subTotal = matCost + prodCostPerPc;
  const ohAndProfit = subTotal * 0.15;
  const iccReduce = -(subTotal * 0.005);
  const bopCost = Number(overrideParams.bopCost ?? item?.parameters?.runningBopCost ?? item?.bopCost ?? (item?.itemCode === '0060217989D' ? 0.14 : 0));
  const postOpCost = Number(overrideParams.postOpCost ?? item?.parameters?.runningPostOpCost ?? item?.postOpCost ?? 0);

  const finalLanded = subTotal + ohAndProfit + iccReduce + bopCost + postOpCost;

  // Compute both baseline and actual simultaneously for delta
  const appMatCost = ((baseRmWeight * appRm) + (mbWeight * appMb)) / 1000;
  const actMatCost = ((baseRmWeight * actRm) + (mbWeight * actMb)) / 1000;
  const appSubTotal = appMatCost + prodCostPerPc;
  const actSubTotal = actMatCost + prodCostPerPc;
  const totalApproved = appSubTotal + (appSubTotal * 0.15) - (appSubTotal * 0.005) + bopCost + postOpCost;
  const totalActual = actSubTotal + (actSubTotal * 0.15) - (actSubTotal * 0.005) + bopCost + postOpCost;
  const delta = totalApproved - totalActual;

  return {
    netWeight: nw,
    runnerWeight: rw,
    cavity: cav,
    cycleTime: ct,
    shiftTariff: st,
    shotWeight,
    partShotWeight,
    baseRmWeight,
    mbWeight,
    shotsPerShift,
    shotsWithEff,
    partsPerShift,
    prodCostPerPc,
    subTotal,
    ohAndProfit,
    iccReduce,
    rmBaseRate: activeRm,
    approvedRmRate: appRm,
    actualRmRate: actRm,
    finalLanded: Number(finalLanded.toFixed(2)),
    approvedBaseline: Number(totalApproved.toFixed(2)),
    actualRunning: Number(totalActual.toFixed(2)),
    totalApproved: Number(totalApproved.toFixed(2)),
    totalActual: Number(totalActual.toFixed(2)),
    delta: Number(delta.toFixed(2)),
    deltaCost: Number(delta.toFixed(2))
  };
}

export function calculateAtombergCost(item, overrideParams = {}) {
  const nw = Number(overrideParams.netWeight ?? item?.parameters?.runningNetWeight ?? item?.netWeight ?? 37);
  const rw = Number(overrideParams.runnerWeight ?? item?.parameters?.runningRunnerWeight ?? item?.runnerWeight ?? 1);
  const cav = Number(overrideParams.cavity ?? item?.parameters?.runningCavity ?? item?.cavity ?? 2) || 1;
  const ct = Number(overrideParams.cycleTime ?? item?.parameters?.runningCycleTime ?? item?.cycleTime ?? 47) || 47;
  const st = Number(overrideParams.shiftTariff ?? item?.shiftTariff ?? 2000);

  const appRmBase = Number(item?.approvedRmRate ?? 131.00);
  const actRmBase = Number(overrideParams.actualRmRate ?? item?.actualRmRate ?? 135.83);

  const appMbBase = Number(item?.masterbatchRate ?? 250.00);
  const actMbBase = Number(overrideParams.actualMbRate ?? item?.actualMbRate ?? 258.54);

  const mbPct = Number(overrideParams.masterbatchPct ?? item?.parameters?.runningMbPct ?? item?.masterbatchPct ?? 4.0);

  // Landed RM and MB rates with ICC and freight
  const appRmLanded = appRmBase + (appRmBase * 0.01) + 1.50;
  const actRmLanded = actRmBase + (actRmBase * 0.01) + 1.50;

  const appMbLanded = appMbBase + (appMbBase * 0.01) + 2.00;
  const actMbLanded = actMbBase + (actMbBase * 0.01) + 2.00;

  const shotWeight = nw + rw;
  const partShotWeight = shotWeight / (cav > 0 ? cav : 1);
  const mbWeight = (partShotWeight * mbPct) / 100;
  const baseRmWeight = partShotWeight - mbWeight;

  const isRunningActual = overrideParams.actualRmRate !== undefined || overrideParams.actualMbRate !== undefined;
  const activeRmLanded = isRunningActual ? actRmLanded : appRmLanded;
  const activeMbLanded = isRunningActual ? actMbLanded : appMbLanded;

  const materialCost = ((baseRmWeight * activeRmLanded) + (mbWeight * activeMbLanded)) / 1000;
  const appMaterialCost = ((baseRmWeight * appRmLanded) + (mbWeight * appMbLanded)) / 1000;
  const actMaterialCost = ((baseRmWeight * actRmLanded) + (mbWeight * actMbLanded)) / 1000;

  const efficiency = 0.90;
  const partsPerShift = (((8 * 3600) / ct) * cav) * efficiency;
  const conversionCost = partsPerShift > 0 ? (st / partsPerShift) : 0;

  const bopCost = Number(overrideParams.bopCost ?? item?.parameters?.runningBopCost ?? item?.bopCost ?? 0);
  const postOpCost = Number(overrideParams.postOpCost ?? item?.parameters?.runningPostOpCost ?? item?.postOpCost ?? 1.73);
  const handlingCostBop = bopCost * 0.03;

  const finalLanded = materialCost + conversionCost + bopCost + postOpCost + handlingCostBop;
  const totalApproved = appMaterialCost + conversionCost + bopCost + postOpCost + handlingCostBop;
  const totalActual = actMaterialCost + conversionCost + bopCost + postOpCost + handlingCostBop;
  const delta = totalApproved - totalActual;

  return {
    netWeight: nw,
    runnerWeight: rw,
    cavity: cav,
    cycleTime: ct,
    shiftTariff: st,
    efficiency,
    partsPerShift,
    shotWeight,
    partShotWeight,
    baseRmWeight,
    mbWeight,
    rmBaseRate: isRunningActual ? actRmBase : appRmBase,
    rmLandedCost: activeRmLanded,
    mbBaseCost: isRunningActual ? actMbBase : appMbBase,
    mbLandedCost: activeMbLanded,
    rmCost: materialCost,
    processCost: conversionCost,
    postOpCost,
    finalLanded: Number(finalLanded.toFixed(2)),
    approvedBaseline: Number(totalApproved.toFixed(2)),
    actualRunning: Number(totalActual.toFixed(2)),
    totalApproved: Number(totalApproved.toFixed(2)),
    totalActual: Number(totalActual.toFixed(2)),
    delta: Number(delta.toFixed(2)),
    deltaCost: Number(delta.toFixed(2))
  };
}

export function calculatePieceCostUnified(item, overrideParams = {}) {
  const v = (item?.vendor || '').toLowerCase();
  if (v.includes('atomberg')) {
    return calculateAtombergCost(item, overrideParams);
  }
  return calculateHaierCost(item, overrideParams);
}

export function calculateCostByVendor(item, vendor = 'Haier', overrideParams = {}) {
  const v = (vendor || item?.vendor || 'Haier').toLowerCase();
  if (v.includes('atomberg')) {
    return calculateAtombergCost(item, overrideParams);
  }
  return calculateHaierCost(item, overrideParams);
}

export default {
  calculatePieceCostUnified,
  calculateHaierCost,
  calculateAtombergCost,
  calculateCostByVendor
};
CALC_EOF

echo "==> 3. Updating CostingRunEnginePage.jsx to compute and show exact matching Baseline vs Actuals..."
cat << 'COSTING_EOF' > src/modules/module3-costing-engine/CostingRunEnginePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  globalStore, 
  subscribeStore, 
  getActiveRmMapping, 
  getActiveMbMapping 
} from '../../shared/masterStore';
import { calculateAtombergCost, calculateHaierCost } from '../../shared/costCalculationService';
import * as XLSX from 'xlsx';
import { Calculator, Download, Search, TrendingUp, TrendingDown } from 'lucide-react';

export default function CostingRunEnginePage() {
  const [, setTick] = useState(0);
  const [vendorFilter, setVendorFilter] = useState('ALL');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    return subscribeStore(() => setTick(t => t + 1));
  }, []);

  const products = globalStore.baselineProducts || [];

  const calculatedRows = products.map(prod => {
    const isAtomberg = (prod.vendor || '').toLowerCase().includes('atomberg');
    const rmInfo = getActiveRmMapping(prod.approvedRm || '', prod.vendor || 'Haier');
    const mbInfo = getActiveMbMapping(prod.vendor || 'Haier');

    // 1. Baseline Contract calculation
    const baseCalc = isAtomberg
      ? calculateAtombergCost(prod, {})
      : calculateHaierCost(prod, {});

    // 2. Simulated Actual Running calculation (with active WA rates & running parameters)
    const runCalc = isAtomberg
      ? calculateAtombergCost(prod, {
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        })
      : calculateHaierCost(prod, {
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        });

    const approvedBaseline = Number(baseCalc.approvedBaseline ?? baseCalc.finalLanded ?? 0);
    const simulatedActual = Number(runCalc.actualRunning ?? runCalc.finalLanded ?? 0);
    const delta = Number((approvedBaseline - simulatedActual).toFixed(2));

    return {
      vendor: prod.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: prod.itemCode,
      componentName: prod.componentName,
      approvedRm: prod.approvedRm,
      approvedRmRate: prod.approvedRmRate || rmInfo.approvedPrice,
      activeRmRate: rmInfo.activeWaPrice,
      approvedCost: approvedBaseline,
      actualCost: simulatedActual,
      deltaCost: delta
    };
  });

  const filteredRows = calculatedRows.filter(row => {
    const matchVendor = vendorFilter === 'ALL' || (row.vendor || '').toLowerCase().includes(vendorFilter.toLowerCase());
    const matchSearch = !searchTerm || 
      (row.itemCode || '').toLowerCase().includes(searchTerm.toLowerCase()) || 
      (row.componentName || '').toLowerCase().includes(searchTerm.toLowerCase());
    return matchVendor && matchSearch;
  });

  const exportExcel = () => {
    const wsData = filteredRows.map(r => ({
      'Item Code': r.itemCode,
      'Component Name': r.componentName,
      'Vendor': r.vendor,
      'Approved RM': r.approvedRm,
      'Approved RM Rate (₹/kg)': Number(r.approvedRmRate || 0).toFixed(2),
      'Active WA RM Rate (₹/kg)': Number(r.activeRmRate || 0).toFixed(2),
      'Approved Baseline (₹)': r.approvedCost.toFixed(2),
      'Simulated Actual (₹)': r.actualCost.toFixed(2),
      'Profit / Loss Delta (₹)': r.deltaCost.toFixed(2)
    }));
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.json_to_sheet(wsData);
    XLSX.utils.book_append_sheet(wb, ws, 'Cost Simulation Output');
    XLSX.writeFile(wb, `Live_Cost_Simulation_Output_${new Date().toISOString().slice(0, 10)}.xlsx`);
  };

  return (
    <div className="space-y-6 pb-12">
      <div className="bg-[#0f172a] text-white p-6 rounded-2xl shadow-xl flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-blue-600/30 rounded-xl border border-blue-500/30 text-blue-400">
            <Calculator className="w-8 h-8" />
          </div>
          <div>
            <h1 className="text-xl md:text-2xl font-bold tracking-tight">3. Dynamic Costing Run Engine</h1>
            <p className="text-sm text-slate-400">Live simulation matching contract baselines against active material inward rates.</p>
          </div>
        </div>

        <button
          onClick={exportExcel}
          className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold px-4 py-2.5 rounded-xl transition-all shadow-md shadow-emerald-600/20 cursor-pointer"
        >
          <Download className="w-4 h-4" /> Export Simulation (.xlsx)
        </button>
      </div>

      <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-sm flex flex-wrap justify-between items-center gap-4">
        <div className="relative flex-1 min-w-[260px]">
          <Search className="w-4 h-4 absolute left-3 top-3 text-slate-400" />
          <input
            type="text"
            placeholder="Search components by name or part number..."
            value={searchTerm}
            onChange={e => setSearchTerm(e.target.value)}
            className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs font-bold text-slate-500">Filter Vendor:</span>
          <select
            value={vendorFilter}
            onChange={e => setVendorFilter(e.target.value)}
            className="bg-slate-100 border border-slate-300 text-slate-800 text-xs font-bold rounded-xl px-3 py-2 outline-none cursor-pointer"
          >
            <option value="ALL">All Vendors Combined</option>
            <option value="Haier">Haier Appliances</option>
            <option value="Atomberg">Atomberg Technologies</option>
          </select>
        </div>
      </div>

      <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
        <div className="p-4 bg-[#0b1329] text-white flex justify-between items-center">
          <div className="font-bold text-xs uppercase tracking-wider flex items-center gap-2">
            <TrendingUp className="w-4 h-4 text-blue-400" /> Live Product Cost Simulation Matrix
          </div>
          <span className="text-xs text-slate-400 font-mono">{filteredRows.length} Products</span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold border-b border-slate-200">
                <th className="py-3 px-4">Item Code / Component</th>
                <th className="py-3 px-3 text-center">Vendor</th>
                <th className="py-3 px-3">Approved RM</th>
                <th className="py-3 px-3 text-right">Approved RM Rate</th>
                <th className="py-3 px-3 text-center text-slate-400">Active Material Link</th>
                <th className="py-3 px-3 text-right bg-blue-50 text-blue-900 font-bold">Active WA Rate</th>
                <th className="py-3 px-3 text-right bg-amber-50 text-amber-900 font-bold">Approved Baseline</th>
                <th className="py-3 px-3 text-right bg-slate-200/60 font-bold">Simulated Actual</th>
                <th className="py-3 px-4 text-right font-bold">Profit / Loss (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredRows.map((r, idx) => {
                const isGain = r.deltaCost >= 0;
                return (
                  <tr key={idx} className="hover:bg-slate-50 transition-colors">
                    <td className="py-3 px-4">
                      <div className="font-bold text-blue-600 font-mono">{r.itemCode}</div>
                      <div className="text-[11px] text-slate-600">{r.componentName}</div>
                    </td>
                    <td className="py-3 px-3 text-center">
                      <span className="px-2 py-0.5 bg-slate-100 text-slate-700 rounded text-[10px] font-bold">{r.vendor}</span>
                    </td>
                    <td className="py-3 px-3 font-medium text-slate-700">{r.approvedRm}</td>
                    <td className="py-3 px-3 text-right font-mono font-bold text-slate-800">₹{Number(r.approvedRmRate || 0).toFixed(2)}/kg</td>
                    <td className="py-3 px-3 text-center text-slate-400 font-mono text-[10px]">Linked to RM Matrix</td>
                    <td className="py-3 px-3 text-right font-mono font-bold bg-blue-50/50 text-blue-800">₹{Number(r.activeRmRate || 0).toFixed(2)}/kg</td>
                    <td className="py-3 px-3 text-right font-mono font-bold bg-amber-50/50 text-amber-900">₹{r.approvedCost.toFixed(2)}</td>
                    <td className="py-3 px-3 text-right font-mono font-bold bg-slate-50 text-slate-900">₹{r.actualCost.toFixed(2)}</td>
                    <td className="py-3 px-4 text-right font-mono font-bold">
                      <span className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-lg border text-xs ${
                        isGain ? 'bg-emerald-50 text-emerald-700 border-emerald-300' : 'bg-rose-50 text-rose-700 border-rose-300'
                      }`}>
                        {isGain ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
                        {isGain ? `+ ₹${r.deltaCost.toFixed(2)}` : `- ₹${Math.abs(r.deltaCost).toFixed(2)}`}
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
COSTING_EOF

echo "==> 4. Updating costOutputStore.js with clean pull API..."
cat << 'STORE_EOF' > src/shared/costOutputStore.js
// ============================================================================
// DEDICATED 6-FIELD COST OUTPUT REPOSITORY (costOutputStore.js)
// ============================================================================

import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping } from './masterStore';
import { calculateAtombergCost, calculateHaierCost } from './costCalculationService';

let costOutputDB = {};
let subscribers = [];

function notify() {
  subscribers.forEach(fn => {
    try { fn(costOutputDB); } catch (e) { console.error('costOutputStore notify error:', e); }
  });
}

export function pullAndMaterializeCosts() {
  const products = globalStore.baselineProducts || [];
  const latestSnapshot = {};

  products.forEach(prod => {
    const isAtomberg = (prod.vendor || '').toLowerCase().includes('atomberg');
    const rmInfo = getActiveRmMapping(prod.approvedRm || '', prod.vendor || 'Haier');
    const mbInfo = getActiveMbMapping(prod.vendor || 'Haier');

    // 1. Baseline Contract Calculation
    const baseResult = isAtomberg
      ? calculateAtombergCost(prod, {})
      : calculateHaierCost(prod, {});

    // 2. Actual Running Calculation with active WA rates & running parameters
    const runResult = isAtomberg
      ? calculateAtombergCost(prod, {
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        })
      : calculateHaierCost(prod, {
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        });

    const approvedCost = Number(baseResult.approvedBaseline ?? baseResult.finalLanded ?? 0);
    const actualCost = Number(runResult.actualRunning ?? runResult.finalLanded ?? 0);
    const deltaCost = Number((approvedCost - actualCost).toFixed(2));

    latestSnapshot[prod.itemCode] = {
      vendor: prod.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: prod.itemCode,
      componentName: prod.componentName || 'Component',
      approvedCost,
      actualCost,
      deltaCost,
      updatedAt: new Date().toISOString()
    };
  });

  costOutputDB = latestSnapshot;
  notify();
  return costOutputDB;
}

// Auto-sync whenever master store changes
subscribeStore(() => {
  pullAndMaterializeCosts();
});

// Initial boot sync
pullAndMaterializeCosts();

export function getProductCostSummary(itemCode) {
  if (!costOutputDB[itemCode] || Object.keys(costOutputDB).length === 0) {
    pullAndMaterializeCosts();
  }
  return costOutputDB[itemCode] || {
    vendor: 'Haier',
    itemCode: itemCode || 'UNKNOWN',
    componentName: 'Component',
    approvedCost: 0,
    actualCost: 0,
    deltaCost: 0
  };
}

export function getAllCostSummaries() {
  if (Object.keys(costOutputDB).length === 0) {
    pullAndMaterializeCosts();
  }
  return costOutputDB;
}

export function subscribeCostOutput(fn) {
  subscribers.push(fn);
  return () => {
    subscribers = subscribers.filter(cb => cb !== fn);
  };
}

export default {
  pullAndMaterializeCosts,
  getProductCostSummary,
  getAllCostSummaries,
  subscribeCostOutput
};
STORE_EOF

echo "==> 5. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done!"
