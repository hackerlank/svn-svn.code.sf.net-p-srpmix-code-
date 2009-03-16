m4_define([pkg_name],    [lcopy])
m4_define([pkg_version], [0.0.16])



AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

AC_PATH_PROG([_BASH_],   [bash])
if test "x$_BASH_" = x; then
   AC_MSG_ERROR([Cannot find bash])
fi

AC_PATH_PROG([_SRPMIX_], [srpmix])
dnl if test x$_SRPMIX_ = x; then
dnl   AC_MSG_ERROR([Cannot find srpmix])
dnl fi			

AC_OUTPUT([
           Makefile
           misc/Makefile
           misc/ac-aux/Makefile
           misc/m4/Makefile
           misc/makefiles/Makefile
           misc/specs/Makefile
           misc/specs/lcopy.spec
           src/Makefile
           src/backends/Makefile
           src/plugins/Makefile
           src/liblcopy.sh
           etc/Makefile
           doc/Makefile
          ])

