EXTRA_DIST = \
	\
	svnweb+jbossas.txt \
	\
	$(NULL)

dist_check_SCRIPTS = \
	\
	svnweb+jbossas.sh
	\
	$(NULL)

TESTS_ENVIRONMENT = \
	top_builddir=$(top_builddir) \
	\
	$(_BASH_) -x

TESTS = $(dist_check_SCRIPTS)
