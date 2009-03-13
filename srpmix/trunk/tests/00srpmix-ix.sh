#!/bin/sh -e

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

make -C ${top_builddir} rpm

ROOTDIR=`pwd`/${TESTDIR}/tmp/$(basename $0).$$
srpmix-ix -f -v ${ROOTDIR} ${top_builddir}/build/SRPMS/*.src.rpm

