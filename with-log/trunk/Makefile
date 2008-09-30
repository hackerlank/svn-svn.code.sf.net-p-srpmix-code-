FILES      = FILES
RST_FILES = $(shell cat $(FILES))
HTML = with-log.html

all: $(HTML)

$(HTML): $(FILES) $(RST_FILES) Makefile
	cat `cat $(FILES)` | rst2html > $@

