import React, { useState } from 'react';
import { Palette, Plus } from 'lucide-react';
import { getStoredMbData, saveMbData } from '../../shared/mbData';

export default function MasterBatchPage() {
  const [mbList, setMbList] = useState(getStoredMbData);

  return (
    <div className="space-y-4 text-xs">
      <div className="bg-slate-900 text-white rounded-2xl p-5 shadow-md flex justify-between items-center">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-rose-600 rounded-xl"><Palette className="w-6 h-6 text-white" /></div>
          <div>
            <h1 className="text-base font-bold">Masterbatch (MB) Color Master & Dosage Matrix</h1>
            <p className="text-xs text-slate-300">Color compounding shades, standard dosing percentages, and inward rates</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs p-5">
        <div className="border border-slate-200 rounded-xl overflow-hidden">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold text-[10px] uppercase">
              <tr>
                <th className="p-3">MB Code</th>
                <th className="p-3">Shade Spec</th>
                <th className="p-3">Carrier Polymer</th>
                <th className="p-3">Supplier</th>
                <th className="p-3 text-right">Approved Rate (₹/kg)</th>
                <th className="p-3 text-right">Std Dosage %</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {mbList.map((mb) => (
                <tr key={mb.mbCode} className="hover:bg-slate-50">
                  <td className="p-3 font-mono font-bold text-purple-700">{mb.mbCode}</td>
                  <td className="p-3 font-semibold text-slate-900">{mb.shadeName}</td>
                  <td className="p-3 text-slate-600">{mb.carrierPolymer}</td>
                  <td className="p-3 text-slate-600">{mb.supplier}</td>
                  <td className="p-3 text-right font-mono font-semibold">₹{mb.approvedRateKg.toFixed(2)}</td>
                  <td className="p-3 text-right font-mono font-bold text-blue-700">{mb.standardDosagePct}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
