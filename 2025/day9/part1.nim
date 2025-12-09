import strutils
import std/sequtils

type Point = (int, int)

var line: string
var points: seq[Point]

while readline(stdin, line):
    var coords = line.split(',').map(parseInt)
    points.add((coords[0], coords[1]))

var largest = 0

for i in 0..<points.len():
    for j in (i+1)..<points.len():
        let p1 = points[i]
        let p2 = points[j]
        let area = (abs(p1[0] - p2[0]) + 1) * (abs(p1[1] - p2[1]) + 1)
        if area > largest:
            largest = area

echo largest