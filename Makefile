.PHONY: build install uninstall

PREFIX ?= /usr/local

image:
	docker build -t codeclimate/codeclimate .

test_only:
	docker run --rm \
	  --entrypoint bundle \
	  --volume /var/run/docker.sock:/var/run/docker.sock \
	  codeclimate/codeclimate exec rake

test: image test_only

install:
	bin/check
	docker pull codeclimate/codeclimate:latest
	docker images | awk '/codeclimate\/codeclimate-/ { print $$1 }' | xargs -n1 docker pull || true
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 codeclimate-wrapper $(DESTDIR)$(PREFIX)/bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	docker rmi codeclimate/codeclimate:latest
