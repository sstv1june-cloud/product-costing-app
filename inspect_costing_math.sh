#!/usr/bin/env bash
set -e

echo "================================================================="
echo "1. HOW INLINE EDIT MODAL CALCULATES ATOMBERG & HAIER:"
echo "================================================================="
grep -A 35 -B 5 "calculateAtombergCost" src/modules/module1-baseline/InlineEditModal.jsx || true
grep -A 35 -B 5 "calculateHaierCost" src/modules/module1-baseline/InlineEditModal.jsx || true

echo "================================================================="
echo "2. HOW COSTING RUN ENGINE CURRENTLY CALCULATES:"
echo "================================================================="
cat src/modules/module3-costing-engine/CostingRunEnginePage.jsx | head -n 95 || true

echo "================================================================="
echo "3. FUNCTION SIGNATURES IN costCalculationService.js:"
echo "================================================================="
head -n 45 src/shared/costCalculationService.js || true

