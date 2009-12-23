#!/bin/bash
name=$(basename $0 .sh)
class=${top_builddir}/src/classes/svnweb
conf=${top_builddir}/src/conf.d/jbossas.prelcopy

diff <(bash -x $class $conf) ./${name}.txt

