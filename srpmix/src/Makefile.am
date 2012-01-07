SUBDIRS = plugins weakview-dist-plugins helpers

bin_SCRIPTS=libsrpmix.sh
CLEANFILES = $(bin_SCRIPTS)

dist_bin_SCRIPTS =           \
        srpmix               \
	\
	srpmix-build         \
	\
	srpmix-ix            \
	srpmix-mock          \
	\
	srpmix-wrap          \
	\
	srpmix-db            \
	\
	srpmix-envelop       \
	\
	srpmix-dir-pkg       \
        \
	srpmix-weakview-dist			\
	srpmix-weakview-packages		\
	srpmix-weakview-alias		        \
	\
	srpmix-plugin                           \
	srpmix-package-attach                   \
	\
	srpmix-weakview-dist-attach             \
	\
	srpmix-rootdir-attach                   \
	\
        $(NULL)

srpmixconfdir=$(sysconfdir)/srpmix
dist_srpmixconf_DATA = srpmix.cf

crondailydir=$(sysconfdir)/cron.daily
dist_crondaily_SCRIPTS = srpmix.daily

macrosdir=$(sysconfdir)/rpm
dist_macros_DATA = macros.srpmix

