.PHONY: rpm
rpm: dist
	rpmbuild -ta $(DIST_ARCHIVES)
