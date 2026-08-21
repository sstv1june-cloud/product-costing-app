#!/usr/bin/env bash
set -e

echo "==> Updating src/shared/costOutputStore.js with full exports including getCostSummariesByPeriod..."
cat << 'STORE_EOF' > src/shared/costOutputStore.js
// ============================================================================
// DEDICATED ONE-WAY COST OUTPUT REPOSITORY (costOutputStore.js)
// Pulls ONLY 6 core summary data points per product from costCalculationService:
// 1. vendor
// 2. itemCode
// 3. componentName
// 4. approvedCost (Approved Baseline Contract Rate)
// 5. actualCost (Simulated Running Rate)
// 6. deltaCost (Variance Gain / Loss)
// + Period snapshots for MIS Multi-Month & Period Comparisons
// ============================================================================

import { globalStore, subscribeStore, getActiveRmMapping, getActiveMbMapping } from './masterStore';
import { calculateAtombergCost, calculateHaierCost } from './costCalculationService';

let costOutputDB = {};
let historyMap = {};
let subscribers = [];

function notify() {
  subscribers.forEach(fn => {
    try { fn(costOutputDB); } catch (e) { console.error('costOutputStore notify error:', e); }
  });
}

/**
 * Extracts only the 6 core summary fields from calculation service
 */
export function pullAndMaterializeCosts(period = '2026-08') {
  const products = globalStore.baselineProducts || [];
  const latestSnapshot = {};

  products.forEach(prod => {
    const isAtomberg = (prod.vendor || '').toLowerCase().includes('atomberg');
    const rmInfo = getActiveRmMapping(prod.approvedRm || '', prod.vendor || 'Haier');
    const mbInfo = getActiveMbMapping(prod.vendor || 'Haier');

    // 1. Baseline contract calculation
    const baseResult = isAtomberg
      ? calculateAtombergCost(prod, {})
      : calculateHaierCost(prod, {});

    // 2. Actual running calculation (with active WA rates & running parameters)
    const runResult = isAtomberg
      ? calculateAtombergCost(prod, {
          netWeight: prod.parameters?.runningNetWeight ?? prod.netWeight,
          runnerWeight: prod.parameters?.runningRunnerWeight ?? prod.runnerWeight,
          cavity: prod.parameters?.runningCavity ?? prod.cavity,
          cycleTime: prod.parameters?.runningCycleTime ?? prod.cycleTime,
          masterbatchPct: prod.parameters?.runningMbPct ?? prod.masterbatchPct,
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        })
      : calculateHaierCost(prod, {
          netWeight: prod.parameters?.runningNetWeight ?? prod.netWeight,
          runnerWeight: prod.parameters?.runningRunnerWeight ?? prod.runnerWeight,
          cavity: prod.parameters?.runningCavity ?? prod.cavity,
          cycleTime: prod.parameters?.runningCycleTime ?? prod.cycleTime,
          masterbatchPct: prod.parameters?.runningMbPct ?? prod.masterbatchPct,
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        });

    const approvedCost = Number(Number(baseResult.approvedBaseline ?? baseResult.finalLanded ?? baseResult.totalApproved ?? 0).toFixed(2));
    const actualCost = Number(Number(runResult.actualRunning ?? runResult.finalLanded ?? runResult.totalActual ?? 0).toFixed(2));
    const deltaCost = Number((approvedCost - actualCost).toFixed(2));

    // Storing ONLY the 6 flat fields
    const record = {
      vendor: prod.vendor || (isAtomberg ? 'Atomberg' : 'Haier'),
      itemCode: prod.itemCode,
      componentName: prod.componentName || 'Component',
      approvedCost,
      actualCost,
      deltaCost,
      period,
      updatedAt: new Date().toISOString()
    };

    latestSnapshot[prod.itemCode] = record;
    historyMap[`${prod.itemCode}_${period}`] = record;
  });

  costOutputDB = latestSnapshot;
  notify();
  return costOutputDB;
}

// Auto-sync when master store changes (RM price edits, baseline changes, additions)
subscribeStore(() => {
  pullAndMaterializeCosts();
});

// Initial boot sync
pullAndMaterializeCosts();

// Pre-fill history snapshots for multi-month trend analysis
['2026-05', '2026-06', '2026-07'].forEach(m => {
  pullAndMaterializeCosts(m);
});

// ============================================================================
// READ-ONLY REPOSITORY API EXPORTS FOR MIS TABLES & EXPORTS
// ============================================================================

export function getProductCostSummary(itemCode, period = '2026-08') {
  const historyKey = `${itemCode}_${period}`;
  if (historyMap[historyKey]) {
    return historyMap[historyKey];
  }
  if (!costOutputDB[itemCode]) {
    pullAndMaterializeCosts(period);
  }
  return costOutputDB[itemCode] || {
    vendor: 'Haier',
    itemCode: itemCode || 'UNKNOWN',
    componentName: 'Component',
    approvedCost: 0,
    actualCost: 0,
    deltaCost: 0,
    period
  };
}

export function getAllCostSummaries() {
  if (Object.keys(costOutputDB).length === 0) {
    pullAndMaterializeCosts();
  }
  return costOutputDB;
}

export function getCostSummariesByPeriod(period) {
  const result = {};
  Object.keys(historyMap).forEach(key => {
    if (key.endsWith(`_${period}`)) {
      const code = key.split(`_${period}`)[0];
      result[code] = historyMap[key];
    }
  });
  return Object.keys(result).length > 0 ? result : costOutputDB;
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
  getCostSummariesByPeriod,
  subscribeCostOutput
};
STORE_EOF

echo "==> Restarting Vite dev server on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Fixed! Hard refresh your browser now."
