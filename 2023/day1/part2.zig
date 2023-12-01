const std = @import("std");
const eql = std.mem.eql;

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var total: i32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first: i32 = -1;
        var last: i32 = -1;
        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            var c = line[i];
            var val: i32 = -1;
            if ('0' <= c and c <= '9') {
                val = c - '0';
            }
            if (line.len - i >= 5) {
                if (eql(u8, line[i .. i + 5], "three")) {
                    val = 3;
                } else if (eql(u8, line[i .. i + 5], "seven")) {
                    val = 7;
                } else if (eql(u8, line[i .. i + 5], "eight")) {
                    val = 8;
                }
            }
            if (line.len - i >= 4) {
                if (eql(u8, line[i .. i + 4], "four")) {
                    val = 4;
                } else if (eql(u8, line[i .. i + 4], "five")) {
                    val = 5;
                } else if (eql(u8, line[i .. i + 4], "nine")) {
                    val = 9;
                }
            }
            if (line.len - i >= 3) {
                if (eql(u8, line[i .. i + 3], "one")) {
                    val = 1;
                } else if (eql(u8, line[i .. i + 3], "two")) {
                    val = 2;
                } else if (eql(u8, line[i .. i + 3], "six")) {
                    val = 6;
                }
            }
            if (val != -1) {
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
