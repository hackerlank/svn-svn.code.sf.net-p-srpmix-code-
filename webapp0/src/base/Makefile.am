pkglibexecdir = @libexecdir@/%PKGNAME%
dist_pkglibexec_SCRIPTS = %PKGNAME%.cgi

symlink_srcs = $(pkglibexecdir)/%PKGNAME%.cgi

install-exec-hook:
	cd $(DESTDIR)@WWWDIR@ && for f in $(symlink_srcs); do $(LN_S) $$f ./; done
