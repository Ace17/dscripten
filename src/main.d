/*
 * Copyright (C) 2016 - Sebastien Alaiwan
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 */
import core.stdc.stdio;

import sdl;
import vec;
static import game;

SDL_Surface* screen;

extern(C) void quit();

extern(C)
void startup()
{
  SDL_Init(SDL_INIT_EVERYTHING);
  screen = SDL_SetVideoMode(640, 480, 32, 0);
  printf("Keys: WASD\n");
  game.init();
}

extern(C)
void mainLoop()
{
  auto cmd = processInput();
  game.update(cmd);
  drawScreen();
}

game.Command processInput()
{
  SDL_PumpEvents();

  game.Command cmd;

  auto keyboard = SDL_GetKeyState(null);
  if(keyboard[SDLK_ESCAPE])
    quit();
  if(keyboard[SDLK_F2])
    game.init();
  if(keyboard[SDLK_a])
    cmd.dir.x += -1;
  if(keyboard[SDLK_d])
    cmd.dir.x += +1;
  if(keyboard[SDLK_w])
    cmd.dir.y += -1;
  if(keyboard[SDLK_s])
    cmd.dir.y += +1;
  if(keyboard[SDLK_SPACE])
    cmd.fire = true;

  return cmd;
}

void drawScreen()
{
  SDL_FillRect(screen, null, 0x20202020);
  int size = 10;
  uint color = game.firing ? 0xFFFFFFFF : 0xCCCCCCCC;
  boxColor(screen, game.pos.x-size/2, game.pos.y-size/2, game.pos.x+size, game.pos.y+size, color);
  SDL_Flip(screen);
}

