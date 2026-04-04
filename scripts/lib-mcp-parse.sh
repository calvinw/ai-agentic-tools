#!/bin/bash
# lib-mcp-parse.sh — sourced by install/uninstall scripts
#
# Provides two functions:
#
#   parse_mcp_conf <file>
#     Populates parallel arrays for install scripts:
#       MCP_NAMES[]      — server name
#       MCP_URLS[]       — server URL
#       MCP_TRANSPORTS[] — "sse" or "http"
#       MCP_HEADERS[]    — resolved "Key:Value|Key2:Value2", or "" if none
#     Entries whose $ENV_VAR is unset are skipped with a warning.
#
#   parse_mcp_names_only <file>
#     Populates only MCP_NAMES[]. Used by uninstall scripts — does not
#     resolve env vars, so all entries are included regardless.

parse_mcp_conf() {
  local conf_file="$1"
  MCP_NAMES=()
  MCP_URLS=()
  MCP_TRANSPORTS=()
  MCP_HEADERS=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue

    local name="${line%%=*}"
    local rest="${line#*=}"

    IFS='|' read -ra fields <<< "$rest"
    local url="${fields[0]}"
    local transport="${fields[1]:-sse}"

    local header_parts=()
    local skip=0
    for (( i=2; i<${#fields[@]}; i++ )); do
      local hname="${fields[$i]%%:*}"
      local hval_raw="${fields[$i]#*:}"
      local var_name="${hval_raw#\$}"
      local hval="${!var_name}"
      if [[ -z "$hval" ]]; then
        echo "WARNING: \$$var_name is unset — skipping MCP '$name'" >&2
        skip=1
        break
      fi
      header_parts+=("${hname}:${hval}")
    done
    [[ $skip -eq 1 ]] && continue

    local headers_joined=""
    if [[ ${#header_parts[@]} -gt 0 ]]; then
      local IFS_old="$IFS"
      IFS='|'
      headers_joined="${header_parts[*]}"
      IFS="$IFS_old"
    fi

    MCP_NAMES+=("$name")
    MCP_URLS+=("$url")
    MCP_TRANSPORTS+=("$transport")
    MCP_HEADERS+=("$headers_joined")
  done < "$conf_file"
}

parse_mcp_names_only() {
  local conf_file="$1"
  MCP_NAMES=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    MCP_NAMES+=("${line%%=*}")
  done < "$conf_file"
}
