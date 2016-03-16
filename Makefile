.PHONY: build install uninstall image test citest

PREFIX ?= /usr/local

image:
	docker build -t codeclimate/codeclimate .

test: image
	docker run --rm \
	  --entrypoint bundle \
	  --volume /var/run/docker.sock:/var/run/docker.sock \
	  codeclimate/codeclimate exec rake spec:all spec:benchmark

citest:
	docker run \
	  --env CIRCLECI=$(CIRCLECI) \
	  --env CIRCLE_BUILD_NUM=$(CIRCLE_BUILD_NUM) \
	  --env CIRCLE_BRANCH=$(CIRCLE_BRANCH) \
	  --env CIRCLE_SHA1=$(CIRCLE_SHA1) \
	  --env CODECLIMATE_REPO_TOKEN=$(CODECLIMATE_REPO_TOKEN) \
	  --entrypoint bundle \
	  --volume $(PWD)/.git:/usr/src/app/.git:ro \
	  --volume /var/run/docker.sock:/var/run/docker.sock \
	  codeclimate/codeclimate exec rake spec:all spec:benchmark

install:
	bin/check
	docker pull codeclimate/codeclimate:latest
	docker images | awk '/codeclimate\/codeclimate-/ { print $$1 }' | xargs -n1 docker pull || true
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	docker run --rm \
	  --volume $(DESTDIR)$(PREFIX)/bin:/host-bin \
	  --entrypoint /bin/cp codeclimate/codeclimate \
	    /usr/src/app/codeclimate-wrapper /host-bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	docker rmi codeclimate/codeclimate:latest
