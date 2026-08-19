import React, { useState } from 'react';
import { X, Building2, Plus } from 'lucide-react';

export default function VendorOnboardingModal({ isOpen, onClose, onSave }) {
  const [formData, setFormData] = useState({
    vendorId: '',
    vendorName: '',
    category: 'Injection Molding'
  });

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.vendorId || !formData.vendorName) return;
    onSave?.({
      ...formData,
      status: 'Active',
      onboardedDate: new Date().toISOString().slice(0, 10),
      adapterKey: 'default'
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-2xl shadow-xl max-w-md w-full p-5 space-y-4 text-xs">
        <div className="flex justify-between items-center border-b pb-3">
          <h3 className="font-bold text-slate-900 flex items-center gap-1.5 text-sm">
            <Building2 className="w-4 h-4 text-blue-600" /> Onboard New Vendor
          </h3>
          <button onClick={onClose} className="p-1 text-slate-400 hover:text-slate-700 cursor-pointer">
            <X className="w-4 h-4" />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="space-y-3">
          <div>
            <label className="text-[10px] font-bold text-slate-500 uppercase block mb-1">Vendor ID / Code</label>
            <input
              type="text"
              placeholder="e.g. VND-WHIRLPOOL"
              value={formData.vendorId}
              onChange={(e) => setFormData({ ...formData, vendorId: e.target.value.toUpperCase() })}
              className="w-full border border-slate-300 rounded-lg p-2 font-mono uppercase text-xs"
              required
            />
          </div>
          <div>
            <label className="text-[10px] font-bold text-slate-500 uppercase block mb-1">Company Name</label>
            <input
              type="text"
              placeholder="e.g. Whirlpool India"
              value={formData.vendorName}
              onChange={(e) => setFormData({ ...formData, vendorName: e.target.value })}
              className="w-full border border-slate-300 rounded-lg p-2 text-xs"
              required
            />
          </div>
          <div>
            <label className="text-[10px] font-bold text-slate-500 uppercase block mb-1">Category</label>
            <select
              value={formData.category}
              onChange={(e) => setFormData({ ...formData, category: e.target.value })}
              className="w-full border border-slate-300 rounded-lg p-2 text-xs"
            >
              <option value="Injection Molding">Injection Molding</option>
              <option value="Sheet Metal">Sheet Metal</option>
            </select>
          </div>
          <div className="flex justify-end gap-2 pt-2 border-t">
            <button type="button" onClick={onClose} className="px-3 py-1.5 border rounded-lg cursor-pointer">
              Cancel
            </button>
            <button type="submit" className="px-4 py-1.5 bg-blue-600 text-white font-bold rounded-lg cursor-pointer flex items-center gap-1">
              <Plus className="w-3.5 h-3.5" /> Save Vendor
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
