#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/uninstall-claude-mcp.sh"
"$SCRIPT_DIR/uninstall-opencode-mcp.sh"
"$SCRIPT_DIR/uninstall-copilot-mcp.sh"
"$SCRIPT_DIR/uninstall-gemini-mcp.sh"
"$SCRIPT_DIR/uninstall-crush-mcp.sh"
"$SCRIPT_DIR/uninstall-codex-mcp.sh"
