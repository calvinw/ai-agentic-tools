#!/usr/bin/env bash
set -euo pipefail

config_dir="${CODEX_HOME:-$HOME/.codex}"
config_file="$config_dir/config.toml"

mkdir -p "$config_dir"
touch "$config_file"

set_top_level_key() {
  local key="$1"
  local value="$2"

  if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$config_file"; then
    sed -i -E "s|^[[:space:]]*${key}[[:space:]]*=.*$|${key} = ${value}|" "$config_file"
  else
    local temp_file
    temp_file="$(mktemp)"
    awk -v entry="${key} = ${value}" '
      !inserted && /^\[/ { print entry; print ""; inserted = 1 }
      { print }
      END { if (!inserted) print entry }
    ' "$config_file" > "$temp_file"
    mv "$temp_file" "$config_file"
  fi
}

# The dev container provides the isolation boundary, so avoid nesting Codex's
# command sandbox inside it. Keep approvals available for sensitive actions.
set_top_level_key "approval_policy" '"on-request"'
set_top_level_key "sandbox_mode" '"danger-full-access"'
