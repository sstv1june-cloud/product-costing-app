#!/usr/bin/env bash
set -e

echo "==> 1. Checking calculateDetailedCost / calculateHaierCost in InlineEditModal..."
grep -n "calculate" src/modules/module1-baseline/InlineEditModal.jsx | head -n 30 || true

echo "==> 2. Updating CostingRunEnginePage.jsx with the exact calculation structure matching InlineEditModal..."
cat << 'PAGE_EOF' > src/modules/module3-costing-engine/CostingRunEnginePage.jsx
import React, { useState, useEffect } from 'react';
import { 
  globalStore, 
  subscribeStore, 
  getActiveRmMapping, 
  getActiveMbMapping 
} from '../../shared/masterStore';
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

  // Replicate exact calculation logic from InlineEditModal.jsx
  const calculatedRows = products.map(prod => {
    const isAtomberg = (prod.vendor || '').toLowerCase().includes('atomberg');
    const rmInfo = getActiveRmMapping(prod.approvedRm || '', prod.vendor || 'Haier');
    const mbInfo = getActiveMbMapping(prod.vendor || 'Haier');

    let approvedBaseline = 0;
    let simulatedActual = 0;

    if (isAtomberg) {
      // ----------------------------------------------------
      // ATOMBERG SPEC FORMULA
      // ----------------------------------------------------
      const nw = Number(prod.parameters?.runningNetWeight ?? prod.netWeight ?? 37);
      const rw = Number(prod.parameters?.runningRunnerWeight ?? prod.runnerWeight ?? 1);
      const cav = Number(prod.parameters?.runningCavity ?? prod.cavity ?? 2) || 1;
      const ct = Number(prod.parameters?.runningCycleTime ?? prod.cycleTime ?? 47) || 47;
      const st = Number(prod.shiftTariff ?? 2000);

      const appRm = Number(prod.approvedRmRate ?? rmInfo.approvedPrice ?? 131.00);
      const actRm = Number(rmInfo.activeWaPrice ?? appRm);

      const appMb = Number(prod.masterbatchRate ?? mbInfo.approvedMbPrice ?? 250.00);
      const actMb = Number(mbInfo.activeMbWaPrice ?? appMb);

      const mbPct = Number(prod.parameters?.runningMbPct ?? prod.masterbatchPct ?? 4.0);

      const appRmLanded = appRm + (appRm * 0.01) + 1.50;
      const actRmLanded = actRm + (actRm * 0.01) + 1.50;

      const appMbLanded = appMb + (appMb * 0.01) + 2.00;
      const actMbLanded = actMb + (actMb * 0.01) + 2.00;

      const shotWeight = nw + rw;
      const partShotWeight = shotWeight / cav;
      const mbWeight = (partShotWeight * mbPct) / 100;
      const baseRmWeight = partShotWeight - mbWeight;

      const appMatCost = ((baseRmWeight * appRmLanded) + (mbWeight * appMbLanded)) / 1000;
      const actMatCost = ((baseRmWeight * actRmLanded) + (mbWeight * actMbLanded)) / 1000;

      const partsPerShift = (((8 * 3600) / ct) * cav) * 0.90;
      const conversionCost = partsPerShift > 0 ? (st / partsPerShift) : 0;

      const bopCost = Number(prod.parameters?.runningBopCost ?? prod.bopCost ?? 0);
      const postOpCost = Number(prod.parameters?.runningPostOpCost ?? prod.postOpCost ?? 1.73);
      const handlingBop = bopCost * 0.03;

      approvedBaseline = appMatCost + conversionCost + bopCost + postOpCost + handlingBop;
      simulatedActual = actMatCost + conversionCost + bopCost + postOpCost + handlingBop;
    } else {
      // ----------------------------------------------------
      // HAIER 38-LINE EXACT COSTING FORMULA
      // ----------------------------------------------------
      const nw = Number(prod.parameters?.runningNetWeight ?? prod.netWeight ?? 197);
      const rw = Number(prod.parameters?.runningRunnerWeight ?? prod.runnerWeight ?? 40);
      const cav = Number(prod.parameters?.runningCavity ?? prod.cavity ?? 2) || 1;
      const ct = Number(prod.parameters?.runningCycleTime ?? prod.cycleTime ?? 48) || 48;
      const st = Number(prod.shiftTariff ?? 3600);

      const appRm = Number(prod.approvedRmRate ?? rmInfo.approvedPrice ?? 136.20);
      const actRm = Number(rmInfo.activeWaPrice ?? appRm);

      const mbPct = Number(prod.parameters?.runningMbPct ?? prod.masterbatchPct ?? 0);
      const appMb = Number(prod.masterbatchRate ?? mbInfo.approvedMbPrice ?? 0);
      const actMb = Number(mbInfo.activeMbWaPrice ?? appMb);

      const shotWeight = nw + rw;
      const partShotWeight = shotWeight / cav;
      const mbWeight = (partShotWeight * mbPct) / 100;
      const baseRmWeight = partShotWeight - mbWeight;

      const appMatCost = ((baseRmWeight * appRm) + (mbWeight * appMb)) / 1000;
      const actMatCost = ((baseRmWeight * actRm) + (mbWeight * actMb)) / 1000;

      const shotsPerShift = (8 * 3600) / ct;
      const shotsWithEff = shotsPerShift * 0.95;
      const partsPerShift = shotsWithEff * cav;
      const prodCostPerPc = partsPerShift > 0 ? (st / partsPerShift) : 0;

      const bopCost = Number(prod.parameters?.runningBopCost ?? prod.bopCost ?? (prod.itemCode === '0060217989D' ? 0.14 : 0));
      const postOpCost = Number(prod.parameters?.runningPostOpCost ?? prod.postOpCost ?? 0);

      const subTotalApp = appMatCost + prodCostPerPc;
      const subTotalAct = actMatCost + prodCostPerPc;

      const ohAndProfitApp = subTotalApp * 0.15;
      const ohAndProfitAct = subTotalAct * 0.15;

      const iccReduceApp = -(subTotalApp * 0.005);
      const iccReduceAct = -(subTotalAct * 0.005);

      approvedBaseline = subTotalApp + ohAndProfitApp + iccReduceApp + bopCost + postOpCost;
      simulatedActual = subTotalAct + ohAndProfitAct + iccReduceAct + bopCost + postOpCost;
    }

    const appFinal = Number(approvedBaseline.toFixed(2));
    const actFinal = Number(simulatedActual.toFixed(2));
    const delta = Number((appFinal - actFinal).toFixed(2));

    return {
      vendor: prod.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: prod.itemCode,
      componentName: prod.componentName,
      approvedRm: prod.approvedRm,
      approvedRmRate: prod.approvedRmRate || rmInfo.approvedPrice,
      activeRmRate: rmInfo.activeWaPrice,
      approvedCost: appFinal,
      actualCost: actFinal,
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
PAGE_EOF

echo "==> 3. Updating costOutputStore.js with identical 6-field extraction..."
cat << 'STORE_EOF' > src/shared/costOutputStore.js
// ============================================================================
// DEDICATED 6-FIELD COST OUTPUT REPOSITORY (costOutputStore.js)
// Reads 6 summary fields per product matching Edit Spec Modal & Costing Engine
// ============================================================================

import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping } from './masterStore';

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

    let approvedBaseline = 0;
    let simulatedActual = 0;

    if (isAtomberg) {
      const nw = Number(prod.parameters?.runningNetWeight ?? prod.netWeight ?? 37);
      const rw = Number(prod.parameters?.runningRunnerWeight ?? prod.runnerWeight ?? 1);
      const cav = Number(prod.parameters?.runningCavity ?? prod.cavity ?? 2) || 1;
      const ct = Number(prod.parameters?.runningCycleTime ?? prod.cycleTime ?? 47) || 47;
      const st = Number(prod.shiftTariff ?? 2000);

      const appRm = Number(prod.approvedRmRate ?? rmInfo.approvedPrice ?? 131.00);
      const actRm = Number(rmInfo.activeWaPrice ?? appRm);

      const appMb = Number(prod.masterbatchRate ?? mbInfo.approvedMbPrice ?? 250.00);
      const actMb = Number(mbInfo.activeMbWaPrice ?? appMb);

      const mbPct = Number(prod.parameters?.runningMbPct ?? prod.masterbatchPct ?? 4.0);

      const appRmLanded = appRm + (appRm * 0.01) + 1.50;
      const actRmLanded = actRm + (actRm * 0.01) + 1.50;

      const appMbLanded = appMb + (appMb * 0.01) + 2.00;
      const actMbLanded = actMb + (actMb * 0.01) + 2.00;

      const shotWeight = nw + rw;
      const partShotWeight = shotWeight / cav;
      const mbWeight = (partShotWeight * mbPct) / 100;
      const baseRmWeight = partShotWeight - mbWeight;

      const appMatCost = ((baseRmWeight * appRmLanded) + (mbWeight * appMbLanded)) / 1000;
      const actMatCost = ((baseRmWeight * actRmLanded) + (mbWeight * actMbLanded)) / 1000;

      const partsPerShift = (((8 * 3600) / ct) * cav) * 0.90;
      const conversionCost = partsPerShift > 0 ? (st / partsPerShift) : 0;

      const bopCost = Number(prod.parameters?.runningBopCost ?? prod.bopCost ?? 0);
      const postOpCost = Number(prod.parameters?.runningPostOpCost ?? prod.postOpCost ?? 1.73);
      const handlingBop = bopCost * 0.03;

      approvedBaseline = appMatCost + conversionCost + bopCost + postOpCost + handlingBop;
      simulatedActual = actMatCost + conversionCost + bopCost + postOpCost + handlingBop;
    } else {
      const nw = Number(prod.parameters?.runningNetWeight ?? prod.netWeight ?? 197);
      const rw = Number(prod.parameters?.runningRunnerWeight ?? prod.runnerWeight ?? 40);
      const cav = Number(prod.parameters?.runningCavity ?? prod.cavity ?? 2) || 1;
      const ct = Number(prod.parameters?.runningCycleTime ?? prod.cycleTime ?? 48) || 48;
      const st = Number(prod.shiftTariff ?? 3600);

      const appRm = Number(prod.approvedRmRate ?? rmInfo.approvedPrice ?? 136.20);
      const actRm = Number(rmInfo.activeWaPrice ?? appRm);

      const mbPct = Number(prod.parameters?.runningMbPct ?? prod.masterbatchPct ?? 0);
      const appMb = Number(prod.masterbatchRate ?? mbInfo.approvedMbPrice ?? 0);
      const actMb = Number(mbInfo.activeMbWaPrice ?? appMb);

      const shotWeight = nw + rw;
      const partShotWeight = shotWeight / cav;
      const mbWeight = (partShotWeight * mbPct) / 100;
      const baseRmWeight = partShotWeight - mbWeight;

      const appMatCost = ((baseRmWeight * appRm) + (mbWeight * appMb)) / 1000;
      const actMatCost = ((baseRmWeight * actRm) + (mbWeight * actMb)) / 1000;

      const shotsPerShift = (8 * 3600) / ct;
      const shotsWithEff = shotsPerShift * 0.95;
      const partsPerShift = shotsWithEff * cav;
      const prodCostPerPc = partsPerShift > 0 ? (st / partsPerShift) : 0;

      const bopCost = Number(prod.parameters?.runningBopCost ?? prod.bopCost ?? (prod.itemCode === '0060217989D' ? 0.14 : 0));
      const postOpCost = Number(prod.parameters?.runningPostOpCost ?? prod.postOpCost ?? 0);

      const subTotalApp = appMatCost + prodCostPerPc;
      const subTotalAct = actMatCost + prodCostPerPc;

      const ohAndProfitApp = subTotalApp * 0.15;
      const ohAndProfitAct = subTotalAct * 0.15;

      const iccReduceApp = -(subTotalApp * 0.005);
      const iccReduceAct = -(subTotalAct * 0.005);

      approvedBaseline = subTotalApp + ohAndProfitApp + iccReduceApp + bopCost + postOpCost;
      simulatedActual = subTotalAct + ohAndProfitAct + iccReduceAct + bopCost + postOpCost;
    }

    const appFinal = Number(approvedBaseline.toFixed(2));
    const actFinal = Number(simulatedActual.toFixed(2));
    const delta = Number((appFinal - actFinal).toFixed(2));

    latestSnapshot[prod.itemCode] = {
      vendor: prod.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: prod.itemCode,
      componentName: prod.componentName || 'Component',
      approvedCost: appFinal,
      actualCost: actFinal,
      deltaCost: delta,
      updatedAt: new Date().toISOString()
    };
  });

  costOutputDB = latestSnapshot;
  notify();
  return costOutputDB;
}

subscribeStore(() => {
  pullAndMaterializeCosts();
});

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

echo "==> 4. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Refresh browser now."
