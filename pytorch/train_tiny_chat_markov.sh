#!/usr/bin/env bash
set -euo pipefail

if [[ -f "pytorch/.venv/bin/activate" ]]; then
  source "pytorch/.venv/bin/activate"
fi

DATA_PATH="$(mktemp)"
trap 'rm -f "$DATA_PATH"' EXIT

cat > "$DATA_PATH" <<'EOF'
H H T H H T H H T H H T H H T H H T
H H T H H T H H T H H T H H T H H T
H H T H H T H H T H H T H H T H H T
EOF

python3 pytorch/train_tiny_chat.py \
  --data "$DATA_PATH" \
  --steps 3000 \
  --batch-size 32 \
  --block-size 16 \
  --lr 1e-2 \
  --prompt "H H " \
  --max-new-tokens 40 \
  --model bigram
