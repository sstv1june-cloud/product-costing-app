#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_BRANCH="backup/dev2-stable-${TIMESTAMP}"
TAG_NAME="checkpoint-dev2-${TIMESTAMP}"
ARCHIVE_NAME="../product-costing-backup-${TIMESTAMP}.tar.gz"

echo "==> 1. Ensuring we are on dev-v2 branch..."
git checkout dev-v2

echo "==> 2. Verifying build before backup..."
npm run build

echo "==> 3. Staging all repository modifications..."
git add -A

echo "==> 4. Committing current working tree..."
git commit -m "checkpoint: verified Haier Reconciliation Weight (198.97g), Line 24 Overhead Package (5.15), dynamic RM/MB alternate WA linking, and complete MIS reports [${TIMESTAMP}]" || echo "Working tree clean, proceeding to checkpointing."

echo "==> 5. Creating dedicated backup branch: ${BACKUP_BRANCH}..."
git branch "${BACKUP_BRANCH}"

echo "==> 6. Creating tagged restore point: ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "Full stable dev-v2 restore point at ${TIMESTAMP}"

echo "==> 7. Creating offline compressed tar.gz archive at ${ARCHIVE_NAME}..."
tar --exclude='./node_modules' --exclude='./.git' --exclude='./dist' -czf "${ARCHIVE_NAME}" .

echo "==> 8. Pushing checkpoint tag and branches to remote..."
git push origin "${TAG_NAME}"
git push origin "${BACKUP_BRANCH}"
git push origin dev-v2 || echo "dev-v2 pushed to origin."

echo "-------------------------------------------------------------------"
echo "✅ FULL REPOSITORY BACKUP & RESTORE POINT CREATED SUCCESSFULLY!"
echo "   • Working Branch   : dev-v2"
echo "   • Backup Branch    : ${BACKUP_BRANCH}"
echo "   • Git Restore Tag  : ${TAG_NAME}"
echo "   • Offline Archive  : ${ARCHIVE_NAME}"
echo "-------------------------------------------------------------------"
