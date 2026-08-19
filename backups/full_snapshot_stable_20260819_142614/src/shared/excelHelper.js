import * as XLSX from 'xlsx';

export const exportBaselineTemplate = (products = []) => {
  const exportData = products.map(p => ({
    "Part Number": p.itemCode,
    "Component Name": p.componentName,
    "Model": p.model,
    "Vendor": p.vendor,
    "Cavity": p.parameters?.cavity ?? p.cavity ?? 1,
    "Tonnage (T)": p.parameters?.machineTonnage ?? p.machineTonnage ?? 0,
    "Cycle Time (s)": p.parameters?.cycleTimeApproved ?? p.cycleTimeApproved ?? 0,
    "Net Weight (g)": p.parameters?.netWeightApproved ?? p.netWeightApproved ?? 0,
    "Runner Weight (g)": p.parameters?.runnerWeight ?? p.runnerWeight ?? 0,
    "Approved Raw Material": p.approvedRm,
    "Approved RM Rate (₹/kg)": p.approvedRmRate,
    "Approved Total Cost (₹)": p.approvedTotalCost
  }));

  const ws = XLSX.utils.json_to_sheet(exportData.length ? exportData : [
    {
      "Part Number": "0060226713H",
      "Component Name": "Sample Part",
      "Model": "HRD-1954",
      "Vendor": "Haier",
      "Cavity": 2,
      "Tonnage (T)": 450,
      "Cycle Time (s)": 48,
      "Net Weight (g)": 118.5,
      "Runner Weight (g)": 12.0,
      "Approved Raw Material": "ABS 300 Pre Colour",
      "Approved RM Rate (₹/kg)": 136.20,
      "Approved Total Cost (₹)": 32.64
    }
  ]);

  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "Baseline_Template");
  XLSX.writeFile(wb, `Baseline_Template_${new Date().toISOString().slice(0, 10)}.xlsx`);
};

export const parseBaselineExcel = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target.result);
        const workbook = XLSX.read(data, { type: 'array' });
        const sheetName = workbook.SheetNames[0];
        const rows = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName]);
        resolve(rows);
      } catch (err) {
        reject(err);
      }
    };
    reader.onerror = reject;
    reader.readAsArrayBuffer(file);
  });
};

export default { exportBaselineTemplate, parseBaselineExcel };
