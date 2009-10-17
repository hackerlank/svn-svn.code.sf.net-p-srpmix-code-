#!/usr/bin/make -f

#RPMS := $(shell find -name '*.rpm')
RPMS := $(wildcard [0-9a-zA-Z]) $(wildcard weakview) $(wildcard dir-pkg/[0-9a-zA-Z]) $(wildcard *.rpm)
CREATEREPO_OPTS =

all: repodata/primary.xml.gz
repodata/primary.xml.gz: $(RPMS)
	if test -f comps.xml; then COMPS_OPT="-g comps.xml"; fi; \
		createrepo $(CREATEREPO_OPTS) -d --skip-stat $$COMPS_OPT  .
