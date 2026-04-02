#!/bin/bash
set -e

# Symlinks .codex/config.toml into ~/.codex/ so Codex picks it up regardless
# of which directory it's launched from. Also injects the [projects."..."]
# trust entry for the current workspace if it isn't already present.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
CODEX_CONFIG="$WORKSPACE_DIR/.codex/config.toml"

mkdir -p ~/.codex

# Append the workspace trust entry if not already present.
if ! grep -qF "[projects.\"$WORKSPACE_DIR\"]" "$CODEX_CONFIG"; then
  printf '\n[projects."%s"]\ntrust_level = "trusted"\n' "$WORKSPACE_DIR" >> "$CODEX_CONFIG"
fi

ln -sf "$CODEX_CONFIG" ~/.codex/config.toml

echo "Codex setup done."
