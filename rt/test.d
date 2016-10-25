// tests that the minimalistic D runtime/helpers actually works
pragma(LDC_no_moduleinfo);
import standard;

extern(C) void quit();

extern(C)
void startup()
{
  printf("Running tests\n");
  testClass();
  testStruct();
  printf("Tests OK\n");
}

extern(C)
void mainLoop()
{
  quit();
}

///////////////////////////////////////////////////////////////////////////////

void testClass()
{
  static class C
  {
    static bool called;

    void f()
    {
      called = true;
    }
  }

  static class D : C
  {
    static bool called;

    override void f()
    {
      called = true;
    }
  }

  auto c = newObject!C;
  c.f();
  check(C.called);

  c = newObject!D;
  c.f();
  check(D.called);
}

void testStruct()
{
  static struct S
  {
    bool initialized = true;
    bool called;
    int arg;
    this(int arg_)
    {
      called = true;
      arg = arg_;
    }

    static bool destroyed;

    ~this() nothrow
    {
      destroyed = true;
    }
  }

  auto s = createStruct!S(123);
  check(s.initialized);
  check(s.called);
  check(s.arg == 123);
  check(!s.destroyed);

  destroyStruct(s);
  check(s.destroyed);
}

///////////////////////////////////////////////////////////////////////////////

void check(bool condition, string file=__FILE__, int line=__LINE__)
{
  if(condition)
    return;

  printf("Check failed at %s(%d)\n", file.ptr, line);
  exit(1);
}

