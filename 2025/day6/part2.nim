import std/strutils
import std/sequtils

var line: string
var lines: seq[string]

while readline(stdin, line):
    lines.add(line)

var bounds: seq[int]
for i in 0..<lines[^1].len():
    if lines[^1][i] != ' ':
        bounds.add(i)

var total = 0

for i in 0..<bounds.len():
    let b = bounds[i]
    let op = lines[^1][b]
    var cur = (if op == '+': 0 else: 1)
    var up = (if i == bounds.len() - 1: lines[0].len() - 1 else: bounds[i+1] - 1)
    for j in b..up:
        var val: string
        for x in 0..<(lines.len() - 1):
            if lines[x][j] != ' ':
                val.add(lines[x][j])
        if val == "":
            continue
        if op == '+':
            cur += parseInt(val)
        else:
            cur *= parseInt(val)
    total += cur

echo total
