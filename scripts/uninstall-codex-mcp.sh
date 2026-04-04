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

python3 - "$WORKSPACE_DIR/.codex/config.toml" "${MCP_NAMES[@]}" <<'EOF'
import sys, re
path = sys.argv[1]
names = set(sys.argv[2:])
with open(path) as f:
    lines = f.readlines()
result = []
skip = False
for line in lines:
    m = re.match(r'^\[mcp_servers\.(?:"([^"]+)"|(\S+))\]', line)
    if m and (m.group(1) or m.group(2)) in names:
        skip = True
        continue
    if skip and re.match(r'^\[', line):
        skip = False
    if not skip:
        result.append(line)
while result and result[-1].strip() == "":
    result.pop()
if result:
    result.append("\n")
with open(path, "w") as f:
    f.writelines(result)
EOF
echo "Codex MCPs removed."
