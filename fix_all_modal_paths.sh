#!/usr/bin/env bash
set -e

echo "==> 1. Fixing imports inside src/components/InlineEditModal.jsx..."
if [ -f "src/components/InlineEditModal.jsx" ]; then
  sed -i "s|['\"]\.\./\.\./shared/masterStore['\"]|'../shared/masterStore'|g" src/components/InlineEditModal.jsx
  sed -i "s|['\"]\.\./\.\./shared/costCalculationService['\"]|'../shared/costCalculationService'|g" src/components/InlineEditModal.jsx
fi

echo "==> 2. Fixing imports inside src/modules/module1-baseline/InlineEditModal.jsx..."
if [ -f "src/modules/module1-baseline/InlineEditModal.jsx" ]; then
  sed -i "s|['\"]\.\./shared/masterStore['\"]|'../../shared/masterStore'|g" src/modules/module1-baseline/InlineEditModal.jsx
  sed -i "s|['\"]\.\./shared/costCalculationService['\"]|'../../shared/costCalculationService'|g" src/modules/module1-baseline/InlineEditModal.jsx
fi

echo "==> 3. Restarting Vite cleanly..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Vite server restarted."
