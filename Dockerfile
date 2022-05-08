FROM alpine:latest AS downloader

# whether to install documentation and/or source files
# this has to be yes or no
ARG DOCFILES=no
ARG SRCFILES=no

# the mirror from which we will download TeX Live
ARG TLMIRRORURL

# the current release needed to determine which way to
# verify files
ARG CURRENTRELEASE

RUN apk add --no-cache ca-certificates curl gpg gpg-agent sed tar

# use a working directory to collect downloaded artifacts
WORKDIR /texlive

# download and verify TL installer before extracting archive
RUN curl "$TLMIRRORURL/install-tl-unx.tar.gz" --output install-tl-unx.tar.gz && \
  # TeX Live before 2016 used sha256 instead of sha512
  if [ "$CURRENTRELEASE" -lt "2016" ]; then \
    curl "$TLMIRRORURL/install-tl-unx.tar.gz.sha256" --output install-tl-unx.tar.gz.sha256 && \
    sha256sum -c install-tl-unx.tar.gz.sha256; \
  else \
    curl "$TLMIRRORURL/install-tl-unx.tar.gz.sha512" --output install-tl-unx.tar.gz.sha512 && \
    curl "$TLMIRRORURL/install-tl-unx.tar.gz.sha512.asc" --output install-tl-unx.tar.gz.sha512.asc && \
    curl https://tug.org/texlive/files/texlive.asc --output texlive.asc && \
    gpg --import texlive.asc && \
    gpg --verify install-tl-unx.tar.gz.sha512.asc install-tl-unx.tar.gz.sha512 && \
    sha512sum -c install-tl-unx.tar.gz.sha512 && \
    rm texlive.asc && \
    rm -rf /root/.gnupg; \
  fi && \
  rm install-tl-unx.tar.gz.sha* && \
  tar xzf install-tl-unx.tar.gz && \
  rm install-tl-unx.tar.gz && \
  mv install-tl-* install-tl

# create installation profile for full scheme installation with
# the selected options
RUN echo "Building with documentation: $DOCFILES" && \
  echo "Building with sources: $SRCFILES" && \
  # choose complete installation
  echo "selected_scheme scheme-full" > install.profile && \
  # … but disable documentation and source files when asked to stay slim
  if [ "$DOCFILES" = "no" ]; then echo "tlpdbopt_install_docfiles 0" >> install.profile && \
    echo "BUILD: Disabling documentation files"; fi && \
  if [ "$SRCFILES" = "no" ]; then echo "tlpdbopt_install_srcfiles 0" >> install.profile && \
    echo "BUILD: Disabling source files"; fi && \
  echo "tlpdbopt_autobackup 0" >> install.profile && \
  # furthermore we want our symlinks in the system binary folder to avoid
  # fiddling around with the PATH
  echo "tlpdbopt_sys_bin /usr/bin" >> install.profile

# download equivs file for dummy package
RUN curl https://tug.org/texlive/files/debian-equivs-2022-ex.txt --output texlive-local && \
  sed -i "s/2022/9999/" texlive-local

FROM registry.gitlab.com/islandoftex/images/texlive:base

# whether to install documentation and/or source files
# this has to be yes or no
ARG DOCFILES=no
ARG SRCFILES=no

# the mirror from which we will download TeX Live
ARG TLMIRRORURL

ARG GENERATE_CACHES=yes

COPY --from=downloader /texlive/texlive-local /tmp/texlive-local

WORKDIR /tmp
RUN apt-get update && \
  # Mark all texlive packages as installed. This enables installing
  # latex-related packges in child images.
  # Inspired by https://tex.stackexchange.com/a/95373/9075.
  apt install -qy --no-install-recommends equivs freeglut3 && \
  # we need to change into tl-equis to get it working
  equivs-build texlive-local && \
  dpkg -i texlive-local_9999.99999999-1_all.deb && \
  apt install -qyf && \
  # reverse the cd command from above and cleanup
  rm -rf * && \
  # save some space
  apt remove -y --purge equivs && \
  apt-get autoremove -qy --purge && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean && \
  rm -rf /var/cache/apt/

COPY --from=downloader /texlive/install-tl /tmp/install-tl
COPY --from=downloader /texlive/install.profile /tmp/install-tl/install.profile

# actually install TeX Live
RUN cd install-tl && \
  ./install-tl -profile install.profile -repository "$TLMIRRORURL" && \
  cd .. && rm -rf install-tl* && \
  # add all relevant binaries to the PATH
  $(find /usr/local/texlive -name tlmgr) path add && \
  if [ "$GENERATE_CACHES" = "yes" ]; then \
    # pregenerate caches as per #3; overhead is < 5 MB which does not really
    # matter for images in the sizes of GBs
    luaotfload-tool -u && \
    mtxrun --generate && \
    # also generate fontconfig cache as per #18 which is approx. 20 MB but
    # benefits XeLaTeX user to load fonts from the TL tree by font name
    cp $(find /usr/local/texlive -name texlive-fontconfig.conf) /etc/fonts/conf.d/09-texlive-fonts.conf && \
    fc-cache -fsv; \
  fi

WORKDIR /
RUN \
  # test the installation
  latex --version && printf '\n' && \
  biber --version && printf '\n' && \
  xindy --version && printf '\n' && \
  arara --version && printf '\n' && \
  python --version && printf '\n' && \
  pygmentize -V && printf '\n' && \
  if [ "$DOCFILES" = "yes" ]; then texdoc -lI geometry; fi && \
  if [ "$SRCFILES" = "yes" ]; then kpsewhich latexbug.dtx; fi
