import std.stdio;
import std.algorithm.searching;

void main() {
  auto done = new bool[26];
  auto deps = new int[][26];
  auto workerDone = new int[5];
  auto workerTasks = new int[5];
  workerTasks[] = -1;
  for (auto i = 0; i < 26; i++) {
    deps[i] = new int[0];
  }
  foreach (string line; lines(stdin)) {
    deps[line[36] - 'A'] ~= line[5] - 'A';
  }
  auto result = "";
  int time = 0;
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
      for (int w = 0; w < 5; w++) {
        if (workerTasks[w] == i) {
          continue outer;
        }
      }
      for (int w = 0; w < 5; w++) {
        if (workerDone[w] <= time) {
          workerTasks[w] = i;
          workerDone[w] = time + 60 + i + 1;
          break;
        }
      }
    }
    // All workers are assigned, skip forward to when the next worker is done
    int minDone = 10000000;
    for (int w = 0; w < 5; w++) {
      if (workerDone[w] > time && workerDone[w] < minDone) {
        minDone = workerDone[w];
      }
    }
    time = minDone;
    for (int w = 0; w < 5; w++) {
      if (workerDone[w] == time) {
        result ~= 'A' + workerTasks[w];
        done[workerTasks[w]] = true;
      }
    }
  }
  writeln(time);
}
