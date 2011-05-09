AUTOMAKE_OPTIONS = foreign
ACLOCAL_AMFLAGS = -I misc/m4

SUBDIRS  = .
SUBDIRS += misc
SUBDIRS += src
SUBDIRS += doc
SUBDIRS += utils
SUBDIRS += tests

EXTRA_DIST = autogen.sh

XSPECS=misc/specs/srpmix-dir-base.SPEC
include $(top_srcdir)/misc/makefiles/rpm.mk
