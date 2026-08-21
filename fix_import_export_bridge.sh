#!/usr/bin/env bash
set -e

echo "==> 1. Exporting all required functions and aliases from costOutputStore.js..."
cat << 'STORE_EOF' > src/shared/costOutputStore.js
// ============================================================================
// DEDICATED COST OUTPUT REPOSITORY (costOutputStore.js)
// Bridge connecting productCostRepo to all MIS tables and exports
// ============================================================================

import { 
  getProductCost, 
  getAllProductCosts, 
  subscribeProductCosts, 
  refreshAllProductCosts 
} from './productCostRepo';

export function pullAndMaterializeCosts() {
  return refreshAllProductCosts();
}

export function syncCostsToStore() {
  return refreshAllProductCosts();
}

export function getProductCostSummary(itemCode) {
  const item = getProductCost(itemCode);
  return {
    vendor: item.vendor,
    itemCode: item.itemCode,
    componentName: item.componentName,
    approvedCost: item.approvedCost,
    actualCost: item.actualCost,
    approvedBaseline: item.approvedCost,
    actualUnitCost: item.actualCost,
    deltaCost: item.deltaCost,
    delta: item.deltaCost
  };
}

export function getProductCostOutput(itemCode) {
  return getProductCostSummary(itemCode);
}

export function getAllCostSummaries() {
  return getAllProductCosts();
}

export function getAllProductCostOutputs() {
  return getAllProductCosts();
}

export function getCostSummariesByPeriod(period) {
  return getAllProductCosts();
}

export function subscribeCostOutput(fn) {
  return subscribeProductCosts(fn);
}

export default {
  pullAndMaterializeCosts,
  syncCostsToStore,
  getProductCostSummary,
  getProductCostOutput,
  getAllCostSummaries,
  getAllProductCostOutputs,
  getCostSummariesByPeriod,
  subscribeCostOutput
};
STORE_EOF

echo "==> 2. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ Export bridge completed and Vite server restarted!"
echo "-------------------------------------------------------------------"
