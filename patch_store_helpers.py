with open("src/shared/masterStore.js", "r") as f:
    content = f.read()

helper_code = """
// Helper to add or update vendor material in RM Master Matrix
export function addOrUpdateVendorMaterial({ vendor, type, approvedCode, approvedPrice }) {
  if (!approvedCode || !vendor) return;
  if (!globalStore.rmMappingsData) globalStore.rmMappingsData = [];

  const vClean = vendor.toLowerCase().trim();
  const cClean = approvedCode.toLowerCase().trim();

  const existingIdx = globalStore.rmMappingsData.findIndex(r => 
    r.vendor.toLowerCase().trim() === vClean && 
    r.type === type && 
    r.approvedCode.toLowerCase().trim() === cClean
  );

  if (existingIdx >= 0) {
    globalStore.rmMappingsData[existingIdx].approvedPrice = Number(approvedPrice || 0);
  } else {
    globalStore.rmMappingsData.push({
      id: `mat-${Date.now()}-${Math.random().toString(36).substr(2, 5)}`,
      vendor,
      type: type || 'RM',
      approvedCode,
      approvedPrice: Number(approvedPrice || 0),
      activeAlt: 'alt1',
      alt1Code: approvedCode,
      alt1Price: Number(approvedPrice || 0),
      alt2Code: '',
      alt2Price: 0,
      alt3Code: '',
      alt3Price: 0
    });
  }

  addAuditLog({
    partCode: approvedCode,
    componentName: `${type} Material Master Entry (${vendor})`,
    vendor,
    modifications: `Approved Base Price: ₹${Number(approvedPrice || 0).toFixed(2)}/kg`,
    costImpact: `₹${Number(approvedPrice || 0).toFixed(2)}/kg`,
    reason: 'Vendor RM/MB Master Registration'
  });

  notifyStore();
}
"""

if "addOrUpdateVendorMaterial" not in content:
    content += helper_code
    with open("src/shared/masterStore.js", "w") as f:
        f.write(content)
    print("masterStore.js patched with addOrUpdateVendorMaterial!")
else:
    print("masterStore.js already has addOrUpdateVendorMaterial.")
