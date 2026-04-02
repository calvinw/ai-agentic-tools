#!/bin/bash
set -e

# Resolve paths relative to this script's location, regardless of where it's called from.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
MCP_URLS_FILE="$WORKSPACE_DIR/configs/mcp-urls.conf"               # One name=url per line
WORKSPACE_CODEX_DIR="$WORKSPACE_DIR/.codex"
CODEX_CONFIG="$WORKSPACE_CODEX_DIR/config.toml"                    # Generated config written here
CODEX_MCP_BRIDGE_BIN="$(command -v supergateway || true)"

mkdir -p "$WORKSPACE_CODEX_DIR" ~/.codex

# Remove any existing symlink or file at the target paths before generating.
rm -f "$CODEX_CONFIG" ~/.codex/config.toml

# Generate .codex/config.toml from the current workspace path and mcp-urls.conf.
{
  echo 'approvals_reviewer = "user"'
  echo 'profile = "codespace"'
  echo ''
  echo '[profiles.codespace]'
  echo 'sandbox_mode = "danger-full-access"'
  echo 'ask_for_approval = "never"'
  echo ''
  echo "[projects.\"$WORKSPACE_DIR\"]"
  echo 'trust_level = "trusted"'
  echo ''
  echo '[plugins."gmail@openai-curated"]'
  echo 'enabled = true'
  echo ''
  echo '[plugins."github@openai-curated"]'
  echo 'enabled = true'
  if [ -x "$CODEX_MCP_BRIDGE_BIN" ] && [ -f "$MCP_URLS_FILE" ]; then
    while IFS='=' read -r name url; do
      [ -z "$name" ] && continue
      case "$name" in \#*) continue ;; esac
      echo ''
      echo "[mcp_servers.$name]"
      echo "command = \"$CODEX_MCP_BRIDGE_BIN\""
      echo "args = [\"--sse\", \"$url\", \"--logLevel\", \"none\"]"
    done < "$MCP_URLS_FILE"
  fi
} > "$CODEX_CONFIG"

# Symlink the generated config into the user home dir so Codex finds it
# regardless of which directory it's launched from.
ln -sf "$CODEX_CONFIG" ~/.codex/config.toml

if [ -f ~/.codex/config.toml ]; then
  echo "Codex config generated: $CODEX_CONFIG"
  if grep -q 'profile = "codespace"' ~/.codex/config.toml && \
     grep -q 'sandbox_mode = "danger-full-access"' ~/.codex/config.toml && \
     grep -q 'ask_for_approval = "never"' ~/.codex/config.toml; then
    echo "Codex default profile verified: codespace (danger-full-access, ask_for_approval=never)"
  else
    echo "WARNING: Codex config found, but the expected codespace profile defaults were not detected."
  fi
else
  echo "WARNING: ~/.codex/config.toml was not created."
fi
