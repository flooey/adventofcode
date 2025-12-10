import strutils
import std/sequtils
import std/deques

type Problem = tuple[goal: seq[int], buttons: seq[seq[int]]]

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
    var buttons: seq[seq[int]]
    var i = 0
    while true:
        var vals: seq[int]
        var t: char
        (vals, t, i) = parseBracketed(line, i)
        if t == '{':
            problems.add((goal: vals, buttons: buttons))
            break
        buttons.add(vals)

var totalPushes = 0

for (goal, buttons) in problems:
    # This functions as a system of linear equations

echo totalPushes

            

