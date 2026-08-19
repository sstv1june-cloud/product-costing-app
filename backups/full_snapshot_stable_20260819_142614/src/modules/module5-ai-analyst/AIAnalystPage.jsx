import React, { useState, useEffect, useMemo } from 'react';
import { 
  Bot, Sparkles, TrendingUp, TrendingDown, AlertTriangle, 
  Lightbulb, ArrowRight, ShieldAlert, Cpu, Layers, DollarSign,
  CheckCircle2, RefreshCw, Send, Key, Settings, ShieldCheck, Check, Lock
} from 'lucide-react';
import { globalStore, subscribeStore, getActiveRmMapping } from '../../shared/masterStore';
import { calculateDetailedCost } from '../module1-baseline/InlineEditModal';

const DEFAULT_GEMINI_KEY = "AQ.Ab8RN6KsRe9Fsv0EZVQkKxA85ASDti9lHDQzPs053eriNATiyw";
const DEFAULT_OPENAI_KEY = "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";

export default function AIAnalystPage() {
  const [, setTick] = useState(0);
  useEffect(() => subscribeStore(() => setTick(t => t + 1)), []);

  const masterList = globalStore.baselineList || [];
  const salesData = globalStore.salesData || [];
  const rmMatrix = globalStore.rmMatrix || [];
  const paramLogs = globalStore.parameterChangeLogs || [];
  const rmLogs = globalStore.rmPriceHistoryLogs || [];

  const [selectedVendor, setSelectedVendor] = useState('Haier');
  const [isGenerating, setIsGenerating] = useState(false);
  const [userQuery, setUserQuery] = useState('');

  // Default to Gemini 3.6 Flash
  const [apiProvider, setApiProvider] = useState(localStorage.getItem('ai_analyst_provider') || 'gemini');
  const [geminiKey, setGeminiKey] = useState(localStorage.getItem('ai_gemini_key') || DEFAULT_GEMINI_KEY);
  const [openAiKey, setOpenAiKey] = useState(localStorage.getItem('ai_openai_key') || DEFAULT_OPENAI_KEY);
  const [geminiModel, setGeminiModel] = useState(localStorage.getItem('ai_gemini_model') || 'gemini-3.6-flash');
  const [openAiModel, setOpenAiModel] = useState(localStorage.getItem('ai_openai_model') || 'gpt-4o-mini');

  const [showConfigModal, setShowConfigModal] = useState(false);
  const [saveSuccessMsg, setSaveSuccessMsg] = useState(null);

  const [chatLog, setChatLog] = useState([
    {
      sender: 'ai',
      text: "👋 Welcome to your AI Costing & MIS Analyst. Powered by **Google Gemini 3.6 Flash** & OpenAI GPT-4o with **Strict Read-Only Sandbox Guardrails**. Ask me about product rankings, cycle time drift, or margin leaks."
    }
  ]);

  const vendorProducts = masterList.filter(item => selectedVendor === 'ALL' || item.vendor === selectedVendor);

  const portfolioStats = useMemo(() => {
    const list = vendorProducts.map(part => {
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

      const contractBaseline = Number(baselineCalc.totalCost.toFixed(2));
      const actualUnitCost = Number(runningCalc.totalCost.toFixed(2));
      const unitProfitLoss = Number((contractBaseline - actualUnitCost).toFixed(2));

      const matchedSales = salesData.filter(s => s.itemCode === part.itemCode);
      const qtySold = matchedSales.reduce((sum, s) => sum + Number(s.saleUnit || 0), 0);
      const totalPnL = Number((unitProfitLoss * qtySold).toFixed(2));
      const totalRevenue = Number((qtySold * (matchedSales[0]?.sellingPrice || (contractBaseline * 1.18))).toFixed(2));

      return {
        itemCode: part.itemCode,
        componentName: part.componentName,
        vendor: part.vendor || selectedVendor,
        approvedRm: part.approvedRm,
        contractBaseline,
        actualUnitCost,
        unitProfitLoss,
        qtySold,
        totalPnL,
        totalRevenue
      };
    });

    const sortedByPnL = [...list].sort((a, b) => b.totalPnL - a.totalPnL);
    return {
      list,
      bestPerformer: sortedByPnL[0],
      worstPerformer: sortedByPnL[sortedByPnL.length - 1],
      sortedByPnL,
      netPnL: list.reduce((acc, r) => acc + r.totalPnL, 0)
    };
  }, [vendorProducts, salesData, selectedVendor]);

  const buildReadOnlyContext = () => {
    return `[READ-ONLY SYSTEM SECURITY GUARDRAIL]
You are a Read-Only Manufacturing & Product Costing AI Intelligence Analyst.
You DO NOT have permission to edit or write records.
Use the following live snapshot to perform calculations, gap analyses, and root-cause audits:

--- LIVE DATA SNAPSHOT (VENDOR: ${selectedVendor}) ---
Portfolio Overview:
${JSON.stringify(portfolioStats.list, null, 2)}

Net Portfolio Realized Sales Variance: ₹${portfolioStats.netPnL.toFixed(2)}

Recent Parameter Modification Audit Trail:
${JSON.stringify(paramLogs.slice(0, 5), null, 2)}

RM Contract & Alternate Rate Locks:
${JSON.stringify(rmLogs.slice(0, 5), null, 2)}

RM Matrix Overview:
${JSON.stringify(rmMatrix, null, 2)}

Instructions:
- Provide clear analytical answers with exact rupee and percentage variances.
- Use bold numbers and clean Markdown formatting.`;
  };

  const executeQuery = async (query) => {
    const systemPrompt = buildReadOnlyContext();

    if (apiProvider === 'gemini') {
      const activeKey = geminiKey.trim() || DEFAULT_GEMINI_KEY;
      const cleanModel = (geminiModel || 'gemini-3.6-flash').replace('models/', '');
      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${cleanModel}:generateContent?key=${activeKey}`;

      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-goog-api-key': activeKey
        },
        body: JSON.stringify({
          contents: [
            { role: 'user', parts: [{ text: `${systemPrompt}\n\nUser Question: ${query}` }] }
          ]
        })
      });

      if (!response.ok) {
        if (openAiKey) {
          const fbResponse = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${openAiKey.trim()}`
            },
            body: JSON.stringify({
              model: 'gpt-4o-mini',
              messages: [
                { role: 'system', content: systemPrompt },
                { role: 'user', content: query }
              ],
              temperature: 0.2
            })
          });
          if (fbResponse.ok) {
            const fbData = await fbResponse.json();
            return `*(Answered via OpenAI GPT-4o Fallback)*\n\n` + fbData.choices[0]?.message?.content;
          }
        }
        const errData = await response.json().catch(() => ({}));
        throw new Error(errData.error?.message || `Gemini request failed (${response.status})`);
      }

      const data = await response.json();
      return data.candidates[0]?.content?.parts[0]?.text;
    } else {
      const activeKey = openAiKey.trim() || DEFAULT_OPENAI_KEY;
      const model = openAiModel || 'gpt-4o-mini';

      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${activeKey}`
        },
        body: JSON.stringify({
          model,
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: query }
          ],
          temperature: 0.2
        })
      });

      if (!response.ok) {
        const errData = await response.json().catch(() => ({}));
        throw new Error(errData.error?.message || `OpenAI request failed (${response.status})`);
      }

      const data = await response.json();
      return data.choices[0]?.message?.content;
    }
  };

  const handleSendQuery = async (e) => {
    e.preventDefault();
    if (!userQuery.trim() || isGenerating) return;

    const q = userQuery.trim();
    setChatLog(prev => [...prev, { sender: 'user', text: q }]);
    setUserQuery('');
    setIsGenerating(true);

    try {
      const reply = await executeQuery(q);
      setChatLog(prev => [...prev, { sender: 'ai', text: reply }]);
    } catch (err) {
      setChatLog(prev => [
        ...prev,
        {
          sender: 'ai',
          text: `⚠️ **API Error (${apiProvider.toUpperCase()}):** ${err.message}\n\nYou can switch to **OpenAI (GPT-4o)** using the Settings button above.`
        }
      ]);
    } finally {
      setIsGenerating(false);
    }
  };

  const handleSaveConfig = (e) => {
    e.preventDefault();
    localStorage.setItem('ai_analyst_provider', apiProvider);
    localStorage.setItem('ai_gemini_key', geminiKey.trim());
    localStorage.setItem('ai_gemini_model', geminiModel);
    localStorage.setItem('ai_openai_key', openAiKey.trim());
    localStorage.setItem('ai_openai_model', openAiModel);

    setSaveSuccessMsg('AI settings updated successfully.');
    setTimeout(() => {
      setSaveSuccessMsg(null);
      setShowConfigModal(false);
    }, 1000);
  };

  return (
    <div className="space-y-4 text-xs font-sans">
      
      {/* Top Banner */}
      <div className="bg-slate-900 text-white rounded-2xl p-4 shadow-md flex flex-wrap justify-between items-center gap-3">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-purple-600 rounded-xl">
            <Bot className="w-5 h-5 text-white" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-sm font-bold">5. AI Costing & MIS Predictive Intelligence</h1>
              <span className="bg-emerald-500/20 text-emerald-300 border border-emerald-500/40 text-[10px] font-bold px-2 py-0.5 rounded-full flex items-center gap-1">
                <Lock className="w-3 h-3" /> Read-Only Sandbox
              </span>
            </div>
            <p className="text-[11px] text-slate-300">Multi-Model Engine (Google Gemini 3.6 Flash & OpenAI GPT-4o)</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowConfigModal(true)}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-purple-300 border border-purple-700/60 rounded-xl font-bold transition cursor-pointer shadow-xs"
          >
            <Settings className="w-3.5 h-3.5" />
            <span>Active: {apiProvider === 'gemini' ? `Gemini (${geminiModel})` : `OpenAI (${openAiModel})`}</span>
          </button>

          <span className="text-[11px] font-bold text-slate-400 ml-1">Vendor:</span>
          <select
            value={selectedVendor}
            onChange={e => setSelectedVendor(e.target.value)}
            className="bg-slate-800 border border-slate-700 text-purple-300 font-bold px-3 py-1.5 rounded-xl text-xs outline-none cursor-pointer"
          >
            <option value="Haier">Haier Appliances</option>
            <option value="LG">LG Electronics</option>
            <option value="Whirlpool">Whirlpool India</option>
            <option value="ALL">All Combined</option>
          </select>
        </div>
      </div>

      {/* KPI Highlights */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
        <div className="bg-rose-50 border border-rose-200 rounded-2xl p-4 space-y-2">
          <div className="flex justify-between items-center">
            <span className="font-bold text-rose-900 flex items-center gap-1.5 text-xs">
              <AlertTriangle className="w-4 h-4 text-rose-600" /> Critical Margin Leakage
            </span>
            <span className="bg-rose-200 text-rose-900 px-2 py-0.5 rounded text-[10px] font-black">ATTENTION</span>
          </div>
          <p className="text-[11px] text-rose-800 font-medium leading-relaxed">
            <span className="font-bold">{portfolioStats.worstPerformer?.componentName || 'End Cap Top Ref'}</span> reflects a deficit of <span className="font-bold text-rose-900 font-mono">₹{Math.abs(portfolioStats.worstPerformer?.unitProfitLoss || 0.19).toFixed(2)}/unit</span>.
          </p>
        </div>

        <div className="bg-emerald-50 border border-emerald-200 rounded-2xl p-4 space-y-2">
          <div className="flex justify-between items-center">
            <span className="font-bold text-emerald-900 flex items-center gap-1.5 text-xs">
              <TrendingUp className="w-4 h-4 text-emerald-600" /> Top Margin Contributor
            </span>
            <span className="bg-emerald-200 text-emerald-900 px-2 py-0.5 rounded text-[10px] font-black">LEADER</span>
          </div>
          <p className="text-[11px] text-emerald-800 font-medium leading-relaxed">
            <span className="font-bold">{portfolioStats.bestPerformer?.componentName || 'CRISPER GPPS VEG BOX'}</span> delivers <span className="font-bold text-emerald-900 font-mono">+₹{portfolioStats.bestPerformer?.unitProfitLoss?.toFixed(2) || '1.91'}/unit</span> surplus margin.
          </p>
        </div>

        <div className="bg-purple-50 border border-purple-200 rounded-2xl p-4 space-y-2">
          <div className="flex justify-between items-center">
            <span className="font-bold text-purple-900 flex items-center gap-1.5 text-xs">
              <ShieldCheck className="w-4 h-4 text-purple-600" /> Data Guardrail Status
            </span>
            <span className="bg-purple-200 text-purple-900 px-2 py-0.5 rounded text-[10px] font-black">READ-ONLY</span>
          </div>
          <p className="text-[11px] text-purple-800 font-medium leading-relaxed">
            Zero mutation permissions assigned to LLM agents. All database baselines, schedules, and logs remain locked.
          </p>
        </div>
      </div>

      {/* Chat Area */}
      <div className="bg-white border border-slate-300 rounded-2xl shadow-sm p-4 space-y-3">
        <div className="flex justify-between items-center border-b pb-2">
          <div className="flex items-center gap-2">
            <Bot className="w-4 h-4 text-purple-600" />
            <h2 className="font-bold text-slate-900 text-sm">Ask AI Costing Analyst</h2>
          </div>
          <span className="text-[10px] text-purple-700 font-bold bg-purple-50 border border-purple-200 px-2.5 py-0.5 rounded-full flex items-center gap-1">
            <Sparkles className="w-3 h-3 text-purple-600" /> Live {apiProvider === 'gemini' ? 'Gemini 3.6 Flash' : 'OpenAI GPT-4o'} Active
          </span>
        </div>

        <div className="h-72 overflow-y-auto space-y-2.5 p-3.5 bg-slate-50 rounded-xl border border-slate-200">
          {chatLog.map((c, i) => (
            <div key={i} className={`flex ${c.sender === 'user' ? 'justify-end' : 'justify-start'}`}>
              <div className={`max-w-2xl p-3.5 rounded-2xl text-xs ${
                c.sender === 'user' 
                  ? 'bg-blue-600 text-white rounded-br-none shadow-xs font-semibold' 
                  : 'bg-white border border-slate-200 text-slate-800 rounded-bl-none shadow-2xs whitespace-pre-line leading-relaxed'
              }`}>
                {c.text}
              </div>
            </div>
          ))}
          {isGenerating && (
            <div className="flex justify-start">
              <div className="bg-white border border-slate-200 p-2.5 rounded-2xl text-slate-500 italic flex items-center gap-2">
                <RefreshCw className="w-3.5 h-3.5 animate-spin text-purple-600" /> Querying {apiProvider.toUpperCase()} in read-only sandbox...
              </div>
            </div>
          )}
        </div>

        {/* Suggestion Pills */}
        <div className="flex flex-wrap gap-2 pt-1">
          <button 
            type="button"
            onClick={() => setUserQuery('What are the latest changes in our baseline and RM logs?')}
            className="px-3 py-1 bg-slate-100 hover:bg-purple-100 hover:text-purple-900 border border-slate-200 rounded-lg text-xs font-semibold text-slate-700 transition cursor-pointer"
          >
            📋 What are the latest changes?
          </button>
          <button 
            type="button"
            onClick={() => setUserQuery('which are the best performing product')}
            className="px-3 py-1 bg-slate-100 hover:bg-purple-100 hover:text-purple-900 border border-slate-200 rounded-lg text-xs font-semibold text-slate-700 transition cursor-pointer"
          >
            🏆 Which product is performing better?
          </button>
          <button 
            type="button"
            onClick={() => setUserQuery('Identify top cost leakage areas and suggest cycle time/tonnage optimizations.')}
            className="px-3 py-1 bg-slate-100 hover:bg-purple-100 hover:text-purple-900 border border-slate-200 rounded-lg text-xs font-semibold text-slate-700 transition cursor-pointer"
          >
            🔍 Where are our top margin leaks?
          </button>
        </div>

        {/* Query Input Form */}
        <form onSubmit={handleSendQuery} className="flex gap-2">
          <input
            type="text"
            value={userQuery}
            onChange={e => setUserQuery(e.target.value)}
            placeholder={`Ask AI about ${selectedVendor} piece costing, variance leaks, cycle time drift, or audit trails...`}
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

      {/* Config Modal */}
      {showConfigModal && (
        <div className="fixed inset-0 bg-slate-900/75 backdrop-blur-xs flex items-center justify-center p-3 z-50 text-xs">
          <div className="bg-white rounded-2xl p-5 max-w-lg w-full space-y-4 border shadow-2xl animate-in fade-in duration-100">
            <div className="flex justify-between items-center border-b pb-2">
              <h3 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                <Settings className="w-4 h-4 text-purple-600" /> Configure AI Provider & Keys
              </h3>
              <button type="button" onClick={() => setShowConfigModal(false)} className="text-slate-400 hover:text-slate-600">✕</button>
            </div>

            {saveSuccessMsg && (
              <div className="bg-emerald-50 border border-emerald-300 text-emerald-900 p-2.5 rounded-xl font-bold flex items-center gap-2">
                <Check className="w-4 h-4 text-emerald-600" /> {saveSuccessMsg}
              </div>
            )}

            <form onSubmit={handleSaveConfig} className="space-y-3.5">
              <div>
                <label className="text-[10px] font-bold text-slate-500 uppercase block mb-1">Select Default Active Engine</label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => setApiProvider('gemini')}
                    className={`p-2.5 rounded-xl border text-center font-bold transition cursor-pointer ${
                      apiProvider === 'gemini' ? 'bg-purple-50 border-purple-600 text-purple-900' : 'bg-slate-50 border-slate-200 text-slate-700'
                    }`}
                  >
                    Google Gemini 3.6 Flash
                  </button>
                  <button
                    type="button"
                    onClick={() => setApiProvider('openai')}
                    className={`p-2.5 rounded-xl border text-center font-bold transition cursor-pointer ${
                      apiProvider === 'openai' ? 'bg-purple-50 border-purple-600 text-purple-900' : 'bg-slate-50 border-slate-200 text-slate-700'
                    }`}
                  >
                    OpenAI ChatGPT
                  </button>
                </div>
              </div>

              {/* Gemini Settings */}
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-200 space-y-2">
                <div className="font-bold text-slate-900 flex items-center justify-between">
                  <span>Google Gemini Setup</span>
                  <span className="text-[10px] text-emerald-700 font-bold bg-emerald-100 px-2 py-0.5 rounded">gemini-3.6-flash Active</span>
                </div>
                <div>
                  <label className="text-[10px] font-bold text-slate-500 uppercase block">Gemini API Key</label>
                  <input
                    type="password"
                    value={geminiKey}
                    onChange={e => setGeminiKey(e.target.value)}
                    className="w-full border bg-white p-2 rounded-lg text-xs font-mono mt-0.5 outline-none"
                    placeholder="AQ.Ab8RN6Ks..."
                  />
                </div>
                <div>
                  <label className="text-[10px] font-bold text-slate-500 uppercase block">Model</label>
                  <select
                    value={geminiModel}
                    onChange={e => setGeminiModel(e.target.value)}
                    className="w-full border bg-white p-1.5 rounded-lg text-xs font-semibold mt-0.5 outline-none"
                  >
                    <option value="gemini-3.6-flash">gemini-3.6-flash (Recommended)</option>
                  </select>
                </div>
              </div>

              {/* OpenAI Settings */}
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-200 space-y-2">
                <div className="font-bold text-slate-900 flex items-center justify-between">
                  <span>OpenAI Configuration</span>
                </div>
                <div>
                  <label className="text-[10px] font-bold text-slate-500 uppercase block">OpenAI Secret Key</label>
                  <input
                    type="password"
                    value={openAiKey}
                    onChange={e => setOpenAiKey(e.target.value)}
                    className="w-full border bg-white p-2 rounded-lg text-xs font-mono mt-0.5 outline-none"
                    placeholder="sk-proj-Hh_qB..."
                  />
                </div>
                <div>
                  <label className="text-[10px] font-bold text-slate-500 uppercase block">Model</label>
                  <select
                    value={openAiModel}
                    onChange={e => setOpenAiModel(e.target.value)}
                    className="w-full border bg-white p-1.5 rounded-lg text-xs font-semibold mt-0.5 outline-none"
                  >
                    <option value="gpt-4o-mini">gpt-4o-mini</option>
                    <option value="gpt-4o">gpt-4o</option>
                  </select>
                </div>
              </div>

              <div className="flex justify-end gap-2 pt-2 border-t">
                <button type="button" onClick={() => setShowConfigModal(false)} className="px-3 py-1.5 border rounded-lg">Cancel</button>
                <button type="submit" className="px-4 py-1.5 bg-purple-600 text-white font-bold rounded-lg shadow-sm">Save & Apply</button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
