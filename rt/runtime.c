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
void _d_allocclass() { NOT_IMPLEMENTED; }
void _d_throw_exception() { NOT_IMPLEMENTED; }
///////////////////////////////////////////////////////////////////////////////

void startup();
void mainLoop();

static int mustQuit;

#ifdef __EMSCRIPTEN__

void emscripten_set_main_loop(void (*function)(), int fps, int simulate_infinite_loop);

int main()
{
  startup();
  emscripten_set_main_loop(&mainLoop, 60, 1);
  return 0;
}

#else

void SDL_Delay(int);

int main()
{
  startup();
  while(!mustQuit)
  {
    mainLoop();
    SDL_Delay(16);
  }
  return 0;
}

#endif

void quit()
{
  mustQuit = 1;
}

