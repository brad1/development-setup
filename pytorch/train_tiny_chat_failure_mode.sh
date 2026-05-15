#!/usr/bin/env bash
set -euo pipefail

if [[ -f "pytorch/.venv/bin/activate" ]]; then
  source "pytorch/.venv/bin/activate"
fi

echo "== pairlinear: expected to plateau because same/different is nonlinear =="
python3 pytorch/train_tiny_chat.py \
  --task same-different \
  --steps 1000 \
  --batch-size 64 \
  --lr 1e-2 \
  --log-every 250 \
  --prompt "HT" \
  --max-new-tokens 12 \
  --sample-strategy argmax \
  --model pairlinear

echo
echo "== bigram2: expected to improve because the hidden ReLU layer can learn the interaction =="
python3 pytorch/train_tiny_chat.py \
  --task same-different \
  --steps 1000 \
  --batch-size 64 \
  --lr 1e-2 \
  --log-every 250 \
  --prompt "HT" \
  --max-new-tokens 12 \
  --sample-strategy argmax \
  --model bigram2
