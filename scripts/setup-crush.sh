#!/bin/bash
set -e

# Symlinks .crush/crush.json into ~/.config/crush/ so Crush picks it up
# regardless of which directory it's launched from.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

mkdir -p ~/.config/crush
ln -sf "$WORKSPACE_DIR/.crush/crush.json" ~/.config/crush/crush.json

echo "Crush setup done."
