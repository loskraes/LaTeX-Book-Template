
PDFVIEWER=open

LATEXROOT=$(wildcard [a-zA-Z0-9]*.tex)
PDFROOT=$(patsubst %.tex,%.pdf,$(LATEXROOT))
LATEX=$(LATEXROOT) $(wildcard [a-zA-Z0-9]*/*.tex)
PDF=$(patsubst %.tex,%.pdf,$(LATEX))

DIRTY_TAG=-dirty
DIRTY_TAG_REGEX=$(DIRTY_TAG)

LATEX_MAX_REPEAT ?= 5

LATEXFLAGS=-pdf -M -MP -MF $(notdir $*).d -use-make -e "\$$max_repeat=$(LATEX_MAX_REPEAT)" -interaction=batchmode

TOOLS_DIR ?= $(shell pwd)/tools
PATH := $(TOOLS_DIR)/bin:$(PATH)


# TODO:
default: 
	echo TODO

all: report.pdf

.PHONY: tools
tools:
	cd $(TOOLS_DIR) && $(MAKE)

report.pdf:
report.pdf.pvc:

-include *.d
-include */*.d

$(PDF): %.pdf: %.tex
	cd $(dir $*) && latexmk $(LATEXFLAGS) $(notdir $*)

.PHONY: $(patsubst %,%.pvc,$(PDF))
$(patsubst %,%.pvc,$(PDF)): %.pdf.pvc: %.tex %.pdf
	cd $(dir $*) && latexmk $(LATEXFLAGS) -pvc $(notdir $*)


.PHONY: _dyn/git-version.tex
_dyn/git-version.tex:
	mkdir -p _dyn
	git describe --tags --match 'v[0-9]*' --dirty="$(DIRTY_TAG)" --broken > $@

.PHONY: _dyn/git-version-short.tex
_dyn/git-version-short.tex: _dyn/git-version.tex
	cat $< | sed -E 's/-[0-9a-h]+($(DIRTY_TAG_REGEX))?$$//' > $@

.PHONY: _dyn/git-log.tex
_dyn/git-log.tex: tools
	mkdir -p _dyn
	git-log-latex > $@

.PHONY: _dyn/git-date-lastcommit.tex
_dyn/git-date-lastcommit.tex:
	mkdir -p _dyn
	echo -n '\DTMsavetimestamp{\datename}{' > $@
	git log --pretty=format:%aI -n1 >> $@
	echo -n '}' >> $@

.PHONY: _dyn/git-date.tex
_dyn/git-date.tex: tools
	mkdir -p _dyn
	echo -n '\DTMsavetimestamp{\datename}{' > $@
	u="$$(git ls-files --exclude-standard --others)" && if [ -z "$u" ]; then \
		git-last-modified-included-file >> $@ ;\
		else \
		git log --pretty=format:%aI -n1 >> $@; \
		fi
	echo -n '}' >> $@


clean:
	latexmk -c
	cd content && latexmk -c
	rm -fr _dyn
	rm -fr *.d */*.d
	rm -f *-oldtmp-[0-9]*.tex
	rm -f *-oldtmp-[0-9]*.tex.rej
	rm -f */*-oldtmp-[0-9]*.tex
	rm -f */*-oldtmp-[0-9]*.tex.rej
dist-clean: clean
	latexmk -C
	cd content && latexmk -C
