pkglibexecdir = @libexecdir@/webperg
dist_pkglibexec_SCRIPTS = webperg.cgi mperg list-srpmnames-by-file.sh
symlink_srcs = $(pkglibexecdir)/webperg.cgi

install-exec-hook:
	cd $(DESTDIR)@WWWDIR@ && for f in $(symlink_srcs); do $(LN_S) $$f ./; done
