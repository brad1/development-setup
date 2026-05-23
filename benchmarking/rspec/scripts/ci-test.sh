#!/usr/bin/env bash

set -euo pipefail

# Ensure user-installed Ruby gem executables like `bundle` are available.
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"

bundle exec rspec "$@"
