.PHONY: build install uninstall

PREFIX ?= /usr/local

image:
	docker build -t codeclimate/codeclimate .

install:
	bin/check
	docker pull codeclimate/codeclimate:latest
	docker images | awk '/codeclimate\/codeclimate-/ { print $$1 }' | xargs -n1 docker pull || true
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 codeclimate-wrapper $(DESTDIR)$(PREFIX)/bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	docker rmi codeclimate/codeclimate:latest

