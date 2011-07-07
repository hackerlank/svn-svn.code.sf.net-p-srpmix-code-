GENERATED=srpmix.spec 
DISTCLEANFILES = $(GENERATED)


XSPECS=srpmix.spec 
XSPECS_INPUT_PREFIX=$(srcdir)/
XSPECS_OUTPUT_PREFIX=$(distdir)/

include $(top_srcdir)/misc/makefiles/xspecs.mk


dist-hook: xspecs
	for x in srpmix.spec; do \
		$(install_sh) $(srcdir)/$${x}.in $(distdir)/$${x}.in; \
	done
