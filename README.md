# Code Climate CLI

[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/codeclimate)
[![CircleCI](https://circleci.com/gh/codeclimate/codeclimate.svg?style=svg)](https://circleci.com/gh/codeclimate/codeclimate)

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

On macOS, we recommend using [Docker for Mac](https://docs.docker.com/docker-for-mac/).

## Installation

### macOS

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

To upgrade to a newer version, just run those steps again.

### Manual Docker invocation

The above packages pull the docker image and install a shell script wrapper.
In some cases you may want to run the docker image directly.

To pull the docker image:

```console
docker pull codeclimate/codeclimate
```

To invoke the CLI via Docker:

```console
docker run \
  --interactive --tty --rm \
  --env CODECLIMATE_CODE="$PWD" \
  --volume "$PWD":/code \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /tmp/cc:/tmp/cc \
  codeclimate/codeclimate help
```

## Project setup

### Configuration

No explicit configuration is needed: by default `codeclimate analyze` will
evaluate supported source files in your repository using our
[maintainability checks][docs_maintainability]. To change default configuration
to customize how the maintainability checks are evaluated, or to turn on open
source plugins, see our [documentation on advanced
configuration][docs_advanced_config].

[docs_maintainability]: https://docs.codeclimate.com/docs/maintainability
[docs_advanced_config]: https://docs.codeclimate.com/docs/configuring-your-analysis#section-configuration-file-structure-and-content

### Plugin installation

Plugins, or "engines", are the docker images that run analysis tools. We support
many different plugins, and will only install the ones necessary to run
analysis. As part of setting up your project, we recommend running `codeclimate
engines:install` from within your repository before running `codeclimate
analyze`, and after adding any new plugins to your configuration file.


### Running analysis

Once you've installed plugins and made any necessary changes to your
configuration, run `codeclimate analyze` to run analysis and see a report on any
issues in your repository.

## Commands

A list of available commands is accessible by running `codeclimate` or
`codeclimate help`.

```console
$ codeclimate help

Available commands:
    analyze [-f format] [-e engine[:channel]] [--dev] [path]
    console
    engines:install
    engines:list
    help [command]
    prepare [--allow-internal-ips]
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

  You can optionally provide a specific path to analyze. If not provided, the
  CLI will analyze your entire repository, except for your configured
  `exclude_paths`. When you do provide an explicit path to analyze, your
  configured `exclude_paths` are ignored, and normally excluded files will be
  analyzed.

  You can also pipe in source in combination with a path to analyze code that is
  not yet written to disk. This is useful when you want to check if your source
  code style matches the project's. This is also a good way to implement
  integration with an editor to check style on the fly.
* `console`
  start an interactive session providing access to the classes
  within the CLI. Useful for engine developers and maintainers.
* `engines:install`
  Compares the list of engines in your `.codeclimate.yml` file to those that
  are currently installed, then installs any missing engines and checks for new images available for existing engines.
* `engines:list`
  Lists all available engines in the
  [Code Climate Docker Hub](https://hub.docker.com/u/codeclimate/)
  .
* `help`
  Displays a list of commands that can be passed to the Code Climate CLI.
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
  (default is 1,024,000,000 bytes):

  ```
  # 2,000,000,000 bytes
  ENGINE_MEMORY_LIMIT_BYTES=2000000000 codeclimate analyze
  ```

## Releasing a new version

CLI's new versions are released automatically when updating
[VERSION](https://github.com/codeclimate/codeclimate/blob/master/VERSION) on `master`.

The releasing process includes;

1. Push new version to rubygems.
1. Create a new release on Github and an associated tag.
1. Update docker images:
  * Push new `latest` image.
  * Push new image with latest version as tag.

Ideally someone will open a pull request against master updating only
[VERSION](https://github.com/codeclimate/codeclimate/blob/master/VERSION).

There is script in place, which assumes [hub](https://hub.github.com/) is installed,
to facilitate that. Check the current VERSION (`cat VERSION`) and upgrade accordingly running:

```sh
./bin/prep-release <VERSION>
```

## Copyright

See [LICENSE](LICENSE)
