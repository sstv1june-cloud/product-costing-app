import React, { useState, useEffect, useMemo } from 'react';
import { 
  Building2, Layers, Sliders, DollarSign, BarChart3, Bot, 
  TrendingUp, TrendingDown, CheckCircle2, UserPlus, Upload, FileSpreadsheet, X, Check
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, onboardVendorWithBlueprint, getActiveRmMapping, getActiveMbMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function DashboardPage({ onNavigate }) {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Atomberg');
  const [showOnboardModal, setShowOnboardModal] = useState(false);
  const [onboardStep, setOnboardStep] = useState(1);
  const [successMsg, setSuccessMsg] = useState(null);

  const [newVendorData, setNewVendorData] = useState({
    vendorName: '',
    vendorCode: '',
    paymentTerms: '45 Days',
    currency: 'INR (₹)'
  });

  const [uploadedFileName, setUploadedFileName] = useState('');
  const [sheetName, setSheetName] = useState('');
  const [stagedLines, setStagedLines] = useState([]);
  const [stagedProduct, setStagedProduct] = useState({});

  const vendors = globalStore.vendors || [];
  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];

  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const dashboardStats = useMemo(() => {
    let totalRev = 0;
    let totalGain = 0;
    let totalQty = 0;

    vendorProducts.forEach(part => {
      const params = part.parameters || {};
      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor || selectedVendor, '2026-08-01');
      const mbMapping = getActiveMbMapping(part.vendor || selectedVendor, '2026-08-01');

      const baseSpec = {
        vendor: part.vendor,
        rmBase: Number(rmMapping.approvedPrice || part.approvedRmRate || 140.00),
        rmRate: Number(rmMapping.approvedPrice || part.approvedRmRate || 140.00),
        mbBase: Number(mbMapping.approvedMbPrice || part.masterbatchRate || 254.00),
        masterbatchRate: Number(mbMapping.approvedMbPrice || part.masterbatchRate || 254.00),
        mbPct: Number((part.masterbatchPct ?? params.masterbatchPct ?? 4.0) / 100),
        masterbatchPct: Number(part.masterbatchPct ?? params.masterbatchPct ?? 4.0),
        partWt: Number(part.netWeight ?? params.netWeightApproved ?? 37),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 37),
        runnerWt: Number(part.runnerWeight ?? params.runnerWeight ?? 1),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 1),
        bopCost: Number(part.bopCost || params.bopCost || 0.0),
        tonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 200),
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 200),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 2000)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 47),
        cavity: Number(part.cavity ?? params.cavity ?? 2)
      };
      const baselineCalc = calculateDetailedCost(baseSpec, true);

      const runningSpec = {
        vendor: part.vendor,
        rmBase: Number(rmMapping.activeWaPrice || baseSpec.rmBase),
        rmRate: Number(rmMapping.activeWaPrice || baseSpec.rmRate),
        mbBase: Number(mbMapping.activeMbPrice || baseSpec.mbBase),
        masterbatchRate: Number(mbMapping.activeMbPrice || baseSpec.masterbatchRate),
        mbPct: Number((params.runningMbPct !== undefined ? params.runningMbPct : baseSpec.masterbatchPct) / 100),
        masterbatchPct: Number(params.runningMbPct ?? baseSpec.masterbatchPct),
        partWt: Number(params.runningNetWeight ?? baseSpec.partWt),
        netWeight: Number(params.runningNetWeight ?? baseSpec.netWeight),
        runnerWt: Number(params.runningRunnerWeight ?? baseSpec.runnerWt),
        runnerWeight: Number(params.runningRunnerWeight ?? baseSpec.runnerWeight),
        bopCost: Number(params.runningBopCost ?? baseSpec.bopCost),
        tonnage: Number(params.runningTonnage ?? baseSpec.tonnage),
        machineTonnage: Number(params.runningTonnage ?? baseSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? baseSpec.shiftTariff),
        cycleTime: Number(params.runningCycleTime ?? baseSpec.cycleTime),
        cavity: Number(params.runningCavity ?? baseSpec.cavity)
      };
      const runningCalc = calculateDetailedCost(runningSpec, false);

      const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
      const actualCost = Number(runningCalc.totalCost.toFixed(2));
      const unitDelta = Number((contractBaseline - actualCost).toFixed(2));

      const matchedSales = salesData.filter(s => {
        const vMatch = selectedVendor === 'ALL' || s.vendor === (part.vendor || selectedVendor);
        return vMatch && s.itemCode === part.itemCode;
      });

      const qty = matchedSales.reduce((acc, s) => acc + Number(s.saleUnit || 0), 0);
      const sp = Number(matchedSales[0]?.sellingPrice || (contractBaseline * 1.18));

      totalQty += qty;
      totalRev += (sp * qty);
      totalGain += (unitDelta * qty);
    });

    return {
      totalQty,
      totalRev,
      totalGain: Number(totalGain.toFixed(2)),
      partsCount: vendorProducts.length
    };
  }, [vendorProducts, salesData, selectedVendor]);

  return (
    <div className="space-y-4 text-xs font-sans">
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-blue-600 rounded-xl">
            <Building2 className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold">0. Executive Costing & MIS Command Dashboard</h1>
            <p className="text-[11px] text-slate-300">Multi-Vendor Approved vs Actual Costing & Real-Time Variance Control</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[11px] font-bold text-slate-400">Vendor Scope:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="bg-slate-800 border border-slate-700 text-blue-300 font-bold px-3 py-1.5 rounded-xl text-xs outline-none cursor-pointer"
          >
            {vendors.map(v => (
              <option key={v.vendorId} value={v.vendorId}>{v.vendorName}</option>
            ))}
            <option value="ALL">All Combined</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Registered Baseline Products</span>
          <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">{dashboardStats.partsCount} Active Parts</span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Total Period Dispatches</span>
          <span className="text-2xl font-black text-blue-900 font-mono mt-1 block">{dashboardStats.totalQty.toLocaleString()} pcs</span>
        </div>

        <div className="bg-white border border-slate-300 rounded-2xl p-4 shadow-xs">
          <span className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Realized Sales Revenue</span>
          <span className="text-2xl font-black text-slate-900 font-mono mt-1 block">
            ₹{dashboardStats.totalRev.toLocaleString('en-IN', { maximumFractionDigits: 0 })}
          </span>
        </div>

        <div className={`border rounded-2xl p-4 shadow-xs ${dashboardStats.totalGain >= 0 ? 'bg-emerald-50/70 border-emerald-300' : 'bg-rose-50 border-rose-300'}`}>
          <div className="flex justify-between items-center">
            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-600">Net Cost Variance (P&L)</span>
            {dashboardStats.totalGain >= 0 ? <TrendingUp className="w-3.5 h-3.5 text-emerald-600" /> : <TrendingDown className="w-3.5 h-3.5 text-rose-600" />}
          </div>
          <span className={`text-2xl font-black font-mono mt-1 block ${dashboardStats.totalGain >= 0 ? 'text-emerald-700' : 'text-rose-700'}`}>
            {dashboardStats.totalGain >= 0 ? `₹ +${dashboardStats.totalGain.toLocaleString('en-IN', { maximumFractionDigits: 0 })}` : `₹ -${Math.abs(dashboardStats.totalGain).toLocaleString('en-IN', { maximumFractionDigits: 0 })}`}
          </span>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-5 gap-3">
        <div onClick={() => onNavigate('baseline')} className="bg-white p-4 rounded-2xl border hover:border-blue-500 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-blue-50 text-blue-600 w-fit rounded-lg"><Layers className="w-4 h-4" /></div>
          <h3 className="font-bold text-slate-900 text-xs">1. Baseline Master</h3>
          <p className="text-[10px] text-slate-500">Manage tool cavity, net weights, and cycle times.</p>
        </div>

        <div onClick={() => onNavigate('rm_matrix')} className="bg-white p-4 rounded-2xl border hover:border-blue-500 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-amber-50 text-amber-600 w-fit rounded-lg"><Sliders className="w-4 h-4" /></div>
          <h3 className="font-bold text-slate-900 text-xs">2. RM & Matrix</h3>
          <p className="text-[10px] text-slate-500">Lock monthly contracts and WA purchase rates.</p>
        </div>

        <div onClick={() => onNavigate('costing_engine')} className="bg-white p-4 rounded-2xl border hover:border-blue-500 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-emerald-50 text-emerald-600 w-fit rounded-lg"><DollarSign className="w-4 h-4" /></div>
          <h3 className="font-bold text-slate-900 text-xs">3. Costing Engine</h3>
          <p className="text-[10px] text-slate-500">Live dynamic piece cost variance simulation.</p>
        </div>

        <div onClick={() => onNavigate('mis')} className="bg-white p-4 rounded-2xl border hover:border-blue-500 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-indigo-50 text-indigo-600 w-fit rounded-lg"><BarChart3 className="w-4 h-4" /></div>
          <h3 className="font-bold text-slate-900 text-xs">4. MIS & Gap</h3>
          <p className="text-[10px] text-slate-500">Invoice batch drilldowns & profit realizations.</p>
        </div>

        <div onClick={() => onNavigate('ai_analyst')} className="bg-purple-900 text-white p-4 rounded-2xl border border-purple-800 hover:shadow-md cursor-pointer transition space-y-2">
          <div className="p-2 bg-purple-600 text-white w-fit rounded-lg"><Bot className="w-4 h-4" /></div>
          <h3 className="font-bold text-white text-xs">5. AI Analyst</h3>
          <p className="text-[10px] text-purple-200">Real-time LLM costing audits & root causes.</p>
        </div>
      </div>
    </div>
  );
}
