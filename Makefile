
LATEXDIR=latex
LATEX_BASE=$(patsubst $(LATEXDIR)/%.tex,%,$(wildcard $(LATEXDIR)/[a-zA-Z0-9]*.tex))
PREVIOUS_VERSION=$(shell git tag --list --no-contains HEAD --merged HEAD --sort=authordate 'v[0-9]*' 2> /dev/null | tail -1)
VERSIONS=$(shell git tag --list --merged HEAD --sort=authordate 'v[0-9]*' 2> /dev/null)

DIFFCOMPLETE=HEAD $(VERSIONS)

SHELL := /bin/bash

all: pdf

pdf: 
	cd latex && $(MAKE) $(patsubst %,%.pdf,$(LATEX_BASE))

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
	## sed -i '/%DIF PREAMBLE/d' $$(find diff-$*/$(LATEXDIR)/*/ -name '*.tex')
	cd diff/$*/$(LATEXDIR) && $(MAKE) all
	for f in diff/$*/$(LATEXDIR)/*.pdf; do\
		new=$$(echo $$f | sed 's~/$(LATEXDIR)/~/diff-$*-~') ;\
		cp $$f $$new -v ;\
		done



