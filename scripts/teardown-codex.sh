#!/bin/bash
set -e

# Removes only the [mcp_servers.<name>] sections (from mcp-urls.conf) from
# .codex/config.toml, leaving all other settings (profiles, projects, plugins) intact.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_URLS_FILE="$WORKSPACE_DIR/configs/mcp-urls.conf"
CODEX_CONFIG="$WORKSPACE_DIR/.codex/config.toml"

if [ -f "$CODEX_CONFIG" ] && [ -f "$MCP_URLS_FILE" ]; then
  names=()
  while IFS='=' read -r name url; do
    [ -z "$name" ] && continue
    case "$name" in \#*) continue ;; esac
    names+=("$name")
  done < "$MCP_URLS_FILE"

  if [ ${#names[@]} -gt 0 ]; then
    # Use Python to remove [mcp_servers.<name>] sections from the TOML file.
    # Each section runs from its header line until the next [section] header or EOF.
    python3 - "$CODEX_CONFIG" "${names[@]}" <<'EOF'
import sys, re

path = sys.argv[1]
names = set(sys.argv[2:])

with open(path) as f:
    lines = f.readlines()

result = []
skip = False
for line in lines:
    # Check if this line starts a [mcp_servers.<name>] section we want to remove.
    m = re.match(r'^\[mcp_servers\."?([^"\]]+)"?\]', line)
    if m and m.group(1) in names:
        skip = True
        continue
    # Any new section header ends the skip.
    if skip and re.match(r'^\[', line):
        skip = False
    if not skip:
        result.append(line)

# Remove trailing blank lines left by removed sections.
while result and result[-1].strip() == "":
    result.pop()
if result:
    result.append("\n")

with open(path, "w") as f:
    f.writelines(result)
EOF
    echo "Removed MCP entries from $CODEX_CONFIG"
  fi
fi

echo "Codex MCP entries removed."
