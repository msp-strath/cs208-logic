.PHONY: clean all

all: week1.pdf week2.pdf week3.pdf week4.pdf week5.pdf week6.pdf week7.pdf week8.pdf week9.pdf week10.pdf

week%.pdf: week%.tex macros.tex strathclyde.sty
	latexmk -xelatex $<

clean:
	rm -f *.pdf *.aux *.log *.xdv *.fls *.nav *.fdb_latexmk *.out *.toc *.snm *.upa
