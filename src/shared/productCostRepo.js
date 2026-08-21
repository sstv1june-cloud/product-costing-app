// ============================================================================
// LIVE PRODUCT COST REPOSITORY
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
    const netWt = params.runningNetWeight ?? item.netWeight ?? (isAtomberg ? 37 : 197);
    const runnerWt = params.runningRunnerWeight ?? item.runnerWeight ?? (isAtomberg ? 1 : 40);
    const mbPctVal = params.runningMbPct !== undefined ? params.runningMbPct : (item.masterbatchPct ?? (isAtomberg ? 4.0 : 0.0));
    const bopCost = params.runningBopCost ?? item.bopCost ?? (isAtomberg ? 0.0 : 0.14);
    const packingCost = params.runningPackingCost ?? item.packingCost ?? (isAtomberg ? 0.86 : 0.0);
    const transportCost = params.runningTransportCost ?? item.transportCost ?? (isAtomberg ? 0.62 : 0.0);
    const cycleTime = params.runningCycleTime ?? item.cycleTimeApproved ?? item.cycleTime ?? (isAtomberg ? 47 : 56);
    const cavity = params.runningCavity ?? item.cavity ?? 2;
    const tonnage = params.runningTonnage ?? item.machineTonnage ?? (isAtomberg ? 200 : 450);
    const costingTariff = item.shiftTariff ?? (isAtomberg ? 2000 : 4600);
    const actualTariff = params.runningShiftTariff ?? item.shiftTariff ?? (isAtomberg ? 2000 : 4600);

    let approvedBaseline = 0;
    let simulatedActual = 0;

    if (isAtomberg) {
      const approvedRmBase = Number(rmInfo.approvedPrice || item.approvedRmRate || 131.00);
      const approvedMbBase = Number(mbInfo.approvedMbPrice || item.masterbatchRate || 254.00);
      const actualRmBase = Number(rmInfo.activeWaPrice || 135.83);
      const actualMbBase = Number(mbInfo.activeMbPrice || 258.54);

      const baseCalc = calculateAtombergCost({
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
        shiftTariff: Number(costingTariff),
        postOpCost: 1.73,
        packingCost: Number(item.packingCost || 0.86),
        transportCost: Number(item.transportCost || 0.62)
      });

      const runCalc = calculateAtombergCost({
        vendor: 'Atomberg',
        rmBase: actualRmBase,
        mbBase: actualMbBase,
        partWt: Number(netWt),
        runnerWt: Number(runnerWt),
        mbPct: Number(mbPctVal) / 100,
        bopCost: Number(bopCost),
        cycleTime: Number(cycleTime),
        cavity: Number(cavity),
        tonnage: Number(tonnage),
        shiftTariff: Number(actualTariff),
        postOpCost: 1.73,
        packingCost: Number(packingCost),
        transportCost: Number(transportCost)
      });

      approvedBaseline = Number(baseCalc.finalLanded || 0);
      simulatedActual = Number(runCalc.finalLanded || 0);
    } else {
      const dynamicHaierApprovedRm = Number(rmInfo.approvedPrice || item.approvedRmRate || 136.20);
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
        shiftTariff: Number(costingTariff),
        cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 56),
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
        shiftTariff: Number(actualTariff),
        cycleTime: Number(cycleTime),
        bopCost: Number(bopCost)
      });

      approvedBaseline = Number(baseCalc.totalCost || 0);
      simulatedActual = Number(runCalc.totalCost || 0);
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
