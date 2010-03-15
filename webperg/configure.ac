AC_INIT([webperg], [0.1.0])
AC_CONFIG_AUX_DIR([misc/ac-aux])
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AC_CONFIG_MACRO_DIR([misc/m4])

AC_PROG_LN_S
PKG_PROG_PKG_CONFIG
AC_RPM_RELEASE

AC_GAUCHE_INIT_EXT
GAUCHE_MODULEDIR=`$GAUCHE_CONFIG --sitelibdir`
AC_SUBST(GAUCHE_MODULEDIR)


args_for_configure_in_spec=""



m4_define([vhost_docroot_default],[/srv/www])
m4_define([wwwdir_default],[vhost_docroot_default/webperg])
AC_ARG_WITH([wwwdir],
  AS_HELP_STRING([--with-wwwdir=WWWDIR],[WWW data topdir. 
                  @<:@default=wwwdir_default@:>@]),
     wwwdir=$with_wwwdir,
     wwwdir=wwwdir_default)
AC_SUBST([WWWDIR],[$wwwdir])
args_for_configure_in_spec="${args_for_configure_in_spec} --with-wwwdir=$wwwdir"



AC_ARG_WITH([srcview],
  AS_HELP_STRING([--with-srcview=srcview],[srcview cgi path]),
  srcview=$with_srcview,
  AC_MSG_ERROR([No srcview is given]))
AC_SUBST([SRCVIEW],[$srcview])
args_for_configure_in_spec="${args_for_configure_in_spec} --with-srcview='$srcview'"

AC_ARG_ENABLE([vhost],
   [AS_HELP_STRING([--enable-vhost],[Add vhost configuration to httpd configuration file.])])
if test x"$enable_vhost" = xno; then
   args_for_configure_in_spec="${args_for_configure_in_spec} --enable-vhost=no"
fi

m4_define([vhost_servername_default],[webperg.com])
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


AC_SUBST_FILE([vhost_conf])
if test x"$enable_vhost" = x"no"; then
   vhost_conf=/dev/null
else
   vhost_conf=$srcdir/misc/httpd/vhost.conf
fi


config_name=default
AC_ARG_WITH([config_name],
	AS_HELP_STRING([--with-config-name=CONFIG],
	               [Configuration name used as part of rpm package named.]),
	    config_name=$with_config_name)


AC_SUBST([ARGS_FOR_CONFIGURE_IN_SPEC], [$args_for_configure_in_spec])
AC_SUBST([SPEC_CONFIG], [$config_name])


AC_OUTPUT([
	   Makefile
	   src/Makefile
	   src/base/Makefile
	   src/base/webperg.cgi
	   src/data/Makefile
	   misc/Makefile
	   misc/ac-aux/Makefile
	   misc/m4/Makefile
	   misc/specs/Makefile
	   misc/specs/webperg.spec
	   misc/makefiles/Makefile
	   misc/pkgconfig/Makefile
	   misc/pkgconfig/webperg.pc
	   misc/httpd/Makefile
	   misc/httpd/vhost.conf
	   misc/httpd/webperg.conf
	   tests/Makefile
	  ])


