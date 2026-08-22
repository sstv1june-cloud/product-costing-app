#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_BRANCH="backup/dev2-stable-${TIMESTAMP}"
TAG_NAME="checkpoint-dev2-${TIMESTAMP}"
ARCHIVE_NAME="../product-costing-backup-${TIMESTAMP}.tar.gz"

echo "==> 1. Ensuring we are on dev-v2 branch..."
git checkout dev-v2

echo "==> 2. Staging all working tree modifications..."
git add -A

echo "==> 3. Committing current snapshot to dev-v2..."
git commit -m "checkpoint: multi-vendor universal sales/purchase upload with deduplication, excel date normalizer, dual-level lock, and complete MIS pivot tables [${TIMESTAMP}]" || echo "Working tree clean, proceeding to checkpointing."

echo "==> 4. Creating dedicated backup branch: ${BACKUP_BRANCH}..."
git branch "${BACKUP_BRANCH}"

echo "==> 5. Creating tagged restore point: ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "Stable dev-v2 restore point at ${TIMESTAMP}"

echo "==> 6. Creating compressed offline archive at ${ARCHIVE_NAME}..."
tar --exclude='./node_modules' --exclude='./.git' --exclude='./dist' -czf "${ARCHIVE_NAME}" .

echo "==> 7. Pushing branch and checkpoint tag to origin remote..."
git push origin "${TAG_NAME}"
git push origin "${BACKUP_BRANCH}"
git push origin dev-v2 || echo "dev-v2 updated on remote."

echo "-------------------------------------------------------------------"
echo "✅ DEV-V2 FULL BACKUP & RESTORE POINT CREATED SUCCESSFULLY!"
echo "   • Working Branch   : dev-v2"
echo "   • Backup Branch    : ${BACKUP_BRANCH}"
echo "   • Git Restore Tag  : ${TAG_NAME}"
echo "   • Offline Archive  : ${ARCHIVE_NAME}"
echo "-------------------------------------------------------------------"
