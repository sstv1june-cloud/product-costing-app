import React, { useState } from 'react';
import { History, ShieldAlert } from 'lucide-react';
import { formatDateDDMMYY } from '../../shared/dateHelper';

export default function ParameterChangeLogPage() {
  const [logs] = useState([
    {
      id: "LOG-001",
      timestamp: new Date().toISOString(),
      itemCode: "0060226713H",
      componentName: "End Cap Top Ref",
      changedBy: "Engineering Head",
      field: "Cycle Time",
      oldValue: "52s",
      newValue: "48s",
      reason: "Mold cooling optimization"
    },
    {
      id: "LOG-002",
      timestamp: new Date(Date.now() - 86400000 * 2).toISOString(),
      itemCode: "0060217978E",
      componentName: "CRISPER GPPS LV",
      changedBy: "Costing Lead",
      field: "Approved RM Rate",
      oldValue: "₹106.50",
      newValue: "₹103.08",
      reason: "Quarterly polymer index reset"
    }
  ]);

  return (
    <div className="space-y-4 text-xs">
      <div className="bg-slate-900 text-white rounded-2xl p-5 shadow-md flex justify-between items-center">
        <div className="flex items-center gap-3">
          <div className="p-2.5 bg-amber-600 rounded-xl">
            <History className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-base font-bold">Engineering Parameter Audit Trail & Change Log</h1>
            <p className="text-xs text-slate-300">Historical track of cycle time, weight, and tariff baseline modifications</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs p-5 space-y-4">
        <div className="border border-slate-200 rounded-xl overflow-hidden">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 text-slate-700 font-bold text-[10px] uppercase">
              <tr>
                <th className="p-3">Date</th>
                <th className="p-3">Part Number</th>
                <th className="p-3">Component Description</th>
                <th className="p-3">Modified Parameter</th>
                <th className="p-3 text-right">Old Value</th>
                <th className="p-3 text-right">New Value</th>
                <th className="p-3">Authorized By</th>
                <th className="p-3">Justification</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {logs.map((log) => (
                <tr key={log.id} className="hover:bg-slate-50">
                  <td className="p-3 font-mono text-slate-500">{formatDateDDMMYY(log.timestamp)}</td>
                  <td className="p-3 font-mono font-bold text-blue-700">{log.itemCode}</td>
                  <td className="p-3 font-semibold text-slate-900">{log.componentName}</td>
                  <td className="p-3 font-medium text-purple-700">{log.field}</td>
                  <td className="p-3 text-right font-mono text-rose-600 line-through">{log.oldValue}</td>
                  <td className="p-3 text-right font-mono font-bold text-emerald-700">{log.newValue}</td>
                  <td className="p-3 text-slate-600">{log.changedBy}</td>
                  <td className="p-3 text-slate-500 italic">{log.reason}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
