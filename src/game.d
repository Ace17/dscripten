/*
 * Copyright (C) 2016 - Sebastien Alaiwan
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 */
import core.stdc.stdio;
import core.stdc.stdlib: rand;
import std.algorithm;

import vec;
import minirt;

Box player;
bool firing;
int ticks;
bool dead;
int bestScore;

struct Box
{
  bool enable;
  Vec2 pos;
  Vec2 vel;
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

Box[128] boxes;

enum SPEED = 30;
enum SIZE = 10;

struct Command
{
  Vec2 dir;
  bool fire;
}

void init()
{
  dead = false;
  ticks = 0;

  if(0)
  {
    enum COLOR
    {
      RED,
      GREEN,
      BLUE,
    }

    auto c = COLOR.GREEN;
    printf("%s\n", enumToString(c).ptr);
  }

  boxes[] = Box();
  player.pos = Vec2(100, 100);
  player.vel = Vec2(1000, 0);

  for(int i = 0; i < 2; ++i)
    spawnRandomBox();
}

void spawnRandomBox()
{
  spawnBox(Vec2(uniform(0, 640), uniform(0, 480)));
}

void shakeEnemies()
{
  foreach(ref b; boxes)
    b.vel = Vec2(uniform(-5, 5) * 100, uniform(-5, 5) * 100);
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

void update(Command cmd)
{
  if(dead)
    return;

  player.vel += cmd.dir * SPEED;
  firing = cmd.fire;

  if(ticks % 100 == 0)
  {
    spawnRandomBox();
    shakeEnemies();
  }

  updateBox(&player);

  foreach(ref b; boxes)
    updateBox(&b);

  detectCollisions();

  ++ticks;
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
  printf("YOU DIED!\n");
  printf("YOUR SCORE: %d (BEST: %d)\n", ticks, bestScore);
  printf("PRESS 'R' TO RESTART\n");
}

void updateBox(Box* box)
{
  if(box.pos.x < 0)
    box.vel.x = abs(box.vel.x);

  if(box.pos.x + SIZE > 640)
    box.vel.x = -abs(box.vel.x);

  if(box.pos.y < 0)
    box.vel.y = abs(box.vel.y);

  if(box.pos.y + SIZE > 480)
    box.vel.y = -abs(box.vel.y);

  box.pos += box.vel / 10;
  box.vel *= 9;
  box.vel /= 10;
}

int uniform(int min, int max)
{
  return rand() % (max - min) + min;
}

