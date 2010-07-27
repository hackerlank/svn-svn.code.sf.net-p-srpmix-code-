SUBDIRS  = .
SUBDIRS += caches
SUBDIRS += dentries
SUBDIRS += dests
SUBDIRS += rearranges
SUBDIRS += renderers
SUBDIRS += shells

moduledir=@GAUCHE_MODULEDIR@/yogomacs
dist_module_DATA =   \
	\
	access.scm				\
	batch.scm				\
	cache.scm				\
	compress.scm				\
	config.scm				\
	dentry.scm				\
	error.scm				\
	face.scm				\
	flserver.scm				\
	main.scm				\
	path.scm				\
	reply.scm				\
	route.scm				\
	sanitize.scm				\
	scheme2js.scm				\
	shell.scm				\
        \
	$(NULL)

confdir=$(sysconfdir)/yogomacs
conf_DATA=


dist_noinst_DATA=default.scm
install-data-hook:
	install default.scm $(DESTDIR)$(sysconfdir)/yogomacs/@SPEC_CONFIG@.scm
