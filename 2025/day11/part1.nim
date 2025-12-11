import strutils
import std/tables

var line: string
var connections = initTable[string, seq[string]]()

while readline(stdin, line):
    let parts = line.split(": ")
    let key = parts[0]
    let outputs = parts[1].split(" ")
    connections[key] = outputs

proc countPaths(connections: Table[string, seq[string]], location: string): int =
    if location == "out":
        return 1
    if not connections.hasKey(location):
        return 0
    var total = 0
    for connection in connections[location]:
        total += countPaths(connections, connection)
    return total

echo countPaths(connections, "you")