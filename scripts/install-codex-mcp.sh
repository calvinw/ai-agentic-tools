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

CODEX_MCP_BRIDGE_BIN="$(command -v supergateway || true)"
if [ -n "$CODEX_MCP_BRIDGE_BIN" ]; then
  python3 - "$WORKSPACE_DIR/.codex/config.toml" "$CODEX_MCP_BRIDGE_BIN" "${entries[@]}" <<'EOF'
import sys
path = sys.argv[1]
bridge = sys.argv[2]
entries = sys.argv[3:]
with open(path) as f:
    content = f.read()
for entry in entries:
    name, _, url = entry.partition("=")
    section = f'[mcp_servers.{name}]'
    if section not in content:
        content = content.rstrip("\n") + f'\n\n[mcp_servers.{name}]\ncommand = "{bridge}"\nargs = ["--sse", "{url}", "--logLevel", "none"]\n'
with open(path, "w") as f:
    f.write(content)
EOF
  echo "Codex MCPs added."
else
  echo "Codex MCPs skipped (supergateway not found)."
fi
