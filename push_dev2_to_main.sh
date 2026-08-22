#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring all changes on dev-v2 are committed..."
git checkout dev-v2
git add -A
git commit -m "chore: finalize dev-v2 updates before merging to main" || echo "Working tree clean on dev-v2."

echo "==> 2. Switching to main branch..."
git checkout main
git pull origin main --rebase || echo "Local main is up to date."

echo "==> 3. Merging dev-v2 into main..."
git merge dev-v2 -m "merge: sync dev-v2 features to main (Haier/Atomberg 38-line costing, dynamic RM/MB alternate linking, and MIS reports)"

echo "==> 4. Verifying production build on main..."
npm run build

echo "==> 5. Pushing main to remote GitHub..."
git push origin main

echo "==> 6. Switching back to dev-v2..."
git checkout dev-v2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESS! dev-v2 has been cleanly merged and pushed to main."
echo "   • Production Branch : main (Live & Updated)"
echo "   • Working Branch    : dev-v2 (Active)"
echo "-------------------------------------------------------------------"
