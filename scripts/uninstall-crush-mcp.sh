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

python3 - "$WORKSPACE_DIR/.crush.json" "${MCP_NAMES[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
names = set(sys.argv[2:])
with open(path) as f:
    config = json.load(f)
for name in names:
    config.get("mcp", {}).pop(name, None)
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
echo "Crush MCPs removed."
