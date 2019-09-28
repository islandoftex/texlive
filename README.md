# TeX Live docker image

This repository provides dockerfiles for [TeX Live](http://tug.org/texlive/)
repositories (full installation with all packages but without documentation).
It also provides the necessary tooling to execute common helper tools (e.g.
Java for Arara, Perl for Biber and Xindy, Python for Pygments).

Please note that we only provide selected historical releases and one image
corresponding to the latest release of TeX Live (tagged latest).

To use one of these images in your projects, simply lookup the name of the
image in our [registry](https://gitlab.com/islandoftex/images/texlive/container_registry)
and use

    FROM registry.gitlab.com/islandoftex/images/texlive:latest

or any other tag.

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

Each of the weekly builds is tagged with `TL{RELEASE}-{YEAR}-{MONTH}-{DAY}-{HOUR}-{MINUTE}`
apart from being `latest` for one week. If you want to have reproducible builds
or happen to find a regression in a later image you can still revert to a date
that worked, e.g. `TL2019-2019-08-01-08-14`.

## Historic releases

> The historic releases are currently unavailable due to shortcomings of the CI
> builds. There are some images available but it may take a while until we have
> the oportunity to complete the repository. Rebuilds are currently not
> scheduled.

We are maintaining images for historic releases from 2014 on. If you need an
image for an older TeX Live feel free to file a feature request. We might
consider adding older distributions if there is a user base.

Historic releases are tagged as `TL{YEAR}-historic`, so you could pull for 2018
`TL2018-historic`, `TL2018-historic-doc`, `TL2018-historic-src` or
`TL2018-historic-doc-src`.

*Concerning the word historic*:
Be aware that we will only have one tag associated with one historic release.
That does *not* mean that the images behind that tag will not change. Quite the
opposite: Every time we rebuild our main image (`latest`) the historic images
will be rebuilt and updated if there are updates for the underlying operating
system image available. That way we make sure not to ship all too outdated
software.
