#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_BRANCH="backup/main-live-${TIMESTAMP}"
TAG_NAME="live-main-checkpoint-${TIMESTAMP}"
ARCHIVE_NAME="../main-live-backup-${TIMESTAMP}.tar.gz"

echo "==> 1. Checking out main branch..."
git checkout main

echo "==> 2. Pulling latest live changes..."
git pull origin main || echo "Working locally or already up to date."

echo "==> 3. Creating dedicated backup branch: ${BACKUP_BRANCH}..."
git branch "${BACKUP_BRANCH}"

echo "==> 4. Creating tagged restore point: ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "Live Production Main Restore Point at ${TIMESTAMP}"

echo "==> 5. Creating compressed offline archive at ${ARCHIVE_NAME}..."
tar --exclude='./node_modules' --exclude='./.git' --exclude='./dist' -czf "${ARCHIVE_NAME}" .

echo "-------------------------------------------------------------------"
echo "✅ LIVE MAIN BACKUP & RESTORE POINT CREATED SUCCESSFULLY!"
echo "   • Production Branch : main"
echo "   • Backup Branch     : ${BACKUP_BRANCH}"
echo "   • Restore Tag       : ${TAG_NAME}"
echo "   • Offline Archive   : ${ARCHIVE_NAME}"
echo "-------------------------------------------------------------------"
