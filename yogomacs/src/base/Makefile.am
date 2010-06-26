pkglibexecdir = @libexecdir@/yogomacs
dist_pkglibexec_SCRIPTS = yogomacs.cgi

symlink_srcs = $(pkglibexecdir)/yogomacs.cgi

install-exec-hook:
	cd $(DESTDIR)@WWWDIR@ && mkdir cgi-bin && cd cgi-bin \
	&& for f in $(symlink_srcs); do $(LN_S) $$f ./; done
