EXTRA_DIST = test-srpmix-0-0.fc11.src.rpm test-srpmix.c test-srpmix.SPEC
dist_check_SCRIPTS = \
                     00distmap.sh		\
                     00srpmix-wrap.sh		\
                     00srpmix-ix.sh		\
                     01srpmix-ix.sh		\
                     00srpmix.sh		\
                     00build-opt-rules		\
                     00srpmix-plugin.sh		\
                     \
		     $(NULL)


# TEST_SRPMS = @TEST_SRPMS@ $(srcdir)/test-srpmix-0-0.fc11.src.rpm
TEST_SRPMS = @TEST_SRPMS@
TESTDIR = data

TESTS_ENVIRONMENT =							\
        DEBUG=$(DEBUG)                                                  \
	TESTDIR=$(TESTDIR)						\
	TEST_SRPMS='$(TEST_SRPMS)'					\
	top_builddir=$(top_builddir)					\
        abs_top_srcdir=$(abs_top_srcdir)                                \
	SRPMIX_PLUGIN_DIR=`pwd`/$(TESTDIR)/${pkgdatadir}/plugins	\
	SRPMIX_VAR_DIR=`pwd`/$(TESTDIR)/${localstatedir}/lib/@PACKAGE@	\
        SRPMIX_USR_DIR=`pwd`/$(TESTDIR)/${datadir}/@PACKAGE@		\
        SRPMIX_SYSCONF_DIR=`pwd`/$(TESTDIR)/${sysconfdir}/@PACKAGE@     \
	bindir=$(bindir)                                                \
	$(NULL)

LOG_COMPILER = bash

TESTS = $(dist_check_SCRIPTS)

clean-local:
	/bin/rm -rf data

