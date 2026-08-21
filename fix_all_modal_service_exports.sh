#!/usr/bin/env bash
set -e

echo "==> 1. Updating src/shared/costCalculationService.js to include all legacy named exports (calculateDetailedCost, calculatePieceCost, calculateCostByVendor)..."
cat << 'CALC_EOF' > src/shared/costCalculationService.js
// ============================================================================
// UNIVERSAL COST CALCULATION SERVICE (All Named Exports Included)
// ============================================================================

export function calculateHaierCost(item, overrideParams = {}) {
  const nw = Number(overrideParams.netWeight ?? item?.parameters?.runningNetWeight ?? item?.netWeight ?? 197);
  const rw = Number(overrideParams.runnerWeight ?? item?.parameters?.runningRunnerWeight ?? item?.runnerWeight ?? 40);
  const cav = Number(overrideParams.cavity ?? item?.parameters?.runningCavity ?? item?.cavity ?? 2) || 1;
  const ct = Number(overrideParams.cycleTime ?? item?.parameters?.runningCycleTime ?? item?.cycleTime ?? 48) || 48;
  const st = Number(overrideParams.shiftTariff ?? item?.shiftTariff ?? 3600);

  const isRunningActual = overrideParams.actualRmRate !== undefined || overrideParams.actualMbRate !== undefined;
  const appRm = Number(item?.approvedRmRate ?? 136.20);
  const actRm = Number(overrideParams.actualRmRate ?? item?.actualRmRate ?? appRm);
  const activeRm = isRunningActual ? actRm : appRm;

  const mbPct = Number(overrideParams.masterbatchPct ?? item?.parameters?.runningMbPct ?? item?.masterbatchPct ?? 0);
  const appMb = Number(item?.masterbatchRate ?? 0);
  const actMb = Number(overrideParams.actualMbRate ?? item?.actualMbRate ?? appMb);
  const activeMb = isRunningActual ? actMb : appMb;

  const shotWeight = nw + rw;
  const partShotWeight = shotWeight / (cav > 0 ? cav : 1);
  const mbWeight = (partShotWeight * mbPct) / 100;
  const baseRmWeight = partShotWeight - mbWeight;

  const matCost = ((baseRmWeight * activeRm) + (mbWeight * activeMb)) / 1000;

  const shotsPerShift = (8 * 3600) / ct;
  const shotsWithEff = shotsPerShift * 0.95;
  const partsPerShift = shotsWithEff * cav;
  const prodCostPerPc = partsPerShift > 0 ? (st / partsPerShift) : 0;

  const subTotal = matCost + prodCostPerPc;
  const ohAndProfit = subTotal * 0.15;
  const iccReduce = -(subTotal * 0.005);
  const bopCost = Number(overrideParams.bopCost ?? item?.parameters?.runningBopCost ?? item?.bopCost ?? (item?.itemCode === '0060217989D' ? 0.14 : 0));
  const postOpCost = Number(overrideParams.postOpCost ?? item?.parameters?.runningPostOpCost ?? item?.postOpCost ?? 0);

  const finalLanded = subTotal + ohAndProfit + iccReduce + bopCost + postOpCost;

  const appMatCost = ((baseRmWeight * appRm) + (mbWeight * appMb)) / 1000;
  const actMatCost = ((baseRmWeight * actRm) + (mbWeight * actMb)) / 1000;
  const appSubTotal = appMatCost + prodCostPerPc;
  const actSubTotal = actMatCost + prodCostPerPc;
  const totalApproved = appSubTotal + (appSubTotal * 0.15) - (appSubTotal * 0.005) + bopCost + postOpCost;
  const totalActual = actSubTotal + (actSubTotal * 0.15) - (actSubTotal * 0.005) + bopCost + postOpCost;
  const delta = totalApproved - totalActual;

  return {
    netWeight: nw,
    runnerWeight: rw,
    cavity: cav,
    cycleTime: ct,
    shiftTariff: st,
    shotWeight,
    partShotWeight,
    baseRmWeight,
    mbWeight,
    shotsPerShift,
    shotsWithEff,
    partsPerShift,
    prodCostPerPc,
    subTotal,
    ohAndProfit,
    iccReduce,
    rmBaseRate: activeRm,
    approvedRmRate: appRm,
    actualRmRate: actRm,
    approvedMaterialCost: appMatCost,
    actualMaterialCost: actMatCost,
    conversionCost: prodCostPerPc,
    bopCost,
    postOpCost,
    finalLanded: Number(finalLanded.toFixed(2)),
    approvedBaseline: Number(totalApproved.toFixed(2)),
    actualRunning: Number(totalActual.toFixed(2)),
    totalApproved: Number(totalApproved.toFixed(2)),
    totalActual: Number(totalActual.toFixed(2)),
    delta: Number(delta.toFixed(2)),
    deltaCost: Number(delta.toFixed(2))
  };
}

export function calculateAtombergCost(item, overrideParams = {}) {
  const nw = Number(overrideParams.netWeight ?? item?.parameters?.runningNetWeight ?? item?.netWeight ?? 37);
  const rw = Number(overrideParams.runnerWeight ?? item?.parameters?.runningRunnerWeight ?? item?.runnerWeight ?? 1);
  const cav = Number(overrideParams.cavity ?? item?.parameters?.runningCavity ?? item?.cavity ?? 2) || 1;
  const ct = Number(overrideParams.cycleTime ?? item?.parameters?.runningCycleTime ?? item?.cycleTime ?? 47) || 47;
  const st = Number(overrideParams.shiftTariff ?? item?.shiftTariff ?? 2000);

  const appRmBase = Number(item?.approvedRmRate ?? 131.00);
  const actRmBase = Number(overrideParams.actualRmRate ?? item?.actualRmRate ?? 135.83);

  const appMbBase = Number(item?.masterbatchRate ?? 250.00);
  const actMbBase = Number(overrideParams.actualMbRate ?? item?.actualMbRate ?? 258.54);

  const mbPct = Number(overrideParams.masterbatchPct ?? item?.parameters?.runningMbPct ?? item?.masterbatchPct ?? 4.0);

  const appRmLanded = appRmBase + (appRmBase * 0.01) + 1.50;
  const actRmLanded = actRmBase + (actRmBase * 0.01) + 1.50;

  const appMbLanded = appMbBase + (appMbBase * 0.01) + 2.00;
  const actMbLanded = actMbBase + (actMbBase * 0.01) + 2.00;

  const shotWeight = nw + rw;
  const partShotWeight = shotWeight / (cav > 0 ? cav : 1);
  const mbWeight = (partShotWeight * mbPct) / 100;
  const baseRmWeight = partShotWeight - mbWeight;

  const isRunningActual = overrideParams.actualRmRate !== undefined || overrideParams.actualMbRate !== undefined;
  const activeRmLanded = isRunningActual ? actRmLanded : appRmLanded;
  const activeMbLanded = isRunningActual ? actMbLanded : appMbLanded;

  const materialCost = ((baseRmWeight * activeRmLanded) + (mbWeight * activeMbLanded)) / 1000;
  const appMaterialCost = ((baseRmWeight * appRmLanded) + (mbWeight * appMbLanded)) / 1000;
  const actMaterialCost = ((baseRmWeight * actRmLanded) + (mbWeight * actMbLanded)) / 1000;

  const efficiency = 0.90;
  const partsPerShift = (((8 * 3600) / ct) * cav) * efficiency;
  const conversionCost = partsPerShift > 0 ? (st / partsPerShift) : 0;

  const bopCost = Number(overrideParams.bopCost ?? item?.parameters?.runningBopCost ?? item?.bopCost ?? 0);
  const postOpCost = Number(overrideParams.postOpCost ?? item?.parameters?.runningPostOpCost ?? item?.postOpCost ?? 1.73);
  const handlingCostBop = bopCost * 0.03;

  const finalLanded = materialCost + conversionCost + bopCost + postOpCost + handlingCostBop;
  const totalApproved = appMaterialCost + conversionCost + bopCost + postOpCost + handlingCostBop;
  const totalActual = actMaterialCost + conversionCost + bopCost + postOpCost + handlingCostBop;
  const delta = totalApproved - totalActual;

  return {
    netWeight: nw,
    runnerWeight: rw,
    cavity: cav,
    cycleTime: ct,
    shiftTariff: st,
    efficiency,
    partsPerShift,
    shotWeight,
    partShotWeight,
    baseRmWeight,
    mbWeight,
    rmBaseRate: isRunningActual ? actRmBase : appRmBase,
    rmLandedCost: activeRmLanded,
    mbBaseCost: isRunningActual ? actMbBase : appMbBase,
    mbLandedCost: activeMbLanded,
    rmCost: materialCost,
    processCost: conversionCost,
    postOpCost,
    finalLanded: Number(finalLanded.toFixed(2)),
    approvedBaseline: Number(totalApproved.toFixed(2)),
    actualRunning: Number(totalActual.toFixed(2)),
    totalApproved: Number(totalApproved.toFixed(2)),
    totalActual: Number(totalActual.toFixed(2)),
    delta: Number(delta.toFixed(2)),
    deltaCost: Number(delta.toFixed(2))
  };
}

export function calculatePieceCostUnified(item, overrideParams = {}) {
  const v = (item?.vendor || '').toLowerCase();
  if (v.includes('atomberg')) {
    return calculateAtombergCost(item, overrideParams);
  }
  return calculateHaierCost(item, overrideParams);
}

export function calculateDetailedCost(item, overrideParams = {}) {
  return calculatePieceCostUnified(item, overrideParams);
}

export function calculatePieceCost(params = {}) {
  return calculatePieceCostUnified(params, params);
}

export function calculateCostByVendor(item, vendor = 'Haier', overrideParams = {}) {
  const v = (vendor || item?.vendor || 'Haier').toLowerCase();
  if (v.includes('atomberg')) {
    return calculateAtombergCost(item, overrideParams);
  }
  return calculateHaierCost(item, overrideParams);
}

export default {
  calculateHaierCost,
  calculateAtombergCost,
  calculatePieceCostUnified,
  calculateDetailedCost,
  calculatePieceCost,
  calculateCostByVendor
};
CALC_EOF

echo "==> 2. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Refresh your browser now."
