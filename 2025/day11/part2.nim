import strutils
import std/tables

var line: string
var connections = initTable[string, seq[string]]()

while readline(stdin, line):
    let parts = line.split(": ")
    let key = parts[0]
    let outputs = parts[1].split(" ")
    connections[key] = outputs

proc countPaths(connections: Table[string, seq[string]], cache: var Table[string, int], location, dest: string): int =
    if location == dest:
        return 1
    if cache.hasKey(location):
        return cache[location]
    if not connections.hasKey(location):
        return 0
    if connections.hasKey(dest):
        for connection in connections[dest]:
            if location == connection:
                return 0
    var total = 0
    for connection in connections[location]:
        total += countPaths(connections, cache, connection, dest)
    cache[location] = total
    return total

proc countPaths(connections: Table[string, seq[string]], location, dest: string): int =
    var cache = initTable[string, int]()
    return countPaths(connections, cache, location, dest)

var start: int
var middle = countPaths(connections, "dac", "fft")
var tail: int
if middle == 0:
    start = countPaths(connections, "svr", "fft")
    middle = countPaths(connections, "fft", "dac")
    tail = countPaths(connections, "dac", "out")
else:
    start = countPaths(connections, "svr", "dac")
    tail = countPaths(connections, "fft", "out")
echo start * middle * tail
