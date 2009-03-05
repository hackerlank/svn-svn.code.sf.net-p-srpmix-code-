SUBDIRS  = .
SUBDIRS += backends

bin_SCRIPTS=liblcopy.sh
CLEANFILES = $(bin_SCRIPTS)

dist_bin_SCRIPTS =     \
	\
	lcopy          \
	\
        lcopy-rebirth  \
        lcopy-refresh  \
        lcopy-genspec  \
	\
        $(NULL)

plugindir = $(libexecdir)/lcopy/plugins
dist_plugin_SCRIPTS = \
	10lcopy-ctags \
	10lcopy-etags \
        \
        $(NULL)
