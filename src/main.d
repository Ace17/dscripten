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
import game;

SDL_Surface* screen;

enum SPEED = 30;

extern(C) void quit();

extern(C)
void startup()
{
  SDL_Init(SDL_INIT_EVERYTHING);
  screen = SDL_SetVideoMode(640, 480, 32, 0);
  printf("Keys: WASD\n");
  init();
}

extern(C)
void mainLoop()
{
  auto cmd = processInput();
  update(cmd);
  drawScreen();
}

Vec2 processInput()
{
  SDL_PumpEvents();
  auto keyboard = SDL_GetKeyState(null);
  if(keyboard[SDLK_ESCAPE])
    quit();
  if(keyboard[SDLK_F2])
    init();

  Vec2 desiredVel;
  if(keyboard[SDLK_a])
    desiredVel.x += -SPEED;
  if(keyboard[SDLK_d])
    desiredVel.x += +SPEED;
  if(keyboard[SDLK_w])
    desiredVel.y += -SPEED;
  if(keyboard[SDLK_s])
    desiredVel.y += +SPEED;

  return desiredVel;
}

void drawScreen()
{
  SDL_FillRect(screen, null, 0x80808080);
  boxColor(screen, pos.x, pos.y, pos.x+10, pos.y+10, 0xFFFFFFFF);
  SDL_Flip(screen);
}

