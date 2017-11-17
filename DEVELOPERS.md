Information for Code Climate CLI developers and contributors.

## Testing local changes

Build a new image using the local sources:

```console
make image
```

If you have the CLI installed, the `codeclimate` wrapper will automatically use
this image:

```console
codeclimate version
```

Otherwise, invoke the `docker run` command found in the README.

## Releasing a new version

### Prerequisites

1. Be an owner of the [codeclimate gem](https://rubygems.org/gems/codeclimate)
   and authenticate with `gem push`
1. Clone [homebrew-formulae](https://github.com/codeclimate/homebrew-formulae)

Prep and open a PR bumping the version:

```console
bin/prep-release VERSION
```

Once merged, release it:

```console
bin/release
```
