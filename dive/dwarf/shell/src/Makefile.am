bin_PROGRAMS = es-src-dwarf

es_src_dwarf_SOURCES = main.c dwarfish.c
es_src_dwarf_LDADD  = @GLIB2_LIBS@ @ES_LANG_C_STDC99_LIBS@ -ldwarves
noinst_HEADERS   = list.h hash.h dwarfish.h

AM_CFLAGS = -g -Wall
INCLUDES = @GLIB2_CFLAGS@ @ES_LANG_C_STDC99_CFLAGS@