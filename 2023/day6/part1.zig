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
    var times = std.ArrayList(u32).init(al);
    var distances = std.ArrayList(u32).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (times.items.len == 0) {
            var it = std.mem.tokenize(u8, line, " ");
            _ = it.next();
            while (it.next()) |time| {
                try times.append(try std.fmt.parseInt(u32, time, 10));
            }
        } else {
            var it = std.mem.tokenize(u8, line, " ");
            _ = it.next();
            while (it.next()) |distance| {
                try distances.append(try std.fmt.parseInt(u32, distance, 10));
            }
        }
    }
    var total: u64 = 1;
    var i: u32 = 0;
    while (i < times.items.len) : (i += 1) {
        var time = times.items[i];
        var distance = distances.items[i];
        var count: u32 = 0;
        var j: u32 = 0;
        while (j < time) : (j += 1) {
            if (j * (time - j) > distance) {
                count += 1;
            }
        }
        total *= count;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
