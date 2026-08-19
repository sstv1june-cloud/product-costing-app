import React, { useState, useEffect, useMemo } from 'react';
import { 
  Building2, Layers, Sliders, DollarSign, BarChart3, Bot, 
  TrendingUp, TrendingDown, AlertTriangle, ArrowRight, ShieldCheck, 
  Sparkles, CheckCircle2, UserPlus, Upload, FileSpreadsheet, X, Check, Eye
} from 'lucide-react';
import * as XLSX from 'xlsx';
import { globalStore, subscribeStore, onboardVendorWithBlueprint, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function DashboardPage({ onNavigate }) {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const [selectedVendor, setSelectedVendor] = useState('Haier');
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

  // Synchronized Dashboard Metrics (uses getActiveRmMapping per polymer)
  const dashboardStats = useMemo(() => {
    let totalRev = 0;
    let totalGain = 0;
    let totalQty = 0;

    vendorProducts.forEach(part => {
      const params = part.parameters || {};
      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor || selectedVendor, '2026-08-01');
      const approvedRmRate = rmMapping.approvedPrice || part.approvedRmRate || 136.20;
      const activeWaRate = rmMapping.activeWaPrice || approvedRmRate;

      const baselineSpec = {
        cavity: Number(part.cavity ?? params.cavity ?? 2),
        netWeight: Number(part.netWeight ?? params.netWeightApproved ?? 197),
        runnerWeight: Number(part.runnerWeight ?? params.runnerWeight ?? 40),
        rmRate: approvedRmRate,
        masterbatchPct: Number(part.masterbatchPct ?? 0),
        masterbatchRate: Number(part.masterbatchRate ?? 0),
        machineTonnage: Number(part.machineTonnage ?? params.machineTonnage ?? 450),
        shiftTariff: Number(part.hourlyRate ? part.hourlyRate * 8 : (params.shiftTariff ?? 3600)),
        cycleTime: Number(part.cycleTimeApproved ?? part.cycleTime ?? 48)
      };
      const baselineCalc = calculateDetailedCost(baselineSpec, true);

      const runningSpec = {
        cavity: Number(params.runningCavity ?? baselineSpec.cavity),
        netWeight: Number(params.runningNetWeight ?? baselineSpec.netWeight),
        runnerWeight: Number(params.runningRunnerWeight ?? baselineSpec.runnerWeight),
        rmRate: activeWaRate,
        masterbatchPct: Number(params.runningMbPct ?? baselineSpec.masterbatchPct),
        masterbatchRate: baselineSpec.masterbatchRate,
        machineTonnage: Number(params.runningTonnage ?? baselineSpec.machineTonnage),
        shiftTariff: Number(params.runningShiftTariff ?? (params.runningTonnage >= 600 ? 4800 : baselineSpec.shiftTariff)),
        cycleTime: Number(params.runningCycleTime ?? baselineSpec.cycleTime)
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

  // Real Excel (.xlsx) Parser Engine
  const handleRealExcelFileUpload = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploadedFileName(file.name);
    const reader = new FileReader();

    reader.onload = (evt) => {
      try {
        const bstr = evt.target.result;
        const wb = XLSX.read(bstr, { type: 'binary' });
        const wsname = wb.SheetNames[0];
        setSheetName(wsname);
        const ws = wb.Sheets[wsname];
        const rawRows = XLSX.utils.sheet_to_json(ws, { header: 1 });

        const parsedBlueprint = [];
        let extractedProduct = {
          itemCode: '',
          componentName: '',
          model: wsname,
          approvedRm: '',
          approvedRmRate: 0,
          cavity: 1,
          netWeight: 0,
          runnerWeight: 0,
          cycleTimeApproved: 0,
          machineTonnage: 0,
          hourlyRate: 400
        };

        let lineCounter = 1;
        rawRows.forEach((row) => {
          if (!row || row.length === 0) return;

          const labelCell = row.find((cell, i) => i < 3 && typeof cell === 'string' && cell.trim() !== '');
          const valCell = row[row.length - 1] !== undefined ? row[row.length - 1] : row[row.length - 2];
          const rateCell = row.length >= 4 ? row[row.length - 2] : null;

          if (labelCell !== undefined && labelCell.toString().trim() !== '') {
            const desc = labelCell.toString().trim();
            const val = valCell !== undefined ? valCell : '';
            const descLower = desc.toLowerCase();

            let classification = 'PARAMETER';
            let uom = '-';

            if (descLower.includes('vendor')) {
              classification = 'HEADER';
              if (!newVendorData.vendorName) {
                setNewVendorData(prev => ({ ...prev, vendorName: String(val).trim() }));
              }
            } else if (descLower.includes('part code') || descLower.includes('part no') || descLower.includes('item code')) {
              classification = 'HEADER';
              extractedProduct.itemCode = String(val).trim();
            } else if (descLower.includes('part name') || descLower.includes('component')) {
              classification = 'HEADER';
              extractedProduct.componentName = String(val).trim();
            } else if (descLower.includes('rm grade') || descLower.includes('polymer') || descLower.includes('raw material')) {
              classification = 'RM LINKED';
              extractedProduct.approvedRm = String(val).trim();
            } else if (descLower.includes('rm base rate') || descLower.includes('rm landed')) {
              classification = 'RM RATE';
              uom = '₹/kg';
              extractedProduct.approvedRmRate = Number(val) || 133;
            } else if (descLower.includes('part weight') || descLower.includes('net wt')) {
              classification = 'PARAMETER';
              uom = 'Gms';
              extractedProduct.netWeight = Number(val) || 0;
            } else if (descLower.includes('runner weight')) {
              classification = 'PARAMETER';
              uom = 'Gms';
              extractedProduct.runnerWeight = Number(val) || 0;
            } else if (descLower.includes('cavity')) {
              classification = 'PARAMETER';
              uom = 'Nos';
              extractedProduct.cavity = Number(val) || 1;
            } else if (descLower.includes('cycle time')) {
              classification = 'PARAMETER';
              uom = 'Sec';
              extractedProduct.cycleTimeApproved = Number(val) || 0;
            } else if (descLower.includes('tonnage')) {
              classification = 'PARAMETER';
              uom = 'T';
              extractedProduct.machineTonnage = Number(val) || 200;
            } else if (descLower.includes('shift rate')) {
              classification = 'PARAMETER';
              uom = '₹/shift';
              extractedProduct.hourlyRate = (Number(val) || 2000) / 8;
            } else if (descLower.includes('total') || descLower.includes('final landed')) {
              classification = 'TOTAL COST';
              uom = '₹/pc';
            } else if (descLower.includes('cost') || descLower.includes('oh') || descLower.includes('rejection')) {
              classification = 'FORMULA CALC';
              uom = '₹';
            }

            parsedBlueprint.push({
              lineNo: lineCounter++,
              description: desc,
              uom,
              rateParam: rateCell,
              classification,
              val: typeof val === 'number' ? Number(val.toFixed(4)) : val
            });
          }
        });

        setStagedLines(parsedBlueprint);
        setStagedProduct(extractedProduct);
        setOnboardStep(3);
      } catch (err) {
        alert('Error parsing Excel file: ' + err.message);
      }
    };

    reader.readAsBinaryString(file);
  };

  const handleCommitNewVendor = () => {
    const vName = newVendorData.vendorName.trim() || 'Atomberg';

    onboardVendorWithBlueprint({
      vendorName: vName,
      vendorCode: newVendorData.vendorCode || vName.substring(0, 4).toUpperCase(),
      paymentTerms: newVendorData.paymentTerms,
      blueprintLines: stagedLines,
      initialProduct: {
        itemCode: stagedProduct.itemCode || 'A101701',
        componentName: stagedProduct.componentName || 'Aris Top Canopy- Gloss White',
        model: sheetName || 'Aris',
        mouldSize: '950*600*450',
        approvedRm: stagedProduct.approvedRm || 'PP H110MA',
        approvedRmRate: stagedProduct.approvedRmRate || 135.83,
        cavity: Number(stagedProduct.cavity || 2),
        netWeight: Number(stagedProduct.netWeight || 37),
        runnerWeight: Number(stagedProduct.runnerWeight || 1),
        cycleTimeApproved: Number(stagedProduct.cycleTimeApproved || 47),
        machineTonnage: Number(stagedProduct.machineTonnage || 200),
        hourlyRate: Number(stagedProduct.hourlyRate || 250)
      }
    });

    setSelectedVendor(vName);
    setShowOnboardModal(false);
    setOnboardStep(1);
    setSuccessMsg(`Vendor "${vName}" onboarded with ${stagedLines.length} exact lines from "${uploadedFileName}".`);
    setTimeout(() => setSuccessMsg(null), 4000);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Banner */}
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
          <button
            onClick={() => { setOnboardStep(1); setShowOnboardModal(true); }}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl shadow-xs transition cursor-pointer"
          >
            <UserPlus className="w-3.5 h-3.5" /> + Onboard New Vendor
          </button>

          <span className="text-[11px] font-bold text-slate-400 ml-2">Vendor Scope:</span>
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

      {successMsg && (
        <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 px-4 py-2.5 rounded-xl flex items-center gap-2 font-bold shadow-xs">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" />
          <span>{successMsg}</span>
        </div>
      )}

      {/* KPI Cards */}
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

      {/* Module Navigation Cards */}
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

      {/* MODAL: ONBOARD NEW VENDOR & DYNAMIC REAL EXCEL PARSER */}
      {showOnboardModal && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl shadow-2xl max-w-3xl w-full p-5 space-y-4 border border-slate-300 animate-in fade-in duration-100 max-h-[90vh] overflow-y-auto">
            
            <div className="flex justify-between items-center border-b pb-3">
              <div>
                <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                  <UserPlus className="w-4 h-4 text-purple-600" /> Onboard New Vendor & Dynamic Costing Blueprint
                </h3>
                <p className="text-[11px] text-slate-500">Step {onboardStep} of 3: Live Variable N-Line Parser Engine</p>
              </div>
              <button onClick={() => setShowOnboardModal(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* STEP 1: Basic Info */}
            {onboardStep === 1 && (
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">OEM / Vendor Name *</label>
                    <input
                      type="text"
                      value={newVendorData.vendorName}
                      onChange={e => setNewVendorData({ ...newVendorData, vendorName: e.target.value })}
                      placeholder="e.g., Atomberg, Godrej, IFB"
                      className="w-full border p-2 rounded-xl text-xs outline-none focus:ring-2 focus:ring-purple-500"
                    />
                  </div>
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Vendor ERP Shortcode</label>
                    <input
                      type="text"
                      value={newVendorData.vendorCode}
                      onChange={e => setNewVendorData({ ...newVendorData, vendorCode: e.target.value })}
                      placeholder="e.g., ATOM, GDJ, IFB"
                      className="w-full border p-2 rounded-xl text-xs outline-none uppercase font-mono"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Commercial Payment Terms</label>
                    <input
                      type="text"
                      value={newVendorData.paymentTerms}
                      onChange={e => setNewVendorData({ ...newVendorData, paymentTerms: e.target.value })}
                      className="w-full border p-2 rounded-xl text-xs outline-none"
                    />
                  </div>
                  <div>
                    <label className="font-bold text-slate-700 block mb-1">Billing Currency</label>
                    <input
                      type="text"
                      value={newVendorData.currency}
                      disabled
                      className="w-full border p-2 rounded-xl text-xs bg-slate-100 font-bold"
                    />
                  </div>
                </div>

                <div className="flex justify-end pt-3 border-t">
                  <button
                    disabled={!newVendorData.vendorName}
                    onClick={() => setOnboardStep(2)}
                    className="px-4 py-2 bg-purple-600 disabled:opacity-50 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-xs"
                  >
                    Next: Upload Vendor Format <ArrowRight className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            )}

            {/* STEP 2: File Upload (Excel .xlsx) */}
            {onboardStep === 2 && (
              <div className="space-y-4 text-center py-4">
                <div className="p-6 border-2 border-dashed border-purple-300 bg-purple-50/50 rounded-2xl space-y-2">
                  <FileSpreadsheet className="w-8 h-8 text-purple-600 mx-auto" />
                  <h4 className="font-bold text-sm text-slate-900">Upload {newVendorData.vendorName} Format File (.xlsx)</h4>
                  <p className="text-[11px] text-slate-500 max-w-md mx-auto">
                    Select your Excel sheet (e.g. <code>Atomberg format.xlsx</code>). The engine will read the exact sheet lines directly.
                  </p>
                  <div className="pt-2">
                    <input
                      type="file"
                      id="real-costing-upload"
                      accept=".xlsx,.xls"
                      onChange={handleRealExcelFileUpload}
                      className="hidden"
                    />
                    <label
                      htmlFor="real-costing-upload"
                      className="px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl cursor-pointer inline-flex items-center gap-2 shadow-xs"
                    >
                      <Upload className="w-3.5 h-3.5" /> Browse and Parse Excel Sheet
                    </label>
                  </div>
                </div>

                <div className="flex justify-between items-center pt-3 border-t">
                  <button onClick={() => setOnboardStep(1)} className="px-3 py-1.5 border rounded-lg">Back</button>
                </div>
              </div>
            )}

            {/* STEP 3: Real Parsed Lines from Excel */}
            {onboardStep === 3 && (
              <div className="space-y-3">
                <div className="bg-emerald-50 border border-emerald-200 text-emerald-900 p-2.5 rounded-xl flex items-center justify-between font-bold">
                  <div className="flex items-center gap-2">
                    <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                    <span>Parsed {stagedLines.length} Custom Lines from "{uploadedFileName}" (Sheet: {sheetName})</span>
                  </div>
                  <span className="text-[10px] bg-emerald-200 text-emerald-900 px-2 py-0.5 rounded">Exact Format Verified</span>
                </div>

                <div className="border border-slate-300 rounded-xl overflow-hidden max-h-72 overflow-y-auto">
                  <table className="min-w-full text-xs text-left">
                    <thead className="bg-slate-100 text-slate-700 font-bold uppercase text-[10px] sticky top-0">
                      <tr>
                        <th className="p-2 w-12 text-center">#</th>
                        <th className="p-2">Costing Description (Vendor Line)</th>
                        <th className="p-2 w-16">UOM</th>
                        <th className="p-2 w-28">Classification</th>
                        <th className="p-2 text-right w-28">Value in Sheet</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-200 font-medium">
                      {stagedLines.map((l) => (
                        <tr key={l.lineNo} className="hover:bg-slate-50">
                          <td className="p-2 text-center font-mono text-slate-500">{l.lineNo}</td>
                          <td className="p-2 font-bold text-slate-900">{l.description}</td>
                          <td className="p-2 font-mono text-slate-600">{l.uom}</td>
                          <td className="p-2">
                            <span className={`text-[10px] font-bold px-2 py-0.5 rounded ${
                              l.classification === 'TOTAL COST' ? 'bg-amber-100 text-amber-900' :
                              l.classification === 'FORMULA CALC' ? 'bg-blue-100 text-blue-900' :
                              l.classification === 'RM LINKED' ? 'bg-purple-100 text-purple-900' : 'bg-slate-100 text-slate-700'
                            }`}>
                              {l.classification}
                            </span>
                          </td>
                          <td className="p-2 text-right font-mono font-bold text-slate-900">
                            {typeof l.val === 'number' ? l.val.toLocaleString('en-IN', { maximumFractionDigits: 4 }) : String(l.val)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                <div className="flex justify-between items-center pt-3 border-t">
                  <button onClick={() => setOnboardStep(2)} className="px-3 py-1.5 border rounded-lg">Back to Upload</button>
                  <button
                    onClick={handleCommitNewVendor}
                    className="px-5 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl flex items-center gap-1.5 cursor-pointer shadow-sm"
                  >
                    <Check className="w-4 h-4" /> Save & Commit {newVendorData.vendorName || 'Atomberg'} ({stagedLines.length} Lines)
                  </button>
                </div>
              </div>
            )}

          </div>
        </div>
      )}

    </div>
  );
}
