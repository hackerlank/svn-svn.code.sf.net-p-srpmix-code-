DISTCLEANFILES = srpmix.spec srpmix-dir-base.SPEC

if USE_SVN_RPM_RELEASE
R = @RPM_RELEASE@svn$(shell LANG=C @SVN@ info | grep Revision | cut -d" " -f2)
else
R = 0
endif

dist-hook:
	for x in srpmix.spec srpmix-dir-base.SPEC; do \
	sed -e 's/#RPM_RELEASE#/$(R)/' \
		-e 's/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/' \
		 < $(srcdir)/$${x}.in \
		 > $(distdir)/$${x}; \
	install $(srcdir)/$${x}.in $(distdir)/$${x}.in; \
	done
