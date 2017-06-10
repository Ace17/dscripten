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

