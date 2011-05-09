#!/bin/bash

function try_source
{
    source $1
    if test $? != 0; then
        echo "*** ABORT..." "cannot find $1" 1>&2
	exit 1
    fi
}

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

try_source libsrpmix.sh


x=$(srpmix_distmap_to_pvr <<"EOF"
(srpmix-wrap name :target-srpm "ElectricFence-2.2.2-20.2.src.rpm" 
                  :package "ElectricFence" :version "2.2.2" 
                  :release "20.2"  
                  :wrapped-name "ElectricFence-2.2.2-20.2-srpmix")
EOF
)

test "x$x" = "xElectricFence 2.2.2 20.2"
