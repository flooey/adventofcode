const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn visit(map: [][]const u8, visited: *std.AutoHashMap(Pos, void), sx: usize, sy: usize, sfromx: usize, sfromy: usize, sdistance: u32) !u32 {
    var x = sx;
    var y = sy;
    var fromx = sfromx;
    var fromy = sfromy;
    var distance = sdistance;
    while (true) {
        if (y == map.len - 1 and x == map[0].len - 2) {
            return distance;
        }
        var neighbors = std.ArrayList(Pos).init(al);
        defer neighbors.deinit();
        if ((map[y - 1][x] == '.' or map[y - 1][x] == '^') and y - 1 != fromy and !visited.contains(Pos{ .x = x, .y = y - 1 })) {
            try neighbors.append(Pos{ .x = x, .y = y - 1 });
        }
        if ((map[y][x - 1] == '.' or map[y][x - 1] == '<') and x - 1 != fromx and !visited.contains(Pos{ .x = x - 1, .y = y })) {
            try neighbors.append(Pos{ .x = x - 1, .y = y });
        }
        if ((map[y + 1][x] == '.' or map[y + 1][x] == 'v') and y + 1 != fromy and !visited.contains(Pos{ .x = x, .y = y + 1 })) {
            try neighbors.append(Pos{ .x = x, .y = y + 1 });
        }
        if ((map[y][x + 1] == '.' or map[y][x + 1] == '>') and x + 1 != fromx and !visited.contains(Pos{ .x = x + 1, .y = y })) {
            try neighbors.append(Pos{ .x = x + 1, .y = y });
        }
        // try std.io.getStdOut().writer().print("{d} {d} - {d}\n", .{ x, y, neighbors.items.len });
        if (neighbors.items.len == 0) {
            return 0;
        }
        if (neighbors.items.len > 1) {
            try visited.put(Pos{ .x = x, .y = y }, {});
            var max: u32 = 0;
            for (neighbors.items) |neighbor| {
                max = @max(max, try visit(map, visited, neighbor.x, neighbor.y, x, y, distance + 1));
            }
            _ = visited.remove(Pos{ .x = x, .y = y });
            return max;
        }
        var neighbor = neighbors.items[0];
        fromx = x;
        fromy = y;
        x = neighbor.x;
        y = neighbor.y;
        distance += 1;
    }
}

const Pos = struct {
    x: usize,
    y: usize,
};

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var mapIn = std.ArrayList([]const u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try mapIn.append(try copy(line));
    }
    var map = mapIn.items;
    var visited = std.AutoHashMap(Pos, void).init(al);
    var dist = try visit(map, &visited, 1, 1, 1, 0, 1);
    try std.io.getStdOut().writer().print("{d}\n", .{dist});
}
