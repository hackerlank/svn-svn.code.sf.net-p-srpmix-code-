SUBDIRS  = .
SUBDIRS += cron cradle-confs dist-mapping

sopconfdir=$(sysconfdir)/sop
dist_sopconf_DATA = sop.cf

dist_pkgdata_SCRIPTS= \
	mirror-wget   \
	mirror-koji   \
	mirror-user   \
	mirror-yum    \
	mirror-lcopy-sys \
	\
	$(NULL)

dist_bin_SCRIPTS =				\
	sop-update				\
	sop-mummify				\
	sop-prepare				\
	\
	$(NULL)
