#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REACT_DIR="$ROOT_DIR/ReactDashboard"

if [[ ! -d "$REACT_DIR" ]]; then
  echo "ReactDashboard directory not found at $REACT_DIR" >&2
  exit 1
fi

cd "$REACT_DIR"

if [[ -f package-lock.json ]]; then
  npm ci
else
  npm install --package-lock-only
  npm ci
fi
