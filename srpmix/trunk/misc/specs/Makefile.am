DISTCLEANFILES = srpmix.spec

if USE_SVN_RPM_RELEASE
R = @RPM_RELEASE@svn$(shell LANG=C @SVN@ info | grep Revision | cut -d" " -f2)
else
R = 0
endif

dist-hook:
	sed -e 's/#RPM_RELEASE#/$(R)/' \
		-e 's/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/' \
		 < $(srcdir)/srpmix.spec.in \
		 > $(distdir)/srpmix.spec
	install $(srcdir)/srpmix.spec.in $(distdir)/srpmix.spec.in
