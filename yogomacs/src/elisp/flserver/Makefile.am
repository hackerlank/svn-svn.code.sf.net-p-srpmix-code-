SUBDIRS = plugins

dist_noinst_DATA=yogomacs.el

flserverdir=$(sysconfdir)/font-lock/flserver
install-data-hook:
	install -D yogomacs.el $(DESTDIR)$(flserverdir)/yogomacs-@SPEC_CONFIG@.el

