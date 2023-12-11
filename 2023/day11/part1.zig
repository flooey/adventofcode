const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

const Galaxy = struct {
    x: i32,
    y: i32,
};

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var galaxies = std.ArrayList(*Galaxy).init(al);
    var y: usize = 0;
    var x: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (y += 1) {
        x = 0;
        while (x < line.len) : (x += 1) {
            if (line[x] == '#') {
                var g = try al.create(Galaxy);
                g.x = @intCast(x);
                g.y = @intCast(y);
                try galaxies.append(g);
            }
        }
    }
    x = 0;
    outer: while (x < 1000) : (x += 1) {
        for (galaxies.items) |g| {
            if (g.x == x) {
                continue :outer;
            }
        }
        for (galaxies.items) |g| {
            if (g.x > x) {
                g.x += 1;
            }
        }
        x += 1;
    }
    y = 0;
    outer: while (y < 1000) : (y += 1) {
        for (galaxies.items) |g| {
            if (g.y == y) {
                continue :outer;
            }
        }
        for (galaxies.items) |g| {
            if (g.y > y) {
                g.y += 1;
            }
        }
        y += 1;
    }
    var total: u128 = 0;
    var i: usize = 0;
    while (i < galaxies.items.len) : (i += 1) {
        var j: usize = i + 1;
        while (j < galaxies.items.len) : (j += 1) {
            total += @intCast(try std.math.absInt(galaxies.items[i].x - galaxies.items[j].x) + try std.math.absInt(galaxies.items[i].y - galaxies.items[j].y));
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
