struct Vec2
{
  int x, y;

  void opAddAssign(Vec2 other)
  {
    x += other.x;
    y += other.y;
  }
}

