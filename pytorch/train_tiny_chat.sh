#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python_script="$script_dir/train_tiny_chat.py"

if [[ -n "${PYTHON_BIN:-}" ]]; then
  python_bin="$PYTHON_BIN"
elif [[ -x "$script_dir/.venv/bin/python" ]]; then
  python_bin="$script_dir/.venv/bin/python"
else
  python_bin="python3"
fi

data_file="$(mktemp)"
prompt_file="$(mktemp)"
trap 'rm -f "$data_file" "$prompt_file"' EXIT

cat >"$data_file" <<'DATA'
User: hi
Assistant: hello

User: how are you?
Assistant: i am good.

User: what is 2+2?
Assistant: 4

User: tell me a joke
Assistant: tiny models tell tiny jokes.
DATA

cat >"$prompt_file" <<'PROMPT'
User: hi
Assistant:
PROMPT

prompt="$(<"$prompt_file")"

steps="${TRAIN_TINY_CHAT_STEPS:-200}"
batch_size="${TRAIN_TINY_CHAT_BATCH_SIZE:-16}"
block_size="${TRAIN_TINY_CHAT_BLOCK_SIZE:-32}"
lr="${TRAIN_TINY_CHAT_LR:-0.01}"
seed="${TRAIN_TINY_CHAT_SEED:-1337}"
log_every="${TRAIN_TINY_CHAT_LOG_EVERY:-50}"
max_new_tokens="${TRAIN_TINY_CHAT_MAX_NEW_TOKENS:-60}"
device="${TRAIN_TINY_CHAT_DEVICE:-cpu}"

exec "$python_bin" "$python_script" \
  --data "$data_file" \
  --prompt "$prompt" \
  --steps "$steps" \
  --batch-size "$batch_size" \
  --block-size "$block_size" \
  --lr "$lr" \
  --seed "$seed" \
  --log-every "$log_every" \
  --max-new-tokens "$max_new_tokens" \
  --device "$device" \
  "$@"
