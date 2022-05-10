#!/usr/bin/env bash

set -e

# See https://tug.org/historic/ for a list of mirrors.
SECURE_MIRRORS=(
  https://ftp.math.utah.edu/pub/tex/historic/
  https://ftp.tu-chemnitz.de/pub/tug/historic/
  https://pi.kwarc.info/historic/
  https://mirrors.tuna.tsinghua.edu.cn/tex-historic-archive/
  https://mirror.nju.edu.cn/tex-historic/
)

# Installers for TeX Live 2016 and earlier cannot use HTTPS.
INSECURE_MIRRORS=(
  ftp://ftp.math.utah.edu/pub/tex/historic/
  ftp://ftp.tu-chemnitz.de/pub/tug/historic/
)

if (( $# != 1 ))
then
  printf 'Usage: %s YEAR\n' "$0"
  exit 1
fi

YEAR="$1"

if (( YEAR > 2016 ))
then
  MIRRORS=( "${SECURE_MIRRORS[@]}" )
else
  MIRRORS=( "${INSECURE_MIRRORS[@]}" )
fi

MIRROR_INDEX=$((YEAR % ${#SECURE_MIRRORS[@]}))
MIRROR="${MIRRORS[$MIRROR_INDEX]}"

echo "$MIRROR"
