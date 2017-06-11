// tests that the minimalistic D runtime/helpers actually works
pragma(LDC_no_moduleinfo);
import standard;

extern(C)
int main()
{
  runTest!("struct: ctor/dtor", testStructCtorAndDtor);

  runTest!("class: empty", testEmptyClass);
  runTest!("class: ctor/dtor", testClassCtorAndDtor);
  runTest!("class: derived", testDerivedClass);

  runTest!("floating point: basic", testFloatingPoint);
  runTest!("arrays: copy", testArrayCopy);
  runTest!("arrays: dynamic", testArrayDynamic);

  runTest!("delegates", testDelegate);

  return 0;
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
    assertEquals(7654, s.initialized);
    check(s.ctorCalled);
    assertEquals(123, s.ctorArg);
    check(!s.dtorCalled);

    deleteStruct(s);
  }
  check(MyStruct.dtorCalled);
}

void testArrayCopy()
{
  int[10] tab;
  tab[] = 4;
  assertEquals(4, tab[0]);
  assertEquals(4, tab[9]);

  int[10] tab2;
  tab2 = tab;
  assertEquals(4, tab2[0]);
  assertEquals(4, tab2[9]);
}

void testArrayDynamic()
{
  int[] tab = newArray!int(256);
  assertEquals(256, cast(int)tab.length);
  assert(tab.ptr);
  assertEquals(0, tab[0]);
  tab[1] = 1234;

  deleteArray(tab);
}

void testDelegate()
{
  static class C
  {
    int a;
    void f()
    {
      ++a;
    }
  }

  static void callMe(void delegate() func)
  {
    for(int i=0;i < 123;++i)
      func();
  }

  auto c = new C;
  callMe(&c.f);
  assertEquals(123, c.a);
}

///////////////////////////////////////////////////////////////////////////////
void runTest(string name, alias f)()
{
  printf("Test: %s\n", name.ptr);
  f();
}

void assertEquals(int expected, int actual, string file=__FILE__, int line=__LINE__) nothrow
{
  if(expected == actual)
    return;

  printf("At %s(%d): expected %d, got %d\n", file.ptr, line, expected, actual);
  exit(1);
}

void check(bool condition, string file=__FILE__, int line=__LINE__) nothrow
{
  if(condition)
    return;

  printf("At %s(%d): assertion failure\n", file.ptr, line);
  exit(1);
}

