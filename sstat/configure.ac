m4_define([pkg_major_version],[0])
m4_define([pkg_minor_version],[0])
m4_define([pkg_micro_version],[0])
m4_define([pkg_name],    [sstat])
m4_define([pkg_version], pkg_major_version.pkg_minor_version.pkg_micro_version)

AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_MAINTAINER_MODE

AC_PATH_PROG([stap])
AC_PATH_PROG([gosh])


AC_SUBST(SSTAT_MAJOR_VERSION, pkg_major_version)
AC_SUBST(SSTAT_MINOR_VERSION, pkg_minor_version)
AC_SUBST(SSTAT_MICRO_VERSION, pkg_micro_version)


AC_RPM_RELEASE

AC_OUTPUT([
	   Makefile
	   misc/Makefile
           misc/ac-aux/Makefile
           misc/m4/Makefile
           misc/makefiles/Makefile
           misc/specs/Makefile
           misc/specs/sstat.spec
	   src/Makefile
	   ])

