#!/bin/bash

# kill containers older than 3 days
docker ps -f status=running --format "{{.ID}} {{.CreatedAt}} {{.Image}}" | grep buildx | while read -r id cdate ctime _; do if [[ $(date +%s -d "$cdate $ctime") -lt $(date +%s -d '3 days ago') ]]; then docker kill "$id"; fi; done

docker images | grep texlive | awk 'BEGIN {OFS=""} /./ {print $3}' | xargs --no-run-if-empty docker rmi
docker system prune --force

# also clean dangling volumes
for v in $(docker volume ls -qf 'dangling=true'); do docker volume rm "$v"; done
