#!/bin/bash
METHOD=alias
ENABLE=no
GC=no
BACKUP=no
BUILD=yes
BUILDERS=diix
DIST_MAPPING=no
INSTALL=no

CREATEREPO_OPT=--update

ALIAS_ORIGINAL=ftp.redhat.com
