.PHONY: rpm srpm

srpm: distcheck
	$(mkinstalldirs) build/{SPECS,RPMS,BUILD,SRPMS}
	rpmbuild --define "_topdir `pwd`/build" -ts $(DIST_ARCHIVES)

rpm: distcheck
	$(mkinstalldirs) build/{SPECS,RPMS,BUILD,SRPMS}
	rpmbuild --define "_topdir `pwd`/build" -ta $(DIST_ARCHIVES)

clean-local::
	/bin/rm -rf build
