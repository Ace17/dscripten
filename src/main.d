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

enum WIDTH = 640;
enum HEIGHT = 480;

extern(C)
void startup()
{
  SDL_Init(SDL_INIT_EVERYTHING);
  screen = SDL_SetVideoMode(WIDTH, HEIGHT, 32, 0);
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

  static bool debounce;
  if(keyboard[SDLK_F2] || keyboard[SDLK_r])
  {
    if(debounce)
    {
      game.init();
      debounce = false;
    }
  }
  else
    debounce = true;

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
  boxColor(Vec2(0, 0), Vec2(WIDTH, HEIGHT), game.dead ? deadBackgroundColor : backgroundColor);
  int size = 10;
  uint color = game.firing ? 255 : 0;

  drawBox(game.player.pos, playerColor);

  foreach(ref box; game.boxes)
  {
    if(box.enable)
      drawBox(box.pos, enemyColor);
  }

  const border = 10;
  lineRGBA(screen, border, border, WIDTH - border, border, 255, 255, 255, 255);
  lineRGBA(screen, WIDTH - border, border, WIDTH - border, HEIGHT - border, 255, 255, 255, 255);
  lineRGBA(screen, WIDTH - border, HEIGHT - border, border, HEIGHT - border, 255, 255, 255, 255);
  lineRGBA(screen, border, HEIGHT - border, border, border, 255, 255, 255, 255);

  SDL_Flip(screen);
}

const backgroundColor = Color(128, 224, 255, 64);
const deadBackgroundColor = Color(224, 128, 128, 255);
const enemyColor = Color(255, 0, 0, 224);
const playerColor = Color(255, 255, 0, 255);

struct Color
{
  int r, g, b, a;
}

void drawBox(Vec2 pos, Color color)
{
  boxColor(pos, Vec2(10, 10), color);
}

void boxColor(Vec2 pos, Vec2 size, Color color)
{
  boxRGBA(screen, pos.x, pos.y, pos.x + size.x, pos.y + size.y, color.r, color.g, color.b, color.a);
}

