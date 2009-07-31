GENERATED=srpmix.spec srpmix-dir-base.SPEC
DISTCLEANFILES = $(GENERATED)


XSPECS=srpmix.spec srpmix-dir-base.SPEC
XSPECS_INPUT_PREFIX=$(srcdir)/
XSPECS_OUTPUT_PREFIX=$(distdir)/

include $(top_srcdir)/misc/makefiles/xspecs.mk


dist-hook: xspecs
	for x in srpmix.spec srpmix-dir-base.SPEC; do \
		$(install_sh) $(srcdir)/$${x}.in $(distdir)/$${x}.in; \
	done
