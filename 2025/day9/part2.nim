import strutils
import std/sequtils

type Point = (int, int)
type Dir = enum North, South, East, West
proc opp(d: Dir): Dir =
    case d:
    of North:
        return South
    of South:
        return North
    of East:
        return West
    of West:
        return East

var line: string
var rawpoints: seq[Point]

proc dir(f, t: Point): Dir =
    if f[0] == t[0]:
        if f[1] < t[1]:
            return North
        else:
            return South
    else:
        if f[0] < t[0]:
            return East
        else:
            return West

proc indir(prev, next, previn: Dir): Dir =
    if previn == next:
        return prev
    if previn == opp(next):
        return opp(prev)
    else:
        return previn


while readline(stdin, line):
    var coords = line.split(',').map(parseInt)
    rawpoints.add((coords[0], coords[1]))

var previn: Dir = South

var points: seq[(Point, Dir, Dir, Dir)]
for i in 0..<rawpoints.len():
    let p = rawpoints[i]
    let prev = if i == 0: rawpoints[^1] else: rawpoints[i-1]
    let next = if i == rawpoints.len() - 1: rawpoints[0] else: rawpoints[i+1]

    let pdir = dir(p, prev)
    let ndir = dir(p, next)
    previn = indir(pdir, ndir, previn)
    points.add((p, pdir, ndir, previn))

var largest = 0

for i in 0..<points.len():
    for j in (i+1)..<points.len():
        let (p1, p1dir1, p1dir2, p1in) = points[i]
        let (p2, p2dir1, p2dir2, p2in) = points[j]
        let area = (abs(p1[0] - p2[0]) + 1) * (abs(p1[1] - p2[1]) + 1)
        if area > largest:
            # echo "Considering ", p1, " ", p2
            # Check if it's valid
            # case p1in:
            # of North:
            #     if p1[1] > p2[1]:
            #         echo "Rejected: outside"
            #         continue
            # of South:
            #     if p1[1] < p2[1]:
            #         echo "Rejected: outside"
            #         continue
            # of East:
            #     if p1[0] > p2[0]:
            #         echo "Rejected: outside"
            #         continue
            # of West:
            #     if p1[0] < p2[0]:
            #         echo "Rejected: outside"
            #         continue
            # case p2in:
            # of North:
            #     if p2[1] > p1[1]:
            #         echo "Rejected: outside"
            #         continue
            # of South:
            #     if p2[1] < p1[1]:
            #         echo "Rejected: outside"
            #         continue
            # of East:
            #     if p2[0] > p1[0]:
            #         echo "Rejected: outside"
            #         continue
            # of West:
            #     if p2[0] < p1[0]:
            #         echo "Rejected: outside"
            #         continue
            let minx = min(p1[0], p2[0])
            let maxx = max(p1[0], p2[0])
            let miny = min(p1[1], p2[1])
            let maxy = max(p1[1], p2[1])
            var valid = true
            for k in 0..<points.len():
                if k == i or k == j:
                    continue
                let (p, pdir1, pdir2, pin) = points[k]

                # If another point falls inside the rectangle, it must not be filled
                if minx < p[0] and p[0] < maxx and miny < p[1] and p[1] < maxy:
                    # echo "Rejected: includes ", p
                    valid = false
                    break
                if minx == p[0] and miny < p[1] and p[1] < maxy:
                    if pdir1 == East or pdir2 == East:
                        # echo "Rejected: includes ", p
                        valid = false
                        break
                if maxx == p[0] and miny < p[1] and p[1] < maxy:
                    if pdir1 == West or pdir2 == West:
                        # echo "Rejected: includes ", p
                        valid = false
                        break
                if minx < p[0] and p[0] < maxx and miny == p[1]:
                    if pdir1 == North or pdir2 == North:
                        # echo "Rejected: includes ", p
                        valid = false
                        break
                if minx < p[0] and p[0] < maxx and maxy == p[1]:
                    if pdir1 == South or pdir2 == South:
                        # echo "Rejected: includes ", p
                        valid = false
                        break

                # If the line from this point to the next point crosses the rectangle, it also must not be filled
                let nextp = if k+1 == points.len(): points[0][0] else: points[
                        k+1][0]
                if (p[0] < minx and maxx < nextp[0]) or (nextp[0] < minx and
                        maxx < p[0]):
                    if miny < p[1] and p[1] < maxy:
                        # echo "Rejected: crossed by ", p, " and ", nextp
                        valid = false
                        break
                if (p[1] < miny and maxy < nextp[1]) or (nextp[1] < miny and
                        maxy < p[1]):
                    if minx < p[0] and p[0] < maxx:
                        # echo "Rejected: crossed by ", p, " and ", nextp
                        valid = false
                        break

            if valid:
                largest = area
                # echo "Improved: ", p1, " ", p2

echo largest
