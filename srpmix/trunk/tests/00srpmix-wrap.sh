#!/bin/sh -e

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

make -C ${top_builddir} rpm
srpmix-wrap --dump-spec ${top_builddir}/build/SRPMS/*.src.rpm
srpmix-wrap --just-print ${top_builddir}/build/SRPMS/*.src.rpm
srpmix-wrap --output-dir=${TESTDIR} ${top_builddir}/build/SRPMS/*.src.rpm

