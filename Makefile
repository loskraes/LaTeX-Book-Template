
LATEXDIR=latex
LATEX_BASE=$(patsubst $(LATEXDIR)/%.tex,%,$(wildcard $(LATEXDIR)/[a-zA-Z0-9]*.tex))
LATEX_ALLBASE=$(LATEX_BASE) $(patsubst $(LATEXDIR)/%.tex,%,$(wildcard $(LATEXDIR)/[a-zA-Z0-9]*/*.tex))
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

.PHONY: phony-always
phony-always:

$(patsubst %,diff/%.zip,$(DIFFCOMPLETE)): diff/%.zip: diff/%/all
	cd diff/$* && zip -r ../$*.zip CHANGELOG.txt pdf/

$(patsubst %,diff/%.tar,$(DIFFCOMPLETE)): diff/%.tar: diff/%/all
	cd diff/$* && tar cvf ../$*.tar CHANGELOG.txt pdf/

$(patsubst %,diff/%.tar.gz,$(DIFFCOMPLETE)): diff/%.tar.gz: diff/%.tar
	gzip -k $<
$(patsubst %,diff/%.tar.xz,$(DIFFCOMPLETE)): diff/%.tar.xz: diff/%.tar
	xz -k $<
$(patsubst %,diff/%.tar.bz2,$(DIFFCOMPLETE)): diff/%.tar.bz2: diff/%.tar
	bzip2 -k $<
$(patsubst %,diff/%.tar.lzma,$(DIFFCOMPLETE)): diff/%.tar.lzma: diff/%.tar
	lzma -k $<

$(patsubst %,diff/%,$(DIFFCOMPLETE)): diff/%: phony-always
	$(MAKE) diff/$*/sources
	echo diff
diff/%/clean: phony-always
	rm -fr diff/$*
	rm -f diff/$*.zip diff/$*.tar diff/$*.tar.gz diff/$*.tar.xz diff/$*.tar.bz2 diff/$*.tar.lzma
diff/%/sources:
	$(MAKE) diff/$*/clean
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

diff/%/all: phony-always
	$(MAKE) diff/$*/sources
	$(eval DIFF_SOURCE_DONE_$*=yes)
	cd diff/$*/$(LATEXDIR) && $(MAKE) \
		$(patsubst diff/$*/$(LATEXDIR)/%.tex,%.pdf,$(wildcard diff/$*/$(LATEXDIR)/[a-zA-Z0-9]*.tex)) \
		$(patsubst diff/$*/$(LATEXDIR)/%.tex,%.pdf,$(wildcard diff/$*/$(LATEXDIR)/[a-zA-Z0-9]*/*.tex))
	for fname in $(patsubst diff/$*/$(LATEXDIR)/%.tex,%,$(wildcard diff/$*/$(LATEXDIR)/[a-zA-Z0-9]*.tex)) \
		$(patsubst diff/$*/$(LATEXDIR)/%.tex,%,$(wildcard diff/$*/$(LATEXDIR)/[a-zA-Z0-9]*/*.tex)); do \
		mkdir -p diff/$*/pdf/$$(dirname $$fname); \
		mkdir -p diff/$*/$$(dirname $$fname); \
		cp diff/$*/$(LATEXDIR)/$$fname.pdf diff/$*/pdf/$$fname.pdf; \
		cp diff/$*/$(LATEXDIR)/$$fname.pdf diff/$*/$$fname.pdf; \
		done
	

define GEN_DIFF_PDF
$$(patsubst %,diff/%/$(filename).pdf,$(DIFFCOMPLETE)): diff/%/$(filename).pdf: phony-always
	if [ "$$(DIFF_SOURCE_DONE_$$*)" != "yes" ]; then \
		$(MAKE) diff/$$*/sources; \
		fi
	$$(eval DIFF_SOURCE_DONE_$$*=yes)
	cd diff/$$*/$(LATEXDIR) && $(MAKE) $(filename).pdf
	mkdir -p diff/$$*/pdf/$(dir $(filename))
	mkdir -p diff/$$*/$(dir $(filename))
	cp diff/$$*/$(LATEXDIR)/$(filename).pdf diff/$$*/pdf/$(filename).pdf
	cp diff/$$*/$(LATEXDIR)/$(filename).pdf diff/$$*/$(filename).pdf
endef

$(foreach filename,$(LATEX_ALLBASE),\
	$(eval $(GEN_DIFF_PDF)) \
)

