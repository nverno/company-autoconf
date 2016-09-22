emacs ?= emacs
ruby ?= ruby

json=macros.json
dat=$(json:.json=.dat)

.PHONY: clean
all: $(dat)

$(dat): $(json)
	$(emacs) -batch -l index.el -f batch-convert $<

$(json):
	$(ruby) index.rb $@

clean:
	$(RM) *~ $(json)
