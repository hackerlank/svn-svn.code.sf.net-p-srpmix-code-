m4_define([pkg_major_version],[0])
m4_define([pkg_minor_version],[0])
m4_define([pkg_micro_version],[4])
m4_define([pkg_name],    [strap])
m4_define([pkg_version], pkg_major_version.pkg_minor_version.pkg_micro_version)

AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_MAINTAINER_MODE


AC_CHECK_PROGS([GOSH],[gosh])
if test "x$GOSH" = x; then
   AC_MSG_ERROR(gosh not found)
fi

AC_CHECK_PROGS([MAILX],[mailx])
if test "x$MAILX" = x; then
   AC_MSG_ERROR(mailx not found)
fi

AC_SUBST(STRAP_MAJOR_VERSION, pkg_major_version)
AC_SUBST(STRAP_MINOR_VERSION, pkg_minor_version)
AC_SUBST(STRAP_MICRO_VERSION, pkg_micro_version)


AC_RPM_RELEASE

AC_OUTPUT([
	   Makefile
	   misc/Makefile
           misc/ac-aux/Makefile
           misc/m4/Makefile
           misc/makefiles/Makefile
           misc/specs/Makefile
           misc/specs/strap.spec
	   src/Makefile
	   ])

