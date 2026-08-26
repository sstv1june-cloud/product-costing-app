// ============================================================================
// MULTI-VENDOR COST CALCULATION ENGINE (Exact Atomberg 38-Line + Haier 38-Line)
// ============================================================================

export function calculateAtombergCost(params = {}) {
  // 1. RM & MB Base Rates
  const rmBase = Number(params.rmBase !== undefined ? params.rmBase : 131.00);
  const mbBase = Number(params.mbBase !== undefined ? params.mbBase : 154.00);
  
  const rmIcc = Number((rmBase * 0.01).toFixed(2));
  const rmFreight = 1.50;
  const rmLanded = Number((rmBase + rmIcc + rmFreight).toFixed(2)); // 133.81

  const mbIcc = Number((mbBase * 0.01).toFixed(2));
  const mbFreight = 2.00;
  const mbLanded = Number((mbBase + mbIcc + mbFreight).toFixed(2)); // 157.54

  // 2. MB % & Blended RM Rate
  const mbPctRaw = Number(params.mbPct !== undefined ? params.mbPct : ((Number(params.masterbatchPct) || 4) / 100));
  const mbPct = mbPctRaw > 1 ? mbPctRaw / 100 : mbPctRaw;
  const blendedRmRate = Number(( (rmLanded * (1 - mbPct)) + (mbLanded * mbPct) ).toFixed(2)); // 134.76 or 138.80

  // 3. Weights & RM Cost
  const partWt = Number(params.partWt !== undefined ? params.partWt : (params.netWeight !== undefined ? params.netWeight : 37.00));
  const runnerWt = Number(params.runnerWt !== undefined ? params.runnerWt : (params.runnerWeight !== undefined ? params.runnerWeight : 1.00));
  const cavity = Number(params.cavity || 2);
  const grossWt = Number((partWt + (cavity > 0 ? (runnerWt / cavity) : runnerWt)).toFixed(2)); // 37.5g or 38g

  const rmCostPerPc = Number(((blendedRmRate * (partWt * cavity + runnerWt)) / (cavity * 1000)).toFixed(2)); // 5.27
  const bopCost = Number(params.bopCost || 0);
  const rmPlusBop = Number((rmCostPerPc + bopCost).toFixed(2)); // 5.27

  // 4. Machine Conversion Cost (90% Efficiency)
  const tonnage = Number(params.tonnage || params.machineTonnage || 200);
  const shiftTariff = Number(params.shiftTariff || 2000);
  const cycleTime = Number(params.cycleTime !== undefined ? params.cycleTime : (params.cycleTimeApproved || 47));
  const efficiency = 0.90;

  const theoreticalShots = cycleTime > 0 ? (28800 / cycleTime) : 0;
  const partsPerShift = Number((theoreticalShots * efficiency * cavity).toFixed(2)); // 1102.98
  const processCostPerPc = partsPerShift > 0 ? Number((shiftTariff / partsPerShift).toFixed(2)) : 1.81; // 1.81

  const handlingBop = Number((bopCost * 0.03).toFixed(2));
  const postOpCost = Number(params.postOpCost !== undefined ? params.postOpCost : 1.73);
  const totalProcessCost = Number((processCostPerPc + handlingBop + postOpCost).toFixed(2)); // 3.54

  // 5. Overheads, Rejections & Recoveries
  const baseConversionTotal = Number((rmPlusBop + totalProcessCost).toFixed(2)); // 8.81
  const ohAndProfit = Number((baseConversionTotal * 0.12).toFixed(2)); // 1.06
  const inProcessRejection = Number((baseConversionTotal * 0.04).toFixed(2)); // 0.35
  const runnerRecoveryCredit = Number((((runnerWt / cavity) / 1000) * 25).toFixed(2)); // 0.03

  const packingCost = Number(params.packingCost !== undefined ? params.packingCost : 0.00);
  const transportCost = Number(params.transportCost !== undefined ? params.transportCost : 0.86);
  const mouldMaintenance = Number((totalProcessCost * 0.175).toFixed(2)) || 0.62; // 0.62
  const otherCost = Number(params.otherCost !== undefined ? params.otherCost : 0.07);

  // 6. Final Landed Cost
  const finalLanded = Number((
    rmPlusBop + 
    totalProcessCost + 
    ohAndProfit + 
    inProcessRejection - 
    runnerRecoveryCredit + 
    packingCost + 
    transportCost + 
    mouldMaintenance + 
    otherCost
  ).toFixed(2)); // 11.75

  return {
    rmBase,
    rmIcc,
    rmFreight,
    rmLanded,
    mbBase,
    mbIcc,
    mbFreight,
    mbLanded,
    mbPct: (mbPct * 100).toFixed(1),
    blendedRmRate,
    partWt,
    runnerWt,
    grossWt,
    rmCostPerPc,
    bopCost,
    rmPlusBop,
    tonnage,
    shiftTariff,
    cycleTime,
    efficiency,
    cavity,
    partsPerShift,
    processCostPerPc,
    handlingBop,
    postOpCost,
    totalProcessCost,
    ohAndProfit,
    inProcessRejection,
    runnerRecoveryCredit,
    packingCost,
    transportCost,
    mouldMaintenance,
    otherCost,
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
