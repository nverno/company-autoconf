emacs ?= emacs
ruby ?= ruby

macros=http://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.69/html_node/Autoconf-Macro-Index.html#Autoconf-Macro-Index

json=macros.json
dat=$(json:.json=.dat)

.PHONY: clean
all: $(dat)

$(dat): $(json)
	$(emacs) -batch -l index.el -f batch-convert $<

$(json):
	$(ruby) index.rb $@ $(macros)


clean:
	$(RM) *~ $(json)
