const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn hash(s: []const u8) u32 {
    var result: u32 = 0;
    for (s) |c| {
        result = (result + c) * 17 % 256;
    }
    return result;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [24000]u8 = undefined;
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, ",");
        while (it.next()) |item| {
            total += hash(item);
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
