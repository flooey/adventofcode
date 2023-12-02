const std = @import("std");
const eql = std.mem.eql;

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var total: i32 = 0;
    var game: i32 = 1;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenizeAny(u8, line, " :,;");
        var good = true;
        var lastNum: i32 = undefined;
        while (it.next()) |x| {
            if (eql(u8, x, "green") and lastNum > 13) {
                good = false;
                break;
            }
            if (eql(u8, x, "red") and lastNum > 12) {
                good = false;
                break;
            }
            if (eql(u8, x, "blue") and lastNum > 14) {
                good = false;
                break;
            }
            const parsed = std.fmt.parseInt(i32, x, 10);
            lastNum = parsed catch 0;
        }
        if (good) {
            total += game;
        }
        game += 1;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
