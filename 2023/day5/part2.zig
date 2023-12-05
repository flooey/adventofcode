const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

const Range = struct {
    dest_type: []const u8,
    dest: u64,
    src: u64,
    length: u64,
};

const ValRange = struct {
    start: u64,
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
    var seeds = std.ArrayList(ValRange).init(al);
    var curType: []const u8 = undefined;
    var nextType: []const u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len > 0) {
            if (eql(u8, line[0..6], "seeds:")) {
                var it = std.mem.split(u8, line, " ");
                _ = it.next();
                while (it.next()) |seed| {
                    var range = try al.create(ValRange);
                    range.start = try std.fmt.parseInt(u64, seed, 10);
                    range.length = try std.fmt.parseInt(u64, it.next().?, 10);
                    try seeds.append(range.*);
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
    var nextVals: std.ArrayList(ValRange) = undefined;
    while (!eql(u8, curType, "location")) {
        // try std.io.getStdOut().writer().print("{s} {d}\n", .{ curType, curVals.items.len });
        nextVals = std.ArrayList(ValRange).init(al);
        for (curVals.items) |curVal| {
            var item = curVal;
            while (item.length > 0) {
                var bestOption: Range = undefined;
                var found = false;
                for (map.get(curType).?.items) |option| {
                    nextType = option.dest_type;
                    if (option.src <= item.start and item.start < option.src + option.length) {
                        // try std.io.getStdOut().writer().print("Inside match\n", .{});
                        bestOption = option;
                        found = true;
                        break;
                    } else if (option.src > item.start) {
                        // try std.io.getStdOut().writer().print("Above match\n", .{});
                        bestOption = option;
                        found = true;
                    }
                }
                if (!found) {
                    // This didn't match anything and is bigger than everything, pass it through whole
                    try nextVals.append(item);
                    break;
                }
                nextType = bestOption.dest_type;
                if (bestOption.src <= item.start) {
                    // We found a mapping
                    if (bestOption.length - (item.start - bestOption.src) >= item.length) {
                        // We fit entirely in the mapping, map it through
                        item.start += bestOption.dest;
                        item.start -= bestOption.src;
                        try nextVals.append(item);
                        break;
                    } else {
                        var newRange = try al.create(ValRange);
                        newRange.start = item.start + bestOption.dest - bestOption.src;
                        newRange.length = bestOption.length - (item.start - bestOption.src);
                        item.length -= newRange.length;
                        item.start += newRange.length;
                        try nextVals.append(newRange.*);
                    }
                } else {
                    // We are between mappings, bestOption is the next biggest
                    if (bestOption.src - item.start >= item.length) {
                        // The whole thing fits in the gap, pass it through
                        try nextVals.append(item);
                        break;
                    } else {
                        var newRange = try al.create(ValRange);
                        newRange.start = item.start;
                        newRange.length = item.length - bestOption.src + item.start;
                        item.length -= newRange.length;
                        item.start += newRange.length;
                        try nextVals.append(newRange.*);
                    }
                }
            }
        }
        curVals = nextVals;
        curType = nextType;
    }
    var min: u64 = 100000000000;
    for (curVals.items) |curVal| {
        if (curVal.start < min) {
            min = curVal.start;
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{min});
}
