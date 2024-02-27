import std.stdio;

void main() {
	auto input = readln();
  input.length--;
  string processed = "";
  foreach (c; input) {
    auto flip = ('A' <= c && c <= 'Z') ? c - 'A' + 'a' : c - 'a' + 'A';
    if (processed.length > 0 && processed[$-1] == flip) {
      processed.length--;
    } else {
      processed ~= c;
    }
  }
  writeln(processed.length);
}
