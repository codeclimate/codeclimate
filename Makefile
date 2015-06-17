VERSION = 0.0.1
PREFIX ?= /usr/local

release:
	git tag -m v$(VERSION) v$(VERSION)
	git push --tags

install:
	which docker
	docker pull codeclimate/codeclimate:$(VERSION)
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 codeclimate-wrapper $(DESTDIR)$(PREFIX)/bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	docker rmi codeclimate/codeclimate:$(VERSION)

.PHONY: install uninstall
