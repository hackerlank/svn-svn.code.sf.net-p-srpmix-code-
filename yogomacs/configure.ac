m4_define([pkg_name], [yogomacs])
m4_define([pkg_version], [0.0.19])

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


AC_PROG_LN_S
dnl PKG_PROG_PKG_CONFIG
AC_RPM_RELEASE

m4_define([vhost_docroot_default],[/srv/www])
m4_define([wwwdir_default],[vhost_docroot_default/yogomacs])
AC_ARG_WITH([wwwdir],
  AS_HELP_STRING([--with-wwwdir=WWWDIR],[WWW data topdir. 
                  @<:@default=wwwdir_default@:>@]),
     wwwdir=$with_wwwdir,
     wwwdir=wwwdir_default)
AC_SUBST([WWWDIR],[$wwwdir])
args_for_configure_in_spec="${args_for_configure_in_spec} --with-wwwdir=$wwwdir"



AC_ARG_ENABLE([vhost],
   [AS_HELP_STRING([--enable-vhost],[Add vhost configuration to httpd configuration file.])])
if test x"$enable_vhost" = xno; then
   args_for_configure_in_spec="${args_for_configure_in_spec} --enable-vhost=no"
fi


m4_define([vhost_servername_default],[yogomacs.com])
AC_ARG_WITH([vhost_servername],
	AS_HELP_STRING([--with-vhost-servername=NAME],
                        [Value for ServerName in VirutalHost section of httpd.conf. 
                         Used only if --enable-vhost is yes. 
                         @<:@default=vhost_servername_default@:>@]),
        vhost_servername=$with_vhost_servername,
        vhost_servername=vhost_servername_default)
AC_SUBST([VHOST_SERVERNAME], [$vhost_servername])
args_for_configure_in_spec="${args_for_configure_in_spec} --with-vhost-servername=$vhost_servername"


m4_define([vhost_port_default],[80])
AC_ARG_WITH([vhost_port],
	AS_HELP_STRING([--with-vhost-port=PORT],
                        [Port number in VirtualHost secion in httpd.conf. 
                         Used only if --enable-vhost is yes. 
                         @<:@default=vhost_port_default@:>@]),
        vhost_port=$with_vhost_port,
	vhost_port=vhost_port_default)
AC_SUBST([VHOST_PORT], [$vhost_port])
args_for_configure_in_spec="${args_for_configure_in_spec} --with-vhost-port=$vhost_port"


AC_ARG_WITH([vhost_docroot],
	AS_HELP_STRING([--with-vhost-docroot=DIR],
                        [Value for DocumentRoot in VirtualHost secion in httpd.conf. 
                         Used only if --enable-vhost is yes. 
                         @<:@default=vhost_docroot_default@:>@]),
        vhost_docroot=$with_vhost_docroot,
	vhost_docroot=vhost_docroot_default)
AC_SUBST([VHOST_DOCROOT], [$vhost_docroot])
args_for_configure_in_spec="${args_for_configure_in_spec} --with-vhost-docroot=$vhost_docroot"

AC_SUBST_FILE([core_conf])
core_conf=$srcdir/misc/httpd/core.conf

AC_SUBST_FILE([vhost_conf])
if test x"$enable_vhost" = x"no"; then
   vhost_conf=$srcdir/misc/httpd/core.conf
else
   vhost_conf=$srcdir/misc/httpd/vhost.conf
fi


config_name=default
AC_ARG_WITH([config_name],
	AS_HELP_STRING([--with-config-name=CONFIG],
	               [Configuration name used as part of rpm package named.]),
	    config_name=$with_config_name)
args_for_configure_in_spec="${args_for_configure_in_spec} --with-config-name=$config_name"


AC_SUBST([ARGS_FOR_CONFIGURE_IN_SPEC], [$args_for_configure_in_spec])
AC_SUBST([SPEC_CONFIG], [$config_name])


AC_CHECK_PROG(SCHEME2JS,scheme2js,scheme2js,no)
if test "$SCHEME2JS" = no; then
   if test -f /usr/bin/scheme2js; then
      AC_MSG_ERROR([Cannot find scheme2js compiler.
If you got this error though you have installed scheme2js package,
you may have to do "chmod a+x /usr/bin/scheme2js".
See http://bugzilla.redhat.com/show_bug.cgi?id=658812.])
   else
      AC_MSG_ERROR([Cannot find scheme2js compiler])
   fi
fi

AC_SUBST([SCHEME2JS])

scheme2js_runtime_dir="/usr/share/scheme2js"
AC_ARG_WITH([scheme2js_runtime_dir],
	    AS_HELP_STRING([--with-scheme2js-runtime-dir=DIR],
	                   [Directory where scheme2js runtime files are.]),
            scheme2js_runtime_dir=$with_scheme2js_runtime_dir)

for f in runtime.js \
         runtime_callcc.js \
         runtime_interface.js \
	 runtime_interface_callcc.js; do
    AC_CHECK_FILE($scheme2js_runtime_dir/$f,, AC_MSG_ERROR([Cannot find $f scheme2js runtime file]))
done

AC_SUBST([SCHEME2JS_RUNTIME_DIR], [$scheme2js_runtime_dir])


AC_CONFIG_COMMANDS([chmod],[
chmod 0755 src/cmds/*
chmod 0755 tests/*.scm
])

AC_OUTPUT([
           Makefile
	   src/Makefile
	   src/css/Makefile
	   src/cmds/Makefile
	   src/elisp/Makefile
	   src/elisp/flserver/Makefile
	   src/elisp/flserver/yogomacs.el
	   src/elisp/flserver/plugins/Makefile
	   src/gauche/Makefile
	   src/gauche/yogomacs/Makefile
	   src/gauche/yogomacs/caches/Makefile
	   src/gauche/yogomacs/commands/Makefile
	   src/gauche/yogomacs/config.scm
	   src/gauche/yogomacs/default.scm
	   src/gauche/yogomacs/dentries/Makefile
	   src/gauche/yogomacs/dests/Makefile
	   src/gauche/yogomacs/overlays/Makefile
	   src/gauche/yogomacs/rearranges/Makefile
	   src/gauche/yogomacs/renderers/Makefile
	   src/gauche/yogomacs/shells/Makefile
	   src/gauche/yogomacs/storages/Makefile
	   src/gauche/yogomacs/util/Makefile
	   src/gauche/yogomacs/reels/Makefile
	   src/gauche/yogomacs/tags/Makefile
	   src/base/Makefile
	   src/data/Makefile
	   src/js/Makefile
	   src/apache-home/Makefile
	   misc/Makefile
	   misc/ac-aux/Makefile
	   misc/m4/Makefile
	   misc/specs/Makefile
	   misc/specs/yogomacs.spec
	   misc/makefiles/Makefile
	   misc/httpd/Makefile
	   misc/httpd/core.conf
	   misc/httpd/vhost.conf
	   misc/httpd/yogomacs.conf
	   tests/Makefile
	   ])
