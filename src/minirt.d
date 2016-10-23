// minimalistic D runtime
pragma(LDC_no_moduleinfo);
import core.stdc.stdio;
import core.stdc.stdlib;
import std.conv: emplace;

T* createStruct(T, Args...)(auto ref Args args)
{
  auto r = cast(T*) calloc(1, T.sizeof);
  emplace!T(r, args);
  return r;
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

