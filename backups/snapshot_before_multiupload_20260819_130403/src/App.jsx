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
