dnl major and minor are reflected to SRPMIX file.
dnl If the directory structure is changed incompatibly, update the major version.
dnl If the directory structure is changed compatibly, update the minor version.
dnl If the source code of srpmix is changed but the directory is not changed,
dnl just increment micro version.

m4_define([pkg_major_version],[3])
m4_define([pkg_minor_version],[104])
m4_define([pkg_micro_version],[0])
m4_define([pkg_name],    [srpmix])
m4_define([pkg_version], pkg_major_version.pkg_minor_version.pkg_micro_version)



AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_MAINTAINER_MODE

AC_SUBST(SRPMIX_MAJOR_VERSION, pkg_major_version)
AC_SUBST(SRPMIX_MINOR_VERSION, pkg_minor_version)
AC_SUBST(SRPMIX_MICRO_VERSION, pkg_micro_version)

#AC_RPM_RELEASE

if test "x$USE_MAINTAINER_MODE" = "xyes"; then
	AC_PATH_PROG([SVN], [svn])
fi
AM_CONDITIONAL([USE_SVN_RPM_RELEASE],
	 [test "x$SVN" != "x" && test -d "$srcdir/.svn"])

AC_CHECK_PROGS([RPM], [rpm])
if test "x$RPM" = "x"; then AC_MSG_ERROR(rpm not found); fi

AC_CHECK_PROGS([RPMBUILD], [rpmbuild])
if test "x$RPMBUILD" = "x"; then AC_MSG_ERROR(rpmbuild not found); fi

AC_SUBST(SWRFPM, $RPM)
AC_SUBST(SWRFBUILD, $RPMBUILD)

AC_ARG_WITH([test-srpms],
       [AS_HELP_STRING([--with-test-srpms='SRPMS...'],
          [specify the space-separated list of src.rpms for test])],
          [])
AC_SUBST([TEST_SRPMS], [$with_test_srpms])



AC_OUTPUT([
           Makefile
           misc/Makefile
           misc/ac-aux/Makefile
           misc/m4/Makefile
           misc/makefiles/Makefile
           misc/specs/Makefile
           src/libsrpmix.sh
           src/Makefile
           src/plugins/Makefile
           doc/Makefile
           utils/Makefile
           tests/Makefile
          ])

