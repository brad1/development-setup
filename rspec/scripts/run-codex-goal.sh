#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf 'Usage: %s TASK_DIR\n' "${0##*/}" >&2
  printf 'Runs each numbered Ruby variant in TASK_DIR in a separate RSpec process.\n' >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 64
fi

task_dir=$1

if [[ ! -d "$task_dir" ]]; then
  printf 'Task directory not found: %s\n' "$task_dir" >&2
  exit 66
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
project_dir=$(cd -- "$script_dir/.." && pwd)

mapfile -t variants < <(
  find "$task_dir" -maxdepth 1 -type f -name '[0-9][0-9][0-9]_*.rb' | sort
)

if [[ ${#variants[@]} -eq 0 ]]; then
  printf 'No numbered Ruby variants found in: %s\n' "$task_dir" >&2
  exit 65
fi

for variant in "${variants[@]}"; do
  printf '\n==> %s\n' "$variant"
  "$project_dir/scripts/ci-test.sh" "$variant"
done
