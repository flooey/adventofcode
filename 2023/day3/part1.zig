const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn isSymbol(x: u8) bool {
    return x != '.' and (x < '0' or '9' < x);
}

const loopies = [_]i8{ -1, 0, 1 };

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var input = std.ArrayList([]u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var buf2 = try al.alloc(u8, line.len);
        std.mem.copy(u8, buf2, line);
        try input.append(buf2);
    }
    var i: i32 = 0;
    var total: u32 = 0;
    while (i < input.items.len) : (i += 1) {
        var curVal: u32 = 0;
        var neighborFound = false;
        var j: i32 = 0;
        while (j < input.items.len) : (j += 1) {
            // try std.io.getStdOut().writer().print("{d} {d}\n", .{ i, j });
            const c = input.items[@intCast(i)][@intCast(j)];
            if ('0' <= c and c <= '9') {
                curVal *= 10;
                curVal += c - '0';
                for (loopies) |ix| {
                    for (loopies) |jx| {
                        const ii = i + ix;
                        const jj = j + jx;
                        if (ii >= 0 and jj >= 0 and ii < input.items.len and jj < input.items.len) {
                            if (isSymbol(input.items[@intCast(ii)][@intCast(jj)])) {
                                neighborFound = true;
                            }
                        }
                    }
                }
            } else {
                if (curVal > 0 and neighborFound) {
                    // try std.io.getStdOut().writer().print("{d}\n", .{curVal});
                    total += curVal;
                }
                curVal = 0;
                neighborFound = false;
            }
        }
        if (curVal > 0 and neighborFound) {
            // try std.io.getStdOut().writer().print("{d}\n", .{curVal});
            total += curVal;
        }
        curVal = 0;
        neighborFound = false;
    }
    // for (try input.toOwnedSlice()) |line| {
    //     try std.io.getStdOut().writer().print("{s}\n", .{line});
    // }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
