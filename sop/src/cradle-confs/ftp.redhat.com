#!/bin/bash
METHOD=wget
ENABLE=yes
GC=no
BACKUP=no
BUILD=yes
BUILDERS=srpmix
DIST_MAPPING=no
INSTALL=no

CREATEREPO_OPTS=--update

WGET_PROTOCOL=ftp
WGET_HOST=ftp.redhat.com
WGET_PATH=/pub/redhat
WGET_PATTERN='*.src.rpm,*-debuginfo-*.x86_64.rpm'
WGET_CUT_DIRS=2
