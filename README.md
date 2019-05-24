# TeX Live docker image

This repository provides dockerfiles for TeX Live repositories (full
installation with all packages but without documentation). It also
provides the necessary tooling to execute common helper tools (e.g.
Java for Arara, Perl for Biber and Xindy, Python for Pygments).

Please note that we only provide selected historical releases and one
image corresponding to the latest release of TeX Live (tagged latest).

To use one of these images in your projects, simply lookup the name of
the image and use

    FROM registry.gitlab.com/islandoftex/images/texlive:latest

or any other tag.
