#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="backups/backup_${TIMESTAMP}"
ARCHIVE_NAME="project_backup_${TIMESTAMP}.tar.gz"

echo "==> Creating local backup directory: ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

# 1. Copy full source tree and critical config files
echo "==> Copying application source and configuration files..."
cp -r src/ "${BACKUP_DIR}/"
cp package.json "${BACKUP_DIR}/" 2>/dev/null || true
cp vite.config.js "${BACKUP_DIR}/" 2>/dev/null || true
cp tailwind.config.js "${BACKUP_DIR}/" 2>/dev/null || true

# 2. Package everything into a compressed archive
echo "==> Compressing into archive: backups/${ARCHIVE_NAME}..."
tar -czf "backups/${ARCHIVE_NAME}" -C "${BACKUP_DIR}" .

# 3. Create a Git restore checkpoint
echo "==> Creating Git restore commit checkpoint..."
git add -A 2>/dev/null || true
git commit -m "RESTORE POINT: Full state before audit log & parameter sync (${TIMESTAMP})" 2>/dev/null || true
git tag -f "checkpoint-${TIMESTAMP}" 2>/dev/null || true

echo "--------------------------------------------------------"
echo "✅ FULL BACKUP COMPLETE"
echo "📁 Archive Location: backups/${ARCHIVE_NAME}"
echo "🏷️ Git Checkpoint Tag: checkpoint-${TIMESTAMP}"
echo "--------------------------------------------------------"
