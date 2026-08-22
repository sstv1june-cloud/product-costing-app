with open("src/shared/masterStore.js", "r") as f:
    content = f.read()

# Ensure default isLocked: true
if "isLocked: false" in content:
    content = content.replace("isLocked: false", "isLocked: true", 1)

# Ensure toggleGlobalLock cleanly notifies listeners
toggle_fn = """export function toggleGlobalLock() {
  globalStore.isLocked = !globalStore.isLocked;
  addAuditLog({
    partCode: 'SYSTEM_LOCK',
    componentName: 'Global Baseline & RM Lock',
    vendor: 'ALL',
    modifications: `Status: ${globalStore.isLocked ? 'LOCKED' : 'UNLOCKED'}`,
    costImpact: globalStore.isLocked ? 'Frozen' : 'Editable',
    reason: 'Lock toggled by Administrator'
  });
  notifyStore();
}"""

with open("src/shared/masterStore.js", "w") as f:
    f.write(content)
print("masterStore.js locked state updated!")
