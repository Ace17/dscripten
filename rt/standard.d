// minimalistic D standard library
pragma(LDC_no_moduleinfo);

extern(C) int printf(const(char)*, ...);
extern(C) void exit(int);
extern(C) void* malloc(size_t);
extern(C) void* calloc(int, size_t);
extern(C) void free(void*);
extern(C) void* memcpy(void*, const(void)*, size_t) pure nothrow;

T* newStruct(T, Args...)(auto ref Args args)
{
  auto r = cast(T*) calloc(1, T.sizeof);
  emplace!T(r, args);
  return r;
}

void deleteStruct(T)(T * r)
{
  .destroy(*r);
  free(r);
}

T newObject(T, Args...)(Args args)
{
  enum classSize = __traits(classInstanceSize, T);

  void* chunk = malloc(classSize);

  return emplace!T(chunk[0 .. classSize]);
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

//*****************************************************************************
/+
emplaceRef is a package function for phobos internal use. It works like
emplace, but takes its argument by ref (as opposed to "by pointer").

This makes it easier to use, easier to be safe, and faster in a non-inline
build.

Furthermore, emplaceRef optionally takes a type paremeter, which specifies
the type we want to build. This helps to build qualified objects on mutable
buffer, without breaking the type system with unsafe casts.
  +/
void emplaceRef(T, UT, Args...)(ref UT chunk, auto ref Args args)
{
  static if (args.length == 0)
  {
    static assert (is(typeof({static T i;})),
        convFormat("Cannot emplace a %1$s because %1$s.this() is annotated with @disable.", T.stringof));
    emplaceInitializer(chunk);
  }
  else static if (
      !is(T == struct) && Args.length == 1 /* primitives, enums, arrays */
      ||
      Args.length == 1 && is(typeof({T t = args[0];})) /* conversions */
      ||
      is(typeof(T(args))) /* general constructors */)
  {
    static struct S
    {
      T payload;
      this(ref Args x)
      {
        static if (Args.length == 1)
          static if (is(typeof(payload = x[0])))
          payload = x[0];
        else
          payload = T(x[0]);
        else
          payload = T(x);
      }
    }
    if (__ctfe)
    {
      static if (is(typeof(chunk = T(args))))
        chunk = T(args);
      else static if (args.length == 1 && is(typeof(chunk = args[0])))
        chunk = args[0];
      else static assert(0, "CTFE emplace doesn't support "
          ~ T.stringof ~ " from " ~ Args.stringof);
    }
    else
    {
      S* p = () @trusted { return cast(S*) &chunk; }();
      emplaceInitializer(*p);
      p.__ctor(args);
    }
  }
  else static if (is(typeof(chunk.__ctor(args))))
  {
    // This catches the rare case of local types that keep a frame pointer
    emplaceInitializer(chunk);
    chunk.__ctor(args);
  }
  else
  {
    //We can't emplace. Try to diagnose a disabled postblit.
    static assert(!(Args.length == 1 && is(Args[0] : T)),
        convFormat("Cannot emplace a %1$s because %1$s.this(this) is annotated with @disable.", T.stringof));

    //We can't emplace.
    static assert(false,
        convFormat("%s cannot be emplaced from %s.", T.stringof, Args[].stringof));
  }
}

//emplace helper functions
void emplaceInitializer(T)(ref T chunk) @trusted pure nothrow
{
  static immutable T init = T.init;
  memcpy(&chunk, &init, T.sizeof);
}

// emplace
/**
  Given a pointer $(D chunk) to uninitialized memory (but already typed
  as $(D T)), constructs an object of non-$(D class) type $(D T) at that
  address.

Returns: A pointer to the newly constructed object (which is the same
as $(D chunk)).
 */
T* emplace(T)(T* chunk) @safe pure nothrow
{
  emplaceRef!T(*chunk);
  return chunk;
}

/**
  Given a pointer $(D chunk) to uninitialized memory (but already typed
  as a non-class type $(D T)), constructs an object of type $(D T) at
  that address from arguments $(D args).

  This function can be $(D @trusted) if the corresponding constructor of
  $(D T) is $(D @safe).

Returns: A pointer to the newly constructed object (which is the same
as $(D chunk)).
 */
  T* emplace(T, Args...)(T* chunk, auto ref Args args)
if (is(T == struct) || Args.length == 1)
{
  emplaceRef!T(*chunk, args);
  return chunk;
}

/**
  Given a raw memory area $(D chunk), constructs an object of $(D class)
  type $(D T) at that address. The constructor is passed the arguments
  $(D Args). The $(D chunk) must be as least as large as $(D T) needs
  and should have an alignment multiple of $(D T)'s alignment. (The size
  of a $(D class) instance is obtained by using $(D
  __traits(classInstanceSize, T))).

  This function can be $(D @trusted) if the corresponding constructor of
  $(D T) is $(D @safe).

Returns: A pointer to the newly constructed object.
 */
  T emplace(T, Args...)(void[] chunk, auto ref Args args)
if (is(T == class))
{
  enum classSize = __traits(classInstanceSize, T);
  auto result = cast(T) chunk.ptr;

  // Initialize the object in its pre-ctor state
  chunk[0 .. classSize] = typeid(T).m_init[];

  // Call the ctor if any
  static if (is(typeof(result.__ctor(args))))
  {
    // T defines a genuine constructor accepting args
    // Go the classic route: write .init first, then call ctor
    result.__ctor(args);
  }
  else
  {
    static assert(args.length == 0 && !is(typeof(&T.__ctor)),
        "Don't know how to initialize an object of type "
        ~ T.stringof ~ " with arguments " ~ Args.stringof);
  }
  return result;
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
