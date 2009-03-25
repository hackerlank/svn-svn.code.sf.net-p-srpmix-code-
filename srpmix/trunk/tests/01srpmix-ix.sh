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
  ROOTDIR=`pwd`/${TESTDIR}/tmp/$(basename $0).$$/$(basename $srpm)

  # This must be failed because "Name: ..." in spec is deleted.
  srpmix-ix -f -v --rearrange-spec-command='sed -e s/^Name: .*//' ${ROOTDIR} $srpm 
  if test $? = 0; then
      exit 1
  fi

  SRPMIX_REARRANGE_SPEC_COMMAND='sed -e s/^Name: .*//' srpmix-ix -f -v ${ROOTDIR} $srpm 
  if test $? = 0; then
      exit 1
  fi

done

exit 0