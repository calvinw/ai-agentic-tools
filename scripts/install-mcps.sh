#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_URLS_FILE="$WORKSPACE_DIR/configs/mcp-urls.conf"

# Collect entries — skip blank lines and comments
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

# --- Claude: use CLI ---
if command -v claude >/dev/null 2>&1; then
  for entry in "${entries[@]}"; do
    name="${entry%%=*}"
    url="${entry#*=}"
    claude mcp add -s user "$name" --transport sse "$url" 2>/dev/null || true
  done
  echo "Claude MCPs registered via CLI."
fi

# --- Copilot: edit .copilot/mcp-config.json ---
python3 - "$WORKSPACE_DIR/.copilot/mcp-config.json" "${entries[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    config = json.load(f)
servers = config.setdefault("mcpServers", {})
for entry in sys.argv[2:]:
    name, _, url = entry.partition("=")
    servers[name] = {"type": "sse", "url": url}
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
echo "Copilot MCPs added."

# --- Gemini: edit .gemini/settings.json ---
python3 - "$WORKSPACE_DIR/.gemini/settings.json" "${entries[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    config = json.load(f)
servers = config.setdefault("mcpServers", {})
for entry in sys.argv[2:]:
    name, _, url = entry.partition("=")
    servers[name] = {"type": "sse", "url": url}
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
echo "Gemini MCPs added."

# --- OpenCode: edit .opencode/opencode.json ---
python3 - "$WORKSPACE_DIR/.opencode/opencode.json" "${entries[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    config = json.load(f)
servers = config.setdefault("mcp", {})
for entry in sys.argv[2:]:
    name, _, url = entry.partition("=")
    servers[name] = {"type": "remote", "url": url, "enabled": True}
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
echo "OpenCode MCPs added."

# --- Crush: edit .crush/crush.json ---
python3 - "$WORKSPACE_DIR/.crush/crush.json" "${entries[@]}" <<'EOF'
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

# --- Codex: edit .codex/config.toml ---
# Uses supergateway bridge if available (Codex requires stdio, not SSE directly).
CODEX_MCP_BRIDGE_BIN="$(command -v supergateway || true)"
if [ -n "$CODEX_MCP_BRIDGE_BIN" ]; then
  python3 - "$WORKSPACE_DIR/.codex/config.toml" "$CODEX_MCP_BRIDGE_BIN" "${entries[@]}" <<'EOF'
import sys, re

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
  echo "Codex MCPs skipped (supergateway not found — install it to enable Codex MCP support)."
fi
