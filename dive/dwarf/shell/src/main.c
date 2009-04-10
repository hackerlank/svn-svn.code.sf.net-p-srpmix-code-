/*
 * Copyright (C) 2009 Red Hat, Inc.
 * Copyright (C) 2009 Masatake YAMATO <yamato@redhat.com>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of version 2 of the GNU General Public License as published
 * by the Free Software Foundation.
 */

#include <stdio.h>
#include <stdlib.h>
#include <dwarves.h>
#include <es-lang-c-stdc99.h>

#include "dwarfish.h"

int main(int argc, char *argv[])
{
  int i;
  struct cus *cus;
  DwarfishContext *ctx;

  dwarves__init(0);

  ctx = dwarfish_context_new();

  for ( i = 0; i < argc - 1; i++)
    {
      cus = dwarfish_cus_new(argv[i + 1]);
      if (cus == NULL)
	continue;

      dwarfish_context_do(ctx, cus);
    }
	
  dwarfish_context_free(ctx);
  return EXIT_SUCCESS;
}
