
PDFVIEWER=open

TEXROOT=$(wildcard [a-zA-Z0-9]*.tex)
PDFROOT=$(patsubst %.tex,%.pdf,$(TEXROOT))
TEX=$(TEXROOT) $(wildcard [a-zA-Z0-9]*/*.tex)
PDF=$(patsubst %.tex,%.pdf,$(TEX))

LATEXFLAGS=-pdf -M -MP -MF $(notdir $*).d -use-make

# TODO:
default: 
	echo TODO

report.pdf:
report.pdf.pvc:

-include *.d
-include */*.d

$(PDF): %.pdf: %.tex
	cd $(dir $*) && latexmk $(LATEXFLAGS) $(notdir $*)

.PHONY: $(patsubst %,%.pvc,$(PDF))
$(patsubst %,%.pvc,$(PDF)): %.pdf.pvc: %.tex
	cd $(dir $*) && latexmk $(LATEXFLAGS) -pvc $(notdir $*)


.PHONY: _dyn/git-version.tex
_dyn/git-version.tex:
	mkdir -p _dyn
	git describe --tags --match 'v[0-9]*' > $@

.PHONY: _dyn/git-version-short.tex
_dyn/git-version-short.tex: _dyn/git-version.tex
	cat $< | sed 's/-[0-9a-h]\+$$//' > $@

