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
typedef int (*lnppLinkFunc) (const char *srcfile, const char *dstfile);
lnppLinkFunc ln_func = NULL;

const char *ln_mode_str = "ANY";

#define BUFSIZE 512
#define BUFSTEP 512

struct gengetopt_args_info args;

const char *prog;

//======================================================================
// Functions

int is_symlink(const char *path)
{
  struct stat path_lstat;
  if (lstat(path,&path_lstat)==-1) {
    if (errno==ENOENT) return 0;
    fprintf(stderr, "%s: lstat() failed for path '%s': %s\n", prog, path, strerror(errno));
    exit(errno);
  }
  return S_ISLNK(path_lstat.st_mode);
}

int is_directory(const char *path)
{
  struct stat path_stat;

  if (args.no_target_directory_flag)
    return 0;
  else if (args.no_dereference_flag && is_symlink(path))
    return 0;

  if (stat(path,&path_stat)==-1) {
    if (errno==ENOENT) return 0;
    fprintf(stderr, "%s: stat() failed for path '%s': %s\n", prog, path, strerror(errno));
    exit(errno);
  }
  return S_ISDIR(path_stat.st_mode);
}


int link_hard(const char *src, const char *dst)
{ return link(src,dst); }

int link_symbolic(const char *src, const char *dst)
{ return symlink(src,dst); }

int link_any(const char *src, const char *dst)
{
  int rc = link(src,dst);
  if (rc!=0) rc = symlink(src,dst);
  return rc;
}

void link_generic(const char *src, const char *dst)
{
  if (args.verbose_flag)
    fprintf(stderr, "LINK %s: `%s' -> `%s'\n", ln_mode_str, dst, src);

  //-- try to force-remove pre-existing dst if requested
  if (args.force_flag) {
    if (access(dst,F_OK) != 0) {
      fprintf(stderr, "%s: refusing to remove existing file `%s': access denied\n", prog, dst);
      exit(255);
    }
    if (strcmp(src,dst)==0) {
      fprintf(stderr, "%s: refusing to remove existing file `%s': source and target paths are identical\n", prog, src);
      exit(255);
    }
    else if (unlink(dst) != 0) {
      fprintf(stderr, "%s: failed to remove existing file `%s': %s\n", prog, dst, strerror(errno));
      exit(255);
    }
  }

  //-- actually link
  if ((*ln_func)(src,dst) != 0) {
    fprintf(stderr, "%s: failed to create %s link `%s' -> `%s': %s\n", prog, ln_mode_str, dst, src, strerror(errno));
    exit(255);
  }
}

void link_generic_multi(int argc, const char **argv, const char *dstdir)
{
  size_t buflen=BUFSIZE, dirlen=strlen(dstdir), dstlen;
  char  *dstbuf = (char*)malloc(buflen*sizeof(char));
  const char *dstbase;
  int i;

  if (!dstbuf) {
    fprintf(stderr, "%s: malloc failed for LINK_NAME buffer: %s\n", prog, strerror(errno));
    exit(2);
  }

  for (i=0; i < argc; ++i) {
    dstbase = basename((char*)argv[i]);

    //-- re-allocate buffer if required
    dstlen  = dirlen + strlen(dstbase) + 2;
    if (dstlen > buflen) {
      buflen = (1+dstlen/BUFSTEP) * BUFSTEP;
      dstbuf = realloc(dstbuf, buflen);
      if (!dstbuf) {
	fprintf(stderr, "%s: realloc failed for LINK_NAME buffer: %s\n", prog, strerror(errno));
	exit(2);
      }
    }

    //-- setup target link name
    strcpy(dstbuf,dstdir);
    dstbuf[dirlen] = '/';
    strcpy(dstbuf+dirlen+1,dstbase);

    //-- actual link call
    link_generic(argv[i], dstbuf);
  }

  //-- cleanup
  if (dstbuf)
    free(dstbuf);
}


//======================================================================
// MAIN
int main(int argc, const char **argv)
{
  //-- command-line processing
  prog = basename((char*)argv[0]);
  if (cmdline_parser(argc, (char**)argv, &args) != 0)
    exit(1);

  //-- sanity checks: link mode
  if      (args.hard_flag)     { ln_func=link_hard;     ln_mode_str="HARD"; }
  else if (args.symbolic_flag) { ln_func=link_symbolic; ln_mode_str="SYMBOLIC"; }
  else                         { ln_func=link_any;      ln_mode_str="ANY"; }
  
  //-- guts: dispatch by calling convention
  if (args.target_directory_arg && !args.no_target_directory_flag) {
    //-- ln [OPTION]... TARGET... DIRECTORY     (4th form)
    link_generic_multi(args.inputs_num, (const char **)args.inputs, args.target_directory_arg);
  }
  else if (args.inputs_num > 1 && is_directory(args.inputs[args.inputs_num-1])) {
    //-- ln [OPTION]... TARGET... DIRECTORY     (3rd form)
    link_generic_multi(args.inputs_num-1, (const char **)args.inputs, args.inputs[args.inputs_num-1]);
  }
  else if (args.inputs_num==1) {
    //-- ln [OPTION]... TARGET                  (2nd form)
    link_generic(args.inputs[0], basename(args.inputs[0]));
  }
  else if (args.inputs_num==2) {
    //-- ln [OPTION]... [-T] TARGET LINK_NAME   (1st form)
    link_generic(args.inputs[0], args.inputs[1]);
  }
  else if (args.inputs_num > 2 && !is_directory(args.inputs[args.inputs_num-1])) {
    //-- more than 2 args, but last one ain't a directory
    fprintf(stderr, "%s: target `%s' is not a directory\n", prog, args.inputs[args.inputs_num-1]);
    exit(2);
  }
  else {
    fprintf(stderr, "%s: failed to parse command-line arguments\n", prog);
    exit(1);
  }
  
  
  return 0;
}
