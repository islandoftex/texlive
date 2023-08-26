#!/usr/bin/env bash

set -e -o xtrace

# Load command-line arguments
if [[ $# != 2 ]]; then
  printf 'Usage: %s RELEASE_IMAGE PUSH_TO_GITLAB\n' "$0" >&2
  exit 1
fi

buildx_driver="$(docker buildx inspect | sed -n 's/^Driver:\s*\(.*\)$/\1/p')"
if [[ "$buildx_driver" != "docker-container" ]]; then
  echo "This runner does not seem set up for buildx building. Trying to rectify by creating buildx environment." >&2
  docker buildx create --use
fi

RELEASE_IMAGE="$1"
PUSH_TO_GITLAB="$2"

# Construct image tag
GL_PUSH_TAG="$RELEASE_IMAGE:base"

if [[ -n "$PUSH_TO_GITLAB" ]]; then
  PUSH_FLAG="--push"
fi

# Build, tag, and push image
docker buildx build \
  --platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
  -f Dockerfile.base --tag "$GL_PUSH_TAG" \
  "$PUSH_FLAG" .

# Untag build images, so that the runner can prune them
docker rmi --no-prune "$GL_PUSH_TAG" || true
