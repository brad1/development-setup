#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="$ROOT_DIR/.venv/bin/python"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Missing virtualenv at $ROOT_DIR/.venv" >&2
  echo "Run bash setup.sh first." >&2
  exit 1
fi

cd "$ROOT_DIR"
"$PYTHON_BIN" -m pytest -q
