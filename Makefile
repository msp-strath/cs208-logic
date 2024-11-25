SITE:=./_site

PAGES:=pages

BUILD:=_build/default

INSTALL:=install -m 644

TARGET:=$(shell cat target)

ifeq ($(TARGET),)
$(error No deploy target found! Should be in a file 'target')
endif

.PHONY: complete-site html-pages frontend-js assets-copy slides all deploy clean

all: complete-site

deploy: complete-site
	rsync -avz --delete $(SITE)/ $(TARGET)

complete-site: $(SITE) html-pages frontend-js assets-copy slides

$(SITE):
	mkdir -p $(SITE)

slides: $(SITE)
	make -C slides -j 8 all
	for w in 1 2 3 4 5 6 7 8 9 10; do \
	  outfile=$$(printf "week%02d-slides.pdf" $$w); \
	  $(INSTALL) -T slides/week$$w.pdf $(SITE)/$$outfile; \
	done

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
