SUBDIRS  = .
SUBDIRS += commands
SUBDIRS += dentries
SUBDIRS += dests
SUBDIRS += overlays
SUBDIRS += rearranges
SUBDIRS += renderers
SUBDIRS += shells
SUBDIRS += storages
SUBDIRS += util
SUBDIRS += reels
SUBDIRS += tags
## ---------------------
SUBDIRS += caches

moduledir=@GAUCHE_MODULEDIR@/yogomacs
dist_module_DATA =   \
	\
	access.scm				\
	auth.scm			        \
	batch.scm				\
	cache.scm				\
	command.scm				\
	config.scm				\
	dentry.scm				\
	domain.scm				\
	entry.scm				\
	error.scm				\
	face.scm				\
	flserver.scm				\
	main.scm				\
	overlay.scm				\
	overlays.scm				\
	params.scm				\
	path.scm				\
	reel.scm				\
	reply.scm				\
	role.scm				\
	route.scm				\
	sanitize.scm				\
	shell.scm				\
	shells.scm				\
	tag.scm					\
	tags.scm				\
	user.scm				\
	window.scm				\
	yarn.scm				\
        \
	$(NULL)

confdir=$(sysconfdir)/yogomacs
conf_DATA=


dist_noinst_DATA=default.scm
install-data-hook:
	install default.scm $(DESTDIR)$(sysconfdir)/yogomacs/@SPEC_CONFIG@.scm
