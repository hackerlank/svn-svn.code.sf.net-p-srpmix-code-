plugindir = $(pkgdatadir)/plugins

EXTRA_DIST = 60srpmix-etags \
	60srpmix-ctags \
	60srpmix-cscope \
	60srpmix-doxygen

plugin_SCRIPTS =

if SRPMIX_ENABLE_PLUGIN_etags
plugin_SCRIPTS += 60srpmix-etags
endif

if SRPMIX_ENABLE_PLUGIN_ctags
plugin_SCRIPTS += 60srpmix-ctags
endif

if SRPMIX_ENABLE_PLUGIN_cscope
plugin_SCRIPTS += 60srpmix-cscope
endif

if SRPMIX_ENABLE_PLUGIN_doxygen
plugin_SCRIPTS += 60srpmix-doxygen
endif

dist_plugin_SCRIPTS = \
        10srpmix-vanilla      \
	50srpmix-coreutils   \
	50srpmix-file        \
        60srpmix-kindex      \
	\
        $(NULL)

