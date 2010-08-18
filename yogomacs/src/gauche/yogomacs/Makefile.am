SUBDIRS  = .
SUBDIRS += caches
SUBDIRS += dentries
SUBDIRS += dests
SUBDIRS += rearranges
SUBDIRS += renderers
SUBDIRS += shells
SUBDIRS += util
SUBDIRS += yarns

moduledir=@GAUCHE_MODULEDIR@/yogomacs
dist_module_DATA =   \
	\
	access.scm				\
	batch.scm				\
	cache.scm				\
	config.scm				\
	dentry.scm				\
	domain.scm				\
	entry.scm				\
	error.scm				\
	face.scm				\
	flserver.scm				\
	main.scm				\
	params.scm				\
	path.scm				\
	reply.scm				\
	route.scm				\
	sanitize.scm				\
	shell.scm				\
	window.scm				\
	yarn.scm				\
        \
	$(NULL)

confdir=$(sysconfdir)/yogomacs
conf_DATA=


dist_noinst_DATA=default.scm
install-data-hook:
	install default.scm $(DESTDIR)$(sysconfdir)/yogomacs/@SPEC_CONFIG@.scm
