#!/bin/bash

SOP_CONF=sop.cf

# TODO
BLACKLIST=fedoraproject-koji


if [ "x$1" != x ] && [ -r "$1/${SOP_CONF}" ]; then
    source "$1/${SOP_CONF}"
elif test -f /etc/sop/${SOP_CONF}; then
    source /etc/sop/${SOP_CONF}
else
    echo "Cannot load ${SOP_CONF} file" 1>&2
    exit 1
fi

find ${SOP_MIRROR_DIR} -name '*.src.rpm' \
    | grep -v "$BLACKLIST"               \
    | while read p; do basename $p; done \
    | sort \
    | uniq 
