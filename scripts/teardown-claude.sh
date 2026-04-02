#!/bin/bash
set -e

# Removes only the MCP entries (from mcp-urls.conf) from .claude/settings.json,
# leaving all other settings intact. Also deregisters each MCP via `claude mcp remove`.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_URLS_FILE="$WORKSPACE_DIR/configs/mcp-urls.conf"
CLAUDE_SETTINGS="$WORKSPACE_DIR/.claude/settings.json"

if [ -f "$CLAUDE_SETTINGS" ] && [ -f "$MCP_URLS_FILE" ]; then
  # Collect MCP names to remove as JSON array for Python
  names=()
  while IFS='=' read -r name url; do
    [ -z "$name" ] && continue
    case "$name" in \#*) continue ;; esac
    names+=("$name")
  done < "$MCP_URLS_FILE"

  if [ ${#names[@]} -gt 0 ]; then
    python3 - "$CLAUDE_SETTINGS" "${names[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
names = set(sys.argv[2:])
with open(path) as f:
    config = json.load(f)
servers = config.get("mcpServers", {})
for name in names:
    servers.pop(name, None)
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
    echo "Removed MCP entries from $CLAUDE_SETTINGS"
  fi
fi

# Deregister each MCP server from the user-scope Claude config.
if command -v claude >/dev/null 2>&1 && [ -f "$MCP_URLS_FILE" ]; then
  while IFS='=' read -r name url; do
    [ -z "$name" ] && continue
    case "$name" in \#*) continue ;; esac
    claude mcp remove -s user "$name" 2>/dev/null || true
  done < "$MCP_URLS_FILE"
fi

echo "Claude MCP entries removed."
