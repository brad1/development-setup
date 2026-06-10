#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIRS=("$ROOT_DIR/ReactDashboard" "$ROOT_DIR/IncentivesLedger")

for APP_DIR in "${APP_DIRS[@]}"; do
  if [[ ! -d "$APP_DIR" ]]; then
    echo "Application directory not found at $APP_DIR" >&2
    exit 1
  fi

  cd "$APP_DIR"
  npm test
  npm run build
done
