import React, { useState } from 'react';
import { X, CheckCircle2, FileSpreadsheet } from 'lucide-react';
import { getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';

export default function StagingModal({ isOpen, onClose, stagedProducts = [], onConfirm }) {
  if (!isOpen || !stagedProducts || stagedProducts.length === 0) return null;

  const [activeIdx, setActiveIdx] = useState(0);
  const [productsData, setProductsData] = useState(() => 
    stagedProducts.map(p => ({
      ...p,
      vendor: p.vendor || 'Haier',
      cavity: Number(p.cavity ?? 2),
      runnerWeight: Number(p.runnerWeight ?? 40),
      netWeight: Number(p.netWeight ?? 197),
      cycleTime: Number(p.cycleTime ?? 56),
      machineTonnage: Number(p.machineTonnage ?? 450),
      shiftTariff: Number(p.shiftTariff ?? 3600),
      bopCost: Number(p.bopCost ?? 0.14),
      masterbatchPct: Number(p.masterbatchPct ?? 0),
      approvedRmRate: Number(p.approvedRmRate ?? 136.20),
      approvedRm: p.approvedRm || 'ABS 300 Pre Colour'
    }))
  );

  const current = productsData[activeIdx] || productsData[0];

  const handleFieldChange = (field, val) => {
    const num = Number(val);
    setProductsData(prev => {
      const copy = [...prev];
      copy[activeIdx] = {
        ...copy[activeIdx],
        [field]: isNaN(num) ? val : num
      };
      return copy;
    });
  };

  // --------------------------------------------------------------------------
  // EXACT 38-LINE HAIER COSTING EVALUATION MATCHING UPLOADED SHEET
  // --------------------------------------------------------------------------
  const rmInfo = getActiveRmMapping(current.approvedRm, current.vendor || 'Haier', '2026-08-01');
  const mbInfo = getActiveMbMapping(current.vendor || 'Haier', '2026-08-01');

  const cav = Number(current.cavity || 2);
  const nw = Number(current.netWeight || 197);
  const rw = Number(current.runnerWeight || 40);
  const ct = Number(current.cycleTime || 56);
  const st = Number(current.shiftTariff || 3600);
  const bop = Number(current.bopCost || 0.14);
  const mbPct = Number(current.masterbatchPct || 0);

  const rmBaseRate = Number(current.approvedRmRate || rmInfo.approvedPrice || 136.20);
  const mbBaseRate = Number(mbInfo.approvedMbPrice || 0);

  const shotWeight = (nw * cav) + rw;
  const partShotWeight = shotWeight / (cav > 0 ? cav : 1);
  const reconciliationWeight = nw * 1.01;
  const mbWeight = (partShotWeight * mbPct) / 100;
  const baseRmWeight = partShotWeight - mbWeight;

  const rawMaterialCost = (partShotWeight * rmBaseRate) / 1000;
  const masterBatchCost = (mbWeight * mbBaseRate) / 1000;
  const scrapRecovery = (rw / (cav > 0 ? cav : 1) / 1000) * (rmBaseRate * 0.25);
  const totalRawMaterialCost = rawMaterialCost + masterBatchCost - scrapRecovery;

  const shotsPerShift = ct > 0 ? (8 * 3600) / ct : 0;
  const shotsWithEff = shotsPerShift * 0.95;
  const partsPerShift = shotsWithEff * cav;
  const prodCostPerPc = partsPerShift > 0 ? (st / partsPerShift) : 0;

  const subTotal = totalRawMaterialCost + prodCostPerPc;
  const line24OH = subTotal * 0.175; // 17.50% OH + Profit + Freight
  const line36Icc = -0.13;
  const line37Scrap = -scrapRecovery;

  const computedTotalCost = subTotal + line24OH + bop + line36Icc + line37Scrap;

  // Complete sequential 38-line representation matching your template
  const haier38Lines = [
    { sn: 1, desc: 'Name Of component', uom: '-', val: current.componentName || 'End Cap Top Ref (without Screen Painting)', editable: false },
    { sn: 2, desc: 'Mould size L x W x H', uom: 'mm', val: current.mouldSize || '1070*720*650', editable: false },
    { sn: 3, desc: 'Item No. / Part Code', uom: '-', val: current.itemCode, editable: false },
    { sn: 4, desc: 'Model', uom: '-', val: current.model || 'OLD DC- 195,220', editable: false },
    { sn: 5, desc: 'Raw Material Required', uom: '-', val: current.approvedRm || 'ABS 300 Pre Colour', editable: false },
    { sn: 6, desc: 'Master Batch Required (%)', uom: '%', val: mbPct, field: 'masterbatchPct', editable: true },
    { sn: 7, desc: 'No. of Cavity', uom: 'Nos', val: cav, field: 'cavity', editable: true },
    { sn: 8, desc: 'Runner Weight', uom: 'Gms', val: rw, field: 'runnerWeight', editable: true },
    { sn: 9, desc: 'Net Weight', uom: 'Gms', val: nw, field: 'netWeight', editable: true },
    { sn: 10, desc: 'Shot Weight', uom: 'Gms', val: `${shotWeight.toFixed(2)}g`, editable: false },
    { sn: 11, desc: 'Reconciliation Weight = Shot wt + 1.0% Melt Loss', uom: 'Gms', val: `${reconciliationWeight.toFixed(2)}g`, editable: false },
    { sn: 12, desc: 'Raw Material Cost', uom: 'Rs', val: `₹${rawMaterialCost.toFixed(2)}`, editable: false },
    { sn: 13, desc: 'Master batch cost', uom: 'Rs', val: `₹${masterBatchCost.toFixed(2)}`, editable: false },
    { sn: 14, desc: 'Runner recovery % (Scrap Credit)', uom: '-', val: `${scrapRecovery.toFixed(2)}`, editable: false },
    { sn: 15, desc: 'Total Raw Material Cost', uom: 'Rs', val: `₹${totalRawMaterialCost.toFixed(2)}`, editable: false },
    { sn: 16, desc: 'Machine Used (Tonnage)', uom: 'T', val: current.machineTonnage || 450, field: 'machineTonnage', editable: true },
    { sn: 17, desc: 'Machine Tariff per Shift', uom: 'Rs', val: `₹${st}`, field: 'shiftTariff', editable: true },
    { sn: 18, desc: 'Cycle Time', uom: 'Sec', val: ct, field: 'cycleTime', editable: true },
    { sn: 19, desc: 'No of Shot / Shift (8Hour)', uom: 'Nos', val: Math.round(shotsPerShift), editable: false },
    { sn: 20, desc: 'No of Shot / Shift with 95% Efficiency', uom: 'Nos', val: Math.round(shotsWithEff), editable: false },
    { sn: 21, desc: 'No. of component / shift', uom: 'Nos', val: Math.round(partsPerShift), editable: false },
    { sn: 22, desc: 'Production Cost / Pc', uom: 'Rs', val: `₹${prodCostPerPc.toFixed(2)}`, editable: false },
    { sn: 23, desc: 'SUB TOTAL', uom: 'Rs', val: `₹${subTotal.toFixed(2)}`, editable: false },
    { sn: 24, desc: 'OH + Profit + ICC + Rejection + Foam/Polybag + Freight Cost', uom: 'Rs', val: `₹${line24OH.toFixed(2)}`, editable: false },
    { sn: 25, desc: 'Foam / Polybag / Masking film', uom: 'Rs', val: '-', editable: false },
    { sn: 26, desc: 'Plastic Bin / Polyenda Box / Trolley', uom: 'Rs', val: '-', editable: false },
    { sn: 27, desc: 'Freight Cost', uom: 'Rs', val: '-', editable: false },
    { sn: 28, desc: 'Secondary Operation 1', uom: 'Rs', val: '-', editable: false },
    { sn: 29, desc: 'Secondary Operation 2', uom: 'Rs', val: '-', editable: false },
    { sn: 30, desc: 'Screen printing - 1st stroke', uom: 'Rs', val: '-', editable: false },
    { sn: 31, desc: 'Screen printing - 2nd stroke', uom: 'Rs', val: '-', editable: false },
    { sn: 32, desc: 'Assembly Cost', uom: 'Rs', val: '-', editable: false },
    { sn: 33, desc: 'Insert / Hinge hole cap cost / Other cost', uom: 'Rs', val: bop, field: 'bopCost', editable: true },
    { sn: 34, desc: 'Mould Maintenance Provision', uom: 'Rs', val: '-', editable: false },
    { sn: 35, desc: 'Quality Inspection Cost', uom: 'Rs', val: '-', editable: false },
    { sn: 36, desc: 'ICC Reduce by .5% (Payment term change From 60 to 45 days)', uom: 'Rs', val: `₹${line36Icc.toFixed(2)}`, editable: false },
    { sn: 37, desc: 'Scrap Recovery Adjustment', uom: 'Rs', val: `₹${line37Scrap.toFixed(2)}`, editable: false },
    { sn: 38, desc: 'TOTAL COST', uom: 'Rs', val: `₹${computedTotalCost.toFixed(2)}`, isTotal: true }
  ];

  const handleFinalConfirm = () => {
    onConfirm(productsData.map(p => ({
      ...p,
      approvedCost: Number(computedTotalCost.toFixed(2))
    })));
  };

  return (
    <div className="fixed inset-0 bg-slate-900/80 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs font-sans">
      <div className="bg-white rounded-2xl shadow-2xl max-w-5xl w-full p-5 space-y-4 border border-slate-300 max-h-[94vh] flex flex-col justify-between">
        
        {/* Header */}
        <div className="flex justify-between items-start border-b border-slate-200 pb-3">
          <div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="w-5 h-5 text-emerald-600" />
              <h2 className="text-base font-bold text-slate-900">
                Staging & Verification: {current.vendor || 'Haier'} Product Import ({productsData.length} Staged Parts)
              </h2>
            </div>
            <p className="text-[11px] text-slate-500 mt-0.5">
              Review full vertical 38-line costing format and make inline parameter corrections before final confirmation.
            </p>
          </div>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-100 text-slate-400 hover:text-slate-700 cursor-pointer">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab Switcher */}
        <div className="flex items-center gap-2 overflow-x-auto pb-1">
          {productsData.map((p, idx) => (
            <button
              key={idx}
              onClick={() => setActiveIdx(idx)}
              className={`px-3 py-1.5 rounded-lg text-xs font-bold font-mono transition-all cursor-pointer whitespace-nowrap ${
                activeIdx === idx 
                  ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' 
                  : 'bg-slate-100 hover:bg-slate-200 text-slate-700'
              }`}
            >
              {p.itemCode}: {p.componentName}
            </button>
          ))}
        </div>

        {/* Staged Component Header Summary */}
        <div className="p-3 bg-slate-50 rounded-xl border border-slate-200 flex justify-between items-center">
          <div>
            <div className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">STAGED COMPONENT & ITEM CODE</div>
            <div className="text-sm font-bold text-slate-900 font-mono">[{current.itemCode}] {current.componentName}</div>
          </div>
          <div className="text-right">
            <div className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">COMPUTED STAGED TOTAL COST</div>
            <div className="text-xl font-black text-emerald-600 font-mono">₹{computedTotalCost.toFixed(2)}</div>
          </div>
        </div>

        {/* Full Sequential 38-Line Table */}
        <div className="border border-slate-200 rounded-xl overflow-y-auto max-h-[50vh]">
          <table className="w-full text-left border-collapse text-xs">
            <thead className="sticky top-0 bg-slate-100 z-10 shadow-xs">
              <tr className="text-[10px] uppercase font-bold text-slate-600 border-b border-slate-200">
                <th className="py-2.5 px-3 w-12 text-center">#</th>
                <th className="py-2.5 px-4">Description / Costing Line</th>
                <th className="py-2.5 px-3 text-center w-20">UOM</th>
                <th className="py-2.5 px-4 text-right w-52">Staged Value (Editable)</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {haier38Lines.map((row) => (
                <tr 
                  key={row.sn} 
                  className={`${row.isTotal ? 'bg-slate-900 text-white font-bold' : 'hover:bg-slate-50'}`}
                >
                  <td className={`py-2 px-3 text-center font-mono ${row.isTotal ? 'text-amber-400 font-bold' : 'text-slate-400 font-bold'}`}>
                    {row.sn}
                  </td>
                  <td className={`py-2 px-4 ${row.isTotal ? 'text-amber-300 uppercase tracking-wider font-black' : 'font-medium text-slate-800'}`}>
                    {row.desc}
                  </td>
                  <td className={`py-2 px-3 text-center font-mono ${row.isTotal ? 'text-slate-300' : 'text-slate-500'}`}>
                    {row.uom}
                  </td>
                  <td className="py-2 px-4 text-right">
                    {row.editable ? (
                      <input 
                        type="number"
                        value={row.val}
                        onChange={(e) => handleFieldChange(row.field, e.target.value)}
                        className="w-24 px-2 py-0.5 text-right font-mono font-bold bg-blue-50 border border-blue-400 rounded-lg text-blue-900 outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    ) : (
                      <span className={`font-mono font-bold ${row.isTotal ? 'text-amber-300 text-sm' : 'text-slate-700'}`}>
                        {row.val}
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Footer */}
        <div className="flex justify-between items-center pt-2 border-t border-slate-200">
          <button
            onClick={onClose}
            className="px-4 py-2 text-xs font-bold text-slate-600 hover:bg-slate-100 rounded-xl transition-all cursor-pointer"
          >
            Cancel Staging
          </button>
          <button
            onClick={handleFinalConfirm}
            className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold px-5 py-2.5 rounded-xl transition-all shadow-md shadow-emerald-600/20 cursor-pointer"
          >
            <CheckCircle2 className="w-4 h-4" /> Confirm & Add All Staged Products ({productsData.length})
          </button>
        </div>

      </div>
    </div>
  );
}
