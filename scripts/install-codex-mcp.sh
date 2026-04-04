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

CODEX_MCP_BRIDGE_BIN="$(command -v supergateway || true)"
if [ -n "$CODEX_MCP_BRIDGE_BIN" ]; then
  python3 - "$WORKSPACE_DIR/.codex/config.toml" "$CODEX_MCP_BRIDGE_BIN" "${#MCP_NAMES[@]}" \
    "${MCP_NAMES[@]}" "${MCP_URLS[@]}" "${MCP_TRANSPORTS[@]}" "${MCP_HEADERS[@]}" <<'EOF'
import sys
path = sys.argv[1]
bridge = sys.argv[2]
count = int(sys.argv[3])
names       = sys.argv[4:4+count]
urls        = sys.argv[4+count:4+2*count]
transports  = sys.argv[4+2*count:4+3*count]
headers_raw = sys.argv[4+3*count:4+4*count]
with open(path) as f:
    content = f.read()
for i in range(count):
    name = names[i]
    section = f'[mcp_servers.{name}]'
    if section not in content:
        if transports[i] == 'sse':
            args = ["--sse", urls[i], "--logLevel", "none"]
        else:
            args = ["--streamableHttp", urls[i]]
            if headers_raw[i]:
                for h in headers_raw[i].split('|'):
                    k, _, v = h.partition(':')
                    args += ["--header", f"{k}: {v}"]
            args += ["--logLevel", "none"]
        args_str = '[' + ', '.join(f'"{a}"' for a in args) + ']'
        content = content.rstrip("\n") + f'\n\n{section}\ncommand = "{bridge}"\nargs = {args_str}\n'
with open(path, "w") as f:
    f.write(content)
EOF
  echo "Codex MCPs added."
else
  echo "Codex MCPs skipped (supergateway not found)."
fi
