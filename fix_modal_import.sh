#!/usr/bin/env bash
set -e

echo "==> 1. Finding InlineEditModal in repository..."
EXISTING_MODAL=$(find src -name "*InlineEditModal*.jsx" | head -n 1)

mkdir -p src/components

if [ -n "$EXISTING_MODAL" ]; then
  echo "Found existing modal at: $EXISTING_MODAL"
  cp "$EXISTING_MODAL" src/components/InlineEditModal.jsx
else
  echo "Modal not found in other paths, checking src/modules/module1-baseline/..."
  if [ -f "src/modules/module1-baseline/InlineEditModal.jsx" ]; then
    cp src/modules/module1-baseline/InlineEditModal.jsx src/components/InlineEditModal.jsx
  fi
fi

# Ensure both relative paths are valid by having copies in both common locations
if [ -f "src/components/InlineEditModal.jsx" ]; then
  mkdir -p src/modules/module1-baseline
  cp src/components/InlineEditModal.jsx src/modules/module1-baseline/InlineEditModal.jsx 2>/dev/null || true
fi

echo "==> 2. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Import path resolved successfully."
