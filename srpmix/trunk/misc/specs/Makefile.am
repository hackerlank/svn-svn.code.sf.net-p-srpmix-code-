RPM_RELEASE = @RPM_RELEASE@
DISTCLEANFILES = srpmix.spec

dist-hook:
	sed -e 's/#RPM_RELEASE#/$(RPM_RELEASE)/' \
		-e 's/#PACKAGE_VERSION#/$(PACKAGE_VERSION)/' \
		 < srpmix.spec.in \
		 > $(distdir)/srpmix.spec
	install srpmix.spec.in $(distdir)/srpmix.spec.in
