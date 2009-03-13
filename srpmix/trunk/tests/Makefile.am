dist_check_SCRIPTS = 00srpmix-wrap.sh

TESTS_ENVIRONMENT = \
	TESTDIR=data \
	top_builddir=$(top_builddir) \
	bindir=$(bindir) \
	$(SHELL)
TESTS = 00srpmix-wrap.sh

clean-local:
	/bin/rm -rf data

