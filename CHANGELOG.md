# Changelog for the TeX Live Docker images

## TeX Live 2022

### 2022-08

* `latest` images are now provided for the `minimal`, `basic`, `small`, and
  `medium` schemes in addition to the `full` scheme.
  (see #11)
* Added `libsm6` to allow running metafont.
  (see #24)

### 2022-05

* `latest` images now include approx. 20 MB fontconfig cache. This allows
  XeLaTeX users to load fonts by name more easily.
  (see #18)
* The `base` image (and therefore all `latest` and `historic` images) does not
  ship with the following packages any longer: `gpg`, `tar`, `rsync`.
* `latest` images now ship with `gpg-agent`.
  (see #21)

*Notes for developers using our image pipeline:*

* The `iso` images have been dropped in favor of using the net installer for
  historic releases as well.

### 2022-04

* `latest` images will now also be provided as
  `TL{RELEASE}-{YEAR}-{MONTH}-{DAY}` instead of
  `TL{RELEASE}-{YEAR}-{MONTH}-{DAY}-{HOUR}-{MINUTE}` because we do not build
  images twice a day except for development purposes where only the last image
  is meant to be used anyway so there is no need for tagging per minute.
  (see #8)

*Notes for developers using our image pipeline:*

* The `base` image (and therefore all `latest` and `historic` images) does not
  ship with the following packages any longer: `xorriso`.
  Furthermore, the following environment variables are not provided anymore:
  `TLHISTMIRRORURL`, `TLMIRRORURL`.
* `iso` images (which are not meant for public consumption but are available in
  our docker registry) now are based on debian as a prerequisite for a later
  move to alpine for even smaller footprint. As those images are purely used in
  builder stage of a multi-stage build, the base image has become irrelevant.

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
