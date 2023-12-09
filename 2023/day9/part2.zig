const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var total: i128 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, " ");
        var cur = std.ArrayList(i128).init(al);
        var next = std.ArrayList(i128).init(al);
        while (it.next()) |item| {
            try cur.append(try std.fmt.parseInt(i128, item, 10));
        }
        var done = false;
        var thisone: i128 = 0;
        var numits: u8 = 0;
        while (!done) : (numits += 1) {
            done = true;
            thisone = -1 * thisone + cur.items[0];
            var i: u8 = 1;
            while (i < cur.items.len) : (i += 1) {
                try next.append(cur.items[i] - cur.items[i - 1]);
                if (next.items[next.items.len - 1] != 0) {
                    done = false;
                }
            }
            cur = next;
            next = std.ArrayList(i128).init(al);
        }
        if (numits % 2 == 0) {
            thisone *= -1;
        }
        total += thisone;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
