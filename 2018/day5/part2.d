import std.stdio;

size_t process(string input, char toRemove) {
  auto toRemoveFlip = toRemove - 'A' + 'a';
  string processed = "";
  foreach (c; input) {
    if (c == toRemove || c == toRemoveFlip) {
      continue;
    }
    auto flip = ('A' <= c && c <= 'Z') ? c - 'A' + 'a' : c - 'a' + 'A';
    if (processed.length > 0 && processed[$-1] == flip) {
      processed.length--;
    } else {
      processed ~= c;
    }
  }
  return processed.length;
}

void main() {
	auto input = readln();
  input.length--;
  size_t min = process(input, 'A');
  for (char c = 'B'; c <= 'Z'; c++) {
    size_t result = process(input, c);
    if (result < min) {
      min = result;
    }
  }

  writeln(min);
}
