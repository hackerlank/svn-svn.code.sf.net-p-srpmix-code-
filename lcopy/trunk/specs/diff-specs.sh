#!/bin/bash

D=/var/lib/lcopy/specs
diff -uN <(ls *.spec) <(cd $D; ls *.spec) | grep -v -e '^+++' | grep -e '^+' | sed -e 's/^+//'

# for x in `bash diff-specs.sh`; do cp /var/lib/lcopy/specs/$x .; done
# svn add `svn status | grep -e -lcopy- | grep -e '?' | while read a b ;do echo $b; done`



