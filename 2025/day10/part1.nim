import strutils
import std/sequtils
import std/tables
import std/bitops
import std/deques

type Problem = tuple[goal: int, buttons: seq[int]]

proc parseBracketed(line: string, oi: int): (seq[int], char, int) =
    var i = oi
    while line[i] != '(' and line[i] != '{':
        inc i
    let start = i
    while line[i] != ')' and line[i] != '}':
        inc i
    let e = i
    let vals = line[(start+1)..(e-1)].split(',').map(parseInt)
    return (vals, line[start], i)

var line: string
var problems: seq[Problem]

while readline(stdin, line):
    var i = 1
    var goal = 0
    while line[i] != ']':
        if line[i] == '#':
            goal += 1 shl (i - 1)
        inc i
    var buttons: seq[int]
    while true:
        var vals: seq[int]
        var t: char
        (vals, t, i) = parseBracketed(line, i)
        if t == '{':
            break
        var button = 0
        for v in vals:
            button += 1 shl v
        buttons.add(button)
    problems.add((goal: goal, buttons: buttons))

var totalPushes = 0

for (goal, buttons) in problems:
    var queue = [(0, 0)].toDeque
    block problem:
        while true:
            let (val, count) = queue.popFirst()
            for b in buttons:
                let newVal = bitxor(val, b)
                if newVal == goal:
                    totalPushes += count + 1
                    break problem
                queue.addLast((newVal, count + 1))

echo totalPushes

            

