#!/usr/bin/env bash
set -e

echo "==> 1. Stopping any stale Node / Vite dev server instances..."
fuser -k 5173/tcp 2>/dev/null || killall -9 node 2>/dev/null || true

echo "==> 2. Purging Vite pre-bundle cache..."
rm -rf node_modules/.vite
rm -rf .vite
rm -rf dist

echo "==> 3. Restarting Vite with --force flag on port 5173..."
nohup npm run dev -- --force --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 3

echo "==> Vite server started cleanly!"
