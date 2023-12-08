const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn lcm(a: u64, b: u64) u64 {
    return a * b / std.math.gcd(a, b);
}

const Node = struct {
    left: []u8,
    right: []u8,
};

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.StringHashMap(*Node).init(al);
    var dirs = try copy(try in_stream.readUntilDelimiter(&buf, '\n'));
    var starts = std.ArrayList([]const u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            continue;
        }
        var it = std.mem.tokenize(u8, line, " =(,)");
        var node = try al.create(Node);
        var dest = try copy(it.next().?);
        node.left = try copy(it.next().?);
        node.right = try copy(it.next().?);
        try map.put(dest, node);
        if (dest[2] == 'A') {
            try starts.append(dest);
        }
    }
    var counts = std.ArrayList(u32).init(al);
    // incs == counts for me, makes life easier
    // var incs = std.ArrayList(u32).init(al);
    for (starts.items) |start| {
        var cur = start;
        var count: u32 = 0;
        while (cur[2] != 'Z') {
            var dir = dirs[count % dirs.len];
            if (dir == 'L') {
                cur = map.get(cur).?.left;
            } else {
                cur = map.get(cur).?.right;
            }
            count += 1;
        }
        try counts.append(count);
        // var count2 = count;
        // while (cur[2] != 'Z' or count2 == count) {
        //     var dir = dirs[count2 % dirs.len];
        //     if (dir == 'L') {
        //         cur = map.get(cur).?.left;
        //     } else {
        //         cur = map.get(cur).?.right;
        //     }
        //     count2 += 1;
        // }
        // try incs.append(count2 - count);
    }
    // for (counts.items) |item| {
    //     try std.io.getStdOut().writer().print("{d} ", .{item});
    // }
    // try std.io.getStdOut().writer().print("\n", .{});
    // for (incs.items) |item| {
    //     try std.io.getStdOut().writer().print("{d} ", .{item});
    // }
    // try std.io.getStdOut().writer().print("\n", .{});

    var result: u64 = 0;
    for (counts.items) |item| {
        if (result == 0) {
            result = item;
        } else {
            result = lcm(result, item);
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{result});
}
