/*
 * Copyright (C) 2009 Red Hat, Inc.
 * Copyright (C) 2009 Masatake YAMATO <yamato@redhat.com>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of version 2 of the GNU General Public License as published
 * by the Free Software Foundation.
 */

#include <argp.h>
#include <stdio.h>
#include <stdlib.h>
#include <dwarves.h>
#include <es-lang-c-stdc99.h>

#include "dwarfish.h"

static int  dwarfish_cu_iterator    (struct cu   *cu, 
				     void* cookie);
static int  dwarfish_tag_iterator   (struct tag *tag, 
				     struct cu *cu, 
				     void* cookie);

static const struct argp_option dwarfish__options[] = {
  {
    .name = NULL,
  }
};

static error_t dwarfish__options_parser(int key, 
					char *arg,
					struct argp_state *state)
{
  switch (key) {
  case ARGP_KEY_INIT: 
    state->child_inputs[0] = state->input; break;
  default:  
    return ARGP_ERR_UNKNOWN;
  }
  return 0;
}

static const char dwarfish__args_doc[] = "DEBUGINFO-FILE";

static struct argp dwarfish__argp = {
  .options  = dwarfish__options,
  .parser   = dwarfish__options_parser,
  .args_doc = dwarfish__args_doc,
};

int main(int argc, char *argv[])
{
	int err;
	struct cus *cus;
	DwarfishContext *ctx;


	cus = cus__new(NULL, NULL);
	if (cus == NULL) {
		fputs("dwarfish: insufficient memory\n", stderr);
		return EXIT_FAILURE;
	}

	err = cus__loadfl(cus, &dwarfish__argp, argc, argv);
	if (err != 0)
		return EXIT_FAILURE;

	dwarves__init(0);

	ctx = dwarfish_context_new();
	cus__for_each_cu(cus, dwarfish_cu_iterator, ctx, NULL);
	dwarfish_context_free(ctx);

	return EXIT_SUCCESS;
}


static int
dwarfish_cu_iterator(struct cu *cu, void *cookie)
{
  return cu__for_each_tag(cu, 
			  dwarfish_tag_iterator, 
			  cookie, 
			  NULL);
}

static int
dwarfish_tag_iterator (struct tag *tag, struct cu *cu, void *cookie)
{
  DwarfishContext *ctx;


  ctx = cookie;
  return dwarfish_tag_do(tag, cu, ctx);
}

