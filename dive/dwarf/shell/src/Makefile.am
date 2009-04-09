bin_PROGRAMS = dwarfish

dwarfish_SOURCES = main.c dwarfish.c es-lang-c-stdc99.c
dwarfish_LDADD  = @GLIB2_LIBS@ -ldwarves
noinst_HEADERS   = list.h hash.h es-lang-c-stdc99.h dwarfish.h

AM_CFLAGS = -g -Wall
INCLUDES = @GLIB2_CFLAGS@