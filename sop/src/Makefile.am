SUBDIRS  = .
SUBDIRS += cron mirror.d 

sopconfdir=$(sysconfdir)/sop
dist_sopconf_DATA = sop.cf

dist_pkgdata_SCRIPTS= \
	mirror-ftp    \
	mirror-koji   \
	mirror-user   \
	\
	$(NULL)

dist_bin_SCRIPTS =				\
	sop-repofile				\
	sop-update				\
	sop-mummify				\
	\
	$(NULL)