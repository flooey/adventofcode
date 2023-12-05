const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var cards = std.ArrayList(u128).init(al);
    var i: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| : (i += 1) {
        var it = std.mem.split(u8, line, ": ");
        _ = it.next();
        if (it.next()) |body| {
            if (i >= cards.items.len) {
                try cards.append(1);
            }
            var it2 = std.mem.split(u8, body, " | ");
            var winners = std.AutoHashMap(u32, void).init(al);
            if (it2.next()) |winning| {
                var it3 = std.mem.tokenizeAny(u8, winning, " ");
                while (it3.next()) |w| {
                    try winners.put(try std.fmt.parseInt(u32, w, 10), {});
                }
            }
            var numMatches: u128 = 0;
            if (it2.next()) |matches| {
                var it3 = std.mem.tokenizeAny(u8, matches, " ");
                while (it3.next()) |m| {
                    const val = try std.fmt.parseInt(u32, m, 10);
                    if (winners.contains(val)) {
                        numMatches += 1;
                    }
                }
            }
            try std.io.getStdOut().writer().print("{d}: {d}\n", .{ i, numMatches });
            var j: u32 = 1;
            while (j <= numMatches) : (j += 1) {
                if (i + j >= cards.items.len) {
                    try cards.append(1);
                }
                cards.items[i + j] += cards.items[i];
            }
        }
    }
    var total: u128 = 0;
    for (cards.items) |x| {
        total += x;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
