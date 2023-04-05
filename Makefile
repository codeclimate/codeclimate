.PHONY: install uninstall image test citest bundle

VERSION ?= $(shell cat VERSION)
ARTIFACTS_OUTPUT ?= artifacts.tar.gz
PREFIX ?= /usr/local
SKIP_ENGINES ?= 0

image:
	docker pull "$(shell grep FROM Dockerfile | sed 's/FROM //')"
	docker build -t codeclimate/codeclimate .

test: RSPEC_ARGS ?= --tag ~slow
test: image
	docker run --rm -it \
	  --entrypoint bundle \
	  --volume /var/run/docker.sock:/var/run/docker.sock \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate exec rspec $(RSPEC_ARGS)

test_all: image
	docker run --rm -it \
	  --entrypoint bundle \
	  --volume /var/run/docker.sock:/var/run/docker.sock \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate exec rake spec:all spec:benchmark

citest:
	docker rm codeclimate-cli-test || true
	docker run \
	  --name codeclimate-cli-test \
	  --entrypoint sh \
	  --volume /var/run/docker.sock:/var/run/docker.sock \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate -c "bundle exec rake spec:all"
	mkdir -p coverage
	docker cp codeclimate-cli-test:/usr/src/app/coverage/. ./coverage/
	./cc-test-reporter after-build --prefix /usr/src/app/
	docker run \
	  --entrypoint sh \
	  --volume /var/run/docker.sock:/var/run/docker.sock \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate -c "bundle exec rake spec:benchmark"

install:
	bin/check
	docker pull codeclimate/codeclimate:latest
	@[ $(SKIP_ENGINES) -eq 1 ] || \
	  docker images | \
	  awk '/codeclimate\/codeclimate-/ { print $$1 }' | \
	  xargs -n1 docker pull 2>/dev/null || true
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 codeclimate-wrapper $(DESTDIR)$(PREFIX)/bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	docker rmi codeclimate/codeclimate:latest

bundle:
	docker run --rm \
	  --entrypoint bundle \
	  --volume $(PWD):/usr/src/app \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate $(BUNDLE_ARGS)

build-gem:
	gem build ./*.gemspec

new-github-release: build-gem
	tar -c -f "${ARTIFACTS_OUTPUT}" ./*.gem
	gh release create "v${VERSION}" "${ARTIFACTS_OUTPUT}" --title "v${VERSION}" --notes "Release v${VERSION}"
