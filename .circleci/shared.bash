#!/bin/bash

set -exuo pipefail

VERSION=$(cat VERSION)

function install_hub() {
    sudo apt update && sudo apt install -y git wget
    url="$(wget -qO- https://api.github.com/repos/github/hub/releases/latest | tr '"' '\n' | grep '.*/download/.*/hub-linux-amd64-.*.tgz')"
    wget -qO- "$url" | sudo tar -xzvf- -C /usr/bin --strip-components=2 --wildcards "*/bin/hub"
}

function login_to_dockerhub() {
  set +x
  docker login --username "$DOCKER_USERNAME" --password "$DOCKER_PASSWORD"
  set -x
}

function login_to_rubygems() {
  mkdir -p "$HOME/.gem"
  touch "$HOME/.gem/credentials"
  chmod 0600 "$HOME/.gem/credentials"
  printf -- "---\n:rubygems_api_key: %s\n" "$GEM_HOST_API_KEY" > "$HOME/.gem/credentials"
}

function tag_version() {
  ARTIFACTS_OUTPUT=binaries.tar.gz
  tar -c -f "${ARTIFACTS_OUTPUT}" ./*.gem
  GITHUB_TOKEN="${GITHUB_TOKEN}" hub release create -a "${ARTIFACTS_OUTPUT}" -m "v${VERSION}" "v${VERSION}"
}

function upload_docker_images() {
  docker build --rm --tag codeclimate/codeclimate .
  docker push codeclimate/codeclimate:latest
  docker tag codeclimate/codeclimate "codeclimate/codeclimate:$VERSION"
  docker push "codeclimate/codeclimate:$VERSION"
}

function trigger_hombrew_release() {
  curl -X POST\
  -u "username:$GITHUB_TOKEN" \
  https://api.github.com/repos/codeclimate/homebrew-formulae/actions/workflows/release.yml/dispatches \
  -d "{\"ref\":\"master\",\"inputs\":{\"version\":\"$VERSION\"}}"
}

function publish_new_version() {
  set +x
  # Build and push gem
  gem build ./*.gemspec
  gem push ./*.gem

  # Create gh tag
  # Skip until we have a better way to handle this
  # tag_version

  # Trigger hombrew release
  trigger_hombrew_release

  # Push docker images
  upload_docker_images

  set -x
}
