pragma (LDC_no_moduleinfo);
pragma (LDC_no_typeinfo);

import sdl;
import vec;
import core.stdc.stdio;
import minirt;

SDL_Surface* screen;

Vec2 pos;
Vec2 vel;

enum SPEED = 3;
enum COLOR
{
  RED,
  GREEN,
  BLUE,
}

extern(C) void quit();

extern(C)
void startup()
{
  SDL_Init(SDL_INIT_VIDEO);
  screen = SDL_SetVideoMode(640, 480, 32, 0);
  pos = Vec2(100, 100);
  vel = Vec2(SPEED, SPEED);
  printf("Init OK\n");
  auto c = COLOR.GREEN;
  printf("%s\n", enumToString(c).ptr);
}

extern(C)
void mainLoop()
{
  processInput();
  update();
  draw();
}

void processInput()
{
  SDL_PumpEvents();
  auto keyboard = SDL_GetKeyState(null);
  if(keyboard[SDLK_ESCAPE])
    quit();

  Vec2 desiredVel = vel;
  if(keyboard[SDLK_a])
    desiredVel.x += -SPEED;
  if(keyboard[SDLK_d])
    desiredVel.x += +SPEED;
  if(keyboard[SDLK_w])
    desiredVel.y += -SPEED;
  if(keyboard[SDLK_s])
    desiredVel.y += +SPEED;

  vel = desiredVel;
}

void update()
{
  if(pos.x < 0)
    vel.x = abs(vel.x);
  if(pos.x > 640)
    vel.x = -abs(vel.x);

  if(pos.y < 0)
    vel.y = abs(vel.y);
  if(pos.y > 480)
    vel.y = -abs(vel.y);

  pos += vel;
  vel *= 9;
  vel /= 10;
}

void draw()
{
  SDL_FillRect(screen, null, 0x80808080);
  boxColor(screen, pos.x, pos.y, pos.x+10, pos.y+10, 0xFFFFFFFF);
  SDL_Flip(screen);
}

