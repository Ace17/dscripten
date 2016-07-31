struct Vec2
{
  int x, y;

  void opAddAssign(Vec2 other)
  {
    x += other.x;
    y += other.y;
  }

  void opMulAssign(T)(T val)
  {
    x *= val;
    y *= val;
  }

  void opDivAssign(T)(T val)
  {
    x /= val;
    y /= val;
  }

  Vec2 opDiv(T)(T val)
  {
    Vec2 r = this;
    r.x /= val;
    r.y /= val;
    return r;
  }
}

auto abs(T)(T val)
{
  if(val < 0)
    return -val;
  else
    return val;
}

