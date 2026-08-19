import React, { useState } from 'react';
import { Settings, Layers, Calculator, BarChart3, Sliders, Bot } from 'lucide-react';
import BaselineMasterPage from './modules/module1-baseline/BaselineMasterPage';
import RMPriceMatrixPage from './modules/module2-rm-matrix/RMPriceMatrixPage';
import CostingRunEnginePage from './modules/module3-costing-engine/CostingRunEnginePage';
import MISReportsPage from './modules/module4-mis-gap/MISReportsPage';
import AdminWorkspacePage from './modules/module0-admin/AdminWorkspacePage';
import AIAnalystPage from './modules/module5-ai-analyst/AIAnalystPage';

export default function App() {
  const [activeModule, setActiveModule] = useState('baseline'); // 'admin' | 'baseline' | 'rm' | 'costing' | 'mis' | 'ai'

  return (
    <div className="min-h-screen bg-slate-100 text-slate-900 flex flex-col font-sans">
      {/* Header */}
      <header className="bg-slate-950 text-white border-b border-slate-800 sticky top-0 z-40 shadow-md">
        <div className="max-w-7xl mx-auto px-4 py-3 flex flex-wrap justify-between items-center gap-4">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 bg-blue-600 rounded-xl flex items-center justify-center font-bold text-base tracking-wider text-white shadow-lg">
              CPC
            </div>
            <div>
              <h1 className="text-sm font-bold tracking-tight">Product Costing & MIS Control System</h1>
              <p className="text-[10px] text-slate-400">Multi-Vendor Approved vs Actual Costing Engine</p>
            </div>
          </div>

          {/* Navigation Bar */}
          <nav className="flex items-center gap-1 bg-slate-900/90 p-1.5 rounded-xl border border-slate-800 text-xs flex-wrap">
            <button
              onClick={() => setActiveModule('admin')}
              className={`flex items-center gap-1 px-2.5 py-1.5 rounded-lg font-bold transition cursor-pointer ${
                activeModule === 'admin' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white hover:bg-slate-800'
              }`}
            >
              <Settings className="w-3.5 h-3.5" /> 0. Admin
            </button>

            <button
              onClick={() => setActiveModule('baseline')}
              className={`flex items-center gap-1 px-2.5 py-1.5 rounded-lg font-bold transition cursor-pointer ${
                activeModule === 'baseline' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white hover:bg-slate-800'
              }`}
            >
              <Sliders className="w-3.5 h-3.5" /> 1. Baseline Master
            </button>

            <button
              onClick={() => setActiveModule('rm')}
              className={`flex items-center gap-1 px-2.5 py-1.5 rounded-lg font-bold transition cursor-pointer ${
                activeModule === 'rm' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white hover:bg-slate-800'
              }`}
            >
              <Layers className="w-3.5 h-3.5" /> 2. RM & Matrix
            </button>

            <button
              onClick={() => setActiveModule('costing')}
              className={`flex items-center gap-1 px-2.5 py-1.5 rounded-lg font-bold transition cursor-pointer ${
                activeModule === 'costing' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white hover:bg-slate-800'
              }`}
            >
              <Calculator className="w-3.5 h-3.5" /> 3. Costing Engine
            </button>

            <button
              onClick={() => setActiveModule('mis')}
              className={`flex items-center gap-1 px-2.5 py-1.5 rounded-lg font-bold transition cursor-pointer ${
                activeModule === 'mis' ? 'bg-blue-600 text-white shadow' : 'text-slate-300 hover:text-white hover:bg-slate-800'
              }`}
            >
              <BarChart3 className="w-3.5 h-3.5" /> 4. MIS & Gap
            </button>

            <button
              onClick={() => setActiveModule('ai')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-bold transition cursor-pointer ${
                activeModule === 'ai' ? 'bg-purple-600 text-white shadow' : 'text-purple-300 hover:text-white hover:bg-purple-950/60'
              }`}
            >
              <Bot className="w-3.5 h-3.5" /> 5. AI Analyst
            </button>
          </nav>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-4 md:p-6">
        {activeModule === 'admin' && <AdminWorkspacePage />}
        {activeModule === 'baseline' && <BaselineMasterPage />}
        {activeModule === 'rm' && <RMPriceMatrixPage />}
        {activeModule === 'costing' && <CostingRunEnginePage />}
        {activeModule === 'mis' && <MISReportsPage />}
        {activeModule === 'ai' && <AIAnalystPage />}
      </main>
    </div>
  );
}