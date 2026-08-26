// ============================================================================
// MULTI-VENDOR COST CALCULATION ENGINE
// ============================================================================

export function calculateAtombergCost(params = {}) {
  const rmBase = Number(params.rmBase !== undefined ? params.rmBase : 131.00);
  const mbBase = Number(params.mbBase !== undefined ? params.mbBase : 242.00);
  const partWt = Number(params.partWt !== undefined ? params.partWt : (params.netWeight !== undefined ? params.netWeight : 133.81));
  const runnerWt = Number(params.runnerWt !== undefined ? params.runnerWt : (params.runnerWeight !== undefined ? params.runnerWeight : 5.27));
  const mbPct = Number(params.mbPct !== undefined ? params.mbPct : ((Number(params.masterbatchPct) || 2) / 100));
  const bopCost = Number(params.bopCost || 0);
  const cycleTime = Number(params.cycleTime !== undefined ? params.cycleTime : (params.cycleTimeApproved || 38));
  const cavity = Number(params.cavity || 2);
  const tonnage = Number(params.tonnage || params.machineTonnage || 150);
  const shiftTariff = Number(params.shiftTariff || 2800);
  const postOpCost = Number(params.postOpCost !== undefined ? params.postOpCost : 1.73);
  const packingCost = Number(params.packingCost !== undefined ? params.packingCost : 0.86);
  const transportCost = Number(params.transportCost !== undefined ? params.transportCost : 0.62);
  const scrapRate = Number(params.scrapRate || 25);

  // 1. Landed Material Rates
  const landedRm = Number((rmBase * 1.01 + 1.50).toFixed(2));
  const landedMb = Number((mbBase * 1.01 + 2.00).toFixed(2));
  const blendedRmRate = Number(((landedRm * (1 - mbPct)) + (landedMb * mbPct)).toFixed(2));

  // 2. Shot Weight & Raw Material Cost
  const totalShotWt = Number(((partWt * cavity) + runnerWt).toFixed(2));
  const rawMatCostPerPc = cavity > 0 ? Number(((blendedRmRate * totalShotWt) / (cavity * 1000)).toFixed(2)) : 0;
  const runnerScrapCredit = cavity > 0 ? Number((((runnerWt / cavity) / 1000) * scrapRate).toFixed(2)) : 0;
  const netRmCost = Number((rawMatCostPerPc - runnerScrapCredit).toFixed(2));

  // 3. Machine Conversion Cost (90% Efficiency)
  const theoreticalShots = cycleTime > 0 ? (28800 / cycleTime) : 0;
  const actualShots = theoreticalShots * 0.90;
  const partsPerShift = actualShots * cavity;
  const convRatePerPc = partsPerShift > 0 ? Number((shiftTariff / partsPerShift).toFixed(2)) : 0;

  // 4. Overheads, Profit & Rejection
  const baseCost = Number((netRmCost + convRatePerPc).toFixed(2));
  const ohAndProfit = Number((baseCost * 0.12).toFixed(2));
  const inProcessRejection = Number((baseCost * 0.04).toFixed(2));
  const mouldMaintenance = Number((convRatePerPc * 0.02).toFixed(2));

  // 5. Final Landed Cost
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
    landedRm,
    landedMb,
    blendedRmRate,
    totalShotWt,
    rawMatCostPerPc,
    runnerScrapCredit,
    netRmCost,
    theoreticalShots: Number(theoreticalShots.toFixed(2)),
    actualShots: Number(actualShots.toFixed(2)),
    partsPerShift: Number(partsPerShift.toFixed(2)),
    convRatePerPc,
    baseCost,
    ohAndProfit,
    inProcessRejection,
    mouldMaintenance,
    bopCost,
    postOpCost,
    packingCost,
    transportCost,
    totalCost: finalLanded,
    finalLanded
  };
}

export function calculateHaierCost(params = {}) {
  const cavity = Number(params.cavity) || 1;
  const netWeight = Number(params.netWeight) || 0;
  const runnerWeight = Number(params.runnerWeight) || 0;
  const shotWeight = params.shotWeight !== undefined && params.shotWeight !== null 
    ? Number(params.shotWeight) 
    : (netWeight * cavity + runnerWeight);
  
  const pieceWeight = cavity > 0 ? (shotWeight > 0 ? (shotWeight / cavity) : netWeight) : netWeight;
  const reconciliationWeight = Number((pieceWeight * 1.01).toFixed(2)) || Number((pieceWeight * 1.02).toFixed(2));

  const rmRate = Number(params.rmRate || 0);
  const mbPct = (Number(params.masterbatchPct || 0)) / 100;
  const mbRate = Number(params.masterbatchRate || 0);

  const rawMaterialCost = Number(((reconciliationWeight / 1000) * (1 - mbPct) * rmRate).toFixed(4));
  const masterbatchCost = Number(((reconciliationWeight / 1000) * mbPct * mbRate).toFixed(4));
  const runnerRecoveryScrap = Number(params.runnerRecoveryScrap || 0);
  const totalRmCost = Number((rawMaterialCost + masterbatchCost - runnerRecoveryScrap).toFixed(4));

  const cycleTime = Number(params.cycleTime) || 70;
  const shiftTariff = Number(params.shiftTariff) || 4800;
  
  const partsPerShift = Number(params.partsPerShift) > 0 
    ? Number(params.partsPerShift) 
    : (cycleTime > 0 ? ((28800 / cycleTime) * 0.95 * cavity) : 0);
  
  const productionCostPerPc = partsPerShift > 0 ? Number((shiftTariff / partsPerShift).toFixed(4)) : (Number(params.productionCostPerPc) || 0);
  const subTotal = Number((totalRmCost + productionCostPerPc).toFixed(4));

  const haierOverheadPackage = Number(params.haierOverheadPackage || 0);
  const foamPolybag = Number(params.foamPolybag || 0);
  const plasticBin = Number(params.plasticBin || 0);
  const freightCost = Number(params.freightCost || 0);
  const secondaryOp1 = Number(params.secondaryOp1 || 0);
  const secondaryOp2 = Number(params.secondaryOp2 || 0);
  const screenPrint1 = Number(params.screenPrint1 || 0);
  const screenPrint2 = Number(params.screenPrint2 || 0);
  const assemblyCost = Number(params.assemblyCost || 0);
  const bopCost = Number(params.bopCost || 0);

  const mouldMaintenance = Number(params.mouldMaintenance || 0);
  const qualityInspection = Number(params.qualityInspection || 0);
  const iccReduce = Number(params.iccReduce || 0);
  const scrapAdj = Number(params.scrapAdj || 0);

  const totalCost = Number((
    subTotal + 
    haierOverheadPackage + 
    foamPolybag + 
    plasticBin + 
    freightCost + 
    secondaryOp1 + 
    secondaryOp2 + 
    screenPrint1 + 
    screenPrint2 + 
    assemblyCost + 
    bopCost + 
    mouldMaintenance + 
    qualityInspection + 
    iccReduce + 
    scrapAdj
  ).toFixed(2));

  return {
    shotWeight,
    reconciliationWeight,
    rawMaterialCost,
    masterbatchCost,
    totalRmCost,
    productionCostPerPc,
    subTotal,
    haierOverheadPackage,
    foamPolybag,
    plasticBin,
    freightCost,
    secondaryOp1,
    secondaryOp2,
    screenPrint1,
    screenPrint2,
    assemblyCost,
    bopCost,
    mouldMaintenance,
    qualityInspection,
    iccReduce,
    scrapAdj,
    totalCost,
    finalLanded: totalCost
  };
}
