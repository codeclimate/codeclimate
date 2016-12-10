# Code Climate CLI

[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/codeclimate/builds/987)

## Overview

`codeclimate` is a command line interface for the Code Climate analysis
platform. It allows you to run Code Climate engines on your local machine inside
of Docker containers.

## Prerequisites

The Code Climate CLI is distributed and run as a
[Docker](https://www.docker.com) image. The engines that perform the actual
analyses are also Docker images. To support this, you must have Docker installed
and running locally. We also require that the Docker daemon supports connections
on the default Unix socket `/var/run/docker.sock`.

On OS X, we recommend using [Docker Machine](https://docs.docker.com/machine/).

## Installation

```console
docker pull codeclimate/codeclimate
```

## Usage

```console
docker run \
  --interactive --tty --rm \
  --env CODECLIMATE_CODE="/code" \
  --volume "$PWD":/code \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /tmp/cc:/tmp/cc \
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
brew tap codeclimate/formulae
brew install codeclimate
```

To update the brew package, use `brew update` first:

```console
brew update
brew upgrade codeclimate
```

### Anywhere

```console
curl -L https://github.com/codeclimate/codeclimate/archive/master.tar.gz | tar xvz
cd codeclimate-* && sudo make install
```

## Commands

A list of available commands is accessible by running `codeclimate` or
`codeclimate help`.

```console
$ codeclimate help

Available commands:
    analyze [-f format] [-e engine(:channel)] <path> [--dev]
    console
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

The following is a brief explanation of each available command.

* `analyze`
  Analyze all relevant files in the current working directory. All
  engines that are enabled in your `.codeclimate.yml` file will run, one after
  another. The `-f` (or `format`) argument allows you to set the output format of
  the analysis (using `json`, `text`, or `html`). The `--dev` flag lets you run
  engines not known to the CLI, for example if you're an engine author developing
  your own, unreleased image.
* `console`
  start an interactive session providing access to the classes
  within the CLI. Useful for engine developers and maintainers.
* `engines:disable engine_name`
  Changes the engine's `enabled:` node to be `false` in your `.codeclimate.yml`
  file. This engine will not be run the next time your project is analyzed.
* `engines:enable engine_name`
  Installs the specified engine (`engine_name`). Also changes the engine's
  `enabled:` node to be `true` in your `.codeclimate.yml` file. This engine
  will be run the next time your project is analyzed.
* `engines:install`
  Compares the list of engines in your `.codeclimate.yml` file to those that
  are currently installed, then installs any missing engines.
* `engines:list`
  Lists all available engines in the
  [Code Climate Docker Hub](https://hub.docker.com/u/codeclimate/)
  .
* `engines:remove engine_name`
  Removes an engine from your `.codeclimate.yml` file.
* `help`
  Displays a list of commands that can be passed to the Code Climate CLI.
* `init`
  Generates a new `.codeclimate.yml` file in the current working directory.
* `validate-config`
  Validates the `.codeclimate.yml` file in the current working directory.
* `version`
  Displays the current version of the Code Climate CLI.

## Environment Variables

* To run `codeclimate` in debug mode:

  ```
  CODECLIMATE_DEBUG=1 codeclimate analyze
  ```

  Prints additional information about the analysis steps, including any stderr
  produced by engines.

* To increase the amount of time each engine container may run (default 15 min):

  ```
  # 30 minutes
  CONTAINER_TIMEOUT_SECONDS=1800 codeclimate analyze
  ```

* You can also configure the default alotted memory with which each engine runs
  (default is 512,000,000 bytes):

  ```
  # 100,000,0000 bytes
  ENGINE_MEMORY_LIMIT_BYTES=1000000000 codeclimate analyze
  ```

## Copyright

See [LICENSE](LICENSE)
