#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "$script_dir/train_tiny_chat.sh" \
  --steps 100 \
  --log-every 25 \
  --max-new-tokens 40 \
  "$@"
