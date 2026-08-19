export const INITIAL_MB_MASTER = [
  {
    mbCode: "MB-SMK-01",
    shadeName: "Smoke Grey 3.5%",
    carrierPolymer: "GPPS / PS",
    supplier: "Poddar Pigments",
    approvedRateKg: 240.00,
    activeInwardRateKg: 232.50,
    standardDosagePct: 3.5,
    status: "Active"
  },
  {
    mbCode: "MB-WHT-02",
    shadeName: "Appliance Pure White",
    carrierPolymer: "ABS Carrier",
    supplier: "Clariant",
    approvedRateKg: 285.00,
    activeInwardRateKg: 285.00,
    standardDosagePct: 2.0,
    status: "Active"
  }
];

export const getStoredMbData = () => {
  try {
    const data = localStorage.getItem('cpc_mb_matrix');
    return data ? JSON.parse(data) : INITIAL_MB_MASTER;
  } catch {
    return INITIAL_MB_MASTER;
  }
};

export const saveMbData = (records) => {
  try {
    localStorage.setItem('cpc_mb_matrix', JSON.stringify(records));
  } catch (err) {
    console.error(err);
  }
};
