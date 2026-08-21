#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_BRANCH="backup/dev2-stable-${TIMESTAMP}"
TAG_NAME="checkpoint-dev2-${TIMESTAMP}"
ARCHIVE_NAME="../product-costing-backup-${TIMESTAMP}.tar.gz"

echo "==> 1. Staging all working tree modifications..."
git add -A

echo "==> 2. Committing current snapshot to dev-v2..."
git commit -m "checkpoint: exact Atomberg row parsing, clean BOP/shift tariff bindings, full masterStore persistence [${TIMESTAMP}]" || echo "Working tree already clean."

echo "==> 3. Creating dedicated backup branch: ${BACKUP_BRANCH}..."
git branch "${BACKUP_BRANCH}"

echo "==> 4. Creating tagged restore point: ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "Restore point created at ${TIMESTAMP}"

echo "==> 5. Creating compressed offline archive at ${ARCHIVE_NAME}..."
tar --exclude='./node_modules' --exclude='./.git' --exclude='./dist' -czf "${ARCHIVE_NAME}" .

echo "-------------------------------------------------------------------"
echo "✅ BACKUP & RESTORE POINT CREATED SUCCESSFULLY!"
echo "   • Git Branch   : ${BACKUP_BRANCH}"
echo "   • Restore Tag  : ${TAG_NAME}"
echo "   • Offline File : ${ARCHIVE_NAME}"
echo "-------------------------------------------------------------------"
