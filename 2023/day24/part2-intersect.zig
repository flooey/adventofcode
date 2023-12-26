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

fn intersect(h1: Hail, h2: Hail) bool {
    // std.io.getStdOut().writer().print("h1: {any}\nh2: {any}\n", .{ h1, h2 }) catch unreachable;
    var cx = h1.vy * h2.vz - h1.vz * h2.vy;
    var cy = h1.vz * h2.vx - h1.vx * h2.vz;
    var cz = h1.vx * h2.vy - h1.vy * h2.vx;
    // std.io.getStdOut().writer().print("cross: {any} {any} {any}\n", .{ cx, cy, cz }) catch unreachable;
    var dot = cx * (h1.x - h2.x) + cy * (h1.y - h2.y) + cz * (h1.z - h2.z);
    // std.io.getStdOut().writer().print("dot: {any}\n", .{dot}) catch unreachable;
    if (std.math.approxEqAbs(f128, dot, 0, 0.01)) {
        return true;
    }
    return false;
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
    var i: usize = 0;
    while (i < hail.len) : (i += 1) {
        var j = i + 1;
        while (j < hail.len) : (j += 1) {
            if (intersect(hail[i], hail[j])) {
                // try std.io.getStdOut().writer().print("Yes: {d} {d}\n", .{ i, j });
                // hail[i] and hail[j] form a plane, find the plane equation
                var h1 = hail[i];
                var h2 = hail[j];
                var dx = h1.x - h2.x;
                var dy = h1.y - h2.y;
                var dz = h1.z - h2.z;
                var cx = dy * h2.vz - dz * h2.vy;
                var cy = dz * h2.vx - dx * h2.vz;
                var cz = dx * h2.vy - dy * h2.vx;
                var scalar = cx * h1.x + cy * h1.y + cz * h1.z;
                // Any other two lines intersecting the plane should give us our line
                var h3: Hail = undefined;
                var h4: Hail = undefined;
                var k: usize = 0;
                while (true) : (k += 1) {
                    if (k != i and k != j) {
                        h3 = hail[k];
                        break;
                    }
                }
                k += 1;
                while (true) : (k += 1) {
                    if (k != i and k != j) {
                        h4 = hail[k];
                        break;
                    }
                }

                var t3 = (scalar - cx * h3.x - cy * h3.y - cz * h3.z) / (cx * h3.vx + cy * h3.vy + cz * h3.vz);
                var p3x = h3.x + h3.vx * t3;
                var p3y = h3.y + h3.vy * t3;
                var p3z = h3.z + h3.vz * t3;

                var t4 = (scalar - cx * h4.x - cy * h4.y - cz * h4.z) / (cx * h4.vx + cy * h4.vy + cz * h4.vz);
                var p4x = h4.x + h4.vx * t4;
                var p4y = h4.y + h4.vy * t4;
                var p4z = h4.z + h4.vz * t4;

                // try std.io.getStdOut().writer().print("{any} {any} {any} / {any} {any} {any} / {any} {any}\n", .{ p3x, p3y, p3z, p4x, p4y, p4z, t3, t4 });

                var x = p3x - t3 * (p3x - p4x) / (t4 - t3);
                var y = p3y - t3 * (p3y - p4y) / (t4 - t3);
                var z = p3z - t3 * (p3z - p4z) / (t4 - t3);
                try std.io.getStdOut().writer().print("{any}\n", .{@round(x + y + z)});
                return;
            } else {
                // try std.io.getStdOut().writer().print("Not: {d} {d}\n", .{ i, j });
            }
        }
    }
}
