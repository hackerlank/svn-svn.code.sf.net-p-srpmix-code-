#!/bin/bash
METHOD=wget
ENABLE=yes
GC=no
BACKUP=no
BUILD=yes
DIST_MAPPING=no
INSTALL=no

WGET_PROTOCOL=ftp
WGET_HOST=ftp.redhat.com
WGET_PATH=/pub/redhat
WGET_PATTERN='*.src.rpm'
WGET_CUT_DIRS=2
