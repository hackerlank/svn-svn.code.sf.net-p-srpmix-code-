#ifndef DWARFISH_H
#define DWARFISH_H

#include <dwarves.h>


typedef struct _DwarfishContext DwarfishContext;

struct _DwarfishContext
{
  int interfactive_p;
};

DwarfishContext * dwarfish_context_new  (void);
void              dwarfish_context_do   (DwarfishContext * fish,
					 struct cus *cus);
void              dwarfish_context_free (DwarfishContext * ctx);

struct cus*       dwarfish_cus_new      (char* file);

int               dwarfish_tag_do       (struct tag *tag, 
					 struct cu *cu, 
					 DwarfishContext * fish);

#endif	/* DWARFISH_H */
