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

1. Update `VERSION` and add tag it in git:

  ```console
  echo 0.0.8 > VERSION          # for example
  bundle                        # to update Gemfile.lock
  git add VERSION Gemfile.lock
  git commit -m "Release v0.0.8"
  git tag -m v0.0.8 v0.0.8
  git push
  git push --tags
  ```

1. Build and push the new image to docker hub

  ```console
  docker build --rm -t codeclimate/codeclimate .
  docker push codeclimate/codeclimate
  ```

1. Update the Homebrew [formula][] with the correct `url` and `sha1sum`

  To calculate the SHA:

  ```console
  curl -L https://github.com/codeclimate/codeclimate/archive/v0.0.8.tar.gz | sha1sum
  ```

1. Update the *Anywhere* README instructions to reference the new archive

[formula]: https://github.com/codeclimate/homebrew-formulae/blob/master/Formula/codeclimate.rb
