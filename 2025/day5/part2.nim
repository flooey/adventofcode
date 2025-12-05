import algorithm
import strutils
import std/sequtils

var line: string
var lines: seq[string]

var ranges: seq[seq[int]]

while readline(stdin, line):
    if line == "":
        break
    ranges.add(map(split(line, '-'), parseInt))

ranges.sort(proc (a, b: seq[int]): int = return a[0] - b[0])

var newranges: seq[seq[int]]
newranges.add(ranges[0])

for i in 1..(ranges.len() - 1):
    if ranges[i][0] <= newranges[^1][1] + 1:
        newranges[^1][1] = max(ranges[i][1], newranges[^1][1])
    else:
        newranges.add(ranges[i])

var total = 0
for r in newranges:
    total += r[1] - r[0] + 1

echo total