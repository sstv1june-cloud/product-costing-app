import { initialBaselineData } from '../modules/module1-baseline/baselineData';

const data = Array.isArray(initialBaselineData) ? initialBaselineData : [];

export const initialPurchaseMaster = [
  { code: "PUR-ABS-01", name: "ABS 300-B Red (Prime Inward)", polymer: "ABS", supplier: "Supreme Petrochem", waPrice: 134.80, inwardDate: "2026-01-20", qtyKg: 12500 },
  { code: "PUR-ABS-02", name: "ABS 300-Blue (Imported)", polymer: "ABS", supplier: "Chi Mei", waPrice: 131.25, inwardDate: "2026-02-05", qtyKg: 8200 },
  { code: "PUR-ABS-03", name: "ABS Recycled Compound (15% Regrind)", polymer: "ABS", supplier: "In-House Reprocess", waPrice: 122.50, inwardDate: "2026-01-10", qtyKg: 15000 },
  { code: "PUR-GPPS-01", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", polymer: "GPPS", supplier: "Supreme", waPrice: 98.40, inwardDate: "2026-01-18", qtyKg: 9000 },
  { code: "PUR-GPPS-02", name: "GPPS Formosa SC-200 Equivalent", polymer: "GPPS", supplier: "Formosa Taiwan", waPrice: 95.50, inwardDate: "2026-02-02", qtyKg: 4500 },
  { code: "PUR-PP-01", name: "PP Reliance H110MA Prime", polymer: "PP", supplier: "Reliance Industries", waPrice: 95.19, inwardDate: "2026-01-25", qtyKg: 20000 }
];

export const initialSalesData = [
  { id: "SALE-01", itemCode: "0060226713H", componentName: "End Cap Top Ref (without Screen Painting )", vendor: "Haier", saleUnit: 10, invoiceDate: "2026-01-20", sellingPrice: 38.50 },
  { id: "SALE-02", itemCode: "0060217989D", componentName: "End cap Bottom Ref-ABS-DC-195,220", vendor: "Haier", saleUnit: 290, invoiceDate: "2026-02-05", sellingPrice: 42.00 },
  { id: "SALE-03", itemCode: "0060217978E", componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX", vendor: "Haier", saleUnit: 300, invoiceDate: "2026-01-28", sellingPrice: 85.00 }
];

export const initialRmMatrix = [
  {
    id: "RM-HAIER-ABS-P1",
    vendor: "Haier",
    approvedRm: "ABS 300 Pre Colour",
    polymer: "ABS",
    approvedPrice: 136.20,
    validFrom: "2026-01-15",
    validTo: "2026-02-14",
    activeSelection: "alt1",
    alt1: { code: "PUR-ABS-01", name: "ABS 300-B Red (Prime Inward)", waPrice: 134.80 },
    alt2: { code: "PUR-ABS-02", name: "ABS 300-Blue (Imported)", waPrice: 131.25 },
    alt3: { code: "PUR-ABS-03", name: "ABS Recycled Compound (15% Regrind)", waPrice: 122.50 }
  },
  {
    id: "RM-HAIER-GPPS-P1",
    vendor: "Haier",
    approvedRm: "GPPS SC201LV",
    polymer: "GPPS",
    approvedPrice: 103.08,
    validFrom: "2026-01-15",
    validTo: "2026-02-14",
    activeSelection: "alt1",
    alt1: { code: "PUR-GPPS-01", name: "GPPS SC201LV + 3.5% Smoke Grey Blend", waPrice: 98.40 },
    alt2: { code: "PUR-GPPS-02", name: "GPPS Formosa SC-200 Equivalent", waPrice: 95.50 },
    alt3: { code: "PUR-GPPS-03", name: "GPPS Reprocessed Clear Blend", waPrice: 89.20 }
  },
  {
    id: "RM-HAIER-PP-P1",
    vendor: "Haier",
    approvedRm: "PP B-120MA",
    polymer: "PP",
    approvedPrice: 96.19,
    validFrom: "2026-01-15",
    validTo: "2026-02-14",
    activeSelection: "alt1",
    alt1: { code: "PUR-PP-01", name: "PP Reliance H110MA Prime", waPrice: 95.19 },
    alt2: { code: "PUR-PP-02", name: "PP IOCL 1110MAS Alternate", waPrice: 93.80 },
    alt3: { code: "PUR-PP-03", name: "PP Copolymer In-House Blend", waPrice: 88.50 }
  },
  {
    id: "RM-LG-ABS-P1",
    vendor: "LG",
    approvedRm: "ABS 300 Pre Colour",
    polymer: "ABS",
    approvedPrice: 138.50,
    validFrom: "2026-01-15",
    validTo: "2026-02-14",
    activeSelection: "alt2",
    alt1: { code: "PUR-ABS-01", name: "ABS 300-B Red (Prime Inward)", waPrice: 134.80 },
    alt2: { code: "PUR-ABS-02", name: "ABS 300-Blue (Imported)", waPrice: 131.25 },
    alt3: { code: "PUR-ABS-03", name: "ABS Recycled Compound (15% Regrind)", waPrice: 122.50 }
  }
];

export const globalStore = {
  baselineList: data,
  baselineData: data,
  baselineProducts: data,
  products: data,
  parts: data,
  items: data,
  purchaseMaster: initialPurchaseMaster,
  salesData: initialSalesData,
  rmMatrix: initialRmMatrix,
  rawMaterials: initialRmMatrix,
  parameterChangeLogs: [],
  rmPriceHistoryLogs: [],
  vendors: [
    { vendorId: "Haier", vendorName: "Haier Appliances" },
    { vendorId: "LG", vendorName: "LG Electronics" },
    { vendorId: "Whirlpool", vendorName: "Whirlpool India" }
  ]
};

const listeners = new Set();
export const subscribeStore = (fn) => { listeners.add(fn); return () => listeners.delete(fn); };
export const notifyStore = () => listeners.forEach(fn => fn());

export const getActiveRmMapping = (approvedRmName, vendor = "Haier", targetDate = null) => {
  const vKey = (vendor || "Haier").toLowerCase();
  const rows = (globalStore.rmMatrix || []).filter(r => 
    r.vendor.toLowerCase() === vKey &&
    (r.approvedRm.toLowerCase() === (approvedRmName || "").toLowerCase() ||
     (approvedRmName || "").toLowerCase().includes(r.polymer.toLowerCase()))
  );

  let row = rows[0];
  if (targetDate && rows.length > 0) {
    const matchedPeriodRow = rows.find(r => targetDate >= r.validFrom && targetDate <= r.validTo);
    if (matchedPeriodRow) row = matchedPeriodRow;
  }

  if (!row) {
    return {
      vendor: vendor || "Haier",
      approvedRm: approvedRmName || "Standard Polymer",
      approvedPrice: 136.20,
      activeRmName: approvedRmName || "Standard Polymer",
      activeWaPrice: 136.20,
      validFrom: "2026-01-15",
      validTo: "2026-02-14"
    };
  }

  let activeRmName = row.approvedRm;
  let activeWaPrice = row.approvedPrice;

  if (row.activeSelection === 'alt1' && row.alt1) {
    activeRmName = row.alt1.name;
    activeWaPrice = row.alt1.waPrice;
  } else if (row.activeSelection === 'alt2' && row.alt2) {
    activeRmName = row.alt2.name;
    activeWaPrice = row.alt2.waPrice;
  } else if (row.activeSelection === 'alt3' && row.alt3) {
    activeRmName = row.alt3.name;
    activeWaPrice = row.alt3.waPrice;
  }

  return {
    vendor: row.vendor,
    approvedRm: row.approvedRm,
    approvedPrice: row.approvedPrice,
    validFrom: row.validFrom,
    validTo: row.validTo,
    activeSelection: row.activeSelection,
    activeRmName,
    activeWaPrice,
    alt1: row.alt1,
    alt2: row.alt2,
    alt3: row.alt3
  };
};

export const updateVendorScheduleBulk = (vendor, validFrom, validTo, updatedRows, logEntries = []) => {
  globalStore.rmMatrix = globalStore.rmMatrix.map(row => {
    if (row.vendor === vendor) {
      const match = updatedRows.find(u => u.id === row.id);
      return match ? { ...match, validFrom, validTo } : { ...row, validFrom, validTo };
    }
    return row;
  });

  if (logEntries && logEntries.length > 0) {
    logEntries.forEach(log => {
      globalStore.rmPriceHistoryLogs.unshift({
        id: `HIST-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`,
        timestamp: new Date().toISOString().replace('T', ' ').substring(0, 19),
        ...log
      });
    });
  }
  notifyStore();
};

export const addManualSaleRecord = (record) => {
  globalStore.salesData.unshift({
    id: `SALE-${Date.now()}`,
    ...record
  });
  notifyStore();
};

export const addManualPurchaseRecord = (record) => {
  globalStore.purchaseMaster.unshift({
    code: `PUR-${Date.now()}`,
    ...record
  });
  notifyStore();
};

export const uploadBulkSales = (newSales) => {
  globalStore.salesData = [...newSales, ...(globalStore.salesData || [])];
  notifyStore();
};

export const uploadBulkPurchases = (newPurchases) => {
  globalStore.purchaseMaster = [...newPurchases, ...(globalStore.purchaseMaster || [])];
  notifyStore();
};

export const updateBaselineParameters = ({ itemId, updatedItem, changeType, newValidFrom, reason } = {}) => {
  const list = globalStore.baselineList || [];
  const idx = list.findIndex(p => p.id === itemId || p.itemCode === (updatedItem?.itemCode));
  if (idx !== -1) {
    globalStore.baselineList[idx] = {
      ...globalStore.baselineList[idx],
      ...updatedItem,
      validFrom: newValidFrom || globalStore.baselineList[idx].validFrom
    };
    notifyStore();
  }
};

export const getVendorRmCosting = (vendorCode, rmCode) => {
  const res = getActiveRmMapping(rmCode, vendorCode);
  return res.activeWaPrice;
};

export { data as baselineList, data as baselineData, data as baselineProducts };
export default globalStore;
