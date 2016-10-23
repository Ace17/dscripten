pragma(LDC_no_moduleinfo);
/*
 * Copyright (C) 2016 - Sebastien Alaiwan
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 */
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

  Vec2 opMul(T)(T val) const
  {
    Vec2 r = this;
    r.x *= val;
    r.y *= val;
    return r;
  }

  void opDivAssign(T)(T val)
  {
    x /= val;
    y /= val;
  }

  Vec2 opDiv(T)(T val) const
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

