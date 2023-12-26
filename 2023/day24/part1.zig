const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Hail = struct {
    x: f128,
    y: f128,
    vx: f128,
    vy: f128,
};

const LOWER = 200000000000000;
const UPPER = 400000000000000;

fn matches(h1: Hail, h2: Hail) !bool {
    var denom = h1.vx * h2.vy - h1.vy * h2.vx;
    if (denom == 0) {
        return false;
    }
    var num = h1.vx * (h1.y - h2.y) + h1.vy * (h2.x - h1.x);
    var t2 = num / denom;
    if (t2 < 0) {
        // try std.io.getStdOut().writer().print("t2 {any} out of bounds\n", .{t2});
        return false;
    }
    var t1 = (h2.x - h1.x + h2.vx * t2) / h1.vx;
    if (t1 < 0) {
        // try std.io.getStdOut().writer().print("t1 {any} out of bounds {any}\n", .{ t1, t2 });
        return false;
    }
    var xint = h1.x + h1.vx * t1;
    if (xint < LOWER or UPPER < xint) {
        // try std.io.getStdOut().writer().print("xint {any} out of bounds\n", .{xint});
        return false;
    }
    var yint = h1.y + h1.vy * t1;
    if (yint < LOWER or UPPER < yint) {
        // try std.io.getStdOut().writer().print("yint {any} out of bounds\n", .{yint});
        return false;
    }
    // try std.io.getStdOut().writer().print("Pass\n", .{});
    return true;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var hailIn = std.ArrayList(Hail).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenize(u8, line, " ,@");
        var x = try std.fmt.parseFloat(f128, it.next().?);
        var y = try std.fmt.parseFloat(f128, it.next().?);
        _ = it.next();
        var vx = try std.fmt.parseFloat(f128, it.next().?);
        var vy = try std.fmt.parseFloat(f128, it.next().?);
        try hailIn.append(Hail{ .x = x, .y = y, .vx = vx, .vy = vy });
    }
    var hail = hailIn.items;
    var i: usize = 0;
    var total: u32 = 0;
    while (i < hail.len) : (i += 1) {
        var j = i + 1;
        while (j < hail.len) : (j += 1) {
            // try std.io.getStdOut().writer().print("{d} {d}\n", .{ i, j });
            if (matches(hail[i], hail[j]) catch false) {
                total += 1;
            }
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
