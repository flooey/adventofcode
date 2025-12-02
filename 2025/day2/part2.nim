import unicode
import std/sequtils
import strutils
import std/math

var line = readline(stdin)

var parts = split(line, Rune(','))

var ranges = map(parts, proc(x: string): seq[int] = map(split(x, Rune('-')), parseInt))
var result = 0

proc is_match(x: int): bool =
    let len = (floor(log10(x.float64)) + 1).Natural
    if len == 1:
        return false
    block outerloop:
        for i in 1..(len div 2):
            if len mod i == 0:
                let segment = 10 ^ i
                let target = x mod segment
                var cur = x
                var found = true
                while cur > 0:
                    if cur mod segment != target:
                        found = false
                        break
                    cur = cur div segment
                if found:
                    return true
    return false


for r in ranges:
    var l = r[0]
    var h = r[1]

    for i in l..h:
        if is_match(i):
            result += i

echo result