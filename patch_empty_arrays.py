with open("src/shared/masterStore.js", "r") as f:
    content = f.read()

import re

# Empty all default demo arrays
content = re.sub(r"rmMappingsData:\s*\[[\s\S]*?\n\s*\],", "rmMappingsData: [],", content)
content = re.sub(r"baselineProducts:\s*\[[\s\S]*?\n\s*\],", "baselineProducts: [],", content)
content = re.sub(r"purchases:\s*\[[\s\S]*?\n\s*\],", "purchases: [],", content)
content = re.sub(r"sales:\s*\[[\s\S]*?\n\s*\],", "sales: [],", content)
content = re.sub(r"auditLogs:\s*\[[\s\S]*?\n\s*\]", "auditLogs: []", content)

with open("src/shared/masterStore.js", "w") as f:
    f.write(content)
print("src/shared/masterStore.js successfully emptied of all demo data!")
