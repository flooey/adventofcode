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
    var i: usize = 0;
    if (dir == .north) {
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
    }
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.ArrayList([]u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try map.append(try copy(line));
    }
    tilt(map.items, .north);
    try std.io.getStdOut().writer().print("{d}\n", .{load(map.items)});
}
