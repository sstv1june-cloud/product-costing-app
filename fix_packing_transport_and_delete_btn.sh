#!/usr/bin/env bash
set -e

echo "==> 1. Updating costCalculationService.js with correct Packing (₹0.86) and Transport (₹0.62) defaults..."
cat << 'CALC_EOF' > src/shared/costCalculationService.js
// ============================================================================
// UNIVERSAL COST CALCULATION SERVICE
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

  const mbBase = Number(p.mbBase || p.masterbatchRate || 254.0);
  const mbIcc = mbBase * 0.01;
  const mbFreight = Number(p.mbFreight || 2.00);
  const mbLanded = mbBase + mbIcc + mbFreight;

  const rawMbPct = Number(p.mbPct !== undefined ? p.mbPct : (p.masterbatchPct !== undefined ? p.masterbatchPct : 4.0));
  const mbPct = rawMbPct > 1 ? rawMbPct / 100 : rawMbPct;
  const rmCombRate = (rmLanded * (1.0 - mbPct)) + (mbLanded * mbPct);

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
  const runnerRecovery = -25.0 * (runnerWt / 1000.0);
  
  // Exact Atomberg breakdown
  const packingCost = Number(p.packingCost !== undefined ? p.packingCost : 0.86);
  const transportCost = Number(p.transportCost !== undefined ? p.transportCost : 0.62);
  const mouldMaint = 0.02 * totalProcessCost;

  const finalLanded = rmCost + bopCost + totalProcessCost + profitOh + inprocessRejection + runnerRecovery + packingCost + transportCost + mouldMaint;

  return {
    rmCost,
    processCost,
    totalProcessCost,
    profitOh,
    inprocessRejection,
    runnerRecovery,
    packingCost,
    transportCost,
    mouldMaint,
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
CALC_EOF

echo "==> 2. Updating InlineEditModal.jsx with corrected Packing/Transport slots, dual edits, and restored Delete Button..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, AlertTriangle, Trash2 } from 'lucide-react';
import { getActiveRmMapping, getActiveMbMapping, deleteProductFromBaseline } from '../../shared/masterStore';
import { 
  calculateAtombergCost, 
  calculateHaierCost, 
  calculateDetailedCost, 
  calculatePieceCostUnified 
} from '../../shared/costCalculationService';

export { 
  calculateAtombergCost, 
  calculateHaierCost, 
  calculateDetailedCost, 
  calculatePieceCostUnified 
};

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const isAtomberg = (item.vendor || '').toLowerCase().includes('atomberg');
  const rmInfo = getActiveRmMapping(item.approvedRm, item.vendor, '2026-08-01');
  const mbInfo = getActiveMbMapping(item.vendor, '2026-08-01');

  const handleDelete = () => {
    deleteProductFromBaseline(item.itemCode, item.vendor);
    setShowDeleteConfirm(false);
    onClose();
  };

  const params = item.parameters || {};

  // Net weight & Runner weight
  const [netWt, setNetWt] = useState(params.runningNetWeight ?? item.netWeight ?? (isAtomberg ? 37 : 197));
  const [runnerWt, setRunnerWt] = useState(params.runningRunnerWeight ?? item.runnerWeight ?? (isAtomberg ? 1 : 40));

  // Dual-column editable MB % (Line 13)
  const initialBaseMbPct = Number(item.masterbatchPct !== undefined ? item.masterbatchPct : (isAtomberg ? 4.0 : 0.0));
  const normalizedBaseMbPct = initialBaseMbPct > 0 && initialBaseMbPct < 1 ? initialBaseMbPct * 100 : initialBaseMbPct;
  const [baseMbPctVal, setBaseMbPctVal] = useState(normalizedBaseMbPct);
  
  const initialActMbPct = Number(params.runningMbPct !== undefined ? params.runningMbPct : normalizedBaseMbPct);
  const normalizedActMbPct = initialActMbPct > 0 && initialActMbPct < 1 ? initialActMbPct * 100 : initialActMbPct;
  const [actMbPctVal, setActMbPctVal] = useState(normalizedActMbPct);

  // Dual-column editable BOP / Inserts Cost
  const [baseBopCost, setBaseBopCost] = useState(item.bopCost ?? (isAtomberg ? 0.00 : 0.14));
  const [actBopCost, setActBopCost] = useState(params.runningBopCost ?? item.bopCost ?? (isAtomberg ? 0.00 : 0.14));

  // Dual-column editable Packing Cost (Line 34)
  const [basePackingCost, setBasePackingCost] = useState(item.packingCost ?? (isAtomberg ? 0.86 : 0.00));
  const [actPackingCost, setActPackingCost] = useState(params.runningPackingCost ?? item.packingCost ?? (isAtomberg ? 0.86 : 0.00));

  // Dual-column editable Transport Cost (Line 35)
  const [baseTransportCost, setBaseTransportCost] = useState(item.transportCost ?? (isAtomberg ? 0.62 : 0.00));
  const [actTransportCost, setActTransportCost] = useState(params.runningTransportCost ?? item.transportCost ?? (isAtomberg ? 0.62 : 0.00));

  // Cycle time, Cavity, Tonnage
  const [cycleTime, setCycleTime] = useState(params.runningCycleTime ?? item.cycleTimeApproved ?? item.cycleTime ?? (isAtomberg ? 47 : 56));
  const [cavity, setCavity] = useState(params.runningCavity ?? item.cavity ?? 2);
  const [tonnage, setTonnage] = useState(params.runningTonnage ?? item.machineTonnage ?? (isAtomberg ? 200 : 450));
  
  // Dual-column editable Shift Tariff
  const [costingTariff, setCostingTariff] = useState(item.shiftTariff ?? (isAtomberg ? 2000 : 4600));
  const [actualTariff, setActualTariff] = useState(params.runningShiftTariff ?? item.shiftTariff ?? (isAtomberg ? 2000 : 4600));
  const [reason, setReason] = useState("Shopfloor parameters & cost verification");

  if (isAtomberg) {
    // ========================================================================
    // ATOMBERG 38-LINE EXACT DUAL-COLUMN CALCULATIONS
    // ========================================================================
    const appRmBase = Number(rmInfo.approvedPrice || item.approvedRmRate || 131.00);
    const actRmBase = Number(rmInfo.activeWaPrice || 135.83);
    const appMbBase = Number(mbInfo.approvedMbPrice || item.masterbatchRate || 254.00);
    const actMbBase = Number(mbInfo.activeMbPrice || 258.54);

    // Baseline Math
    const baseRmLanded = appRmBase + (appRmBase * 0.01) + 1.50;
    const baseMbLanded = appMbBase + (appMbBase * 0.01) + 2.00;
    const baseMbFraction = Number(baseMbPctVal || 0) / 100;
    const baseRmComb = (baseRmLanded * (1.0 - baseMbFraction)) + (baseMbLanded * baseMbFraction);
    const basePartWt = Number(item.netWeight || 37.0);
    const baseRunnerWt = Number(item.runnerWeight || 1.0);
    const baseGrossWt = basePartWt + baseRunnerWt;
    const baseRmCost = (baseGrossWt / 1000.0) * baseRmComb;
    const baseBop = Number(baseBopCost || 0.0);
    const baseRmBop = baseRmCost + baseBop;
    const baseCav = Number(item.cavity || 2);
    const baseCt = Number(item.cycleTimeApproved || item.cycleTime || 47);
    const basePartsShift = (28800.0 / baseCt) * 0.90 * baseCav;
    const baseProcessCost = basePartsShift > 0 ? (Number(costingTariff) / basePartsShift) : 0;
    const baseTotalProcess = baseProcessCost + (0.03 * baseBop) + 1.73;
    const baseProfitOh = (baseRmCost + baseTotalProcess) * 0.12;
    const baseInprocRej = (baseRmBop + baseTotalProcess) * 0.04;
    const baseRunnerRec = -25.0 * (baseRunnerWt / 1000.0);
    const basePacking = Number(basePackingCost || 0.86);
    const baseTransport = Number(baseTransportCost || 0.62);
    const baseMouldMaint = 0.02 * baseTotalProcess;
    const baseOther = 0.00;
    const baseFinalLanded = baseRmCost + baseBop + baseTotalProcess + baseProfitOh + baseInprocRej + baseRunnerRec + basePacking + baseTransport + baseMouldMaint + baseOther;

    // Actual Running Math
    const actRmLanded = actRmBase + (actRmBase * 0.01) + 1.50;
    const actMbLanded = actMbBase + (actMbBase * 0.01) + 2.00;
    const actMbFraction = Number(actMbPctVal || 0) / 100;
    const actRmComb = (actRmLanded * (1.0 - actMbFraction)) + (actMbLanded * actMbFraction);
    const actPartWt = Number(netWt);
    const actRunnerWt = Number(runnerWt);
    const actGrossWt = actPartWt + actRunnerWt;
    const actRmCost = (actGrossWt / 1000.0) * actRmComb;
    const actBop = Number(actBopCost || 0.0);
    const actRmBop = actRmCost + actBop;
    const actCav = Number(cavity);
    const actCt = Number(cycleTime);
    const actPartsShift = (28800.0 / actCt) * 0.90 * actCav;
    const actProcessCost = actPartsShift > 0 ? (Number(actualTariff) / actPartsShift) : 0;
    const actTotalProcess = actProcessCost + (0.03 * actBop) + 1.73;
    const actProfitOh = (actRmCost + actTotalProcess) * 0.12;
    const actInprocRej = (actRmBop + actTotalProcess) * 0.04;
    const actRunnerRec = -25.0 * (actRunnerWt / 1000.0);
    const actPacking = Number(actPackingCost || 0.86);
    const actTransport = Number(actTransportCost || 0.62);
    const actMouldMaint = 0.02 * actTotalProcess;
    const actOther = 0.00;
    const actFinalLanded = actRmCost + actBop + actTotalProcess + actProfitOh + actInprocRej + actRunnerRec + actPacking + actTransport + actMouldMaint + actOther;

    const profitLossDelta = Number((baseFinalLanded - actFinalLanded).toFixed(2));

    const atomberg38Rows = [
      { sn: 1, desc: 'Vendor', uom: '-', costing: item.vendor || 'Atomberg', actual: item.vendor || 'Atomberg', delta: '-' },
      { sn: 2, desc: 'Part Code', uom: '-', costing: item.itemCode, actual: item.itemCode, delta: '-' },
      { sn: 3, desc: 'Part name', uom: '-', costing: item.componentName, actual: item.componentName, delta: '-' },
      { sn: 4, desc: 'RM grade (Locked & Linked)', uom: '-', costing: item.approvedRm || 'PP H110MA', actual: item.approvedRm || 'PP H110MA', delta: '-' },
      { sn: 5, desc: 'RM Base Rate (From RM Matrix)', uom: '₹/kg', costing: `₹${appRmBase.toFixed(2)}`, actual: `₹${actRmBase.toFixed(2)}`, delta: `₹${(appRmBase - actRmBase).toFixed(2)}` },
      { sn: 6, desc: 'ICC Cost @ 1% of RM', uom: '1%', costing: `₹${(appRmBase * 0.01).toFixed(2)}`, actual: `₹${(actRmBase * 0.01).toFixed(2)}`, delta: `₹${((appRmBase - actRmBase) * 0.01).toFixed(2)}` },
      { sn: 7, desc: 'Freight Cost', uom: '₹/kg', costing: '₹1.50', actual: '₹1.50', delta: '₹0.00' },
      { sn: 8, desc: 'RM Landed Cost', uom: '₹/kg', costing: `₹${baseRmLanded.toFixed(2)}`, actual: `₹${actRmLanded.toFixed(2)}`, delta: `₹${(baseRmLanded - actRmLanded).toFixed(2)}`, isHighlight: true },
      { sn: 9, desc: 'MB Base Cost', uom: '₹/kg', costing: `₹${appMbBase.toFixed(2)}`, actual: `₹${actMbBase.toFixed(2)}`, delta: `₹${(appMbBase - actMbBase).toFixed(2)}` },
      { sn: 10, desc: 'MB-ICC Cost @ 1% of MB', uom: '1%', costing: `₹${(appMbBase * 0.01).toFixed(2)}`, actual: `₹${(actMbBase * 0.01).toFixed(2)}`, delta: `₹${((appMbBase - actMbBase) * 0.01).toFixed(2)}` },
      { sn: 11, desc: 'MB Freight Cost', uom: '₹/kg', costing: '₹2.00', actual: '₹2.00', delta: '₹0.00' },
      { sn: 12, desc: 'MB Landed Cost', uom: '₹/kg', costing: `₹${baseMbLanded.toFixed(2)}`, actual: `₹${actMbLanded.toFixed(2)}`, delta: `₹${(baseMbLanded - actMbLanded).toFixed(2)}`, isHighlight: true },
      { 
        sn: 13, 
        desc: 'MB %', 
        uom: '%', 
        isSpecialEdit: true,
        costingVal: baseMbPctVal,
        setCostingVal: setBaseMbPctVal,
        actualVal: actMbPctVal,
        setActualVal: setActMbPctVal,
        delta: `${(Number(baseMbPctVal || 0) - Number(actMbPctVal || 0)).toFixed(2)}%`
      },
      { sn: 14, desc: 'RM cost (PP + MB) /KG', uom: '₹/kg', costing: `₹${baseRmComb.toFixed(2)}`, actual: `₹${actRmComb.toFixed(2)}`, delta: `₹${(baseRmComb - actRmComb).toFixed(2)}` },
      { sn: 15, desc: 'Part weight grams', uom: 'Gms', costing: `${basePartWt.toFixed(2)}g`, isInput: true, inputType: 'netWt', actual: netWt, delta: `${(basePartWt - Number(netWt)).toFixed(2)}g` },
      { sn: 16, desc: 'Runner weight grams', uom: 'Gms', costing: `${baseRunnerWt.toFixed(2)}g`, isInput: true, inputType: 'runnerWt', actual: runnerWt, delta: `${(baseRunnerWt - Number(runnerWt)).toFixed(2)}g` },
      { sn: 17, desc: 'Gross weight', uom: 'Gms', costing: `${baseGrossWt.toFixed(2)}g`, actual: `${actGrossWt.toFixed(2)}g`, delta: `${(baseGrossWt - actGrossWt).toFixed(2)}g` },
      { sn: 18, desc: 'RM cost', uom: '₹/pc', costing: `₹${baseRmCost.toFixed(2)}`, actual: `₹${actRmCost.toFixed(2)}`, delta: `₹${(baseRmCost - actRmCost).toFixed(2)}`, isSubtotal: true },
      { 
        sn: 19, 
        desc: 'Inserts / BOP cost', 
        uom: '₹/pc', 
        isSpecialEdit: true,
        costingVal: baseBopCost,
        setCostingVal: setBaseBopCost,
        actualVal: actBopCost,
        setActualVal: setActBopCost,
        delta: `₹${(Number(baseBopCost || 0) - Number(actBopCost || 0)).toFixed(2)}`
      },
      { sn: 20, desc: 'RM + BOP Cost', uom: '₹/pc', costing: `₹${baseRmBop.toFixed(2)}`, actual: `₹${actRmBop.toFixed(2)}`, delta: `₹${(baseRmBop - actRmBop).toFixed(2)}`, isSubtotal: true },
      { sn: 21, desc: 'M/c tonnage', uom: 'T', costing: `${item.machineTonnage || 200}T`, isInput: true, inputType: 'tonnage', actual: tonnage, delta: (Number(item.machineTonnage || 200) - Number(tonnage)) },
      { sn: 22, desc: 'Shift rate (Manual Entry)', uom: '₹/shift', isTariffRow: true, costing: costingTariff, actual: actualTariff, delta: `₹${(Number(costingTariff) - Number(actualTariff)).toFixed(2)}` },
      { sn: 23, desc: 'Cycle time', uom: 'Sec', costing: `${baseCt}s`, isInput: true, inputType: 'cycleTime', actual: cycleTime, delta: `${(baseCt - Number(cycleTime)).toFixed(1)}s` },
      { sn: 24, desc: 'Efficiency', uom: '-', costing: '0.90', actual: '0.90', delta: '-' },
      { sn: 25, desc: 'No of cavity', uom: 'Nos', costing: baseCav, isInput: true, inputType: 'cavity', actual: cavity, delta: (baseCav - Number(cavity)) },
      { sn: 26, desc: 'Parts/shift', uom: 'Nos', costing: Math.round(basePartsShift), actual: Math.round(actPartsShift), delta: Math.round(basePartsShift - actPartsShift) },
      { sn: 27, desc: 'Process cost', uom: '₹/pc', costing: `₹${baseProcessCost.toFixed(2)}`, actual: `₹${actProcessCost.toFixed(2)}`, delta: `₹${(baseProcessCost - actProcessCost).toFixed(2)}` },
      { sn: 28, desc: 'Handling cost for BOP', uom: '3%', costing: `₹${(0.03 * baseBop).toFixed(2)}`, actual: `₹${(0.03 * actBop).toFixed(2)}`, delta: `₹${(0.03 * (baseBop - actBop)).toFixed(2)}` },
      { sn: 29, desc: 'Post operation cost', uom: '₹/pc', costing: '₹1.73', actual: '₹1.73', delta: '₹0.00' },
      { sn: 30, desc: 'Total Process Cost', uom: '₹/pc', costing: `₹${baseTotalProcess.toFixed(2)}`, actual: `₹${actTotalProcess.toFixed(2)}`, delta: `₹${(baseTotalProcess - actTotalProcess).toFixed(2)}`, isSubtotal: true },
      { sn: 31, desc: 'Profit & OH', uom: '12%', costing: `₹${baseProfitOh.toFixed(2)}`, actual: `₹${actProfitOh.toFixed(2)}`, delta: `₹${(baseProfitOh - actProfitOh).toFixed(2)}` },
      { sn: 32, desc: 'Inprocess Rejection', uom: '4%', costing: `₹${baseInprocRej.toFixed(2)}`, actual: `₹${actInprocRej.toFixed(2)}`, delta: `₹${(baseInprocRej - actInprocRej).toFixed(2)}` },
      { sn: 33, desc: 'Runner recovery cost', uom: '₹25/kg', costing: `- ₹${Math.abs(baseRunnerRec).toFixed(2)}`, actual: `- ₹${Math.abs(actRunnerRec).toFixed(2)}`, delta: `₹${(baseRunnerRec - actRunnerRec).toFixed(2)}`, isHighlight: true },
      { 
        sn: 34, 
        desc: 'Packing cost', 
        uom: '₹/pc', 
        isSpecialEdit: true,
        costingVal: basePackingCost,
        setCostingVal: setBasePackingCost,
        actualVal: actPackingCost,
        setActualVal: setActPackingCost,
        delta: `₹${(Number(basePackingCost || 0) - Number(actPackingCost || 0)).toFixed(2)}`
      },
      { 
        sn: 35, 
        desc: 'Transport cost', 
        uom: '₹/pc', 
        isSpecialEdit: true,
        costingVal: baseTransportCost,
        setCostingVal: setBaseTransportCost,
        actualVal: actTransportCost,
        setActualVal: setActTransportCost,
        delta: `₹${(Number(baseTransportCost || 0) - Number(actTransportCost || 0)).toFixed(2)}`
      },
      { sn: 36, desc: 'Mould maintenance cost', uom: '2%', costing: `₹${baseMouldMaint.toFixed(2)}`, actual: `₹${actMouldMaint.toFixed(2)}`, delta: `₹${(baseMouldMaint - actMouldMaint).toFixed(2)}` },
      { sn: 37, desc: 'Other Cost', uom: '₹/pc', costing: '₹0.00', actual: '₹0.00', delta: '₹0.00' },
      { sn: 38, desc: 'FINAL LANDED COST', uom: '₹/pc', costing: `₹${baseFinalLanded.toFixed(2)}`, actual: `₹${actFinalLanded.toFixed(2)}`, delta: `₹${profitLossDelta >= 0 ? '+' : ''}${profitLossDelta.toFixed(2)}`, isTotal: true }
    ];

    const handleSaveAtomberg = () => {
      onSave({
        updatedItem: {
          ...item,
          shiftTariff: Number(costingTariff),
          masterbatchPct: Number(baseMbPctVal),
          bopCost: Number(baseBopCost),
          packingCost: Number(basePackingCost),
          transportCost: Number(baseTransportCost),
          parameters: {
            ...item.parameters,
            runningNetWeight: Number(netWt),
            runningRunnerWeight: Number(runnerWt),
            runningMbPct: Number(actMbPctVal),
            runningBopCost: Number(actBopCost),
            runningPackingCost: Number(actPackingCost),
            runningTransportCost: Number(actTransportCost),
            runningCycleTime: Number(cycleTime),
            runningCavity: Number(cavity),
            runningTonnage: Number(tonnage),
            runningShiftTariff: Number(actualTariff)
          }
        },
        changeType: "Atomberg Spec Adjustment",
        reason
      });
    };

    return (
      <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
        <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] flex flex-col justify-between relative">
          
          {/* Delete Confirmation Modal Overlay */}
          {showDeleteConfirm && (
            <div className="absolute inset-0 bg-slate-900/90 backdrop-blur-sm z-60 rounded-2xl flex items-center justify-center p-6">
              <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl border-2 border-rose-500 text-center space-y-4">
                <div className="w-12 h-12 bg-rose-100 text-rose-600 rounded-full flex items-center justify-center mx-auto">
                  <AlertTriangle className="w-6 h-6" />
                </div>
                <h3 className="text-base font-bold text-slate-900">Delete Product Baseline?</h3>
                <p className="text-xs text-slate-600">
                  Are you sure you want to delete <span className="font-bold text-slate-900 font-mono">[{item.itemCode}] {item.componentName}</span>? This action will remove it from all costing and MIS views.
                </p>
                <div className="flex justify-center gap-3 pt-2">
                  <button 
                    onClick={() => setShowDeleteConfirm(false)} 
                    className="px-4 py-2 border border-slate-300 rounded-xl hover:bg-slate-50 font-bold cursor-pointer"
                  >
                    Cancel
                  </button>
                  <button 
                    onClick={handleDelete} 
                    className="px-5 py-2 bg-rose-600 hover:bg-rose-700 text-white rounded-xl font-bold shadow-md shadow-rose-600/30 cursor-pointer flex items-center gap-1.5"
                  >
                    <Trash2 className="w-4 h-4" /> Yes, Delete Product
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Header */}
          <div className="flex justify-between items-start border-b border-slate-200 pb-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="px-2.5 py-0.5 bg-blue-600 text-white rounded font-mono font-bold text-xs">{item.itemCode}</span>
                <h2 className="text-base font-bold text-slate-900">{item.componentName}</h2>
                <span className="text-[10px] px-2 py-0.5 bg-slate-100 text-slate-600 rounded font-semibold border">Atomberg Prescribed Format</span>
              </div>
              <div className="text-[11px] text-slate-500 mt-0.5">Vendor: <span className="font-bold text-slate-700">{item.vendor}</span> | RM Link: <span className="font-mono font-bold text-blue-600">(₹{actRmBase.toFixed(2)}/kg)</span></div>
            </div>
            <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-700 cursor-pointer"><X className="w-5 h-5" /></button>
          </div>

          {/* Top 3 KPI Cards */}
          <div className="grid grid-cols-3 gap-3">
            <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl">
              <div className="text-[10px] font-bold text-slate-400 uppercase">APPROVED BASELINE CONTRACT</div>
              <div className="text-2xl font-black text-slate-900 font-mono mt-1">₹{baseFinalLanded.toFixed(2)}</div>
            </div>
            <div className="p-4 bg-blue-50/60 border border-blue-200 rounded-xl">
              <div className="text-[10px] font-bold text-blue-600 uppercase">ACTUAL RUNNING SHOPFLOOR</div>
              <div className="text-2xl font-black text-blue-700 font-mono mt-1">₹{actFinalLanded.toFixed(2)}</div>
            </div>
            <div className={`p-4 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-rose-50 border-rose-200 text-rose-700'}`}>
              <div className="text-[10px] font-bold uppercase">PROFIT / LOSS (Δ)</div>
              <div className="text-2xl font-black font-mono mt-1 flex items-center gap-1">
                {profitLossDelta >= 0 ? `+ ₹${profitLossDelta.toFixed(2)}` : `- ₹${Math.abs(profitLossDelta).toFixed(2)}`}
              </div>
            </div>
          </div>

          {/* Table */}
          <div className="border border-slate-200 rounded-xl overflow-hidden max-h-[50vh] overflow-y-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold sticky top-0 z-10">
                <tr>
                  <th className="py-2.5 px-3 w-12 text-center">#</th>
                  <th className="py-2.5 px-4">ATOMBERG COSTING LINE</th>
                  <th className="py-2.5 px-3 text-center w-20">UOM / RATE</th>
                  <th className="py-2.5 px-4 text-right w-44">APPROVED BASELINE</th>
                  <th className="py-2.5 px-4 text-right w-44">ACTUAL RUNNING</th>
                  <th className="py-2.5 px-4 text-right w-28">DELTA (Δ)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {atomberg38Rows.map((r) => {
                  if (r.isTotal) {
                    return (
                      <tr key={r.sn} className="bg-slate-900 text-white font-black text-sm">
                        <td className="py-3 px-3 text-center text-amber-400 font-bold">{r.sn}</td>
                        <td className="py-3 px-4 text-amber-300 uppercase tracking-wider">{r.desc}</td>
                        <td className="py-3 px-3 text-center text-slate-300 font-mono">{r.uom}</td>
                        <td className="py-3 px-4 text-right font-mono text-amber-300">{r.costing}</td>
                        <td className="py-3 px-4 text-right font-mono text-amber-300">{r.actual}</td>
                        <td className={`py-3 px-4 text-right font-mono ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>{r.delta}</td>
                      </tr>
                    );
                  }

                  if (r.isSpecialEdit) {
                    return (
                      <tr key={r.sn} className="bg-amber-50/40">
                        <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                        <td className="py-2 px-4 font-bold text-slate-900">{r.desc}</td>
                        <td className="py-2 px-3 text-center font-mono font-semibold text-slate-600">{r.uom}</td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            value={r.costingVal} 
                            onChange={e => r.setCostingVal(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            value={r.actualVal} 
                            onChange={e => r.setActualVal(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-blue-500 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 focus:ring-2 focus:ring-blue-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">{r.delta}</td>
                      </tr>
                    );
                  }

                  if (r.isTariffRow) {
                    return (
                      <tr key={r.sn} className="bg-emerald-50/40">
                        <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                        <td className="py-2 px-4 font-bold text-slate-900">{r.desc}</td>
                        <td className="py-2 px-3 text-center font-mono font-semibold text-slate-600">{r.uom}</td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            value={costingTariff} 
                            onChange={e => setCostingTariff(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            value={actualTariff} 
                            onChange={e => setActualTariff(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-blue-500 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 focus:ring-2 focus:ring-blue-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">{r.delta}</td>
                      </tr>
                    );
                  }

                  return (
                    <tr 
                      key={r.sn} 
                      className={`${r.isSubtotal ? 'bg-amber-50/50 font-bold' : 'hover:bg-slate-50'}`}
                    >
                      <td className="py-2 px-3 text-center font-mono text-slate-400">{r.sn}</td>
                      <td className={`py-2 px-4 ${r.isSubtotal ? 'text-slate-900' : 'text-slate-800 font-medium'}`}>{r.desc}</td>
                      <td className="py-2 px-3 text-center font-mono text-slate-500">{r.uom}</td>
                      <td className="py-2 px-4 text-right font-mono">{r.costing}</td>
                      <td className="py-2 px-4 text-right">
                        {r.isInput ? (
                          <input 
                            type="number" 
                            value={r.actual} 
                            onChange={e => {
                              const val = e.target.value;
                              if (r.inputType === 'netWt') setNetWt(val);
                              else if (r.inputType === 'runnerWt') setRunnerWt(val);
                              else if (r.inputType === 'tonnage') setTonnage(val);
                              else if (r.inputType === 'cycleTime') setCycleTime(val);
                              else if (r.inputType === 'cavity') setCavity(val);
                            }} 
                            className="w-20 px-1 py-0.5 border border-blue-400 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 outline-none focus:ring-2 focus:ring-blue-500" 
                          />
                        ) : (
                          <span className={`font-mono ${r.isSubtotal ? 'text-blue-700 font-bold' : r.isHighlight ? 'text-emerald-700 font-bold' : 'text-slate-700'}`}>
                            {r.actual}
                          </span>
                        )}
                      </td>
                      <td className={`py-2 px-4 text-right font-mono ${r.isSubtotal ? 'text-rose-600 font-bold' : 'text-slate-500'}`}>{r.delta}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* Footer Actions with Red Delete Button */}
          <div className="flex justify-between items-center pt-2 border-t border-slate-200">
            <button
              onClick={() => setShowDeleteConfirm(true)}
              className="flex items-center gap-1.5 px-4 py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-300 rounded-xl text-xs font-bold transition-all cursor-pointer shadow-xs"
            >
              <Trash2 className="w-4 h-4 text-rose-600" /> Delete Product
            </button>

            <div className="flex items-center gap-2">
              <button onClick={onClose} className="px-4 py-2 border rounded-xl font-bold cursor-pointer hover:bg-slate-50 text-slate-700">Cancel</button>
              <button onClick={handleSaveAtomberg} className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer flex items-center gap-1.5"><Save className="w-4 h-4" /> Save & Log Parameters</button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // ========================================================================
  // HAIER 38-LINE EXACT DUAL-COLUMN CALCULATIONS
  // ========================================================================
  const dynamicHaierApprovedRm = Number(rmInfo.approvedPrice || item.approvedRmRate || 136.20);
  const dynamicHaierActualRm = Number(rmInfo.activeWaPrice || 134.80);
  const dynamicHaierApprovedMb = Number(mbInfo.approvedMbPrice || item.masterbatchRate || 0.0);

  const baseCalc = calculateHaierCost({
    cavity: Number(item.cavity || 2),
    netWeight: Number(item.netWeight || 197),
    runnerWeight: Number(item.runnerWeight || 40),
    rmRate: dynamicHaierApprovedRm,
    masterbatchPct: Number(baseMbPctVal || 0.0),
    masterbatchRate: dynamicHaierApprovedMb,
    machineTonnage: Number(item.machineTonnage || 450),
    shiftTariff: Number(costingTariff),
    cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 56),
    bopCost: Number(baseBopCost || 0.14)
  });

  const runCalc = calculateHaierCost({
    cavity: Number(cavity),
    netWeight: Number(netWt),
    runnerWeight: Number(runnerWt),
    rmRate: dynamicHaierActualRm,
    masterbatchPct: Number(actMbPctVal || 0.0),
    masterbatchRate: dynamicHaierApprovedMb,
    machineTonnage: Number(tonnage),
    shiftTariff: Number(actualTariff),
    cycleTime: Number(cycleTime),
    bopCost: Number(actBopCost || 0.14)
  });

  const profitLossDelta = Number((baseCalc.totalCost - runCalc.totalCost).toFixed(2));

  const haier38FullRows = [
    { sn: 1, desc: 'Name Of component', uom: '-', costing: item.componentName, actual: item.componentName, delta: '-' },
    { sn: 2, desc: 'Mould size L x W xH', uom: 'mm', costing: item.mouldSize || '1070*720*650', actual: item.mouldSize || '1070*720*650', delta: '-' },
    { sn: 3, desc: 'Item No.', uom: '-', costing: item.itemCode, actual: item.itemCode, delta: '-' },
    { sn: 4, desc: 'Model', uom: '-', costing: item.model || 'OLD DC- 195,220', actual: item.model || 'OLD DC- 195,220', delta: '-' },
    { sn: 5, desc: 'Raw Material Required (Fetched from RM Page)', uom: '-', costing: `${item.approvedRm || 'ABS 300 Pre Colour'} (₹${dynamicHaierApprovedRm.toFixed(2)}/kg)`, actual: `(₹${dynamicHaierActualRm.toFixed(2)}/kg)`, delta: `${(dynamicHaierApprovedRm - dynamicHaierActualRm).toFixed(2)}` },
    { 
      sn: 6, 
      desc: 'Master Batch Required (%)', 
      uom: '%', 
      isSpecialEdit: true,
      costingVal: baseMbPctVal,
      setCostingVal: setBaseMbPctVal,
      actualVal: actMbPctVal,
      setActualVal: setActMbPctVal,
      delta: `${(Number(baseMbPctVal || 0) - Number(actMbPctVal || 0)).toFixed(2)}%`
    },
    { sn: 7, desc: 'No. of Cavity', uom: 'Nos', costing: item.cavity || 2, isInput: true, inputType: 'cavity', actual: cavity, delta: (Number(item.cavity || 2) - Number(cavity)) },
    { sn: 8, desc: 'Runner Weight', uom: 'Gms', costing: `${item.runnerWeight || 40}g`, isInput: true, inputType: 'runnerWt', actual: runnerWt, delta: `${(Number(item.runnerWeight || 40) - Number(runnerWt)).toFixed(1)}g` },
    { sn: 9, desc: 'Net Weight', uom: 'Gms', costing: `${item.netWeight || 197}g`, isInput: true, inputType: 'netWt', actual: netWt, delta: `${(Number(item.netWeight || 197) - Number(netWt)).toFixed(1)}g` },
    { sn: 10, desc: 'Shot Weight', uom: 'Gms', costing: `${baseCalc.shotWeight?.toFixed(2)}g`, actual: `${runCalc.shotWeight?.toFixed(2)}g`, delta: `${(baseCalc.shotWeight - runCalc.shotWeight).toFixed(2)}g` },
    { sn: 11, desc: 'Reconciliation Weight = Shot wt + 1.0 % Melt Loss on shot wt', uom: 'Gms', costing: `${(Number(item.netWeight || 197) * 1.01).toFixed(2)}g`, actual: `${(Number(netWt) * 1.01).toFixed(2)}g`, delta: `${((Number(item.netWeight || 197) - Number(netWt)) * 1.01).toFixed(2)}g` },
    { sn: 12, desc: 'Raw Material Cost', uom: 'Rs', costing: `₹${baseCalc.rawMaterialCost?.toFixed(2)}`, actual: `₹${runCalc.rawMaterialCost?.toFixed(2)}`, delta: `₹${(baseCalc.rawMaterialCost - runCalc.rawMaterialCost).toFixed(2)}` },
    { sn: 13, desc: 'Master batch cost', uom: 'Rs', costing: `₹${baseCalc.masterBatchCost?.toFixed(2)}`, actual: `₹${runCalc.masterBatchCost?.toFixed(2)}`, delta: `₹${(baseCalc.masterBatchCost - runCalc.masterBatchCost).toFixed(2)}` },
    { sn: 14, desc: 'Runner recovery % (Scrap Credit)', uom: '-', costing: `- ₹${baseCalc.scrapCredit?.toFixed(2)}`, actual: `- ₹${runCalc.scrapCredit?.toFixed(2)}`, delta: `₹${(baseCalc.scrapCredit - runCalc.scrapCredit).toFixed(2)}`, isHighlight: true },
    { sn: 15, desc: 'Total Raw Material Cost', uom: 'Rs', costing: `₹${baseCalc.totalRmCost?.toFixed(2)}`, actual: `₹${runCalc.totalRmCost?.toFixed(2)}`, delta: `₹${(baseCalc.totalRmCost - runCalc.totalRmCost).toFixed(2)}`, isSubtotal: true },
    { sn: 16, desc: 'Machine Used', uom: 'T', costing: `${item.machineTonnage || 450}T`, isInput: true, inputType: 'tonnage', actual: tonnage, delta: (Number(item.machineTonnage || 450) - Number(tonnage)) },
    { sn: 17, desc: 'Machine Tariff per Shift (Manual Entry)', uom: 'Rs', isTariffRow: true, costing: costingTariff, actual: actualTariff, delta: `₹${(Number(costingTariff) - Number(actualTariff)).toFixed(2)}` },
    { sn: 18, desc: 'Cycle Time', uom: 'Sec', costing: `${item.cycleTimeApproved || item.cycleTime || 56}s`, isInput: true, inputType: 'cycleTime', actual: cycleTime, delta: `${(Number(item.cycleTimeApproved || 56) - Number(cycleTime)).toFixed(1)}s` },
    { sn: 19, desc: 'No of Shot / Shift (8Hour)', uom: 'Nos', costing: Math.round(baseCalc.shotsPerShift), actual: Math.round(runCalc.shotsPerShift), delta: Math.round(baseCalc.shotsPerShift - runCalc.shotsPerShift) },
    { sn: 20, desc: 'No of Shot / Shift with 95 % Efficiency', uom: 'Nos', costing: Math.round(baseCalc.shotsWithEff), actual: Math.round(runCalc.shotsWithEff), delta: Math.round(baseCalc.shotsWithEff - runCalc.shotsWithEff) },
    { sn: 21, desc: 'No. of component / shift', uom: 'Nos', costing: Math.round(baseCalc.partsPerShift), actual: Math.round(runCalc.partsPerShift), delta: Math.round(baseCalc.partsPerShift - runCalc.partsPerShift) },
    { sn: 22, desc: 'Production Cost / Pc', uom: 'Rs', costing: `₹${baseCalc.productionCostPerPc?.toFixed(2)}`, actual: `₹${runCalc.productionCostPerPc?.toFixed(2)}`, delta: `₹${(baseCalc.productionCostPerPc - runCalc.productionCostPerPc).toFixed(2)}` },
    { sn: 23, desc: 'SUB TOTAL', uom: 'Rs', costing: `₹${baseCalc.subTotal?.toFixed(2)}`, actual: `₹${runCalc.subTotal?.toFixed(2)}`, delta: `₹${(baseCalc.subTotal - runCalc.subTotal).toFixed(2)}`, isSubtotal: true },
    { sn: 24, desc: 'OH+Profit+ICC+Rejection+Foam/Polybag+Masking film+Plastic Bin/Polyenda Box/Trolley+Freight Cost', uom: 'Rs', costing: `₹${baseCalc.line24OH?.toFixed(2)}`, actual: `₹${runCalc.line24OH?.toFixed(2)}`, delta: `₹${(baseCalc.line24OH - runCalc.line24OH).toFixed(2)}`, isBlueHighlight: true },
    { sn: 25, desc: 'Foam / Polybag / Masking film', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 26, desc: 'Plastic Bin / Polyend Box / Trolley', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 27, desc: 'Freight Cost', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 28, desc: 'Secondary Operation 1', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 29, desc: 'Secondary Operation 2', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 30, desc: 'Screen printing - 1st stroke', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 31, desc: 'Screen printing - 2nd stroke', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 32, desc: 'Assembly Cost', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { 
      sn: 33, 
      desc: 'Insert / Hinge hole cap cost / Other cost', 
      uom: 'Rs', 
      isSpecialEdit: true,
      costingVal: baseBopCost,
      setCostingVal: setBaseBopCost,
      actualVal: actBopCost,
      setActualVal: setActBopCost,
      delta: `₹${(Number(baseBopCost || 0) - Number(actBopCost || 0)).toFixed(2)}`
    },
    { sn: 34, desc: 'Mould Maintenance Provision', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 35, desc: 'Quality Inspection Cost', uom: 'Rs', costing: '-', actual: '-', delta: '-' },
    { sn: 36, desc: 'ICC Reduce by .5% (Payment term change From 60 to 45 days)', uom: '-', costing: `- ₹${Math.abs(baseCalc.iccReduce || 0.13).toFixed(2)}`, actual: `- ₹${Math.abs(runCalc.iccReduce || 0.13).toFixed(2)}`, delta: '₹0.00' },
    { sn: 37, desc: 'Scrap Recovery Adjustment', uom: 'Rs', costing: `- ₹${baseCalc.scrapCredit?.toFixed(2)}`, actual: `- ₹${runCalc.scrapCredit?.toFixed(2)}`, delta: '₹0.00' },
    { sn: 38, desc: 'TOTAL COST', uom: 'Rs', costing: `₹${baseCalc.totalCost?.toFixed(2)}`, actual: `₹${runCalc.totalCost?.toFixed(2)}`, delta: `₹${profitLossDelta >= 0 ? '+' : ''}${profitLossDelta.toFixed(2)}`, isTotal: true }
  ];

  const handleSaveHaier = () => {
    onSave({
      updatedItem: {
        ...item,
        shiftTariff: Number(costingTariff),
        masterbatchPct: Number(baseMbPctVal),
        bopCost: Number(baseBopCost),
        netWeight: Number(netWt),
        runnerWeight: Number(runnerWt),
        machineTonnage: Number(tonnage),
        cycleTimeApproved: Number(cycleTime),
        cavity: Number(cavity),
        parameters: {
          ...item.parameters,
          runningNetWeight: Number(netWt),
          runningRunnerWeight: Number(runnerWt),
          runningMbPct: Number(actMbPctVal),
          runningBopCost: Number(actBopCost),
          runningCycleTime: Number(cycleTime),
          runningCavity: Number(cavity),
          runningTonnage: Number(tonnage),
          runningShiftTariff: Number(actualTariff)
        }
      },
      changeType: "Haier Parameter Drift Update",
      reason
    });
  };

  return (
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] flex flex-col justify-between relative">
        
        {/* Delete Confirmation Modal Overlay */}
        {showDeleteConfirm && (
          <div className="absolute inset-0 bg-slate-900/90 backdrop-blur-sm z-60 rounded-2xl flex items-center justify-center p-6">
            <div className="bg-white rounded-2xl p-6 max-w-md w-full shadow-2xl border-2 border-rose-500 text-center space-y-4">
              <div className="w-12 h-12 bg-rose-100 text-rose-600 rounded-full flex items-center justify-center mx-auto">
                <AlertTriangle className="w-6 h-6" />
              </div>
              <h3 className="text-base font-bold text-slate-900">Delete Product Baseline?</h3>
              <p className="text-xs text-slate-600">
                Are you sure you want to delete <span className="font-bold text-slate-900 font-mono">[{item.itemCode}] {item.componentName}</span>? This action will remove it from all costing and MIS views.
              </p>
              <div className="flex justify-center gap-3 pt-2">
                <button 
                  onClick={() => setShowDeleteConfirm(false)} 
                  className="px-4 py-2 border border-slate-300 rounded-xl hover:bg-slate-50 font-bold cursor-pointer"
                >
                  Cancel
                </button>
                <button 
                  onClick={handleDelete} 
                  className="px-5 py-2 bg-rose-600 hover:bg-rose-700 text-white rounded-xl font-bold shadow-md shadow-rose-600/30 cursor-pointer flex items-center gap-1.5"
                >
                  <Trash2 className="w-4 h-4" /> Yes, Delete Product
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Header */}
        <div className="flex justify-between items-start border-b border-slate-200 pb-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 bg-blue-600 text-white rounded font-mono font-bold text-xs">{item.itemCode}</span>
              <h2 className="text-base font-bold text-slate-900">{item.componentName}</h2>
              <span className="text-[10px] px-2 py-0.5 bg-blue-50 text-blue-700 rounded font-semibold border border-blue-200">Haier 38-Line Exact Costing Sheet</span>
            </div>
            <div className="text-[11px] text-slate-500 mt-0.5">Vendor: <span className="font-bold text-slate-700">{item.vendor}</span> | RM Link: <span className="font-mono font-bold text-blue-600">(₹{Number(rmInfo.activeWaPrice || 0).toFixed(2)}/kg)</span></div>
          </div>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-700 cursor-pointer"><X className="w-5 h-5" /></button>
        </div>

        {/* Top 3 KPI Cards */}
        <div className="grid grid-cols-3 gap-3">
          <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl">
            <div className="text-[10px] font-bold text-slate-400 uppercase">COSTING (BASELINE)</div>
            <div className="text-2xl font-black text-slate-900 font-mono mt-1">₹{baseCalc.totalCost?.toFixed(2)}</div>
          </div>
          <div className="p-4 bg-blue-50/60 border border-blue-200 rounded-xl">
            <div className="text-[10px] font-bold text-blue-600 uppercase">ACTUAL RUNNING</div>
            <div className="text-2xl font-black text-blue-700 font-mono mt-1">₹{runCalc.totalCost?.toFixed(2)}</div>
          </div>
          <div className={`p-4 rounded-xl border ${profitLossDelta >= 0 ? 'bg-emerald-50 border-emerald-200 text-emerald-700' : 'bg-rose-50 border-rose-200 text-rose-700'}`}>
            <div className="text-[10px] font-bold uppercase">PROFIT / LOSS (Δ)</div>
            <div className="text-2xl font-black font-mono mt-1 flex items-center gap-1">
              {profitLossDelta >= 0 ? `+ ₹${profitLossDelta.toFixed(2)}` : `- ₹${Math.abs(profitLossDelta).toFixed(2)}`}
            </div>
          </div>
        </div>

        {/* Full Table */}
        <div className="border border-slate-200 rounded-xl overflow-hidden max-h-[50vh] overflow-y-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="bg-slate-100 text-slate-700 uppercase text-[10px] font-bold sticky top-0 z-10">
              <tr>
                <th className="py-2.5 px-3 w-12 text-center">S.N.</th>
                <th className="py-2.5 px-4">DESCRIPTION</th>
                <th className="py-2.5 px-3 text-center w-16">UOM</th>
                <th className="py-2.5 px-4 text-right w-44">COSTING</th>
                <th className="py-2.5 px-4 text-right w-44">ACTUAL</th>
                <th className="py-2.5 px-4 text-right w-28">DELTA (Δ)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {haier38FullRows.map((r) => {
                if (r.isTotal) {
                  return (
                    <tr key={r.sn} className="bg-slate-900 text-white font-black text-sm">
                      <td className="py-3 px-3 text-center text-amber-400 font-bold">{r.sn}</td>
                      <td className="py-3 px-4 text-amber-300 uppercase tracking-wider">{r.desc}</td>
                      <td className="py-3 px-3 text-center text-slate-300">{r.uom}</td>
                      <td className="py-3 px-4 text-right font-mono text-amber-300">{r.costing}</td>
                      <td className="py-3 px-4 text-right font-mono text-amber-300">{r.actual}</td>
                      <td className={`py-3 px-4 text-right font-mono ${profitLossDelta >= 0 ? 'text-emerald-400' : 'text-rose-400'}`}>{r.delta}</td>
                    </tr>
                  );
                }

                if (r.isSpecialEdit) {
                  return (
                    <tr key={r.sn} className="bg-amber-50/40">
                      <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                      <td className="py-2 px-4 font-bold text-slate-900">{r.desc}</td>
                      <td className="py-2 px-3 text-center font-mono font-semibold text-slate-600">{r.uom}</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={r.costingVal} 
                          onChange={e => r.setCostingVal(e.target.value)} 
                          className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                        />
                      </td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={r.actualVal} 
                          onChange={e => r.setActualVal(e.target.value)} 
                          className="w-24 px-1.5 py-0.5 border border-blue-500 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 focus:ring-2 focus:ring-blue-500" 
                        />
                      </td>
                      <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">{r.delta}</td>
                    </tr>
                  );
                }

                if (r.isTariffRow) {
                  return (
                    <tr key={r.sn} className="bg-emerald-50/40">
                      <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                      <td className="py-2 px-4 font-bold text-slate-900">{r.desc}</td>
                      <td className="py-2 px-3 text-center font-mono font-semibold text-slate-600">{r.uom}</td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={costingTariff} 
                          onChange={e => setCostingTariff(e.target.value)} 
                          className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                        />
                      </td>
                      <td className="py-2 px-4 text-right">
                        <input 
                          type="number" 
                          value={actualTariff} 
                          onChange={e => setActualTariff(e.target.value)} 
                          className="w-24 px-1.5 py-0.5 border border-blue-500 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 focus:ring-2 focus:ring-blue-500" 
                        />
                      </td>
                      <td className="py-2 px-4 text-right font-mono font-bold text-slate-700">{r.delta}</td>
                    </tr>
                  );
                }

                return (
                  <tr 
                    key={r.sn} 
                    className={`${r.isSubtotal ? 'bg-amber-50/50 font-bold' : r.isBlueHighlight ? 'bg-blue-50/30' : 'hover:bg-slate-50'}`}
                  >
                    <td className="py-2 px-3 text-center font-mono text-slate-400">{r.sn}</td>
                    <td className={`py-2 px-4 ${r.isSubtotal ? 'text-slate-900' : r.isBlueHighlight ? 'font-bold text-blue-950' : 'text-slate-800 font-medium'}`}>{r.desc}</td>
                    <td className="py-2 px-3 text-center font-mono text-slate-500">{r.uom}</td>
                    <td className="py-2 px-4 text-right font-mono">{r.costing}</td>
                    <td className="py-2 px-4 text-right">
                      {r.isInput ? (
                        <input 
                          type="number" 
                          value={r.actual} 
                          onChange={e => {
                            const val = e.target.value;
                            if (r.inputType === 'cavity') setCavity(val);
                            else if (r.inputType === 'runnerWt') setRunnerWt(val);
                            else if (r.inputType === 'netWt') setNetWt(val);
                            else if (r.inputType === 'tonnage') setTonnage(val);
                            else if (r.inputType === 'cycleTime') setCycleTime(val);
                          }} 
                          className="w-20 px-1 py-0.5 border border-blue-400 bg-blue-50 rounded text-right font-mono font-bold text-blue-900 outline-none focus:ring-2 focus:ring-blue-500" 
                        />
                      ) : (
                        <span className={`font-mono ${r.isSubtotal ? 'text-blue-700 font-bold' : r.isBlueHighlight ? 'text-blue-900 font-bold' : r.isHighlight ? 'text-emerald-700 font-bold' : 'text-slate-700'}`}>
                          {r.actual}
                        </span>
                      )}
                    </td>
                    <td className={`py-2 px-4 text-right font-mono ${r.isSubtotal ? 'text-rose-600 font-bold' : 'text-slate-500'}`}>{r.delta}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Footer Actions with Red Delete Button */}
        <div className="flex justify-between items-center pt-2 border-t border-slate-200">
          <button
            onClick={() => setShowDeleteConfirm(true)}
            className="flex items-center gap-1.5 px-4 py-2 bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-300 rounded-xl text-xs font-bold transition-all cursor-pointer shadow-xs"
          >
            <Trash2 className="w-4 h-4 text-rose-600" /> Delete Product
          </button>

          <div className="flex items-center gap-2">
            <button onClick={onClose} className="px-4 py-2 border rounded-xl font-bold cursor-pointer hover:bg-slate-50 text-slate-700">Cancel</button>
            <button onClick={handleSaveHaier} className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer flex items-center gap-1.5"><Save className="w-4 h-4" /> Save & Log Parameters</button>
          </div>
        </div>
      </div>
    </div>
  );
}
MODAL_EOF

echo "==> 3. Updating productCostRepo.js to account for Packing and Transport costs in live sync..."
cat << 'REPO_EOF' > src/shared/productCostRepo.js
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
REPO_EOF

echo "==> 4. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Refresh browser to verify."
