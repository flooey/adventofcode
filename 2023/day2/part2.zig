const std = @import("std");
const eql = std.mem.eql;

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var total: i64 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenizeAny(u8, line, " :,;");
        var lastNum: i32 = undefined;
        var green: i32 = 0;
        var blue: i32 = 0;
        var red: i32 = 0;
        while (it.next()) |x| {
            if (eql(u8, x, "green")) {
                if (lastNum > green) {
                    green = lastNum;
                }
            }
            if (eql(u8, x, "red")) {
                if (lastNum > red) {
                    red = lastNum;
                }
            }
            if (eql(u8, x, "blue")) {
                if (lastNum > blue) {
                    blue = lastNum;
                }
            }
            const parsed = std.fmt.parseInt(i32, x, 10);
            lastNum = parsed catch 0;
        }
        // try std.io.getStdOut().writer().print("{d} {d} {d}\n", .{ green, blue, red });
        total += green * blue * red;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
