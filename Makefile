IMAGE     = ghcr.io/calvinw/ai-course-devcontainer
TAG       = latest
CONTAINER = ai-container
WORKSPACE = /workspaces/ai-container

# --- Local devcontainer workflow ---

up: pull run setup shell

pull:
	docker pull $(IMAGE):$(TAG)

run:
	docker run -d \
		--name $(CONTAINER) \
		-e CLAUDE_CODE_DISABLE_VSCODE_EXTENSION=1 \
		-e IS_SANDBOX=1 \
		-v "$(PWD)":$(WORKSPACE) \
		-w $(WORKSPACE) \
		$(IMAGE):$(TAG) \
		sleep infinity

setup:
	docker exec $(CONTAINER) bash .devcontainer/post-create.sh

shell:
	docker exec -it $(CONTAINER) bash

stop:
	docker stop $(CONTAINER) && docker rm $(CONTAINER)

# --- Local test workflow ---

build-test:
	docker build -t ai-container-test .

run-test:
	docker run -d \
		--name $(CONTAINER) \
		-e CLAUDE_CODE_DISABLE_VSCODE_EXTENSION=1 \
		-e IS_SANDBOX=1 \
		-v "$(PWD)":/workspace \
		-w /workspace \
		ai-container-test \
		sleep infinity

# --- Image build/publish workflow ---

build:
	docker build -t $(IMAGE):$(TAG) .

push:
	docker push $(IMAGE):$(TAG)

clean:
	docker rmi $(IMAGE):$(TAG)

.PHONY: up pull run setup shell stop build-test run-test build push clean
