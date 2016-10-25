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
    static bool constructed;
    static bool destroyed;

    this()
    {
      constructed = true;
    }

    ~this()
    {
      destroyed = true;
    }

    void f()
    {
      called = true;
    }
  }

  // empty class
  {
    static class E
    {
    }

    auto o = newObject!E;
    check(o !is null);
    deleteObject(o);
  }

  // construction/destruction
  {
    auto c = newObject!C;
    check(C.constructed);
    c.f();
    check(C.called);

    deleteObject(c);
    check(C.destroyed);
  }

  static class D : C
  {
    static bool derivedObjectConstructed;
    static bool called;

    this()
    {
      derivedObjectConstructed = true;
    }

    override void f()
    {
      called = true;
    }
  }

  // polymorphism
  {
    C c = newObject!D;
    c.f();
    check(D.called);
    check(D.derivedObjectConstructed);

    deleteObject(c);
  }
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

  {
    auto s = newStruct!S(123);
    check(s.initialized);
    check(s.called);
    check(s.arg == 123);
    check(!s.destroyed);

    deleteStruct(s);
  }
  check(S.destroyed);
}

///////////////////////////////////////////////////////////////////////////////

void check(bool condition, string file=__FILE__, int line=__LINE__)
{
  if(condition)
    return;

  printf("Check failed at %s(%d)\n", file.ptr, line);
  exit(1);
}

