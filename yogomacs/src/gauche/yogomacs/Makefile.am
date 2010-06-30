SUBDIRS  = .
SUBDIRS += dentries
SUBDIRS += dests
SUBDIRS += renderers

moduledir=@GAUCHE_MODULEDIR@/yogomacs
dist_module_DATA =   \
	\
	access.scm   \
	config.scm   \
	css-cache.scm \
	dentry.scm   \
	flserver.scm \
	main.scm     \
	path.scm     \
	render.scm   \
	route.scm    \
	sanitize.scm \
        \
	$(NULL)

confdir=$(sysconfdir)/yogomacs
conf_DATA=


dist_noinst_DATA=default.scm
install-data-hook:
	install default.scm $(DESTDIR)$(sysconfdir)/yogomacs/@SPEC_CONFIG@.scm

csscachedir=$(localstatedir)/lib/yogomacs/@SPEC_CONFIG@/css_cache
csscache_DATA=
