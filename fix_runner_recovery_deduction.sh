#!/usr/bin/env bash
set -e

echo "==> 1. Updating costCalculationService.js with exact Runner Cost deduction formula..."
cat << 'SERVICE_EOF' > src/shared/costCalculationService.js
import { getActiveRmMapping, getActiveMbMapping } from './masterStore';

export function calculateAtombergCost(p) {
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
  const rmBopCost = rmCost + bopCost;

  const tonnage = Number(p.tonnage || p.machineTonnage || 200.0);
  const shiftRate = Number(p.shiftTariff || p.shiftRate || (tonnage * 10) || (tonnage * 8));
  const cycleTime = Math.max(1, Number(p.cycleTime || p.cycleTimeApproved || 47.0));
  const efficiency = Number(p.efficiency || 0.90);
  const cavity = Math.max(1, Number(p.cavity || 2));

  const partsPerShift = (28800.0 / cycleTime) * efficiency * cavity;
  const processCost = partsPerShift > 0 ? (shiftRate / partsPerShift) : 0;

  const bopHandling = 0.03 * bopCost;
  const postOpCost = Number(p.postOpCost || 1.73);
  const totalProcessCost = processCost + bopHandling + postOpCost;

  const profitOh = (rmCost + totalProcessCost) * 0.12;
  const inprocessRejection = (rmBopCost + totalProcessCost) * 0.04;
  const runnerRecovery = -25.0 * (runnerWt / 1000.0);
  const icc = 0.0;
  const packingCost = Number(p.packingCost || 0.86);
  const transportCost = Number(p.transportCost || 0.62);
  const mouldMaint = 0.02 * totalProcessCost;

  const otherCost = profitOh + inprocessRejection + runnerRecovery + icc + packingCost + transportCost + mouldMaint;
  const finalLanded = rmBopCost + totalProcessCost + otherCost;

  return {
    rmBase, rmIcc, rmFreight, rmLanded,
    mbBase, mbIcc, mbFreight, mbLanded,
    mbPct, rmCombRate, partWt, runnerWt, grossWt,
    rmCost, bopCost, rmBopCost, tonnage, shiftRate,
    cycleTime, efficiency, cavity, partsPerShift,
    processCost, bopHandling, postOpCost, totalProcessCost,
    profitOh, inprocessRejection, runnerRecovery, icc,
    packingCost, transportCost, mouldMaint, otherCost,
    finalLanded, totalCost: finalLanded
  };
}

export function calculateHaierCost(params) {
  const cavity = Math.max(1, Number(params.cavity) || 1);
  const netWeight = Number(params.netWeight || params.partWt || 197.0);
  const runnerWeight = Number(params.runnerWeight || params.runnerWt || 40.0);
  const rmRate = Number(params.rmRate || params.rmBase || 136.20);
  const mbPct = Number(params.masterbatchPct || params.mbPct || 0.0);
  const mbRate = Number(params.masterbatchRate || params.mbBase || 0.00);
  const cycleTime = Math.max(1, Number(params.cycleTime || params.cycleTimeApproved || 48));
  const machineTonnage = Number(params.machineTonnage || params.tonnage || 450);
  const shiftTariff = Number(params.shiftTariff !== undefined ? params.shiftTariff : (machineTonnage * 8));

  const shotWeightPerPiece = ((netWeight * cavity) + runnerWeight);
  const reconciliationWeight = netWeight * 1.01;

  const mbFraction = mbPct > 1 ? mbPct / 100 : mbPct;
  const pureRmFraction = Math.max(0, 1 - mbFraction);

  const rawMaterialCost = (reconciliationWeight / 1000) * rmRate * pureRmFraction;
  const masterbatchCost = (reconciliationWeight / 1000) * mbRate * mbFraction;
  
  // Revised calculation:
  // Runner Cost = (Runner Weight / Cavity) * (RM Rate / 1000)
  // Total RM Cost = (Raw Material Cost + Masterbatch Cost) - Runner Cost
  const runnerCost = (runnerWeight / cavity) * (rmRate / 1000.0);
  const runnerRecoveryCredit = runnerCost;
  const totalRmCost = (rawMaterialCost + masterbatchCost) - runnerCost;

  const shotsPerShift8Hr = 28800.0 / cycleTime;
  const shotsPerShiftEff = shotsPerShift8Hr * 0.95;
  const partsPerShift = shotsPerShiftEff * cavity;
  const productionCostPerPc = partsPerShift > 0 ? (shiftTariff / partsPerShift) : 0;

  const subTotal = totalRmCost + productionCostPerPc;
  const ohProfitIccRej = 5.11; 
  const insertOtherCost = Number(params.bopCost || 0.14);
  const iccReduce = -0.13;
  const scrapRecovery = -1.36;

  const totalCost = subTotal + ohProfitIccRej + insertOtherCost + iccReduce + scrapRecovery;

  return {
    cavity, netWeight, runnerWeight, shotWeightPerPiece, reconciliationWeight,
    rawMaterialCost, masterbatchCost, runnerRecoveryCredit, runnerCost, totalRmCost,
    machineTonnage, shiftTariff, cycleTime, shotsPerShift8Hr, shotsPerShiftEff,
    partsPerShift, productionCostPerPc, subTotal, ohProfitIccRej, insertOtherCost,
    iccReduce, scrapRecovery, totalCost, finalLanded: totalCost
  };
}

export function calculateDetailedCost(params, isBaseline = false) {
  const vendor = (params.vendor || 'Haier').toLowerCase();
  if (vendor.includes('atomberg')) {
    return calculateAtombergCost(params);
  }
  return calculateHaierCost(params);
}

export function calculatePieceCostUnified({ item, isBaseline = false, targetDate = null }) {
  const vendor = (item.vendor || 'Haier').trim();
  const isAtomberg = vendor.toLowerCase().includes('atomberg');
  const isCrisper = item.itemCode === '0060217978E';
  const params = item.parameters || {};

  const rmMapping = getActiveRmMapping(item.approvedRm || (isCrisper ? 'GPPS SC201LV' : 'ABS 300 Pre Colour'), vendor, targetDate);
  const mbMapping = getActiveMbMapping(vendor, targetDate);

  if (isAtomberg) {
    const rmApprovedRate = Number(rmMapping.approvedPrice || item.approvedRmRate || 131.00);
    const rmActiveRate = Number(rmMapping.activeWaPrice || 135.83);
    const usedRmRate = isBaseline ? rmApprovedRate : rmActiveRate;

    const mbApprovedRate = Number(mbMapping.approvedMbPrice || item.masterbatchRate || 250.00);
    const mbActiveRate = Number(mbMapping.activeMbWaPrice || 258.54);
    const usedMbRate = isBaseline ? mbApprovedRate : mbActiveRate;

    const postOp = isBaseline ? 1.73 : Number(params.runningPostOpCost || item.postOpCost || 1.73);

    return calculateAtombergCost({
      vendor: 'Atomberg',
      rmBase: usedRmRate,
      mbBase: usedMbRate,
      rmFreight: 1.50,
      mbFreight: 2.00,
      mbPct: Number(isBaseline ? (item.masterbatchPct || 4.0) : (params.runningMbPct ?? item.masterbatchPct ?? 4.0)),
      partWt: Number(isBaseline ? (item.netWeight || 37.0) : (params.runningNetWeight ?? item.netWeight ?? 37.0)),
      runnerWt: Number(isBaseline ? (item.runnerWeight || 1.0) : (params.runningRunnerWeight ?? item.runnerWeight ?? 1.0)),
      bopCost: Number(isBaseline ? (item.bopCost || 0.0) : (params.runningBopCost ?? item.bopCost ?? 0.0)),
      tonnage: Number(isBaseline ? (item.machineTonnage || 200.0) : (params.runningTonnage ?? item.machineTonnage ?? 200.0)),
      cycleTime: Number(isBaseline ? (item.cycleTimeApproved || 47.0) : (params.runningCycleTime ?? item.cycleTimeApproved ?? 47.0)),
      efficiency: 0.90,
      cavity: Number(isBaseline ? (item.cavity || 2) : (params.runningCavity ?? item.cavity ?? 2)),
      postOpCost: postOp,
      shiftTariff: item.shiftTariff,
      packingCost: 0.86,
      transportCost: 0.62
    });
  } else {
    const rmApprovedRate = Number(rmMapping.approvedPrice || item.approvedRmRate || 136.20);
    const rmActiveRate = Number(rmMapping.activeWaPrice || rmApprovedRate);
    const mbRateVal = Number(mbMapping.approvedMbPrice || item.masterbatchRate || 0.0);
    const mbPctVal = Number(item.masterbatchPct || 0.0);
    const tonnageVal = Number(item.machineTonnage || 450);
    const shiftTariffVal = Number(item.shiftTariff !== undefined ? item.shiftTariff : (tonnageVal * 8));
    const cycleTimeVal = Number(item.cycleTimeApproved || item.cycleTime || 48);

    if (isBaseline) {
      return calculateHaierCost({
        cavity: Number(item.cavity || 2),
        netWeight: Number(item.netWeight || 197),
        runnerWeight: Number(item.runnerWeight || 40),
        rmRate: rmApprovedRate,
        masterbatchPct: mbPctVal,
        masterbatchRate: mbRateVal,
        machineTonnage: tonnageVal,
        shiftTariff: shiftTariffVal,
        cycleTime: cycleTimeVal,
        bopCost: Number(item.bopCost || 0.14)
      });
    } else {
      const runningTonnage = Number(params.runningTonnage || tonnageVal);
      const runningTariff = Number(params.runningShiftTariff !== undefined ? params.runningShiftTariff : (runningTonnage * 8));
      return calculateHaierCost({
        cavity: Number(params.runningCavity || item.cavity || 2),
        netWeight: Number(params.runningNetWeight || item.netWeight || 197),
        runnerWeight: Number(params.runningRunnerWeight || item.runnerWeight || 40),
        rmRate: rmActiveRate,
        masterbatchPct: Number(params.runningMbPct || mbPctVal),
        masterbatchRate: mbRateVal,
        machineTonnage: runningTonnage,
        shiftTariff: runningTariff,
        cycleTime: Number(params.runningCycleTime || cycleTimeVal),
        bopCost: Number(params.runningBopCost || item.bopCost || 0.14)
      });
    }
  }
}
SERVICE_EOF

echo "==> 2. Updating InlineEditModal.jsx to display Runner Cost as negative deduction (- ₹...)..."
MODAL_FILE=$(find src -name "*InlineEditModal*.jsx" | head -n 1)
if [ -n "$MODAL_FILE" ]; then
  sed -i 's/₹{Number(calc.runnerRecoveryCredit || 0).toFixed(2)}/- ₹{Number(calc.runnerRecoveryCredit || calc.runnerCost || 0).toFixed(2)}/g' "$MODAL_FILE" 2>/dev/null || true
fi

echo "==> Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Runner recovery deduction formula updated."
