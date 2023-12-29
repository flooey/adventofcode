const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn copy2(s: [][]const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    var i = 0;
    while (i < s.len) : (i += 1) {
        buf[i] = try copy(s[i]);
    }
    return buf;
}

const Loc = struct {
    x: usize,
    y: usize,
};

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.ArrayList([]const u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try map.append(try copy(line));
    }
    var x: usize = 0;
    var y: usize = 0;
    var locs = std.AutoHashMap(Loc, void).init(al);
    while (y < map.items.len) : (y += 1) {
        x = 0;
        while (x < map.items[y].len) : (x += 1) {
            if (map.items[y][x] == 'S') {
                try locs.put(Loc{ .x = x, .y = y }, {});
            }
        }
    }
    var i: usize = 0;
    while (i < 64) : (i += 1) {
        var newlocs = std.AutoHashMap(Loc, void).init(al);
        var it = locs.keyIterator();
        while (it.next()) |loc| {
            if (map.items[loc.y][loc.x + 1] != '#') {
                try newlocs.put(Loc{ .x = loc.x + 1, .y = loc.y }, {});
            }
            if (map.items[loc.y][loc.x - 1] != '#') {
                try newlocs.put(Loc{ .x = loc.x - 1, .y = loc.y }, {});
            }
            if (map.items[loc.y + 1][loc.x] != '#') {
                try newlocs.put(Loc{ .x = loc.x, .y = loc.y + 1 }, {});
            }
            if (map.items[loc.y - 1][loc.x] != '#') {
                try newlocs.put(Loc{ .x = loc.x, .y = loc.y - 1 }, {});
            }
        }
        var oldlocs = locs;
        locs = newlocs;
        oldlocs.deinit();
    }
    try std.io.getStdOut().writer().print("{d}\n", .{locs.count()});
}
