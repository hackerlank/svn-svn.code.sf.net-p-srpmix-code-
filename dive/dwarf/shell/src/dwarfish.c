#include "dwarfish.h"
#include "es-lang-c-stdc99.h"
#include <stdlib.h>



int dwarfish_variable_do    (const struct variable *var,
			     struct cu *cu,
			     DwarfishContext * ctx);
int dwarfish_function_do    (const struct function * func, 
			     struct cu *cu,
			     DwarfishContext * ctx);

DwarfishContext *
dwarfish_context_new  (void)
{
  return malloc(sizeof(DwarfishContext));
}
void
dwarfish_context_free (DwarfishContext * fish)
{
  free(fish);
}


int
dwarfish_tag_do       (struct tag *tag, 
		       struct cu *cu, 
		       DwarfishContext * ctx)
{
  if (tag->tag == DW_TAG_variable)
    return dwarfish_variable_do(tag__variable(tag), cu, ctx);
  else if (tag->tag == DW_TAG_subprogram)
    return dwarfish_function_do(tag__function(tag), cu, ctx);
  else
    {
      const char* name;

      name = dwarf_tag_name(tag->tag);
      printf(";; TODO: %s\n", name);
      return 0;
    }
}



int
dwarfish_variable_do  (const struct variable *var, 
		       struct cu *cu,
		       DwarfishContext * fish)
{
  EsObject* o;
  const char* name;

  name = variable__name(var, cu);
  if (!name)
    goto out;

  o = es_srealize("(dwarfish variable :name %s :file %s :line %d :external %b :declaration %b :location %S)", 
		  name,
		  var->tag.decl_file,
		  var->tag.decl_line,
		  var->external? es_true: es_false,
		  var->declaration? es_true: es_false,
		  (var->location == LOCATION_UNKNOWN)   ? "unknown":
		  (var->location == LOCATION_LOCAL)     ? "local":
		  (var->location == LOCATION_GLOBAL)    ? "global":
		  (var->location == LOCATION_REGISTER)  ? "register":
		  (var->location == LOCATION_OPTIMIZED) ? "optimized": "?"
		  );
  es_print(o, NULL);
  puts("");
  es_object_unref(o);

 out:
  return 0;
}

int
dwarfish_function_do  (const struct function * func, 
		       struct cu *cu,
		       DwarfishContext * fish)
{
  EsObject* o;
  const char* name;


  name = function__name(func, cu);
  if (!name)
    goto out;

  o = es_srealize("(dwarfish function :name %s :external %b :file %s :line %d)", 
		  name,
		  (func->external? es_true: es_false),
		  func->proto.tag.decl_file? func->proto.tag.decl_file: (func->lexblock.tag.decl_file? func->lexblock.tag.decl_file: ""),
		  func->proto.tag.decl_line? func->proto.tag.decl_line: (func->lexblock.tag.decl_line? func->lexblock.tag.decl_line: 0)
		  );
  es_print(o, NULL);
  puts("");
  es_object_unref(o);

 out:  
  return 0;
}
  
