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

#       SPEC->sepc:
#	The original spec file has SPEC(upper case) as suffix. src.rpm including such
#	spec file is rejected by mock. To embed spec file which has spec(lower case)
#	as suffix, use temporary spec file.

	for x in $(XSPECS); do                               \
		y=$$(echo $${x} | tr 'SPEC' 'spec');         \
		cp $(XSPEC_INPUT_PREFIX)$${x} $(XSPEC_INPUT_PREFIX)$${y}; \
		rpmbuild --define "_topdir `pwd`/build" -ba $(XSPEC_INPUT_PREFIX)$${y}; \
		rm $(XSPEC_INPUT_PREFIX)$${y}; \
	done

clean-local::
	/bin/rm -rf build
