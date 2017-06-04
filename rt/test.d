// tests that the minimalistic D runtime/helpers actually works
pragma(LDC_no_moduleinfo);
import standard;

extern(C) void quit();

extern(C)
void startup()
{
  runTest!("class: empty", testEmptyClass);
  runTest!("class: ctor/dtor", testClassCtorAndDtor);
  runTest!("class: derived", testDerivedClass);

  runTest!("struct: ctor/dtor", testStructCtorAndDtor);
}

extern(C)
void mainLoop()
{
  quit();
}

///////////////////////////////////////////////////////////////////////////////

private class C
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

void testEmptyClass()
{
  static class E
  {
  }

  auto o = newObject!E;
  check(o !is null);
  deleteObject(o);
}

void testClassCtorAndDtor()
{
  auto c = newObject!C;
  check(C.constructed);
  c.f();
  check(C.called);

  deleteObject(c);
  check(C.destroyed);
}

void testDerivedClass()
{
  // construction/destruction
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
    check(D.derivedObjectConstructed);

    c.f();
    check(D.called);

    deleteObject(c);
  }
}

void testStructCtorAndDtor()
{
  static struct MyStruct
  {
    bool initialized = true;
    bool ctorCalled;
    int ctorArg;
    this(int arg_)
    {
      ctorCalled = true;
      ctorArg = arg_;
    }

    static bool dtorCalled;

    ~this() nothrow
    {
      dtorCalled = true;
    }
  }

  {
    auto s = newStruct!MyStruct(123);
    check(s.initialized);
    check(s.ctorCalled);
    check(s.ctorArg == 123);
    check(!s.dtorCalled);

    deleteStruct(s);
  }
  check(MyStruct.dtorCalled);
}

///////////////////////////////////////////////////////////////////////////////

void runTest(string name, alias f)()
{
  printf("Test: %s\n", name.ptr);
  f();
}

void check(bool condition, string file=__FILE__, int line=__LINE__)
{
  if(condition)
    return;

  printf("Check failed at %s(%d)\n", file.ptr, line);
  exit(1);
}

