#!/bin/bash
set -e

# Symlinks .gemini/settings.json into ~/.gemini/ so Gemini CLI picks it up
# regardless of which directory it's launched from.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

mkdir -p ~/.gemini
ln -sf "$WORKSPACE_DIR/.gemini/settings.json" ~/.gemini/settings.json

echo "Gemini setup done."
