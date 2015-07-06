PREFIX ?= /usr/local

install:
	bin/check
	docker pull codeclimate/codeclimate:latest
	docker images | awk '/codeclimate\/codeclimate-/ { print $$1 }' | xargs -n1 docker pull
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 codeclimate-wrapper $(DESTDIR)$(PREFIX)/bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	docker rmi codeclimate/codeclimate:latest

.PHONY: install uninstall
