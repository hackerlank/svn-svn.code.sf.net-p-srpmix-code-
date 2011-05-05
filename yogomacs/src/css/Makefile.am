cssdir=$(pkgdatadir)/css
css_static= \
	file-font-lock--Default.css		\
	file-font-lock--Invert.css		\
	dired-font-lock--Default.css		\
	dired-font-lock--Invert.css		\
	proto.menu--Common.css			\
	yogomacs--Default.css			\
	yogomacs--Invert.css			\
	yarn--Default.css			\
	yarn--Invert.css                        \
	tag--Default.css			\
	tag--Invert.css                        \
	\
	$(NULL)

dist_css_DATA= $(css_static)



csscachedir=$(localstatedir)/lib/yogomacs/css/@SPEC_CONFIG@
dist_csscache_DATA=
install-data-hook:
	mkdir -p $(DESTDIR)$(localstatedir)/lib/yogomacs/css/@SPEC_CONFIG@
	for x in $(css_static); do \
		$(LN_S) $(pkgdatadir)/css/$$x \
                        $(DESTDIR)$(localstatedir)/lib/yogomacs/css/@SPEC_CONFIG@; \
	done

