#!/bin/sh -e

DEBUG=${DEBUG}

if test -z "$TEST_SRPMS"; then
    echo ";;; No TEST_SRPMS is specified" 1>&2
# magic number defined in automake:
#
#   If a given test program exits with a status of 77,
#   then its result is ignored in the final count.
#
    exit 77
fi

if test -f ~/.rpmmacros; then
    echo ";;; Use own .rpmmacros exists" 1>&2
    exit 77
else
    cat ${top_srcdir}/src/macros.srpmix >> ~/.rpmmacros
    trap "rm ~/.rpmmacros" 0
fi

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

for srpm in $TEST_SRPMS
do
  ROOTDIR=`pwd`/${TESTDIR}/tmp/$(basename $0).$$/$(basename $srpm)
  srpmix-ix ${DEBUG} -f -v ${ROOTDIR} $srpm 
done

