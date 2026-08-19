#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/full_snapshot_stable_${TIMESTAMP}"
ARCHIVE_NAME="backup_stable_${TIMESTAMP}.tar.gz"
GIT_TAG="stable-milestone-${TIMESTAMP}"

echo "=========================================================="
echo "Creating Git Backup Point..."
echo "Timestamp: ${TIMESTAMP}"
echo "=========================================================="

mkdir -p "${BACKUP_DIR}"

# 1. Copy source files
echo "==> 1. Copying source files to ${BACKUP_DIR}..."
cp -r src "${BACKUP_DIR}/"
cp package.json package-lock.json vite.config.js "${BACKUP_DIR}/" 2>/dev/null || true

# 2. Archive cleanly via /tmp to avoid self-read conflicts
echo "==> 2. Generating clean archive..."
tar --exclude='node_modules' --exclude='.git' --exclude='dist' --exclude='backups' -czf "/tmp/${ARCHIVE_NAME}" .
mv "/tmp/${ARCHIVE_NAME}" "${BACKUP_DIR}/${ARCHIVE_NAME}"
cp "${BACKUP_DIR}/${ARCHIVE_NAME}" "./${ARCHIVE_NAME}"

# 3. Create Git commit and tags
echo "==> 3. Creating Git commit and tags..."
git add -A
git commit -m "Full project stable milestone backup: Atomberg & Haier synced [${TIMESTAMP}]" || echo "Nothing new to commit."
git branch "restore-stable-${TIMESTAMP}" 2>/dev/null || true
git tag -a "${GIT_TAG}" -m "Stable Milestone ${TIMESTAMP}" 2>/dev/null || true

echo "=========================================================="
echo "✓ BACKUP COMPLETED"
echo "Git Tag: ${GIT_TAG}"
echo "=========================================================="
