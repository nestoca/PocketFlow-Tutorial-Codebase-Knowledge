# Makefile for PocketFlow Tutorial Codebase Knowledge

# Variables - can be overridden from command line
IMAGE_NAME ?= documentation-generator
IMAGE_TAG ?= latest
REGISTRY ?= docker.io
REGISTRY_USER ?= your-username
FULL_IMAGE_NAME = $(REGISTRY)/$(REGISTRY_USER)/$(IMAGE_NAME):$(IMAGE_TAG)

# Docker build arguments
DOCKER_BUILD_ARGS ?= --no-cache

# Default paths for local development
CONFIG_FILE ?= configs/example_config.yaml
OUTPUT_DIR ?= ./output
MOUNT_DIR ?= ./mount

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help build push run run-local clean validate lint test all

# Default target
all: build

## Help - Display available targets
help:
	@echo "$(GREEN)PocketFlow Tutorial Docker Management$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@echo "  $(GREEN)build$(NC)      - Build the Docker image"
	@echo "  $(GREEN)push$(NC)       - Push the Docker image to registry"
	@echo "  $(GREEN)run$(NC)        - Run the Docker container with file input"
	@echo "  $(GREEN)run-local$(NC)  - Run container with local directory mounting"
	@echo "  $(GREEN)validate$(NC)   - Validate configuration file without running"
	@echo "  $(GREEN)clean$(NC)      - Clean up Docker images and containers"
	@echo "  $(GREEN)lint$(NC)       - Run linting and code quality checks"
	@echo "  $(GREEN)test$(NC)       - Run tests"
	@echo "  $(GREEN)shell$(NC)      - Open an interactive shell in the container"
	@echo "  $(GREEN)logs$(NC)       - Show logs from the last container run"
	@echo "  $(GREEN)help$(NC)       - Show this help message"
	@echo ""
	@echo "$(YELLOW)Configuration:$(NC)"
	@echo "  IMAGE_NAME=$(IMAGE_NAME)"
	@echo "  IMAGE_TAG=$(IMAGE_TAG)"
	@echo "  REGISTRY=$(REGISTRY)"
	@echo "  REGISTRY_USER=$(REGISTRY_USER)"
	@echo "  FULL_IMAGE_NAME=$(FULL_IMAGE_NAME)"
	@echo ""
	@echo "$(YELLOW)Usage examples:$(NC)"
	@echo "  make build"
	@echo "  make push REGISTRY_USER=myusername"
	@echo "  make run CONFIG_FILE=configs/my_config.yaml"
	@echo "  make run-local CONFIG_FILE=configs/my_config.yaml MOUNT_DIR=/path/to/source"

## Build - Build the Docker image
build:
	@echo "$(GREEN)Building Docker image: $(FULL_IMAGE_NAME)$(NC)"
	docker build $(DOCKER_BUILD_ARGS) -t $(IMAGE_NAME):$(IMAGE_TAG) -t $(FULL_IMAGE_NAME) .
	@echo "$(GREEN)✅ Build completed successfully!$(NC)"

## Push - Push the Docker image to registry
push: build
	@echo "$(GREEN)Pushing Docker image: $(FULL_IMAGE_NAME)$(NC)"
	docker push $(FULL_IMAGE_NAME)
	@echo "$(GREEN)✅ Push completed successfully!$(NC)"

## Run - Run the Docker container with file input support
run: build
	@echo "$(GREEN)Running Docker container with config: $(CONFIG_FILE)$(NC)"
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "$(RED)❌ Configuration file not found: $(CONFIG_FILE)$(NC)"; \
		echo "$(YELLOW)Please specify a valid config file with: make run CONFIG_FILE=path/to/config.yaml$(NC)"; \
		exit 1; \
	fi
	@mkdir -p $(OUTPUT_DIR)
	docker run --rm \
		-v "$(PWD)/$(CONFIG_FILE):/app/config.yaml:ro" \
		-v "$(PWD)/$(OUTPUT_DIR):/app/output" \
		-v "$(PWD)/.env:/app/.env:ro" \
		--name $(IMAGE_NAME)-run \
		$(FULL_IMAGE_NAME) config.yaml
	@echo "$(GREEN)✅ Container run completed! Check output in: $(OUTPUT_DIR)$(NC)"

## Run with local directory mounting
run-local: build
	@echo "$(GREEN)Running Docker container with local directory mounting$(NC)"
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "$(RED)❌ Configuration file not found: $(CONFIG_FILE)$(NC)"; \
		exit 1; \
	fi
	@mkdir -p $(OUTPUT_DIR)
	@if [ -d "$(MOUNT_DIR)" ]; then \
		echo "$(YELLOW)Mounting local directory: $(MOUNT_DIR)$(NC)"; \
		docker run --rm \
			-v "$(PWD)/$(CONFIG_FILE):/app/config.yaml:ro" \
			-v "$(PWD)/$(OUTPUT_DIR):/app/output" \
			-v "$(PWD)/$(MOUNT_DIR):/app/mount:ro" \
			-v "$(PWD)/.env:/app/.env:ro" \
			--name $(IMAGE_NAME)-run \
			$(FULL_IMAGE_NAME) config.yaml; \
	else \
		echo "$(YELLOW)Mount directory not found, running without local mount$(NC)"; \
		$(MAKE) run CONFIG_FILE=$(CONFIG_FILE); \
	fi

## Validate - Validate configuration file without running analysis
validate: build
	@echo "$(GREEN)Validating configuration: $(CONFIG_FILE)$(NC)"
	@if [ ! -f "$(CONFIG_FILE)" ]; then \
		echo "$(RED)❌ Configuration file not found: $(CONFIG_FILE)$(NC)"; \
		exit 1; \
	fi
	docker run --rm \
		-v "$(PWD)/$(CONFIG_FILE):/app/config.yaml:ro" \
		--name $(IMAGE_NAME)-validate \
		$(FULL_IMAGE_NAME) config.yaml --validate-only
	@echo "$(GREEN)✅ Configuration validation completed!$(NC)"

## Shell - Open an interactive shell in the container
shell: build
	@echo "$(GREEN)Opening interactive shell in container$(NC)"
	docker run --rm -it \
		-v "$(PWD):/app/workspace:ro" \
		-v "$(PWD)/$(OUTPUT_DIR):/app/output" \
		--name $(IMAGE_NAME)-shell \
		--entrypoint /bin/bash \
		$(FULL_IMAGE_NAME)

## Logs - Show logs from the last container run
logs:
	@echo "$(GREEN)Showing logs from last container run$(NC)"
	docker logs $(IMAGE_NAME)-run 2>/dev/null || echo "$(YELLOW)No logs found for $(IMAGE_NAME)-run$(NC)"

## Clean - Clean up Docker images and containers
clean:
	@echo "$(GREEN)Cleaning up Docker resources$(NC)"
	@docker rm -f $(IMAGE_NAME)-run 2>/dev/null || true
	@docker rm -f $(IMAGE_NAME)-validate 2>/dev/null || true
	@docker rm -f $(IMAGE_NAME)-shell 2>/dev/null || true
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@docker rmi $(FULL_IMAGE_NAME) 2>/dev/null || true
	@docker system prune -f
	@echo "$(GREEN)✅ Cleanup completed!$(NC)"

## Lint - Run linting and code quality checks
lint:
	@echo "$(GREEN)Running linting checks$(NC)"
	@if command -v python3 >/dev/null 2>&1; then \
		python3 -m py_compile main.py flow.py nodes.py utils/*.py; \
		echo "$(GREEN)✅ Python syntax check passed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Python3 not found, skipping syntax check$(NC)"; \
	fi
	@if command -v yamllint >/dev/null 2>&1; then \
		find configs -name "*.yaml" -o -name "*.yml" | xargs yamllint; \
		echo "$(GREEN)✅ YAML lint check passed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  yamllint not found, skipping YAML check$(NC)"; \
	fi

## Test - Run tests
test: build
	@echo "$(GREEN)Running tests$(NC)"
	docker run --rm \
		-v "$(PWD)/configs/example_config.yaml:/app/config.yaml:ro" \
		--name $(IMAGE_NAME)-test \
		$(FULL_IMAGE_NAME) config.yaml --validate-only
	@echo "$(GREEN)✅ Tests completed!$(NC)"

## Quick start for development
dev: build validate
	@echo "$(GREEN)Development environment ready!$(NC)"
	@echo "$(YELLOW)Try: make run CONFIG_FILE=configs/example_config.yaml$(NC)"

# Advanced targets

## Build with custom args
build-dev:
	$(MAKE) build DOCKER_BUILD_ARGS="--target development"

## Run with debug mode
run-debug: build
	@echo "$(GREEN)Running in debug mode$(NC)"
	docker run --rm -it \
		-v "$(PWD)/$(CONFIG_FILE):/app/config.yaml:ro" \
		-v "$(PWD)/$(OUTPUT_DIR):/app/output" \
		-v "$(PWD)/.env:/app/.env:ro" \
		--name $(IMAGE_NAME)-debug \
		--entrypoint /bin/bash \
		$(FULL_IMAGE_NAME)

## Tag and push with version
tag-and-push:
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)❌ VERSION is required. Usage: make tag-and-push VERSION=1.0.0$(NC)"; \
		exit 1; \
	fi
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(REGISTRY)/$(REGISTRY_USER)/$(IMAGE_NAME):$(VERSION)
	docker push $(REGISTRY)/$(REGISTRY_USER)/$(IMAGE_NAME):$(VERSION)
	@echo "$(GREEN)✅ Tagged and pushed version $(VERSION)$(NC)"

# Make sure output directory exists
$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)
