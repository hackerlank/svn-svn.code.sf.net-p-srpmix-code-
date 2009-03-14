#!/bin/sh -e

if test -z "$TEST_SRPMS"; then
    echo ";;; No TEST_SRPMS is specified" 1>&2
# magic number defined in automake:
#
#   If a given test program exits with a status of 77,
#   then its result is ignored in the final count.
#
    exit 77
fi

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

for srpm in $TEST_SRPMS
do
  srpmix-wrap --dump-spec $srpm
  srpmix-wrap --just-print $srpm
  srpmix-wrap --output-dir=${TESTDIR} $srpm
done

