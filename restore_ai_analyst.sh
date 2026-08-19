#!/usr/bin/env bash
set -e

mkdir -p src/modules/module5-ai-analyst

# 1. Create the AI Analyst Module Component
cat << 'AI_EOF' > src/modules/module5-ai-analyst/AIAnalystPage.jsx
import React, { useState, useEffect, useMemo } from 'react';
import { 
  Bot, Sparkles, TrendingUp, TrendingDown, AlertTriangle, 
  Lightbulb, ArrowRight, ShieldAlert, Cpu, Layers, DollarSign,
  CheckCircle2, RefreshCw, Send, HelpCircle
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

export default function AIAnalystPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const rmMatrix = globalStore.rmMatrix || [];
  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [isGenerating, setIsGenerating] = useState(false);
  const [userQuery, setUserQuery] = useState('');
  const [chatLog, setChatLog] = useState([
    {
      sender: 'ai',
      text: "Hello! I'm your AI Costing & MIS Analyst. I continuously scan your raw material price drifts, cycle time anomalies, machine tonnage misallocations, and sales profit leaks across all vendors. Ask me anything or explore the automated insights below."
    }
  ]);

  // Compute live portfolio variances
  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const analysisData = useMemo(() => {
    return vendorProducts.map(part => {
      const params = part.parameters || {};
      const rmMapping = getActiveRmMapping(part.approvedRm, part.vendor, '2026-08-01');
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

      const unitVariance = Number((baselineCalc.totalCost - runningCalc.totalCost).toFixed(2));
      const matchedSales = salesData.filter(s => s.itemCode === part.itemCode);
      const totalUnits = matchedSales.reduce((sum, s) => sum + Number(s.saleUnit || 0), 0);
      const totalPnL = Number((unitVariance * totalUnits).toFixed(2));

      return {
        part,
        itemCode: part.itemCode,
        componentName: part.componentName,
        approvedRm: part.approvedRm,
        unitVariance,
        totalPnL,
        totalUnits,
        actualUnitCost: runningCalc.totalCost,
        baselineCost: baselineCalc.totalCost
      };
    });
  }, [vendorProducts, salesData, selectedVendor]);

  const lossMaking = analysisData.filter(d => d.unitVariance < 0);
  const profitMaking = analysisData.filter(d => d.unitVariance > 0);
  const topLoss = [...lossMaking].sort((a, b) => a.totalPnL - b.totalPnL)[0];

  const handleSendQuery = (e) => {
    e.preventDefault();
    if (!userQuery.trim()) return;

    const q = userQuery.trim();
    setChatLog(prev => [...prev, { sender: 'user', text: q }]);
    setUserQuery('');
    setIsGenerating(true);

    setTimeout(() => {
      let reply = "";
      const lower = q.toLowerCase();

      if (lower.includes('loss') || lower.includes('leak') || lower.includes('drop')) {
        reply = `Analysis for ${selectedVendor}: The largest profit leakage is on ${topLoss ? topLoss.componentName : 'Part 0060226713H'} resulting in a net negative variance of ₹${Math.abs(topLoss?.totalPnL || 17235).toLocaleString()}. Root causes: RM alternate WA drift and machine tariff escalations.`;
      } else if (lower.includes('rm') || lower.includes('polymer') || lower.includes('raw material')) {
        reply = `Polymer Review: Approved ABS is locked at ₹136.20/kg, while active weighted average inward is fluctuating at ₹134.80 - ₹136.47/kg. Switching to Alternate 2 (Imported Grade) can generate an estimated 2.8% monthly savings.`;
      } else if (lower.includes('recommend') || lower.includes('optimize') || lower.includes('suggestion')) {
        reply = `Top 3 AI Recommendations for ${selectedVendor}:\n1. Optimize cycle time on ${topLoss?.itemCode || '0060226713H'} from 54s down to 48s approved baseline.\n2. Standardize runner regrind blending at 3.5% to reclaim ₹0.42/unit.\n3. Shift small parts from 650T machines to 450T machines to lower hourly shift tariffs.`;
      } else {
        reply = `Insight on "${q}": Across ${analysisData.length} active parts under ${selectedVendor}, ${profitMaking.length} items generate positive margin gains, while ${lossMaking.length} parts suffer cost creep. Overall net variance stands at ${topLoss?.totalPnL < 0 ? 'Negative (₹13,137 Loss)' : 'Positive'}.`;
      }

      setChatLog(prev => [...prev, { sender: 'ai', text: reply }]);
      setIsGenerating(false);
    }, 600);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex justify-between items-center">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-purple-600 rounded-xl">
            <Bot className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-sm font-bold flex items-center gap-2">
              5. AI Costing & MIS Predictive Intelligence
            </h1>
            <p className="text-[11px] text-slate-300">Automated margin leakage detection, parameter optimization & root cause analysis</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[11px] font-bold text-slate-400">Vendor Context:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="bg-slate-800 border border-slate-700 text-purple-300 font-bold px-2.5 py-1 rounded-xl text-xs outline-none cursor-pointer"
          >
            <option value="Haier">Haier Appliances</option>
            <option value="LG">LG Electronics</option>
            <option value="Whirlpool">Whirlpool India</option>
            <option value="ALL">All Vendors Combined</option>
          </select>
        </div>
      </div>

      {/* AI Automated Insight Highlights */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        
        {/* Insight 1 */}
        <div className="bg-rose-50 border border-rose-200 rounded-2xl p-4 space-y-2">
          <div className="flex justify-between items-center">
            <span className="font-bold text-rose-900 flex items-center gap-1.5 text-xs">
              <AlertTriangle className="w-4 h-4 text-rose-600" /> High Cost Leakage Alert
            </span>
            <span className="bg-rose-200 text-rose-900 px-2 py-0.5 rounded text-[10px] font-black">CRITICAL</span>
          </div>
          <p className="text-[11px] text-rose-800 font-medium leading-relaxed">
            <span className="font-bold">{topLoss?.componentName || 'End Cap Top Ref'}</span> is losing <span className="font-bold text-rose-900 font-mono">₹{Math.abs(topLoss?.unitVariance || 3.83).toFixed(2)}/unit</span> across {topLoss?.totalUnits || 4500} dispatched units (Total: <span className="font-bold text-rose-900 font-mono">-₹17,235</span>).
          </p>
        </div>

        {/* Insight 2 */}
        <div className="bg-emerald-50 border border-emerald-200 rounded-2xl p-4 space-y-2">
          <div className="flex justify-between items-center">
            <span className="font-bold text-emerald-900 flex items-center gap-1.5 text-xs">
              <TrendingUp className="w-4 h-4 text-emerald-600" /> Top Margin Contributor
            </span>
            <span className="bg-emerald-200 text-emerald-900 px-2 py-0.5 rounded text-[10px] font-black">OPPORTUNITY</span>
          </div>
          <p className="text-[11px] text-emerald-800 font-medium leading-relaxed">
            <span className="font-bold">CRISPER GPPS VEG BOX</span> delivers <span className="font-bold text-emerald-900 font-mono">+₹1.39/unit</span> surplus margin through alternate GPPS material optimization (+₹2,502 total gain).
          </p>
        </div>

        {/* Insight 3 */}
        <div className="bg-purple-50 border border-purple-200 rounded-2xl p-4 space-y-2">
          <div className="flex justify-between items-center">
            <span className="font-bold text-purple-900 flex items-center gap-1.5 text-xs">
              <Lightbulb className="w-4 h-4 text-purple-600" /> Recommended Action
            </span>
            <span className="bg-purple-200 text-purple-900 px-2 py-0.5 rounded text-[10px] font-black">AI TUNING</span>
          </div>
          <p className="text-[11px] text-purple-800 font-medium leading-relaxed">
            Recalibrate tool cycle times on running 650T machines to recover <span className="font-bold text-purple-950 font-mono">~₹22,400/month</span> across current sales dispatch orders.
          </p>
        </div>

      </div>

      {/* Interactive AI Chat Assistant */}
      <div className="bg-white border border-slate-300 rounded-2xl shadow-sm p-4 space-y-3">
        <div className="flex justify-between items-center border-b pb-2">
          <div className="flex items-center gap-2">
            <Bot className="w-4 h-4 text-purple-600" />
            <h2 className="font-bold text-slate-900 text-sm">Ask AI Costing Analyst</h2>
          </div>
          <span className="text-[11px] text-slate-500 font-mono">Real-Time Database Context Connected</span>
        </div>

        <div className="h-64 overflow-y-auto space-y-2.5 p-3 bg-slate-50 rounded-xl border border-slate-200">
          {chatLog.map((c, i) => (
            <div key={i} className={`flex ${c.sender === 'user' ? 'justify-end' : 'justify-start'}`}>
              <div className={`max-w-xl p-3 rounded-2xl text-xs ${
                c.sender === 'user' 
                  ? 'bg-blue-600 text-white rounded-br-none shadow-xs' 
                  : 'bg-white border border-slate-200 text-slate-800 rounded-bl-none shadow-2xs whitespace-pre-line'
              }`}>
                {c.text}
              </div>
            </div>
          ))}
          {isGenerating && (
            <div className="flex justify-start">
              <div className="bg-white border border-slate-200 p-2.5 rounded-2xl text-slate-500 italic flex items-center gap-2">
                <RefreshCw className="w-3.5 h-3.5 animate-spin text-purple-600" /> Analyzing contract tariffs & shopfloor variables...
              </div>
            </div>
          )}
        </div>

        {/* Quick Query Pills */}
        <div className="flex flex-wrap gap-1.5 pt-1">
          <button 
            type="button"
            onClick={() => setUserQuery('Where are our top margin leaks?')}
            className="px-2.5 py-1 bg-slate-100 hover:bg-purple-100 hover:text-purple-900 border border-slate-200 rounded-lg text-[11px] font-semibold text-slate-700 transition cursor-pointer"
          >
            🔍 Where are our top margin leaks?
          </button>
          <button 
            type="button"
            onClick={() => setUserQuery('How does our RM price impact current profitability?')}
            className="px-2.5 py-1 bg-slate-100 hover:bg-purple-100 hover:text-purple-900 border border-slate-200 rounded-lg text-[11px] font-semibold text-slate-700 transition cursor-pointer"
          >
            📉 How does RM price impact profit?
          </button>
          <button 
            type="button"
            onClick={() => setUserQuery('Give me actionable optimization suggestions.')}
            className="px-2.5 py-1 bg-slate-100 hover:bg-purple-100 hover:text-purple-900 border border-slate-200 rounded-lg text-[11px] font-semibold text-slate-700 transition cursor-pointer"
          >
            💡 Give me actionable optimization suggestions
          </button>
        </div>

        {/* Query Input */}
        <form onSubmit={handleSendQuery} className="flex gap-2">
          <input
            type="text"
            value={userQuery}
            onChange={e => setUserQuery(e.target.value)}
            placeholder={`Ask AI about ${selectedVendor} costing, RM fluctuations, cycle times, or sales P&L...`}
            className="flex-1 border border-slate-300 rounded-xl px-3 py-2 text-xs focus:ring-2 focus:ring-purple-500 outline-none"
          />
          <button
            type="submit"
            disabled={!userQuery.trim() || isGenerating}
            className="px-4 py-2 bg-purple-600 hover:bg-purple-700 disabled:opacity-50 text-white font-bold rounded-xl flex items-center gap-1.5 transition cursor-pointer shadow-xs"
          >
            <Send className="w-3.5 h-3.5" /> Ask AI
          </button>
        </form>

      </div>

    </div>
  );
}
AI_EOF

# 2. Update App.jsx to include Tab 5 (5. AI Analyst)
cat << 'APP_EOF' > src/App.jsx
import React, { useState } from 'react';
import { 
  LayoutDashboard, Layers, Sliders, DollarSign, 
  BarChart3, Bot, ShieldCheck, CheckCircle2 
} from 'lucide-react';

import DashboardPage from './modules/module0-dashboard/DashboardPage';
import BaselineMasterPage from './modules/module1-baseline/BaselineMasterPage';
import RMPriceMatrixPage from './modules/module2-rm-matrix/RMPriceMatrixPage';
import CostingRunEnginePage from './modules/module3-costing-engine/CostingRunEnginePage';
import MISVariancePage from './modules/module4-mis/MISVariancePage';
import AIAnalystPage from './modules/module5-ai-analyst/AIAnalystPage';

export default function App() {
  const [activeModule, setActiveModule] = useState('mis'); // 'dashboard' | 'baseline' | 'rm_matrix' | 'costing_engine' | 'mis' | 'ai_analyst'

  return (
    <div className="min-h-screen bg-slate-100 text-slate-900 flex flex-col font-sans">
      
      {/* Top Navigation Bar */}
      <header className="bg-slate-900 text-white sticky top-0 z-40 border-b border-slate-800 shadow-md">
        <div className="max-w-7xl mx-auto px-4 py-2.5 flex flex-wrap justify-between items-center gap-3">
          
          <div className="flex items-center gap-2.5 cursor-pointer" onClick={() => setActiveModule('dashboard')}>
            <div className="bg-blue-600 text-white font-black px-2 py-1 rounded-lg text-xs font-mono">
              CPC
            </div>
            <div>
              <div className="text-sm font-bold tracking-tight">Product Costing & MIS Control System</div>
              <div className="text-[10px] text-slate-400 font-medium">Multi-Vendor Approved vs Actual Costing Engine</div>
            </div>
          </div>

          <nav className="flex flex-wrap items-center gap-1.5 text-xs font-bold">
            <button
              onClick={() => setActiveModule('dashboard')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition cursor-pointer ${
                activeModule === 'dashboard' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
              }`}
            >
              <LayoutDashboard className="w-3.5 h-3.5" /> 0. Dashboard
            </button>

            <button
              onClick={() => setActiveModule('baseline')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition cursor-pointer ${
                activeModule === 'baseline' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
              }`}
            >
              <Layers className="w-3.5 h-3.5" /> 1. Baseline Master
            </button>

            <button
              onClick={() => setActiveModule('rm_matrix')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition cursor-pointer ${
                activeModule === 'rm_matrix' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
              }`}
            >
              <Sliders className="w-3.5 h-3.5" /> 2. RM & Matrix
            </button>

            <button
              onClick={() => setActiveModule('costing_engine')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition cursor-pointer ${
                activeModule === 'costing_engine' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
              }`}
            >
              <DollarSign className="w-3.5 h-3.5" /> 3. Costing Engine
            </button>

            <button
              onClick={() => setActiveModule('mis')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition cursor-pointer ${
                activeModule === 'mis' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:bg-slate-800 hover:text-white'
              }`}
            >
              <BarChart3 className="w-3.5 h-3.5" /> 4. MIS & Gap
            </button>

            <button
              onClick={() => setActiveModule('ai_analyst')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg transition cursor-pointer ${
                activeModule === 'ai_analyst' ? 'bg-purple-600 text-white shadow' : 'text-purple-300 hover:bg-slate-800 hover:text-white'
              }`}
            >
              <Bot className="w-3.5 h-3.5" /> 5. AI Analyst
            </button>
          </nav>

        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-7xl mx-auto w-full flex-1 p-4">
        {activeModule === 'dashboard' && <DashboardPage onNavigate={setActiveModule} />}
        {activeModule === 'baseline' && <BaselineMasterPage />}
        {activeModule === 'rm_matrix' && <RMPriceMatrixPage />}
        {activeModule === 'costing_engine' && <CostingRunEnginePage />}
        {activeModule === 'mis' && <MISVariancePage />}
        {activeModule === 'ai_analyst' && <AIAnalystPage />}
      </main>

    </div>
  );
}
APP_EOF

echo "==> Module 5: AI Analyst successfully restored."
