import std/sequtils

var line: string

var total = 0

while readline(stdin, line):
    var joltages = map(line, proc(c: char): int = ord(c) - ord('0'))
    var maxValue = 0
    var maxInd = -1
    for i in 0..(joltages.len-2):
        if joltages[i] > maxValue:
            maxValue = joltages[i]
            maxInd = i

    var nextValue = 0
    var nextInd = 0
    for i in (maxInd+1)..(joltages.len-1):
        if joltages[i] > nextValue:
            nextValue = joltages[i]
            nextInd = i
    
    total += 10 * maxValue + nextValue

echo total