# Changelog for the TeX Live Docker images

## TeX Live 2021

### 2022-02

* Removed `wget` from the images and use `curl` for downloads. `wget` cannot
  deal with tug.org's Let's Encrypt certificates, so there is no need to keep
  it in the image when `curl` is already present.

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
