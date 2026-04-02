#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_URLS_FILE="$WORKSPACE_DIR/configs/mcp-urls.conf"

# Collect names to remove
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

# --- Claude: use CLI ---
if command -v claude >/dev/null 2>&1; then
  for name in "${names[@]}"; do
    claude mcp remove -s user "$name" 2>/dev/null || true
  done
  echo "Claude MCPs removed via CLI."
fi

# --- OpenCode: edit project-level .opencode/opencode.json ---
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

# --- Copilot: edit project-level .mcp.json ---
python3 - "$WORKSPACE_DIR/.mcp.json" "${names[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
names = set(sys.argv[2:])
with open(path) as f:
    config = json.load(f)
for name in names:
    config.get("mcpServers", {}).pop(name, None)
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
echo "Copilot MCPs removed."

# --- Gemini: edit project-level .gemini/settings.json ---
python3 - "$WORKSPACE_DIR/.gemini/settings.json" "${names[@]}" <<'EOF'
import json, sys
path = sys.argv[1]
names = set(sys.argv[2:])
with open(path) as f:
    config = json.load(f)
for name in names:
    config.get("mcpServers", {}).pop(name, None)
with open(path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
EOF
echo "Gemini MCPs removed."

# --- Crush: edit project-level .crush.json ---
python3 - "$WORKSPACE_DIR/.crush.json" "${names[@]}" <<'EOF'
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

# --- Codex: edit project-level .codex/config.toml ---
python3 - "$WORKSPACE_DIR/.codex/config.toml" "${names[@]}" <<'EOF'
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
