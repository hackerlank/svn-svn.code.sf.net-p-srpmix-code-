AC_INIT([%PKGNAME%], [0.0.0])
AM_INIT_AUTOMAKE

AC_PROG_LN_S

wwwdir=/opt/www/%PKGNAME%
AC_ARG_WITH([wwwdir],
  [AS_HELP_STRING([--with-wwwdir],[WWW data topdir. default=$wwwdir])],
     [wwwdir=$withval])
AC_SUBST([WWWDIR],[$wwwdir])

AC_OUTPUT([
Makefile
misc/Makefile
misc/ac-aux/Makefile
misc/m4/Makefile
misc/specs/Makefile
misc/specs/%PKGNAME%.spec
])


