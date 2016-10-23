// minimalistic D runtime
pragma(LDC_no_moduleinfo);
pragma(LDC_no_typeinfo):
import core.stdc.stdio;
import core.stdc.stdlib;
import std.traits: isAbstractClass, classInstanceAlignment;

extern (C) void not_implemented(string file=__FILE__, int line=__LINE__)
{
  printf("Not implemented: %s(%d)\n", file.ptr, line);
  exit(123);
}

extern(C) int printf(const(char)*, ...);

T* createStruct(T, Args...)(auto ref Args args)
{
  auto r = cast(T*) calloc(1, T.sizeof);
  emplace!T(r, args);
  return r;
}

T newObject(T, Args...)(Args args)
{
  enum classSize = __traits(classInstanceSize, T);

  void* chunk = malloc(classSize);
  
  return emplace!T(chunk[0 .. classSize]);
}

void destroyStruct(T)(T * r)
{
  .destroy(*r);
  free(r);
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
  package void emplaceRef(T, UT, Args...)(ref UT chunk, auto ref Args args)
if (is(UT == Unqual!T))
{
  static if (args.length == 0)
  {
    static assert (is(typeof({static T i;})),
        convFormat("Cannot emplace a %1$s because %1$s.this() is annotated with @disable.", T.stringof));
    static if (is(T == class)) static assert (!isAbstractClass!T,
        T.stringof ~ " is abstract and it can't be emplaced");
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
// ditto
  package void emplaceRef(UT, Args...)(ref UT chunk, auto ref Args args)
if (is(UT == Unqual!UT))
{
  emplaceRef!(UT, UT)(chunk, args);
}

//emplace helper functions
private void emplaceInitializer(T)(ref T chunk) @trusted pure nothrow
{
  static if (!hasElaborateAssign!T && isAssignable!T)
    chunk = T.init;
  else
  {
    import core.stdc.string : memcpy;
    static immutable T init = T.init;
    memcpy(&chunk, &init, T.sizeof);
  }
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
  static assert (!isAbstractClass!T, T.stringof ~
      " is abstract and it can't be emplaced");

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

/**
  Given a raw memory area $(D chunk), constructs an object of non-$(D
  class) type $(D T) at that address. The constructor is passed the
  arguments $(D args), if any. The $(D chunk) must be as least as large
  as $(D T) needs and should have an alignment multiple of $(D T)'s
  alignment.

  This function can be $(D @trusted) if the corresponding constructor of
  $(D T) is $(D @safe).

Returns: A pointer to the newly constructed object.
 */
  T* emplace(T, Args...)(void[] chunk, auto ref Args args)
if (!is(T == class))
{
  testEmplaceChunk(chunk, T.sizeof, T.alignof, T.stringof);
  emplaceRef!(T, Unqual!T)(*cast(Unqual!T*) chunk.ptr, args);
  return cast(T*) chunk.ptr;
}

