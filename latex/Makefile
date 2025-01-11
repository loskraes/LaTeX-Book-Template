
PDFVIEWER=open

TEXROOT=$(wildcard [a-zA-Z0-9]*.tex)
PDFROOT=$(patsubst %.tex,%.pdf,$(TEXROOT))
TEX=$(TEXROOT) $(wildcard [a-zA-Z0-9]*/*.tex)
PDF=$(patsubst %.tex,%.pdf,$(TEX))

#LATEXFLAGS=-pdf -e "\$$pdf_previewer = '$(PDFVIEWER) %O %S'" -M -MP -MF $(notdir $*).d -use-make
LATEXFLAGS=-pdf -e "\$$pdf_previewer = '$(PDFVIEWER) %O %S'" -M -MP -MF $(notdir $*).d -use-make

# TODO:
default: 
	echo TODO

report.pdf:
report.pdf.pvc:

-include *.d
-include */*.d

$(PDF): %.pdf: %.tex
	cd $(dir $*) && latexmk $(LATEXFLAGS) $(notdir $*)
