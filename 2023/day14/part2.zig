const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Dir = enum { north, south, east, west };

fn load(map: [][]u8) usize {
    var i: usize = 0;
    var total: usize = 0;
    while (i < map.len) : (i += 1) {
        var j: usize = 0;
        while (j < map[i].len) : (j += 1) {
            if (map[i][j] == 'O') {
                total += map.len - i;
            }
        }
    }
    return total;
}

fn tilt(map: [][]u8, dir: Dir) void {
    if (dir == .north) {
        var i: usize = 0;
        while (i < map.len) : (i += 1) {
            var j: usize = 0;
            while (j < map[i].len) : (j += 1) {
                if (map[i][j] == 'O') {
                    var k = i;
                    while (0 < k and map[k - 1][j] == '.') : (k -= 1) {}
                    map[i][j] = '.';
                    map[k][j] = 'O';
                }
            }
        }
    } else if (dir == .south) {
        var i: usize = map.len - 1;
        while (0 <= i) : (i -= 1) {
            var j: usize = 0;
            while (j < map[i].len) : (j += 1) {
                if (map[i][j] == 'O') {
                    var k = i;
                    while (k < map.len - 1 and map[k + 1][j] == '.') : (k += 1) {}
                    map[i][j] = '.';
                    map[k][j] = 'O';
                }
            }
            if (i == 0) {
                break;
            }
        }
    } else if (dir == .west) {
        var i: usize = 0;
        while (i < map.len) : (i += 1) {
            var j: usize = 0;
            while (j < map[i].len) : (j += 1) {
                if (map[i][j] == 'O') {
                    var k = j;
                    while (0 < k and map[i][k - 1] == '.') : (k -= 1) {}
                    map[i][j] = '.';
                    map[i][k] = 'O';
                }
            }
        }
    } else if (dir == .east) {
        var i: usize = 0;
        while (i < map.len) : (i += 1) {
            var j: usize = map.len - 1;
            while (0 <= j) : (j -= 1) {
                if (map[i][j] == 'O') {
                    var k = j;
                    while (k < map[0].len - 1 and map[i][k + 1] == '.') : (k += 1) {}
                    map[i][j] = '.';
                    map[i][k] = 'O';
                }
                if (j == 0) {
                    break;
                }
            }
        }
    }
}

fn spin(map: [][]u8) void {
    tilt(map, .north);
    tilt(map, .west);
    tilt(map, .south);
    tilt(map, .east);
}

fn hash(map: [][]u8) u64 {
    var h = std.hash.Wyhash.init(1);
    for (map) |line| {
        h.update(line);
    }
    return h.final();
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.ArrayList([]u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try map.append(try copy(line));
    }
    var i: usize = 0;
    var maps = std.AutoHashMap(u64, usize).init(al);
    while (i < 12000) : (i += 1) {
        spin(map.items);
        var v = try maps.getOrPut(hash(map.items));
        if (v.found_existing) {
            var old = v.value_ptr.*;
            var increment = i - old;
            while ((1000000000 - i - 1) % increment != 0) : (i += 1) {
                spin(map.items);
            }
            try std.io.getStdOut().writer().print("{d}\n", .{load(map.items)});
            return;
        } else {
            v.value_ptr.* = i;
        }
    }
    for (map.items) |line| {
        try std.io.getStdOut().writer().print("{s}\n", .{line});
    }
    try std.io.getStdOut().writer().print("{d}\n", .{load(map.items)});
}
