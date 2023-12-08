const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
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
    }
    var cur: []const u8 = "AAA";
    var count: u32 = 0;
    while (!eql(u8, cur, "ZZZ")) {
        var dir = dirs[count % dirs.len];
        if (dir == 'L') {
            cur = map.get(cur).?.left;
        } else {
            cur = map.get(cur).?.right;
        }
        count += 1;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{count});
}
