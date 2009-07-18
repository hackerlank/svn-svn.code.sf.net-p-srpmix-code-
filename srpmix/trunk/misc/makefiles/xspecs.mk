include $(top_srcdir)/misc/makefiles/svn_release.mk

.PHONY: xspecs
xspecs: 
	for x in $(XSPECS); do \
		sed -e 's/#RPM_RELEASE#/$(SVN_RELEASE)/' \
		-e 's/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/' \
		 < $(XSPECS_INPUT_PREFIX)$${x}.in \
		 > $(XSPECS_OUTPUT_PREFIX)$${x};   \
	done

