SUBDIRS = plugins helpers

bin_SCRIPTS=libsrpmix.sh
CLEANFILES = $(bin_SCRIPTS)

dist_bin_SCRIPTS =           \
        srpmix               \
	\
	srpmix-build         \
	\
	srpmix-ix            \
	\
	srpmix-wrap          \
	\
	srpmix-db            \
	\
	srpmix-envelop       \
        \
	srpmix-weakview-dist			\
	srpmix-weakview-packages		\
	\
	srpmix-plugin                           \
	\
        $(NULL)

srpmixconfdir=$(sysconfdir)/srpmix
dist_srpmixconf_DATA = srpmix.cf

crondailydir=$(sysconfdir)/cron.daily
dist_crondaily_SCRIPTS = srpmix.daily

macrosdir=$(sysconfdir)/rpm
dist_macros_DATA = macros.srpmix

