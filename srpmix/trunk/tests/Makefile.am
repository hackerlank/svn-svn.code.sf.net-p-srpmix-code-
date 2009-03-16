dist_check_SCRIPTS = 00srpmix-wrap.sh  \
                     00srpmix-ix.sh    \
                     00srpmix.sh       \
                     00build-opt-rules \
                     \
		     $(NULL)

TEST_SRPMS = @TEST_SRPMS@
TESTDIR = data

TESTS_ENVIRONMENT =							\
	TESTDIR=$(TESTDIR)						\
	TEST_SRPMS='$(TEST_SRPMS)'					\
	top_builddir=$(top_builddir)					\
	SRPMIX_PLUGIN_DIR=`pwd`/$(TESTDIR)/${pkgdatadir}/plugins	\
	SRPMIX_VAR_DIR=`pwd`/$(TESTDIR)/${localstatedir}/lib/@PACKAGE@	\
        SRPMIX_USR_DIR=`pwd`/$(TESTDIR)/${datadir}/@PACKAGE@		\
	bindir=$(bindir)                                                \
	$(SHELL) -x
TESTS = $(dist_check_SCRIPTS)

clean-local:
	/bin/rm -rf data

