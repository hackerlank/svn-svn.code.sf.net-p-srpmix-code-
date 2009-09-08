m4_define([pkg_name], sdoc)
m4_define([pkg_verison], [0.0.0])

AC_INIT(pkg_name, pkg_verison)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AC_CONFIG_MACRO_DIR([misc/m4])

AC_CHECK_PROGS(MAKEINFO, makeinfo)

AC_OUTPUT([
	Makefile
	misc/Makefile
        misc/ac-aux/Makefile 
        misc/m4/Makefile
        doc/Makefile
        ])

