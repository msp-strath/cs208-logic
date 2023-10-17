SITE:=./_site

PAGES:=pages

BUILD:=_build/default

INSTALL:=install -m 644

TARGET:=$(shell cat target)

ifeq ($(TARGET),)
$(error No deploy target found! Should be in a file 'target')
endif

.PHONY: complete-site html-pages frontend-js assets-copy all deploy clean

all: complete-site

deploy: complete-site
	rsync -avz --delete $(SITE)/ $(TARGET)

complete-site: $(SITE) html-pages frontend-js assets-copy

$(SITE):
	mkdir -p $(SITE)

html-pages: $(SITE)
	dune exec ./site_gen/main.exe pages $(SITE)

frontend-js: $(SITE)
	dune build --profile=release frontend/frontend.bc.js
	$(INSTALL) $(BUILD)/frontend/frontend.bc.js $(SITE)/

assets-copy: $(SITE)
	$(INSTALL) assets/* $(SITE)/

clean:
	dune clean
	rm -rf $(SITE)
