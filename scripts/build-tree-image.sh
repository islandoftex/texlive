#!/usr/bin/env bash

set -e -o xtrace

# Load command-line arguments
if [[ $# != 8 ]]; then
  printf 'Usage: %s RELEASE_IMAGE DOCKER_HUB_IMAGE DOCFILES SRCFILES CURRENTRELEASE TLMIRRORURL PUSH_TO_GITLAB PUSH_TO_DOCKER_HUB\n' "$0" >&2
  exit 1
fi

RELEASE_IMAGE="$1"
DOCKER_HUB_IMAGE="$2"
DOCFILES="$3"
SRCFILES="$4"
CURRENTRELEASE="$5"
TLMIRRORURL="$6"
PUSH_TO_GITLAB="$7"
PUSH_TO_DOCKER_HUB="$8"

# Construct image tags
SUFFIX="$(if [ "$DOCFILES" = "yes" ]; then echo "-doc"; fi)"
SUFFIX="$SUFFIX$(if [ "$SRCFILES" = "yes" ]; then echo "-src"; fi)"
IMAGETAG="TL$CURRENTRELEASE-historic-tree$SUFFIX"
GL_PUSH_TAG="$RELEASE_IMAGE:$IMAGETAG"
GH_PUSH_TAG="$DOCKER_HUB_IMAGE:$IMAGETAG"
TAGS=("$GL_PUSH_TAG" "$GH_PUSH_TAG")

# Build and tag image
# shellcheck disable=SC2068
docker build -f Dockerfile.tree ${TAGS[@]/#/--tag } \
  --build-arg DOCFILES="$DOCFILES" \
  --build-arg SRCFILES="$SRCFILES" \
  --build-arg TLMIRRORURL="$TLMIRRORURL" .

# Push image
if [[ -n "$PUSH_TO_GITLAB" ]]; then
  docker push "$GL_PUSH_TAG"
fi

if [[ -n "$PUSH_TO_DOCKER_HUB" ]]; then
  docker push "$GH_PUSH_TAG"
fi

# Untag build images, so that the runner can prune them
docker rmi --no-prune "${TAGS[@]}" || true
