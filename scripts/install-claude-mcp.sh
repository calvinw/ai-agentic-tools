#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_CONF_FILE="$WORKSPACE_DIR/configs/mcp-servers.conf"

. "$SCRIPT_DIR/lib-mcp-parse.sh"
parse_mcp_conf "$MCP_CONF_FILE"

if [ ${#MCP_NAMES[@]} -eq 0 ]; then
  echo "No MCPs configured in $MCP_CONF_FILE"
  exit 0
fi

if command -v claude >/dev/null 2>&1; then
  for i in "${!MCP_NAMES[@]}"; do
    name="${MCP_NAMES[$i]}"
    url="${MCP_URLS[$i]}"
    transport="${MCP_TRANSPORTS[$i]}"
    headers="${MCP_HEADERS[$i]}"

    args=(-s user "$name" --transport "$transport" "$url")
    if [[ -n "$headers" ]]; then
      IFS='|' read -ra hfields <<< "$headers"
      for hfield in "${hfields[@]}"; do
        hname="${hfield%%:*}"
        hval="${hfield#*:}"
        args+=(--header "$hname: $hval")
      done
    fi
    claude mcp add "${args[@]}"
  done
  echo "Claude MCPs registered via CLI."
else
  echo "Claude not found, skipping."
fi
