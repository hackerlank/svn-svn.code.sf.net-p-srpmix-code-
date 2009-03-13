#!/bin/sh -e

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

for srpm in $TEST_SRPMS
do
  srpmix --output-dir=${TESTDIR} --output-format=swrf --srpm=$srpm
done
find ${TESTDIR} -name '*.swrf' | xargs -n1 --verbose rpm -qpl

