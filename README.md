# Code Climate CLI<br>

[![Code Climate](https://codeclimate.com/repos/5589eac269568019f50011ab/badges/58a4aad546ecbc23eb36/gpa.svg)](https://codeclimate.com/repos/5589eac269568019f50011ab/feed)

`codeclimate` is a command line interface for the Code Climate analysis
platform. It allows you to run Code Climate engines on your local machine inside
of Docker containers.

## Recommended OS X Install

Use boot2docker and our Homebrew wrapper scripts:

* [Install boot2docker](https://github.com/boot2docker/osx-installer/releases).
* [Complete the boot2docker set up steps](https://docs.docker.com/installation/mac/). Ensure that you initalize the boot2docker virtual machine, start it, and then set the required Docker environment variables. Before continuing on, run `docker version` to verify that Docker is succesfully set up and running.
* If it's not already, install [Homebrew](http://brew.sh/).
* Run `brew tap codeclimate/formulae` and then `brew install codeclimate`.
* To use the Code Climate CLI, run `codeclimate help`.

## Alt. OS X Install

If you prefer not to use Homebrew:

* [Install boot2docker](https://github.com/boot2docker/osx-installer/releases).
* [Complete the boot2docker set up steps](https://docs.docker.com/installation/mac/). Ensure that you initalize the boot2docker virtual machine, start it, and then set the required Docker environment variables. Before continuing on, run `docker version` to verify that Docker is succesfully set up and running.
* Run `docker pull codeclimate/codeclimate`.
* To use the Code Climate CLI:

```
docker run \
  --interactive --tty --rm \
  --env CODE_PATH="$PWD" \
  --volume "$PWD":/code \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /tmp/cc:/tmp/cc \
  codeclimate/codeclimate help
```

## Anywhere

If you are not using OS X:

* Run the following command:
```
curl -L https://github.com/codeclimate/codeclimate/archive/v0.0.7.tar.gz | tar xvz
cd codeclimate-* && sudo make install
```
* Run `docker pull codeclimate/codeclimate`. Before continuing on, run `docker version` to verify that Docker is succesfully set up and running.
* To use the Code Climate CLI:

```
docker run \
  --interactive --tty --rm \
  --env CODE_PATH="$PWD" \
  --volume "$PWD":/code \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /tmp/cc:/tmp/cc \
  codeclimate/codeclimate help
```

## CLI Commands

A list of available commands is accessible by running `codeclimate` or `codeclimate help`.

```console
$ codeclimate help

Available commands:
    analyze [-f format]
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

Description of each command:

* `analyze`: Analyze all relevant files in the current working directory. All engines that are enabled in your `.codeclimate.yml` file will run, one after another. The `-f` (or `format`) argument allows you to set the output format of the analysis (using `json` or `text`).
* `engines:disable engine_name`: Changes the engine's `enabled:` node to be `false` in your `.codeclimate.yml` file. This engine will not be run the next time your project is analyzed.
* `engines:enable engine_name`: Installs the specified engine (`engine_name`). Also changes the engine's `enabled:` node to be `true` in your `.codeclimate.yml` file. This engine will be run the next time your project is analyzed.
* `engines:install`: Compares the list of engines in your `.codeclimate.yml` file to those that are currently installed, then installs any missing engines.
* `engines:list`: Lists all available engines in the [Code Climate Docker Hub](https://registry.hub.docker.com/repos/codeclimate/).
* `engines:remove engine_name`: Removes an engine from your `.codeclimate.yml` file.
* `help`: Displays a list of commands that can be passed to the Code Climate CLI.
* `init`: Generates a new `.codeclimate.yml` file in the current working directory.
* `validate-config`: Validates the `.codeclimate.yml` file in the current working directory.
* `version`: Displays the current version of the Code Climate CLI.

## Copyright

See [LICENSE](LICENSE)
