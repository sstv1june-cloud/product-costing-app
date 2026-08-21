#!/usr/bin/env bash
set -e

echo "==> 1. Restoring CostingRunEnginePage.jsx directly from checkpoint-dev2-20260821_064903..."
git checkout checkpoint-dev2-20260821_064903 -- src/modules/module3-costing-engine/CostingRunEnginePage.jsx

echo "==> 2. Updating costOutputStore.js to pull ONLY the 6 core summary fields from costCalculationService.js..."
cat << 'STORE_EOF' > src/shared/costOutputStore.js
// ============================================================================
// DEDICATED COST OUTPUT REPOSITORY (costOutputStore.js)
// Pulls ONLY 6 summary fields per product from costCalculationService.js:
// 1. vendor
// 2. itemCode
// 3. componentName
// 4. approvedCost (Contract Baseline)
// 5. actualCost (Simulated Running Cost)
// 6. deltaCost (Variance Gain / Loss)
// + Period history for MIS reports
// (No shopfloor parameters, no 38/50-line breakdown details)
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
 * Pull and extract ONLY the 6 summary data points for each product
 */
export function pullAndMaterializeCosts(period = '2026-08') {
  const products = globalStore.baselineProducts || [];
  const latestSnapshot = {};

  products.forEach(prod => {
    const isAtomberg = (prod.vendor || '').toLowerCase().includes('atomberg');
    const rmInfo = getActiveRmMapping(prod.approvedRm || '', prod.vendor || 'Haier');
    const mbInfo = getActiveMbMapping(prod.vendor || 'Haier');

    // 1. Calculate Approved Baseline
    const baseResult = isAtomberg
      ? calculateAtombergCost(prod, {})
      : calculateHaierCost(prod, {});

    // 2. Calculate Actual Running Cost
    const runResult = isAtomberg
      ? calculateAtombergCost(prod, {
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        })
      : calculateHaierCost(prod, {
          actualRmRate: rmInfo.activeWaPrice,
          actualMbRate: mbInfo.activeMbWaPrice
        });

    const approvedCost = Number(Number(baseResult.approvedBaseline ?? baseResult.finalLanded ?? baseResult.totalApproved ?? 0).toFixed(2));
    const actualCost = Number(Number(runResult.actualRunning ?? runResult.finalLanded ?? runResult.totalActual ?? 0).toFixed(2));
    const deltaCost = Number((approvedCost - actualCost).toFixed(2));

    // Save ONLY the 6 core summary fields
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

// Auto-sync when masterStore changes (RM prices, baseline specs, add/delete)
subscribeStore(() => {
  pullAndMaterializeCosts();
});

// Initial boot pull
pullAndMaterializeCosts();

// Pre-fill previous months with baseline records for multi-month trend analysis
['2026-05', '2026-06', '2026-07'].forEach(m => {
  pullAndMaterializeCosts(m);
});

// ============================================================================
// READ-ONLY REPOSITORY API FOR MIS TABLES & EXCEL EXPORTS
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

echo "==> 3. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Hard-refresh your browser now."
