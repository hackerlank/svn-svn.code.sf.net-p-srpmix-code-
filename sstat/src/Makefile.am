dist_pkgdata_SCRIPTS =  \
	\
	sstat.stp     \
	sstat-pre.scm \
	sstat-post.scm \
	\
	$(NULL)

dist_sbin_SCRIPTS       =  \
	\
	sstat-pre     \
	sstat-post    \
	\
	$(NULL)


sstatconfdir=$(sysconfdir)/sstat
dist_sstatconf_DATA = \
	sstat.cf \
	mapping.es \
	\
	$(NULL)

sstatstaterundir=${localstatedir}/run/sstat-pre
sstatstaterun_DATA=


crondailydir=$(sysconfdir)/cron.hourly
dist_crondaily_SCRIPTS = \
	\
	sstat-post.cron \
	\
	$(NULL)
