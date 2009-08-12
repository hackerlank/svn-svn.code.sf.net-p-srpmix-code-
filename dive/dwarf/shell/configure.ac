m4_define([pkg_name],    [dwarfish])
m4_define([pkg_verison], [0.0.1])


AC_INIT(pkg_name, pkg_verison)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

AC_PROG_CC
AC_PROG_CC_STDC

AC_PROG_LIBTOOL

dnl AM_PATH_GLIB_2_0
PKG_CHECK_MODULES([GLIB2],    [glib-2.0])
PKG_CHECK_MODULES([ES_LANG_C_STDC99], [es-lang-c-stdc99])
AC_CHECK_LIB(dwarves, dwarves__init)

AC_OUTPUT([
	   Makefile
           misc/Makefile 
           misc/ac-aux/Makefile 
	   src/Makefile
	  ])
