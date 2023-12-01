const std = @import("std");

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var total: i32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first: i32 = -1;
        var last: i32 = -1;
        for (line) |c| {
            if ('0' <= c and c <= '9') {
                var val = c - '0';
                if (first == -1) {
                    first = val;
                }
                last = val;
            }
        }
        total += first * 10 + last;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
