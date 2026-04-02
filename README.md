This repo is for building a codespace dev container that contains Claude Code, OpenCode, Gemini CLI and Codex installed so students can access these tools in codespaces.

---

## How the image is built

The `Dockerfile` defines the container. GitHub Actions (`.github/workflows/build-image.yml`) automatically builds and pushes to `ghcr.io/calvinw/ai-course-devcontainer:latest` whenever the `Dockerfile` changes on `main`. It also rebuilds on a weekly schedule.

The base image is intentionally lean — it includes the AI tools, PDF utilities, and system dependencies. Data science tools (Python packages, Quarto, TinyTeX, Dolt) are available as optional install scripts you run after the container is up.

---

## Optional install scripts

Run these inside the container when needed:

```bash
bash scripts/install-datascience.sh   # Python packages, Quarto, TinyTeX
bash scripts/install-dolt.sh          # Dolt version-controlled database
```

---

## MCPs (Model Context Protocol servers)

MCP servers extend the AI tools with external data and actions. The shared endpoint list lives in `configs/mcp-urls.conf` — one `name=url` entry per line. Every setup script reads this file, so adding a line here registers the MCP in all tools at once.

```
# configs/mcp-urls.conf
dolt=https://bus-mgmt-databases.mcp.mathplosion.com/mcp-dolt-database/sse
```

### Install / uninstall MCPs

```bash
bash scripts/install-mcps.sh    # register all MCPs from mcp-urls.conf in every AI tool
bash scripts/uninstall-mcps.sh  # remove all those MCP registrations
```

Both scripts delegate to per-tool setup/teardown scripts (`setup-claude.sh`, `teardown-claude.sh`, etc.) and are idempotent — safe to re-run at any time.

### Adding a new MCP

1. Append a `name=url` line to `configs/mcp-urls.conf`.
2. Run `bash scripts/install-mcps.sh`.

All AI tools will pick up the new server.

---

## Skills

Skills are shared slash commands (`/skill-name`) that work across Claude Code, Copilot, Gemini CLI, OpenCode, Crush, and Codex. They are defined as Markdown files under `.skillshare/skills/` and synced to each tool by the [skillshare CLI](https://github.com/runkids/skillshare).

### Setup and sync

```bash
bash scripts/setup-skills.sh   # create .skillshare/, install the CLI, add a sample skill
bash scripts/sync-skills.sh    # push all skills in .skillshare/skills/ to every AI tool
bash scripts/unsync-skills.sh  # remove synced skills from AI tools (keeps .skillshare/)
```

Run `setup-skills.sh` once. After that, use `sync-skills.sh` whenever you add or change skills.

### Adding a new skill

1. Create a directory under `.skillshare/skills/<skill-name>/`.
2. Add a `SKILL.md` file — see `.skillshare/skills/hello-world/SKILL.md` for the format.
3. Run `bash scripts/sync-skills.sh`.

The skill is now available as `/<skill-name>` in every configured AI tool.

### `.skillshare/config.yaml`

Controls which AI tools receive the synced skills:

```yaml
targets:
  - claude
  - copilot
  - gemini
  - opencode
  - crush
  - codex
```

---

## Workflows

### 1. VSCode devcontainer (remote image)

Normal day-to-day use. VSCode pulls the pre-built image from GitHub Container Registry.

**Prerequisites:** Docker Desktop running, VSCode with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension.

```
docker pull ghcr.io/calvinw/ai-course-devcontainer:latest
```

Then in VSCode: `Cmd+Shift+P` → **Dev Containers: Reopen in Container**

> After a push that changes the `Dockerfile`, wait for the Actions build to finish before pulling.

---

### 2. Local Dockerfile testing (no VSCode)

Use this when you've changed the `Dockerfile` and want to test before pushing.

```bash
make build-test   # build image locally as ai-container-test
make run-test     # start container with local repo mounted at /workspace
make setup        # run post-create.sh inside the container
make shell        # open a shell
make stop         # stop and remove the container
```

---

### 3. Plain Docker via Makefile (remote image, no VSCode)

```bash
make up      # pull remote image, start container, run setup, open shell
make shell   # re-attach to a running container
make stop    # stop and remove the container
```
