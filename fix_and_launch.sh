#!/usr/bin/env bash
set -e

# 1. Kill any existing node/vite processes completely
killall -9 node 2>/dev/null || fuser -k 5173/tcp 3000/tcp 2>/dev/null || true

# 2. Ensure vite.config.js has explicit root and base configuration
cat << 'CONFIG_EOF' > vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  root: '.',
  base: '/',
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    allowedHosts: true,
    cors: true
  },
  preview: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    allowedHosts: true,
    cors: true
  }
});
CONFIG_EOF

# 3. Clean cache and restart development server
rm -rf node_modules/.vite
npm run dev -- --host 0.0.0.0 --port 5173
