#!/usr/bin/env bash

set -e -o xtrace

# Load command-line arguments
if [[ $# != 9 ]]; then
  printf 'Usage: %s RELEASE_IMAGE DOCKER_HUB_IMAGE DOCFILES SRCFILES SCHEME CURRENTRELEASE TLMIRRORURL PUSH_TO_GITLAB PUSH_TO_DOCKER_HUB\n' "$0" >&2
  exit 1
fi

RELEASE_IMAGE="$1"
DOCKER_HUB_IMAGE="$2"
DOCFILES="$3"
SRCFILES="$4"
SCHEME="$5"
CURRENTRELEASE="$6"
TLMIRRORURL="$7"
PUSH_TO_GITLAB="$8"
PUSH_TO_DOCKER_HUB="$9"

# Construct image tags
SUFFIX="$(if [[ "$DOCFILES" = "yes" ]]; then echo "-doc"; fi)"
SUFFIX="$SUFFIX$(if [[ "$SRCFILES" = "yes" ]]; then echo "-src"; fi)"
IMAGEDATE="$(date +%Y-%m-%d)"
IMAGETAG="TL$CURRENTRELEASE-$IMAGEDATE-$SCHEME$SUFFIX"
GL_PUSH_TAGS=("$RELEASE_IMAGE:$IMAGETAG" "$RELEASE_IMAGE:latest-$SCHEME$SUFFIX")
GH_PUSH_TAGS=("$DOCKER_HUB_IMAGE:latest-$SCHEME$SUFFIX")
if [[ "$SCHEME" = "full" ]]; then
  GL_PUSH_TAGS+=("$RELEASE_IMAGE:latest$SUFFIX")
  GH_PUSH_TAGS+=("$DOCKER_HUB_IMAGE:latest$SUFFIX")
fi
TAGS=("${GL_PUSH_TAGS[@]}" "${GH_PUSH_TAGS[@]}")

# Build and tag image
# shellcheck disable=SC2068
docker build -f Dockerfile ${TAGS[@]/#/--tag } \
  --build-arg DOCFILES="$DOCFILES" \
  --build-arg SRCFILES="$SRCFILES" \
  --build-arg SCHEME="$SCHEME" \
  --build-arg TLMIRRORURL="$TLMIRRORURL" .

# Push image
if [[ -n "$PUSH_TO_GITLAB" ]]; then
  for TAG in "${GL_PUSH_TAGS[@]}"; do
    docker push "$TAG"
  done
fi

if [[ -n "$PUSH_TO_DOCKER_HUB" ]]; then
  for TAG in "${GH_PUSH_TAGS[@]}"; do
    docker push "$TAG"
  done
fi

# Update CI badge
curl "https://img.shields.io/badge/latest-TL$CURRENTRELEASE--${IMAGEDATE//-/--}-blue" -o latest.svg

# Untag build images, so that the runner can prune them
docker rmi --no-prune "${TAGS[@]}" || true
