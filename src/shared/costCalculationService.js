// ============================================================================
// MULTI-VENDOR COST CALCULATION ENGINE
// ============================================================================

export function calculateAtombergCost(params = {}) {
  const rmBase = Number(params.rmBase || 0);
  const mbBase = Number(params.mbBase || 0);
  const partWt = Number(params.partWt || 37);
  const runnerWt = Number(params.runnerWt || 1);
  const mbPct = Number(params.mbPct || 0.04);
  const bopCost = Number(params.bopCost || 0);
  const cycleTime = Number(params.cycleTime || 47);
  const cavity = Number(params.cavity || 2);
  const tonnage = Number(params.tonnage || 200);
  const shiftTariff = Number(params.shiftTariff || 2000);
  const postOpCost = Number(params.postOpCost || 1.73);
  const packingCost = Number(params.packingCost || 0.86);
  const transportCost = Number(params.transportCost || 0.62);
  const scrapRate = Number(params.scrapRate || 25);

  const landedRm = Number((rmBase * 1.01 + 1.50).toFixed(2));
  const landedMb = Number((mbBase * 1.01 + 2.00).toFixed(2));
  const blendedRmRate = Number(((landedRm * (1 - mbPct)) + (landedMb * mbPct)).toFixed(2));

  const totalShotWt = (partWt * cavity) + runnerWt;
  const rawMatCostPerPc = cavity > 0 ? Number(((blendedRmRate * totalShotWt) / (cavity * 1000)).toFixed(2)) : 0;

  const runnerScrapCredit = cavity > 0 ? Number((((runnerWt / cavity) / 1000) * scrapRate).toFixed(2)) : 0;
  const netRmCost = Number((rawMatCostPerPc - runnerScrapCredit).toFixed(2));

  const theoreticalShots = cycleTime > 0 ? (28800 / cycleTime) : 0;
  const actualShots = theoreticalShots * 0.90;
  const partsPerShift = actualShots * cavity;
  const convRatePerPc = partsPerShift > 0 ? Number((shiftTariff / partsPerShift).toFixed(2)) : 0;

  const baseCost = Number((netRmCost + convRatePerPc).toFixed(2));
  const ohAndProfit = Number((baseCost * 0.12).toFixed(2));
  const inProcessRejection = Number((baseCost * 0.04).toFixed(2));
  const mouldMaintenance = Number((convRatePerPc * 0.02).toFixed(2));

  const finalLanded = Number((
    netRmCost + 
    convRatePerPc + 
    ohAndProfit + 
    inProcessRejection + 
    bopCost + 
    postOpCost + 
    packingCost + 
    transportCost + 
    mouldMaintenance
  ).toFixed(2));

  return {
    landedRm: landedRm || 0,
    landedMb: landedMb || 0,
    blendedRmRate: blendedRmRate || 0,
    totalShotWt: totalShotWt || 0,
    rawMatCostPerPc: rawMatCostPerPc || 0,
    runnerScrapCredit: runnerScrapCredit || 0,
    netRmCost: netRmCost || 0,
    convRatePerPc: convRatePerPc || 0,
    ohAndProfit: ohAndProfit || 0,
    inProcessRejection: inProcessRejection || 0,
    mouldMaintenance: mouldMaintenance || 0,
    totalCost: finalLanded || 0,
    finalLanded: finalLanded || 0
  };
}

export function calculateHaierCost(params = {}) {
  const cavity = Number(params.cavity) || 1;
  const netWeight = Number(params.netWeight) || 0;
  const runnerWeight = Number(params.runnerWeight) || 0;
  const shotWeight = params.shotWeight !== undefined && params.shotWeight !== null 
    ? Number(params.shotWeight) 
    : (netWeight * cavity + runnerWeight);
  
  const pieceWeight = cavity > 0 ? (shotWeight / cavity) : netWeight;
  const reconciliationWeight = Number((pieceWeight * 1.02).toFixed(2));

  const rmRate = Number(params.rmRate || 0);
  const mbPct = (Number(params.masterbatchPct || 0)) / 100;
  const mbRate = Number(params.masterbatchRate || 0);

  const rawMaterialCost = Number(((reconciliationWeight / 1000) * (1 - mbPct) * rmRate).toFixed(4));
  const masterbatchCost = Number(((reconciliationWeight / 1000) * mbPct * mbRate).toFixed(4));
  const runnerRecoveryScrap = Number(params.runnerRecoveryScrap || 0);
  const totalRmCost = Number((rawMaterialCost + masterbatchCost - runnerRecoveryScrap).toFixed(4));

  const cycleTime = Number(params.cycleTime) || 70;
  const shiftTariff = Number(params.shiftTariff) || 4800;
  const theoreticalShots = cycleTime > 0 ? (28800 / cycleTime) : 0;
  const actualShots = theoreticalShots * 0.95;
  const partsPerShift = actualShots * cavity;
  const productionCostPerPc = partsPerShift > 0 ? Number((shiftTariff / partsPerShift).toFixed(4)) : 0;

  const subTotal = Number((totalRmCost + productionCostPerPc).toFixed(4));
  const haierOverheadPackage = Number(params.haierOverheadPackage || 0);
  const mouldMaintenance = Number(params.mouldMaintenance || 0);
  const qualityInspection = Number(params.qualityInspection || 0);
  const iccReduce = Number(params.iccReduce || 0);
  const scrapAdj = Number(params.scrapAdj || 0);
  const otherBop = Number(params.bopCost || 0);

  const totalCost = Number((
    subTotal + 
    haierOverheadPackage + 
    mouldMaintenance + 
    qualityInspection + 
    iccReduce + 
    scrapAdj + 
    otherBop
  ).toFixed(2));

  return {
    shotWeight: shotWeight || 0,
    reconciliationWeight: reconciliationWeight || 0,
    rawMaterialCost: rawMaterialCost || 0,
    masterbatchCost: masterbatchCost || 0,
    totalRmCost: totalRmCost || 0,
    productionCostPerPc: productionCostPerPc || 0,
    subTotal: subTotal || 0,
    haierOverheadPackage: haierOverheadPackage || 0,
    mouldMaintenance: mouldMaintenance || 0,
    qualityInspection: qualityInspection || 0,
    iccReduce: iccReduce || 0,
    scrapAdj: scrapAdj || 0,
    totalCost: totalCost || 0,
    finalLanded: totalCost || 0
  };
}
