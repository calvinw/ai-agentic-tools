#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_URLS_FILE="$WORKSPACE_DIR/configs/mcp-urls.conf"

names=()
while IFS='=' read -r name url; do
  [ -z "$name" ] && continue
  case "$name" in \#*) continue ;; esac
  names+=("$name")
done < "$MCP_URLS_FILE"

if [ ${#names[@]} -eq 0 ]; then
  echo "No MCPs configured in $MCP_URLS_FILE"
  exit 0
fi

if command -v claude >/dev/null 2>&1; then
  for name in "${names[@]}"; do
    claude mcp remove -s user "$name" 2>/dev/null || true
  done
  echo "Claude MCPs removed via CLI."
else
  echo "Claude not found, skipping."
fi
