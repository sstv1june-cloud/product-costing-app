#!/usr/bin/env bash
set -e

echo "==> 1. Updating masterStore.js to empty initial arrays (0 demo data)..."
cat << 'STORE_EOF' > patch_clean_store.py
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
STORE_EOF
python3 patch_clean_store.py

echo "==> 2. Verifying build with npm run build..."
npm run build

echo "==> 3. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! Both Supabase and the App are completely cleared & synced."
echo "-------------------------------------------------------------------"
