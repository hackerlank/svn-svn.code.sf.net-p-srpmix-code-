.PHONY: rpm srpm

srpm: distcheck
	$(mkinstalldirs) build/{SPECS,RPMS,BUILD,SRPMS}
	rpmbuild --define "_topdir `pwd`/build" -ts $(DIST_ARCHIVES)
	rpmbuild --define "_topdir `pwd`/build" -bs misc/specs/srpmix-dir-base.SPEC

rpm: distcheck
	$(mkinstalldirs) build/{SPECS,RPMS,BUILD,SRPMS}
	rpmbuild --define "_topdir `pwd`/build" -ta $(DIST_ARCHIVES)
	rpmbuild --define "_topdir `pwd`/build" -ba misc/specs/srpmix-dir-base.SPEC

clean-local::
	/bin/rm -rf build
