with open("src/shared/masterStore.js", "r") as f:
    content = f.read()

# Replace the incomplete updateBaselineParameters function
old_fn = """export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  
  if (updatedItem.parameters) {
    prod.parameters = { ...prod.parameters, ...updatedItem.parameters };
  }"""

new_fn = """export function updateBaselineParameters({ itemId, updatedItem, reason }) {
  const prod = (globalStore.baselineProducts || []).find(p => p.id === itemId || p.itemCode === itemId);
  if (!prod) return;
  
  // Persist all top-level baseline costing fields
  if (updatedItem.shiftTariff !== undefined) prod.shiftTariff = Number(updatedItem.shiftTariff);
  if (updatedItem.shiftRate !== undefined) prod.shiftRate = Number(updatedItem.shiftRate);
  if (updatedItem.masterbatchPct !== undefined) prod.masterbatchPct = Number(updatedItem.masterbatchPct);
  if (updatedItem.bopCost !== undefined) prod.bopCost = Number(updatedItem.bopCost);
  if (updatedItem.packingCost !== undefined) prod.packingCost = Number(updatedItem.packingCost);
  if (updatedItem.transportCost !== undefined) prod.transportCost = Number(updatedItem.transportCost);
  if (updatedItem.netWeight !== undefined) prod.netWeight = Number(updatedItem.netWeight);
  if (updatedItem.runnerWeight !== undefined) prod.runnerWeight = Number(updatedItem.runnerWeight);
  if (updatedItem.cavity !== undefined) prod.cavity = Number(updatedItem.cavity);
  if (updatedItem.machineTonnage !== undefined) prod.machineTonnage = Number(updatedItem.machineTonnage);
  if (updatedItem.cycleTimeApproved !== undefined) prod.cycleTimeApproved = Number(updatedItem.cycleTimeApproved);
  if (updatedItem.approvedCost !== undefined) prod.approvedCost = Number(updatedItem.approvedCost);

  // Persist running shopfloor parameters
  if (updatedItem.parameters) {
    prod.parameters = { ...prod.parameters, ...updatedItem.parameters };
  }"""

if old_fn in content:
    content = content.replace(old_fn, new_fn)
    with open("src/shared/masterStore.js", "w") as f:
        f.write(content)
    print("masterStore.js successfully patched!")
else:
    print("Could not find exact string match, applying regex replacement...")
    import re
    pattern = r"export function updateBaselineParameters\(\{ itemId, updatedItem, reason \}\)\s*\{[\s\S]*?if \(updatedItem\.parameters\)\s*\{[\s\S]*?prod\.parameters = \{ \.\.\.prod\.parameters, \.\.\.updatedItem\.parameters \};\s*\}"
    content = re.sub(pattern, new_fn, content)
    with open("src/shared/masterStore.js", "w") as f:
        f.write(content)
    print("masterStore.js patched via regex!")
