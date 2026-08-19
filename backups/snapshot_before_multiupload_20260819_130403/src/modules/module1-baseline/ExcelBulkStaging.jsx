import React from 'react';

export default function ExcelBulkStaging({ stagingData = [], onConfirm, onCancel }) {
  if (!stagingData || stagingData.length === 0) return null;

  return (
    <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50 text-xs">
      <div className="bg-white rounded-2xl shadow-xl max-w-4xl w-full max-h-[85vh] overflow-y-auto p-5 space-y-4">
        <h3 className="text-sm font-bold text-slate-900">Excel Bulk Import Preview</h3>
        <p className="text-slate-500">Staging {stagingData.length} records for baseline ingestion.</p>
        
        <div className="border border-slate-200 rounded-xl overflow-x-auto max-h-60">
          <table className="min-w-full text-xs text-left">
            <thead className="bg-slate-100 uppercase font-bold text-[10px]">
              <tr>
                <th className="p-2">Part No</th>
                <th className="p-2">Name</th>
                <th className="p-2">Rate</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {stagingData.map((row, idx) => (
                <tr key={idx}>
                  <td className="p-2 font-mono">{row["Part Number"] || row.itemCode}</td>
                  <td className="p-2">{row["Component Name"] || row.componentName}</td>
                  <td className="p-2 font-mono">₹{row["Approved RM Rate (₹/kg)"] || row.approvedRmRate}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="flex justify-end gap-2 pt-2 border-t">
          <button onClick={onCancel} className="px-4 py-1.5 border rounded-lg cursor-pointer">Cancel</button>
          <button onClick={() => onConfirm?.(stagingData)} className="px-4 py-1.5 bg-blue-600 text-white font-bold rounded-lg cursor-pointer">Commit Staging</button>
        </div>
      </div>
    </div>
  );
}
