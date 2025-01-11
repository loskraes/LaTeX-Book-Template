
PDFVIEWER=open

LATEXROOT=$(wildcard [a-zA-Z0-9]*.tex)
PDFROOT=$(patsubst %.tex,%.pdf,$(LATEXROOT))
LATEX=$(LATEXROOT) $(wildcard [a-zA-Z0-9]*/*.tex)
PDF=$(patsubst %.tex,%.pdf,$(LATEX))

DIRTY_TAG=-dirty
DIRTY_TAG_REGEX=$(DIRTY_TAG)

LATEXFLAGS=-pdf -M -MP -MF $(notdir $*).d -use-make

# TODO:
default: 
	echo TODO

all: report.pdf

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


dist-clean:
	latexmk -C
	cd content && latexmk -C
	rm -fr *.d */*.d
