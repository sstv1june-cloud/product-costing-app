// ============================================================================
// UNIVERSAL COST CALCULATION SERVICE (Exact Excel Formula & Manual Tariff)
// ============================================================================

export function calculateHaierCost(p = {}) {
  const cav = Math.max(1, Number(p.cavity ?? 2));
  const nw = Number(p.netWeight ?? 197);
  const rw = Number(p.runnerWeight ?? 40);
  const rmRate = Number(p.rmRate ?? p.approvedRmRate ?? 136.20);
  const mbPct = Number(p.masterbatchPct ?? 0);
  const mbRate = Number(p.masterbatchRate ?? 0);
  const ct = Math.max(1, Number(p.cycleTime ?? 56));
  const st = Number(p.shiftTariff ?? 4600);
  const bop = Number(p.bopCost ?? 0.14);

  const shotWeight = (nw * cav) + rw;
  const partShotWeight = shotWeight / cav;
  const reconciliationWeight = nw * 1.01;
  const mbWeight = (partShotWeight * mbPct) / 100;
  const baseRmWeight = partShotWeight - mbWeight;

  const rawMaterialCost = (reconciliationWeight * rmRate) / 1000;
  const masterBatchCost = (mbWeight * mbRate) / 1000;
  const scrapCredit = (rw / cav / 1000) * (rmRate * 0.50);
  const totalRmCost = rawMaterialCost + masterBatchCost - scrapCredit;

  const shotsPerShift = (8 * 3600) / ct;
  const shotsWithEff = shotsPerShift * 0.95;
  const partsPerShift = shotsWithEff * cav;
  const productionCostPerPc = partsPerShift > 0 ? (st / partsPerShift) : 0;

  const subTotal = totalRmCost + productionCostPerPc;

  // Exact Excel Line 24 Formula:
  // = 3%*E41 + 3%*E42 + 3%*E34 + 2%*E42 + 0.8 + 1.5 + 0 + 0.5
  // E41 = productionCostPerPc, E42 = subTotal, E34 = totalRmCost
  const line24OH = (0.03 * productionCostPerPc) + (0.03 * subTotal) + (0.03 * totalRmCost) + (0.02 * subTotal) + 0.80 + 1.50 + 0.00 + 0.50;

  const iccReduce = -(subTotal * 0.0044187);
  const scrapRecoveryAdj = -scrapCredit;

  const totalCost = subTotal + line24OH + bop + iccReduce + scrapRecoveryAdj;

  return {
    shotWeight,
    partShotWeight,
    reconciliationWeight,
    rawMaterialCost,
    masterBatchCost,
    scrapCredit,
    totalRmCost,
    shotsPerShift,
    shotsWithEff,
    partsPerShift,
    productionCostPerPc,
    subTotal,
    line24OH,
    iccReduce,
    bopCost: bop,
    totalCost: Number(totalCost.toFixed(2)),
    finalLanded: Number(totalCost.toFixed(2)),
    approvedBaseline: Number(totalCost.toFixed(2)),
    actualRunning: Number(totalCost.toFixed(2))
  };
}

export function calculateAtombergCost(p = {}) {
  const rmBase = Number(p.rmBase || p.rmRate || 131.0);
  const rmIcc = rmBase * 0.01;
  const rmFreight = Number(p.rmFreight || 1.50);
  const rmLanded = rmBase + rmIcc + rmFreight;

  const mbBase = Number(p.mbBase || p.masterbatchRate || 250.0);
  const mbIcc = mbBase * 0.01;
  const mbFreight = Number(p.mbFreight || 2.00);
  const mbLanded = mbBase + mbIcc + mbFreight;

  const rawMbPct = Number(p.mbPct !== undefined ? p.mbPct : (p.masterbatchPct !== undefined ? p.masterbatchPct : 4.0));
  const mbPct = rawMbPct > 1 ? rawMbPct / 100 : rawMbPct;
  const rmCombRate = rmLanded * (1.0 - mbPct) + mbLanded * mbPct;

  const partWt = Number(p.partWt || p.netWeight || 37.0);
  const runnerWt = Number(p.runnerWt || p.runnerWeight || 1.0);
  const grossWt = partWt + runnerWt;

  const rmCost = (grossWt / 1000.0) * rmCombRate;
  const bopCost = Number(p.bopCost || 0.0);

  const cycleTime = Math.max(1, Number(p.cycleTime || p.cycleTimeApproved || 47.0));
  const efficiency = Number(p.efficiency || 0.90);
  const cavity = Math.max(1, Number(p.cavity || 2));
  const shiftRate = Number(p.shiftTariff || 2000);

  const partsPerShift = (28800.0 / cycleTime) * efficiency * cavity;
  const processCost = partsPerShift > 0 ? (shiftRate / partsPerShift) : 0;

  const postOpCost = Number(p.postOpCost || 1.73);
  const bopHandling = 0.03 * bopCost;
  const totalProcessCost = processCost + bopHandling + postOpCost;

  const profitOh = (rmCost + totalProcessCost) * 0.12;
  const inprocessRejection = (rmCost + bopCost + totalProcessCost) * 0.04;
  const packingCost = Number(p.packingCost || 0.86);
  const transportCost = Number(p.transportCost || 0.62);

  const finalLanded = rmCost + bopCost + totalProcessCost + profitOh + inprocessRejection + packingCost + transportCost;

  return {
    rmCost,
    processCost,
    totalProcessCost,
    profitOh,
    finalLanded: Number(finalLanded.toFixed(2)),
    approvedBaseline: Number(finalLanded.toFixed(2)),
    actualRunning: Number(finalLanded.toFixed(2)),
    totalCost: Number(finalLanded.toFixed(2))
  };
}

export function calculateDetailedCost(params, isBaseline = false) {
  const v = (params?.vendor || '').toLowerCase();
  if (v.includes('atomberg')) {
    return calculateAtombergCost(params);
  }
  return calculateHaierCost(params);
}

export function calculatePieceCostUnified(params) {
  const item = params?.item || params || {};
  const v = (item?.vendor || '').toLowerCase();
  if (v.includes('atomberg')) {
    return calculateAtombergCost(item);
  }
  return calculateHaierCost(item);
}

export default {
  calculateHaierCost,
  calculateAtombergCost,
  calculateDetailedCost,
  calculatePieceCostUnified
};
