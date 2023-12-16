const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

const Dir = enum { up, down, left, right };

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Loc = struct {
    x: usize,
    y: usize,
};

var seen = std.AutoHashMap(Loc, *std.AutoHashMap(Dir, void)).init(al);

fn markSeen(x: usize, y: usize, dir: Dir) !void {
    var key = .{ .x = x, .y = y };
    if (!seen.contains(key)) {
        var val = try al.create(std.AutoHashMap(Dir, void));
        val.* = std.AutoHashMap(Dir, void).init(al);
        try seen.put(key, val);
    }
    try seen.get(key).?.put(dir, {});
}

fn isSeen(x: usize, y: usize, dir: Dir) bool {
    var key = .{ .x = x, .y = y };
    return seen.contains(key) and seen.get(key).?.contains(dir);
}

fn do(map: [][]const u8, sx: usize, sy: usize, sdir: Dir) !void {
    var x = sx;
    var y = sy;
    var dir = sdir;
    while (!isSeen(x, y, dir)) {
        try markSeen(x, y, dir);
        switch (map[y][x]) {
            '.' => {
                // Do nothing
            },
            '|' => {
                if (dir == .right or dir == .left) {
                    try do(map, x, y, .up);
                    dir = .down;
                }
            },
            '-' => {
                if (dir == .up or dir == .down) {
                    try do(map, x, y, .left);
                    dir = .right;
                }
            },
            '/' => {
                dir = switch (dir) {
                    .up => .right,
                    .down => .left,
                    .right => .up,
                    .left => .down,
                };
            },
            '\\' => {
                dir = switch (dir) {
                    .up => .left,
                    .down => .right,
                    .right => .down,
                    .left => .up,
                };
            },
            else => {
                unreachable;
            },
        }
        switch (dir) {
            .up => {
                if (y == 0) {
                    return;
                }
                y -= 1;
            },
            .down => {
                if (y == map.len - 1) {
                    return;
                }
                y += 1;
            },
            .right => {
                if (x == map[0].len - 1) {
                    return;
                }
                x += 1;
            },
            .left => {
                if (x == 0) {
                    return;
                }
                x -= 1;
            },
        }
    }
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.ArrayList([]const u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try map.append(try copy(line));
    }
    var m: usize = 0;
    var y: usize = 0;
    while (y < map.items.len) : (y += 1) {
        try do(map.items, 0, y, .right);
        m = @max(m, seen.count());
        seen.clearAndFree();
        try do(map.items, map.items[0].len - 1, y, .left);
        m = @max(m, seen.count());
        seen.clearAndFree();
    }
    var x: usize = 0;
    while (x < map.items[0].len) : (x += 1) {
        try do(map.items, x, 0, .down);
        m = @max(m, seen.count());
        seen.clearAndFree();
        try do(map.items, x, map.items.len - 1, .up);
        m = @max(m, seen.count());
        seen.clearAndFree();
    }
    try std.io.getStdOut().writer().print("{d}\n", .{m});
}
