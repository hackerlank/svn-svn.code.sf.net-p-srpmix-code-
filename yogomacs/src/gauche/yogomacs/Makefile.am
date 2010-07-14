SUBDIRS  = .
SUBDIRS += caches
SUBDIRS += dentries
SUBDIRS += dests
SUBDIRS += rearranges
SUBDIRS += renderers

moduledir=@GAUCHE_MODULEDIR@/yogomacs
dist_module_DATA =   \
	\
	access.scm   \
	batch.scm    \
	compress.scm \
	config.scm   \
	dentry.scm   \
	flserver.scm \
	main.scm     \
	path.scm     \
	fix.scm      \
	renderer.scm \
	route.scm    \
	sanitize.scm \
        \
	$(NULL)

confdir=$(sysconfdir)/yogomacs
conf_DATA=


dist_noinst_DATA=default.scm
install-data-hook:
	install default.scm $(DESTDIR)$(sysconfdir)/yogomacs/@SPEC_CONFIG@.scm
