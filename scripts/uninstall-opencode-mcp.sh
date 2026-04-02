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

python3 - "$WORKSPACE_DIR/.opencode/opencode.json" "${names[@]}" <<'EOF'
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
echo "OpenCode MCPs removed."
