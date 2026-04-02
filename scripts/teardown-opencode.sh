#!/bin/bash
set -e

# Removes only the MCP entries (from mcp-urls.conf) from .opencode/opencode.json,
# leaving all other settings intact.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_URLS_FILE="$WORKSPACE_DIR/configs/mcp-urls.conf"
OPENCODE_CONFIG="$WORKSPACE_DIR/.opencode/opencode.json"

if [ -f "$OPENCODE_CONFIG" ] && [ -f "$MCP_URLS_FILE" ]; then
  names=()
  while IFS='=' read -r name url; do
    [ -z "$name" ] && continue
    case "$name" in \#*) continue ;; esac
    names+=("$name")
  done < "$MCP_URLS_FILE"

  if [ ${#names[@]} -gt 0 ]; then
    python3 - "$OPENCODE_CONFIG" "${names[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
names = set(sys.argv[2:])
with open(path) as f:
    config = json.load(f)
servers = config.get("mcp", {})
for name in names:
    servers.pop(name, None)
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
    echo "Removed MCP entries from $OPENCODE_CONFIG"
  fi
fi

echo "OpenCode MCP entries removed."
