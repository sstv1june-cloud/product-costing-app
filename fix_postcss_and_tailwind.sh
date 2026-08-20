#!/usr/bin/env bash
set -e

echo "==> 1. Re-installing required styling packages..."
npm install tailwindcss @tailwindcss/postcss autoprefixer xlsx

echo "==> 2. Re-creating postcss.config.js..."
cat << 'POST_EOF' > postcss.config.js
export default {
  plugins: {
    '@tailwindcss/postcss': {},
    autoprefixer: {},
  },
}
POST_EOF

echo "==> 3. Restarting Vite Server..."
rm -rf node_modules/.vite 2>/dev/null || true
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
nohup npm run dev -- --host 0.0.0.0 --port 5173 > /tmp/vite_server.log 2>&1 &
sleep 2

echo "==> Done! Styling restored and .xlsx download enabled."
