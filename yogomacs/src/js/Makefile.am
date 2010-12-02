jscachedir=$(localstatedir)/lib/yogomacs/js
dist_jscache_DATA = \
	biwascheme.js       \
	prototype.js        \
	proto.menu.js	    \
	yogomacs_builtin.js \
	\
	scriptaculous.js    \
	builder.js          \
        effects.js          \
        dragdrop.js         \
        controls.js         \
        slider.js           \
	\
	$(NULL)

scheme2js_runtime = \
	runtime.js				\
        runtime_callcc.js			\
        runtime_interface.js			\
	runtime_interface_callcc.js             \
	\
	$(NULL)
install-exec-hook:
	mkdir -p $(DESTDIR)$(jscachedir)
	for x in $(scheme2js_runtime); do \
		$(LN_S) @SCHEME2JS_RUNTIME_DIR@/$$x $(DESTDIR)$(jscachedir)/scheme2js_$$x; \
        done


EXTRA_DIST =


scheme2js_input = \
	yogomacs-macs.scm        \
	yogomacs-util.scm        \
	yogomacs-web.scm         \
	yogomacs-js.scm	         \
	yogomacs-bscm.scm        \
	yogomacs-hook-def.scm    \
	yogomacs-menu.scm	 \
	yogomacs-full-screen.scm \
	yogomacs-builtin.scm     \
	yogomacs-repl.scm        \
	yogomacs-stitch.scm      \
	yogomacs-fringe.scm      \
	yogomacs-hook-setup.scm  \
	\
	$(NULL)

EXTRA_DIST += $(scheme2js_input)
yogomacs_builtin.scm: $(scheme2js_input)
	cat $^ > $@ 
yogomacs_builtin.js: yogomacs_builtin.scm
	@SCHEME2JS@ -o $@ $<
	rm $<

macrodir=$(pkgdatadir)/scheme2js
dist_macro_DATA = yogomacs-macs.scm

