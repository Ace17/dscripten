#include <stdint.h>
#include <stdio.h>

// make link work. will most probably crash if actually used during runtime.
int _d_dso_registry;
int _d_assert_msg;
int _d_switch_error;

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
  printf("Goodbye!\n");
  mustQuit = 1;
}

