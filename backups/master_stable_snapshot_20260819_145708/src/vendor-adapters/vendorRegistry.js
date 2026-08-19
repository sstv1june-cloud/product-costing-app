export const initialVendors = [
  {
    vendorId: "VND-HAIER",
    vendorName: "Haier Appliances India",
    category: "Injection Molding",
    status: "Active",
    onboardedDate: "2026-01-10",
    adapterKey: "haier"
  },
  {
    vendorId: "VND-LG01",
    vendorName: "LG Electronics",
    category: "Injection Molding",
    status: "Active",
    onboardedDate: "2026-02-15",
    adapterKey: "default"
  }
];

export const getRegisteredVendors = () => {
  try {
    const saved = localStorage.getItem('cpc_vendors');
    return saved ? JSON.parse(saved) : initialVendors;
  } catch {
    return initialVendors;
  }
};

export const saveRegisteredVendors = (vendors) => {
  try {
    localStorage.setItem('cpc_vendors', JSON.stringify(vendors));
  } catch (err) {
    console.error(err);
  }
};

export default { getRegisteredVendors, saveRegisteredVendors, initialVendors };
