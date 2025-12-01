import strutils
import std/strformat

var
    line: string
    pos = 50
    count = 0

while readline(stdin, line):
    var tomove = strutils.parseInt(line[1 .. ^1])
    if line[0] == 'L':
        while tomove > 0:
            pos -= 1
            if pos == 0:
                count += 1
            if pos < 0:
                pos += 100
            tomove -= 1
    else:
        while tomove > 0:
            pos += 1
            if pos >= 100:
                pos -= 100
            if pos == 0:
                count += 1
            tomove -= 1

echo count
