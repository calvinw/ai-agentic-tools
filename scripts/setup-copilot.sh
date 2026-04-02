#!/bin/bash
set -e

# Symlinks .copilot/mcp-config.json into ~/.copilot/ so Copilot picks it up
# regardless of which directory it's launched from.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

mkdir -p ~/.copilot
ln -sf "$WORKSPACE_DIR/.copilot/mcp-config.json" ~/.copilot/mcp-config.json

echo "Copilot setup done."
