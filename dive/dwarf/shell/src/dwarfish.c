#include "dwarfish.h"
#include "es-lang-c-stdc99.h"
#include <stdlib.h>



int dwarfish_variable_do    (const struct variable *var,
			     struct cu *cu,
			     DwarfishContext * ctx);
int dwarfish_function_do    (const struct function * func, 
			     struct cu *cu,
			     DwarfishContext * ctx);
int dwarfish_base_type_do   (struct base_type* base_type,
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
  else if (tag->tag == DW_TAG_base_type)
    return dwarfish_base_type_do(tag__base_type(tag), cu, ctx);
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

  o = es_srealize("(dwarfish variable :name %s :file %s :line %d)", 
		  name,
		  var->tag.decl_file,
		  var->tag.decl_line
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

  o = es_srealize("(dwarfish function :name %s :file %s :line %d)", 
		  name,
		  func->proto.tag.decl_file? func->proto.tag.decl_file: (func->lexblock.tag.decl_file? func->lexblock.tag.decl_file: ""),
		  func->proto.tag.decl_line? func->proto.tag.decl_line: (func->lexblock.tag.decl_line? func->lexblock.tag.decl_line: 0)
		  );
  es_print(o, NULL);
  puts("");
  es_object_unref(o);

 out:  
  return 0;
}
  

int
dwarfish_base_type_do   (struct base_type* base_type,
			 struct cu *cu,
			 DwarfishContext * ctx)
{
  EsObject* o, * o0;
  const char* name;

  name = base_type->name;
  if (!name)
    goto out;

  o = es_srealize("(dwarfish base-type :name %s :size  %d :file %, :line %d)",
		  name,
		  base_type->size,
		  o0 = (base_type->tag.decl_file? es_string_new(base_type->tag.decl_file): es_false) ,
		  base_type->tag.decl_line);
  es_print(o, NULL);
  puts("");
  es_object_unref(o);
  es_object_unref(o0);

 out:
  return 0;
}
