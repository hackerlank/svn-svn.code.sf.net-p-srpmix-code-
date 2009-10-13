#!/bin/sh

set -x

LANG=C
rm -rf autom4te.cache

aclocal -I misc/m4
automake --add-missing --force-missing -Wno-portability
autoconf

REQUIRED=koji
if which yum > /dev/null 2>&1; then
    yum -y install ${REQUIRED}
fi