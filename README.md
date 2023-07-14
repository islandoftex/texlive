# TeX Live docker image

This repository provides dockerfiles for [TeX Live](http://tug.org/texlive/)
repositories (full installation with all packages but without documentation).
It also provides the necessary tooling to execute common helper tools (e.g.
Java for arara, Perl for Biber and Xindy, Python for Pygments).

Please note that we only provide selected historical releases and one image
corresponding to the latest release of TeX Live (tagged latest).

To use one of these images in your projects, simply lookup the name of the
image in our [registry](https://gitlab.com/islandoftex/images/texlive/container_registry)
and use

    FROM registry.gitlab.com/islandoftex/images/texlive:latest

or any other tag.

If you want to pull these images from Docker Hub, simply use

    FROM texlive/texlive:latest

or any other tag.

For some tutorials on using these images within a Docker workflow, have a look
at the posts listed on our [wiki page](https://gitlab.com/islandoftex/images/texlive/-/wikis/home).

> These images are provided by the Island of TeX. Please use the images'
> [repo](https://gitlab.com/islandoftex/images/texlive) to report issues or
> feature request. We are not active on the TeX Live mailing list.

## Flavors we provide

For every release `X` (e.g. `latest`) we are providing the following flavors:

* `X`: A "minimal" TeX Live installation without documentation and source
  files. However, all tools mentioned above will work without problems.
* `X-doc`: `X` with documentation files.
* `X-src`: `X` with source files.
* `X-doc-src`: `X` with documentation and source files.

If in doubt, choose `X` and only pull the larger images if you have to.
Especially documentation files do add a significant payload.

## The `latest` release

Our continuous integration is scheduled to rebuild all Docker images weekly.
Hence, pulling the `latest` image will provide you with an at most one week old
snapshot of TeX Live including all packages. You can manually update within the
container by running `tlmgr update --self --all`.

Each of the weekly builds is tagged with `TL{RELEASE}-{YEAR}-{MONTH}-{DAY}`
apart from being `latest` for one week. If you want to have reproducible builds
or happen to find a regression in a later image you can still revert to a date
that worked, e.g. `TL2022-2022-06-05`.

> In releases prior to TL2021, we used
> `TL{RELEASE}-{YEAR}-{MONTH}-{DAY}-{HOUR}-{MINUTE}` which should be considered
> when referring to older images by date.

`latest` images are also available for different TeX Live *schemes*. The
following schemes are built: `minimal`, `basic`, `small`, `medium`, and `full`.
For all these, you may use them with doc tree, src tree, or both, or none like
you would a regular `latest` image. Example: `latest-small-doc` will pull the
`latest` image built with the basic scheme and the doc tree (without source
tree). `latest-{,doc,src,doc-src}` is an alias for
`latest-full-{,doc,src,doc-src}` (i.e. we default to scheme `full`).

*Note for users of schemes other than `full`*: if you `tlmgr install` another
binary they are not added to the `PATH` automatically because they are not
respected by `tlmgr path add` while building the image. Use `tlmgr install
binary && tlmgr path add` to install new executables.

## Historic releases

We are maintaining images for historic releases from 2013 on. If you need an
image for an older TeX Live feel free to file a feature request. We might
consider adding older distributions if there is a user base.

Historic releases are tagged as `TL{YEAR}-historic`, so you could pull for 2018
`TL2018-historic`, `TL2018-historic-doc`, `TL2018-historic-src` or
`TL2018-historic-doc-src`.

*Concerning the word historic*:
Be aware that we will only have one tag associated with one historic release.
That does *not* mean that the images behind that tag will not change. Quite the
opposite: Every month, the historic images will be rebuilt and updated if there
are updates for the underlying operating system image available. That way we
make sure not to ship all too outdated software.

## Licensing

The software in terms of the MIT license are the Dockerfiles and test files
provided. This does not include the pre-built Docker images we provide. They
follow the redistribution conditions of the bundled software.
