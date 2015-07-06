Information for Code Climate CLI developers and contributors.

## Testing local changes

Build a new image using the local sources:

```console
docker build --rm -t codeclimate/codeclimate .
```

If you have the CLI installed, the `codeclimate` wrapper will automatically use
this image:

```console
codeclimate version
```

Otherwise, invoke the `docker run` command found in the README.

## Releasing a new version

1. Update `VERSION` and tag it in git:

  ```console
  echo 0.0.8 > VERSION          # for example
  bundle                        # to update Gemfile.lock
  git add VERSION Gemfile.lock
  git commit -m "Release v0.0.8"
  git tag -m v0.0.8 v0.0.8
  git push
  git push --tags
  ```

1. Release the new version to RubyGems:

  ```console
  rake release
  ```

  **Note**: this is not required if you don't need to incorporate your changes
  into server-side analysis.

1. Build and push the new image to docker hub

  ```console
  docker build --rm -t codeclimate/codeclimate .
  docker push codeclimate/codeclimate
  ```

  **Note**: this will cause any user who installs after this point to get the
  updated image, regardless of which *package version* they may be installing.

1. Update the Homebrew [formula][] with the correct `url` and `sha1sum`

  To calculate the SHA:

  ```console
  curl -L https://github.com/codeclimate/codeclimate/archive/v0.0.8.tar.gz | sha1sum
  ```

  **Note**: this is not required if you don't need to trigger Homebrew users to
  update (maybe what you've changed only impacts server-side analysis).

1. Update the *Anywhere* README instructions to reference the new archive

[formula]: https://github.com/codeclimate/homebrew-formulae/blob/master/Formula/codeclimate.rb

1. Update the release notes for the tag you created in github using the `FIX`, `FEATURE` syntax
