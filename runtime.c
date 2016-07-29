#include <stdint.h>
#include <stdio.h>

typedef struct
{
  void* a;
  void* b;
} Array;

typedef int (*MainFunc)(Array a);

uint32_t _d_run_main(uint32_t argc, uint8_t** argv, uint8_t* ptr)
{
  Array a;
  MainFunc entryPoint = (MainFunc)ptr;
  printf("_d_run_main: %p\n", ptr);
  entryPoint(a);
}

void _d_assert_msg()
{
}

int _d_dso_registry;

void startup();
void mainLoop();

#ifdef __EMSCRIPTEN__

void emscripten_set_main_loop(void function(), int fps, int simulate_infinite_loop);

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
  for(;;)
  {
    mainLoop();
    SDL_Delay(16);
  }
  return 0;
}

#endif

