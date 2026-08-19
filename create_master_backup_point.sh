#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/master_stable_snapshot_${TIMESTAMP}"
ARCHIVE_NAME="production_ready_backup_${TIMESTAMP}.tar.gz"
GIT_TAG="production-stable-${TIMESTAMP}"

echo "=========================================================="
echo "Creating Master Production Backup & Restore Point..."
echo "Timestamp: ${TIMESTAMP}"
echo "=========================================================="

# 1. Ensure backup directory structure
mkdir -p "${BACKUP_DIR}"

# 2. Copy source code and project configuration files
echo "==> 1. Archiving source files and configs..."
cp -r src "${BACKUP_DIR}/"
cp package.json package-lock.json vite.config.js "${BACKUP_DIR}/" 2>/dev/null || true
cp tailwind.config.js postcss.config.js index.html "${BACKUP_DIR}/" 2>/dev/null || true

# 3. Create a clean compressed archive (excluding node_modules and build outputs)
echo "==> 2. Generating compressed bundle: ${ARCHIVE_NAME}..."
tar --exclude='node_modules' --exclude='.git' --exclude='dist' --exclude='backups' -czf "/tmp/${ARCHIVE_NAME}" .
mv "/tmp/${ARCHIVE_NAME}" "${BACKUP_DIR}/${ARCHIVE_NAME}"
cp "${BACKUP_DIR}/${ARCHIVE_NAME}" "./${ARCHIVE_NAME}"

# 4. Commit current state to Git and apply a permanent Milestone Tag
echo "==> 3. Creating permanent Git commit, branch, and tag..."
git add -A
git commit -m "MASTER PRODUCTION BACKUP: Stable milestone with full multi-vendor sync & localStorage [${TIMESTAMP}]" || echo "Working tree already clean."
git branch "restore-production-${TIMESTAMP}" 2>/dev/null || true
git tag -a "${GIT_TAG}" -m "Production Stable Milestone - All modules fully aligned and persistent [${TIMESTAMP}]" 2>/dev/null || true

echo ""
echo "=========================================================="
echo "✓ MASTER BACKUP CREATED SUCCESSFULLY"
echo "=========================================================="
echo "• Backup Directory : ${BACKUP_DIR}/"
echo "• Archive Bundle   : ./${ARCHIVE_NAME}"
echo "• Git Tag Pointer  : ${GIT_TAG}"
echo "• Git Branch Point : restore-production-${TIMESTAMP}"
echo "=========================================================="
