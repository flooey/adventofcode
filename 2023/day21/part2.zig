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
    x: i64,
    y: i64,
};

fn mod(n: i64, d: usize) usize {
    return @intCast(@mod(n, @as(i64, @intCast(d))));
}

fn run(map: [][]const u8, start: Loc, iterations: usize, min: Loc, max: Loc) !usize {
    var locs = std.AutoHashMap(Loc, void).init(al);
    try locs.put(start, {});
    return runGo(map, &locs, iterations, min, max);
}

fn run2(map: [][]const u8, start: Loc, start2: Loc, iterations: usize, min: Loc, max: Loc) !usize {
    var locs = std.AutoHashMap(Loc, void).init(al);
    try locs.put(start, {});
    try locs.put(start2, {});
    return runGo(map, &locs, iterations, min, max);
}

fn runGo(map: [][]const u8, startLocs: *std.AutoHashMap(Loc, void), iterations: usize, min: Loc, max: Loc) !usize {
    var locs = startLocs.*;
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        var newlocs = std.AutoHashMap(Loc, void).init(al);
        var it = locs.keyIterator();
        while (it.next()) |loc| {
            if (map[mod(loc.y, map.len)][mod(loc.x + 1, map.len)] != '#') {
                if (loc.x + 1 < max.x) {
                    try newlocs.put(Loc{ .x = loc.x + 1, .y = loc.y }, {});
                }
            }
            if (map[mod(loc.y, map.len)][mod(loc.x - 1, map.len)] != '#') {
                if (min.x <= loc.x - 1) {
                    try newlocs.put(Loc{ .x = loc.x - 1, .y = loc.y }, {});
                }
            }
            if (map[mod(loc.y + 1, map.len)][mod(loc.x, map.len)] != '#') {
                if (loc.y + 1 < max.y) {
                    try newlocs.put(Loc{ .x = loc.x, .y = loc.y + 1 }, {});
                }
            }
            if (map[mod(loc.y - 1, map.len)][mod(loc.x, map.len)] != '#') {
                if (min.y <= loc.y - 1) {
                    try newlocs.put(Loc{ .x = loc.x, .y = loc.y - 1 }, {});
                }
            }
        }
        var oldlocs = locs;
        locs = newlocs;
        oldlocs.deinit();
    }
    var c = locs.count();
    locs.deinit();
    return c;
}

const STEPS = 26501365;

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.ArrayList([]const u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try map.append(try copy(line));
    }
    var x: i64 = 0;
    var y: i64 = 0;
    var iLen: i64 = @intCast(map.items.len);
    var start: Loc = undefined;
    while (y < map.items.len) : (y += 1) {
        x = 0;
        while (x < map.items[@intCast(y)].len) : (x += 1) {
            if (map.items[@intCast(y)][@intCast(x)] == 'S') {
                start = Loc{ .x = x, .y = y };
            }
        }
    }
    if (map.items.len != map.items[0].len) {
        return error.PathNotFound;
    }
    var parity1 = try run(map.items, start, map.items.len + 4, Loc{ .x = 0, .y = 0 }, Loc{ .x = iLen, .y = iLen });
    var parity2 = try run(map.items, Loc{ .x = start.x, .y = start.y + 1 }, map.items.len + 4, Loc{ .x = 0, .y = 0 }, Loc{ .x = iLen, .y = iLen });
    var stepsToCareAbout = map.items.len + (@as(usize, @intCast(STEPS - start.x - 1)) % map.items.len);
    var radius = @divExact(STEPS - stepsToCareAbout - @as(usize, @intCast(start.x)) - 1, map.items.len);

    // End bits
    var leftCount = try run(map.items, Loc{ .x = iLen - 1, .y = start.y }, stepsToCareAbout, Loc{ .x = -10000, .y = -10000 }, Loc{ .x = iLen, .y = 10000 });
    var rightCount = try run(map.items, Loc{ .x = 0, .y = start.y }, stepsToCareAbout, Loc{ .x = 0, .y = -10000 }, Loc{ .x = 10000, .y = 10000 });
    var topCount = try run(map.items, Loc{ .x = start.x, .y = iLen - 1 }, stepsToCareAbout, Loc{ .x = 0, .y = -10000 }, Loc{ .x = iLen, .y = iLen });
    var bottomCount = try run(map.items, Loc{ .x = start.x, .y = 0 }, stepsToCareAbout, Loc{ .x = 0, .y = 0 }, Loc{ .x = iLen, .y = 10000 });

    // Sideways bits
    var upLeftCount = try run2(map.items, Loc{ .x = start.x, .y = iLen - 1 }, Loc{ .x = iLen - 1, .y = start.y }, stepsToCareAbout, Loc{ .x = 0, .y = -10000 }, Loc{ .x = iLen, .y = iLen });
    var upRightCount = try run2(map.items, Loc{ .x = start.x, .y = iLen - 1 }, Loc{ .x = 0, .y = start.y }, stepsToCareAbout, Loc{ .x = 0, .y = -10000 }, Loc{ .x = iLen, .y = iLen });
    var downRightCount = try run2(map.items, Loc{ .x = start.x, .y = 0 }, Loc{ .x = 0, .y = start.y }, stepsToCareAbout, Loc{ .x = 0, .y = 0 }, Loc{ .x = iLen, .y = 10000 });
    var downLeftCount = try run2(map.items, Loc{ .x = start.x, .y = 0 }, Loc{ .x = iLen - 1, .y = start.y }, stepsToCareAbout, Loc{ .x = 0, .y = 0 }, Loc{ .x = iLen, .y = 10000 });

    var radiusFloored = @divFloor(radius, 2);
    var radiusCeiled = @divFloor(radius + 1, 2);

    // try std.io.getStdOut().writer().print("{d} {d} {d} {d}\n", .{ radius, stepsToCareAbout, parity1, parity2 });
    // try std.io.getStdOut().writer().print("{d} {d} {d} {d}\n", .{ leftCount, rightCount, topCount, bottomCount });
    // try std.io.getStdOut().writer().print("{d} {d} {d} {d}\n", .{ upLeftCount, upRightCount, downRightCount, downLeftCount });

    var total = leftCount + rightCount + topCount + bottomCount + radius * (upLeftCount + upRightCount + downRightCount + downLeftCount) + (4 * radiusFloored + 4) * radiusFloored * parity1 + 4 * radiusCeiled * radiusCeiled * parity2 + parity1;
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
