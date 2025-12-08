import strutils
import std/sequtils
import std/sets
import std/tables
import std/algorithm
import math

type Point = (int, int, int)

var line: string
var points: seq[Point]

while readline(stdin, line):
    var coords = line.split(',').map(parseInt)
    points.add((coords[0], coords[1], coords[2]))

proc dist(x, y: Point): float64 =
    return sqrt(((x[0] - y[0]) ^ 2 + (x[1] - y[1]) ^ 2 + (x[2] - y[2]) ^ 2).float64)

var distances: seq[(float64, Point, Point)]

for i in 0..<len(points):
    for j in (i+1)..<len(points):
        let x = points[i]
        let y = points[j]
        distances.add((dist(x, y), x, y))

distances.sort(proc(a, b: (float64, Point, Point)): int =
    let d1 = a[0]
    let d2 = b[0]
    if d1 < d2:
        return -1
    elif d1 > d2:
        return 1
    else:
        return 0
)

var componentNum = 1
var pointToComponent: Table[Point, int]
var componentToPoints: Table[int, HashSet[Point]]

for i in 0..<distances.len():
    let p1 = distances[i][1]
    let p2 = distances[i][2]

    if not pointToComponent.contains(p1) and not pointToComponent.contains(p2):
        # New component
        pointToComponent.add(p1, componentNum)
        pointToComponent.add(p2, componentNum)
        componentToPoints.add(componentNum, toHashSet([p1, p2]))
        inc componentNum
    elif pointToComponent.contains(p1) and pointToComponent.contains(p2):
        # Both already in components
        let newComponent = pointToComponent[p1]
        let oldComponent = pointToComponent[p2]
        if newComponent == oldComponent:
            continue
        for p in componentToPoints[oldComponent]:
            componentToPoints[newComponent].incl(p)
            pointToComponent[p] = newComponent
        componentToPoints.del(oldComponent)
    else:
        # Only one in a component
        let component = pointToComponent.getOrDefault(p1, pointToComponent.getOrDefault(p2, -1))
        pointToComponent[p1] = component
        pointToComponent[p2] = component
        componentToPoints[component].incl(p1)
        componentToPoints[component].incl(p2)
    if len(componentToPoints) == 1:
        for c in componentToPoints.values:
            if len(c) == len(points):
                echo p1[0] * p2[0]
                quit()
