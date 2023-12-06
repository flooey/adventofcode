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
    var time: u64 = 0;
    var distance: u128 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (time == 0) {
            var it = std.mem.tokenize(u8, line, " ");
            _ = it.next();
            while (it.next()) |tstr| {
                var t = try std.fmt.parseInt(u32, tstr, 10);
                if (t < 10) {
                    time *= 10;
                } else {
                    time *= 100;
                }
                time += t;
            }
        } else {
            var it = std.mem.tokenize(u8, line, " ");
            _ = it.next();
            while (it.next()) |dstr| {
                var d = try std.fmt.parseInt(u32, dstr, 10);
                if (d < 10) {
                    distance *= 10;
                } else if (d < 100) {
                    distance *= 100;
                } else if (d < 1000) {
                    distance *= 1000;
                } else {
                    distance *= 10000;
                }
                distance += d;
            }
        }
    }
    var total: u128 = 0;
    var i: u32 = 0;
    while (i < time) : (i += 1) {
        if (i * (time - i) > distance) {
            total = time + 1 - i * 2;
            break;
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
