import std.stdio;
import std.conv;
import std.array;
import std.container.dlist;

void mark(int[] coord, int[][][] map, int id) {
  auto todo = DList!(int[])();
  todo.insert([coord[0], coord[1], 0]);
  while (!todo.empty) {
    auto val = todo.front();
    todo.removeFront();
    auto x = val[0];
    auto y = val[1];
    auto steps = val[2];
    if (x < 0 || map.length <= x || y < 0 || map[0].length <= y) {
      continue;
    }
    auto curDist = map[x][y][1];
    if (curDist < steps) {
      continue;
    }
    if (curDist == steps && (map[x][y][0] == id || map[x][y][0] == -1)) {
      continue;
    }
    if (curDist == steps) {
      map[x][y][0] = -1;
    } else {
      map[x][y][0] = id;
      map[x][y][1] = steps;
    }
    todo.insert([[x + 1, y, steps + 1], [x - 1, y, steps + 1], [x, y + 1, steps + 1], [x, y - 1, steps + 1]]);
  }
}

int count(int id, int[][][] map) {
  int result = 0;
  for (int x = 0; x < map.length; x++) {
    for (int y = 0; y < map[0].length; y++) {
      if (map[x][y][0] == id) {
        if (x == 0 || x == map.length - 1 || y == 0 || y == map[0].length - 1) {
          return -1;
        }
        result++;
      }
    }
  }
  return result;
}

void main() {
  auto coords = new int[][0];
  int minX = 10000;
  int minY = 10000;
  int maxX = 0;
  int maxY = 0;
  foreach (string line; lines(stdin)) {
    auto x = parse!int(line);
    line = line[2..$];
    auto y = parse!int(line);
    coords ~= [x, y];
    if (x > maxX) {
      maxX = x;
    }
    if (x < minX) {
      minX = x;
    }
    if (y > maxY) {
      maxY = y;
    }
    if (y < minY) {
      minY = y;
    }
  }
  maxX -= minX - 1;
  maxY -= minY - 1;
  auto map = new int[][][maxX + 1];
  for (int x = 0; x < map.length; x++) {
    map[x] = new int[][maxY + 1];
    for (int y = 0; y < map[x].length; y++) {
      map[x][y] = [-1, 10000];
    }
  }
  foreach (i, coord; coords) {
    coord[0] -= minX - 1;
    coord[1] -= minY - 1;
    mark(coord, map, to!int(i));
  }
  int best = 0;
  for (auto i = 0; i < coords.length; i++) {
    auto c = count(i, map);
    if (c > best) {
      best = c;
    }
  }
  writeln(best);
}
