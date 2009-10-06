SUBDIRS  = .
SUBDIRS += builders

sbuildconfdir=$(sysconfdir)/sbuild
dist_sbuildconf_DATA = sbuild.cf

dist_bin_SCRIPTS=    \
	sbuild       \
	\
	$(NULL)

dist_pkgdata_SCRIPTS=				\
	sbuild-createrepo.mk			\
	srpmix.mk				\
	gc-repo-srpmix-version.scm		\
	gc-repo-pkg-version.scm			\
	create-comps.scm                        \
	\
	$(NULL)
