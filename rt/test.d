pragma(LDC_no_moduleinfo);
import standard;

extern(C) void quit();

extern(C)
void startup()
{
  testClass();
}

extern(C)
void mainLoop()
{
  quit();
}

void testClass()
{
  printf("HELLO\n");
  ubyte[128] buffer;
  auto c = newObject!C;
  c.f();
  c = newObject!D;
  c.f();
}

class C
{
  void f()
  {
    printf("YO: C\n");
  }
}

class D : C
{
  override void f()
  {
    printf("YO: D\n");
  }
}

