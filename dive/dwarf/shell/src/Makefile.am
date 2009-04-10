bin_PROGRAMS = es-src-dwarf

es_src_dwarf_SOURCES = main.c dwarfish.c es-lang-c-stdc99.c
es_src_dwarf_LDADD  = @GLIB2_LIBS@ -ldwarves
noinst_HEADERS   = list.h hash.h es-lang-c-stdc99.h dwarfish.h

AM_CFLAGS = -g -Wall
INCLUDES = @GLIB2_CFLAGS@