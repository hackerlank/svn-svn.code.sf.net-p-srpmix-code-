jscachedir=$(pkgdatadir)/js

yogomacs_input = \
	prototype.js        \
	proto.menu.js       \
	cookie.js           \
	yogomacs_runtime.js \
	\
	$(NULL)

dist_jscache_DATA = \
	\
	$(yogomacs_input) \
	\
	yogomacs-@VERSION@-@RPM_RELEASE@.js
	\
	$(NULL)

scheme2js_runtime = \
	runtime.js				\
        runtime_callcc.js			\
        runtime_interface.js			\
	runtime_interface_callcc.js             \
	\
	$(NULL)
install-data-hook:
	mkdir -p $(DESTDIR)$(jscachedir)
	for x in $(scheme2js_runtime); do \
		$(LN_S) @SCHEME2JS_RUNTIME_DIR@/$$x $(DESTDIR)$(jscachedir)/scheme2js_$$x; \
        done


copyright_input = \
	     scheme2js.copyright  \
	     prototype.copyright  \
	     proto.menu.copyright \
	     cookie.copyright     \
	     yogomacs.copyright   \
	     \
	     $(NULL)

EXTRA_DIST = yjsmin.pl \
	     $(copyright_input) \
	     \
	     $(NULL)

scheme2js_input = \
	yogomacs-macs.scm        \
	\
	utils.scm		 \
	dom.scm			 \
	sxml.scm		 \
	js.scm	                 \
	\
	decls.scm		 \
	\
	stitch.scm               \
	yarn.scm                 \
	tag.scm                  \
	\
	window.scm		 \
	\
	major-mode.scm           \
	fundamental-mode.scm     \
	\
	repl.scm                 \
	\
	main.scm		 \
	\
	$(NULL)

EXTRA_DIST += $(scheme2js_input)
yogomacs_runtime.scm: $(scheme2js_input)
	cat $^ > $@ 
yogomacs_runtime.js: yogomacs_runtime.scm
	@SCHEME2JS@ -g -o $@ $<

yogomacs-@VERSION@-@RPM_RELEASE@.js: @SCHEME2JS_RUNTIME_DIR@/runtime.js $(yogomacs_input)
	rm yogomacs-[0-9]*.js

	echo > $@

	cat scheme2js.copyright >> $@
	perl yjsmin.pl @SCHEME2JS_RUNTIME_DIR@/runtime.js \
	     "Converted from runtime.js of scheme2js" >> $@
	echo >> $@

	cat prototype.copyright >> $@
	perl yjsmin.pl prototype.js \
	     "Converted from prototype.js" >> $@
	echo >> $@

	cat proto.menu.copyright >> $@
	perl yjsmin.pl proto.menu.js \
	     "Converted from proto.menu.js" >> $@
	echo >> $@

	cat cookie.copyright >> $@
	perl yjsmin.pl cookie.js \
	     "Converted from cookie.js" >> $@
	echo >> $@

	echo >> $@
	cat yogomacs.copyright >> $@
#	perl yjsmin.pl yogomacs_runtime.js \
#	     "Converted from yogomacs_runtime.js" >> $@
	cat yogomacs_runtime.js >> $@
	echo >> $@


macrodir=$(pkgdatadir)/scheme2js
dist_macro_DATA = yogomacs-macs.scm

