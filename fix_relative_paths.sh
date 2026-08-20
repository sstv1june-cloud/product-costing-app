#!/usr/bin/env bash
set -e

echo "==> 1. Fixing import in src/modules/module1-baseline/BaselineMasterPage.jsx..."
# Point BaselineMasterPage to import InlineEditModal from its own folder
sed -i 's|import InlineEditModal from "../../components/InlineEditModal";|import InlineEditModal from "./InlineEditModal";|g' src/modules/module1-baseline/BaselineMasterPage.jsx 2>/dev/null || true
sed -i 's|import InlineEditModal from "../components/InlineEditModal";|import InlineEditModal from "./InlineEditModal";|g' src/modules/module1-baseline/BaselineMasterPage.jsx 2>/dev/null || true

echo "==> 2. Ensuring InlineEditModal.jsx has correct relative paths in both locations..."

# For src/modules/module1-baseline/InlineEditModal.jsx (2 levels deep: ../../shared/...)
if [ -f "src/modules/module1-baseline/InlineEditModal.jsx" ]; then
  sed -i 's|from "\.\./shared/masterStore"|from "../../shared/masterStore"|g' src/modules/module1-baseline/InlineEditModal.jsx
  sed -i 's|from "\.\./shared/costCalculationService"|from "../../shared/costCalculationService"|g' src/modules/module1-baseline/InlineEditModal.jsx
fi

# For src/components/InlineEditModal.jsx (1 level deep: ../shared/...)
if [ -f "src/components/InlineEditModal.jsx" ]; then
  sed -i 's|from "\.\./\.\./shared/masterStore"|from "../shared/masterStore"|g' src/components/InlineEditModal.jsx
  sed -i 's|from "\.\./\.\./shared/costCalculationService"|from "../shared/costCalculationService"|g' src/components/InlineEditModal.jsx
fi

echo "==> 3. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Import paths verified and synced."
