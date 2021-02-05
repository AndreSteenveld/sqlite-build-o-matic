# SQLite Build-O-Matic

Build every released version of SQLite and packaged as a docker image

# Usage

Using the `sqlite3` bash script contained in this repository an image can be used similarly to the regular `sqlite3` cli interface. There are some environment variables that can be provided to specify paths, versions among other things.

* `SQLITE_DOCKER_COMMAND` - Specify the docker command to run. Defaults to `docker`
* `SQLITE_DOCKER_REGISTRY` - Specify the docker repository to use. Defaults to `docker.io/AndreSteenveld`
* `SQLITE_VERSION` - Specify the version of SQLite (image) to use. Defaults to `latest`
* `SQLITE_ROOT` - What is mounted under `/-` inside the container. Defaults to `/`
* `SQLITE_WORKDIR` - The path to run the CLI in. Defaults to `/-/$PWD`

When running from a windows you might need to set the `SQLITE_DOCKER` variable to `winpty docker`.

# Building images

`make bootstrap` - Create a image with a fresh checkout of SQLite

`make sqlite-releases` - Dump all "version" tags from the repository in to a file (`./sqlite-releases`)

`make build SQLITE_VERSION=<tag name> SQLITE_TAG=<image tag>` - Create a docker image from "`SQLITE_VERSION`" with image tag "`SQLITE_TAG`"

Building everything
```bash

cat ./sqlite-releases | xargs                                               \
    --replace=@@                                                            \
    --max-procs=$(lscpu --json | jq '.lscpu[4].data | tonumber | . - 1' )   \
    bash -c                                                                 \
        'make build SQLITE_VERSION="@@" SQLITE_TAG=$(sed "s/version-//" <<<"@@")'

```
