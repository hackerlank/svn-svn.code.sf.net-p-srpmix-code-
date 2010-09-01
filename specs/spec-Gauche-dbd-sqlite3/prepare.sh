PACKAGE=Gauche-dbd-sqlite3
VERSION=0.1.3
URL=http://autogol.ath.cx/dbd-sqlite3

sudo yum -y install gauche-devel sqlite-devel

wget -O /tmp/${PACKAGE}-${VERSION}.tgz ${URL}/${PACKAGE}-${VERSION}.tgz
if ! [ $? = 0 ]; then
    echo "Cannot get tgz from $URL" 1>&2
    exit 1
fi

if ! [ -d ~/rpmbuild/SOURCES/ ] ; then
    echo "Cannot find directory for SOURCES" 1>&2
    exit 1
fi
mv /tmp/${PACKAGE}-${VERSION}.tgz ~/rpmbuild/SOURCES/

sed \
    -e "s|@PACKAGE@|$PACKAGE|g"  \
    -e "s|@VERSION@|$VERSION|g"  \
    -e "s|@URL@|$URL|g"          \
    < ${PACKAGE}.spec.in         \
    > ${PACKAGE}.spec

rpmbuild -ba ${PACKAGE}.spec
