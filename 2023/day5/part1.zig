const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

const Range = struct {
    dest_type: []const u8,
    dest: u64,
    src: u64,
    length: u64,
};

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.StringHashMap(*std.ArrayList(Range)).init(al);
    var seeds = std.ArrayList(u64).init(al);
    var curType: []const u8 = undefined;
    var nextType: []const u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 0) {
            if (eql(u8, line[0..6], "seeds:")) {
                var it = std.mem.split(u8, line, " ");
                _ = it.next();
                while (it.next()) |seed| {
                    try seeds.append(try std.fmt.parseInt(u64, seed, 10));
                }
            } else if ('0' <= line[0] and line[0] <= '9') {
                var it = std.mem.split(u8, line, " ");
                var range = try al.create(Range);
                range.dest_type = nextType;
                range.dest = try std.fmt.parseInt(u64, it.next().?, 10);
                range.src = try std.fmt.parseInt(u64, it.next().?, 10);
                range.length = try std.fmt.parseInt(u64, it.next().?, 10);
                try map.get(curType).?.append(range.*);
            } else {
                var it = std.mem.tokenize(u8, line, "- ");
                curType = try copy(it.next().?);
                _ = it.next();
                nextType = try copy(it.next().?);

                const a = try al.create(std.ArrayList(Range));
                a.* = std.ArrayList(Range).init(al);
                try map.put(curType, a);
            }
        }
    }
    curType = "seed";
    var curVals = seeds;
    var nextVals: std.ArrayList(u64) = undefined;
    while (!eql(u8, curType, "location")) {
        nextVals = std.ArrayList(u64).init(al);
        for (curVals.items) |curVal| {
            var found = false;
            for (map.get(curType).?.items) |option| {
                if (option.src <= curVal and curVal < option.src + option.length) {
                    try nextVals.append(option.dest + curVal - option.src);
                    nextType = option.dest_type;
                    found = true;
                    break;
                }
            }
            if (!found) {
                try nextVals.append(curVal);
            }
        }
        curVals = nextVals;
        curType = nextType;
    }
    var min: u64 = 100000000000;
    for (curVals.items) |curVal| {
        if (curVal < min) {
            min = curVal;
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{min});
}
