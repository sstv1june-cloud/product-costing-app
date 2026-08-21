#!/usr/bin/env bash
set -e

echo "==> 1. Ensuring all changes on dev-v2 are committed..."
git checkout dev-v2
git add -A
git commit -m "feat: complete 38-line costing engine, Excel staging parser, manual machine tariff & dual BOP/packing persistence" || echo "Working tree clean on dev-v2."

echo "==> 2. Switching to main branch..."
git checkout main

echo "==> 3. Pulling latest main from remote..."
git pull origin main || echo "Already up to date."

echo "==> 4. Merging dev-v2 into main..."
git merge dev-v2 --no-edit -m "merge: dev-v2 into main (38-line costing & spec parity)"

echo "==> 5. Running production build check..."
npm run build

echo "==> 6. Pushing live updates to origin/main..."
git push origin main

echo "==> 7. Switching back to dev-v2..."
git checkout dev-v2

echo "-------------------------------------------------------------------"
echo "✅ SUCCESSFULLY MERGED AND DEPLOYED DEV-V2 TO MAIN!"
echo "   • Production Branch : main (Live)"
echo "   • Working Branch    : dev-v2"
echo "-------------------------------------------------------------------"
