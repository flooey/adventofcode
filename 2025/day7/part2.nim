import std/sets
import std/tables

var line: string
var splitters: HashSet[(int, int)]
var cur: Table[(int, int), int]

var y = 0
while readline(stdin, line):
    for x in 0..<line.len():
        if line[x] == '^':
            splitters.incl((x, y))
        elif line[x] == 'S':
            cur.add((x, y), 1)
    inc y

let maxy = y
y = 0
while y < maxy:
    var newCur: Table[(int, int), int]
    for p in cur.keys:
        if splitters.contains((p[0], p[1] + 1)):
            let l = (p[0] - 1, p[1] + 1)
            let r = (p[0] + 1, p[1] + 1)
            newCur[l] = newCur.getOrDefault(l, 0) + cur[p]
            newCur[r] = newCur.getOrDefault(r, 0) + cur[p]
        else:
            let newP = (p[0], p[1] + 1)
            newCur[newP] = newCur.getOrDefault(newP, 0) + cur[p]
    cur = newCur
    inc y

var lifetimes = 0
for p in cur.keys:
    lifetimes += cur[p]
echo lifetimes