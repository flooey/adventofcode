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
    z: f128,
    vx: f128,
    vy: f128,
    vz: f128,
};

fn collide(h1: Hail, h2: Hail) bool {
    // std.io.getStdOut().writer().print("h1: {any}\nh2: {any}\n", .{ h1, h2 }) catch unreachable;
    var tx = (h1.x - h2.x) / (h2.vx - h1.vx);
    var ty = (h1.y - h2.y) / (h2.vy - h1.vy);
    var tz = (h1.z - h2.z) / (h2.vz - h1.vz);

    if (h1.vx == h2.vx) {
        return std.math.approxEqAbs(f128, ty, tz, 0.01);
    }
    if (h1.vy == h2.vy) {
        return std.math.approxEqAbs(f128, tx, tz, 0.01);
    }
    if (h1.vz == h2.vz) {
        return std.math.approxEqAbs(f128, tx, ty, 0.01);
    }

    return std.math.approxEqAbs(f128, tx, ty, 0.01) and std.math.approxEqAbs(f128, tx, tz, 0.01);
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
        var z = try std.fmt.parseFloat(f128, it.next().?);
        var vx = try std.fmt.parseFloat(f128, it.next().?);
        var vy = try std.fmt.parseFloat(f128, it.next().?);
        var vz = try std.fmt.parseFloat(f128, it.next().?);
        try hailIn.append(Hail{ .x = x, .y = y, .z = z, .vx = vx, .vy = vy, .vz = vz });
    }
    var hail = hailIn.items;

    const LIMIT: f128 = 300;
    var vx: f128 = -1 * LIMIT;
    while (vx <= LIMIT) : (vx += 1) {
        // const vxForPrint: f64 = @floatCast(vx);
        // try std.io.getStdOut().writer().print("{d}\n", .{vxForPrint});
        var vy: f128 = -1 * LIMIT;
        while (vy <= LIMIT) : (vy += 1) {
            var vz: f128 = -1 * LIMIT;
            zloop: while (vz <= LIMIT) : (vz += 1) {
                // Determine the plane that results if this intersects with hail[0]
                var h0 = hail[0];
                var cx = vy * h0.vz - vz * h0.vy;
                var cy = vz * h0.vx - vx * h0.vz;
                var cz = vx * h0.vy - vy * h0.vx;
                var scalar = cx * h0.x + cy * h0.y + cz * h0.z;

                // Find the implied x, y, z at t=0 of this slope from hail[1]
                var h1 = hail[1];
                var t1 = (scalar - cx * h1.x - cy * h1.y - cz * h1.z) / (cx * h1.vx + cy * h1.vy + cz * h1.vz);

                // The point that h1 intersects the plane
                var p1x = h1.x + h1.vx * t1;
                var p1y = h1.y + h1.vy * t1;
                var p1z = h1.z + h1.vz * t1;

                var x = p1x - vx * t1;
                var y = p1y - vy * t1;
                var z = p1z - vz * t1;

                var superHail = Hail{ .x = x, .y = y, .z = z, .vx = vx, .vy = vy, .vz = vz };

                var i: usize = 2;
                while (i < hail.len) : (i += 1) {
                    if (!collide(superHail, hail[i])) {
                        continue :zloop;
                    }
                }
                // try std.io.getStdOut().writer().print("{any}\n", .{t1});
                // try std.io.getStdOut().writer().print("{any}\n", .{superHail});
                const result: f64 = @floatCast(@round(x + y + z));
                try std.io.getStdOut().writer().print("{d}\n", .{result});
                return;
            }
        }
    }
}
