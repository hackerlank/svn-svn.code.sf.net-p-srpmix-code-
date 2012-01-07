.PHONY: rpm srpm

include $(top_srcdir)/misc/makefiles/xspecs.mk

srpm: distcheck xspecs
	$(mkinstalldirs) build/{SPECS,RPMS,BUILD,SRPMS}
	rpmbuild --define "_topdir `pwd`/build" -ts $(DIST_ARCHIVES)
	for x in $(XSPECS); do                               \
		rpmbuild --define "_topdir `pwd`/build" -bs ${x}; \
	done


rpm: distcheck xspecs
	$(mkinstalldirs) build/{SPECS,RPMS,BUILD,SRPMS}
	rpmbuild --define "_topdir `pwd`/build" -ta $(DIST_ARCHIVES)
	for x in $(XSPECS); do                               \
		rpmbuild --define "_topdir `pwd`/build" -ba $(XSPEC_INPUT_PREFIX)$${x}; \
	done

clean-local::
	/bin/rm -rf build
