#!/bin/bash
set -e

echo "=== Installing Dolt ==="
curl -L https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash

echo "=== Verifying ==="
dolt version
echo "=== Dolt installed ==="
