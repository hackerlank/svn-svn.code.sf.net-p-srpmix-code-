dist_check_SCRIPTS = 00srpmix-wrap.sh 00srpmix-ix.sh

TESTS_ENVIRONMENT = \
	TESTDIR=data \
	top_builddir=$(top_builddir) \
	bindir=$(bindir) \
	$(SHELL) -x
TESTS = $(dist_check_SCRIPTS)

clean-local:
	/bin/rm -rf data

