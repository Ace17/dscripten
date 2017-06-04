// tests that the minimalistic D runtime/helpers actually works
pragma(LDC_no_moduleinfo);
import standard;

extern(C) void quit();

extern(C)
void startup()
{
  runTest!("struct: ctor/dtor", testStructCtorAndDtor);

  runTest!("class: empty", testEmptyClass);
  runTest!("class: ctor/dtor", testClassCtorAndDtor);
  runTest!("class: derived", testDerivedClass);
}

extern(C)
void mainLoop()
{
  quit();
}

///////////////////////////////////////////////////////////////////////////////

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

  auto c = newObject!C;
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
    Base c = newObject!D;
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
    auto s = newStruct!MyStruct(123);
    check(s.initialized == 7654);
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

void check(bool condition, string file=__FILE__, int line=__LINE__) nothrow
{
  if(condition)
    return;

  printf("Check failed at %s(%d)\n", file.ptr, line);
  exit(1);
}

