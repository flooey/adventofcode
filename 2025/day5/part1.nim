import strutils
import std/sequtils

var line: string
var lines: seq[string]

var ranges: seq[seq[int]]

while readline(stdin, line):
    if line == "":
        break
    ranges.add(map(split(line, '-'), parseInt))

var available: seq[int]
while readline(stdin, line):
    available.add(parseInt(line))

var total = 0
for i in available:
    for r in ranges:
        if r[0] <= i and i <= r[1]:
            inc total
            break

echo total