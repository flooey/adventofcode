import strutils
import std/strformat

var
    line: string
    pos = 50
    count = 0

while readline(stdin, line):
    var dir = 1
    if line[0] == 'L':
        dir = -1
    pos += dir * strutils.parseInt(line[1 .. ^1])
    while pos < 0:
        pos += 100
    while pos >= 100:
        pos -= 100
    if pos == 0:
        count += 1

echo count
