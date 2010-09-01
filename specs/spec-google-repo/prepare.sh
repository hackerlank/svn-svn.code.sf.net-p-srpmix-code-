PACKAGE=google-repo
VERSION=0.0.0
URL=http://android.git.kernel.org/repo
wget -O /tmp/repo http://android.git.kernel.org/repo
if ! [ $? = 0 ]; then
    echo "Cannot get script from $URL" 1>&2
    exit 1
fi

if ! [ -d ~/rpmbuild/SOURCES/ ] ; then
    echo "Cannot find directory for SOURCES" 1>&2
    exit 1
fi
mv /tmp/repo ~/rpmbuild/SOURCES/repo

sed \
    -e "s|@PACKAGE@|$PACKAGE|g"  \
    -e "s|@VERSION@|$VERSION|g"  \
    -e "s|@URL@|$URL|g"          \
    < ${PACKAGE}.spec.in         \
    > ${PACKAGE}.spec

rpmbuild -ba ${PACKAGE}.spec
