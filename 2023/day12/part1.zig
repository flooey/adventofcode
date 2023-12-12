const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn doTest(springs: []u8, nums: std.ArrayList(u32), i: u8) !u32 {
    if (i == springs.len) {
        var j: u8 = 0;
        var curRun: u32 = 0;
        var runs = std.ArrayList(u32).init(al);
        defer runs.deinit();
        while (j < springs.len) : (j += 1) {
            if (springs[j] == '#') {
                curRun += 1;
            } else {
                if (curRun > 0) {
                    try runs.append(curRun);
                }
                curRun = 0;
            }
        }
        if (curRun > 0) {
            try runs.append(curRun);
        }
        if (eql(u32, nums.items, runs.items)) {
            return 1;
        } else {
            return 0;
        }
    }
    if (springs[i] != '?') {
        return doTest(springs, nums, i + 1);
    }
    springs[i] = '#';
    var yes = try doTest(springs, nums, i + 1);
    springs[i] = '.';
    var no = try doTest(springs, nums, i + 1);
    springs[i] = '?';
    return yes + no;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var total: i128 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, " ");
        var springs = try copy(it.next().?);
        var nums = std.ArrayList(u32).init(al);
        var numIt = std.mem.split(u8, it.next().?, ",");
        while (numIt.next()) |n| {
            try nums.append(try std.fmt.parseInt(u32, n, 10));
        }
        total += try doTest(springs, nums, 0);
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
