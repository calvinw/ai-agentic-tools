FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl git vim \
    python3 python3-pip python3-venv \
    lsof procps iproute2 jq \
    pspg bat fzf miller \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install glow (markdown renderer) via Charm apt repo
RUN apt-get update && apt-get install -y gpg \
    && curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /usr/share/keyrings/charm.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" > /etc/apt/sources.list.d/charm.list \
    && apt-get update && apt-get install -y glow \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install visidata (terminal data explorer) via pip
RUN pip3 install visidata --break-system-packages

# Install delta (better git diffs)
RUN ARCH=$(uname -m) \
    && VER=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | jq -r '.tag_name') \
    && mkdir /tmp/delta \
    && curl -L "https://github.com/dandavison/delta/releases/download/${VER}/delta-${VER}-${ARCH}-unknown-linux-musl.tar.gz" \
    | tar -xz -C /tmp/delta --strip-components=1 \
    && mv /tmp/delta/delta /usr/local/bin/delta \
    && rm -rf /tmp/delta

# Install jless (interactive JSON pager)
RUN ARCH=$(uname -m) \
    && VER=$(curl -s https://api.github.com/repos/PaulJuliusMartinez/jless/releases/latest | jq -r '.tag_name') \
    && curl -fL "https://github.com/PaulJuliusMartinez/jless/releases/download/${VER}/jless-${VER}-${ARCH}-unknown-linux-musl.tar.gz" \
    -o /tmp/jless.tar.gz \
    && tar -xz -C /usr/local/bin -f /tmp/jless.tar.gz \
    && rm /tmp/jless.tar.gz

# Install upterm
COPY scripts/install_upterm.sh /tmp/install_upterm.sh
RUN chmod +x /tmp/install_upterm.sh && /tmp/install_upterm.sh

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && cp -L /root/.local/bin/claude /usr/local/bin/claude \
    && chmod 755 /usr/local/bin/claude

# Install npm-based AI tools
RUN npm i -g opencode-ai@latest \
    && npm i -g opencode-gemini-auth \
    && npm i -g @openai/codex \
    && npm i -g @google/gemini-cli \
    && npm i -g @qwen-code/qwen-code \
    && npm i -g @charmland/crush \
    && npm i -g @github/copilot \
    && npm install -g @mariozechner/pi-coding-agent \
    && npm cache clean --force \
    && rm -rf /root/.cache

# Configure opencode with gemini-auth plugin for all users
COPY config/opencode.json /etc/skel/.config/opencode/opencode.json
RUN mkdir -p /home/node/.config/opencode \
    && cp /etc/skel/.config/opencode/opencode.json /home/node/.config/opencode/opencode.json \
    && chown -R node:node /home/node/.config

# Set simple prompt for all terminals
RUN echo 'PS1="# "' >> /root/.bashrc

# Install Dolt
RUN curl -L https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash

# Verify all tools are installed
RUN echo "=== Verifying installed tools ===" \
    && upterm version \
    && claude --version \
    && opencode --version \
    && codex --version \
    && gemini --version \
    && qwen --version \
    && crush --version \
    && copilot --version \
    && pi --version \
    && dolt version \
    && echo "=== All tools verified ==="
