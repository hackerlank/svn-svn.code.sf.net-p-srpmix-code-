httpdconfdir	= @sysconfdir@/httpd/conf.d

EXTRA_DIST = yogomacs.conf
dist_httpdconf_DATA = yogomacs-@SPEC_CONFIG@.conf
yogomacs-@SPEC_CONFIG@.conf: yogomacs.conf
	cp yogomacs.conf yogomacs-@SPEC_CONFIG@.conf

