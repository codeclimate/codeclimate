VERSION = 0.0.15
PREFIX ?= /usr/local

release:
	git tag -m v$(VERSION) v$(VERSION)
	git push --tags

install:
	bin/check
	docker pull codeclimate/codeclimate:latest
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 codeclimate-wrapper $(DESTDIR)$(PREFIX)/bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	docker rmi codeclimate/codeclimate:latest

.PHONY: install uninstall
