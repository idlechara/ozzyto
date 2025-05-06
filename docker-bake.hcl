// docker-bake.hcl
// BuildKit HCL configuration for multi-architecture builds

// Variables with defaults that can be overridden
variable "IMAGE_NAME" {
  default = "ozzyto-streamer"
}

variable "IMAGE_TAG" {
  default = "latest"
}

variable "REGISTRY" {
  default = "ghcr.io"  // Default to GitHub Container Registry
}

variable "GITHUB_REPOSITORY" {
  default = ""  // Will be determined dynamically in the build process
}

// Group for all platforms
group "default" {
  targets = ["image-all"]
}

// Target for building all architectures
target "image-all" {
  inherits = ["image-base"]
  platforms = [
    "linux/amd64",
    "linux/arm/v7",
    "linux/arm64"
  ]
}

// Base target with common configuration
target "image-base" {
  context = "."
  dockerfile = "Dockerfile"
  args = {
    BUILDKIT_INLINE_CACHE = "1"
  }
  labels = {
    "org.opencontainers.image.source" = "https://github.com/${GITHUB_REPOSITORY}"
    "org.opencontainers.image.created" = "${timestamp()}"
    "org.opencontainers.image.description" = "Camera streaming service for multiple architectures"
    "org.opencontainers.image.licenses" = "MIT"
  }
  tags = ["${REGISTRY}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}"]
  output = ["type=registry"]
}

// Individual architecture targets
target "image-amd64" {
  inherits = ["image-base"]
  platforms = ["linux/amd64"]
  tags = ["${REGISTRY}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}-amd64"]
}

target "image-armv7" {
  inherits = ["image-base"]
  platforms = ["linux/arm/v7"]
  tags = ["${REGISTRY}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}-armv7"]
}

target "image-arm64" {
  inherits = ["image-base"]
  platforms = ["linux/arm64"]
  tags = ["${REGISTRY}/${GITHUB_REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}-arm64"]
}

// Local development target (doesn't push to registry)
target "dev" {
  inherits = ["image-base"]
  output = ["type=docker"]
  tags = ["${IMAGE_NAME}:dev"]
}