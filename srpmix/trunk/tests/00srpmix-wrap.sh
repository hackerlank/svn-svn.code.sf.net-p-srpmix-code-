#!/bin/sh -e

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

for srpm in $TEST_SRPMS
do
  srpmix-wrap --dump-spec $srpm
  srpmix-wrap --just-print $srpm
  srpmix-wrap --output-dir=${TESTDIR} $srpm
done

