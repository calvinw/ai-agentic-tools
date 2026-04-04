#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_CONF_FILE="$WORKSPACE_DIR/configs/mcp-servers.conf"

. "$SCRIPT_DIR/lib-mcp-parse.sh"
parse_mcp_names_only "$MCP_CONF_FILE"

if [ ${#MCP_NAMES[@]} -eq 0 ]; then
  echo "No MCPs configured in $MCP_CONF_FILE"
  exit 0
fi

if command -v claude >/dev/null 2>&1; then
  for name in "${MCP_NAMES[@]}"; do
    claude mcp remove -s user "$name" 2>/dev/null || true
  done
  echo "Claude MCPs removed via CLI."
else
  echo "Claude not found, skipping."
fi
