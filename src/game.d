/*
 * Copyright (C) 2016 - Sebastien Alaiwan
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 */
import core.stdc.stdio;

import vec;
import minirt;

Vec2 pos;
Vec2 vel;
bool firing;

enum SPEED = 30;

struct Command
{
  Vec2 dir;
  bool fire;
}

void init()
{
  enum COLOR
  {
    RED,
    GREEN,
    BLUE,
  }

  auto c = COLOR.GREEN;
  printf("%s\n", enumToString(c).ptr);

  pos = Vec2(100, 100);
  vel = Vec2(1000, 0);
}

void update(Command cmd)
{
  vel += cmd.dir * SPEED;
  if(pos.x < 0)
    vel.x = abs(vel.x);
  if(pos.x > 640)
    vel.x = -abs(vel.x);

  if(pos.y < 0)
    vel.y = abs(vel.y);
  if(pos.y > 480)
    vel.y = -abs(vel.y);

  pos += vel / 10;
  vel *= 9;
  vel /= 10;

  firing = cmd.fire;
}

