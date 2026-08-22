#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_BRANCH="backup/main-stable-${TIMESTAMP}"
TAG_NAME="checkpoint-main-${TIMESTAMP}"
ARCHIVE_NAME="../product-costing-main-backup-${TIMESTAMP}.tar.gz"

echo "==> 1. Ensuring all current dev-v2 working modifications are committed..."
git add -A
git commit -m "checkpoint: pre-merge stable snapshot [${TIMESTAMP}]" || echo "Working tree clean on current branch."

echo "==> 2. Switching to main branch..."
git checkout main
git pull origin main || echo "Local main is ready."

echo "==> 3. Merging latest verified features from dev-v2 into main..."
git merge dev-v2 -m "release: sync dev-v2 to main with verified Haier/Atomberg 38-line costing, dynamic RM/MB alternate linking, and MIS reports [${TIMESTAMP}]"

echo "==> 4. Verifying production build on main..."
npm run build

echo "==> 5. Creating dedicated backup branch: ${BACKUP_BRANCH}..."
git branch "${BACKUP_BRANCH}"

echo "==> 6. Creating tagged restore point: ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "Full stable production restore point of main at ${TIMESTAMP}"

echo "==> 7. Creating compressed offline tar.gz archive at ${ARCHIVE_NAME}..."
tar --exclude='./node_modules' --exclude='./.git' --exclude='./dist' -czf "${ARCHIVE_NAME}" .

echo "==> 8. Pushing main, backup branch, and tag to GitHub remote..."
git push origin main
git push origin "${TAG_NAME}"
git push origin "${BACKUP_BRANCH}"

echo "==> 9. Returning to dev-v2 for ongoing development..."
git checkout dev-v2

echo "-------------------------------------------------------------------"
echo "✅ MAIN FULL BACKUP & RESTORE POINT CREATED SUCCESSFULLY!"
echo "   • Production Branch : main (Synced & Verified)"
echo "   • Backup Branch     : ${BACKUP_BRANCH}"
echo "   • Git Restore Tag   : ${TAG_NAME}"
echo "   • Offline Archive   : ${ARCHIVE_NAME}"
echo "   • Active Dev Branch : dev-v2"
echo "-------------------------------------------------------------------"
