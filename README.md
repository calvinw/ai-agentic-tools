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
