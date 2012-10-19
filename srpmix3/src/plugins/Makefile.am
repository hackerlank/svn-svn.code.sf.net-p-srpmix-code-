plugindir = $(pkgdatadir)/plugins

EXTRA_DIST = \
	60srpmix-etags			        \
	60srpmix-ctags				\
	60srpmix-cscope				\
	60srpmix-doxygen			\
	60srpmix-xgettext                       \
	60srpmix-nctags				\
	\
	_60srpmix-hyperestraier                 \
	\
	$(NULL)

plugin_SCRIPTS =

if SRPMIX_ENABLE_PLUGIN_etags
plugin_SCRIPTS += 60srpmix-etags
endif

if SRPMIX_ENABLE_PLUGIN_ctags
plugin_SCRIPTS += 60srpmix-ctags
plugin_SCRIPTS += _60srpmix-nctags
endif

if SRPMIX_ENABLE_PLUGIN_cscope
plugin_SCRIPTS += 60srpmix-cscope
endif

if SRPMIX_ENABLE_PLUGIN_doxygen
plugin_SCRIPTS += 60srpmix-doxygen
endif

if SRPMIX_ENABLE_PLUGIN_hyperestraier
plugin_SCRIPTS += _60srpmix-hyperestraier
endif

if SRPMIX_ENABLE_PLUGIN_xgettext
plugin_SCRIPTS += 60srpmix-xgettext
endif

dist_plugin_SCRIPTS = \
        10srpmix-vanilla      \
	50srpmix-coreutils   \
	50srpmix-file        \
        60srpmix-kindex      \
	\
        $(NULL)

