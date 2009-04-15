# Use this from build.sh
# -----------------------------------------------------------------

DIR    := $(shell pwd)
TMPDIR := /var/tmp/sources-seed

# The directory where ftp.redhat.com mirror is
MIRRORDIR := /misc/mirror

OUTPUTDIR := /misc/srpmix/redhat-srpmix

RELEASE := 0
SRPMIX_OPTIONS := --release=$(RELEASE) --output-dir=$(OUTPUTDIR)
SRPMIX         := /usr/bin/srpmix


ifneq ($(DEBUG),y)
.SILENT:
else
SRPMIX_OPTIONS += --debug
endif


BLACKLISTDIR := $(DIR)/blacklist.d
VPATHLIST    := $(DIR)/vpath.list
VPATH        := $(DIR):$(shell make $(VPATHLIST); cat $(VPATHLIST) | tr \\n :)

all:


$(VPATHLIST): $(VPATHLIST).in Makefile
	sed -e 's|@MIRRORDIR@|$(MIRRORDIR)|' < $< > $@

blacklist.d:
	mkdir -p $<



%.log: %.rpm
	install -d $(BLACKLISTDIR)
	+if ! test -f $(BLACKLISTDIR)/$@; then \
	        echo "$$(basename $<)"; \
		SRPMIX_OPTIONS="$(SRPMIX_OPTIONS)"; \
		echo TMPDIR=$(TMPDIR) $(SRPMIX) --srpm=$< $$SRPMIX_OPTIONS; \
		if TMPDIR=$(TMPDIR) $(SRPMIX) --srpm=$< $$SRPMIX_OPTIONS > .$@ 2>&1; then \
			mv .$@ $@; \
		else \
			mv .$@ $(BLACKLISTDIR)/$@; \
			exit 1; \
		fi; \
	fi

outputdir:
	@echo $(OUTPUTDIR)

clean:
	rm -f $(VPATHLIST)
