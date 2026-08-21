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
