with open("src/shared/masterStore.js", "r") as f:
    content = f.read()

# Replace getActiveRmMapping and getActiveMbMapping with strict Vendor + Code resolution
new_lookups = """
// ----------------------------------------------------------------------------
// STRICT PRICE RESOLUTION: Vendor + RM Code / Vendor + MB Code (Zero Fallback)
// ----------------------------------------------------------------------------
export function parseMaterialString(rawMaterialStr) {
  if (!rawMaterialStr) return { baseRm: '', mbGrade: '' };
  const cleanStr = rawMaterialStr.toString().trim();
  if (cleanStr.includes('+')) {
    const parts = cleanStr.split('+').map(s => s.trim());
    return {
      baseRm: parts[0] || '',
      mbGrade: parts[1] || ''
    };
  }
  return {
    baseRm: cleanStr,
    mbGrade: ''
  };
}

export function getActiveRmMapping(gradeName, vendor, targetDate) {
  if (!gradeName) return { approvedPrice: 0.0, activeWaPrice: 0.0, activeGrade: 'Unspecified', isFound: false };
  
  // Clean composite string if needed
  const { baseRm } = parseMaterialString(gradeName);
  const targetCode = (baseRm || gradeName).toLowerCase().trim();
  const vClean = (vendor || '').toLowerCase().trim();

  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'RM' && 
    (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim()) || r.vendor.toLowerCase().includes(vClean)) && 
    r.approvedCode.toLowerCase().trim() === targetCode
  );

  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] || found.alt1Price || found.approvedPrice || 0);
    return {
      approvedPrice: Number(found.approvedPrice || 0),
      activeWaPrice: waPrice,
      activeGrade: found[`${activeKey}Code`] || found.alt1Code || found.approvedCode,
      isFound: true
    };
  }

  // If not found in RM page under this vendor, return ZERO
  return { approvedPrice: 0.00, activeWaPrice: 0.00, activeGrade: baseRm || gradeName, isFound: false };
}

export function getActiveMbMapping(mbGradeName, vendor, targetDate) {
  const vClean = (vendor || '').toLowerCase().trim();
  let targetMb = (mbGradeName || '').toLowerCase().trim();

  if (!targetMb) {
    // Check if vendor has default MBs
    return { approvedMbPrice: 0.00, activeMbWaPrice: 0.00, isFound: false };
  }

  const found = (globalStore.rmMappingsData || []).find(r => 
    r.type === 'MB' && 
    (r.vendor.toLowerCase().trim() === vClean || vClean.includes(r.vendor.toLowerCase().trim()) || r.vendor.toLowerCase().includes(vClean)) && 
    r.approvedCode.toLowerCase().trim() === targetMb
  );

  if (found) {
    const activeKey = found.activeAlt || 'alt1';
    const waPrice = Number(found[`${activeKey}Price`] || found.alt1Price || found.approvedPrice || 0);
    return {
      approvedMbPrice: Number(found.approvedPrice || 0),
      activeMbWaPrice: waPrice,
      isFound: true
    };
  }

  // If not found in RM page under this vendor, return ZERO
  return { approvedMbPrice: 0.00, activeMbWaPrice: 0.00, isFound: false };
}
"""

# Update masterStore.js
import re
pattern = r"export function getActiveRmMapping[\s\S]*?return \{ approvedMbPrice: 0\.00, activeMbWaPrice: 0\.00, isFound: false \};\s*\}"
if re.search(pattern, content):
    content = re.sub(pattern, new_lookups.strip(), content)
else:
    # Append/replace directly
    content += "\n" + new_lookups

with open("src/shared/masterStore.js", "w") as f:
    f.write(content)
print("masterStore.js updated with exact dynamic price extraction!")
