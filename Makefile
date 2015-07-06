PREFIX ?= /usr/local

install:
	bin/check
	docker pull codeclimate/codeclimate:latest
	docker images | grep codeclimate/codeclimate- | awk '{print $1}' | while read image; do docker pull $image; done
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 codeclimate-wrapper $(DESTDIR)$(PREFIX)/bin/codeclimate

uninstall:
	$(RM) $(DESTDIR)$(PREFIX)/bin/codeclimate
	docker rmi codeclimate/codeclimate:latest

.PHONY: install uninstall
