import lib;
import core.stdc.stdio;

SDL_Surface* screen;

Vec2 pos;
Vec2 vel;

enum SPEED = 3;

extern(C)
void startup()
{
  SDL_Init(SDL_INIT_VIDEO);
  screen = SDL_SetVideoMode(640, 480, 32, 0);
  pos = Vec2(100, 100);
  vel = Vec2(SPEED, SPEED);
  printf("Init OK\n");
}

extern(C)
void mainLoop()
{
  update();
  draw();
}

void update()
{
  if(pos.x < 0)
    vel.x = SPEED;
  if(pos.x > 640)
    vel.x = -SPEED;

  if(pos.y < 0)
    vel.y = SPEED;
  if(pos.y > 480)
    vel.y = -SPEED;

  pos += vel;
}

void draw()
{
  SDL_FillRect(screen, null, 0x80808080);
  boxColor(screen, pos.x, pos.y, pos.x+10, pos.y+10, 0xFFFFFFFF);

  SDL_Flip(screen);
}

// SDL imports
extern(C)
{
  void boxColor(SDL_Surface* s, int x1, int y1, int x2, int x2, uint c);
  int SDL_Init(uint flags);
  const uint SDL_INIT_VIDEO		= 0x00000020;
  SDL_Surface* SDL_SetVideoMode(int width, int height, int bpp, uint flags);
  int SDL_FillRect (SDL_Surface *dst, SDL_Rect *dstrect, uint color);
  int SDL_Flip(SDL_Surface *screen);

  alias SDL_Surface = void;

  alias SDL_Rect = void;
}
