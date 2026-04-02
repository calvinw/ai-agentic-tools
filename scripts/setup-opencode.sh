#!/bin/bash
set -e

# Symlinks .opencode/opencode.json into ~/.config/opencode/ so OpenCode picks
# it up regardless of which directory it's launched from.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

mkdir -p ~/.config/opencode
ln -sf "$WORKSPACE_DIR/.opencode/opencode.json" ~/.config/opencode/opencode.json

echo "OpenCode setup done."
