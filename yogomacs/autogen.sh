#!/bin/sh

set -x

LANG=C
rm -rf autom4te.cache

#libtoolize --force
aclocal -I misc/m4
automake --add-missing --force-missing
autoconf
