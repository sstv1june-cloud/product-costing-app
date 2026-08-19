#!/usr/bin/env bash
set -e

if [ ! -f "./CPC_LATEST_STABLE_BACKUP.tar.gz" ]; then
  echo "Error: ./CPC_LATEST_STABLE_BACKUP.tar.gz not found!"
  exit 1
fi

echo "==> Restoring full project from stable checkpoint..."
tar -xzf ./CPC_LATEST_STABLE_BACKUP.tar.gz
echo "==> Project successfully restored to 5-module stable recovery point."
