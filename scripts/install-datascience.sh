#!/bin/bash
set -e

echo "=== Installing Python data science packages ==="
pip3 install visidata jupyter numpy pandas matplotlib seaborn requests --break-system-packages

echo "=== Installing Quarto ==="
QUARTO_VERSION=$(curl -s https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest | jq -r '.tag_name' | sed 's/^v//')
ARCH=$(dpkg --print-architecture)
curl -LO "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${ARCH}.deb"
dpkg -i "quarto-${QUARTO_VERSION}-linux-${ARCH}.deb"
rm "quarto-${QUARTO_VERSION}-linux-${ARCH}.deb"

echo "=== Installing TinyTeX ==="
quarto install tinytex --no-prompt
ARCH=$(uname -m)
if ! grep -q "TinyTeX" ~/.bashrc; then
    echo "export PATH=\"/root/.TinyTeX/bin/${ARCH}-linux:\$PATH\"" >> ~/.bashrc
fi
export PATH="/root/.TinyTeX/bin/${ARCH}-linux:$PATH"

echo "=== Verifying ==="
quarto check
echo "=== Data science tools installed ==="
