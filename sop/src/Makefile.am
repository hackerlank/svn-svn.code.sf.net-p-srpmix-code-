SUBDIRS  = .
SUBDIRS += cron cradle-confs dist-mapping

sopconfdir=$(sysconfdir)/sop
dist_sopconf_DATA = sop.cf

dist_pkgdata_SCRIPTS= \
	mirror-wget   \
	mirror-koji   \
	mirror-user   \
	mirror-yum    \
	mirror-lcopy-sys    \
	mirror-lcopy-user   \
	\
	mirror-prelcopy-sys \
	\
	mirror-alias      \
	mirror-nop        \
	\
	\
	dist-map-nop      \
	dist-map-srpms    \
	dist-map-lcopy    \
	\
	$(NULL)

dist_bin_SCRIPTS =				\
	sop-update				\
	sop-mummify				\
	sop-prepare				\
	sop-mirror				\
	sop-garbages				\
	\
	$(NULL)
