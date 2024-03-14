#!/usr/bin/env bash

set -e

# The lists of historic TeX mirrors below have last been updated on
# 2024-03-14 from <https://tug.org/historic/>.
MIRRORS=(
  rsync://tug.org/historic/
  rsync://ftp.math.utah.edu/historic/
  rsync://texlive.info/historic/
  rsync://pi.kwarc.info/historic/
  rsync://mirrors.tuna.tsinghua.edu.cn/tex-historic-archive/
  rsync://mirror.nju.edu.cn/tex-historic/
)

if (($# != 1)); then
  printf 'Usage: %s YEAR\n' "$0" >&2
  exit 1
fi

YEAR="$1"

if [[ ! $YEAR =~ ^[0-9]{4}$ ]]; then
  printf 'Invalid year: %s. Expected four digits.\n' "$YEAR" >&2
  exit 2
fi

MIRROR_INDEX=$((YEAR % ${#MIRRORS[@]}))
MIRROR="${MIRRORS[$MIRROR_INDEX]}"

echo "$MIRROR"
