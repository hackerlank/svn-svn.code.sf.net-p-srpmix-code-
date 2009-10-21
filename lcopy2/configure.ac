m4_define([pkg_name],    [lcopy])
m4_define([pkg_major_version],[0])
m4_define([pkg_minor_version],[2])
m4_define([pkg_micro_version],[5])
m4_define([pkg_version],pkg_major_version.pkg_minor_version.pkg_micro_version)

AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_MAINTAINER_MODE

AC_PATH_PROG([_BASH_],   [bash])
if test "x$_BASH_" = x; then
   AC_MSG_ERROR([Cannot find bash])
fi

AC_PATH_PROG([_SRPMIX_], [srpmix])
if test x$_SRPMIX_ = x; then
  AC_MSG_ERROR([Cannot find srpmix])
fi			

AC_PATH_PROG([_CVS_], [cvs])
if test x$_CVS_ = x; then
  AC_MSG_ERROR([Cannot find cvs])
fi			

AC_PATH_PROG([_SVN_], [svn])
if test x$_SVN_ = x; then
  AC_MSG_ERROR([Cannot find svn])
fi			

AC_PATH_PROG([_GIT_], [git])
if test x$_GIT_ = x; then
  AC_MSG_ERROR([Cannot find git])
fi			

AC_PATH_PROG([_HG_], [hg])
if test x$_HG_ = x; then
  AC_MSG_ERROR([Cannot find hg])
fi			

AC_PATH_PROG([_DARCS_], [darcs])
if test x$_DARCS_ = x; then
  AC_MSG_ERROR([Cannot find darcs])
fi			

AC_PATH_PROG([_BZR_], [bzr])
if test x$_BZR_ = x; then
  AC_MSG_ERROR([Cannot find bzr])
fi			

AC_PATH_PROG([_SRPMIX_PLUGIN_], [srpmix-plugin])
if test x$_SRPMIX_PLUGIN_ = x; then
  AC_MSG_ERROR([Cannot find srpmix-plugin])
fi			

AC_RPM_RELEASE

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
    	   src/liblcopy.sh
    	   src/liblcopy_backends.sh
    	   src/conf.d/Makefile
          ])
