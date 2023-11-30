const std = @import("std");

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var cur: i32 = 0;
    var max: i32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.eql(u8, line, "")) {
            if (cur > max) {
                max = cur;
            }
            cur = 0;
        } else {
            cur += try std.fmt.parseInt(i32, line, 10);
        }
    }
    if (cur > max) {
        max = cur;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{max});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
