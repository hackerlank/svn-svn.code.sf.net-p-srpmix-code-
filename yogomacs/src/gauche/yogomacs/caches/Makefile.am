moduledir=@GAUCHE_MODULEDIR@/yogomacs/caches
dist_module_DATA =   \
	\
	css.scm    \
	js.scm     \
	shtml.scm  \
	yarn.scm   \
        \
	$(NULL)


csscachedir=$(localstatedir)/lib/yogomacs/@SPEC_CONFIG@/css
dist_csscache_DATA= \
	file-font-lock--Default.css		\
	file-font-lock--Invert.css		\
	dired-font-lock--Default.css		\
	dired-font-lock--Invert.css		\
	yogomacs--Default.css			\
	yogomacs--Invert.css			\
	yarn--Default.css			\
	yarn--Invert.css                        \
	\
	$(NULL)

jscachedir=$(localstatedir)/lib/yogomacs/js
dist_jscache_DATA = \
	biwascheme.js       \
	prototype.js        \
	yogomacs_builtin.js \
	\
	$(NULL)
install-exec-hook:
	mkdir -p $(DESTDIR)$(jscachedir)
	for x in runtime.js runtime_callcc.js runtime_interface.js runtime_interface_callcc.js; do \
		$(LN_S) @SCHEME2JS_RUNTIME_DIR@/$$x $(DESTDIR)$(jscachedir)/scheme2js_$$x; \
        done
EXTRA_DIST = yogomacs-builtin.scm yogomacs-macs.scm
yogomacs_builtin.scm: yogomacs-macs.scm yogomacs-builtin.scm
	cat $^ > $@ 
yogomacs_builtin.js: yogomacs_builtin.scm
	@SCHEME2JS@ -o $@ $<
	rm $<

macrodir=$(pkgdatadir)/scheme2js
dist_macro_DATA = yogomacs-macs.scm

shtmlcachedir=$(localstatedir)/cache/yogomacs/shtml
dist_shtmlcache_DATA=

EXTRA_DIST += stitch.es
yarncachedir=$(localstatedir)/lib/yogomacs/yarn
dist_yarncache_DATA = 
