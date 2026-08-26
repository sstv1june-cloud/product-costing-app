#!/usr/bin/env bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BRANCH=$(git rev-parse --abbrev-ref HEAD)
TAG_NAME="checkpoint-${BRANCH}-${TIMESTAMP}"
BACKUP_BRANCH="backup/${BRANCH}-stable-${TIMESTAMP}"
ARCHIVE_NAME="backup_${BRANCH}_${TIMESTAMP}.tar.gz"

echo "==> 1. Staging and committing all pending changes on ${BRANCH}..."
git add -A
git commit -m "checkpoint(${BRANCH}): verified purchase/sales templates, RM default lock, MIS & costing report exports [${TIMESTAMP}]" || echo "Working tree clean."

echo "==> 2. Pushing current state to remote origin/${BRANCH}..."
git push origin "${BRANCH}"

echo "==> 3. Creating Git checkpoint tag: ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "Stable restore point for ${BRANCH} at ${TIMESTAMP}"
git push origin "${TAG_NAME}"

echo "==> 4. Creating dedicated backup branch: ${BACKUP_BRANCH}..."
git branch "${BACKUP_BRANCH}"
git push origin "${BACKUP_BRANCH}"

echo "==> 5. Generating offline tarball archive (${ARCHIVE_NAME})..."
tar --exclude='./node_modules' --exclude='./.git' --exclude='./dist' -czf "../${ARCHIVE_NAME}" .
mv "../${ARCHIVE_NAME}" "./${ARCHIVE_NAME}"

echo "-------------------------------------------------------------------"
echo "✅ BACKUP & RESTORE POINT CREATED SUCCESSFULLY!"
echo "   • Git Tag:        ${TAG_NAME}"
echo "   • Backup Branch:  ${BACKUP_BRANCH}"
echo "   • Archive File:   ${ARCHIVE_NAME}"
echo "   • Active Branch:  ${BRANCH} (Untouched & Ready)"
echo "-------------------------------------------------------------------"
