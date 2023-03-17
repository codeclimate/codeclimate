.PHONY: install uninstall image test citest bundle

PREFIX ?= /usr/local
SKIP_ENGINES ?= 0

image:
	podman pull "$(shell grep FROM Dockerfile | sed 's/FROM //')"
	podman build -t codeclimate/codeclimate .

test: RSPEC_ARGS ?= --tag ~slow
test: image
	podman run --rm -it \
	  --entrypoint bundle \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate exec rspec $(RSPEC_ARGS)

test_all: image
	podman run --rm -it \
	  --entrypoint bundle \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate exec rake spec:all spec:benchmark

citest:
	podman rm codeclimate-cli-test || true
	podman run \
	  --name codeclimate-cli-test \
	  --entrypoint sh \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate -c "bundle exec rake spec:all"
	mkdir -p coverage
	podman cp codeclimate-cli-test:/usr/src/app/coverage/. ./coverage/
	./cc-test-reporter after-build --prefix /usr/src/app/
	podman run \
	  --entrypoint sh \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate -c "bundle exec rake spec:benchmark"

install:
	bin/check
	podman pull codeclimate/codeclimate:latest
	@[ $(SKIP_ENGINES) -eq 1 ] || \
	  podman images | \
	  awk '/codeclimate\/codeclimate-/ { print $$1 }' | \
	  xargs -n1 podman pull 2>/dev/null || true
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 codeclimate-wrapper $(DESTDIR)$(PREFIX)/bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	podman rmi codeclimate/codeclimate:latest

bundle:
	podman run --rm \
	  --entrypoint bundle \
	  --volume $(PWD):/usr/src/app \
	  --workdir /usr/src/app \
	  codeclimate/codeclimate $(BUNDLE_ARGS)
