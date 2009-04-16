#!/bin/sh

FTP=ftp.redhat.com
MPATH=ftp://${FTP}/pub/redhat
OROOT=/tmp/mirror

ODIR=${OROOT}/${FTP}
LDIR=${OROOT}/log
PATTERN='*.src.rpm,*-debuginfo-*'
DATE=$(date --rfc-3339=date)



if ! test -d $ODIR; then
   mkdir -p $ODIR
fi

if ! test -d $LDIR; then
   mkdir -p $LDIR
fi

{
    cd ${ODIR}
    wget -nH --cut-dirs=2 --mirror ${MPATH} -A ${PATTERN} \
	  -o ${LDIR}/${FTP}.${DATE}.log
}
