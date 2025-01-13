
LATEXDIR=latex
LATEX_BASE=$(patsubst $(LATEXDIR)/%.tex,%,$(wildcard $(LATEXDIR)/[a-zA-Z0-9]*.tex))
PREVIOUS_VERSION=$(shell git tag --list --no-contains HEAD --merged HEAD --sort=authordate 'v[0-9]*' 2> /dev/null | tail -1)
VERSIONS=$(shell git tag --list --merged HEAD --sort=authordate 'v[0-9]*' 2> /dev/null)

DIFFCOMPLETE=HEAD $(VERSIONS)

LATEX_MAX_REPEAT_DIFF ?= 5
TOOLS_DIR ?= $(shell pwd)/tools
export TOOLS_DIR

SHELL := /bin/bash
PATH := $(TOOLS_DIR)/bin:$(PATH)

all: pdf

.PHONY: tools
tools:
	cd $(TOOLS_DIR) && $(MAKE)

pdf: 
	cd latex && $(MAKE) $(patsubst %,%.pdf,$(LATEX_BASE))

.PHONY: clean
clean:
	cd $(TOOLS_DIR) && $(MAKE) clean
	cd $(LATEXDIR) && $(MAKE) clean
	rm -fr diff/*/latex

.PHONY: dist-clean
dist-clean:
	cd $(TOOLS_DIR) && $(MAKE) dist-clean
	cd $(LATEXDIR) && $(MAKE) dist-clean
	rm -fr diff

.PHONY: always-phony
always-phony:

$(patsubst %,diff/%,$(DIFFCOMPLETE)).zip:
$(patsubst %,diff/%,$(DIFFCOMPLETE)):

diff/%.zip: always-phony
	$(MAKE) diff/$*
	zip diff/$*.zip diff/$*/CHANGELOG.txt $$(find diff/$*/$(LATEXDIR) -name '*.pdf')

diff/%: always-phony
	rm -fr diff/$*
	mkdir -p diff/$*
	git shortlog $*$$([[ ! "$*" =~ ".." ]] && echo '..') | sed "s/^\\s\\+/- /" >> diff/$*/CHANGELOG.txt
	echo '```' >> diff/$*/CHANGELOG.txt
	git diff --compact-summary $*$$([[ ! "$*" =~ ".." ]] && echo '..') >> diff/$*/CHANGELOG.txt
	echo '```' >> diff/$*/CHANGELOG.txt
	cat diff/$*/CHANGELOG.txt
	# Generate pdf diff
	cp -r $(LATEXDIR)/ diff/$*/$(LATEXDIR)
	cd diff/$*/$(LATEXDIR) && $(MAKE) dist-clean
	find diff/$*/$(LATEXDIR) -name '*.tex' -delete
	latexdiff-vc --git -d diff/$* -r $* $(shell find $(LATEXDIR) -name '*.tex')
	echo ASDF
	for base in $(LATEX_BASE); do\
		sed -i 's/\\input{_meta}//' diff/$*/$(LATEXDIR)/$$base.tex; \
		sed -i 's/\\begin{document}/\\input{_meta}\\begin{document}/' diff/$*/$(LATEXDIR)/$$base.tex; \
		done
	for subfile in $$(grep -r  --color -H --include '*.tex' -l -P '\\documentclass\[[^\]]*\]{subfiles}' diff/$*/$(LATEXDIR)/); do \
		echo subfile = $$subfile; \
		sed -i '/%DIF PREAMBLE EXTENSION ADDED BY LATEXDIFF/,/%DIF END PREAMBLE EXTENSION ADDED BY LATEXDIFF/d' $$subfile; \
		done
	cd diff/$*/$(LATEXDIR) && $(MAKE) all $(patsubst %,%.pdf,$(LATEX_BASE)) LATEX_MAX_REPEAT=$(LATEX_MAX_REPEAT_DIFF)
	for f in diff/$*/$(LATEXDIR)/*.pdf; do\
		new=$$(echo $$f | sed 's~/$(LATEXDIR)/~/diff-$*-~') ;\
		cp $$f $$new -v ;\
		done



