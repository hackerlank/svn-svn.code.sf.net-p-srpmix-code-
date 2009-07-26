EXTRA_DIST = test-srpmix-0-0.fc11.src.rpm test-srpmix.c test-srpmix.SPEC
dist_check_SCRIPTS = \
                     00distmap.sh      \
                     00srpmix-wrap.sh  \
                     00srpmix-ix.sh    \
                     01srpmix-ix.sh    \
                     00srpmix.sh       \
                     00build-opt-rules \
                     \
		     $(NULL)


TEST_SRPMS = @TEST_SRPMS@ $(srcdir)/test-srpmix-0-0.fc11.src.rpm
TESTDIR = data

TESTS_ENVIRONMENT =							\
        DEBUG=$(DEBUG)                                                  \
	TESTDIR=$(TESTDIR)						\
	TEST_SRPMS='$(TEST_SRPMS)'					\
	top_builddir=$(top_builddir)					\
        top_srcdir=$(top_srcdir)                                        \
	SRPMIX_PLUGIN_DIR=`pwd`/$(TESTDIR)/${pkgdatadir}/plugins	\
	SRPMIX_VAR_DIR=`pwd`/$(TESTDIR)/${localstatedir}/lib/@PACKAGE@	\
        SRPMIX_USR_DIR=`pwd`/$(TESTDIR)/${datadir}/@PACKAGE@		\
        SRPMIX_SYSCONF_DIR=`pwd`/$(TESTDIR)/${sysconfdir}/@PACKAGE@     \
	bindir=$(bindir)                                                \
	$(SHELL) -x
TESTS = $(dist_check_SCRIPTS)

clean-local:
	/bin/rm -rf data

