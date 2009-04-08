/*
 * Copyright (C) 2007 Davi E. M. Arnaut <davi@haxent.com.br>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of version 2 of the GNU General Public License as published
 * by the Free Software Foundation.
 */

#include <argp.h>
#include <malloc.h>
#include <search.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "dwarves.h"
#include "dutil.h"

#include "es-lang-c-stdc99.h"


static int  dwarfish_iterator  (struct cu *cu, void *cookie);
static int  dwarfish_iterator0 (struct tag *tag, struct cu *cu, void *cookie);
static int  dwarfish_variable  (const struct variable *var, void *cookie);
static int  dwarfish_function  (struct function * func, void *cookie);

static const struct argp_option dwarfish__options[] = {
	{
		.name = NULL,
	}
};
static error_t dwarfish__options_parser(int key, char *arg __unused,
				      struct argp_state *state)
{
	switch (key) {
	case ARGP_KEY_INIT: state->child_inputs[0] = state->input; break;
	default:  return ARGP_ERR_UNKNOWN;
	}
	return 0;
}

static const char dwarfish__args_doc[] = "DEBUGINFO-FILE";

static struct argp dwarfish__argp = {
	.options  = dwarfish__options,
	.parser	  = dwarfish__options_parser,
	.args_doc = dwarfish__args_doc,
};

int main(int argc, char *argv[])
{
	int err;
	struct cus *cus = cus__new(NULL, NULL);

	if (cus == NULL) {
		fputs("dwarfish: insufficient memory\n", stderr);
		return EXIT_FAILURE;
	}

	err = cus__loadfl(cus, &dwarfish__argp, argc, argv);
	if (err != 0)
		return EXIT_FAILURE;

	dwarves__init(0);

	cus__for_each_cu(cus, dwarfish_iterator, NULL, NULL);

	return EXIT_SUCCESS;
}


static int
dwarfish_iterator(struct cu *cu, void *cookie)
{
  return cu__for_each_tag(cu, dwarfish_iterator0, cookie, NULL);
}

static int
dwarfish_iterator0 (struct tag *tag, struct cu *cu, void *cookie)
{
  if (tag->tag == DW_TAG_variable)
    return dwarfish_variable(tag__variable(tag), cookie);
  else if (tag->tag == DW_TAG_subprogram)
    return dwarfish_function(tag__function(tag), cookie);
  else
    return 0;

}

static int
dwarfish_variable  (const struct variable *var, void *cookie)
{
  EsObject* o;


  if (!var->name)
    goto out;

  o = es_srealize("(dwarfish variable :name %s)", var->name);
  es_print(o, NULL);
  puts("\n");
  es_object_unref(o);

 out:
  return 0;
}

static int
dwarfish_function  (struct function * func, void *cookie)
{
  EsObject* o;


  if (!func->name)
    goto out;

  o = es_srealize("(dwarfish function :name %s)", func->name);
  es_print(o, NULL);
  puts("\n");
  es_object_unref(o);

 out:  
  return 0;
}
  
