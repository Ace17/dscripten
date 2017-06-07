// minimalistic D standard library
pragma(LDC_no_moduleinfo);

extern(C) int printf(const(char)*, ...) nothrow;
extern(C) void exit(int) nothrow;
extern(C) void* malloc(size_t) nothrow;
extern(C) void* calloc(int, size_t) nothrow;
extern(C) void free(void*) nothrow;
extern(C) void* memcpy(void*, const(void)*, size_t) pure nothrow;

void deleteStruct(T)(T * r) nothrow
{
  .destroy(*r);
  free(r);
}

void deleteObject(T)(T o) if(is(T == class))
{
  static if(hasMember!(T, "__dtor"))
  {
    o.__dtor();
  }
  free(cast(void*)o);
}

struct vector (T)
{
  this(int n)
  {
    for(int i = 0; i < n; ++i)
      push_back(T.init);
  }

  ~this()
  {
    clear();
  }

  void push_back()(auto ref T val)
  {
    ++len;
    buffer = cast(T*) realloc(buffer, len* T.sizeof);
    buffer[len - 1] = val;
  }

  void opIndexAssign()(auto ref T val, int idx)
  {
    buffer[idx] = val;
  }

  void clear()
  {
    foreach(element; this.opSlice())
      destroy(element);

    free(buffer);
    buffer = null;
    len = 0;
  }

  T[] opSlice()
  {
    return buffer[0 .. len];
  }

  int size() const
  {
    return len;
  }

  bool empty() const
  {
    return len == 0;
  }

  T* data()
  {
    return buffer;
  }

private:
  T* buffer;
  int len;
}

///////////////////////////////////////////////////////////////////////////////
// meta

template hasMember(T, string name)
{
  static if (is(T == struct) || is(T == class) || is(T == union) || is(T == interface))
  {
    enum bool hasMember =
      staticIndexOf!(name, __traits(allMembers, T)) != -1 ||
      __traits(compiles, { mixin("alias Sym = Identity!(T."~name~");"); });
  }
  else
  {
    enum bool hasMember = false;
  }
}

template staticIndexOf(T, TList...)
{
  enum staticIndexOf = genericIndexOf!(T, TList).index;
}

template staticIndexOf(alias T, TList...)
{
  enum staticIndexOf = genericIndexOf!(T, TList).index;
}

  template genericIndexOf(args...)
if (args.length >= 1)
{
  alias e     = Alias!(args[0]);
  alias tuple = args[1 .. $];

  static if (tuple.length)
  {
    alias head = Alias!(tuple[0]);
    alias tail = tuple[1 .. $];

    static if (isSame!(e, head))
    {
      enum index = 0;
    }
    else
    {
      enum next  = genericIndexOf!(e, tail).index;
      enum index = (next == -1) ? -1 : 1 + next;
    }
  }
  else
  {
    enum index = -1;
  }
}

template Alias(alias a)
{
  static if (__traits(compiles, { alias x = a; }))
    alias Alias = a;
  else static if (__traits(compiles, { enum x = a; }))
    enum Alias = a;
  else
    static assert(0, "Cannot alias " ~ a.stringof);
}

template Alias(a...)
{
  alias Alias = a;
}

  template isSame(ab...)
if (ab.length == 2)
{
  static if (__traits(compiles, expectType!(ab[0]),
        expectType!(ab[1])))
  {
    enum isSame = is(ab[0] == ab[1]);
  }
  else static if (!__traits(compiles, expectType!(ab[0])) &&
      !__traits(compiles, expectType!(ab[1])) &&
      __traits(compiles, expectBool!(ab[0] == ab[1])))
  {
    static if (!__traits(compiles, &ab[0]) ||
        !__traits(compiles, &ab[1]))
      enum isSame = (ab[0] == ab[1]);
    else
      enum isSame = __traits(isSame, ab[0], ab[1]);
  }
  else
  {
    enum isSame = __traits(isSame, ab[0], ab[1]);
  }
}
