/*-*- Mode: C -*-*/

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#include <stdio.h>
#include <errno.h>
#include <libgen.h> //-- for basename()
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "cmdline.h"

//======================================================================
// Typedefs & Globals
const char *prog = "fexists";

//======================================================================
// Functions

int file_exists(const char *path)
{
  struct stat statbuf;
  return (stat (path, &statbuf) == 0);
}

int link_exists(const char *path)
{
  struct stat statbuf;
  return (lstat (path, &statbuf) == 0);
}

//======================================================================
// MAIN
int main(int argc, const char **argv)
{
  //-- command-line processing
  prog = basename((char*)argv[0]);

  int i;
  for (i=1; i < argc; ++i) {
    const char *path = argv[i];
    int xfile = file_exists(path);
    int xlink = link_exists(path);
    printf("%s : file_exists=%d ; link_exists=%d\n", path, xfile, xlink);
  }

  return 0;
}
