# Code Climate CLI

## Overview

`codeclimate` is a command line interface for the Code Climate analysis
platform. It allows you to run Code Climate engines on your local machine inside
of Docker containers.

## Prerequisites

The Code Climate CLI is distributed and run as a
[Docker](https://www.docker.com) image. The engines that perform the actual
analyses are also Docker images. To support this, you must have Docker installed
and running locally. We also require that the Docker daemon supports connections
on the default unix socket `/var/run/docker.sock`.

On OS X, we recommend using [boot2docker](http://boot2docker.io/).

## Installation

```console
docker pull codeclimate/codeclimate
```

## Usage

```console
docker run \
  --interactive --tty --rm \
  --env CODE_PATH="$PWD" \
  --volume "$PWD":/code \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  codeclimate/codeclimate help
```

## Packages

The above is very transparent. It's clear what's happening, and any changes
required to work with your specific Docker setup can be discovered easily. That
said, it can be unwieldy to invoke such a command on a regular basis.

For this reason, we also provide packages that include a small wrapper script
for the above invocation:

### OS X

```console
brew tap codeclimate/homebrew-formulae
brew install codeclimate
```

### Anywhere

```console
curl https://github.com/codeclimate/codeclimate/archive/v0.0.1.tar.gz | tar xvzf -
sudo make install
```

## Commands

A list of available commands is accessible by running `codeclimate` or
`codeclimate help`.

```console
$ codeclimate help

Available commands:
    analyze [-f format] [path]
    engines:disable engine_name
    engines:enable engine_name
    engines:install
    engines:list
    engines:remove
    help
    init
    validate-config
    version
```

## Copyright

See [LICENSE](LICENSE)
