/*
 * Copyright (C) 2016 - Sebastien Alaiwan
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 */
pragma(LDC_no_moduleinfo);

import vec;
import standard;

enum WIDTH = 512;
enum HEIGHT = 512;

struct Box
{
  bool enable;
  Vec2 pos;
  Vec2 vel;
}

Box player;
bool firing;
bool dead;

Box[128] boxes;

enum SIZE = 10;

struct Command
{
  Vec2 dir;
  bool fire;
}

void init()
{
  printf("-------------------------\n");
  printf("Avoid the red boxes!\n");

  dead = false;
  ticks = 0;

  boxes[] = Box();
  player.pos = Vec2(100, 100);
  player.vel = Vec2(1000, 0);

  for(int i = 0; i < 2; ++i)
    spawnRandomBox();

  testClass();
}

void testClass()
{
  printf("HELLO\n");
  ubyte[128] buffer;
  auto c = newObject!C;
  c.f();
  c = newObject!D;
  c.f();
}

class C
{
  void f()
  {
    printf("YO: C\n");
  }
}

class D : C
{
  override void f()
  {
    printf("YO: D\n");
  }
}

void update(Command cmd)
{
  if(dead)
    return;

  player.vel += cmd.dir * SPEED;
  firing = cmd.fire;

  if(ticks % 100 == 0)
  {
    spawnRandomBox();
    shakeBoxes();
  }

  updateBox(&player);

  foreach(ref b; boxes)
    updateBox(&b);

  detectCollisions();

  ++ticks;
}

private:

enum SPEED = 30;
int ticks;
int bestScore;

void updateBox(Box* box)
{
  if(box.pos.x < 0)
    box.vel.x = abs(box.vel.x);

  if(box.pos.x + SIZE > WIDTH)
    box.vel.x = -abs(box.vel.x);

  if(box.pos.y < 0)
    box.vel.y = abs(box.vel.y);

  if(box.pos.y + SIZE > HEIGHT)
    box.vel.y = -abs(box.vel.y);

  box.pos += box.vel / 10;
  box.vel *= 9;
  box.vel /= 10;
}

void detectCollisions()
{
  foreach(ref b; boxes)
  {
    if(!b.enable)
      continue;

    if(overlaps(b, player))
    {
      gameOver();
      break;
    }
  }
}

void gameOver()
{
  dead = true;

  bestScore = max(bestScore, ticks);
  printf("You died!\n");
  printf("Your score: %d (High score: %d)\n", ticks, bestScore);
  printf("Press 'R' to retry\n");
}

void shakeBoxes()
{
  foreach(ref b; boxes)
    b.vel = Vec2(uniform(-5, 5) * 100, uniform(-5, 5) * 100);
}

void spawnRandomBox()
{
  spawnBox(Vec2(uniform(0, WIDTH), uniform(0, HEIGHT)));
}

Box* spawnBox(Vec2 where)
{
  auto box = allocBox();
  box.pos = where;
  return box;
}

Box* allocBox()
{
  foreach(ref box; boxes)
  {
    if(!box.enable)
    {
      box.enable = true;
      return &box;
    }
  }

  return &boxes[0];
}

bool overlaps(ref Box a, ref Box b)
{
  if(a.pos.x + SIZE < b.pos.x)
    return false;

  if(b.pos.x + SIZE < a.pos.x)
    return false;

  if(a.pos.y + SIZE < b.pos.y)
    return false;

  if(b.pos.y + SIZE < a.pos.y)
    return false;

  return true;
}

int uniform(int min, int max)
{
  import core.stdc.stdlib: rand;
  return rand() % (max - min) + min;
}

auto max(T)(T a, T b)
{
  return a > b ? a : b;
}

