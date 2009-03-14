#!/bin/sh -e

if test -z "$TEST_SRPMS"; then
    echo ";;; No TEST_SRPMS is specified" 1>&2
# magic number defined in automake:
#
#   If a given test program exits with a status of 77,
#   then its result is ignored in the final count.
#
#   TODO: --name=yum handling
    exit 77
fi

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

for srpm in $TEST_SRPMS
do
  srpmix --output-dir=${TESTDIR} --output-format=swrf --srpm=$srpm
  srpmix --output-format=swrf --srpm=$srpm
done
#TODO: test by configure?
#srpmix --output-format=swrf --name=yum
find ${TESTDIR} -name '*.swrf' | xargs -n1 --verbose rpm -qpl

for srpm in $TEST_SRPMS
do
  srpmix --output-dir=${TESTDIR} --output-format=rpm --srpm=$srpm
done
#TODO: test by configure?
#srpmix --output-dir=${TESTDIR} --output-format=rpm --name=yum
find ${TESTDIR} -name '*.rpm' | xargs -n1 --verbose rpm -qpl

