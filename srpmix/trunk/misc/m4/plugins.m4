dnl
dnl SRPMIX_ENABLE_PLUGIN(etags, [test "x$ETAGS" != "x"])
dnl
AC_DEFUN([SRPMIX_ENABLE_PLUGIN],[
    AC_MSG_CHECKING(for $1 plugin)
    AC_ARG_ENABLE([plugin-$1],
	[AS_HELP_STRING([--enable-plugin-$1],
	       [enable $1 plugin])],
	[if $2; then
           enable_plugin_$1=$enableval
         else
           if test "x$enableval" = "xyes"; then
             AC_MSG_ERROR($1 not found)
           else
             enable_plugin_$1=no
           fi
        fi],
	[if $2; then enable_plugin_$1=yes; else enable_plugin_$1=no; fi])
    AC_SUBST([SRPMIX_ENABLE_PLUGIN_$1],$enable_plugin_$1)
    AM_CONDITIONAL([SRPMIX_ENABLE_PLUGIN_$1], [test "x$enable_plugin_$1" = "xyes"])
    AC_MSG_RESULT([$enable_plugin_$1])
])

AC_DEFUN([SRPMIX_ENABLE_PLUGIN_ETAGS],[
    AC_CHECK_PROGS([ETAGS], [etags])
    SRPMIX_ENABLE_PLUGIN(etags, [test "x$ETAGS" != "x"])
])

AC_DEFUN([SRPMIX_ENABLE_PLUGIN_CTAGS],[
    AC_CHECK_PROGS([CTAGS], [ctags])
    SRPMIX_ENABLE_PLUGIN(ctags, [test "x$CTAGS" != "x"])
])

AC_DEFUN([SRPMIX_ENABLE_PLUGIN_CSCOPE],[
    AC_CHECK_PROGS([CSCOPE], [cscope])
    SRPMIX_ENABLE_PLUGIN(cscope, [test "x$CSCOPE" != "x"])
])

AC_DEFUN([SRPMIX_ENABLE_PLUGIN_DOXYGEN],[
    AC_CHECK_PROGS([DOXYGEN], [doxygen])
    SRPMIX_ENABLE_PLUGIN(doxygen, [test "x$DOXYGEN" != "x"])
])

