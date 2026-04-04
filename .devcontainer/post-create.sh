#!/bin/bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="${WORKSPACE_DIR:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"

cd "$WORKSPACE_DIR"

bash "$WORKSPACE_DIR/scripts/setup-env.sh"
bash "$WORKSPACE_DIR/scripts/install-mcps.sh" || true
