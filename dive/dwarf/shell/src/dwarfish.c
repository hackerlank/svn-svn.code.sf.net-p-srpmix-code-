#include "dwarfish.h"
#include "es-lang-c-stdc99.h"
#include <stdlib.h>
#include <argp.h>


#define O(X) es_object_autounref(X) 
#define UNDEF es_symbol_intern("undef")


typedef struct _TagHandlerTable TagHandlerTable;
struct _TagHandlerTable {
  int tag;
  EsObject* (* convert_to_es) (const struct tag* tag,
			       struct  cu*       cu,
			       DwarfishContext*  ctx);
}; 

static int  dwarfish_cu_iterator    (struct cu   *cu, 
				     void* cookie);
static int  dwarfish_tag_iterator   (struct tag *tag, 
				     struct cu *cu, 
				     void* cookie);

DwarfishContext *
dwarfish_context_new  (void)
{
  return malloc(sizeof(DwarfishContext));
}

void
dwarfish_context_do   (DwarfishContext * ctx,
		       struct cus *cus)
{
  cus__for_each_cu(cus, dwarfish_cu_iterator, ctx, NULL);
}

void
dwarfish_context_free (DwarfishContext * fish)
{
  free(fish);
}


EsObject* dwarfish_variable_convert_to_es  (const struct tag* tag,
				 struct cu *cu,
				 DwarfishContext * ctx);
EsObject* dwarfish_function_convert_to_es  (const struct tag* tag,
				 struct cu *cu,
				 DwarfishContext * ctx);
EsObject* dwarfish_base_type_convert_to_es (const struct tag* tag,
				 struct cu *cu,
				 DwarfishContext * ctx);
EsObject* dwarfish_typedef_convert_to_es   (const struct tag* tag,
				 struct cu *cu,
				 DwarfishContext * ctx);


static TagHandlerTable tag_handler_table [] = 
  {
    { DW_TAG_variable,   dwarfish_variable_convert_to_es  },
    { DW_TAG_subprogram, dwarfish_function_convert_to_es  },
    { DW_TAG_base_type,  dwarfish_base_type_convert_to_es },
    { DW_TAG_typedef,    dwarfish_typedef_convert_to_es   },
    { 0,                 NULL                  },
  };


int
dwarfish_tag_do       (struct tag *tag, 
		       struct cu *cu, 
		       DwarfishContext * ctx)
{
  int i;
  EsObject* o = UNDEF;



  for (i = 0; ; ++i)
    {
      if (tag_handler_table[i].tag == 0
	  && tag_handler_table[i].convert_to_es == NULL)
	break;
      else if (tag_handler_table[i].tag == tag->tag)
	{
	  es_autounref_pool_push();
	  o = tag_handler_table[i].convert_to_es(tag, cu, ctx);
	  es_autounref_pool_pop();
	  break;
	}
    }

  if (o != UNDEF)
    {
      es_print(o, NULL);
      es_object_unref(o);
    }
  else
    {
      const char* name;
      
      name = dwarf_tag_name(tag->tag);
      printf(";; TODO: %s", name);
    }

  puts("");


  return 0;
}



EsObject*
dwarfish_variable_convert_to_es  (const struct tag* tag,
		       struct cu *cu,
		       DwarfishContext * fish)
{
  const struct variable *var;
  EsObject* o;
  const char* name;


  var = tag__variable(tag);


  o = UNDEF;
  name = variable__name(var, cu);
  if (!name)
    goto out;

  o = es_srealize
    (
     "(dwarfish variable :name %s :file %s :line %d)", 
     name,
     var->tag.decl_file,
     var->tag.decl_line
     );

 out:
  return o;
}

EsObject*
dwarfish_function_convert_to_es  (const struct tag* tag,
		       struct cu *cu,
		       DwarfishContext * fish)
{
  struct function * func;
  EsObject* o;
  const char* name;


  func = tag__function(tag);


  o = UNDEF;
  name = function__name(func, cu);
  if (!name)
    goto out;

  o = es_srealize
    (
     "(dwarfish function :name %s :file %s :line %d)", 
     name,
     func->proto.tag.decl_file? func->proto.tag.decl_file: (func->lexblock.tag.decl_file? func->lexblock.tag.decl_file: ""),
     func->proto.tag.decl_line? func->proto.tag.decl_line: (func->lexblock.tag.decl_line? func->lexblock.tag.decl_line: 0)
     );

 out:  
  return o;
}
  

EsObject*
dwarfish_base_type_convert_to_es   (const struct tag* tag,
			 struct cu *cu,
			 DwarfishContext * ctx)
{
  struct base_type* base_type;
  EsObject* o;
  const char* name;


  base_type = tag__base_type(tag);


  o = UNDEF;
  name = base_type->name;
  if (!name)
    goto out;

  o = es_srealize
    (
     "(dwarfish base-type :name %s :size  %d :file %, :line %d)",
     name,
     tag__size(&base_type->tag, cu),
     O(base_type->tag.decl_file? es_string_new(base_type->tag.decl_file): es_false) ,
     base_type->tag.decl_line
     );

 out:
  return o;
}

EsObject*
dwarfish_typedef_convert_to_es     (const struct tag* tag,
			 struct cu *cu,
			 DwarfishContext * ctx)
{
  struct type* type;
  EsObject* o;
  char  buffer[512];
  

  type = tag__type(tag);


  o = es_srealize
    (
     "(dwarfish typedef :name %s :size %d :file %, :line %d)",
     tag__name(&type->namespace.tag, cu, buffer, sizeof(buffer)),
     tag__size(&type->namespace.tag, cu),
     O(type->namespace.tag.decl_file? es_string_new(type->namespace.tag.decl_file): es_false) ,
     type->namespace.tag.decl_line
     );

  return o;
}


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

struct cus*
dwarfish_cus_new (char* file)
{
  struct cus* cus;

  int err;
  int argc;
  char * argv[2];

  argv[0] = "dwarfish";
  argv[1] = file;
  argc =  2;

  cus = cus__new(NULL, NULL);
  if (cus == NULL)
    {
      fputs("dwarfish: insufficient memory\n", stderr);
      return NULL;
    }

  err = cus__loadfl(cus, &dwarfish__argp, argc, argv);
  if (err != 0)
    {
      fprintf(stderr, "dwarfish: failed to load: %s\n", file);
      free(cus);
      return NULL;
    }

  return cus;
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
