#!/bin/sh

MPATH=ftp.redhat.com:/pub/redhat
OROOT=/tmp/mirror
ODIR=${OROOT}/ftp.redhat.com
OLOG=${OROOT}/ftp.redhat.com.log
PATTERN='*.src.rpm,*-debuginfo-*'

if ! test -d $ODIR; then
   mkdir -p $ODIR
fi

wget --mirror ${MPATH} -A ${PATTERN} ${ODIR}  -o ${OLOG}
