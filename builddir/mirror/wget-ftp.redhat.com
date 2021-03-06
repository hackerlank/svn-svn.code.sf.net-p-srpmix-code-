#!/bin/sh
#
# Mirror src.rpm and debuginfo files at ftp.redhat.com to local
#
#
# Masatake YAMATO, GPL3.
#

# Where the data are mirrored to
ROOT=/srv/sources/archives/mirror

# Data sources
FTP=ftp.redhat.com
MPATH=ftp://${FTP}/pub/redhat


ODIR=${ROOT}/${FTP}
LDIR=${ROOT}/log

#PATTERN='*.src.rpm,*-debuginfo-*'
PATTERN='*.src.rpm'

DATE=$(date --rfc-3339=date)

if ! test -d $ODIR; then
   mkdir -p $ODIR
fi

if ! test -d $LDIR; then
   mkdir -p $LDIR
fi

{
    cd ${ODIR}
    LANG=C wget -nH --cut-dirs=2 --mirror ${MPATH} -A ${PATTERN} \
	        -o ${LDIR}/${FTP}.${DATE}.log
}

