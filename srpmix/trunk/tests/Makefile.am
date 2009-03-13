dist_check_SCRIPTS = 00srpmix-wrap.sh 00srpmix-ix.sh
TEST_SRPMS = @TEST_SRPMS@

TESTS_ENVIRONMENT = \
	TESTDIR=data \
	TEST_SRPMS='$(TEST_SRPMS)' \
	top_builddir=$(top_builddir) \
	bindir=$(bindir) \
	$(SHELL) -x
TESTS = $(dist_check_SCRIPTS)


clean-local:
	/bin/rm -rf data

