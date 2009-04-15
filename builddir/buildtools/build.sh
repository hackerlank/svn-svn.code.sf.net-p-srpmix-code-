#!/bin/sh

export DIR=`pwd`
export MKDIR=${DIR}/makefiles
export BUILDMK=${MKDIR}/build.mk 
export REPOMK=${MKDIR}/createrepo.mk
export OUTPUTDIR=$(make -f DIR=${DIR} ${BUILDMK} outputdir)
export RELEASE=`date +%Y%m%d`

while read f; do
  h=$(echo $f | sed 's/\(.\).*/\1/')
  echo "Processing $h"

  install -d $h

  make -f ${BUILDMK}				\
       DIR=${DIR}				\
       -k -l4 -e -C $h				\
      $(echo $f | sed 's/\.rpm/.log/g')
done

( cd $OUTPUTDIR && make -f ${REPOMK} )

