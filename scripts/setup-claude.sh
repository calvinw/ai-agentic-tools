#!/bin/bash
set -e

# Symlinks .claude/settings.json into ~/.claude/ so Claude Code picks it up
# regardless of which directory it's launched from.
# Also adds the alias that enables sandbox bypass mode.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

mkdir -p ~/.claude
ln -sf "$WORKSPACE_DIR/.claude/settings.json" ~/.claude/settings.json

ALIAS_LINE="alias claude='IS_SANDBOX=1 claude --dangerously-skip-permissions'"
grep -qF "$ALIAS_LINE" ~/.bashrc 2>/dev/null || echo "$ALIAS_LINE" >> ~/.bashrc
grep -qF "$ALIAS_LINE" ~/.bash_profile 2>/dev/null || echo "$ALIAS_LINE" >> ~/.bash_profile

echo "Claude setup done."
