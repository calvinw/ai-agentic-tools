# AI Agentic Tools for Students

Welcome! This container gives you access to powerful AI coding assistants. Pick the one that fits your workflow, or switch between them as you work.

---

## Quick Start

Your container comes pre-loaded with:
- **[Claude Code](https://code.claude.com/docs/en/overview)** — AI agentic coding tool from Anthropic
- **[OpenCode](https://github.com/opencode-ai/opencode)** — Open source code-focused AI tool  
- **[Copilot](https://github.com/features/copilot)** — GitHub's AI pair programmer
- **[Crush](https://github.com/charmbracelet/crush)** — A beautifully themed assistant for command-line work
- **[Codex](https://github.com/openai/codex)** — OpenAI's agentic tool

Pick one and start typing commands. You can even use different ones.

---

## The Agents and Best Subscriptions

### Claude Code

- Claude Pro or Max subscription

### OpenCode

- Github Copilot subscription
- OpenAI Pro subscription
- OpenRouter API Key (but this is pay per API call)

### Copilot

- Github Copilot subscription

### Crush

- Github Copilot subscription

### Codex

- OpenAI Pro subscription

---

## Sign up for GitHub Education

If you're a student, the single best thing you can do before anything else is sign up for [GitHub Education](https://education.github.com/students). It's free and gives you access to the [GitHub Student Developer Pack](https://education.github.com/pack), which includes a free GitHub Copilot subscription.

**Why this matters for this container:**

- You get **300 free Copilot premium requests per month** — enough to do serious work without paying anything
- Copilot powers not just the Copilot agent, but also **OpenCode** and **Crush**, which both support GitHub Copilot as a backend
- In a **GitHub Codespace**, you're already authenticated as your GitHub account — so OpenCode and Copilot start working immediately with no login steps required. This is the smoothest zero-friction path to using AI tools

If you're working in Codespaces, start here. Sign up for GitHub Education, then come back and everything will just work.

---

## Starting the Agents with Elevated Permissions

Each agent has a launcher script in the `permissions/` folder that starts it with the right flags.

### Claude Code

```
% ./permissions/claude.sh
```

This runs `claude` with two settings: `IS_SANDBOX=1` tells Claude it's running in a sandboxed environment so it won't prompt you for confirmation on every file operation, and `--dangerously-skip-permissions` bypasses the normal permission checks that would otherwise ask you to approve reads, writes, and shell commands one by one. In a dev container this is safe and makes the experience much smoother — without it, Claude stops and asks before doing almost anything.

### OpenCode

```
% ./permissions/opencode.sh
```

This simply runs `opencode` with no extra flags. OpenCode reads its permissions from `.opencode/opencode.json` in the project directory, which is already configured with `read`, `write`, and `execute` all set to `allow`. So the permissions are handled by the config file rather than command-line flags — no extra arguments needed.

### Copilot

```
% ./permissions/copilot.sh
```

This runs `copilot` with the `--allow-all` flag, which tells it to allow all file and shell operations without prompting. Without this flag, Copilot would ask for approval before reading files, making edits, or running commands — `--allow-all` keeps the workflow uninterrupted.

### Crush

```
% ./permissions/crush.sh
```

This runs `crush` with the `--yolo` flag — Charmbracelet's way of saying "skip all permission prompts and just do it." It grants Crush full autonomy to read, write, and execute without stopping to ask. Same idea as the other tools, just with a more colorful flag name.

### Codex

```
% ./permissions/codex.sh
```

This runs `codex` with no extra flags. Codex handles its own permission model internally and doesn't require command-line flags to operate smoothly in a container environment.

---

## Need More Tools? (Optional)

By default, the container includes AI tools and basic utilities. But you can install the additions below if you need them.
Or you can install your own tools, we are just in a docker container that is based on node:22-slim — a slim Debian-based image with Node.js 22.

### Data Science Additions

This is the setup for doing data science with Python alongside the AI agents. Once installed, you can ask any of the agents to help you write, debug, and explain data analysis code — the libraries will all be available in the environment.

It installs the following:

- **numpy** — numerical computing and array operations
- **pandas** — data manipulation and analysis with DataFrames
- **matplotlib** — plotting and data visualization
- **seaborn** — statistical visualizations built on matplotlib
- **requests** — HTTP library for fetching data from APIs and the web
- **Jupyter** — interactive notebooks for running Python code in the browser
- **Quarto** — publishing system for creating reports, notebooks, and slides from code
- **TinyTeX** — lightweight LaTeX distribution used by Quarto to generate PDFs

```
% scripts/install-datascience.sh
```

### Dolt Database Executable

Installs Dolt, a version-controlled SQL database:

```
% scripts/install-dolt.sh
```

---

## Advanced: Technical Setup & Configuration

### Container Image

This repo builds a Docker image that includes all four AI tools. The `Dockerfile` defines what's installed. GitHub Actions automatically builds and pushes to `ghcr.io/calvinw/ai-course-devcontainer:latest` whenever the `Dockerfile` changes, with weekly rebuilds.

The base image is intentionally lean — data science tools are optional.

### MCPs (Model Context Protocol servers)

MCP servers extend AI tools with access to external data and services. Shared MCP endpoints are listed in `configs/mcp-urls.conf` — one `name=url` entry per line.

#### Installing MCPs

```
% scripts/install-mcps.sh
```

Reads every `name=url` entry in `configs/mcp-urls.conf` and registers each MCP server in all configured AI tools — Claude Code, OpenCode, Copilot, Crush, and Codex. It delegates to a per-tool install script for each agent, so each tool gets the MCP added in its own config format. Safe to re-run at any time.

#### Uninstalling MCPs

```
% scripts/uninstall-mcps.sh
```

Removes all MCP registrations that were added by `install-mcps.sh`. It runs the corresponding per-tool teardown script for each agent, cleanly removing the MCP entries from every tool's config. Also safe to re-run.

#### Adding a new MCP

1. Append `name=url` to `configs/mcp-urls.conf`:
   ```
   dolt=https://bus-mgmt-databases.mcp.mathplosion.com/mcp-dolt-database/sse
   ```
2. Run `% scripts/install-mcps.sh`.

All tools pick up the new server automatically.

### Skills (Custom slash commands)

Skills are shared slash commands (`/skill-name`) available across Claude Code, Copilot, OpenCode, Codex, and more. They live in `.skillshare/skills/` and are synced via the [skillshare CLI](https://github.com/runkids/skillshare).

#### Setup

```
% scripts/setup-skills.sh
```

Run this once. It creates the `.skillshare/` directory structure, installs the skillshare CLI, and drops in a sample `hello-world` skill so you have something to test with.

#### Syncing Skills

```
% scripts/sync-skills.sh
```

Pushes all skills defined in `.skillshare/skills/` out to every AI tool listed in `.skillshare/config.yaml`. Run this whenever you add or change a skill.

#### Unsyncing Skills

```
% scripts/unsync-skills.sh
```

Removes all synced skills from the AI tools but leaves the `.skillshare/` directory intact. Run this to clean up, then re-run `sync-skills.sh` to redeploy.

#### Adding a skill

1. Create `.skillshare/skills/<skill-name>/SKILL.md` — see `.skillshare/skills/hello-world/SKILL.md` for format.
2. Run `% scripts/sync-skills.sh`.

The skill is now available as `/<skill-name>` everywhere.

#### Configure targets

Edit `.skillshare/config.yaml` to choose which tools receive skills:

```yaml
targets:
  - claude
  - copilot
  - opencode
  - crush
  - codex
```

### Running the Container

#### VSCode Dev Container (Recommended)

**Prerequisites:** Docker Desktop, VSCode with [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.

```
% docker pull ghcr.io/calvinw/ai-course-devcontainer:latest
```

In VSCode: `Cmd+Shift+P` → **Dev Containers: Reopen in Container**

#### Local testing (after Dockerfile changes)

```
% make build-test   # build locally as ai-container-test
% make run-test     # start with local repo mounted
% make setup        # run post-create.sh
% make shell        # open shell
% make stop         # stop container
```

#### Plain Docker

```
% make up      # pull image, start, setup, open shell
% make shell   # re-attach to running container
% make stop    # stop container
```
