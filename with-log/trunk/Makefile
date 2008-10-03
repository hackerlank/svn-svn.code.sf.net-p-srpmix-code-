FILES      = FILES
RST_FILES = $(shell cat $(FILES))
HTML = with-log.html

all: $(HTML)

check:
	for x in `cat $(FILES)`; do		\
	  rst2html $$x > /dev/null;		\
        done
$(HTML): $(FILES) $(RST_FILES) Makefile
	cat `cat $(FILES)` | rst2html > $@

.PHONY: check