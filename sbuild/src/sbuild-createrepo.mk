#!/usr/bin/make -f

#RPMS := $(shell find -name '*.rpm')
RPMS := $(wildcard [0-9a-zA-Z]) weakview $(wildcard *.rpm)

repodata/primary.xml.gz: $(RPMS) comps.xml
	time createrepo --update -d --skip-stat -g comps.xml .

