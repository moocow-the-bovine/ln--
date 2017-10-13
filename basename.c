#include <stdio.h>
#include <libgen.h>
#include <string.h>

int main(int argc, const char **argv)
{
  const char *base = basename((char*)argv[1]);
  printf("%s\n", base);
  return 0;
}
