#!/usr/bin/make -f

#RPMS := $(shell find -name '*.rpm')
RPMS := $(wildcard [0-9a-zA-Z]) $(wildcard weakview) $(wildcard dir-pkg) $(wildcard *.rpm)

all: repodata/primary.xml.gz
repodata/primary.xml.gz: $(RPMS) comps.xml
	time createrepo --update -d --skip-stat -g comps.xml .
