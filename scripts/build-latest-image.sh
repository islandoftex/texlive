#!/usr/bin/env bash

set -e -o xtrace

# Load command-line arguments
if [[ $# != 8 ]]; then
  printf 'Usage: %s RELEASE_IMAGE DOCKER_HUB_IMAGE DOCFILES SRCFILES SCHEME TLMIRRORURL PUSH_TO_GITLAB PUSH_TO_DOCKER_HUB\n' "$0" >&2
  exit 1
fi

RELEASE_IMAGE="$1"
DOCKER_HUB_IMAGE="$2"
DOCFILES="$3"
SRCFILES="$4"
SCHEME="$5"
TLMIRRORURL="$6"
PUSH_TO_GITLAB="$7"
PUSH_TO_DOCKER_HUB="$8"

# Construct temporary image tag which will be used to identify the image
# locally. As we extract the TL release's year from the image, we cannot
# construct the final tags yet.
SUFFIX="$(if [[ "$DOCFILES" = "yes" ]]; then echo "-doc"; fi)"
SUFFIX="$SUFFIX$(if [[ "$SRCFILES" = "yes" ]]; then echo "-src"; fi)"
LATESTTAG="latest-$SCHEME$SUFFIX"

# Build and temporarily tag image
# shellcheck disable=SC2068
docker build -f Dockerfile --tag "$LATESTTAG" \
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
TAGS=("${GL_PUSH_TAGS[@]}" "${GH_PUSH_TAGS[@]}")

echo "Tagging $LATESTTAG as ${TAGS[*]}"
for TAG in "${TAGS[@]}"; do
  docker tag "$LATESTTAG" "$TAG"
done

# Push image to remotes.
if [[ -n "$PUSH_TO_GITLAB" ]]; then
  echo "Initiating push to GitLab"
  for TAG in "${GL_PUSH_TAGS[@]}"; do
    docker push "$TAG"
  done
fi

if [[ -n "$PUSH_TO_DOCKER_HUB" ]]; then
  echo "Initiating push to DockerHub"
  for TAG in "${GH_PUSH_TAGS[@]}"; do
    docker push "$TAG"
  done
fi

# Update CI badge
curl "https://img.shields.io/badge/latest-TL$CURRENTRELEASE--${IMAGEDATE//-/--}-blue" -o latest.svg

# Untag build images, so that the runner can prune them
docker rmi --no-prune "$LATESTTAG" "${TAGS[@]}" || true
