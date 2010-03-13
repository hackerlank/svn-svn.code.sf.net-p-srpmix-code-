pkglibexecdir = @libexecdir@/webperg
dist_pkglibexec_SCRIPTS = webperg.cgi 
symlink_srcs = $(pkglibexecdir)/webperg.cgi

dist_bin_SCRIPTS = \
	mperg->html \
	\
	$(NULL)

moduledir=@GAUCHE_MODULEDIR@
dist_module_DATA =   \
	mperg->html.scm \
        \
	$(NULL)

install-exec-hook:
	cd $(DESTDIR)@WWWDIR@ && for f in $(symlink_srcs); do $(LN_S) $$f ./; done
