import std/strutils
import std/sequtils

var line: string

var items: seq[seq[string]]

while readline(stdin, line):
    items.add(line.split().filter(proc (x: string): bool = x != ""))

var total = 0

for i in 0..(items[0].len() - 1):
    let op = items[^1][i]
    var cur = (if op == "+": 0 else: 1)
    for j in 0..(items.len() - 2):
        if op == "+":
            cur += parseInt(items[j][i])
        else:
            cur *= parseInt(items[j][i])
    total += cur

echo total
