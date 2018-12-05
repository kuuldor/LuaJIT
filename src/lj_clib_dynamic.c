#include "lj_obj.h"

#if LJ_HASFFI

#include "lj_gc.h"
#include "lj_err.h"
#include "lj_tab.h"
#include "lj_str.h"
#include "lj_udata.h"
#include "lj_ctype.h"
#include "lj_cconv.h"
#include "lj_cdata.h"
#include "lj_clib.h"
#include "lj_strfmt.h"

/* -- OS-specific functions ----------------------------------------------- */

#if LJ_TARGET_DLOPEN

#include <dlfcn.h>
#include <stdio.h>

#if defined(RTLD_DEFAULT)
#define CLIB_DEFHANDLE	RTLD_DEFAULT
#elif LJ_TARGET_OSX || LJ_TARGET_BSD
#define CLIB_DEFHANDLE	((void *)(intptr_t)-2)
#else
#define CLIB_DEFHANDLE	NULL
#endif


#if LJ_TARGET_CYGWIN
#define CLIB_SOPREFIX	"cyg"
#else
#define CLIB_SOPREFIX	"lib"
#endif

#if LJ_TARGET_OSX
#define CLIB_SOEXT	"%s.dylib"
#elif LJ_TARGET_CYGWIN
#define CLIB_SOEXT	"%s.dll"
#else
#define CLIB_SOEXT	"%s.so"
#endif

static const char *clib_extname(lua_State *L, const char *name)
{
  if (!strchr(name, '/')
#if LJ_TARGET_CYGWIN
      && !strchr(name, '\\')
#endif
     ) {
    if (!strchr(name, '.')) {
      name = lj_strfmt_pushf(L, CLIB_SOEXT, name);
      L->top--;
#if LJ_TARGET_CYGWIN
    } else {
      return name;
#endif
    }
    if (!(name[0] == CLIB_SOPREFIX[0] && name[1] == CLIB_SOPREFIX[1] &&
	  name[2] == CLIB_SOPREFIX[2])) {
      name = lj_strfmt_pushf(L, CLIB_SOPREFIX "%s", name);
      L->top--;
    }
  }
  return name;
}

/* Check for a recognized ld script line. */
static const char *clib_check_lds(lua_State *L, const char *buf)
{
  char *p, *e;
  if ((!strncmp(buf, "GROUP", 5) || !strncmp(buf, "INPUT", 5)) &&
      (p = strchr(buf, '('))) {
    while (*++p == ' ') ;
    for (e = p; *e && *e != ' ' && *e != ')'; e++) ;
    return strdata(lj_str_new(L, p, e-p));
  }
  return NULL;
}

/* Quick and dirty solution to resolve shared library name from ld script. */
static const char *clib_resolve_lds(lua_State *L, const char *name)
{
  FILE *fp = fopen(name, "r");
  const char *p = NULL;
  if (fp) {
    char buf[256];
    if (fgets(buf, sizeof(buf), fp)) {
      if (!strncmp(buf, "/* GNU ld script", 16)) {  /* ld script magic? */
	while (fgets(buf, sizeof(buf), fp)) {  /* Check all lines. */
	  p = clib_check_lds(L, buf);
	  if (p) break;
	}
      } else {  /* Otherwise check only the first line. */
	p = clib_check_lds(L, buf);
      }
    }
    fclose(fp);
  }
  return p;
}


void *clib_loadlib(lua_State *L, const char *name, int global)
{
  void *h = dlopen(clib_extname(L, name),
		   RTLD_LAZY | (global?RTLD_GLOBAL:RTLD_LOCAL));
  if (!h) {
    const char *e, *err = dlerror();
    if (*err == '/' && (e = strchr(err, ':')) &&
	(name = clib_resolve_lds(L, strdata(lj_str_new(L, err, e-err))))) {
      h = dlopen(name, RTLD_LAZY | (global?RTLD_GLOBAL:RTLD_LOCAL));
      if (h) return h;
      err = dlerror();
    }
    lj_err_callermsg(L, err);
  }
  return h;
}

void clib_unloadlib(CLibrary *cl)
{
  if (cl->handle && cl->handle != CLIB_DEFHANDLE)
    dlclose(cl->handle);
}

void *clib_getsym(CLibrary *cl, const char *name)
{
  void *p = dlsym(cl->handle, name);
  return p;
}

#endif

#endif