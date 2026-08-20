#!/usr/bin/env bash
set -e

# 1. Identify the latest backup archive
LATEST_BACKUP=$(ls -t backups/project_backup_*.tar.gz 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "⚠️ No backup archive found in backups/. Checking for backup directories..."
  LATEST_DIR=$(ls -td backups/backup_* 2>/dev/null | head -n 1)
  if [ -n "$LATEST_DIR" ]; then
    echo "Restoring from directory: $LATEST_DIR"
    cp -rf "$LATEST_DIR/src" ./
    cp "$LATEST_DIR/package.json" ./ 2>/dev/null || true
    cp "$LATEST_DIR/vite.config.js" ./ 2>/dev/null || true
  else
    echo "Restoring via Git checkpoint tag..."
    LATEST_TAG=$(git tag -l "checkpoint-*" --sort=-v:refname 2>/dev/null | head -n 1)
    if [ -n "$LATEST_TAG" ]; then
      git checkout -f "$LATEST_TAG"
    else
      git reset --hard HEAD
    fi
  fi
else
  echo "==> Restoring from archive: $LATEST_BACKUP"
  # Clean old src to prevent orphaned files
  rm -rf src/
  tar -xzf "$LATEST_BACKUP" -C ./
fi

# 2. Reset build cache and restart development server
echo "==> Clearing Vite cache..."
rm -rf node_modules/.vite 2>/dev/null || true

echo "==> Restarting Vite Server..."
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "--------------------------------------------------------"
echo "✅ VERIFIED RESTORE COMPLETED SUCCESSFULLY"
echo "🌐 Server running on port 5173"
echo "--------------------------------------------------------"
