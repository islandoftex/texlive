#!/usr/bin/env bash

set -e -o xtrace

# Load command-line arguments
if [[ $# != 8 ]]; then
  printf 'Usage: %s RELEASE_IMAGE DOCKER_HUB_IMAGE DOCFILES SRCFILES SCHEME TLMIRRORURL PUSH_TO_GITLAB PUSH_TO_DOCKER_HUB [PRETEST]\n' "$0" >&2
  exit 1
fi

BUILDX_DRIVER="$(docker buildx inspect | sed -n 's/^Driver:\s*\(.*\)$/\1/p')"
if [[ "$BUILDX_DRIVER" != "docker-container" ]]; then
  echo "This runner does not seem set up for buildx building. Trying to rectify by creating buildx environment." >&2
  docker buildx create --use
fi
BUILDX_PLATFORMS="linux/arm64/v8,linux/amd64"

RELEASE_IMAGE="$1"
DOCKER_HUB_IMAGE="$2"
DOCFILES="$3"
SRCFILES="$4"
SCHEME="$5"
TLMIRRORURL="$6"
PUSH_TO_GITLAB="$7"
PUSH_TO_DOCKER_HUB="$8"
PRETEST="$9"

# Construct temporary image tag which will be used to identify the image
# locally. As we extract the TL release's year from the image, we cannot
# construct the final tags yet.
SUFFIX="$(if [[ "$DOCFILES" = "yes" ]]; then echo "-doc"; fi)"
SUFFIX="$SUFFIX$(if [[ "$SRCFILES" = "yes" ]]; then echo "-src"; fi)"
LATESTTAG="$(if [[ -z "$PRETEST" ]]; then echo "latest"; else echo "pretest"; fi)-$SCHEME$SUFFIX"

# Build and temporarily tag image for all platforms, caching the build for all
# of them locally. Ideally, would directly load the images but that does not
# work because of still unresolved https://github.com/docker/buildx/issues/59
# shellcheck disable=SC2068
docker buildx build \
  --platform "$BUILDX_PLATFORMS" \
  --cache-from type=local,src=./cache-dir \
  --cache-to type=local,dest=./cache-dir,mode=max \
  -f Dockerfile --tag "$LATESTTAG" \
  --build-arg DOCFILES="$DOCFILES" \
  --build-arg SRCFILES="$SRCFILES" \
  --build-arg SCHEME="$SCHEME" \
  --build-arg TLMIRRORURL="$TLMIRRORURL" .
# Load the image for the host platform into the local docker cache to be able
# to run it later on (--load). Does not build anything, just reuses the cache
# created earlier.
docker buildx build --load \
  --cache-from type=local,src=./cache-dir \
  -f Dockerfile --tag "$LATESTTAG" \
  --build-arg DOCFILES="$DOCFILES" \
  --build-arg SRCFILES="$SRCFILES" \
  --build-arg SCHEME="$SCHEME" \
  --build-arg TLMIRRORURL="$TLMIRRORURL" .

# Extract the current year from the container by checking which TL year folder
# can be found in `/usr/local/texlive`.
docker run "$LATESTTAG" \
  find /usr/local/texlive/ -mindepth 1 -maxdepth 1 -type d -regex ".*/[0-9]*" -printf "%f\n" >find_output
CURRENTRELEASE=$(head -c 4 <find_output)

if ! [[ $CURRENTRELEASE =~ ^[0-9]+$ ]]; then
  echo "TeX Live release must only contain digits 0-9, invalid output $(cat find_output)." >&2
  exit 1
fi
if [ "${#CURRENTRELEASE}" -ne 4 ]; then
  echo "Years have to be represented by 4 digits, invalid output $(cat find_output)." >&2
  exit 1
fi

# Compose tags which will be pushed to the remote hosts. Then tag the image
# identified by the temporary tag with the appropriate remote tags.
IMAGEDATE="$(date +%Y-%m-%d)"
IMAGETAG="TL$CURRENTRELEASE-$IMAGEDATE-$SCHEME$SUFFIX"
GL_PUSH_TAGS=("$RELEASE_IMAGE:$IMAGETAG" "$RELEASE_IMAGE:$LATESTTAG")
GH_PUSH_TAGS=("$DOCKER_HUB_IMAGE:$LATESTTAG")
if [[ "$SCHEME" = "full" ]]; then
  GL_PUSH_TAGS+=("$RELEASE_IMAGE:latest$SUFFIX")
  GH_PUSH_TAGS+=("$DOCKER_HUB_IMAGE:latest$SUFFIX")
fi
if [[ -z "$PUSH_TO_GITLAB" ]]; then
  GL_PUSH_TAGS=()
fi
if [[ -z "$PUSH_TO_DOCKER_HUB" ]]; then
  GH_PUSH_TAGS=()
fi
TAGS=("${GL_PUSH_TAGS[@]}" "${GH_PUSH_TAGS[@]}")

echo "Tagging $LATESTTAG as ${TAGS[*]}"
# Push the images for all platforms to the registries (--push). Does not build
# anything, just reuses the cache created earlier.
if [ "${#TAGS[@]}" -gt 0 ]; then
  TAGSTR="${TAGS[*]}"
  TAGSTR="--tag ${TAGSTR// / --tag }"
  # shellcheck disable=SC2086 # quotes are intentionally missing because the
  # tag flags are supposed to be split by whitespace
  docker buildx build --push --provenance false \
    --platform "$BUILDX_PLATFORMS" \
    --cache-from type=local,src=./cache-dir \
    -f Dockerfile $TAGSTR \
    --build-arg DOCFILES="$DOCFILES" \
    --build-arg SRCFILES="$SRCFILES" \
    --build-arg SCHEME="$SCHEME" \
    --build-arg TLMIRRORURL="$TLMIRRORURL" .
fi

# Update CI badge
curl "https://img.shields.io/badge/latest-TL$CURRENTRELEASE--${IMAGEDATE//-/--}-blue" -o latest.svg

# Stop and remove builders to avoid long-running containers blocking the
# cleanup.
docker buildx stop
docker buildx rm --all-inactive --force

# Untag build images, so that the runner can prune them
docker rmi --no-prune "$LATESTTAG" "${TAGS[@]}" || true
