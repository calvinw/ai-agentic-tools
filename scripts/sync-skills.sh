#!/bin/bash
set -euo pipefail

# Syncs all skills defined in .skillshare/skills/ to each target AI tool
# configured in .skillshare/config.yaml. Run setup-skills.sh first if you
# haven't set up the .skillshare directory yet.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

cd "$WORKSPACE_DIR"

if [ ! -d ".skillshare" ]; then
  echo "No .skillshare directory found. Run scripts/setup-skills.sh first."
  exit 1
fi

if ! command -v skillshare >/dev/null 2>&1; then
  echo "skillshare CLI not found. Run scripts/setup-skills.sh first."
  exit 1
fi

skillshare sync
