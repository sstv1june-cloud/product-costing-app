import React, { useState } from 'react';
import { 
  Building2, Plus, Sliders, ShieldCheck, Database, 
  Layers, Lock, CheckCircle2, AlertCircle, FileSpreadsheet
} from 'lucide-react';
import { getRegisteredVendors } from '../../vendor-adapters/vendorRegistry';
import VendorOnboardingModal from './VendorOnboardingModal';

export default function AdminWorkspacePage() {
  const [activeTab, setActiveTab] = useState('registry'); // 'registry' | 'designer' | 'security'
  const [showOnboardModal, setShowOnboardModal] = useState(false);
  const [vendorList, setVendorList] = useState(getRegisteredVendors());

  const handleVendorCreated = () => {
    setVendorList([...getRegisteredVendors()]);
  };

  return (
    <div className="space-y-6">
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-6 shadow-md flex justify-between items-center flex-wrap gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="p-2 bg-blue-600 rounded-xl">
              <Building2 className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-lg font-bold">System Administration & Multi-Vendor Configuration</h1>
              <p className="text-xs text-slate-300 mt-0.5">
                Manage OEM customer profiles, custom costing baseline schemas, and global calculation parameters
              </p>
            </div>
          </div>
        </div>

        <button 
          onClick={() => setShowOnboardModal(true)}
          className="px-4 py-2.5 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-xl text-xs shadow-lg flex items-center gap-2 cursor-pointer transition">
          <Plus className="w-4 h-4" /> + Onboard New Vendor
        </button>
      </div>

      {/* Tab Navigation */}
      <div className="flex items-center gap-2 border-b border-slate-200 pb-2">
        <button 
          onClick={() => setActiveTab('registry')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 cursor-pointer ${
            activeTab === 'registry' ? 'bg-blue-600 text-white shadow' : 'bg-white text-slate-700 hover:bg-slate-100 border border-slate-200'
          }`}>
          <Building2 className="w-4 h-4" /> 1. Vendor Registry ({vendorList.length})
        </button>

        <button 
          onClick={() => setActiveTab('designer')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 cursor-pointer ${
            activeTab === 'designer' ? 'bg-blue-600 text-white shadow' : 'bg-white text-slate-700 hover:bg-slate-100 border border-slate-200'
          }`}>
          <Sliders className="w-4 h-4" /> 2. Schema Designer (Custom 10-60 Rows)
        </button>

        <button 
          onClick={() => setActiveTab('security')}
          className={`px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 cursor-pointer ${
            activeTab === 'security' ? 'bg-blue-600 text-white shadow' : 'bg-white text-slate-700 hover:bg-slate-100 border border-slate-200'
          }`}>
          <ShieldCheck className="w-4 h-4" /> 3. Security & Admin Lock Controls
        </button>
      </div>

      {/* TAB 1: VENDOR REGISTRY */}
      {activeTab === 'registry' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {vendorList.map((v) => (
            <div key={v.vendorId} className="bg-white rounded-2xl border border-slate-200 shadow-xs hover:shadow-md transition p-5 flex flex-col justify-between">
              <div>
                <div className="flex justify-between items-start mb-3">
                  <span className="px-2.5 py-1 bg-blue-50 text-blue-800 rounded-lg font-mono text-[10px] font-bold border border-blue-200">
                    {v.vendorId}
                  </span>
                  <span className="flex items-center gap-1 text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                    <CheckCircle2 className="w-3 h-3" /> ACTIVE
                  </span>
                </div>

                <h3 className="text-base font-bold text-slate-900 mb-1">{v.vendorName}</h3>
                <p className="text-xs text-slate-500 mb-4">
                  {v.schema?.description || 'Custom Costing baseline profile configured.'}
                </p>

                <div className="bg-slate-50 rounded-xl p-3 space-y-1.5 text-[11px] border border-slate-100">
                  <div className="flex justify-between text-slate-600">
                    <span>Calculation Basis:</span>
                    <span className="font-bold text-slate-800">{v.calculationBasis}</span>
                  </div>
                  <div className="flex justify-between text-slate-600">
                    <span>Standard Efficiency:</span>
                    <span className="font-bold text-slate-800">{v.defaultEfficiencyPct}%</span>
                  </div>
                  <div className="flex justify-between text-slate-600">
                    <span>Schema Parameter Rows:</span>
                    <span className="font-bold text-blue-700">{v.schema?.rows?.length || v.totalRows} Rows</span>
                  </div>
                </div>
              </div>

              <div className="mt-4 pt-3 border-t border-slate-100 flex justify-between items-center">
                <span className="text-[11px] text-slate-400 font-semibold">{v.activePartsCount} Parts Mapped</span>
                <button 
                  onClick={() => setActiveTab('designer')}
                  className="text-xs text-blue-600 font-bold hover:underline cursor-pointer">
                  View / Edit Schema →
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* TAB 2: SCHEMA DESIGNER */}
      {activeTab === 'designer' && (
        <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs space-y-4">
          <div className="flex justify-between items-center border-b pb-4">
            <div>
              <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                <FileSpreadsheet className="w-4 h-4 text-blue-600" />
                Upload & Ingest Vendor Costing Format (One-Time Ingestion)
              </h3>
              <p className="text-xs text-slate-500 mt-0.5">
                Drop any new customer sample sheet to automatically extract line items and bind them to core calculation formulas.
              </p>
            </div>
          </div>

          <div className="border-2 border-dashed border-slate-300 hover:border-blue-500 rounded-2xl p-8 text-center bg-slate-50/50 hover:bg-blue-50/20 transition cursor-pointer">
            <FileSpreadsheet className="w-10 h-10 text-blue-600 mx-auto mb-2" />
            <h4 className="text-xs font-bold text-slate-800">Drop Vendor Costing Sample Sheet Here</h4>
            <p className="text-[11px] text-slate-400 mt-1">Accepts .xlsx, .xls containing custom 10 to 60-row breakdowns</p>
          </div>
        </div>
      )}

      {/* TAB 3: SECURITY & ADMIN LOCK */}
      {activeTab === 'security' && (
        <div className="bg-white rounded-2xl border border-slate-200 p-6 shadow-xs space-y-4">
          <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
            <Lock className="w-4 h-4 text-blue-600" /> Admin Baseline Locking & AI Permissions
          </h3>
          <p className="text-xs text-slate-500">
            Ensure audited contract baselines are locked from accidental shop-floor changes and enforce read-only tokens for the AI Copilot.
          </p>

          <div className="space-y-3 pt-2">
            <div className="flex items-center justify-between p-3.5 bg-slate-50 rounded-xl border border-slate-200">
              <div>
                <span className="font-bold text-xs text-slate-800 block">Lock Historical Baseline Versions</span>
                <span className="text-[11px] text-slate-500">Prevents editing of past validity window specifications</span>
              </div>
              <span className="px-3 py-1 bg-emerald-100 text-emerald-800 text-xs font-bold rounded-lg">ENABLED</span>
            </div>

            <div className="flex items-center justify-between p-3.5 bg-slate-50 rounded-xl border border-slate-200">
              <div>
                <span className="font-bold text-xs text-slate-800 block">Strict Read-Only AI Analyst Access</span>
                <span className="text-[11px] text-slate-500">The AI assistant cannot modify prices, baselines, or inventory entries</span>
              </div>
              <span className="px-3 py-1 bg-emerald-100 text-emerald-800 text-xs font-bold rounded-lg">ENFORCED</span>
            </div>
          </div>
        </div>
      )}

      {/* Onboard Modal */}
      {showOnboardModal && (
        <VendorOnboardingModal 
          onClose={() => setShowOnboardModal(false)}
          onVendorCreated={handleVendorCreated}
        />
      )}
    </div>
  );
}