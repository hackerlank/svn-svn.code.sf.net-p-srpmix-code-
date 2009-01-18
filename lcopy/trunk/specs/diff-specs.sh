#!/bin/bash

D=/var/lib/lcopy/specs
diff -uN <(ls *.spec) <(cd $D; ls *.spec) | grep -v -e '^+++' | grep -e '^+' | sed -e 's/^+//'



