#!/bin/sh -e

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

for srpm in $TEST_SRPMS
do
  ROOTDIR=`pwd`/${TESTDIR}/tmp/$(basename $0).$$/$(basename $srpm)
  srpmix-ix -f -v ${ROOTDIR} $srpm
done

