#!/usr/bin/env bash

set -e

# The lists of historic TeX mirrors below have last been updated on
# 2022-05-10 from <https://tug.org/historic/>.
SECURE_MIRRORS=(
  https://ftp.math.utah.edu/pub/tex/historic/
  https://ftp.tu-chemnitz.de/pub/tug/historic/
  https://pi.kwarc.info/historic/
  https://mirrors.tuna.tsinghua.edu.cn/tex-historic-archive/
  https://mirror.nju.edu.cn/tex-historic/
)
INSECURE_MIRRORS=(  # Installers for TL <= 2016 cannot use HTTPS.
  ftp://ftp.math.utah.edu/pub/tex/historic/
  ftp://ftp.tu-chemnitz.de/pub/tug/historic/
)

if (( $# != 1 ))
then
  printf 'Usage: %s YEAR\n' "$0" >&2
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
