import std.stdio;

void main() {
  auto done = new bool[26];
  auto deps = new int[][26];
  for (auto i = 0; i < 26; i++) {
    deps[i] = new int[0];
  }
  foreach (string line; lines(stdin)) {
    deps[line[36] - 'A'] ~= line[5] - 'A';
  }
  auto result = "";
  while (result.length < 26) {
    outer: for (auto i = 0; i < 26; i++) {
      if (done[i]) {
        continue;
      }
      foreach (int c; deps[i]) {
        if (!done[c]) {
          continue outer;
        }
      }
      result ~= 'A' + i;
      done[i] = true;
      break;
    }
  }
  writeln(result);
}
