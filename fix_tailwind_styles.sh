#!/usr/bin/env bash
set -e

# 1. Ensure Tailwind CSS, PostCSS, and Autoprefixer are configured
cat << 'CONFIG_EOF' > tailwind.config.js
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
CONFIG_EOF

cat << 'POSTCSS_EOF' > postcss.config.js
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTCSS_EOF

# 2. Re-create main stylesheet with Tailwind directives
mkdir -p src
cat << 'CSS_EOF' > src/index.css
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  padding: 0;
  background-color: #f8fafc;
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  color: #0f172a;
}
CSS_EOF

# 3. Ensure src/main.jsx imports './index.css'
cat << 'MAIN_EOF' > src/main.jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
MAIN_EOF

# 4. Clean Vite cache and restart
rm -rf node_modules/.vite
killall -9 node 2>/dev/null || fuser -k 5173/tcp 2>/dev/null || true
npm run dev -- --host 0.0.0.0 --port 5173
