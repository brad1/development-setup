#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting Vite dev server for playwright-test"
cd ReactDashboard

if [ -f package-lock.json ]; then
  npm ci >/tmp/reactdashboard-npm.log 2>&1
else
  npm install >/tmp/reactdashboard-npm.log 2>&1
fi

echo "==> Ensuring Playwright system deps"
if ! npx playwright install-deps chromium >/tmp/reactdashboard-playwright-deps.log 2>&1; then
  echo "==> Playwright deps install failed. See /tmp/reactdashboard-playwright-deps.log"
  exit 1
fi

echo "==> Ensuring Playwright browser binaries"
npx playwright install chromium >/tmp/reactdashboard-playwright-install.log 2>&1

mkdir -p artifacts

port=$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(('127.0.0.1', 0))
print(s.getsockname()[1])
s.close()
PY
)

echo "==> Using dev server port ${port}"
npm run dev -- --host 127.0.0.1 --port "${port}" --strictPort >/tmp/reactdashboard-dev.log 2>&1 &
pid=$!
trap 'echo "==> Stopping Vite (pid ${pid})"; kill ${pid} >/dev/null 2>&1 || true' EXIT

for _ in {1..40}; do
  if curl -sf "http://127.0.0.1:${port}/" >/dev/null; then
    break
  fi
  sleep 0.25
done

echo "==> Running Playwright ops"
VITE_PORT="${port}" node -e "import('playwright').then(async ({ chromium }) => { const browser = await chromium.launch(); const page = await browser.newPage(); await page.setViewportSize({ width: 1440, height: 900 }); await page.goto('http://127.0.0.1:' + process.env.VITE_PORT + '/', { waitUntil: 'networkidle' }); await page.waitForTimeout(1000); await page.screenshot({ path: 'artifacts/react-dashboard-playwright.png', fullPage: true }); await browser.close(); });" >/tmp/reactdashboard-playwright.log 2>&1

echo "==> Screenshot saved to ReactDashboard/artifacts/react-dashboard-playwright.png"
echo "==> playwright-test passed"
echo "==> Please run playwright-test between code drafts and share /tmp/reactdashboard-playwright.log for follow-up corrections."
