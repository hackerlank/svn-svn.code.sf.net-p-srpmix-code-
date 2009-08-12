#!/bin/bash

DIR=$1

# TODO
BLACKLIST=fedoraproject-koji

if ! test -d "$1"; then
    echo "No such directory: $1" 1>&2
    exit 1
fi

find ${DIR} -name '*.src.rpm' \
    | grep -v "$BLACKLIST"               \
    | while read p; do basename $p; done \
    | sort \
    | uniq 
