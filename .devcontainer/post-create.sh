#!/bin/bash
mkdir -p ~/.ssh && ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' 2>/dev/null || true
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
