// minimalistic D runtime
// stripped-down version of the official one
module object;

pragma(LDC_no_moduleinfo);

private
{
  extern (C) void not_implemented(const char* file=__FILE__.ptr, int line=__LINE__) pure @nogc @safe nothrow;
  extern(C) int strlen(const char*) nothrow pure;
  extern(C) void* malloc(size_t) nothrow pure;
  extern(C) void memset(void*, long, size_t) nothrow pure;
}

version(D_LP64)
{
  alias ulong size_t;
  alias long  ptrdiff_t;
}
else
{
  alias uint  size_t;
  alias int   ptrdiff_t;
}

alias immutable(char)[]  string;
alias immutable(wchar)[] wstring;
alias immutable(dchar)[] dstring;

class Object
{
  string toString()
  {
    not_implemented();
    return "";
  }

  size_t toHash() @trusted nothrow
  {
    not_implemented();
    return 0;
  }

  int opCmp(Object o)
  {
    not_implemented();
    return 0;
  }

  bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  static Object factory(string classname)
  {
    not_implemented();
    return null;
  }
}

/**
 * Information about an interface.
 * When an object is accessed via an interface, an Interface* appears as the
 * first entry in its vtbl.
 */
struct Interface
{
  TypeInfo_Class   classinfo;  /// .classinfo for this interface (not for containing class)
  void*[]     vtbl;
  size_t      offset;     /// offset to Interface 'this' from Object 'this'
}

/**
 * Array of pairs giving the offset and type information for each
 * member in an aggregate.
 */
struct OffsetTypeInfo
{
  size_t   offset;    /// Offset of member from start of object
  TypeInfo ti;        /// TypeInfo for this member
}

/**
 * Runtime type information about a type.
 * Can be retrieved for any type using a
 * $(GLINK2 expression,TypeidExpression, TypeidExpression).
 */
class TypeInfo
{
  override string toString() const pure @safe nothrow
  {
    not_implemented();
    return "";
  }

  override size_t toHash() @trusted const
  {
    not_implemented();
    return 0;
  }

  override int opCmp(Object o)
  {
    not_implemented();
    return 0;
  }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  /// Returns a hash of the instance of a type.
  size_t getHash(in void* p) @trusted nothrow const
  {
    not_implemented();
    return 0;
  }

  /// Compares two instances for equality.
  bool equals(in void* p1, in void* p2) const { return p1 == p2; }

  /// Compares two instances for &lt;, ==, or &gt;.
  int compare(in void* p1, in void* p2) const { not_implemented(); return 0;}

  /// Returns size of the type.
  @property size_t tsize() nothrow pure const @safe @nogc { return 0; }

  /// Swaps two instances of the type.
  void swap(void* p1, void* p2) const
  {
    size_t n = tsize;
    for (size_t i = 0; i < n; i++)
    {
      byte t = (cast(byte *)p1)[i];
      (cast(byte*)p1)[i] = (cast(byte*)p2)[i];
      (cast(byte*)p2)[i] = t;
    }
  }

  /// Get TypeInfo for 'next' type, as defined by what kind of type this is,
  /// null if none.
  @property inout(TypeInfo) next() nothrow pure inout @nogc { return null; }

  /// Return default initializer.  If the type should be initialized to all zeros,
  /// an array with a null ptr and a length equal to the type size will be returned.
  version(LDC)
  {
    // LDC uses TypeInfo's vtable for the typeof(null) type:
    //   %"typeid(typeof(null))" = type { %object.TypeInfo.__vtbl*, i8* }
    // Therefore this class cannot be abstract, and all methods need implementations.
    // Tested by test14754() in runnable/inline.d, and a unittest below.
    const(void)[] initializer() nothrow pure const @safe @nogc { return null; }
  }
  else
  {
    abstract const(void)[] initializer() nothrow pure const @safe @nogc;
  }

  /// $(RED Scheduled for deprecation.) Please use `initializer` instead.
  alias init = initializer; // added in 2.070, to stay in 2.071
  version(none) deprecated alias init = initializer; // planned for 2.072
  version(none) @disable static const(void)[] init(); // planned for 2.073
  /* Planned for 2.074: Remove init, making way for the init type property,
     fixing issue 12233. */

  /// Get flags for type: 1 means GC should scan for pointers,
  /// 2 means arg of this type is passed in XMM register
  @property uint flags() nothrow pure const @safe @nogc { return 0; }

  /// Get type information on the contents of the type; null if not available
  const(OffsetTypeInfo)[] offTi() const { return null; }
  /// Run the destructor on the object and all its sub-objects
  void destroy(void* p) const {}
  /// Run the postblit on the object and all its sub-objects
  void postblit(void* p) const {}


  /// Return alignment of type
  @property size_t talign() nothrow pure const @safe @nogc { return tsize; }

  /** Return internal info on arguments fitting into 8byte.
   * See X86-64 ABI 3.2.3
   */
  version (X86_64) int argTypes(out TypeInfo arg1, out TypeInfo arg2) @safe nothrow
  {
    arg1 = this;
    return 0;
  }

  /** Return info used by the garbage collector to do precise collection.
   */
  @property immutable(void)* rtInfo() nothrow pure const @safe @nogc { return null; }
}

class TypeInfo_Typedef : TypeInfo
{
  override string toString() const { return name; }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override size_t getHash(in void* p) const { return base.getHash(p); }
  override bool equals(in void* p1, in void* p2) const { return base.equals(p1, p2); }
  override int compare(in void* p1, in void* p2) const { return base.compare(p1, p2); }
  override @property size_t tsize() nothrow pure const { return base.tsize; }
  override void swap(void* p1, void* p2) const { return base.swap(p1, p2); }

  override @property inout(TypeInfo) next() nothrow pure inout { return base.next; }
  override @property uint flags() nothrow pure const { return base.flags; }

  override const(void)[] initializer() const
  {
    return m_init.length ? m_init : base.initializer();
  }

  override @property size_t talign() nothrow pure const { return base.talign; }

  version (X86_64) override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
  {
    return base.argTypes(arg1, arg2);
  }

  override @property immutable(void)* rtInfo() const { return base.rtInfo; }

  TypeInfo base;
  string   name;
  void[]   m_init;
}

class TypeInfo_Enum : TypeInfo_Typedef
{

}

// Please make sure to keep this in sync with TypeInfo_P (src/rt/typeinfo/ti_ptr.d)
class TypeInfo_Pointer : TypeInfo
{
  override string toString() const
  {
    not_implemented();
    return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override size_t getHash(in void* p) @trusted const
  {
    not_implemented();
    return 0;
  }

  override bool equals(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override int compare(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    not_implemented();
    return 0;
  }

  override const(void)[] initializer() const @trusted
  {
    not_implemented();
    return [];
  }

  override void swap(void* p1, void* p2) const
  {
    not_implemented();
  }

  override @property inout(TypeInfo) next() nothrow pure inout { return m_next; }
  override @property uint flags() nothrow pure const { return 1; }

  TypeInfo m_next;
}

class TypeInfo_Array : TypeInfo
{
  override string toString() const
  {
    not_implemented();
    return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override bool equals(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override int compare(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    return (void[]).sizeof;
  }

  override const(void)[] initializer() const @trusted
  {
    return (cast(void *)null)[0 .. (void[]).sizeof];
  }

  override void swap(void* p1, void* p2) const
  {
    not_implemented();
  }

  TypeInfo value;

  override @property inout(TypeInfo) next() nothrow pure inout
  {
    return value;
  }

  override @property uint flags() nothrow pure const { return 1; }

  override @property size_t talign() nothrow pure const
  {
    return (void[]).alignof;
  }

  version (X86_64) override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
  {
    not_implemented();
    return 0;
  }
}

class TypeInfo_StaticArray : TypeInfo
{
  override string toString() const
  {
    not_implemented();
    return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override bool equals(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override int compare(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    return len * value.tsize;
  }

  override void swap(void* p1, void* p2) const
  {
    not_implemented();
  }

  override const(void)[] initializer() nothrow pure const
  {
    return value.initializer();
  }

  override @property inout(TypeInfo) next() nothrow pure inout { return value; }
  override @property uint flags() nothrow pure const { return value.flags; }

  override void destroy(void* p) const
  {
    auto sz = value.tsize;
    p += sz * len;
    foreach (i; 0 .. len)
    {
      p -= sz;
      value.destroy(p);
    }
  }

  override void postblit(void* p) const
  {
    auto sz = value.tsize;
    foreach (i; 0 .. len)
    {
      value.postblit(p);
      p += sz;
    }
  }

  TypeInfo value;
  size_t   len;

  override @property size_t talign() nothrow pure const
  {
    return value.talign;
  }

  version (X86_64) override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
  {
    not_implemented();
    return 0;
  }
}

class TypeInfo_AssociativeArray : TypeInfo
{
  override string toString() const
  {
    not_implemented();
    return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  // BUG: need to add the rest of the functions

  override @property size_t tsize() nothrow pure const
  {
    return (char[int]).sizeof;
  }

  override const(void)[] initializer() const @trusted
  {
    return (cast(void *)null)[0 .. (char[int]).sizeof];
  }

  override @property inout(TypeInfo) next() nothrow pure inout { return value; }
  override @property uint flags() nothrow pure const { return 1; }

  TypeInfo value;
  TypeInfo key;

  override @property size_t talign() nothrow pure const
  {
    return (char[int]).alignof;
  }

  version (X86_64) override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
  {
    not_implemented();
    return 0;
  }
}

class TypeInfo_Vector : TypeInfo
{
  override string toString() const
  {
    not_implemented();
    return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override size_t getHash(in void* p) const { return base.getHash(p); }
  override bool equals(in void* p1, in void* p2) const { return base.equals(p1, p2); }
  override int compare(in void* p1, in void* p2) const { return base.compare(p1, p2); }
  override @property size_t tsize() nothrow pure const { return base.tsize; }
  override void swap(void* p1, void* p2) const { return base.swap(p1, p2); }

  override @property inout(TypeInfo) next() nothrow pure inout { return base.next; }
  override @property uint flags() nothrow pure const { return base.flags; }

  override const(void)[] initializer() nothrow pure const
  {
    return base.initializer();
  }

  override @property size_t talign() nothrow pure const { return 16; }

  version (X86_64) override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
  {
    return base.argTypes(arg1, arg2);
  }

  TypeInfo base;
}

class TypeInfo_Function : TypeInfo
{
  override string toString() const
  {
    not_implemented(); return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented(); return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    return 0;       // no size for functions
  }

  override const(void)[] initializer() const @safe
  {
    return null;
  }

  TypeInfo next;
  string deco;
}

class TypeInfo_Delegate : TypeInfo
{
  override string toString() const
  {
    not_implemented();
    return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override bool equals(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override int compare(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    not_implemented();
    return 0;
  }

  override const(void)[] initializer() const @trusted
  {
    not_implemented();
    return [];
  }

  override @property uint flags() nothrow pure const { return 1; }

  TypeInfo next;
  string deco;

  override @property size_t talign() nothrow pure const
  {
    not_implemented();
    return 0;
  }

  version (X86_64) override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
  {
    not_implemented();
    return 0;
  }
}

/**
 * Runtime type information about a class.
 * Can be retrieved from an object instance by using the
 * $(DDSUBLINK spec/property,classinfo, .classinfo) property.
 */
class TypeInfo_Class : TypeInfo
{
  override string toString() const
  {
    not_implemented();
    return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override size_t getHash(in void* p) @trusted const
  {
    not_implemented();
    return 0;
  }

  override bool equals(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override int compare(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    not_implemented();
    return 0;
  }

  override const(void)[] initializer() nothrow pure const @safe
  {
    return m_init;
  }

  override @property uint flags() nothrow pure const { return 1; }

  override @property const(OffsetTypeInfo)[] offTi() nothrow pure const
  {
    return m_offTi;
  }

  @property auto info() @safe nothrow pure const { return this; }
  @property auto typeinfo() @safe nothrow pure const { return this; }

  byte[]      m_init;         /** class static initializer
                               * (init.length gives size in bytes of class)
                               */
  string      name;           /// class name
  void*[]     vtbl;           /// virtual function pointer table
  Interface[] interfaces;     /// interfaces this class implements
  TypeInfo_Class   base;           /// base class
  void*       destructor;
  void function(Object) classInvariant;
  enum ClassFlags : uint
  {
    isCOMclass = 0x1,
    noPointers = 0x2,
    hasOffTi = 0x4,
    hasCtor = 0x8,
    hasGetMembers = 0x10,
    hasTypeInfo = 0x20,
    isAbstract = 0x40,
    isCPPclass = 0x80,
    hasDtor = 0x100,
  }
  ClassFlags m_flags;
  void*       deallocator;
  OffsetTypeInfo[] m_offTi;
  void function(Object) defaultConstructor;   // default Constructor

  immutable(void)* m_RTInfo;        // data for precise GC
  override @property immutable(void)* rtInfo() const { return m_RTInfo; }

  static const(TypeInfo_Class) find(in char[] classname)
  {
    not_implemented();
    return null;
  }

  Object create() const
  {
    not_implemented();
    return null;
  }
}

class TypeInfo_Interface : TypeInfo
{
  override string toString() const { return info.name; }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override size_t getHash(in void* p) @trusted const
  {
    not_implemented();
    return 0;
  }

  override bool equals(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override int compare(in void* p1, in void* p2) const
  {
    not_implemented();
    return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    return Object.sizeof;
  }

  override const(void)[] initializer() const @trusted
  {
    return (cast(void *)null)[0 .. Object.sizeof];
  }

  override @property uint flags() nothrow pure const
  {
    return 1;
  }

  TypeInfo_Class info;
}

class TypeInfo_Struct : TypeInfo
{
  override string toString() const { return name; }

  override bool opEquals(Object o)
  {
    not_implemented();
    return 0;
  }

  override size_t getHash(in void* p) @safe pure nothrow const
  {
    not_implemented();
    return 0;
  }

  override bool equals(in void* p1, in void* p2) @trusted pure nothrow const
  {
    not_implemented();
    return 0;
  }

  override int compare(in void* p1, in void* p2) @trusted pure nothrow const
  {
    not_implemented();
    return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    return initializer().length;
  }

  override const(void)[] initializer() nothrow pure const @safe
  {
    return m_init;
  }

  override @property uint flags() nothrow pure const { return m_flags; }

  override @property size_t talign() nothrow pure const { return m_align; }

  final override void destroy(void* p) const
  {
    if (xdtor)
    {
      if (m_flags & StructFlags.isDynamicType)
        (*xdtorti)(p, this);
      else
        (*xdtor)(p);
    }
  }

  override void postblit(void* p) const
  {
    if (xpostblit)
      (*xpostblit)(p);
  }

  string name;
  void[] m_init;      // initializer; m_init.ptr == null if 0 initialize

  @safe pure nothrow
  {
    size_t   function(in void*)           xtoHash;
    bool     function(in void*, in void*) xopEquals;
    int      function(in void*, in void*) xopCmp;
    string   function(in void*)           xtoString;

    enum StructFlags : uint
    {
      hasPointers = 0x1,
      isDynamicType = 0x2, // built at runtime, needs type info in xdtor
    }
    StructFlags m_flags;
  }
  union
  {
    void function(void*)                xdtor;
    void function(void*, const TypeInfo_Struct ti) xdtorti;
  }
  void function(void*)                    xpostblit;

  uint m_align;

  override @property immutable(void)* rtInfo() const { return m_RTInfo; }

  version (X86_64)
  {
    override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
    {
      arg1 = m_arg1;
      arg2 = m_arg2;
      return 0;
    }
    TypeInfo m_arg1;
    TypeInfo m_arg2;
  }
  immutable(void)* m_RTInfo;                // data for precise GC
}

/+
class TypeInfo_Tuple : TypeInfo
{
  TypeInfo[] elements;

  override string toString() const
  {
    not_implemented();
    return "";
  }

  override bool opEquals(Object o)
  {
    not_implemented(); return 0;
  }

  override size_t getHash(in void* p) const
  {
    not_implemented(); return 0;
  }

  override bool equals(in void* p1, in void* p2) const
  {
    not_implemented(); return 0;
  }

  override int compare(in void* p1, in void* p2) const
  {
    not_implemented(); return 0;
  }

  override @property size_t tsize() nothrow pure const
  {
    not_implemented(); return 0;
  }

  override const(void)[] initializer() const @trusted
  {
    not_implemented(); return [];
  }

  override void swap(void* p1, void* p2) const
  {
    not_implemented();
  }

  override void destroy(void* p) const
  {
    not_implemented();
  }

  override void postblit(void* p) const
  {
    not_implemented();
  }

  override @property size_t talign() nothrow pure const
  {
    not_implemented(); return 0;
  }

  version (X86_64) override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
  {
    not_implemented(); return 0;
  }
}

+/

// required by the compiler
class TypeInfo_Const : TypeInfo
{
  override string toString() const
  {
    not_implemented(); return "";
  }

  //override bool opEquals(Object o) { return base.opEquals(o); }
  override bool opEquals(Object o)
  {
    not_implemented(); return 0;
  }

  override size_t getHash(in void *p) const { return base.getHash(p); }
  override bool equals(in void *p1, in void *p2) const { return base.equals(p1, p2); }
  override int compare(in void *p1, in void *p2) const { return base.compare(p1, p2); }
  override @property size_t tsize() nothrow pure const { return base.tsize; }
  override void swap(void *p1, void *p2) const { return base.swap(p1, p2); }

  override @property inout(TypeInfo) next() nothrow pure inout { return base.next; }
  override @property uint flags() nothrow pure const { return base.flags; }

  override const(void)[] initializer() nothrow pure const
  {
    return base.initializer();
  }

  override @property size_t talign() nothrow pure const { return base.talign; }

  version (X86_64) override int argTypes(out TypeInfo arg1, out TypeInfo arg2)
  {
    return base.argTypes(arg1, arg2);
  }

  TypeInfo base;
}

/+
class TypeInfo_Invariant : TypeInfo_Const
{
  override string toString() const
  {
    return cast(string) ("immutable(" ~ base.toString() ~ ")");
  }
}

class TypeInfo_Shared : TypeInfo_Const
{
  override string toString() const
  {
    return cast(string) ("shared(" ~ base.toString() ~ ")");
  }
}

class TypeInfo_Inout : TypeInfo_Const
{
  override string toString() const
  {
    return cast(string) ("inout(" ~ base.toString() ~ ")");
  }
}


+/
///////////////////////////////////////////////////////////////////////////////
// ModuleInfo
///////////////////////////////////////////////////////////////////////////////


enum
{
  MIctorstart  = 0x1,   // we've started constructing it
  MIctordone   = 0x2,   // finished construction
  MIstandalone = 0x4,   // module ctor does not depend on other module
  // ctors being done first
  MItlsctor    = 8,
  MItlsdtor    = 0x10,
  MIctor       = 0x20,
  MIdtor       = 0x40,
  MIxgetMembers = 0x80,
  MIictor      = 0x100,
  MIunitTest   = 0x200,
  MIimportedModules = 0x400,
  MIlocalClasses = 0x800,
  MIname       = 0x1000,
}


struct ModuleInfo
{
  uint _flags;
  uint _index; // index into _moduleinfo_array[]

  version (all)
  {
    deprecated("ModuleInfo cannot be copy-assigned because it is a variable-sized struct.")
      void opAssign(in ModuleInfo m) { _flags = m._flags; _index = m._index; }
  }
  else
  {
    @disable this();
    @disable this(this) const;
  }

const:
  private void* addrOf(int flag) nothrow pure
  {
    void* p = cast(void*)&this + ModuleInfo.sizeof;

    if (flags & MItlsctor)
    {
      if (flag == MItlsctor) return p;
      p += typeof(tlsctor).sizeof;
    }
    if (flags & MItlsdtor)
    {
      if (flag == MItlsdtor) return p;
      p += typeof(tlsdtor).sizeof;
    }
    if (flags & MIctor)
    {
      if (flag == MIctor) return p;
      p += typeof(ctor).sizeof;
    }
    if (flags & MIdtor)
    {
      if (flag == MIdtor) return p;
      p += typeof(dtor).sizeof;
    }
    if (flags & MIxgetMembers)
    {
      if (flag == MIxgetMembers) return p;
      p += typeof(xgetMembers).sizeof;
    }
    if (flags & MIictor)
    {
      if (flag == MIictor) return p;
      p += typeof(ictor).sizeof;
    }
    if (flags & MIunitTest)
    {
      if (flag == MIunitTest) return p;
      p += typeof(unitTest).sizeof;
    }
    if (flags & MIimportedModules)
    {
      if (flag == MIimportedModules) return p;
      p += size_t.sizeof + *cast(size_t*)p * typeof(importedModules[0]).sizeof;
    }
    if (flags & MIlocalClasses)
    {
      if (flag == MIlocalClasses) return p;
      p += size_t.sizeof + *cast(size_t*)p * typeof(localClasses[0]).sizeof;
    }
    if (true || flags & MIname) // always available for now
    {
      if (flag == MIname) return p;
      p += strlen(cast(immutable char*)p);
    }
    not_implemented(); return null;
  }

  @property uint index() nothrow pure { return _index; }

  @property uint flags() nothrow pure { return _flags; }

  @property void function() tlsctor() nothrow pure
  {
    return flags & MItlsctor ? *cast(typeof(return)*)addrOf(MItlsctor) : null;
  }

  @property void function() tlsdtor() nothrow pure
  {
    return flags & MItlsdtor ? *cast(typeof(return)*)addrOf(MItlsdtor) : null;
  }

  @property void* xgetMembers() nothrow pure
  {
    return flags & MIxgetMembers ? *cast(typeof(return)*)addrOf(MIxgetMembers) : null;
  }

  @property void function() ctor() nothrow pure
  {
    return flags & MIctor ? *cast(typeof(return)*)addrOf(MIctor) : null;
  }

  @property void function() dtor() nothrow pure
  {
    return flags & MIdtor ? *cast(typeof(return)*)addrOf(MIdtor) : null;
  }

  @property void function() ictor() nothrow pure
  {
    return flags & MIictor ? *cast(typeof(return)*)addrOf(MIictor) : null;
  }

  @property void function() unitTest() nothrow pure
  {
    return flags & MIunitTest ? *cast(typeof(return)*)addrOf(MIunitTest) : null;
  }

  @property immutable(ModuleInfo*)[] importedModules() nothrow pure
  {
    if (flags & MIimportedModules)
    {
      auto p = cast(size_t*)addrOf(MIimportedModules);
      return (cast(immutable(ModuleInfo*)*)(p + 1))[0 .. *p];
    }
    return null;
  }

  @property TypeInfo_Class[] localClasses() nothrow pure
  {
    if (flags & MIlocalClasses)
    {
      auto p = cast(size_t*)addrOf(MIlocalClasses);
      return (cast(TypeInfo_Class*)(p + 1))[0 .. *p];
    }
    return null;
  }

  @property string name() nothrow pure
  {
    if (true || flags & MIname) // always available for now
    {
      auto p = cast(immutable char*)addrOf(MIname);
      return p[0 .. strlen(p)];
    }
    // return null;
  }

  static int opApply(scope int delegate(ModuleInfo*) dg)
  {
    /*
       import core.internal.traits : externDFunc;
       alias moduleinfos_apply = externDFunc!("rt.minfo.moduleinfos_apply",
       int function(scope int delegate(immutable(ModuleInfo*))));
    // Bugzilla 13084 - enforcing immutable ModuleInfo would break client code
    return moduleinfos_apply(
    (immutable(ModuleInfo*)m) => dg(cast(ModuleInfo*)m));
     */
    not_implemented();
    return 0;
  }
}

///////////////////////////////////////////////////////////////////////////////
// Throwable
///////////////////////////////////////////////////////////////////////////////

/**
 * The base class of all thrown objects.
 *
 * All thrown objects must inherit from Throwable. Class $(D Exception), which
 * derives from this class, represents the category of thrown objects that are
 * safe to catch and handle. In principle, one should not catch Throwable
 * objects that are not derived from $(D Exception), as they represent
 * unrecoverable runtime errors. Certain runtime guarantees may fail to hold
 * when these errors are thrown, making it unsafe to continue execution after
 * catching them.
 */
class Throwable : Object
{
  interface TraceInfo
  {
    int opApply(scope int delegate(ref const(char[]))) const;
    int opApply(scope int delegate(ref size_t, ref const(char[]))) const;
    string toString() const;
  }

  string      msg;    /// A message describing the error.

  /**
   * The _file name and line number of the D source code corresponding with
   * where the error was thrown from.
   */
  string      file;
  size_t      line;   /// ditto

  /**
   * The stack trace of where the error happened. This is an opaque object
   * that can either be converted to $(D string), or iterated over with $(D
   * foreach) to extract the items in the stack trace (as strings).
   */
  TraceInfo   info;

  /**
   * A reference to the _next error in the list. This is used when a new
   * $(D Throwable) is thrown from inside a $(D catch) block. The originally
   * caught $(D Exception) will be chained to the new $(D Throwable) via this
   * field.
   */
  Throwable   next;

  @nogc @safe pure nothrow this(string msg, Throwable next = null)
  {
    this.msg = msg;
    this.next = next;
    //this.info = _d_traceContext();
  }

  @nogc @safe pure nothrow this(string msg, string file, size_t line, Throwable next = null)
  {
    this(msg, next);
    this.file = file;
    this.line = line;
    //this.info = _d_traceContext();
  }

  /**
   * Overrides $(D Object.toString) and returns the error message.
   * Internally this forwards to the $(D toString) overload that
   * takes a $(PARAM sink) delegate.
   */
  override string toString()
  {
    not_implemented();
    return "";
  }

  /**
   * The Throwable hierarchy uses a toString overload that takes a
   * $(PARAM sink) delegate to avoid GC allocations, which cannot be
   * performed in certain error situations.  Override this $(D
   * toString) method to customize the error message.
   */
  void toString(scope void delegate(in char[]) sink) const
  {
    not_implemented();
  }
}

/+
/**
 * The base class of all errors that are safe to catch and handle.
 *
 * In principle, only thrown objects derived from this class are safe to catch
 * inside a $(D catch) block. Thrown objects not derived from Exception
 * represent runtime errors that should not be caught, as certain runtime
 * guarantees may not hold, making it unsafe to continue program execution.
 */
class Exception : Throwable
{

  /**
   * Creates a new instance of Exception. The next parameter is used
   * internally and should always be $(D null) when passed by user code.
   * This constructor does not automatically throw the newly-created
   * Exception; the $(D throw) statement should be used for that purpose.
   */
  @nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
  {
    super(msg, file, line, next);
  }

  @nogc @safe pure nothrow this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__)
  {
    super(msg, file, line, next);
  }
}
+/

/**
 * The base class of all unrecoverable runtime errors.
 *
 * This represents the category of $(D Throwable) objects that are $(B not)
 * safe to catch and handle. In principle, one should not catch Error
 * objects, as they represent unrecoverable runtime errors.
 * Certain runtime guarantees may fail to hold when these errors are
 * thrown, making it unsafe to continue execution after catching them.
 */
class Error : Throwable
{
  /**
   * Creates a new instance of Error. The next parameter is used
   * internally and should always be $(D null) when passed by user code.
   * This constructor does not automatically throw the newly-created
   * Error; the $(D throw) statement should be used for that purpose.
   */
  @nogc @safe pure nothrow this(string msg, Throwable next = null)
  {
    super(msg, next);
    bypassedException = null;
  }

  @nogc @safe pure nothrow this(string msg, string file, size_t line, Throwable next = null)
  {
    super(msg, file, line, next);
    bypassedException = null;
  }

  /// The first $(D Exception) which was bypassed when this Error was thrown,
  /// or $(D null) if no $(D Exception)s were pending.
  Throwable   bypassedException;
}

void destroy(T)(T obj) if (is(T == class))
{
  rt_finalize(cast(void*)obj);
}

void destroy(T)(T obj) if (is(T == interface))
{
  destroy(cast(Object)obj);
}

void destroy(T)(ref T obj) if (is(T == struct))
{
  _destructRecurse(obj);
  auto buf = (cast(ubyte*) &obj)[0 .. T.sizeof];
  auto init = cast(ubyte[])typeid(T).init();
  if (init.ptr is null) // null ptr means initialize to 0s
    buf[] = 0;
  else
    buf[] = init[];
}

  private void _destructRecurse(S)(ref S s)
if (is(S == struct))
{
  static if (__traits(hasMember, S, "__xdtor") &&
      // Bugzilla 14746: Check that it's the exact member of S.
      __traits(isSame, S, __traits(parent, s.__xdtor)))
    s.__xdtor();
}

private void _destructRecurse(E, size_t n)(ref E[n] arr)
{
  // import core.internal.traits : hasElaborateDestructor;
  // static if (hasElaborateDestructor!E)
  {
    foreach_reverse (ref elem; arr)
      _destructRecurse(elem);
  }
}

extern (C) Object _d_allocclass(const TypeInfo_Class ci) nothrow
{
  auto p = cast(byte*)malloc(ci.initializer.length);
  p[0 .. ci.initializer.length] = cast(byte[])ci.initializer[];
  return cast(Object)p;
}

extern (C) void* _d_newitemU(in TypeInfo ti)
{
	return malloc(ti.tsize);
}

extern (C) void* _d_newitemT(in TypeInfo ti)
{
	auto p = _d_newitemU(ti);
	memset(p, 0, ti.tsize);
	return p;
}

extern (C) void* _d_newitemiT(in TypeInfo ti)
{
	auto p = _d_newitemU(ti);
	auto init = ti.init;
	assert(init.length <= ti.tsize);
	p[0 .. init.length] = init[];
	return p;
}

// for array cast
extern (C)
size_t _d_array_cast_len(size_t len, size_t elemsz, size_t newelemsz)
{
  if (newelemsz == 1)
    return len*elemsz;
  if ((len*elemsz) % newelemsz)
    not_implemented(); // bad array cast
  return (len*elemsz)/newelemsz;
}

