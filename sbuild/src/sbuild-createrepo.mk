#!/usr/bin/make -f

#RPMS := $(shell find -name '*.rpm')
RPMS := $(wildcard [0-9a-zA-Z]) $(wildcard weakview) $(wildcard dir-pkg/[0-9a-zA-Z]) $(wildcard *.rpm)
CREATEREPO_OPTS =
COMPS := $(shell test -f comps.xml && echo "comps.xml")
COMPS_OPT := $(if $(COMPS),-g comps.xml,)

all: repodata/primary.xml.gz
repodata/primary.xml.gz: $(RPMS) $(COMPS)
	createrepo $(CREATEREPO_OPTS) -d --skip-stat $(COMPS_OPT) .
