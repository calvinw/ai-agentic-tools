#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_URLS_FILE="$WORKSPACE_DIR/configs/mcp-urls.conf"

entries=()
while IFS='=' read -r name url; do
  [ -z "$name" ] && continue
  case "$name" in \#*) continue ;; esac
  entries+=("$name=$url")
done < "$MCP_URLS_FILE"

if [ ${#entries[@]} -eq 0 ]; then
  echo "No MCPs configured in $MCP_URLS_FILE"
  exit 0
fi

python3 - "$WORKSPACE_DIR/.crush.json" "${entries[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    config = json.load(f)
servers = config.setdefault("mcp", {})
for entry in sys.argv[2:]:
    name, _, url = entry.partition("=")
    servers[name] = {"type": "sse", "url": url}
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
echo "Crush MCPs added."
