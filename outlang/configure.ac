m4_define([pkg_name], [outlang])
m4_define([pkg_version], [0.0.2])

AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AC_CONFIG_MACRO_DIR([misc/m4])


AC_ARG_WITH([vim],
             AC_HELP_STRING([--with-source-highlight=SOURCE_HIGHLIGHT],
                            [specify the executable file name of source-highlight]),
             [ SOURCE_HIGHLIGHT="${withval}" ])

AC_GAUCHE_INIT_EXT
GAUCHE_MODULEDIR=`$GAUCHE_CONFIG --sitelibdir`
AC_SUBST(GAUCHE_MODULEDIR)

AC_RPM_RELEASE

AC_CONFIG_COMMANDS([chmod],[
chmod 0755 src/cmds/*
])

AC_OUTPUT([
           Makefile
	   misc/Makefile
	   misc/ac-aux/Makefile
	   misc/m4/Makefile
	   misc/specs/Makefile
	   misc/specs/outlang.spec
	   misc/makefiles/Makefile
	   src/Makefile
	   src/cmds/Makefile
	   src/source-highlight/Makefile
	   src/gauche/Makefile
	   src/gauche/outlang/Makefile
	   ])
