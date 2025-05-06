# Makefile for building and pushing multi-architecture Docker images using docker buildx bake

# Image configuration
IMAGE_NAME ?= ozzyto-streamer
IMAGE_TAG ?= latest
GITHUB_OWNER ?= $(shell git config --get remote.origin.url | sed 's/.*github.com[\/:]\(.*\)\/[^\/]*\.git/\1/' || echo "your-username")
GITHUB_REPOSITORY ?= $(GITHUB_OWNER)/ozzyto

.PHONY: all buildx-setup login build build-push build-amd64 build-armv7 build-arm64 build-dev clean

# Default target
all: build

# Setup buildx for multi-architecture builds
buildx-setup:
	@echo "Setting up Docker buildx..."
	docker buildx create --name multiarch-builder --use || true
	docker buildx inspect --bootstrap

# Login to GitHub Container Registry
login:
	@echo "Logging in to GitHub Container Registry..."
	@echo "Please enter your GitHub Personal Access Token with packages:write and contents:read scopes"
	@docker login ghcr.io

# Build for all architectures without pushing
build: buildx-setup
	@echo "Building Docker image for multiple architectures..."
	REGISTRY=ghcr.io IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	docker buildx bake -f docker-bake.hcl \
		--set "*.output=type=docker"

# Build and push to registry
build-push: buildx-setup login
	@echo "Building and pushing Docker image for multiple architectures to GitHub Container Registry..."
	REGISTRY=ghcr.io IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	docker buildx bake -f docker-bake.hcl \
		--push

# Build only AMD64 architecture
build-amd64: buildx-setup
	@echo "Building Docker image for AMD64 architecture..."
	REGISTRY=ghcr.io IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	docker buildx bake -f docker-bake.hcl image-amd64

# Build only ARMv7 architecture
build-armv7: buildx-setup
	@echo "Building Docker image for ARMv7 architecture..."
	REGISTRY=ghcr.io IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	docker buildx bake -f docker-bake.hcl image-armv7

# Build only ARM64 architecture
build-arm64: buildx-setup
	@echo "Building Docker image for ARM64 architecture..."
	REGISTRY=ghcr.io IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	docker buildx bake -f docker-bake.hcl image-arm64

# Build and push specific architecture (amd64, armv7, arm64)
build-push-%: buildx-setup login
	@echo "Building and pushing Docker image for $* architecture to GitHub Container Registry..."
	REGISTRY=ghcr.io IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	docker buildx bake -f docker-bake.hcl image-$* \
		--push

# Build development version (local only)
build-dev: buildx-setup
	@echo "Building development Docker image..."
	REGISTRY=ghcr.io IMAGE_NAME=$(IMAGE_NAME) IMAGE_TAG=$(IMAGE_TAG) GITHUB_REPOSITORY=$(GITHUB_REPOSITORY) \
	docker buildx bake -f docker-bake.hcl dev

# Clean up
clean:
	@echo "Cleaning up..."
	docker buildx rm multiarch-builder || true