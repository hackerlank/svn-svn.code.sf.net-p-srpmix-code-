#TMPDIR=
#OUTPUTDIR=
#VPATHFILE=
#BLACKLISTDIR=
#RELEASE=
#DEBUG=


PKGDATADIR = /usr/share/sbuild
VPATH := $(shell cat $(VPATHFILE) | tr \\n :)

SRPMIX_OPTIONS = 
ifneq ($(DEBUG),y)
.SILENT:
else
SRPMIX_OPTIONS += --debug
endif
SRPMIX_OPTIONS  += --release=$(RELEASE) --output-dir=$(OUTPUTDIR)

# or
# cat .$@ | gzip > $@; rm .$@;
# mv .$@ $@; touch --reference=$@ $@;
# touch $@; rm .$@;
dummy:
%.log: %.rpm
	install -d $(BLACKLISTDIR)
	+if ! test -f $(BLACKLISTDIR)/$@; then \
	        echo "$$(basename $<)"; \
		SRPMIX_OPTIONS="$(SRPMIX_OPTIONS)"; \
		echo TMPDIR=$(TMPDIR) srpmix --srpm=$< $$SRPMIX_OPTIONS; \
		if TMPDIR=$(TMPDIR) srpmix --srpm=$< $$SRPMIX_OPTIONS > .$@ 2>&1; then \
			mv .$@ $@; \
		else \
			mv .$@ $(BLACKLISTDIR)/$@; \
			exit 1; \
		fi; \
	fi
