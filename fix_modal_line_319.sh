#!/usr/bin/env bash
set -e

echo "==> 1. Checking lines 310 to 330 in InlineEditModal.jsx..."
sed -n '310,330p' src/modules/module1-baseline/InlineEditModal.jsx || true

echo "==> 2. Restoring pristine InlineEditModal and costCalculationService from checkpoint..."
git checkout checkpoint-dev2-20260821_064903 -- src/modules/module1-baseline/InlineEditModal.jsx src/shared/costCalculationService.js

echo "==> 3. Inspecting original exports and functions..."
grep -E "export function" src/shared/costCalculationService.js || true

echo "==> 4. Restarting Vite development server cleanly on port 5173..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true
rm -rf node_modules/.vite 2>/dev/null || true
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Restored cleanly!"
