SUBDIRS = plugins

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

dist_sysconf_DATA = srpmix.cf

crondailydir=$(sysconfdir)/cron.daily
dist_crondaily_SCRIPTS = srpmix.daily


helpersdir = $(pkgdatadir)/helpers
dist_helpers_SCRIPTS =   \
        build-opt-rules  \
	\
        $(NULL)

