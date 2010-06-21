m4_define([pkg_name], [yogomacs])
m4_define([pkg_version], [0.0.0])

AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AC_CONFIG_MACRO_DIR([misc/m4])

AC_CONFIG_MACRO_DIR([misc/m4])

AC_ARG_WITH([emacs],
             AC_HELP_STRING([--with-emacs=PROG],
                            [specify the executable file name of emacs]),
             [ EMACS="${withval}" ])
AM_PATH_LISPDIR


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
	   misc/specs/yogomacs.spec
	   misc/makefiles/Makefile
	   src/Makefile
	   src/cmds/Makefile
	   src/elisp/Makefile
	   src/elisp/flserver/Makefile
	   src/elisp/flserver/plugins/Makefile
	   src/gauche/Makefile
	   src/gauche/yogomacs/Makefile
	   src/gauche/yogomacs/dentries/Makefile
	   ])
