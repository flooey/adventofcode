const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Brick = struct {
    x1: u32,
    x2: u32,
    y1: u32,
    y2: u32,
    z1: u32,
    z2: u32,
};

fn brickLess(_: void, a: Brick, b: Brick) bool {
    return a.z1 < b.z1;
}

fn intersects(a1: u32, a2: u32, b1: u32, b2: u32) bool {
    return a1 <= b2 and b1 <= a2;
}

fn supports(b1: Brick, b2: Brick) bool {
    return b1.z2 + 1 == b2.z1 and intersects(b1.x1, b1.x2, b2.x1, b2.x2) and intersects(b1.y1, b1.y2, b2.y1, b2.y2);
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var bricksIn = std.ArrayList(Brick).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenize(u8, line, ",~");
        var x1 = try std.fmt.parseInt(u32, it.next().?, 10);
        var y1 = try std.fmt.parseInt(u32, it.next().?, 10);
        var z1 = try std.fmt.parseInt(u32, it.next().?, 10);
        var x2 = try std.fmt.parseInt(u32, it.next().?, 10);
        var y2 = try std.fmt.parseInt(u32, it.next().?, 10);
        var z2 = try std.fmt.parseInt(u32, it.next().?, 10);
        try bricksIn.append(Brick{ .x1 = x1, .x2 = x2, .y1 = y1, .y2 = y2, .z1 = z1, .z2 = z2 });
    }
    var bricks = bricksIn.items;
    std.mem.sort(Brick, bricks, {}, brickLess);
    var supportedBy = try al.alloc(u32, bricks.len);
    var i: usize = 0;
    while (i < bricks.len) : (i += 1) {
        var j: usize = 0;
        var minZ: u32 = 0;
        while (j < i) : (j += 1) {
            if (intersects(bricks[i].x1, bricks[i].x2, bricks[j].x1, bricks[j].x2) and intersects(bricks[i].y1, bricks[i].y2, bricks[j].y1, bricks[j].y2)) {
                minZ = @max(minZ, bricks[j].z2);
            }
        }
        var newZ = minZ + 1;
        var diff = bricks[i].z1 - newZ;
        bricks[i].z1 -= diff;
        bricks[i].z2 -= diff;
        supportedBy[i] = 0;
        j = 0;
        while (j < i) : (j += 1) {
            if (supports(bricks[j], bricks[i])) {
                supportedBy[i] += 1;
            }
        }
    }
    i = 0;
    var total: u32 = 0;
    outer: while (i < bricks.len) : (i += 1) {
        var j: usize = i;
        while (j < bricks.len) : (j += 1) {
            if (supportedBy[j] == 1 and supports(bricks[i], bricks[j])) {
                continue :outer;
            }
        }
        total += 1;
    }
    // i = 0;
    // while (i < bricks.len) : (i += 1) {
    //     var brick = bricks[i];
    //     try std.io.getStdOut().writer().print("{d}-{d} {d}-{d} {d}-{d} ({d})\n", .{ brick.x1, brick.x2, brick.y1, brick.y2, brick.z1, brick.z2, supportedBy[i] });
    // }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
