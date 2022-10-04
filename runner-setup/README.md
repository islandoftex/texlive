# TeX Live docker images GitLab runner setup

The TeX Live docker image repository builds the images and afterwards uploads them to our [GitLab registry](https://gitlab.com/islandoftex/images/texlive/container_registry) and [Docker Hub](https://hub.docker.com/r/texlive/texlive).
The build process is using [Runners](https://docs.gitlab.com/runner/).
This document describes how to setup a runner for the project yourself.

## Requirements

The requirements to setup a runner mostly consist of available disk space (minimum 25 GB, when aggressive pruning is applied, see below) and a network connection to download the files from CTAN.

We use the docker executor to avoid conflicts with the base system. Therefore you need to have an up and running [docker demon](https://docs.docker.com/config/daemon/) as well as the [GitLab Runner binaries](https://docs.gitlab.com/runner/install/).

To cleanup the file system, we currently use prune scripts. They require bash, xargs, awk and grep. The files in this repo will use systemd but this is not a general requirement one could easily adjust those for cron.

## Register a runner

The registration of a runner can be done as usual. Simply run

```
gitlab-runner register
```

You will then be asked for

- the GitLab instance URL (https://gitlab.com)
- the registration token (can be found at `<Project Repo URL>/-/settings/ci_cd`)
- description
- optional tags
- optional maintenance note
- excutor (we recommend and use the docker executor)

For the official IoT repository the registrations tokens are not public. In case you want to support us by providing additional runners feel free to get into contact ([Matrix room](https://matrix.to/#/!titTeSvZiqNOvRIKCv:matrix.org?via=matrix.org) see project badges).

The basic build process involves pushing to multiple registries. To allow your runner to do so you also have to change/add some settings withing your runner configuration.
This should be found in `/etc/gitlab-runner/config.toml`. Please ensure to only edit the Runner you just registered for this project.

```
[[runners]]
name = "RUNNER_NAME"
url = "https://gitlab.com/"
token = "REGISTRATION_TOKEN"
executor = "docker"
[runners.docker]
# … here might be some other settings
# this has to be set to true:
privileged = true
# Here the docker socket has to be added so the build process can access the network. /cache might already be there.
volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
```


## Pruning the images
Since we build docker images which might need a lot of disk space it's necessary to setup some pruning mechanisms.
We currently use a systemd service which is starting a simple bash script to search for leftover images and is cleaning this up.
The script  is called `prune-texlive-images.sh`.
To install it as a systemd service which is run hourly you move the `prune-texlive-images.service` and the `prune-texlive-images.timer` files to your systemd directory (probably `/etc/systemd/system/`).
The bash script is placed in `/usr/local/bin/prune-texlive-images.sh`.

Run `systemctl daemon-reload` to update the daemon and afterwards you should enable (`systemctl enable prune-texlive-images`) and start the service (`systemctl start prune-texlive-images`).

You can of course also edit the script path. Please take care that you also have to adjust the path within the `prune-texlie-images.service` file.
In case you have a lot of available disk space it's possible to reduce the frequency. This can be adjusted within the timer file.
