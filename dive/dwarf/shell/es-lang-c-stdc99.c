/*
  Copyright (c) 2009 Masatake YAMATO

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE. */

#include "es-lang-c-stdc99.h"


#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>


static int es_debug = 0;

struct _EsObject
{
  EsType  type;
  int     ref_count;
};

typedef struct _EsInteger EsInteger;
struct _EsInteger
{
  EsObject base;
  int      value;
};

typedef struct _EsReal EsReal;
struct _EsReal
{
  EsObject base;
  double   value;
};

typedef struct _EsBoolean EsBoolean;
struct _EsBoolean
{
  EsObject base;
  int      value;
};

typedef struct _EsString EsString;
struct _EsString
{
  EsObject    base;
  char*       value;
};

typedef struct _EsSingleton EsSingleton;
struct _EsSingleton
{
  EsObject     base;
  EsSingleton* next;
  char*        quark;
};


typedef struct _EsSymbol EsSymbol;
struct _EsSymbol
{
  EsSingleton base;
};

typedef struct _EsError EsError;
struct _EsError
{
  EsSingleton base;
};


typedef struct _EsCons EsCons;
struct _EsCons
{
  EsObject base;
  EsObject* car;
  EsObject* cdr;
};


typedef struct _EsObjectClass EsObjectClass;
struct _EsObjectClass
{
  size_t         size;
  void           (* free)  (EsObject* object);
  int            (* equal) (const EsObject* self, const EsObject* other);
  void           (* print) (const EsObject* object, FILE* fp);
  char           atom_p;
  EsSingleton  **obarray;
  const char*    name;
};


static void es_nil_free(EsObject* object);
static int  es_nil_equal(const EsObject* self, const EsObject* other);
static void es_nil_print(const EsObject* object, FILE* fp);

static void es_integer_free(EsObject* object);
static int  es_integer_equal(const EsObject* self, const EsObject* other);
static void es_integer_print(const EsObject* object, FILE* fp);

static void es_real_free(EsObject* object);
static int  es_real_equal(const EsObject* self, const EsObject* other);
static void es_real_print(const EsObject* object, FILE* fp);

static void es_boolean_free(EsObject* object);
static int  es_boolean_equal(const EsObject* self, const EsObject* other);
static void es_boolean_print(const EsObject* object, FILE* fp);

static void es_string_free(EsObject* object);
static int  es_string_equal(const EsObject* self, const EsObject* other);
static void es_string_print(const EsObject* self, FILE* fp);

static void es_symbol_free(EsObject* object);
static int  es_symbol_equal(const EsObject* self, const EsObject* other);
static void es_symbol_print(const EsObject* object, FILE* fp);

static void es_cons_free(EsObject* object);
static int  es_cons_equal(const EsObject* self, const EsObject* other);
static void es_cons_print(const EsObject* object, FILE* fp);

static void es_error_free(EsObject* object);
static int  es_error_equal(const EsObject* self, const EsObject* other);
static void es_error_print(const EsObject* other, FILE* fp);


static EsSingleton* es_obarray_intern(EsType type, const char* symbol);
static const char*  es_singleton_get   (EsSingleton *singleton);
static unsigned int hash(const char* keyarg);
#define OBARRAY_SIZE    83
static EsSingleton  *symbol_obarray[OBARRAY_SIZE];
static EsSingleton  *error_obarray [OBARRAY_SIZE];

static EsObjectClass classes[] = {
  [ES_TYPE_NIL] = {
    .size    = 0,                 
    .free    = es_nil_free,
    .equal   = es_nil_equal,
    .print   = es_nil_print,
    .atom_p  = 1,
    .obarray = NULL,
    .name    = "nil",
  },
  [ES_TYPE_INTEGER] = {
    .size    = sizeof(EsInteger), 
    .free    = es_integer_free,
    .equal   = es_integer_equal,
    .print   = es_integer_print,
    .atom_p  = 1,
    .obarray = NULL,
    .name    = "integer",
  },
  [ES_TYPE_REAL]    = {
    .size    = sizeof(EsReal),    
    .free    = es_real_free,
    .equal   = es_real_equal,
    .print   = es_real_print,
    .atom_p  = 1,
    .obarray = NULL,
    .name    = "real",
  },
  [ES_TYPE_BOOLEAN] = {
    .size    = sizeof(EsBoolean), 
    .free    = es_boolean_free,
    .equal   = es_boolean_equal,
    .print   = es_boolean_print,
    .atom_p  = 1,
    .obarray = (void*)1,
    .name    = "boolean",
  },
  [ES_TYPE_SYMBOL]  = {
    .size    = sizeof(EsSymbol),  
    .free    = es_symbol_free,
    .equal   = es_symbol_equal,
    .print   = es_symbol_print,
    .atom_p  = 1,
    .obarray = symbol_obarray,
    .name    = "symbol",
  },
  [ES_TYPE_STRING]  = {
    .size    = sizeof(EsString),  
    .free    = es_string_free,
    .equal   = es_string_equal,
    .print   = es_string_print,
    .atom_p  = 1,
    .obarray = NULL,
    .name    = "string",
  },
  [ES_TYPE_CONS]    = {
    .size    = sizeof(EsCons),    
    .free    = es_cons_free,
    .equal   = es_cons_equal,
    .print   = es_cons_print,
    .atom_p  = 0,
    .obarray = NULL,
    .name    = "cons",
  },
  [ES_TYPE_ERROR] = {
    .size    = sizeof(EsError),   
    .free    = es_error_free,
    .equal   = es_error_equal,
    .print   = es_error_print,
    .atom_p  = 1,
    .obarray = error_obarray,
    .name    = "error",
  },
};



static EsObjectClass* 
class_of(const EsObject* object)
{
  return &(classes[es_object_get_type(object)]);
}

static EsObject*
es_object_new(EsType type)
{
  EsObject* r;


  r = calloc(1, (&classes[type])->size);
  r->type = type;
  r->ref_count = 1;

  if (es_debug) 
    fprintf(stderr, "new{%s}: 0x%p\n", 
	    (&classes[type])->name, 
	    r);

  return r;
}

static void
es_object_free(EsObject* object)
{
  memset(object, 0, class_of(object)->size);
  free(object);
}

static int
es_object_type_p(const EsObject* object, EsType type)
{
  return es_object_get_type(object) == type;
}

EsType
es_object_get_type      (const EsObject*      object)
{
  return object? object->type: ES_TYPE_NIL;
}

EsObject*
es_object_ref           (EsObject*       object)
{
  if (object)
    {
      if (es_debug && (class_of(object)->obarray == NULL))
	fprintf(stderr, "ref{%s}: [%d]0x%p\n", 
		class_of(object)->name,
		object->ref_count,
		object);
      object->ref_count++;
    }
  return object;
}

void
es_object_unref         (EsObject*       object)
{
  
  if (object)
    {  
      if (object->ref_count == 0)
	if ((1 || es_debug) && (class_of(object)->obarray == NULL))
	  {
	    fprintf(stderr, "*** ref_count < 0: 0x%p ***\n", object);
	    fprintf(stderr, "*** BOOSTING while(1). ***\n");
	    while (1);
	  }

      object->ref_count--;
      if (es_debug && (class_of(object)->obarray == NULL))
	fprintf(stderr, "unref{%s}: [%d]0x%p\n", 
		class_of(object)->name,
		object->ref_count, object);
      if (object->ref_count == 0 &&
	  (class_of(object)->obarray == NULL))
	{
	  if (es_debug)
	    fprintf(stderr, "free{%s}: 0x%p\n", 
		    class_of(object)->name,
		    object);
	  class_of(object)->free(object);
	}
    }
}

void
es_object_unref_batch (EsObject*       array[], 
		       unsigned int    count)
{
  unsigned int i;

  for (i = 0; i < count; i++)
    {
      es_object_unref(array[i]);
      array[i] = es_nil;
    }
}

int
es_object_equal         (const EsObject* self,
			 const EsObject* other)
{
  if (self == other)
    return 1;

  return class_of(self)->equal(self, other);
}


int
es_atom         (const EsObject* object)
{
  return class_of(object)->atom_p;
}


/* 
 * Nil
 */
int
es_null(const EsObject* object)
{
  return (object == es_nil)? 1: 0;
}

static void
es_nil_free(EsObject* object)
{
  /* DO NOTHING */
}

static int
es_nil_equal(const EsObject* self, const EsObject* other)
{
  return es_null(other);
}

static void
es_nil_print(const EsObject* object, FILE* fp)
{
  fputs("()", fp);
}

/* 
 * Integer
 */
EsObject*    
es_integer_new (int                value)
{
  EsObject* r;

  r = es_object_new(ES_TYPE_INTEGER);
  ((EsInteger*)r)->value = value;
  return r;
}

int
es_integer_p   (const EsObject*   object)
{
  return es_object_type_p(object, ES_TYPE_INTEGER);
}

int
es_integer_get (const EsObject*   object)
{
  if (es_integer_p(object))
    return ((EsInteger *)object)->value;
  else
    {
      /* TODO */
      return -1;
    }
}

static void
es_integer_free(EsObject* object)
{
  es_object_free(object);
}

static int
es_integer_equal(const EsObject* self, const EsObject* other)
{
  return ((es_integer_p(other)) 
	  && (es_integer_get(self) == es_integer_get(other)))? 1: 0;
}

static void
es_integer_print(const EsObject* object, FILE* fp)
{
  fprintf(fp, "%d", es_integer_get(object));
}


/* 
 * Real
 */
EsObject*    
es_real_new (double                value)
{
  EsObject* r;

  r = es_object_new(ES_TYPE_REAL);
  ((EsReal*)r)->value = value;
  return r;
}

int
es_real_p   (const EsObject*   object)
{
  return es_object_type_p(object, ES_TYPE_REAL);
}

double
es_real_get (const EsObject*   object)
{
  if (es_real_p(object))
    return ((EsReal *)object)->value;
  else
    {
      /* TODO */
      return -1;
    }
}

static void
es_real_free(EsObject* object)
{
  es_object_free(object);
}

static int
es_real_equal(const EsObject* self, const EsObject* other)
{
  return ((es_real_p(other)) 
	  /* TODO: Too restricted? */
	  && (es_real_get(self) == es_real_get(other)))? 1: 0;
}

static void
es_real_print(const EsObject* object, FILE* fp)
{
  fprintf(fp, "%f", es_real_get(object));
}

/* 
 * Use Integer as Real
 */
int
es_number_p    (const EsObject*   object)
{
  return (es_integer_p(object) || es_real_p(object))? 1: 0;
}

double
es_number_get  (const EsObject*   object)
{
  double r;

  switch(es_object_get_type(object))
    {
    case ES_TYPE_INTEGER:
      r = (double)es_integer_get(object);
      break;
    case ES_TYPE_REAL:
      r = es_real_get(object);
      break;
    default:
      /* TODO */
      r = -1.0;
      break;
    }
  return r;
}


/* 
 * Boolean
 */
EsObject*    
es_boolean_new (int                value)
{
  static EsObject* T;
  static EsObject* F;

  if (!T)
    {
      T = es_object_new(ES_TYPE_BOOLEAN);
      ((EsBoolean*)T)->value = 1;
    }
  if (!F)
    {
      F = es_object_new(ES_TYPE_BOOLEAN);
      ((EsBoolean*)F)->value = 0;
    }
  
  return value? T: F;
}

int
es_boolean_p   (const EsObject*   object)
{
  return es_object_type_p(object, ES_TYPE_BOOLEAN);
}

int
es_boolean_get (const EsObject*   object)
{
  if (es_boolean_p(object))
    return ((EsBoolean *)object)->value;
  else
    {
      /* TODO */
      return -1;
    }
}

static void
es_boolean_free(EsObject* object)
{
  /* Do nothing */
}

static int
es_boolean_equal(const EsObject* self, const EsObject* other)
{
  return (self == other)? 1: 0;
}

static void
es_boolean_print(const EsObject* object, FILE* fp)
{
  fprintf(fp, "#%c", (es_boolean_get(object)? 't': 'f'));
}

/* 
 * Singleton
 */
static EsSingleton*
es_obarray_intern(EsType type, const char* name)
{
  unsigned int hv;
  EsSingleton** obarray;
  EsSingleton* s;
  EsSingleton* tmp;


  obarray = (&classes[type])->obarray;
  if (!obarray)
    return NULL;

  hv = hash(name);
  tmp = obarray[hv];

  s = NULL;
  while (tmp)
    {
      if (!strcmp(tmp->quark, name))
	{
	  s = tmp;
	  break;
	}
      else
	tmp = tmp->next;
    }

  if (!s)
    {
      s = (EsSingleton*) es_object_new(type);
      s->quark = strdup(name);
      tmp = obarray[hv];
      obarray[hv] = s;
      s->next = tmp;
    }

  return s;
  
}

static const char*
es_singleton_get   (EsSingleton *singleton)
{
  return singleton->quark;
}


/*
 * Symbol
 */
static unsigned char get_char_class(int c);


EsObject*    
es_symbol_intern  (const char*       symbol)
{
  EsSingleton* r;

  r = es_obarray_intern(ES_TYPE_SYMBOL, symbol);
  return (EsObject*)r;
}

int
es_symbol_p    (const EsObject*   object)
{
  return es_object_type_p(object, ES_TYPE_SYMBOL);
}

const char*  
es_symbol_get  (const EsObject*   object)
{
  if (es_symbol_p(object))
    return es_singleton_get((EsSingleton*)object);
  else
    {
      /* TODO */
      return NULL;
    }
}

static void
es_symbol_free(EsObject* object)
{
  /* DO NOTHING */
}

static int
es_symbol_equal(const EsObject* self, const EsObject* other)
{
  return (self == other)? 1: 0;
}

static void
es_symbol_print(const EsObject* object, FILE* fp)
{
  const char* string;
  size_t len;
  char c;
  unsigned char cc;
  unsigned char mask;
  int needs_bar;
  int i;

  string = es_symbol_get(object);
  if (!string)
    return;

  len = strlen(string);
  if (len == 0)
    needs_bar = 1;

  c = string[0];
  cc = get_char_class(c);
  mask = 0x1;
  needs_bar = (cc & mask)? 1: 0;
  if (!needs_bar)
    {
      /* 0 => 1? */
      mask = 0x2;
      for (i = 0; i< len; i++)
	{
	  c = string[i];
	  cc = get_char_class(c);
	  needs_bar = (cc & mask)? 1: 0;
	  if (needs_bar)
	    break;
	}
      
    }

  if (needs_bar)
    fprintf(fp, "|");
  
  for (i = 0; i < len; i++)
    {
      c = string[i];
      if (c == '\\' || c == '|')
	fprintf(fp, "\\");
      fprintf(fp, "%c", c);
    }

  if (needs_bar)
    fprintf(fp, "|");
}


/*
 * symbol.c - symbol implementation
 *
 *   Copyright (c) 2000-2007  Shiro Kawai  <shiro@acm.org>
 * 
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following conditions
 *   are met:
 * 
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   3. Neither the name of the authors nor the names of its contributors
 *      may be used to endorse or promote products derived from this
 *      software without specific prior written permission.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 *   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *  $Id: symbol.c,v 1.40 2007/09/13 12:30:28 shirok Exp $
 */
/* table of special chars.
   bit 0: bad char for symbol to begin with
   bit 1: bad char for symbol to contain
   bit 2: bad char for symbol, and should be written as \nnn
   bit 3: bad char for symbol, and should be written as \c
   bit 4: may be escaped when case fold mode
 */
static char symbol_special[] = {
 /* NUL .... */
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
 /* .... */
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
 /*    !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /  */
    3, 0, 3, 3, 0, 0, 0, 3, 3, 3, 0, 1, 3, 1, 1, 0,
 /* 0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  */
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 3, 0, 0, 0, 0,
 /* @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  */
    1, 16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,
 /* P  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  */
    16,16,16,16,16,16,16,16,16,16,16,3, 11,3, 0, 0,
 /* `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  */
    3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
 /* p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~  ^? */
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 11,3, 0, 7
};

/* symbol_special[':'] was 1 in the symbol.c of Gauche.
   However I modified it to 0.
   Because a keyword is a just a symbol started from `:' 
   in Es. */
static unsigned char
get_char_class(int c)
{
  return (c < 0)? 0xff: symbol_special[c];
}

/* 
 * String
 */
EsObject*
es_string_new  (const char*        value)
{
  EsObject* r;

  r = es_object_new(ES_TYPE_STRING);
  ((EsString*)r)->value = strdup(value);
  return r;
}

int
es_string_p    (const EsObject*   object)
{
  return es_object_type_p(object, ES_TYPE_STRING);
}

const char*
es_string_get  (const EsObject*   object)
{
  if (es_string_p(object))
    return ((EsString *)object)->value;
  else
    {
      /* TODO */
      return NULL;
    }
}

static void
es_string_free(EsObject* object)
{
  if (es_string_p(object))
    {
      free(((EsString*) object)->value);
      ((EsString*) object)->value = NULL;
      es_object_free(object);
    }
  else
    ;				/* TODO */
}


static int
es_string_equal(const EsObject* self, const EsObject* other)
{
  if (es_string_p(other))
    {
      return (!strcmp(es_string_get(self), es_string_get(other)));
    }
  else
    return 0;
}

static void
es_string_print(const EsObject* object, FILE* fp)
{
  const char* string;
  char  c;
  size_t len;
  int      i;


  string = es_string_get(object);
  len    = strlen(string);

  fprintf(fp, "\"");
  
  for (i = 0; i < len; i++)
    {
      char cc;
      
      c = string[i];
      switch (c)
	{
	case '\n':
	  cc = 'n';
	  break;
	case '\t':
	  cc = 't';
	  break;
	case '\r':
	  cc = 'r';
	  break;
	case '\f':
	  cc = 'f';
	  break;
	default:
	  cc = 0;
	  break;
	}
      if (cc)
	{
	  fprintf(fp, "\\");
	  fprintf(fp, "%c", cc);
	  continue;
	}
      
      if (c == '\\' || c == '"')
	fprintf(fp, "\\");
      fprintf(fp, "%c", c);
    }
  
  fprintf(fp, "\"");
}

/*
 * Cons
 */
EsObject*    
es_cons        (EsObject* car, EsObject* cdr)
{
  EsObject* r;

  if (!es_list_p(cdr))
    {
      /* This library doesn't permit to dotted list. */
      return es_nil;
    }


  r = es_object_new(ES_TYPE_CONS);
  if (es_debug)
    {
      fprintf(stderr, "cons[0x%p] = (0x%p . 0x%p)\n", r, car, cdr);
      /* es_print(car, stderr);
	 fputc('\n', stderr);
	 es_print(cdr, stderr);
	 fputc('\n', stderr); */
    }
  ((EsCons*)r)->car = es_object_ref(car);
  ((EsCons*)r)->cdr = es_object_ref(cdr);

  return r;  
}

int
es_cons_p      (const EsObject* object)
{
  return es_object_type_p(object, ES_TYPE_CONS);
}

int
es_list_p      (const EsObject* object)
{
  EsType t;

  t = es_object_get_type(object);
  return (t == ES_TYPE_NIL || t == ES_TYPE_CONS);
}

EsObject*
es_car         (const EsObject* object)
{
  if (es_cons_p(object))
    return ((EsCons*)object)->car;
  else if (es_null(object))
    return es_nil;
  else
    return es_nil;		/* TODO */
}

EsObject*
es_cdr         (const EsObject* object)
{
  if (es_cons_p(object))
    return ((EsCons*)object)->cdr;
  else if (es_null(object))
    return es_nil;
  else
    return es_nil;		/* TODO */
}

static void
es_cons_free(EsObject* object)
{
  EsCons* cons;

  if (es_cons_p(object))
    {
      cons = ((EsCons*)object);
      
      es_object_unref(cons->car);
      cons->car = NULL;
      
      es_object_unref(cons->cdr);
      cons->cdr = NULL;
      es_object_free(object);
    }
  else if (es_null(object))
    ;				/* DO NOTHING */
  else
    ;				/* TODO */
}

static int
es_cons_equal(const EsObject* self, const EsObject* other)
{
  return (es_null(other)
	  || (!es_cons_p(other))
	  || (!es_object_equal(es_car(self), es_car(other)))
	  || (!es_object_equal(es_cdr(self), es_cdr(other))))
    ? 0
    : 1;
}

static void
es_cons_print(const EsObject* object, FILE* fp)
{
  EsObject* car;
  EsObject* cdr;

  fprintf(fp, "(");
  while(!es_null(object))
    {
      car = es_car(object);
      cdr = es_cdr(object);

      es_print(car, fp);
      if (es_cons_p(cdr))
	fputc(' ', fp);
      else if (!es_null(cdr))
	{
	  /* TODO: 
	     g_warning("Es does not support dotted list");
	     break;
	   */
	}
      object = cdr;
    }
  fprintf(fp, ")");
}

static EsObject* es_cons_reverse_rec(EsObject* cdr, 
				     EsObject* car, 
				     EsObject* gathered);

static EsObject* 
es_cons_reverse  (EsObject*        cons)
{
  /* g_return_val_if_fail (es_null(cons) || es_cons_p(cons), es_nil);
     g_return_val_if_fail (!es_cproc_dotted_p(cons), es_nil); */

  if (es_null(cons))
    return es_nil;
  else
    return es_cons_reverse_rec(es_cdr(cons),
			       es_car(cons),
			       es_nil);
}

EsObject*
es_reverse  (EsObject* cons)
{
  return es_cons_reverse(cons);
}

static EsObject* 
es_cons_reverse_rec(EsObject* cdr, 
		    EsObject* car, 
		    EsObject* gathered)
{
  EsObject* cons;
  EsObject* o;
  
  cons = es_cons(car, o = gathered);
  es_object_unref(o);
  
  if (es_null(cdr))
    return cons;
  else
    return es_cons_reverse_rec(es_cdr(cdr),
			       es_car(cdr),
			       cons);
}

/*
 * Error
 */
EsObject*    
es_error_intern  (const char*       error)
{
  EsSingleton* r;

  r = es_obarray_intern(ES_TYPE_ERROR, error);
  return (EsObject*)r;
}

int
es_error_p    (const EsObject*   object)
{
  return es_object_type_p(object, ES_TYPE_ERROR);
}

const char*  
es_error_get  (const EsObject*   object)
{
  if (es_error_p(object))
    return es_singleton_get((EsSingleton *)object);
  else
    {
      /* TODO */
      return NULL;
    }
}

static void
es_error_free(EsObject* object)
{
  /* DO NOTHING */
}

static int
es_error_equal(const EsObject* self, const EsObject* other)
{
  return (self == other)? 1: 0;
}

static void
es_error_print(const EsObject* object, FILE* fp)
{
  const char* string;


  string = es_error_get(object);
  fprintf(fp, "#%s", string);
}



/*	$NetBSD: hash_func.c,v 1.11 2007/02/03 23:46:09 christos Exp $	*/

/*-
 * Copyright (c) 1990, 1993
 *	The Regents of the University of California.  All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Margo Seltzer.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
/*
 * HASH FUNCTIONS
 *
 * Assume that we've already split the bucket to which this key hashes,
 * calculate that bucket, and check that in fact we did already split it.
 *
 * This came from ejb's hsearch.
 */
#define PRIME1		37
static unsigned int
hash(const char* keyarg)
{
  unsigned int len;
  const unsigned char *key;
  unsigned int h;


  len = strlen(keyarg);

  /* Convert string to integer */
  for (key = (unsigned char*)keyarg, h = 0; len--;)
    h = h * PRIME1 ^ (*key++ - ' ');
  h %= OBARRAY_SIZE;
  return (h);
}


/*
 * Print
 */
void
es_print           (const EsObject* object,
		    FILE*           out)
{
  class_of(object)->print(object, out? out: stdout);
}


char*
es_print_to_string (EsObject*        object)
{
#ifdef __GLIBC__
  char *bp;
  size_t size;
  FILE* out;


  out = open_memstream (&bp, &size);
  es_print(object, out);
  fclose(out);
  
  return bp;
#else
  return NULL;
#endif 
}



/* 
 * Read
 */
typedef struct _Token Token;
struct _Token
{
  char*  buffer;
  size_t filled;
  size_t allocated;
};
static Token* token_new   (char seed);
static void   token_free  (Token* token);
static Token* token_append(Token* token, char c);

static Token  eof_token;
#define EOF_TOKEN         (&eof_token)
static Token  open_paren_token;
#define OPEN_PAREN_TOKEN  (&open_paren_token)
static Token  close_paren_token;
#define CLOSE_PAREN_TOKEN (&close_paren_token)

static Token*   get_token      (FILE* in);
static void     skip_to_newline(FILE* in);
static int      is_whitespace    (char c);
static int      is_paren_open    (char c);
static int      is_paren_close   (char c);
static int      is_comment_start (char c);
static int      is_string_start  (char c);
static int      is_fence_start   (char c);

typedef 
       int (*TerminalDetector) (int c);

static int is_string_end       (int c);
static int is_fence_end        (int c);
static int is_separator        (int c);

static Token* get_sequence      (FILE* fp, 
				 Token* seed,
				 TerminalDetector is_terminator,
				 int              include_terminator);
static Token* get_string        (FILE* fp, char seed);
static Token* get_escaped_symbol(FILE* fp, char seed);
static Token* get_symbol        (FILE* fp, char seed);

static EsObject* fill_list    (FILE*  fp);
static EsObject* make_atom    (Token* token);
static EsObject* make_string  (char* t);
static EsObject* make_symbol  (char* t, 
			       int is_wrapped);
static EsObject* make_boolean (int b);
static int  is_integer   (const char* t, 
			  int* i);
static EsObject* make_integer (int  i);
static int  is_real      (const char* t, 
			  double* d);
static EsObject* make_real    (double d);    


EsObject*    
es_read            (FILE* in)
{
  Token* t;
  EsObject* r;


  in = in? in: stdin;

  t = get_token(in);

  if (t == NULL)
    return ES_READER_ERROR;
  else if (t == EOF_TOKEN)
    return ES_READER_EOF;
  else if (t == OPEN_PAREN_TOKEN)
    r = fill_list(in);
  else if (t == CLOSE_PAREN_TOKEN)
    return ES_READER_ERROR;
  else
    r = make_atom(t);

  token_free(t);

  return r;
}


static Token*
get_token(FILE* in)
{
  Token* t;

  int c;
  while (1)
    {
      c = getc(in);

      if (c == EOF)
	{
	  t = EOF_TOKEN;
	  break;
	}
      else
	{
	  char c0;

	  c0 = (char)c;

	  if (is_whitespace(c0))
	    continue;
	  else if (is_comment_start(c0))
	    {
	      skip_to_newline(in);
	      continue;
	    }
	  else if (is_paren_open(c0))
	    {
	      t = OPEN_PAREN_TOKEN;
	      break;
	    }
	  else if (is_paren_close(c0))
	    {
	      t = CLOSE_PAREN_TOKEN;
	      break;
	    }
	  else if (is_string_start(c0))
	    {
	      t = get_string(in, c0);
	      break;
	    }
	  else if (is_fence_start(c0))
	    {
	      t = get_escaped_symbol(in, c0);
	      break;
	    }
	  else
	    {
	      t = get_symbol(in, c0);
	      break;
	    }
	}
    }

  return t;
}

static int
is_whitespace    (char c)
{
  static const char* const whitespace_chars = " \t\n\r\f";

  return strchr(whitespace_chars, c)? 1: 0;
}
    
static int 
is_paren_open    (char c)
{
  return (c == '(')? 1: 0;
}
    
static int
is_paren_close   (char c)
{
  return (c == ')')? 1: 0;
}
    
static int 
is_comment_start (char c)
{
  return (c == ';')? 1: 0;
}

static int 
is_string_start  (char c)
{
  return (c == '"')? 1: 0;
}

static int
is_fence_start  (char c)
{
  return (c == '|')? 1: 0;
}

static void
skip_to_newline  (FILE* fp)
{
  int c;


  while (1)
    {
      char c0;
      

      c = fgetc(fp);
      if (c == EOF)
	break;
	  
      c0 = (char)c;
      if (c0 == '\n')
	break;
    }
}

static int
is_string_end    (int c)
{
  return ((char)(c) == '"')? 1: 0;
}

static int
is_fence_end     (int c)
{
  return ((char)(c) == '|')? 1: 0;
}

static int
is_separator     (int c)
{
  if (c == EOF)
    return 1;
  else
    {
      char c0;


      c0 = (char)(c);
      if (is_whitespace(c0)
	  || is_comment_start(c0)
	  || is_paren_open(c0)
	  || is_paren_close(c0)
	  || is_string_start(c0)
	  || is_fence_start(c0))
	return 1;
    }

  return 0;
}

static Token*
get_string         (FILE* fp,
		    char seed)
{
  Token* t;

  t = token_new(seed);
  return get_sequence(fp, t, is_string_end, 1);
}
    
static Token*
get_escaped_symbol (FILE* fp,
		    char seed)
{
  Token* t;

  t = token_new(seed);
  return get_sequence(fp, t, is_fence_end, 1);
}
    
static Token*
get_symbol         (FILE* fp,
		    char seed)
{
  Token* t;

  t = token_new(seed);
  return get_sequence(fp, t, is_separator, 0);
}
    

static Token*
get_sequence       (FILE* fp,
		    Token* seed,
		    TerminalDetector     is_terminator,
		    int             include_terminator)
{
  int c;
  int in_escape;
      
  in_escape = 0;
  while (1)
    {
      c = getc(fp);
      if (EOF == c)
	{
	  if (in_escape)
	    {
	      token_free(seed);
	      return NULL;
	      /*
		throw ReadError("no character after escape character: " + seed);
	      */
	    }
	  else if (is_terminator(c))
	    break;
	  else
	    {
	      token_free(seed);
	      return NULL;

	      /*
		throw ReadError("got EOF during reading a sequence: " + seed);
	      */
	    }
	}
      else
	{
	  char c0;

	      
	  c0 = (char)(c);
	  if (in_escape)
	    {
	      switch (c0)
		{
		case 'n': c0 = '\n'; break;
		case 't': c0 = '\t'; break;
		case 'r': c0 = '\r'; break;
		case 'f': c0 = '\f'; break;
		default:  c0 = c0  ; break;
		}
	      seed = token_append(seed, c0);
	      in_escape = 0;
	      continue;
	    }
	  else if (c0 == '\\')
	    {
	      in_escape = 1;
	      continue;
	    }
	  else if (is_terminator(c))
	    {
	      if (include_terminator)
		seed = token_append(seed, c0);
	      else 
		{
		  if (ungetc(c, fp) == EOF)
		    {
		      token_free(seed);
		      return NULL;
		    }
		}
	      break;
	    }
	  else
	    {
	      seed = token_append(seed, c0);
	      in_escape = 0;
	      continue;
	    }
	}
    }
  return seed;
}


/* 
(let ((total-length 0)
      (count-symbol 0))
  (mapatoms (lambda (s) (setq total-length (+ total-length (length (symbol-name s)))
			      count-symbol (+ 1 count-symbol)
			      )))
  (/ total-length count-symbol)) => 15
*/
#define DEFAULT_TOKEN_LENGHT 16
static Token*
token_new   (char seed)
{
  Token *t;


  t = malloc(sizeof(Token));
  if (!t)
    return NULL;

  t->buffer = calloc(1, sizeof(char) * DEFAULT_TOKEN_LENGHT);
  if (!t->buffer)
    {
      free(t);
      return NULL;
    }
  
  t->filled = 0;
  t->buffer[t->filled++] = seed;
  t->buffer[t->filled++]   = '\0';
  t->allocated = DEFAULT_TOKEN_LENGHT;

  return t;
}

static void
token_free  (Token* token)
{
  if ((token == NULL)
      || (token == EOF_TOKEN)
      || (token == OPEN_PAREN_TOKEN)
      || (token == CLOSE_PAREN_TOKEN))
    return;
      
      
  free(token->buffer);
  token->buffer = NULL;
  free(token);
}

static Token*
token_append(Token* t, char c)
{
  size_t d;
  

  d = t->allocated - t->filled;
  if (d < 1)
    {
      char* tmp;

      tmp = t->buffer;
      t->buffer = realloc(t->buffer, t->allocated *= 2);
      if (!t->buffer)
	{
	  t->buffer = tmp;
	  token_free(t);
	  return NULL;
	}
    }

  t->buffer[t->filled - 1] = c;
  t->buffer[t->filled++]   = '\0';
  
  return t;
}

static EsObject*
fill_list (FILE* fp)
{
  EsObject* r;
  Token*    t;

  r = es_nil;
  while(1)
    {
      t = get_token(fp);
      if (t == NULL)
	{
	  es_object_unref(r);
	  return ES_READER_ERROR;
	}
      else if (t == EOF_TOKEN)
	{
	  es_object_unref(r);
	  return ES_READER_ERROR;
	}
      else if (t == CLOSE_PAREN_TOKEN)
	{
	  EsObject* tmp;
	  
	  tmp = es_cons_reverse(r);
	  es_object_unref(r);
	  r = tmp;
	  break;
	}
      else if (t == OPEN_PAREN_TOKEN)
	{
	  EsObject* car;
	  EsObject* cdr;

	  car = fill_list(fp);
	  if (es_error_p(car))
	    {
	      es_object_unref(r);
	      r = car;
	      break;
	    }
	  
	  cdr = r;
	  r = es_cons(car, cdr);
	  es_object_unref(car);
	  es_object_unref(cdr);
	  
	  continue;
	}
      else
	{
	  EsObject* car;
	  EsObject* cdr;

	  car = make_atom(t);
	  token_free(t);
	  /* TODO: check error */
	  cdr = r;
	  r = es_cons(car, cdr);
	  es_object_unref(car);
	  es_object_unref(cdr);
	  
	  continue;
	}
    }

  return r;
}


static EsObject* 
make_atom          (Token*   token)
{
  EsObject* r;
  char* t;

  int i;
  double d;


  t = token->buffer;

  if (t[0] == '"')
    r = make_string(t);
  else if (t[0] == '|')
    r = make_symbol(t, 1);
  else if (strcmp(t, "#t") == 0)
    r = make_boolean(1);
  else if (strcmp(t, "#f") == 0)
    r = make_boolean(0);
  else if (is_integer(t, &i))
    {
      r = make_integer(i);
    }
  else if (is_real(t, &d))
    {
      r = make_real(d);
    }
  else 
    r = make_symbol(t, 0);

  return r;
}

static EsObject* 
make_string  (char* t)
{
  size_t len;


  len = strlen(t);
  t[(len - 1)] = '\0';
  return es_string_new(t + 1);
}

static EsObject* 
make_symbol  (char* t, 
	      int is_wrapped)
{
  if (is_wrapped)
    {
      size_t len;

      len = strlen(t);
      t[(len - 1)] = '\0';
      t = t + 1;
    }

  return es_symbol_intern(t);
}


static EsObject* 
make_boolean (int b)
{
  return es_boolean_new(b);
}

static int  
is_integer   (const char* cstr, 
	      int* i)
{
  char* endptr;
  long  r;

  endptr = NULL;
  errno = 0;
  r = strtol(cstr, &endptr, 10);

  if (errno || (endptr == cstr))
    return 0;
  else if (*endptr != '\0')
    return 0;

  if ((r > INT_MAX) || r < INT_MIN)
    {
      /* TODO: What I should do?
	 TODO: Set error */
      /* 
      throw ReadError("Too large integer for `int': " + r);
      */
      return 0;
    }

  *i = r;
  return 1;
}

static EsObject* 
make_integer (int  i)
{
  return es_integer_new(i);
}

static int 
is_real      (const char* cstr,
	      double* d)
{
  char* endptr;

  endptr = NULL;
  errno = 0;
  *d = strtod(cstr, &endptr);
      
  if (errno || (endptr == cstr))
    return 0;
  else if (*endptr != '\0')
    return 0;

  /* TODO: INF, NAN... */
  return 1;
}

static EsObject* 
make_real (double d)
{
  return es_real_new(d);
}



EsObject*
es_read_from_string(char* buf,
		    char** saveptr)
{
#ifdef __GLIBC__
  FILE* in;
  EsObject* o;


  in = fmemopen(buf, strlen(buf), "r");
  o = es_read(in);
  if (saveptr )
    *saveptr = buf + ftell(in);
  fclose(in);

  return o;
#else
  return ES_PROC_UNIMPLEMENTED;
#endif 
}



typedef struct _EsAutounrefPool EsAutounrefPool;
typedef struct _EsChain EsChain;

struct _EsChain
{
  EsObject* object;
  EsChain*  next;
};

struct _EsAutounrefPool
{
  EsAutounrefPool * parent_pool;
  EsChain*          chain;
};

static EsAutounrefPool * currrent_pool;

static EsAutounrefPool* es_autounref_pool_new(void);
static void             es_autounref_pool_free(EsAutounrefPool* pool);
static EsChain*         es_chain_new(EsObject* object);
static void             es_chain_free(EsChain* chain);


void
es_autounref_pool_push(void)
{
  EsAutounrefPool* r;

  r = es_autounref_pool_new();
  r->parent_pool = currrent_pool;
  currrent_pool = r;
}

void
es_autounref_pool_pop (void)
{
  EsAutounrefPool *tmp;

  tmp = currrent_pool;
  currrent_pool = tmp->parent_pool;

  es_autounref_pool_free(tmp);
}

static void
es_autounref_pool_free(EsAutounrefPool* pool)
{
  pool->parent_pool = NULL;
  es_chain_free(pool->chain);
  pool->chain = NULL;
  
  free(pool);  
}

EsObject*
es_object_autounref   (EsObject* object)
{
  EsChain* r;

  r = es_chain_new(object);
  r->next = currrent_pool->chain;
  currrent_pool->chain = r;
  
  return object;
}

static EsAutounrefPool*
es_autounref_pool_new(void)
{
  EsAutounrefPool* r;

  r = calloc(1, sizeof(EsAutounrefPool));
  return r;
}

static EsChain*
es_chain_new(EsObject *object)
{
  EsChain* r;
  
  r = calloc(1, sizeof(EsChain));
  r->object = object;
  return r;
}

static void
es_chain_free(EsChain *chain)
{
  EsChain *tmp;

  while(chain)
    {
      tmp = chain;
      chain = chain->next;

      es_object_unref(tmp->object);
      tmp->object = NULL;
      tmp->next = NULL;
      free(tmp);
    }
}


#include <stdarg.h>
static EsObject* es_list_va(EsObject* object, va_list ap);

EsObject*
es_list(EsObject* object,...)
{
  EsObject* r;
  va_list ap;

  va_start(ap, object);
  r = es_list_va(object, ap);
  va_end(ap);

  return r;
}

static EsObject*
es_list_va(EsObject* object, va_list ap)
{
  EsObject* r;
  EsObject* p;
  EsObject* tmp;
  
  r = es_nil;
  p = object;
  es_autounref_pool_push();
  do {
    if (p == ES_READER_EOF)
      break;

    r = es_cons((p), es_object_autounref(r));
    p = va_arg(ap, EsObject *);
  } while(1);
  es_autounref_pool_pop();

  tmp = r;
  r = es_cons_reverse(r);
  es_object_unref(tmp);
  
  return r;
}


static EsObject* es_append0(EsObject* tail, EsObject* body);
static EsObject* es_append1(EsObject* tail, EsObject* body0);

EsObject* 
es_append(EsObject* list,...)
{
  EsObject *r;
  EsObject *tmp;
  EsObject *tail;
  EsObject *body;
  va_list ap;
  

  va_start(ap, list);
  r = es_list_va(list, ap);
  va_end(ap);

  tmp = r;
  r = es_cons_reverse(r);
  es_object_unref(tmp);

  /* r */
  tail = es_car(r);
  body = es_cdr(r);
  tmp  = r;
  r = es_append0(tail, body);
  es_object_unref(tmp);

  return r;
}

static EsObject*
es_append0(EsObject* tail, EsObject* body)
{
  if (es_null(body))
    return tail;
  else
    {
      EsObject* car;

      car = es_cons_reverse(es_car(body));
      tail = es_append1(tail, car);
      es_object_unref(car);
      body = es_cdr(body);
      return es_append0(tail, body);
    }
}

static EsObject*
es_append1(EsObject* tail, EsObject* body0)
{
  if (es_null(body0))
    return es_object_ref(tail);
  else
    {
      EsObject* car;
      EsObject* r;
      
      car  = es_car(body0);
      tail = es_cons(car, tail);

      r = es_append1(tail, es_cdr(body0));
      es_object_unref(tail);
      return r;
    }
}



static EsObject* pattern_d         = NULL;
static EsObject* pattern_f         = NULL;
static EsObject* pattern_F         = NULL;
static EsObject* pattern_s         = NULL;
static EsObject* pattern_S         = NULL;
static EsObject* pattern_b         = NULL;
static EsObject* pattern_rest   = NULL;
static EsObject* pattern_unquote      = NULL;

static EsObject* pattern_i_d       = NULL;
static EsObject* pattern_i_f       = NULL;
static EsObject* pattern_i_F       = NULL;
static EsObject* pattern_i_s       = NULL;
static EsObject* pattern_i_S       = NULL;
static EsObject* pattern_i_b       = NULL;
static EsObject* pattern_i_rest = NULL;
static EsObject* pattern_i_unquote    = NULL;

static void
pattern_init(void)
{
  if (!pattern_d) (pattern_d = es_symbol_intern("%d"));
  if (!pattern_f) (pattern_f = es_symbol_intern("%f"));
  if (!pattern_F) (pattern_F = es_symbol_intern("%F"));
  if (!pattern_s) (pattern_s = es_symbol_intern("%s"));
  if (!pattern_S) (pattern_S = es_symbol_intern("%S"));
  if (!pattern_b) (pattern_b = es_symbol_intern("%b"));
  if (!pattern_rest) (pattern_rest = es_symbol_intern("%@"));
  if (!pattern_unquote) (pattern_unquote = es_symbol_intern("%,"));

  if (!pattern_i_d) (pattern_i_d = es_symbol_intern("%_d"));
  if (!pattern_i_f) (pattern_i_f = es_symbol_intern("%_f"));
  if (!pattern_i_F) (pattern_i_F = es_symbol_intern("%_F"));
  if (!pattern_i_s) (pattern_i_s = es_symbol_intern("%_s"));
  if (!pattern_i_S) (pattern_i_S = es_symbol_intern("%_S"));
  if (!pattern_i_b) (pattern_i_b = es_symbol_intern("%_b"));
  if (!pattern_i_rest) (pattern_i_rest = es_symbol_intern("%_@"));
  if (!pattern_i_unquote) (pattern_i_unquote = es_symbol_intern("%_,"));
}

static EsObject*
es_vrealize_atom(EsObject* fmt_object, va_list ap)
{
  pattern_init();
  
  if (fmt_object == pattern_d)
    return es_integer_new(va_arg(ap, int));
  else if (fmt_object == pattern_f)
    return es_real_new(va_arg(ap, double));
  else if (fmt_object == pattern_s)
    return es_string_new(va_arg(ap, char *));
  else if (fmt_object == pattern_S)
    return es_symbol_intern(va_arg(ap, char *));
  else if (fmt_object == pattern_b)
    return es_boolean_new(va_arg(ap, int));
  else if (fmt_object == pattern_unquote)
    return es_object_ref(va_arg(ap, EsObject*));
  else
    return es_object_ref(fmt_object);

}

static EsObject*
es_vrealize(EsObject* fmt_object, va_list ap)
{
  if (es_cons_p(fmt_object))
    {
      EsObject* car;
      EsObject* cdr;
      EsObject* kar;
      EsObject* kdr;
      EsObject* r;

      car = es_car(fmt_object);

      if (car == pattern_rest)
	r = es_object_ref(va_arg(ap, EsObject*));
      else
	{
	  cdr = es_cdr(fmt_object);
      
	  kar = es_vrealize(car, ap);
	  kdr = es_vrealize(cdr, ap);
      
	  r = es_cons(kar, kdr);
	  es_object_unref(kar);
	  es_object_unref(kdr);
	}
      return r;
    }
  else
    return es_vrealize_atom(fmt_object, ap);
}

EsObject*
es_realize   (EsObject* fmt_object,...)
{
  EsObject* object;
  va_list ap;

  if (es_error_p(fmt_object))
    return es_object_ref(fmt_object);

  va_start(ap, fmt_object);
  object = es_vrealize(fmt_object, ap);
  va_end(ap);

  return object;
}

EsObject*
es_srealize  (const char* fmt,...)
{
  EsObject* fmt_object;
  EsObject* object;
  va_list ap;

  fmt_object = es_read_from_string(fmt, NULL);
  if (es_error_p(fmt_object))
    return fmt_object;
  
  va_start(ap, fmt);
  object = es_vrealize(fmt_object, ap);
  va_end(ap);

  es_object_unref(fmt_object);

  return object;
}


static EsObject*
es_vmatch_atom_input(EsObject* input, EsObject* fmt_object, va_list ap)
{
  return ES_READER_ERROR;
}

static EsObject*
es_vmatch_atom_fmt(EsObject* input, EsObject* fmt_object, va_list ap)
{
  if (fmt_object == pattern_unquote)
    *(va_arg(ap, EsObject**)) = /* es_object_ref */(input);
  else if (fmt_object == pattern_i_unquote)
    ;
  else
    return ES_READER_ERROR;

  return fmt_object;
}

static EsObject*
es_vmatch_atom(EsObject* input, EsObject* fmt_object, va_list ap)
{
  if (fmt_object == pattern_d)
    {
      if (es_integer_p(input))
	*(va_arg(ap, int*)) = es_integer_get(input);
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_i_d)
    {
      if (es_integer_p(input))
	;
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_f)
    {
      if (es_real_p(input))
	*(va_arg(ap, double*)) = es_real_get(input);
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_i_f)
    {
      if (es_real_p(input))
	;
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_F)
    {
      if (es_integer_p(input))
	{
	  int i;
	  
	  i = es_integer_get(input);
	  *(va_arg(ap, double*)) = (double)i;
	}
      else if (es_real_p(input))
	{
	  *(va_arg(ap, double*)) = es_real_get(input);
	}
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_i_F)
    {
      if (es_integer_p(input) || es_real_p(input))
	;
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_s)
    {
      if (es_string_p(input))
	*(va_arg(ap, char**)) = /* strdup */(es_string_get(input));
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_i_s)
    {
      if (es_string_p(input))
	;
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_S)
    {
      if (es_symbol_p(input))
	*(va_arg(ap, char**)) = /* strdup */(es_symbol_get(input));
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_i_S)
    {
      if (es_symbol_p(input))
	;
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_b)
    {
      if (es_boolean_p(input))
	*(va_arg(ap, int*)) = es_boolean_get(input);
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_i_b)
    {
      if (es_boolean_p(input))
	;
      else
	return ES_READER_ERROR;
    }
  else if (fmt_object == pattern_unquote)
    *(va_arg(ap, EsObject**)) = /* es_object_ref */(input);
  else if (fmt_object == pattern_i_unquote)
    ;
  else if (es_object_equal(fmt_object, input))
    ;
  else
    return ES_READER_ERROR;

  return fmt_object;
}

static void
recover(EsObject* fmt_object, va_list aq)
{
  if (es_cons_p(fmt_object))
    {
      recover(es_car(fmt_object), aq);
      recover(es_cdr(fmt_object), aq);
    }
  else
    {
      if (fmt_object == pattern_s
	  || fmt_object == pattern_S)
	{
	  char **s;
	  
	  s = va_arg(aq, char **);
	  /* free */(*s);

	  *s = NULL;
	}
      else if (fmt_object == pattern_rest
	       || fmt_object == pattern_unquote)
	{
	  EsObject** o;

	  o = va_arg(aq, EsObject**);
	  /* es_object_unref */(*o);
	  *o = NULL;
	}
    }
}

static EsObject*
es_vmatch(EsObject* input, EsObject* fmt_object, va_list ap)
{
  pattern_init();
  
  if (es_cons_p(fmt_object) && es_cons_p(input))
    {
      EsObject* fmt_car;
      EsObject* fmt_cdr;
      EsObject* i_car;
      EsObject* i_cdr;

      EsObject* r_car;
      EsObject* r_cdr;

      va_list   aq;

      fmt_car = es_car(fmt_object);

      if (fmt_car == pattern_rest)
	{
	  *(va_arg(ap, EsObject**)) = /* es_object_ref */(input);
	  return fmt_car;
	}
      else if (fmt_car == pattern_i_rest)
	{
	  return fmt_car;
	}

      fmt_cdr = es_cdr(fmt_object);

      i_car   = es_car(input);
      i_cdr   = es_cdr(input);

      va_copy(aq, ap);
      r_car = es_vmatch(i_car, fmt_car, ap);
      if (es_error_p(r_car))
	{
	  va_end(aq);
	  return r_car;
	}
      
      r_cdr = es_vmatch(i_cdr, fmt_cdr, ap);
      if (es_error_p(r_cdr))
	{
	  recover(fmt_car, aq);
	  va_end(aq);
	  return r_cdr;
	}
      va_end(aq);
      return r_cdr;
    }
  else if (es_cons_p(fmt_object))
    {
      return es_vmatch_atom_input(input, fmt_object, ap);
    }
  else if (es_cons_p(input))
    {
      if (fmt_object == pattern_rest)
	{
	  *(va_arg(ap, EsObject**)) = /* es_object_ref */(input);
	  return fmt_object;
	}
      else if (fmt_object == pattern_i_rest)
	return fmt_object;
      else
	return es_vmatch_atom_fmt(input, fmt_object, ap);
    }
  else
    {
      return es_vmatch_atom(input, fmt_object, ap);
    }
}

int
es_match(EsObject* input, EsObject* fmt_object,...)
{
  EsObject* object;
  va_list ap;

  va_start(ap, fmt_object);
  object = es_vmatch(input, fmt_object, ap);
  va_end(ap);

  return !(es_error_p(object));
}

int
es_smatch   (EsObject* input, const char* fmt,...)
{
  int r;
  EsObject* object;
  EsObject* fmt_object;
  va_list ap;

  fmt_object = es_read_from_string(fmt, NULL);
  if (es_error_p(fmt_object))
    return 0;

  va_start(ap, fmt);
  object = es_vmatch(input, fmt_object, ap);
  va_end(ap);

  r = !(es_error_p(object));
  es_object_unref(fmt_object);

  return r;
}

EsObject*
es_pget (EsObject* plist, EsObject* key, EsObject* default_value)
{
  if (es_cons_p(plist))
    {
      EsObject* car;
      EsObject* cdr;
      EsObject* cadr;
      EsObject* cddr;

      car = es_car(plist);
      cdr = es_cdr(plist);

      if (es_cons_p(cdr))
	{
	  cadr = es_car(cdr);
	  cddr = es_cdr(cdr);
	  
	  if (es_object_equal(car, key))
	    return cadr;
	  else
	    return es_pget(cddr, key, default_value);
	}
      else
	return ES_READER_ERROR;
    }
  else
    return ES_READER_EOF;
}



#if 0
int
main(int argc, char** argv)
{
  EsObject* tmp;

  es_print(es_symbol_intern(""), NULL);
  es_autounref_pool_push();
  es_print(es_object_autounref(es_append(es_object_autounref(es_list(es_object_autounref(es_integer_new(1)),
								     es_object_autounref(es_integer_new(2)),
								     ES_READER_EOF)),
					 es_object_autounref(es_list(es_object_autounref(es_integer_new(3)),
								     es_object_autounref(es_integer_new(4)),
								     ES_READER_EOF)),
					 ES_READER_EOF)), NULL);

  es_print(es_object_autounref(es_list(es_object_autounref(es_integer_new(1)),
				       ES_READER_EOF)), NULL);
  printf("\n");
  while(1)
    {
      tmp = es_read(NULL);
      es_object_autounref(tmp);
      if (tmp == ES_READER_EOF)
	break;
      
      es_print(tmp, NULL);
      printf("\n");
    }

  es_autounref_pool_pop();


  char * in = "(1 2 3)";
  char * saveptr = NULL;
  EsObject* r;
  
  r = es_read_from_string(in, &saveptr);
  printf("=>");
  es_print(r, NULL);
  printf("\n");

  char* out;
  out = es_print_to_string(r);
  printf("==>%s\n", out);
  free(out);
  es_object_unref(r);

  EsObject* pattern;

  pattern = es_read_from_string("(%d (%d (%d () %f %s %S %b %@)) %,)", 
				NULL);
  r = es_realize(pattern, 
		 1,
		 2,
		 3,
		 3.14,
		 "abc",
		 "symbol",
		 1,
		 es_read_from_string("(a b c)", NULL),
		 es_list(es_nil, es_true, es_false, ES_READER_EOF)
		 );
  es_print(r, NULL);
  
  {
    char *i;
    int j;

    EsObject * pattern;
    EsObject * input;
    int r;
    
    input   = es_read_from_string("(\"abc\" 2 3)", NULL);
    pattern = es_read_from_string("(%s %_F %d)", NULL);
    r = es_match(input, pattern, &i, &j);
    if (r)
      {
	printf("\n;; %s %d\n", i, j);
	/* free */(i);
      }
    else
      printf("\n;; error in matching\n");
    es_object_unref(input);
    es_object_unref(pattern);
  }

  return 0;
}
#endif
