import std/sets

var line: string
var splitters: HashSet[(int, int)]
var cur: HashSet[(int, int)]

var y = 0
while readline(stdin, line):
    for x in 0..<line.len():
        if line[x] == '^':
            splitters.incl((x, y))
        elif line[x] == 'S':
            cur.incl((x, y))
    inc y

var splits = 0
let maxy = y
y = 0
while y < maxy:
    var newCur: HashSet[(int, int)]
    for p in cur:
        if splitters.contains((p[0], p[1] + 1)):
            newCur.incl((p[0] + 1, p[1] + 1))
            newCur.incl((p[0] - 1, p[1] + 1))
            inc splits
        else:
            newCur.incl((p[0], p[1] + 1))
    cur = newCur
    inc y

echo splits