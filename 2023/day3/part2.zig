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
    var gears = std.AutoHashMap(u32, *std.ArrayList(u32)).init(al);
    while (i < input.items.len) : (i += 1) {
        var curVal: u32 = 0;
        var gear: u32 = 0;
        var j: i32 = 0;
        while (j < input.items.len) : (j += 1) {
            const c = input.items[@intCast(i)][@intCast(j)];
            if ('0' <= c and c <= '9') {
                curVal *= 10;
                curVal += c - '0';
                for (loopies) |ix| {
                    for (loopies) |jx| {
                        const ii = i + ix;
                        const jj = j + jx;
                        if (ii >= 0 and jj >= 0 and ii < input.items.len and jj < input.items.len) {
                            if (input.items[@intCast(ii)][@intCast(jj)] == '*') {
                                const new_gear: u32 = @intCast(ii * 1000 + jj);
                                if (gear != 0 and gear != new_gear) {
                                    try std.io.getStdOut().writer().print("Double gear: {d}\n", .{gear});
                                }
                                gear = new_gear;
                            }
                        }
                    }
                }
            } else {
                if (curVal > 0 and gear > 0) {
                    if (!gears.contains(gear)) {
                        const a = try al.create(std.ArrayList(u32));
                        a.* = std.ArrayList(u32).init(al);
                        try gears.put(gear, a);
                    }
                    try gears.get(gear).?.append(curVal);
                }
                curVal = 0;
                gear = 0;
            }
        }
        if (curVal > 0 and gear > 0) {
            if (!gears.contains(gear)) {
                const a = try al.create(std.ArrayList(u32));
                a.* = std.ArrayList(u32).init(al);
                try gears.put(gear, a);
            }
            try gears.get(gear).?.append(curVal);
        }
        curVal = 0;
        gear = 0;
    }
    var total: u32 = 0;
    var it = gears.iterator();
    while (it.next()) |item| {
        if (item.value_ptr.*.items.len == 2) {
            total += item.value_ptr.*.items[0] * item.value_ptr.*.items[1];
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
