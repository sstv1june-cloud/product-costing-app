#!/usr/bin/env bash
set -e

echo "================================================================="
echo "1. HOW BaselineMasterPage.jsx HANDLES MODAL SAVE (onSave):"
echo "================================================================="
grep -A 30 -B 5 "handleSave" src/modules/module1-baseline/BaselineMasterPage.jsx || grep -A 30 -B 5 "onSave" src/modules/module1-baseline/BaselineMasterPage.jsx || true

echo "================================================================="
echo "2. HOW masterStore.js UPDATES BASELINE PRODUCTS:"
echo "================================================================="
grep -A 25 -B 5 "updateProduct" src/shared/masterStore.js || grep -A 25 -B 5 "baselineProducts" src/shared/masterStore.js || true

echo "================================================================="
echo "3. INLINE EDIT MODAL INITIAL STATE & SAVE HANDLER:"
echo "================================================================="
grep -A 25 "const \[baseBopCost" src/modules/module1-baseline/InlineEditModal.jsx || true
grep -A 30 "handleSaveAtomberg" src/modules/module1-baseline/InlineEditModal.jsx || true
