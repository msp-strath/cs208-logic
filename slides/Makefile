.PHONY: clean all

# all: week1.pdf week2.pdf week3.pdf week4.pdf week5.pdf week6.pdf week7.pdf week8.pdf week9.pdf week10.pdf

all: topic0.pdf \
     topic1.pdf \
     topic2.pdf \
     topic3.pdf \
     topic4.pdf \
     topic5.pdf \
     topic6.pdf \
     topic7.pdf \
     topic8.pdf \
     topic9.pdf \
     topic10.pdf \
     intro.pdf

%.pdf: %.tex macros.tex strathclyde.sty
	latexmk -xelatex $<

clean:
	rm -f *.pdf *.aux *.log *.xdv *.fls *.nav *.fdb_latexmk *.out *.toc *.snm *.upa
