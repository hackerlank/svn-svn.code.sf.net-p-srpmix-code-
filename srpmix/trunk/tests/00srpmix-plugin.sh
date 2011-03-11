#!/bin/bash -e

rm -rf `pwd`/${TESTDIR}
make DESTDIR=`pwd`/${TESTDIR} -C ${top_builddir} install

PATH=`pwd`/${TESTDIR}/${bindir}:$PATH
which srpmix-plugin
diff <(srpmix-plugin --list | while read name arrow file; do echo $name; done) <(cat <<"EOF"
coreutils
cscope
ctags
etags
file
hyperestraier
kindex
vanilla
xgettext
EOF
)
