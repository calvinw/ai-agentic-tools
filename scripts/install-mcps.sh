#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/install-claude-mcp.sh"
"$SCRIPT_DIR/install-opencode-mcp.sh"
"$SCRIPT_DIR/install-copilot-mcp.sh"
"$SCRIPT_DIR/install-gemini-mcp.sh"
"$SCRIPT_DIR/install-crush-mcp.sh"
"$SCRIPT_DIR/install-codex-mcp.sh"
