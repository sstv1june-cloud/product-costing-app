export const INITIAL_SALES_RECORDS = [
  {
    id: "SLS-2026-001",
    invoiceDate: "2026-08-05",
    vendor: "Haier",
    itemCode: "0060226713H",
    componentName: "End Cap Top Ref (without Screen Painting )",
    model: "HRD-1954",
    quantitySold: 4500,
    sellingPricePerUnit: 38.50,
    approvedCostPerUnit: 32.64,
    actualCostPerUnit: 31.80
  },
  {
    id: "SLS-2026-002",
    invoiceDate: "2026-08-10",
    vendor: "Haier",
    itemCode: "0060217989D",
    componentName: "End cap Bottom Ref-ABS-DC-195,220",
    model: "HRD-1954",
    quantitySold: 4200,
    sellingPricePerUnit: 42.00,
    approvedCostPerUnit: 36.85,
    actualCostPerUnit: 35.90
  },
  {
    id: "SLS-2026-003",
    invoiceDate: "2026-08-12",
    vendor: "Haier",
    itemCode: "0060217978E",
    componentName: "CRISPER GPPS LV + 3.5% SMOKE GREY VEG BOX",
    model: "HRD-2204",
    quantitySold: 1800,
    sellingPricePerUnit: 85.00,
    approvedCostPerUnit: 70.97,
    actualCostPerUnit: 68.40
  }
];

export const getStoredSalesData = () => {
  try {
    const d = localStorage.getItem('cpc_sales_records');
    return d ? JSON.parse(d) : INITIAL_SALES_RECORDS;
  } catch {
    return INITIAL_SALES_RECORDS;
  }
};

export const saveSalesData = (records) => {
  try {
    localStorage.setItem('cpc_sales_records', JSON.stringify(records));
  } catch (e) {
    console.error(e);
  }
};
