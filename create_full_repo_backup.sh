#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/full_snapshot_stable_${TIMESTAMP}"
ARCHIVE_NAME="backup_stable_${TIMESTAMP}.tar.gz"
GIT_TAG="stable-milestone-${TIMESTAMP}"

echo "=========================================================="
echo "Creating Full Multi-Layer Backup Snapshot..."
echo "Timestamp: ${TIMESTAMP}"
echo "=========================================================="

# 1. Ensure backup directory exists
mkdir -p "${BACKUP_DIR}"

# 2. Copy all critical project source files and configuration
echo "==> 1. Copying source files..."
cp -r src "${BACKUP_DIR}/"
cp package.json package-lock.json vite.config.js "${BACKUP_DIR}/" 2>/dev/null || true
cp index.html "${BACKUP_DIR}/" 2>/dev/null || true
cp tailwind.config.js postcss.config.js "${BACKUP_DIR}/" 2>/dev/null || true

# 3. Create a compressed tar.gz archive of the snapshot
echo "==> 2. Generating compressed project archive: ${ARCHIVE_NAME}..."
tar --exclude='node_modules' --exclude='.git' --exclude='dist' -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" .
cp "${BACKUP_DIR}/${ARCHIVE_NAME}" "./${ARCHIVE_NAME}"

# 4. Create Git Commit, Branch, and Tag
echo "==> 3. Creating dedicated Git Restore Point..."
git add -A
git commit -m "STABLE CHECKPOINT: Full vendor sync (Atomberg & Haier), Dynamic MB & MIS calculations [${TIMESTAMP}]" || echo "Git index already up-to-date."
git branch "restore-stable-${TIMESTAMP}" || true
git tag -a "${GIT_TAG}" -m "Stable Milestone - All 5 Modules Synchronized" || true

echo ""
echo "=========================================================="
echo "✓ FULL BACKUP COMPLETED SUCCESSFULLY"
echo "=========================================================="
echo "1. Backup Folder:  ${BACKUP_DIR}/"
echo "2. Archive File:   ./${ARCHIVE_NAME}"
echo "3. Git Tag:        ${GIT_TAG}"
echo "4. Git Branch:     restore-stable-${TIMESTAMP}"
echo "=========================================================="
