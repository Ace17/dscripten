#include <stdio.h>
#include <stdlib.h>

///////////////////////////////////////////////////////////////////////////////

void not_implemented(const char* file, int line)
{
  printf("Not implemented: %s(%d)\n", file, line);
  exit(123);
}

#define NOT_IMPLEMENTED not_implemented(__FILE__, __LINE__)

///////////////////////////////////////////////////////////////////////////////
// make link work. will most probably crash if actually used during runtime.
// can't get rid of those, seems to be refered-to by compiler-inserted code
int _D10TypeInfo_v6__initZ;
int _D10TypeInfo_m6__initZ;
int _D11TypeInfo_Ai6__initZ;
void _d_throw_exception() { NOT_IMPLEMENTED; }
///////////////////////////////////////////////////////////////////////////////

