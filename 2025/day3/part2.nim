import std/sequtils
import std/math

var line: string

var total = 0

while readline(stdin, line):
    var joltages = map(line, proc(c: char): int = ord(c) - ord('0'))
    var start = 0
    for d in 0..11:
        var maxValue = 0
        var maxInd = -1
        for i in start..(joltages.len - (12 - d)):
            if joltages[i] > maxValue:
                maxValue = joltages[i]
                maxInd = i
        total += maxValue * (10 ^ (11 - d))
        start = maxInd + 1

echo total