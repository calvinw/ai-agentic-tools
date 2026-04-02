#!/bin/bash
set -e

# Removes all MCP configs and symlinks registered by install-mcps.sh.
# Safe to run at any time — re-running is idempotent.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

bash "$WORKSPACE_DIR/scripts/teardown-claude.sh"
bash "$WORKSPACE_DIR/scripts/teardown-codex.sh"
bash "$WORKSPACE_DIR/scripts/teardown-copilot.sh"
bash "$WORKSPACE_DIR/scripts/teardown-crush.sh"
bash "$WORKSPACE_DIR/scripts/teardown-gemini.sh"
bash "$WORKSPACE_DIR/scripts/teardown-opencode.sh"
