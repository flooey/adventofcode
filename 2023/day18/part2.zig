const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn opposite(dir: u8) u8 {
    return switch (dir) {
        'D' => 'U',
        'U' => 'D',
        'R' => 'L',
        'L' => 'R',
        else => unreachable,
    };
}

const Move = struct {
    dir: u8,
    dist: u32,
};

fn adjust(moves: *std.ArrayList(Move), si: usize) i128 {
    var diff: i128 = 0;
    var i = si;
    if (moves.items[i + 2].dist < moves.items[i].dist) {
        moves.items[i].dist -= moves.items[i + 2].dist;
        _ = moves.orderedRemove(i + 2);
    } else if (moves.items[i].dist < moves.items[i + 2].dist) {
        moves.items[i + 2].dist -= moves.items[i].dist;
        _ = moves.orderedRemove(i);
    } else {
        _ = moves.orderedRemove(i + 2);
        _ = moves.orderedRemove(i);
    }
    if (i > 0) {
        i -= 1;
    }
    var end = i + 4;
    while (i < end and i < moves.items.len - 1) {
        if (moves.items[i].dir == moves.items[i + 1].dir) {
            moves.items[i].dist += moves.items[i + 1].dist;
            _ = moves.orderedRemove(i + 1);
        } else if (moves.items[i].dir == opposite(moves.items[i + 1].dir)) {
            moves.items[i].dir = if (moves.items[i].dist > moves.items[i + 1].dist) moves.items[i].dir else moves.items[i + 1].dir;
            var smaller = @min(moves.items[i].dist, moves.items[i + 1].dist);
            var bigger = @max(moves.items[i].dist, moves.items[i + 1].dist);
            diff += smaller;
            moves.items[i].dist = bigger - smaller;
            _ = moves.orderedRemove(i + 1);
        } else {
            i += 1;
        }
    }
    return diff;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var moves = std.ArrayList(Move).init(al);
    var total: i128 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, "#");
        _ = it.next();
        var cmd = it.next().?;
        var dist = try std.fmt.parseInt(u32, cmd[0..5], 16);
        var dir: u8 = switch (cmd[5]) {
            '0' => 'R',
            '1' => 'D',
            '2' => 'L',
            '3' => 'U',
            else => unreachable,
        };
        // Uncommenting this would use the part 1 inputs
        // var it = std.mem.split(u8, line, " ");
        // var dir = it.next().?[0];
        // var dist = try std.fmt.parseInt(u32, it.next().?, 10);
        try moves.append(Move{ .dir = dir, .dist = dist });
    }
    outer: while (moves.items.len > 4) {
        var i: usize = 0;
        while (i < moves.items.len - 2) : (i += 1) {
            var nextOnes = &[_]u8{ moves.items[i].dir, moves.items[i + 1].dir, moves.items[i + 2].dir };
            if (eql(u8, nextOnes, "DRU") or eql(u8, nextOnes, "LDR") or eql(u8, nextOnes, "ULD") or eql(u8, nextOnes, "RUL")) {
                var a: i128 = moves.items[i + 1].dist - 1;
                var b: i128 = @min(moves.items[i].dist, moves.items[i + 2].dist);
                total -= a * b;
                // try std.io.getStdOut().writer().print("Removing at: {d} {s}, total now {d}\n", .{ i, nextOnes, total });
                total += adjust(&moves, i);
                continue :outer;
            }
        }
        i = 0;
        while (i < moves.items.len - 2) : (i += 1) {
            var nextOnes = &[_]u8{ moves.items[i].dir, moves.items[i + 1].dir, moves.items[i + 2].dir };
            if (eql(u8, nextOnes, "URD") or eql(u8, nextOnes, "RDL") or eql(u8, nextOnes, "DLU") or eql(u8, nextOnes, "LUR")) {
                var a: i128 = moves.items[i + 1].dist + 1;
                var b: i128 = @min(moves.items[i].dist, moves.items[i + 2].dist);
                total += a * b;
                // try std.io.getStdOut().writer().print("Removing at: {d} {s}, total now {d}\n", .{ i, nextOnes, total });
                total += adjust(&moves, i);
                continue :outer;
            }
        }
        try std.io.getStdOut().writer().print("Uh oh: {d}\n", .{moves.items.len});
        return error.PathNotFound;
    }
    total += (moves.items[0].dist + 1) * (moves.items[1].dist + 1);
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
