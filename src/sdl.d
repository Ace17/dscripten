extern(C):

enum SDLK_ESCAPE = 27;
enum SDLK_SPACE = 32;
enum SDLK_UP    = 273;
enum SDLK_DOWN  = 274;
enum SDLK_RIGHT = 275;
enum SDLK_LEFT  = 276;

enum SDLK_a     = 97;
enum SDLK_b     = 98;
enum SDLK_c     = 99;
enum SDLK_d     = 100;
enum SDLK_e     = 101;
enum SDLK_f     = 102;
enum SDLK_g     = 103;
enum SDLK_h     = 104;
enum SDLK_i     = 105;
enum SDLK_j     = 106;
enum SDLK_k     = 107;
enum SDLK_l     = 108;
enum SDLK_m     = 109;
enum SDLK_n     = 110;
enum SDLK_o     = 111;
enum SDLK_p     = 112;
enum SDLK_q     = 113;
enum SDLK_r     = 114;
enum SDLK_s     = 115;
enum SDLK_t     = 116;
enum SDLK_u     = 117;
enum SDLK_v     = 118;
enum SDLK_w     = 119;
enum SDLK_x     = 120;
enum SDLK_y     = 121;
enum SDLK_z     = 122;

ubyte* SDL_GetKeyState(int*);
void SDL_PumpEvents();
void boxColor(SDL_Surface* s, int x1, int y1, int x2, int x2, uint c);
int SDL_Init(uint flags);
const uint SDL_INIT_VIDEO   = 0x00000020;
SDL_Surface* SDL_SetVideoMode(int width, int height, int bpp, uint flags);
int SDL_FillRect (SDL_Surface *dst, SDL_Rect *dstrect, uint color);
int SDL_Flip(SDL_Surface *screen);

alias SDL_Surface = void;
alias SDL_Rect = void;

