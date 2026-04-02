#!/bin/bash
set -e

# Re-runs all per-tool MCP setup scripts so that any MCPs added to
# configs/mcp-urls.conf are registered in every AI tool.
# Safe to run at any time — re-running is idempotent.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

bash "$WORKSPACE_DIR/scripts/setup-claude.sh"
bash "$WORKSPACE_DIR/scripts/setup-codex.sh"
bash "$WORKSPACE_DIR/scripts/setup-copilot.sh"
bash "$WORKSPACE_DIR/scripts/setup-crush.sh"
bash "$WORKSPACE_DIR/scripts/setup-gemini.sh"
bash "$WORKSPACE_DIR/scripts/setup-opencode.sh"
