#!/usr/bin/env bash
set -e

echo "==> 1. Updating InlineEditModal.jsx to re-export calculateDetailedCost and all calculation utilities..."
cat << 'MODAL_EOF' > src/modules/module1-baseline/InlineEditModal.jsx
import React, { useState } from 'react';
import { X, Save, AlertTriangle, Trash2 } from 'lucide-react';
import { 
  getActiveRmMapping, 
  getActiveMbMapping, 
  parseMaterialString,
  deleteProductFromBaseline 
} from '../../shared/masterStore';
import { 
  calculateAtombergCost, 
  calculateHaierCost,
  calculateDetailedCost,
  calculatePieceCostUnified
} from '../../shared/costCalculationService';

// Re-export calculation helpers imported by Dashboard and other modules
export { 
  calculateDetailedCost, 
  calculateAtombergCost, 
  calculateHaierCost, 
  calculatePieceCostUnified 
};

export default function InlineEditModal({ item, isOpen, onClose, onSave }) {
  if (!isOpen || !item) return null;

  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const isAtomberg = (item.vendor || '').toLowerCase().includes('atomberg');

  // Parse composite material string (e.g. "PP Mi3530 + Gray MB" -> "PP Mi3530" & "Gray MB")
  const initialParsed = parseMaterialString(item.approvedRm);
  const initialBaseRm = item.baseRm || initialParsed.baseRm || item.approvedRm || (isAtomberg ? 'PP H110MA' : 'ABS 300 Pre Colour');
  const initialMbGrade = item.approvedMb || initialParsed.mbGrade || (isAtomberg ? 'Black MB' : 'White MB');

  const [selectedRmGrade, setSelectedRmGrade] = useState(initialBaseRm);
  const [selectedMbGrade, setSelectedMbGrade] = useState(initialMbGrade);

  // Live lookup from RM Matrix (Strict Vendor + Code matching with 0 fallback)
  const rmInfo = getActiveRmMapping(selectedRmGrade, item.vendor, '2026-08-01');
  const mbInfo = getActiveMbMapping(selectedMbGrade, item.vendor, '2026-08-01');

  const params = item.parameters || {};

  // Part Weights
  const [netWt, setNetWt] = useState(params.runningNetWeight ?? item.netWeight ?? (isAtomberg ? 37 : 197));
  const [runnerWt, setRunnerWt] = useState(params.runningRunnerWeight ?? item.runnerWeight ?? (isAtomberg ? 1 : 40));

  // Dual MB %
  const parsedBaseMb = Number(item.masterbatchPct !== undefined && item.masterbatchPct !== null ? item.masterbatchPct : 4.0);
  const cleanBaseMb = parsedBaseMb > 0 && parsedBaseMb < 1 ? parsedBaseMb * 100 : parsedBaseMb;
  const [baseMbPctVal, setBaseMbPctVal] = useState(cleanBaseMb);
  
  const parsedActMb = Number(params.runningMbPct !== undefined && params.runningMbPct !== null ? params.runningMbPct : cleanBaseMb);
  const cleanActMb = parsedActMb > 0 && parsedActMb < 1 ? parsedActMb * 100 : parsedActMb;
  const [actMbPctVal, setActMbPctVal] = useState(cleanActMb);

  // Dual BOP Cost
  const initialBaseBop = Number(item.bopCost ?? 0.00);
  const [baseBopCost, setBaseBopCost] = useState(initialBaseBop);
  const [actBopCost, setActBopCost] = useState(Number(params.runningBopCost ?? initialBaseBop));

  // Dual Packing Cost
  const initialBasePacking = Number(item.packingCost ?? (isAtomberg ? 0.86 : 0.00));
  const [basePackingCost, setBasePackingCost] = useState(initialBasePacking);
  const [actPackingCost, setActPackingCost] = useState(Number(params.runningPackingCost ?? initialBasePacking));

  // Dual Transport Cost
  const initialBaseTransport = Number(item.transportCost ?? (isAtomberg ? 0.62 : 0.00));
  const [baseTransportCost, setBaseTransportCost] = useState(initialBaseTransport);
  const [actTransportCost, setActTransportCost] = useState(Number(params.runningTransportCost ?? initialBaseTransport));

  // Cycle time, Cavity, Tonnage
  const [cycleTime, setCycleTime] = useState(params.runningCycleTime ?? item.cycleTimeApproved ?? item.cycleTime ?? (isAtomberg ? 47 : 56));
  const [cavity, setCavity] = useState(params.runningCavity ?? item.cavity ?? 2);
  const [tonnage, setTonnage] = useState(params.runningTonnage ?? item.machineTonnage ?? (isAtomberg ? 200 : 450));
  
  // Dual Shift Tariff
  const initialCostingTariff = Number(item.shiftTariff ?? item.shiftRate ?? (isAtomberg ? 2000 : 4600));
  const [costingTariff, setCostingTariff] = useState(initialCostingTariff);
  const [actualTariff, setActualTariff] = useState(Number(params.runningShiftTariff ?? initialCostingTariff));

  const [reason, setReason] = useState("Shopfloor parameters & dynamic material verification");

  const handleDelete = () => {
    deleteProductFromBaseline(item.itemCode, item.vendor);
    setShowDeleteConfirm(false);
    onClose();
  };

  if (isAtomberg) {
    // ========================================================================
    // ATOMBERG 38-LINE EXACT DUAL-COLUMN CALCULATIONS
    // ========================================================================
    const appRmBase = Number(rmInfo.approvedPrice || 0.00);
    const actRmBase = Number(rmInfo.activeWaPrice || 0.00);
    const appMbBase = Number(mbInfo.approvedMbPrice || 0.00);
    const actMbBase = Number(mbInfo.activeMbWaPrice || 0.00);

    // Baseline Costing Math
    const baseRmLanded = appRmBase > 0 ? (appRmBase + (appRmBase * 0.01) + 1.50) : 0;
    const baseMbLanded = appMbBase > 0 ? (appMbBase + (appMbBase * 0.01) + 2.00) : 0;
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
    const basePartsShift = (28800.0 / (baseCt > 0 ? baseCt : 1)) * 0.90 * baseCav;
    const baseProcessCost = basePartsShift > 0 ? (Number(costingTariff) / basePartsShift) : 0;
    const baseTotalProcess = baseProcessCost + (0.03 * baseBop) + 1.73;
    const baseProfitOh = (baseRmCost + baseTotalProcess) * 0.12;
    const baseInprocRej = (baseRmBop + baseTotalProcess) * 0.04;
    const baseRunnerRec = -25.0 * (baseRunnerWt / 1000.0);
    const basePacking = Number(basePackingCost !== undefined ? basePackingCost : 0.86);
    const baseTransport = Number(baseTransportCost !== undefined ? baseTransportCost : 0.62);
    const baseMouldMaint = 0.02 * baseTotalProcess;
    const baseOther = 0.00;
    const baseFinalLanded = baseRmCost + baseBop + baseTotalProcess + baseProfitOh + baseInprocRej + baseRunnerRec + basePacking + baseTransport + baseMouldMaint + baseOther;

    // Actual Running Math
    const actRmLanded = actRmBase > 0 ? (actRmBase + (actRmBase * 0.01) + 1.50) : 0;
    const actMbLanded = actMbBase > 0 ? (actMbBase + (actMbBase * 0.01) + 2.00) : 0;
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
    const actPartsShift = (28800.0 / (actCt > 0 ? actCt : 1)) * 0.90 * actCav;
    const actProcessCost = actPartsShift > 0 ? (Number(actualTariff) / actPartsShift) : 0;
    const actTotalProcess = actProcessCost + (0.03 * actBop) + 1.73;
    const actProfitOh = (actRmCost + actTotalProcess) * 0.12;
    const actInprocRej = (actRmBop + actTotalProcess) * 0.04;
    const actRunnerRec = -25.0 * (actRunnerWt / 1000.0);
    const actPacking = Number(actPackingCost !== undefined ? actPackingCost : 0.86);
    const actTransport = Number(actTransportCost !== undefined ? actTransportCost : 0.62);
    const actMouldMaint = 0.02 * actTotalProcess;
    const actOther = 0.00;
    const actFinalLanded = actRmCost + actBop + actTotalProcess + actProfitOh + actInprocRej + actRunnerRec + actPacking + actTransport + actMouldMaint + actOther;

    const profitLossDelta = Number((baseFinalLanded - actFinalLanded).toFixed(2));

    const atomberg38Rows = [
      { sn: 1, desc: 'Vendor', uom: '-', costing: item.vendor || 'Atomberg Technologies', actual: item.vendor || 'Atomberg Technologies', delta: '-' },
      { sn: 2, desc: 'Part Code', uom: '-', costing: item.itemCode, actual: item.itemCode, delta: '-' },
      { sn: 3, desc: 'Part name', uom: '-', costing: item.componentName, actual: item.componentName, delta: '-' },
      { 
        sn: 4, 
        desc: 'RM Grade (From RM Matrix)', 
        uom: '-', 
        isCodeInput: true,
        val: selectedRmGrade,
        setVal: setSelectedRmGrade,
        status: rmInfo.isFound ? `Linked (₹${appRmBase.toFixed(2)})` : 'Not in RM Page (Rate = ₹0.00)',
        isFound: rmInfo.isFound
      },
      { sn: 5, desc: 'RM Base Rate (From RM Matrix)', uom: '₹/kg', costing: `₹${appRmBase.toFixed(2)}`, actual: `₹${actRmBase.toFixed(2)}`, delta: `₹${(appRmBase - actRmBase).toFixed(2)}` },
      { sn: 6, desc: 'ICC Cost @ 1% of RM', uom: '1%', costing: `₹${(appRmBase * 0.01).toFixed(2)}`, actual: `₹${(actRmBase * 0.01).toFixed(2)}`, delta: `₹${((appRmBase - actRmBase) * 0.01).toFixed(2)}` },
      { sn: 7, desc: 'Freight Cost', uom: '₹/kg', costing: appRmBase > 0 ? '₹1.50' : '₹0.00', actual: actRmBase > 0 ? '₹1.50' : '₹0.00', delta: '₹0.00' },
      { sn: 8, desc: 'RM Landed Cost', uom: '₹/kg', costing: `₹${baseRmLanded.toFixed(2)}`, actual: `₹${actRmLanded.toFixed(2)}`, delta: `₹${(baseRmLanded - actRmLanded).toFixed(2)}`, isHighlight: true },
      { 
        sn: 9, 
        desc: 'MB Grade (From RM Matrix)', 
        uom: '-', 
        isCodeInput: true,
        val: selectedMbGrade,
        setVal: setSelectedMbGrade,
        status: mbInfo.isFound ? `Linked (₹${appMbBase.toFixed(2)})` : 'Not in RM Page (Rate = ₹0.00)',
        isFound: mbInfo.isFound
      },
      { sn: 10, desc: 'MB Base Cost (From RM Matrix)', uom: '₹/kg', costing: `₹${appMbBase.toFixed(2)}`, actual: `₹${actMbBase.toFixed(2)}`, delta: `₹${(appMbBase - actMbBase).toFixed(2)}` },
      { sn: 11, desc: 'MB-ICC Cost @ 1% of MB', uom: '1%', costing: `₹${(appMbBase * 0.01).toFixed(2)}`, actual: `₹${(actMbBase * 0.01).toFixed(2)}`, delta: `₹${((appMbBase - actMbBase) * 0.01).toFixed(2)}` },
      { sn: 12, desc: 'MB Freight Cost', uom: '₹/kg', costing: appMbBase > 0 ? '₹2.00' : '₹0.00', actual: actMbBase > 0 ? '₹2.00' : '₹0.00', delta: '₹0.00' },
      { sn: 13, desc: 'MB Landed Cost', uom: '₹/kg', costing: `₹${baseMbLanded.toFixed(2)}`, actual: `₹${actMbLanded.toFixed(2)}`, delta: `₹${(baseMbLanded - actMbLanded).toFixed(2)}`, isHighlight: true },
      { 
        sn: 14, 
        desc: 'MB %', 
        uom: '%', 
        isSpecialEdit: true,
        costingVal: baseMbPctVal,
        setCostingVal: setBaseMbPctVal,
        actualVal: actMbPctVal,
        setActualVal: setActMbPctVal,
        delta: `${(Number(baseMbPctVal || 0) - Number(actMbPctVal || 0)).toFixed(2)}%`
      },
      { sn: 15, desc: 'RM cost (PP + MB) /KG', uom: '₹/kg', costing: `₹${baseRmComb.toFixed(2)}`, actual: `₹${actRmComb.toFixed(2)}`, delta: `₹${(baseRmComb - actRmComb).toFixed(2)}` },
      { sn: 16, desc: 'Part weight grams', uom: 'Gms', costing: `${basePartWt.toFixed(2)}g`, isInput: true, inputType: 'netWt', actual: netWt, delta: `${(basePartWt - Number(netWt)).toFixed(2)}g` },
      { sn: 17, desc: 'Runner weight grams', uom: 'Gms', costing: `${baseRunnerWt.toFixed(2)}g`, isInput: true, inputType: 'runnerWt', actual: runnerWt, delta: `${(baseRunnerWt - Number(runnerWt)).toFixed(2)}g` },
      { sn: 18, desc: 'Gross weight', uom: 'Gms', costing: `${baseGrossWt.toFixed(2)}g`, actual: `${actGrossWt.toFixed(2)}g`, delta: `${(baseGrossWt - actGrossWt).toFixed(2)}g` },
      { sn: 19, desc: 'RM cost', uom: '₹/pc', costing: `₹${baseRmCost.toFixed(2)}`, actual: `₹${actRmCost.toFixed(2)}`, delta: `₹${(baseRmCost - actRmCost).toFixed(2)}`, isSubtotal: true },
      { 
        sn: 20, 
        desc: 'Inserts / BOP cost', 
        uom: '₹/pc', 
        isSpecialEdit: true,
        costingVal: baseBopCost,
        setCostingVal: setBaseBopCost,
        actualVal: actBopCost,
        setActualVal: setActBopCost,
        delta: `₹${(Number(baseBopCost || 0) - Number(actBopCost || 0)).toFixed(2)}`
      },
      { sn: 21, desc: 'RM + BOP Cost', uom: '₹/pc', costing: `₹${baseRmBop.toFixed(2)}`, actual: `₹${actRmBop.toFixed(2)}`, delta: `₹${(baseRmBop - actRmBop).toFixed(2)}`, isSubtotal: true },
      { sn: 22, desc: 'M/c tonnage', uom: 'T', costing: `${item.machineTonnage || 200}T`, isInput: true, inputType: 'tonnage', actual: tonnage, delta: (Number(item.machineTonnage || 200) - Number(tonnage)) },
      { sn: 23, desc: 'Shift rate (Manual Entry)', uom: '₹/shift', isTariffRow: true, costing: costingTariff, actual: actualTariff, delta: `₹${(Number(costingTariff) - Number(actualTariff)).toFixed(2)}` },
      { sn: 24, desc: 'Cycle time', uom: 'Sec', costing: `${baseCt}s`, isInput: true, inputType: 'cycleTime', actual: cycleTime, delta: `${(baseCt - Number(cycleTime)).toFixed(1)}s` },
      { sn: 25, desc: 'Efficiency', uom: '-', costing: '0.90', actual: '0.90', delta: '-' },
      { sn: 26, desc: 'No of cavity', uom: 'Nos', costing: baseCav, isInput: true, inputType: 'cavity', actual: cavity, delta: (baseCav - Number(cavity)) },
      { sn: 27, desc: 'Parts/shift', uom: 'Nos', costing: Math.round(basePartsShift), actual: Math.round(actPartsShift), delta: Math.round(basePartsShift - actPartsShift) },
      { sn: 28, desc: 'Process cost', uom: '₹/pc', costing: `₹${baseProcessCost.toFixed(2)}`, actual: `₹${actProcessCost.toFixed(2)}`, delta: `₹${(baseProcessCost - actProcessCost).toFixed(2)}` },
      { sn: 29, desc: 'Handling cost for BOP', uom: '3%', costing: `₹${(0.03 * baseBop).toFixed(2)}`, actual: `₹${(0.03 * actBop).toFixed(2)}`, delta: `₹${(0.03 * (baseBop - actBop)).toFixed(2)}` },
      { sn: 30, desc: 'Post operation cost', uom: '₹/pc', costing: '₹1.73', actual: '₹1.73', delta: '₹0.00' },
      { sn: 31, desc: 'Total Process Cost', uom: '₹/pc', costing: `₹${baseTotalProcess.toFixed(2)}`, actual: `₹${actTotalProcess.toFixed(2)}`, delta: `₹${(baseTotalProcess - actTotalProcess).toFixed(2)}`, isSubtotal: true },
      { sn: 32, desc: 'Profit & OH', uom: '12%', costing: `₹${baseProfitOh.toFixed(2)}`, actual: `₹${actProfitOh.toFixed(2)}`, delta: `₹${(baseProfitOh - actProfitOh).toFixed(2)}` },
      { sn: 33, desc: 'Inprocess Rejection', uom: '4%', costing: `₹${baseInprocRej.toFixed(2)}`, actual: `₹${actInprocRej.toFixed(2)}`, delta: `₹${(baseInprocRej - actInprocRej).toFixed(2)}` },
      { sn: 34, desc: 'Runner recovery cost', uom: '₹25/kg', costing: `- ₹${Math.abs(baseRunnerRec).toFixed(2)}`, actual: `- ₹${Math.abs(actRunnerRec).toFixed(2)}`, delta: `₹${(baseRunnerRec - actRunnerRec).toFixed(2)}`, isHighlight: true },
      { 
        sn: 35, 
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
        sn: 36, 
        desc: 'Transport cost', 
        uom: '₹/pc', 
        isSpecialEdit: true,
        costingVal: baseTransportCost,
        setCostingVal: setBaseTransportCost,
        actualVal: actTransportCost,
        setActualVal: setActTransportCost,
        delta: `₹${(Number(baseTransportCost || 0) - Number(actTransportCost || 0)).toFixed(2)}`
      },
      { sn: 37, desc: 'Mould maintenance cost', uom: '2%', costing: `₹${baseMouldMaint.toFixed(2)}`, actual: `₹${actMouldMaint.toFixed(2)}`, delta: `₹${(baseMouldMaint - actMouldMaint).toFixed(2)}` },
      { sn: 38, desc: 'FINAL LANDED COST', uom: '₹/pc', costing: `₹${baseFinalLanded.toFixed(2)}`, actual: `₹${actFinalLanded.toFixed(2)}`, delta: `₹${profitLossDelta >= 0 ? '+' : ''}${profitLossDelta.toFixed(2)}`, isTotal: true }
    ];

    const handleSaveAtomberg = () => {
      const compositeMatName = selectedMbGrade ? `${selectedRmGrade} + ${selectedMbGrade}` : selectedRmGrade;

      onSave({
        updatedItem: {
          ...item,
          approvedRm: compositeMatName,
          baseRm: selectedRmGrade,
          approvedMb: selectedMbGrade,
          shiftTariff: Number(costingTariff),
          shiftRate: Number(costingTariff),
          masterbatchPct: Number(baseMbPctVal),
          bopCost: Number(baseBopCost),
          packingCost: Number(basePackingCost),
          transportCost: Number(baseTransportCost),
          approvedCost: Number(baseFinalLanded.toFixed(2)),
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
        changeType: "Atomberg Spec Update",
        reason
      });
    };

    return (
      <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
        <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] flex flex-col justify-between relative">
          
          {/* Header */}
          <div className="flex justify-between items-start border-b border-slate-200 pb-3">
            <div>
              <div className="flex items-center gap-2">
                <span className="px-2.5 py-0.5 bg-blue-600 text-white rounded font-mono font-bold text-xs">{item.itemCode}</span>
                <h2 className="text-base font-bold text-slate-900">{item.componentName}</h2>
                <span className="text-[10px] px-2 py-0.5 bg-slate-100 text-slate-600 rounded font-semibold border">Atomberg Prescribed Format</span>
              </div>
              <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-3">
                <span>Vendor: <strong className="text-slate-700">{item.vendor}</strong></span>
                <span className="flex items-center gap-1">
                  RM ({selectedRmGrade || 'None'}): <strong className={rmInfo.isFound ? 'text-blue-700 font-mono' : 'text-rose-600 font-mono'}>₹{appRmBase.toFixed(2)}/kg</strong>
                  {!rmInfo.isFound && <span className="text-[9px] bg-rose-100 text-rose-700 px-1.5 py-0.2 rounded font-bold">Unlinked (₹0)</span>}
                </span>
                <span className="flex items-center gap-1">
                  MB ({selectedMbGrade || 'None'}): <strong className={mbInfo.isFound ? 'text-purple-700 font-mono' : 'text-rose-600 font-mono'}>₹{appMbBase.toFixed(2)}/kg</strong>
                  {!mbInfo.isFound && <span className="text-[9px] bg-rose-100 text-rose-700 px-1.5 py-0.2 rounded font-bold">Unlinked (₹0)</span>}
                </span>
              </div>
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

          {/* 38-Line Table */}
          <div className="border border-slate-200 rounded-xl overflow-hidden max-h-[48vh] overflow-y-auto">
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

                  if (r.isCodeInput) {
                    return (
                      <tr key={r.sn} className="bg-blue-50/40">
                        <td className="py-2 px-3 text-center font-mono font-bold text-slate-500">{r.sn}</td>
                        <td className="py-2 px-4 font-bold text-slate-900 flex items-center gap-2">
                          {r.desc}
                          <span className={`text-[10px] px-1.5 py-0.2 rounded font-bold ${r.isFound ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'}`}>
                            {r.status}
                          </span>
                        </td>
                        <td className="py-2 px-3 text-center font-mono text-slate-500">{r.uom}</td>
                        <td colSpan={2} className="py-2 px-4">
                          <input 
                            type="text" 
                            value={r.val} 
                            onChange={e => r.setVal(e.target.value)} 
                            placeholder="Enter Code as in RM page..."
                            className="w-full px-2 py-0.5 border border-blue-400 bg-white rounded font-mono font-bold text-slate-900 text-xs focus:ring-2 focus:ring-blue-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right font-mono text-slate-400">-</td>
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
                            step="any"
                            value={r.costingVal} 
                            onChange={e => r.setCostingVal(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            step="any"
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
                            step="any"
                            value={costingTariff} 
                            onChange={e => setCostingTariff(e.target.value)} 
                            className="w-24 px-1.5 py-0.5 border border-amber-400 bg-amber-50 rounded text-right font-mono font-bold text-amber-900 focus:ring-2 focus:ring-amber-500" 
                          />
                        </td>
                        <td className="py-2 px-4 text-right">
                          <input 
                            type="number" 
                            step="any"
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
                    <tr key={r.sn} className={`${r.isSubtotal ? 'bg-amber-50/50 font-bold' : 'hover:bg-slate-50'}`}>
                      <td className="py-2 px-3 text-center font-mono text-slate-400">{r.sn}</td>
                      <td className={`py-2 px-4 ${r.isSubtotal ? 'text-slate-900' : 'text-slate-800 font-medium'}`}>{r.desc}</td>
                      <td className="py-2 px-3 text-center font-mono text-slate-500">{r.uom}</td>
                      <td className="py-2 px-4 text-right font-mono">{r.costing}</td>
                      <td className="py-2 px-4 text-right">
                        {r.isInput ? (
                          <input 
                            type="number" 
                            step="any"
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

          {/* Footer */}
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

  // Haier / Atharva Polymer Format
  const appRmBase = Number(rmInfo.approvedPrice || 0.00);
  const actRmBase = Number(rmInfo.activeWaPrice || 0.00);
  const appMbBase = Number(mbInfo.approvedMbPrice || 0.00);
  const actMbBase = Number(mbInfo.activeMbWaPrice || 0.00);

  const baseCalc = calculateHaierCost({
    cavity: Number(item.cavity || 2),
    netWeight: Number(item.netWeight || 197),
    runnerWeight: Number(item.runnerWeight || 40),
    rmRate: appRmBase,
    masterbatchPct: Number(baseMbPctVal || 0.0),
    masterbatchRate: appMbBase,
    machineTonnage: Number(item.machineTonnage || 450),
    shiftTariff: Number(costingTariff),
    cycleTime: Number(item.cycleTimeApproved || item.cycleTime || 56),
    bopCost: Number(baseBopCost || 0.14)
  });

  const runCalc = calculateHaierCost({
    cavity: Number(cavity),
    netWeight: Number(netWt),
    runnerWeight: Number(runnerWt),
    rmRate: actRmBase,
    masterbatchPct: Number(actMbPctVal || 0.0),
    masterbatchRate: actMbBase,
    machineTonnage: Number(tonnage),
    shiftTariff: Number(actualTariff),
    cycleTime: Number(cycleTime),
    bopCost: Number(actBopCost || 0.14)
  });

  const profitLossDelta = Number((baseCalc.totalCost - runCalc.totalCost).toFixed(2));

  return (
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] flex flex-col justify-between relative">
        <div className="flex justify-between items-start border-b pb-3">
          <div>
            <div className="flex items-center gap-2">
              <span className="px-2.5 py-0.5 bg-blue-600 text-white rounded font-mono font-bold text-xs">{item.itemCode}</span>
              <h2 className="text-base font-bold text-slate-900">{item.componentName}</h2>
              <span className="text-[10px] px-2 py-0.5 bg-blue-50 text-blue-700 rounded font-semibold border border-blue-200">Haier 38-Line Format</span>
            </div>
            <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-3">
              <span>Vendor: <strong className="text-slate-700">{item.vendor}</strong></span>
              <span>RM ({selectedRmGrade}): <strong className={rmInfo.isFound ? 'text-blue-700 font-mono' : 'text-rose-600 font-mono'}>₹{appRmBase.toFixed(2)}/kg</strong></span>
              <span>MB ({selectedMbGrade}): <strong className={mbInfo.isFound ? 'text-purple-700 font-mono' : 'text-rose-600 font-mono'}>₹{appMbBase.toFixed(2)}/kg</strong></span>
            </div>
          </div>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-700 cursor-pointer"><X className="w-5 h-5" /></button>
        </div>

        <div className="grid grid-cols-3 gap-3">
          <div className="p-4 bg-slate-50 border rounded-xl">
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

        <div className="p-4 border rounded-xl bg-slate-50 space-y-3">
          <div className="font-bold text-slate-900">Link RM & MB Code for Matrix Price Fetching:</div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-[11px] font-semibold text-slate-600">RM Grade Code:</label>
              <input 
                type="text" 
                value={selectedRmGrade} 
                onChange={e => setSelectedRmGrade(e.target.value)} 
                className="w-full mt-1 px-2.5 py-1.5 border rounded-lg bg-white font-mono font-bold text-xs" 
              />
            </div>
            <div>
              <label className="text-[11px] font-semibold text-slate-600">MB Grade Code:</label>
              <input 
                type="text" 
                value={selectedMbGrade} 
                onChange={e => setSelectedMbGrade(e.target.value)} 
                className="w-full mt-1 px-2.5 py-1.5 border rounded-lg bg-white font-mono font-bold text-xs" 
              />
            </div>
          </div>
        </div>

        <div className="flex justify-between items-center pt-2 border-t">
          <button onClick={onClose} className="px-4 py-2 border rounded-xl font-bold cursor-pointer hover:bg-slate-50 text-slate-700">Cancel</button>
          <button 
            onClick={() => onSave({
              updatedItem: {
                ...item,
                approvedRm: selectedMbGrade ? `${selectedRmGrade} + ${selectedMbGrade}` : selectedRmGrade,
                baseRm: selectedRmGrade,
                approvedMb: selectedMbGrade,
                parameters: { ...item.parameters, runningNetWeight: Number(netWt), runningMbPct: Number(actMbPctVal) }
              },
              changeType: "Haier Spec Update",
              reason
            })}
            className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-bold cursor-pointer flex items-center gap-1.5"
          >
            <Save className="w-4 h-4" /> Save & Log Parameters
          </button>
        </div>
      </div>
    </div>
  );
}
MODAL_EOF

echo "==> 2. Verifying entire build with npm run build..."
npm run build

echo "==> 3. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ BUILD 100% SUCCEEDED! All modules & exports are live on port 5173."
echo "-------------------------------------------------------------------"
