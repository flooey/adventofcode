import std.stdio;
import std.conv;
import std.math.algebraic;

int dist(int x1, int y1, int x2, int y2) {
  return abs(x1 - x2) + abs(y1 - y2);
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
  int count = 0;
  for (int x = minX - 1; x <= maxX + 1; x++) {
    for (int y = minY - 1; y <= maxY + 1; y++) {
      int totalDist = 0;
      foreach (coord; coords) {
        totalDist += dist(x, y, coord[0], coord[1]);
      }
      if (totalDist < 10000) {
        count++;
      }
    }
  }
  writeln(count);
}
