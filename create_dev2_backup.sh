#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_ARCHIVE="backup_dev2_${TIMESTAMP}.tar.gz"
BRANCH_NAME="backup-dev2-${TIMESTAMP}"
TAG_NAME="checkpoint-dev2-${TIMESTAMP}"

echo "==> 1. Staging and committing any uncommitted changes on dev-v2..."
git checkout dev-v2
git add .
git commit -m "Checkpoint: dev-v2 stable state with editable approved price, dropdown alternates & audit logging as of ${TIMESTAMP}" || true

echo "==> 2. Creating local compressed backup archive..."
mkdir -p backups
tar --exclude='node_modules' --exclude='.git' --exclude='backups' -czf "backups/${BACKUP_ARCHIVE}" ./

echo "==> 3. Creating Git backup branch: ${BRANCH_NAME}..."
git branch "${BRANCH_NAME}"

echo "==> 4. Creating Git checkpoint tag: ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "Full Restore Point: dev-v2 as of ${TIMESTAMP}"

echo "==> 5. Pushing dev-v2 branch, backup branch & tag to GitHub for cloud safety..."
git push origin dev-v2
git push origin "${BRANCH_NAME}"
git push origin "${TAG_NAME}"

echo "-------------------------------------------------------------------"
echo "✅ DEV-V2 BACKUP & RESTORE POINT CREATED SUCCESSFULLY"
echo "📦 Local Archive: backups/${BACKUP_ARCHIVE}"
echo "🌿 GitHub Backup Branch: ${BRANCH_NAME}"
echo "🏷️ Git Restore Tag: ${TAG_NAME}"
echo "-------------------------------------------------------------------"
