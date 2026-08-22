#!/usr/bin/env bash
set -e

echo "==> 1. Setting all store arrays to empty ([]) in src/shared/masterStore.js..."
cat << 'STORE_EOF' > patch_empty_arrays.py
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
STORE_EOF
python3 patch_empty_arrays.py

echo "==> 2. Verifying clean build..."
npm run build

echo "==> 3. Committing clean state on dev-v2..."
git checkout dev-v2
git add -A
git commit -m "chore: wipe all demo data from masterStore (clean empty slate for production)" || echo "dev-v2 up to date."
git push origin dev-v2

echo "==> 4. Merging and pushing clean state to main (Vercel Auto-Deploy)..."
git checkout main
git pull origin main --rebase || true
git merge dev-v2 -m "release: empty demo data for live testing on Vercel"
git push origin main

echo "==> 5. Returning to dev-v2..."
git checkout dev-v2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Clean empty state pushed to main."
echo "   Vercel will finish building in ~30-45 seconds."
echo "-------------------------------------------------------------------"
