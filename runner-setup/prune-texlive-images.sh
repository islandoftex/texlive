#!/bin/bash

docker images | grep texlive | awk 'BEGIN {OFS=""} /./ {print $3}' | xargs --no-run-if-empty docker rmi
docker system prune --force

# also clean dangling volumes
[ -z "$(docker volume ls -qf dangling=true)" ] || docker volume rm "$(docker volume ls -qf dangling=true)"
