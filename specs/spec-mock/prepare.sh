P=runtime-plugin.patch
wget -O $P 'https://bugzilla.redhat.com/attachment.cgi?id=447492'
git clone git://git.fedorahosted.org/git/mock.git
cd mock
patch -p1 < ../$P
bash autogen.sh
./configure
make rpm
