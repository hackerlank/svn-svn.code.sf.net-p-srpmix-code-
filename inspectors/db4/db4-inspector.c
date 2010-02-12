#include <db.h>
#include <stdio.h>


void
print_usage(const char* prog, FILE * out)
{
  fprintf(out, "Usage: \n");
  fprintf(out, "	%s DB4FILE\n", prog);
  fprintf(out, "\n");
  fprintf(out, "Example: \n");
  fprintf(out, "	%s /var/lib/rpm/Packages\n", prog);
}

static const char*
inspect_db_DBTYPE_to_str(DBTYPE type)
{
  switch(type)
    {
#define cr(X)  case DB_ ## X: return "DB_" # X
      cr(BTREE);
      cr(HASH);
      cr(RECNO);
      cr(QUEUE);
      cr(UNKNOWN);
    default:
      return "WRONGTYPE";
    }
}

int
inspect_db(DB* dbp, FILE* out)
{
  DBTYPE type;
  int ret;

  

  ret = dbp->get_type(dbp, &type);
  if (ret != 0)
    {
      dbp->err(dbp, ret, "Failed in getting type");
      return ret;
    }
  fprintf(out, "Type: %s\n", inspect_db_DBTYPE_to_str(type));


  return 0;
}

int
main(int argc, char** argv)
{
  const char* prog;
  const char* db_file;

  DB* dbp;
  u_int32_t flags;
  int ret;


  prog = argv[0];

  if (argc < 2)
    {
      print_usage(prog, stderr);
      return 1;
    }
  db_file = argv[1];


  ret = db_create(&dbp, NULL, 0);
  if (ret != 0) 
    {
      fprintf(stderr, "%s: %s\n", prog, db_strerror(ret));
      return 2;
    }
  
  flags = DB_RDONLY|0;

  ret = dbp->open(dbp,
		  NULL,
		  db_file,
		  NULL,
		  DB_UNKNOWN,
		  flags,
		  0);
  if (ret != 0)
    {
      dbp->err(dbp, ret, "Failed in opening database: %s", db_file);
      return 2;
    }

  ret = inspect_db(dbp, stdout);
  if (ret != 0)
    {
      dbp->close(dbp, 0);
      return 3;
    }
  
  ret = dbp->close(dbp, 0);
  if (ret != 0)
    {
      dbp->err(dbp, ret, "Failed in closing database: %s", db_file);
      return 2;
    }

  return 0;
}
