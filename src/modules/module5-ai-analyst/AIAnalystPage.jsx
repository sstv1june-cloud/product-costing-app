import React, { useState } from 'react';
import { Bot, Send, Sparkles } from 'lucide-react';

export default function AIAnalystPage() {
  const [input, setInput] = useState('');
  const [messages, setMessages] = useState([
    { sender: 'ai', text: 'Hello! I am your CPC Costing & Profitability Analyst. Ask me anything about your baseline cycle times, polymer price variance, or gross margins.' }
  ]);

  const handleSend = (e) => {
    e.preventDefault();
    if (!input.trim()) return;
    const userMsg = { sender: 'user', text: input };
    const reply = { sender: 'ai', text: `Analysis for "${input}": Your current gross margin across active Haier items stands at 18.2%, with a favorable variance gain of ₹13,440 generated primarily by GPPS raw material savings.` };
    setMessages(prev => [...prev, userMsg, reply]);
    setInput('');
  };

  return (
    <div className="space-y-4 text-xs">
      <div className="bg-slate-900 text-white rounded-2xl p-5 shadow-md flex justify-between items-center">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-purple-600 rounded-xl"><Bot className="w-6 h-6 text-white" /></div>
          <div>
            <h1 className="text-base font-bold">AI Product Costing Analyst</h1>
            <p className="text-xs text-slate-300">Automated financial variance detection and contract negotiation insights</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs p-5 flex flex-col h-[500px]">
        <div className="flex-1 overflow-y-auto space-y-3 p-2">
          {messages.map((m, idx) => (
            <div key={idx} className={`flex ${m.sender === 'user' ? 'justify-end' : 'justify-start'}`}>
              <div className={`max-w-[75%] p-3 rounded-2xl text-xs ${
                m.sender === 'user' ? 'bg-purple-600 text-white font-medium' : 'bg-slate-100 text-slate-800 border border-slate-200'
              }`}>
                {m.text}
              </div>
            </div>
          ))}
        </div>

        <form onSubmit={handleSend} className="flex gap-2 pt-3 border-t border-slate-200">
          <input
            type="text"
            placeholder="Ask AI Analyst a question..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            className="flex-1 border border-slate-300 rounded-xl p-2.5 text-xs outline-none focus:ring-2 focus:ring-purple-500"
          />
          <button type="submit" className="px-4 bg-purple-600 text-white font-bold rounded-xl flex items-center gap-1 cursor-pointer">
            <Send className="w-3.5 h-3.5" /> Send
          </button>
        </form>
      </div>
    </div>
  );
}
