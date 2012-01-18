m4_define([pkg_name],[prelcopy])
m4_define([pkg_major_version],[0])
m4_define([pkg_minor_version],[0])
m4_define([pkg_micro_version],[3])
m4_define([pkg_version],pkg_major_version.pkg_minor_version.pkg_micro_version)

AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_MAINTAINER_MODE

AC_PATH_PROG([_BASH_],   [bash])
if test "x$_BASH_" = x; then
   AC_MSG_ERROR([Cannot find bash])
fi

AC_PATH_PROG([_CURL_], [curl])
if test x$_CURL_ = x; then
  AC_MSG_ERROR([Cannot find curl])
fi			

AC_RPM_RELEASE

AC_OUTPUT([
           Makefile
           misc/Makefile
           misc/ac-aux/Makefile
           misc/m4/Makefile
           misc/makefiles/Makefile
           misc/specs/Makefile
           misc/specs/prelcopy.spec
           src/Makefile
           src/classes/Makefile
    	   src/conf.d/Makefile
    	   tests/Makefile
          ])
