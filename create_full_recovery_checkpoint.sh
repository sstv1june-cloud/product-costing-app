#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="backups/checkpoint_${TIMESTAMP}"
ARCHIVE_NAME="CPC_Costing_5Modules_Recovery_${TIMESTAMP}.tar.gz"

echo "==> Creating backup directory: ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}"

# 1. Archive core source files, public assets, configs, and stores (excluding heavy node_modules & dist)
echo "==> Compressing project snapshot into ${ARCHIVE_NAME}..."
tar --exclude='./node_modules' \
    --exclude='./dist' \
    --exclude='./.git' \
    --exclude='./backups' \
    -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" .

# Copy latest backup archive to root for immediate visibility
cp "${BACKUP_DIR}/${ARCHIVE_NAME}" "./CPC_LATEST_STABLE_BACKUP.tar.gz"

# 2. Generate a 1-click restore script
cat << 'RESTORE_EOF' > restore_backup.sh
#!/usr/bin/env bash
set -e

if [ ! -f "./CPC_LATEST_STABLE_BACKUP.tar.gz" ]; then
  echo "Error: ./CPC_LATEST_STABLE_BACKUP.tar.gz not found!"
  exit 1
fi

echo "==> Restoring full project from stable checkpoint..."
tar -xzf ./CPC_LATEST_STABLE_BACKUP.tar.gz
echo "==> Project successfully restored to 5-module stable recovery point."
RESTORE_EOF
chmod +x restore_backup.sh

# 3. Create a Git Tag and Branch checkpoint
if [ -d ".git" ]; then
  echo "==> Creating Git recovery branch and tag..."
  git add -A
  git commit -m "CHECKPOINT: Stable 5-Module CPC Costing & MIS System with Gemini 3.6 & OpenAI GPT-4o (${TIMESTAMP})" || true
  git branch -M "recovery-stable-5modules-${TIMESTAMP}" || true
  git tag -a "v1.0.0-stable-5modules" -m "Stable state: Dashboard, Baseline, RM Matrix, Costing Engine, MIS, AI Analyst" || true
fi

echo ""
echo "================================================================="
echo "✅ FULL RECOVERY POINT CREATED SUCCESSFULLY!"
echo "-----------------------------------------------------------------"
echo "• Backup Archive Location : ${BACKUP_DIR}/${ARCHIVE_NAME}"
echo "• Quick Restore File      : ./CPC_LATEST_STABLE_BACKUP.tar.gz"
echo "• 1-Click Restore Command : bash restore_backup.sh"
echo "• Git Branch Checkpoint   : recovery-stable-5modules-${TIMESTAMP}"
echo "================================================================="
