#!/usr/bin/env bash
set -e

echo "==> 1. Updating productCostRepo.js to match InlineEditModal parameters precisely..."
cat << 'REPO_EOF' > src/shared/productCostRepo.js
// ============================================================================
// DEDICATED LIVE PRODUCT COST REPOSITORY (productCostRepo.js)
// Exact parameter matching with InlineEditModal.jsx
// ============================================================================

import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping } from './masterStore';
import { calculateAtombergCost, calculateHaierCost } from './costCalculationService';

let productCostDB = {};
let listeners = [];

function notify() {
  listeners.forEach(fn => {
    try { fn(productCostDB); } catch (e) { console.error('productCostRepo notify error:', e); }
  });
}

export function refreshAllProductCosts() {
  const products = globalStore.baselineProducts || [];
  const nextDB = {};

  products.forEach(item => {
    const isAtomberg = (item.vendor || '').toLowerCase().includes('atomberg');
    const rmInfo = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');
    const mbInfo = getActiveMbMapping(item.vendor, '2026-08-01');

    const params = item.parameters || {};
    const netWt = params.runningNetWeight ?? item.netWeight ?? 197;
    const runnerWt = params.runningRunnerWeight ?? item.runnerWeight ?? 40;
    const mbPctVal = params.runningMbPct !== undefined ? params.runningMbPct : (item.masterbatchPct ?? 0.0);
    const bopCost = params.runningBopCost ?? item.bopCost ?? 0.14;
    const cycleTime = params.runningCycleTime ?? item.cycleTimeApproved ?? item.cycleTime ?? 48;
    const cavity = params.runningCavity ?? item.cavity ?? 2;
    const tonnage = params.runningTonnage ?? item.machineTonnage ?? 450;

    let approvedBaseline = 0;
    let simulatedActual = 0;

    if (isAtomberg) {
      // ---------- EXACT ATOMBERG CALCULATION FROM InlineEditModal ----------
      const approvedRmBase = Number(rmInfo.approvedPrice || 140.00);
      const approvedMbBase = Number(mbInfo.approvedMbPrice || 254.00);
      const actualRmBase = Number(rmInfo.activeWaPrice || 135.83);
      const actualMbBase = Number(mbInfo.activeMbPrice || 258.54);

      const baseP = {
        vendor: 'Atomberg',
        rmBase: approvedRmBase,
        mbBase: approvedMbBase,
        partWt: Number(item.netWeight || 37),
        runnerWt: Number(item.runnerWeight || 1),
        mbPct: Number(item.masterbatchPct || 4.0) / 100,
        bopCost: Number(item.bopCost || 0),
        cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 47),
        cavity: Number(item.cavity || 2),
        tonnage: Number(item.machineTonnage || 200),
        postOpCost: 1.73,
        packingCost: 0.86,
        transportCost: 0.62
      };
      const baseCalc = calculateAtombergCost(baseP);

      const runningP = {
        ...baseP,
        rmBase: actualRmBase,
        mbBase: actualMbBase,
        partWt: Number(netWt),
        runnerWt: Number(runnerWt),
        mbPct: Number(mbPctVal) / 100,
        bopCost: Number(bopCost),
        cycleTime: Number(cycleTime),
        cavity: Number(cavity),
        tonnage: Number(tonnage)
      };
      const runCalc = calculateAtombergCost(runningP);

      approvedBaseline = Number(baseCalc.finalLanded || 0);
      simulatedActual = Number(runCalc.finalLanded || 0);
    } else {
      // ---------- EXACT HAIER CALCULATION FROM InlineEditModal ----------
      const dynamicHaierApprovedRm = Number(rmInfo.approvedPrice || item.approvedRmRate || 130.00);
      const dynamicHaierActualRm = Number(rmInfo.activeWaPrice || 134.80);
      const dynamicHaierApprovedMb = Number(mbInfo.approvedMbPrice || item.masterbatchRate || 0.0);

      const baseCalc = calculateHaierCost({
        cavity: Number(item.cavity || 2),
        netWeight: Number(item.netWeight || 197),
        runnerWeight: Number(item.runnerWeight || 40),
        rmRate: dynamicHaierApprovedRm,
        masterbatchPct: Number(item.masterbatchPct || 0.0),
        masterbatchRate: dynamicHaierApprovedMb,
        machineTonnage: Number(item.machineTonnage || 450),
        shiftTariff: Number((item.machineTonnage || 450) >= 650 ? 5760 : 4600),
        cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 48),
        bopCost: Number(item.bopCost || 0.14)
      });

      const runCalc = calculateHaierCost({
        cavity: Number(cavity),
        netWeight: Number(netWt),
        runnerWeight: Number(runnerWt),
        rmRate: dynamicHaierActualRm,
        masterbatchPct: Number(mbPctVal),
        masterbatchRate: dynamicHaierApprovedMb,
        machineTonnage: Number(tonnage),
        shiftTariff: Number(tonnage >= 650 ? 5760 : 4600),
        cycleTime: Number(cycleTime),
        bopCost: Number(bopCost)
      });

      approvedBaseline = Number(baseCalc.totalCost ?? baseCalc.finalLanded ?? 0);
      simulatedActual = Number(runCalc.totalCost ?? runCalc.finalLanded ?? 0);
    }

    const appFinal = Number(approvedBaseline.toFixed(2));
    const actFinal = Number(simulatedActual.toFixed(2));
    const delta = Number((appFinal - actFinal).toFixed(2));

    nextDB[item.itemCode] = {
      vendor: item.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: item.itemCode,
      componentName: item.componentName || 'Component',
      approvedRm: item.approvedRm || '',
      approvedRmRate: Number(rmInfo.approvedPrice || item.approvedRmRate || 0),
      activeRmRate: Number(rmInfo.activeWaPrice || 0),
      approvedCost: appFinal,
      actualCost: actFinal,
      approvedBaseline: appFinal,
      simulatedActual: actFinal,
      deltaCost: delta,
      delta: delta,
      updatedAt: new Date().toISOString()
    };
  });

  productCostDB = nextDB;
  notify();
  return productCostDB;
}

subscribeStore(() => {
  refreshAllProductCosts();
});

refreshAllProductCosts();

export function getProductCost(itemCode) {
  if (!productCostDB[itemCode] || Object.keys(productCostDB).length === 0) {
    refreshAllProductCosts();
  }
  return productCostDB[itemCode] || {
    vendor: 'Haier',
    itemCode: itemCode || 'UNKNOWN',
    componentName: 'Component',
    approvedRm: '',
    approvedRmRate: 0,
    activeRmRate: 0,
    approvedCost: 0,
    actualCost: 0,
    approvedBaseline: 0,
    simulatedActual: 0,
    deltaCost: 0,
    delta: 0
  };
}

export function getAllProductCosts() {
  if (Object.keys(productCostDB).length === 0) {
    refreshAllProductCosts();
  }
  return productCostDB;
}

export function subscribeProductCosts(fn) {
  listeners.push(fn);
  return () => {
    listeners = listeners.filter(cb => cb !== fn);
  };
}

export default {
  refreshAllProductCosts,
  getProductCost,
  getAllProductCosts,
  subscribeProductCosts
};
REPO_EOF

echo "==> 2. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done!"
