import unicode
import std/sequtils
import strutils
import std/math

var line = readline(stdin)

var parts = split(line, Rune(','))

var ranges = map(parts, proc(x: string): seq[int] = map(split(x, Rune('-')), parseInt))
var result = 0

for r in ranges:
    var low = r[0]
    var high = r[1]

    let lenLow = (floor(log10(low.float64)) + 1).Natural
    
    var cur = 0
    var step = 0
    if lenLow mod 2 == 1:
        # If lenLow == 5, we want cur = 100100 and step = 1001
        cur = 10 ^ lenLow + 10 ^ (lenLow div 2)
        step = 10 ^ (lenLow div 2 + 1) + 1
    else:
        # If lenLow = 6, we want cur = XYZXYZ and step = 1001
        cur = low div (10 ^ (lenLow div 2)) * (10 ^ (lenLow div 2)) + low div (10 ^ (lenLow div 2))
        step = 10 ^ (lenLow div 2) + 1
    
    let lenHigh = (floor(log10(high.float64)) + 1).Natural
    if lenHigh mod 2 == 1:
        high = 10 ^ (lenHigh - 1)
    
    while cur <= high:
        if cur >= low:
            result += cur
        cur += step

echo result