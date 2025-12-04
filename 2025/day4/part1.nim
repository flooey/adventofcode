var line: string
var lines: seq[string]

while readline(stdin, line):
    lines.add(line)

proc neighbors(x: int, y: int, lines: seq[string]): int =
    var total = 0
    for i in (x-1)..(x+1):
        for j in (y-1)..(y+1):
            if i == x and j == y:
                continue
            if i < 0 or i >= lines.len:
                continue
            if j < 0 or j >= lines[i].len:
                continue
            if lines[i][j] == '@':
                inc total
        
    return total

var available = 0
for i in 0..(lines.len - 1):
    for j in 0..(lines[i].len - 1):
        if lines[i][j] == '@' and neighbors(i, j, lines) < 4:
            inc available

echo available