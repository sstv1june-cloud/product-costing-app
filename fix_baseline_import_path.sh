#!/usr/bin/env bash
set -e

echo "==> 1. Fixing import path in BaselineMasterPage.jsx..."
BASELINE_FILE="src/modules/module1-baseline/BaselineMasterPage.jsx"

# Replace the incorrect import path with the correct relative path
sed -i 's|\.\./\.\./\.\./shared/masterStore|\.\./\.\./shared/masterStore|g' "$BASELINE_FILE"

echo "==> 2. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! BaselineMasterPage import resolved."
