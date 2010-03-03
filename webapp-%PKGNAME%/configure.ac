AC_INIT([%PKGNAME%], [0.0.0])
AC_CONFIG_AUX_DIR([misc/ac-aux])
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AC_CONFIG_MACRO_DIR([misc/m4])

AC_PROG_LN_S
PKG_PROG_PKG_CONFIG
AC_RPM_RELEASE


wwwdir=/srv/www/%PKGNAME%
AC_ARG_WITH([wwwdir],
  [AS_HELP_STRING([--with-wwwdir],[WWW data topdir. default=$wwwdir])],
     [wwwdir=$withval])
AC_SUBST([WWWDIR],[$wwwdir])


drootdir=`dirname $wwwdir`
AC_SUBST([DROOTDIR], [$drootdir])


vhost_servername=%PKGNAME%.com
AC_SUBST([VHOST_SERVERNAME], [$vhost_servername])


AC_SUBST_FILE([vhost_conf])
vhost_conf=$builddir/misc/httpd/vhost_conf


AC_OUTPUT([
	   Makefile
	   src/Makefile
	   src/base/Makefile
	   src/data/Makefile
	   misc/Makefile
	   misc/ac-aux/Makefile
	   misc/m4/Makefile
	   misc/specs/Makefile
	   misc/specs/%PKGNAME%.spec
	   misc/makefiles/Makefile
	   misc/pkgconfig/Makefile
	   misc/pkgconfig/%PKGNAME%.pc
	   misc/httpd/Makefile
	   misc/httpd/vhost.conf
	   misc/httpd/%PKGNAME%.conf
	   tests/Makefile
	  ])


