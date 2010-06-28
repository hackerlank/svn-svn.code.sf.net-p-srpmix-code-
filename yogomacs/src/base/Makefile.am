pkglibexecdir = @libexecdir@/yogomacs
dist_pkglibexec_SCRIPTS = yogomacs.cgi

symlink_srcs = $(pkglibexecdir)/yogomacs.cgi

install-exec-hook:
	cd $(DESTDIR)@WWWDIR@ && mkdir cgi-bin && cd cgi-bin \
	&& $(LN_S) $(pkglibexecdir)/yogomacs.cgi ./yogomacs-@SPEC_CONFIG@.cgi
