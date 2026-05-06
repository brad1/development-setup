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

echo "== bigram: expected to plateau because it only sees one token of context =="
python3 pytorch/train_tiny_chat.py \
  --data "$DATA_PATH" \
  --steps 3000 \
  --batch-size 32 \
  --block-size 16 \
  --lr 1e-2 \
  --prompt "H H " \
  --max-new-tokens 40 \
  --model bigram

echo
echo "== bigram2: expected to improve because it can use a 2-token context =="
python3 pytorch/train_tiny_chat.py \
  --data "$DATA_PATH" \
  --steps 3000 \
  --batch-size 32 \
  --block-size 16 \
  --lr 1e-2 \
  --prompt "H H " \
  --max-new-tokens 40 \
  --model bigram2
