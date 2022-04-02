# Changelog for the TeX Live Docker images

## TeX Live 2022

### 2022-04

* `latest` images will now also be provided as
  `TL{RELEASE}-{YEAR}-{MONTH}-{DAY}` instead of
  `TL{RELEASE}-{YEAR}-{MONTH}-{DAY}-{HOUR}-{MINUTE}` because we do not build
  images twice a day except for development purposes where only the last image
  is meant to be used anyway so there is no need for tagging per minute.
  (see #8)

## TeX Live 2021

### 2022-04

* Use multi-stage build for historic images to exclude the ISO image from
  layering, thus reducing the image size a bit.
* The experimental `-with-cache` images have been removed. The font cache will
  now be generated for each `latest` image by default.
  (see #3)

### 2022-02

* Removed `wget` from the latest images and use `curl` for downloads. `wget`
  cannot deal with tug.org's Let's Encrypt certificates, so there is no need
  to keep it in the image when `curl` is already present except for the
  historic images where install-tl relies on it.

### 2022-01

* Added `gnuplot-nox` to the base image to allow for gnuplot graphics in
  `pgfplots` plots.
  (see !13)

### 2021-12

* Added `libunicode-linebreak-perl libfile-homedir-perl libyaml-tiny-perl`
  packages to the base image to solve latexindent errors.
  (see #13)
* Added `ghostscript` package to allow including eps files.
  (see #14)
* Added `curl` package to allow CTAN uploads using `l3build`.

## TeX Live 2020 and before

There has been no CHANGELOG apart from the commit history for these images.
