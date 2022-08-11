#!/usr/bin/env bash

set -e -o xtrace

# Load command-line arguments
if [[ $# != 2 ]]
then
  printf 'Usage: %s RELEASE_IMAGE PUSH_TO_GITLAB\n' "$0" >&2
  exit 1
fi

RELEASE_IMAGE="$1"
PUSH_TO_GITLAB="$2"

# Construct image tag
GL_PUSH_TAG="$RELEASE_IMAGE:base"

# Build and tag image
docker build -f Dockerfile.base --tag "$GL_PUSH_TAG" .

# Push image
if [[ ! -z "$PUSH_TO_GITLAB" ]]
then
  docker push "$GL_PUSH_TAG"
fi

# Untag build images, so that the runner can prune them
docker rmi --no-prune "$TAG" || true
