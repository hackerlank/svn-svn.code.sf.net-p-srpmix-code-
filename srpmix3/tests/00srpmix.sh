#!/bin/bash -e

DEBUG=${DEBUG:+--debug}

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

if test -f ~/.rpmmacros; then
    echo ";;; Use own .rpmmacros exists" 1>&2
    exit 77
else
    cat ${abs_top_srcdir}/src/macros.srpmix >> ~/.rpmmacros
    trap "rm ~/.rpmmacros" 0
fi

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH

for srpm in $TEST_SRPMS
do
  srpmix ${DEBUG} --output-dir=${TESTDIR} --output-format=swrf --srpm=$srpm
  srpmix ${DEBUG} --output-format=swrf --srpm=$srpm
done
#TODO: test by configure?
#srpmix --output-format=swrf --name=yum
find ${TESTDIR} -name '*.swrf' | xargs -n1 --verbose rpm -qpl
find ${TESTDIR} -name '*.swrf' | while read swrf
do
  if rpm -qpl $swrf | grep SRPMIX > /dev/null; then
    srpmix-build ${DEBUG} --output-format=swrf --type=plugin --output-dir=${TESTDIR} --swrf=$swrf
    srpmix-build ${DEBUG} --output-format=rpm --type=plugin --output-dir=${TESTDIR} --swrf=$swrf
  fi
done

for srpm in $TEST_SRPMS
do
  srpmix ${DEBUG} --output-dir=${TESTDIR} --output-format=rpm --srpm=$srpm
done
#TODO: test by configure?
#srpmix --output-dir=${TESTDIR} --output-format=rpm --name=yum
find ${TESTDIR} -name '*.rpm' | xargs -n1 --verbose rpm -qpl

