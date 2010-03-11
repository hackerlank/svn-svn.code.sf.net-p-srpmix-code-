#!/bin/sh

set -x

aclocal -I misc/m4
automake --foreign --add-missing
autoconf
