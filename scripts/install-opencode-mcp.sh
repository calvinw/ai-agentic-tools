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

python3 - "$WORKSPACE_DIR/.opencode/opencode.json" "${#MCP_NAMES[@]}" \
  "${MCP_NAMES[@]}" "${MCP_URLS[@]}" "${MCP_TRANSPORTS[@]}" "${MCP_HEADERS[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
count = int(sys.argv[2])
names       = sys.argv[3:3+count]
urls        = sys.argv[3+count:3+2*count]
transports  = sys.argv[3+2*count:3+3*count]
headers_raw = sys.argv[3+3*count:3+4*count]
with open(path) as f:
    config = json.load(f)
servers = config.setdefault("mcp", {})
for i in range(count):
    # OpenCode uses type "remote" for both SSE and HTTP transports.
    # oauth: false suppresses OAuth discovery when using API key headers.
    obj = {"type": "remote", "url": urls[i], "enabled": True}
    if headers_raw[i]:
        obj["oauth"] = False
        obj["headers"] = {h.partition(':')[0]: h.partition(':')[2]
                          for h in headers_raw[i].split('|')}
    servers[names[i]] = obj
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
echo "OpenCode MCPs added."
