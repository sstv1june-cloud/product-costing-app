with open("src/shared/masterStore.js", "r") as f:
    code = f.read()

import re

code = re.sub(r"rmMappingsData:\s*\[[\s\S]*?\n\s*\],", "rmMappingsData: [],", code)
code = re.sub(r"baselineProducts:\s*\[[\s\S]*?\n\s*\],", "baselineProducts: [],", code)
code = re.sub(r"purchases:\s*\[[\s\S]*?\n\s*\],", "purchases: [],", code)
code = re.sub(r"sales:\s*\[[\s\S]*?\n\s*\],", "sales: [],", code)
code = re.sub(r"auditLogs:\s*\[[\s\S]*?\n\s*\]", "auditLogs: []", code)

with open("src/shared/masterStore.js", "w") as f:
    f.write(code)
print("masterStore.js cleaned to empty arrays!")
