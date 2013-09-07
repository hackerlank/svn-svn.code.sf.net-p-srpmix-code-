#!/bin/bash

h=$(pwd)
for t in tests/*.d; do
    echo -n $(basename ${t})...
    (cd $t
	T=$(mktemp)
	if [[ -f build.mk ]]; then
	    make -f build.mk > /dev/null
	else
	    make -f $h/tests/build.mk > /dev/null
	fi
	gosh $h/callq --script input.es  | {
	    if [[ $(cat filter)  = "read/write" ]]; then
		gosh -b -e '(let loop ((r (read))) (if (eof-object? r) (exit 0) (begin (write r) (newline) (loop (read)))))' 
	    else
		cat
	    fi 
	} > $T

	if diff output.dat $T > /dev/null; then
	    echo successful
	    rm $T
	else
	    echo failed "(see $T)"
	    diff output.dat $T
	fi
    )
done
