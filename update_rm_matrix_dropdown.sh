#!/usr/bin/env bash
set -e

# Find exact file imported by App.jsx for RM Matrix
RM_FILE=$(grep -rn "module2" src/App.jsx 2>/dev/null | awk '{print $NF}' | tr -d "';\"," || true)
if [ -z "$RM_FILE" ]; then
  TARGET_PATH="src/modules/module2-rm-matrix/RMPriceMatrixPage.jsx"
else
  TARGET_PATH="src/${RM_FILE#./}.jsx"
  [ -f "$TARGET_PATH" ] || TARGET_PATH="src/${RM_FILE#./}"
fi

echo "==> Updating target RM file: $TARGET_PATH"

cat << 'PAGE_EOF' > "$TARGET_PATH"
import React, { useState, useEffect } from 'react';
import { 
  globalStore, 
  subscribeStore, 
  updateRmMappingRow, 
  addDayWisePurchase, 
  addDayWiseSales 
} from '../../shared/masterStore';
import { 
  Lock, 
  Unlock, 
  Save, 
  FileSpreadsheet, 
  ShoppingCart, 
  Truck, 
  History, 
  CheckCircle2, 
  Calendar, 
  Filter, 
  Plus, 
  ChevronDown 
} from 'lucide-react';

export default function RMPriceMatrixPage() {
  const [, setTick] = useState(0);
  const [activeTab, setActiveTab] = useState('matrix');
  const [selectedVendor, setSelectedVendor] = useState('Haier Appliances');
  const [periodFrom, setPeriodFrom] = useState('2026-08-01');
  const [periodTo, setPeriodTo] = useState('2026-08-31');
  const [saveSuccess, setSaveSuccess] = useState(false);

  const [newPur, setNewPur] = useState({ date: '2026-08-15', grade: '', qty: '', rate: '', invoiceNo: '' });
  const [newSale, setNewSale] = useState({ date: '2026-08-15', itemCode: '', componentName: '', qty: '', sellingPrice: '' });

  useEffect(() => {
    return subscribeStore(() => setTick(t => t + 1));
  }, []);

  const isLocked = globalStore.isGlobalLocked;
  const rawVendorKey = selectedVendor.toLowerCase().includes('haier') ? 'Haier' : 'Atomberg';

  const currentMappings = (globalStore.rmMappingsData || []).filter(
    m => (m.vendor || '').toLowerCase().includes(rawVendorKey.toLowerCase())
  );

  const availablePurchaseGrades = Array.from(new Set(
    (globalStore.purchases || [])
      .filter(p => (p.vendor || '').toLowerCase().includes(rawVendorKey.toLowerCase()))
      .map(p => p.grade)
  )).filter(Boolean);

  const handleActiveAltChange = (rowId, altKey) => {
    if (isLocked) return;
    updateRmMappingRow(rowId, { activeAlt: altKey }, `Active alternate switched to ${altKey.toUpperCase()}`);
  };

  const handleDropdownSelect = (rowId, altSlot, selectedGrade) => {
    if (isLocked) return;
    const purMatch = (globalStore.purchases || []).find(
      p => (p.vendor || '').toLowerCase().includes(rawVendorKey.toLowerCase()) && p.grade === selectedGrade
    );
    const updates = { [`${altSlot}Code`]: selectedGrade };
    if (purMatch && purMatch.rate) {
      updates[`${altSlot}Price`] = Number(purMatch.rate);
    }
    updateRmMappingRow(rowId, updates, `Updated ${altSlot.toUpperCase()} to ${selectedGrade}`);
  };

  const handlePriceChange = (rowId, altSlot, newPrice) => {
    if (isLocked) return;
    updateRmMappingRow(rowId, { [`${altSlot}Price`]: Number(newPrice) || 0 }, `Updated ${altSlot.toUpperCase()} price`);
  };

  const handleSavePeriod = () => {
    setSaveSuccess(true);
    setTimeout(() => setSaveSuccess(false), 3000);
  };

  const handleAddPurchase = (e) => {
    e.preventDefault();
    if (!newPur.grade || !newPur.qty || !newPur.rate) return;
    addDayWisePurchase({
      id: `pur-${Date.now()}`,
      date: newPur.date,
      vendor: rawVendorKey,
      grade: newPur.grade,
      qty: Number(newPur.qty),
      rate: Number(newPur.rate),
      invoiceNo: newPur.invoiceNo || `INV-${Date.now().toString().slice(-4)}`
    });
    setNewPur({ date: '2026-08-15', grade: '', qty: '', rate: '', invoiceNo: '' });
  };

  const handleAddSale = (e) => {
    e.preventDefault();
    if (!newSale.itemCode || !newSale.qty || !newSale.sellingPrice) return;
    addDayWiseSales({
      id: `sale-${Date.now()}`,
      date: newSale.date,
      vendor: rawVendorKey,
      itemCode: newSale.itemCode,
      componentName: newSale.componentName || 'Molded Component',
      qty: Number(newSale.qty),
      sellingPrice: Number(newSale.sellingPrice)
    });
    setNewSale({ date: '2026-08-15', itemCode: '', componentName: '', qty: '', sellingPrice: '' });
  };

  const getDropdownOptions = (row, currentVal) => {
    const list = new Set([
      currentVal,
      row.approvedCode,
      row.alt1Code,
      row.alt2Code,
      row.alt3Code,
      ...availablePurchaseGrades
    ]);
    return Array.from(list).filter(Boolean);
  };

  const renderAltCell = (row, altSlot) => {
    const altCodeKey = `${altSlot}Code`;
    const isActive = (row.activeAlt || 'alt1') === altSlot;
    const currentVal = row[altCodeKey] || '';
    const options = getDropdownOptions(row, currentVal);

    return (
      <td className="py-2.5 px-3">
        <div className={`p-2 rounded-xl border transition-all flex flex-col gap-2 ${
          isActive 
            ? 'border-blue-500 bg-blue-50/70 shadow-sm ring-1 ring-blue-400/40' 
            : 'border-slate-200 bg-slate-50/50 hover:border-slate-300'
        }`}>
          {/* Dropdown Material Selector */}
          <div className="relative flex items-center">
            <select
              disabled={isLocked}
              value={currentVal}
              onChange={(e) => handleDropdownSelect(row.id, altSlot, e.target.value)}
              className="w-full appearance-none bg-white border border-slate-300 rounded-lg pl-2.5 pr-7 py-1.5 text-xs font-semibold text-slate-800 outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-100 disabled:text-slate-700 disabled:cursor-not-allowed shadow-sm truncate"
            >
              {options.map((opt, idx) => (
                <option key={idx} value={opt}>{opt}</option>
              ))}
            </select>
            <ChevronDown className="w-3.5 h-3.5 text-slate-400 absolute right-2 pointer-events-none" />
          </div>

          {/* Radio Button Selector */}
          <div className="flex items-center justify-between pt-1 border-t border-slate-200/70">
            <label className="flex items-center gap-2 cursor-pointer select-none">
              <input
                type="radio"
                name={`activeAlt-${row.id}`}
                checked={isActive}
                disabled={isLocked}
                onChange={() => handleActiveAltChange(row.id, altSlot)}
                className="w-4 h-4 text-blue-600 focus:ring-blue-500 cursor-pointer disabled:cursor-not-allowed"
              />
              <span className="text-[11px] font-bold text-slate-700">Set Active</span>
            </label>
            <span className={`px-2 py-0.5 rounded text-[10px] font-black uppercase tracking-wider ${
              isActive ? 'bg-blue-600 text-white shadow-xs' : 'bg-slate-200 text-slate-600'
            }`}>
              {isActive ? 'Active' : 'Standby'}
            </span>
          </div>
        </div>
      </td>
    );
  };

  return (
    <div className="space-y-6 pb-12">
      {/* Header Banner */}
      <div className="bg-[#0f172a] text-white p-6 rounded-2xl shadow-xl flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-blue-600/30 rounded-xl border border-blue-500/30 text-blue-400">
            <FileSpreadsheet className="w-8 h-8" />
          </div>
          <div>
            <h1 className="text-xl md:text-2xl font-bold tracking-tight">RM Mapping & Inward Registry</h1>
            <p className="text-sm text-slate-400">Synchronized RM & MB Baseline to Purchase Weighted Average Mapping</p>
          </div>
        </div>

        <button 
          onClick={() => {
            globalStore.isGlobalLocked = !globalStore.isGlobalLocked;
            setTick(t => t + 1);
          }}
          className={`flex items-center gap-2 px-5 py-2.5 rounded-xl font-bold text-sm shadow-md transition-all ${
            isLocked 
              ? 'bg-amber-500 hover:bg-amber-600 text-white shadow-amber-500/20' 
              : 'bg-emerald-600 hover:bg-emerald-700 text-white shadow-emerald-600/20'
          }`}
        >
          {isLocked ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4" />}
          {isLocked ? 'Page Locked (Click to Unlock & Edit)' : 'Page Unlocked (Editing Active)'}
        </button>
      </div>

      {/* Sub Tabs */}
      <div className="flex flex-wrap gap-2 border-b border-slate-200 pb-2">
        <button
          onClick={() => setActiveTab('matrix')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all ${
            activeTab === 'matrix' ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' : 'bg-white text-slate-600 hover:bg-slate-100'
          }`}
        >
          <FileSpreadsheet className="w-4 h-4" /> RM Price Matrix
        </button>
        <button
          onClick={() => setActiveTab('purchases')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all ${
            activeTab === 'purchases' ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' : 'bg-white text-slate-600 hover:bg-slate-100'
          }`}
        >
          <ShoppingCart className="w-4 h-4" /> Day-wise Purchases ({(globalStore.purchases || []).length})
        </button>
        <button
          onClick={() => setActiveTab('sales')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all ${
            activeTab === 'sales' ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' : 'bg-white text-slate-600 hover:bg-slate-100'
          }`}
        >
          <Truck className="w-4 h-4" /> Day-wise Sales ({(globalStore.sales || []).length})
        </button>
        <button
          onClick={() => setActiveTab('logs')}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-bold transition-all ${
            activeTab === 'logs' ? 'bg-blue-600 text-white shadow-md shadow-blue-500/20' : 'bg-white text-slate-600 hover:bg-slate-100'
          }`}
        >
          <History className="w-4 h-4" /> Baseline & RM Change Log ({(globalStore.parameterChangeLogs || []).length})
        </button>
      </div>

      {/* Filter Scope Toolbar */}
      <div className="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-sm flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-blue-600 font-bold" />
            <span className="text-xs font-black uppercase tracking-wider text-slate-500">FILTER:</span>
            <span className="text-xs font-bold text-slate-700">Vendor:</span>
            <select 
              value={selectedVendor} 
              onChange={e => setSelectedVendor(e.target.value)}
              className="bg-slate-50 border border-slate-300 text-slate-800 text-sm font-bold rounded-lg px-3 py-1.5 focus:ring-2 focus:ring-blue-500 outline-none cursor-pointer"
            >
              <option value="Haier Appliances">Haier Appliances</option>
              <option value="Atomberg Technologies">Atomberg Technologies</option>
            </select>
          </div>

          <div className="flex items-center gap-2">
            <Calendar className="w-4 h-4 text-slate-400" />
            <span className="text-xs font-bold text-slate-600">Period:</span>
            <span className="text-xs text-slate-400">From</span>
            <input 
              type="date" 
              value={periodFrom} 
              onChange={e => setPeriodFrom(e.target.value)}
              className="bg-slate-50 border border-slate-300 text-slate-700 text-xs font-medium rounded-lg px-2 py-1 outline-none"
            />
            <span className="text-xs text-slate-400">To</span>
            <input 
              type="date" 
              value={periodTo} 
              onChange={e => setPeriodTo(e.target.value)}
              className="bg-slate-50 border border-slate-300 text-slate-700 text-xs font-medium rounded-lg px-2 py-1 outline-none"
            />
          </div>
        </div>

        <button 
          onClick={handleSavePeriod}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-4 py-2 rounded-xl transition-all shadow-sm"
        >
          <Save className="w-4 h-4" /> Save for Vendor + period
        </button>
      </div>

      {saveSuccess && (
        <div className="p-3 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl text-xs font-bold flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4 text-emerald-600" /> Vendor and period schedule saved successfully.
        </div>
      )}

      {/* MATRIX TABLE */}
      {activeTab === 'matrix' && (
        <div className="bg-white border border-slate-200 rounded-2xl shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-[#0b1329] text-white uppercase text-[11px] tracking-wider font-semibold border-b border-slate-800">
                  <th className="py-3.5 px-4 font-bold min-w-[200px]">Approved RM/MB Code</th>
                  <th className="py-3.5 px-3 font-bold text-center bg-[#152347] min-w-[120px]">Approved Price (₹/kg)</th>
                  <th className="py-3.5 px-3 font-bold min-w-[230px]">Alternate RM-1</th>
                  <th className="py-3.5 px-3 font-bold text-center bg-[#152347] min-w-[90px]">Price (WA)</th>
                  <th className="py-3.5 px-3 font-bold min-w-[230px]">Alternate RM-2</th>
                  <th className="py-3.5 px-3 font-bold text-center bg-[#152347] min-w-[90px]">Price (WA)</th>
                  <th className="py-3.5 px-3 font-bold min-w-[230px]">Alternate RM-3</th>
                  <th className="py-3.5 px-3 font-bold text-center bg-[#152347] min-w-[90px]">Price (WA)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {currentMappings.map((row) => (
                  <tr key={row.id} className="hover:bg-slate-50/80 transition-colors">
                    {/* Approved RM/MB Code */}
                    <td className="py-3 px-4">
                      <div className="flex items-center gap-2">
                        <span className={`px-2 py-0.5 rounded text-[10px] font-black uppercase ${
                          row.type === 'MB' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'
                        }`}>
                          {row.type === 'MB' ? 'Masterbatch' : 'RM Code'}
                        </span>
                        <span className="font-bold text-slate-900">{row.approvedCode}</span>
                      </div>
                    </td>

                    {/* Approved Price */}
                    <td className="py-3 px-3 text-center bg-slate-50/50">
                      <div className="inline-flex items-center justify-center font-bold text-slate-900 bg-white border border-slate-200 px-3 py-1.5 rounded-lg text-xs shadow-sm">
                        ₹ {Number(row.approvedPrice || 0).toFixed(2)}
                      </div>
                    </td>

                    {/* Alt 1 */}
                    {renderAltCell(row, 'alt1')}
                    <td className="py-3 px-3 text-center bg-slate-50/50">
                      {isLocked ? (
                        <span className="font-bold text-blue-600">₹{Number(row.alt1Price || 0).toFixed(2)}</span>
                      ) : (
                        <input 
                          type="number"
                          step="0.01"
                          value={row.alt1Price || 0}
                          onChange={(e) => handlePriceChange(row.id, 'alt1', e.target.value)}
                          className="w-20 text-center font-bold text-blue-700 bg-white border border-blue-300 rounded-lg px-2 py-1 text-xs shadow-sm outline-none focus:ring-2 focus:ring-blue-500"
                        />
                      )}
                    </td>

                    {/* Alt 2 */}
                    {renderAltCell(row, 'alt2')}
                    <td className="py-3 px-3 text-center bg-slate-50/50">
                      {isLocked ? (
                        <span className="font-bold text-slate-800">₹{Number(row.alt2Price || 0).toFixed(2)}</span>
                      ) : (
                        <input 
                          type="number"
                          step="0.01"
                          value={row.alt2Price || 0}
                          onChange={(e) => handlePriceChange(row.id, 'alt2', e.target.value)}
                          className="w-20 text-center font-bold text-slate-800 bg-white border border-slate-300 rounded-lg px-2 py-1 text-xs shadow-sm outline-none focus:ring-2 focus:ring-blue-500"
                        />
                      )}
                    </td>

                    {/* Alt 3 */}
                    {renderAltCell(row, 'alt3')}
                    <td className="py-3 px-3 text-center bg-slate-50/50">
                      {isLocked ? (
                        <span className="font-bold text-slate-800">₹{Number(row.alt3Price || 0).toFixed(2)}</span>
                      ) : (
                        <input 
                          type="number"
                          step="0.01"
                          value={row.alt3Price || 0}
                          onChange={(e) => handlePriceChange(row.id, 'alt3', e.target.value)}
                          className="w-20 text-center font-bold text-slate-800 bg-white border border-slate-300 rounded-lg px-2 py-1 text-xs shadow-sm outline-none focus:ring-2 focus:ring-blue-500"
                        />
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 2: DAY-WISE PURCHASES */}
      {activeTab === 'purchases' && (
        <div className="space-y-4">
          <form onSubmit={handleAddPurchase} className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-wrap items-center gap-3">
            <span className="text-xs font-bold text-slate-700">Add Purchase Inward:</span>
            <input 
              type="date" 
              value={newPur.date} 
              onChange={e => setNewPur({...newPur, date: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none"
              required
            />
            <input 
              type="text" 
              placeholder="Inward RM Grade" 
              value={newPur.grade} 
              onChange={e => setNewPur({...newPur, grade: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none min-w-[200px]"
              required
            />
            <input 
              type="number" 
              placeholder="Qty (kg)" 
              value={newPur.qty} 
              onChange={e => setNewPur({...newPur, qty: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-24"
              required
            />
            <input 
              type="number" 
              step="0.01"
              placeholder="Rate (₹/kg)" 
              value={newPur.rate} 
              onChange={e => setNewPur({...newPur, rate: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-24"
              required
            />
            <input 
              type="text" 
              placeholder="Invoice #" 
              value={newPur.invoiceNo} 
              onChange={e => setNewPur({...newPur, invoiceNo: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-28"
            />
            <button type="submit" className="bg-blue-600 text-white px-4 py-1.5 rounded-lg text-xs font-bold hover:bg-blue-700 flex items-center gap-1">
              <Plus className="w-3.5 h-3.5" /> Add Inward
            </button>
          </form>

          <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-100 text-slate-700 font-bold border-b border-slate-200">
                  <th className="py-2.5 px-4">Date</th>
                  <th className="py-2.5 px-4">Vendor</th>
                  <th className="py-2.5 px-4">Invoice #</th>
                  <th className="py-2.5 px-4">Grade</th>
                  <th className="py-2.5 px-4 text-right">Inward Qty (kg)</th>
                  <th className="py-2.5 px-4 text-right">Purchase Rate (₹/kg)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {(globalStore.purchases || []).map((p, i) => (
                  <tr key={i} className="hover:bg-slate-50">
                    <td className="py-2 px-4 font-mono">{p.date}</td>
                    <td className="py-2 px-4">{p.vendor}</td>
                    <td className="py-2 px-4 font-mono">{p.invoiceNo || '-'}</td>
                    <td className="py-2 px-4 font-bold text-slate-800">{p.grade}</td>
                    <td className="py-2 px-4 text-right font-mono">{Number(p.qty).toLocaleString()} kg</td>
                    <td className="py-2 px-4 text-right font-bold text-blue-600">₹{Number(p.rate).toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 3: DAY-WISE SALES */}
      {activeTab === 'sales' && (
        <div className="space-y-4">
          <form onSubmit={handleAddSale} className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-wrap items-center gap-3">
            <span className="text-xs font-bold text-slate-700">Add Dispatch Sale:</span>
            <input 
              type="date" 
              value={newSale.date} 
              onChange={e => setNewSale({...newSale, date: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none"
              required
            />
            <input 
              type="text" 
              placeholder="Item Code" 
              value={newSale.itemCode} 
              onChange={e => setNewSale({...newSale, itemCode: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-32"
              required
            />
            <input 
              type="text" 
              placeholder="Component Description" 
              value={newSale.componentName} 
              onChange={e => setNewSale({...newSale, componentName: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none min-w-[200px]"
            />
            <input 
              type="number" 
              placeholder="Dispatch Qty" 
              value={newSale.qty} 
              onChange={e => setNewSale({...newSale, qty: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-28"
              required
            />
            <input 
              type="number" 
              step="0.01"
              placeholder="Selling Price (₹)" 
              value={newSale.sellingPrice} 
              onChange={e => setNewSale({...newSale, sellingPrice: e.target.value})}
              className="border border-slate-300 rounded-lg px-3 py-1.5 text-xs outline-none w-28"
              required
            />
            <button type="submit" className="bg-blue-600 text-white px-4 py-1.5 rounded-lg text-xs font-bold hover:bg-blue-700 flex items-center gap-1">
              <Plus className="w-3.5 h-3.5" /> Record Dispatch
            </button>
          </form>

          <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-sm">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="bg-slate-100 text-slate-700 font-bold border-b border-slate-200">
                  <th className="py-2.5 px-4">Date</th>
                  <th className="py-2.5 px-4">Vendor</th>
                  <th className="py-2.5 px-4">Item Code</th>
                  <th className="py-2.5 px-4">Component Name</th>
                  <th className="py-2.5 px-4 text-right">Qty</th>
                  <th className="py-2.5 px-4 text-right">Selling Price (₹)</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {(globalStore.sales || []).map((s, i) => (
                  <tr key={i} className="hover:bg-slate-50">
                    <td className="py-2 px-4 font-mono">{s.date}</td>
                    <td className="py-2 px-4">{s.vendor}</td>
                    <td className="py-2 px-4 font-mono font-bold text-blue-600">{s.itemCode}</td>
                    <td className="py-2 px-4">{s.componentName}</td>
                    <td className="py-2 px-4 text-right font-mono font-semibold">{Number(s.qty).toLocaleString()}</td>
                    <td className="py-2 px-4 text-right font-bold text-emerald-600">₹{Number(s.sellingPrice).toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* TAB 4: CHANGE LOGS */}
      {activeTab === 'logs' && (
        <div className="bg-white border border-slate-200 rounded-xl overflow-hidden shadow-sm">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="bg-slate-100 text-slate-700 font-bold border-b border-slate-200">
                <th className="py-2.5 px-4">Timestamp</th>
                <th className="py-2.5 px-4">Part / Grade Code</th>
                <th className="py-2.5 px-4">Vendor</th>
                <th className="py-2.5 px-4">Modifications</th>
                <th className="py-2.5 px-4">Impact</th>
                <th className="py-2.5 px-4">Authorized By</th>
                <th className="py-2.5 px-4">Reason</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {(globalStore.parameterChangeLogs || []).length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-6 text-center text-slate-400 italic">No parameter or RM mapping changes recorded yet.</td>
                </tr>
              ) : (
                globalStore.parameterChangeLogs.map((log, idx) => (
                  <tr key={idx} className="hover:bg-slate-50">
                    <td className="py-2 px-4 font-mono text-slate-500">{log.timestamp}</td>
                    <td className="py-2 px-4 font-bold text-slate-800">{log.partCode}</td>
                    <td className="py-2 px-4">{log.vendor}</td>
                    <td className="py-2 px-4 text-slate-700">{log.modifications}</td>
                    <td className="py-2 px-4 font-bold text-blue-600">{log.costImpact}</td>
                    <td className="py-2 px-4 font-semibold text-slate-600">{log.authorizedBy}</td>
                    <td className="py-2 px-4 text-slate-500 italic">{log.reason}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
PAGE_EOF

echo "==> Restarting Vite dev server cleanly..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Refresh your browser now."
