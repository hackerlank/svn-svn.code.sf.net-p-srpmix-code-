DISTCLEANFILES = srpmix.spec

if USE_SVN_RPM_RELEASE
RPM_RELEASE = 0svn$(shell LANG=C @SVN@ info | grep Revision | cut -d" " -f2)
else
RPM_RELEASE = 0
endif

dist-hook:
	sed -e 's/#RPM_RELEASE#/$(RPM_RELEASE)/' \
		-e 's/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/' \
		 < $(srcdir)/srpmix.spec.in \
		 > $(distdir)/srpmix.spec
	install $(srcdir)/srpmix.spec.in $(distdir)/srpmix.spec.in
