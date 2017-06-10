// tests that the minimalistic D runtime/helpers actually works
pragma(LDC_no_moduleinfo);
import standard;

extern(C) void quit();

extern(C)
bool startup()
{
  runTest!("struct: ctor/dtor", testStructCtorAndDtor);

  runTest!("class: empty", testEmptyClass);
  runTest!("class: ctor/dtor", testClassCtorAndDtor);
  runTest!("class: derived", testDerivedClass);

  runTest!("floating point: basic", testFloatingPoint);
  runTest!("arrays: copy", testArrayCopy);

  return false; // don't run mainLoop
}

extern(C)
void mainLoop()
{
  assert(0);
}

///////////////////////////////////////////////////////////////////////////////

float g_f; // global nan-initialized float compile-test

void testFloatingPoint()
{
  check(g_f != g_f);

  float f;
  check(f != f);
}

void testEmptyClass()
{
  static class E
  {
  }

  auto o = new E;
  check(o !is null);
  deleteObject(o);
}

void testClassCtorAndDtor()
{
  static class C
  {
    static bool called;
    static bool constructed;
    static bool destroyed;

    this() nothrow
    {
      constructed = true;
    }

    ~this() nothrow
    {
      destroyed = true;
    }

    void f() nothrow
    {
      called = true;
    }
  }

  auto c = new C;
  check(C.constructed);
  c.f();
  check(C.called);

  deleteObject(c);
  check(C.destroyed);
}

void testDerivedClass()
{
  static class Base
  {
    void f()
    {
    }
  }

  // construction/destruction
  static class D : Base
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
    Base c = new D;
    check(D.derivedObjectConstructed);

    c.f();
    check(D.called);

    deleteObject(c);
  }
}

void testStructCtorAndDtor() nothrow
{
  static struct MyStruct
  {
    int initialized = 7654;
    bool ctorCalled;
    int ctorArg;
    this(int arg_) nothrow
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

  // statically allocated struct
  {
    {
      auto s = MyStruct(123);
      check(s.initialized == 7654);
      check(s.ctorCalled);
      check(s.ctorArg == 123);
      check(!s.dtorCalled);
    }
    check(MyStruct.dtorCalled);
  }

  // dynamically allocated struct
  MyStruct.dtorCalled = false;
  {
    auto s = new MyStruct(123);
    check(s.initialized == 7654);
    check(s.ctorCalled);
    check(s.ctorArg == 123);
    check(!s.dtorCalled);

    deleteStruct(s);
  }
  check(MyStruct.dtorCalled);
}

void testArrayCopy()
{
  int[10] tab;
  tab[] = 4;
  check(tab[0] == 4);
  check(tab[9] == 4);

  int[10] tab2;
  tab2 = tab;
  check(tab2[0] == 4);
  check(tab2[9] == 4);
}

///////////////////////////////////////////////////////////////////////////////

void runTest(string name, alias f)()
{
  printf("Test: %s\n", name.ptr);
  f();
}

void check(bool condition, string file=__FILE__, int line=__LINE__) nothrow
{
  if(condition)
    return;

  printf("Check failed at %s(%d)\n", file.ptr, line);
  exit(1);
}

