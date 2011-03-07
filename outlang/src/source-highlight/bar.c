/*
  a
  b
 */
int
dog(int i)
{
  int j = i * 2;

  return j;
}


int
foo(int i)
{ 
  return dog(i+1);
}

