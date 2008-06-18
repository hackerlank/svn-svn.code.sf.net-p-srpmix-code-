#!/bin/sh
#
# build-sources.sh --- run srpmix* in batch to build sources 
#
# Usage:
#
#        build-sources.sh [image-directory]
#
# Default image-directory is /srv/sources/src-images.
#
#

IMG_DIR=/srv/sources/src-images
if test "$1"; then
    IMG_DIR="$1"
fi

#
# _ is dummy. _ triggers hardlink.
#
DISTROS="EL5SU2 _ F9"
DEPLOYED_DIR=/srv/sources/src-deployed

verify_imgdir()
{
    d=$1


    if test ! -d "${IMG_DIR}/${d}"; then
	echo '*'cannot find image directory: ${IMG_DIR}/${d}'*' 1>&2
	exit 1
    else
	:
#
#	echo image found for ${d}: ${IMG_DIR}/${d}
#
    fi
}


install_and_expand()
{
    d=$1
    

    srpmix -f -v -s -g sources ${DEPLOYED_DIR}/${d} ${IMG_DIR}/${d}/*.iso
    srpmix-etags ${DEPLOYED_DIR}/${d}
#    srpmix-ctags ${DEPLOYED_DIR}/${d}
#    srpmix-cscope ${DEPLOYED_DIR}/${d}
    srpmix-spider ${DEPLOYED_DIR}/${d}    
#    srpmix-gonzui  {DEPLOYED_DIR}/${d}
    srpmix-vanilla {DEPLOYED_DIR}/${d}
}

main()
{
    for d in $DISTROS ;do
	if test "$d" != _; then
	    verify_imgdir "$d"
	fi
    done    

    mkdir -p ${DEPLOYED_DIR}
    groupadd sources

    for d in $DISTROS ;do
	if test "$d" = _; then
	    logger -t build-sources.sh "start hardlink: $(date)"
	    srpmix-meta-hardlink {DEPLOYED_DIR}/*  | sh
	    logger -t build-sources.sh "end hardlink: $(date)"
	else
	    logger -t build-sources.sh "start building $d: $(date)"
	    if test ! -d ${DEPLOYED_DIR}/${d}; then
		install_and_expand "$d"
	    fi
	    logger -t build-sources.sh "end building $d: $(date)"
	fi
    done
}


main
