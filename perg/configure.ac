m4_define([pkg_name],[perg])
m4_define([pkg_major_version],[0])
m4_define([pkg_minor_version],[1])
m4_define([pkg_micro_version],[0])
m4_define([pkg_version],pkg_major_version.pkg_minor_version.pkg_micro_version)

AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AC_CONFIG_MACRO_DIR([misc/m4])
AM_MAINTAINER_MODE

AC_CHECK_PROGS([GOSH], [gosh])
if test "x$GOSH" = "x"; then 
   AC_MSG_ERROR(gosh not found); 
fi

PKG_CHECK_EXISTS([es-src-xgettext])
PKG_CHECK_EXISTS([es-src-syslog])
PKG_CHECK_EXISTS([es-filter-filelines])
PKG_CHECK_EXISTS([es-filter-generic])
PKG_CHECK_EXISTS([es-dest-syslog])
PKG_CHECK_EXISTS([es-dest-grep])


AM_PATH_LISPDIR

AC_RPM_RELEASE

AC_OUTPUT([
	Makefile
	misc/Makefile
	misc/ac-aux/Makefile
	misc/specs/Makefile
	misc/specs/perg.spec
	misc/m4/Makefile
	misc/makefiles/Makefile
	misc/pkgconfig/Makefile
	misc/pkgconfig/perg.pc
	src/Makefile
	src/cmds/Makefile
	src/cmds/mperg
	src/emacs/Makefile
	tests/Makefile
	])
