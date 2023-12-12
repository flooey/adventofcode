const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;
const Managed = std.math.big.int.Managed;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn sum(nums: []u8) u32 {
    var result: u32 = 0;
    for (nums) |num| {
        result += num;
    }
    return result;
}

fn fac(n: usize) u128 {
    var result: u128 = 1;
    var i: u32 = 1;
    while (i <= n) : (i += 1) {
        result *= i;
    }
    return result;
}

fn bigFac(n: usize) !Managed {
    var result = try Managed.init(al);
    try Managed.addScalar(&result, &result, 1);
    var i: u32 = 1;
    while (i <= n) : (i += 1) {
        var toMul = try Managed.init(al);
        defer toMul.deinit();
        try Managed.addScalar(&toMul, &toMul, i);
        try Managed.mul(&result, &result, &toMul);
    }
    return result;
}

const MemoKey = struct {
    block: []u8,
    nums: []u8,
};

const MemoKeyContext = struct {
    pub fn hash(self: MemoKeyContext, key: MemoKey) u64 {
        _ = self;
        var h = std.hash.Wyhash.init(1);
        h.update(key.block);
        h.update(key.nums);
        return h.final();
    }

    pub fn eql(self: MemoKeyContext, a: MemoKey, b: MemoKey) bool {
        _ = self;
        return std.mem.eql(u8, a.block, b.block) and std.mem.eql(u8, a.nums, b.nums);
    }
};

const debug = false;

var memos = std.HashMap(MemoKey, u128, MemoKeyContext, 80).init(al);

fn countOneBlock(block: []u8, nums: []u8) !u128 {
    const memoKey = .{ .block = block, .nums = nums };
    if (memos.contains(memoKey)) {
        if (debug) try std.io.getStdOut().writer().print("[memo] Count block {s} {any} = {d}\n", .{ block, nums, memos.get(memoKey).? });
        return memos.get(memoKey).?;
    }
    var s = sum(nums);
    if (s + nums.len > block.len + 1) {
        try memos.put(memoKey, 0);
        if (debug) try std.io.getStdOut().writer().print("Count block {s} {any} = {d}\n", .{ block, nums, 0 });
        return 0;
    }
    var i = std.mem.indexOf(u8, block, "#");
    if (nums.len == 0) {
        if (i == null) {
            if (debug) try std.io.getStdOut().writer().print("Count block {s} {any} = {d}\n", .{ block, nums, 1 });
            try memos.put(memoKey, 1);
            return 1;
        } else {
            if (debug) try std.io.getStdOut().writer().print("Count block {s} {any} = {d}\n", .{ block, nums, 0 });
            try memos.put(memoKey, 0);
            return 0;
        }
    }
    if (i == null) {
        var n: usize = block.len + 1 - s - nums.len;
        var m: usize = nums.len;
        var x = @divExact(fac(n + m), fac(n) * fac(m));
        if (debug) try std.io.getStdOut().writer().print("Count block {s} {any} = {d}\n", .{ block, nums, x });
        try memos.put(memoKey, x);
        return x;
    }
    var start = i.?;
    var pivot: usize = 0;
    var total: u128 = 0;
    while (pivot < nums.len) : (pivot += 1) {
        var offset: usize = 0;
        while (offset < nums[pivot]) : (offset += 1) {
            if (offset <= start and start + nums[pivot] <= block.len + offset) {
                var x: u128 = 1;
                if (start > 1 + offset) {
                    if (block[start - offset - 1] == '#') {
                        continue;
                    } else {
                        x *= try countOneBlock(block[0 .. start - offset - 1], nums[0..pivot]);
                    }
                } else if (pivot != 0) {
                    continue;
                } else if (start > offset and block[start - offset - 1] == '#') {
                    continue;
                }
                if (start + nums[pivot] + 1 < block.len + offset) {
                    if (block[start + nums[pivot] - offset] == '#') {
                        continue;
                    } else {
                        x *= try countOneBlock(block[start + nums[pivot] + 1 - offset .. block.len], nums[pivot + 1 .. nums.len]);
                    }
                } else if (pivot != nums.len - 1) {
                    continue;
                } else if (start + nums[pivot] < block.len + offset and block[start + nums[pivot] - offset] == '#') {
                    continue;
                }
                total += x;
            }
        }
    }
    if (debug) try std.io.getStdOut().writer().print("Count block {s} {any} = {d}\n", .{ block, nums, total });
    try memos.put(memoKey, total);
    return total;
}

fn count(blocks: [][]u8, nums: []u8) !u128 {
    if (nums.len == 0) {
        for (blocks) |block| {
            if (std.mem.indexOf(u8, block, "#") != null) {
                return 0;
            }
        }
        return 1;
    }
    if (blocks.len == 1) {
        var x = try countOneBlock(blocks[0], nums);
        // try std.io.getStdOut().writer().print("Count block {s} {any} = {d}\n", .{ blocks[0], nums, x });
        return x;
    }
    var total: u128 = 0;
    var i: usize = 0;
    while (i <= nums.len) : (i += 1) {
        var x = try countOneBlock(blocks[0], nums[0..i]);
        if (x == 0) {
            if (sum(nums[0..i]) + i > blocks[0].len + 1) {
                break;
            }
            continue;
        }
        total += x * try count(blocks[1..blocks.len], nums[i..nums.len]);
    }
    return total;
}

const repeats = 5;

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var total = try std.math.big.int.Managed.init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, " ");
        var origMap = it.next().?;
        var map = try al.alloc(u8, origMap.len * repeats + (repeats - 1));
        var i: usize = 0;
        while (i < repeats) : (i += 1) {
            if (i > 0) {
                map[(origMap.len + 1) * i - 1] = '?';
            }
            std.mem.copy(u8, map[(origMap.len + 1) * i .. (origMap.len + 1) * (i + 1) - 1], origMap);
        }
        var blockIt = std.mem.tokenize(u8, map, ".");
        var blocks = std.ArrayList([]u8).init(al);
        while (blockIt.next()) |block| {
            try blocks.append(try copy(block));
        }
        var origNums = it.next().?;
        var numText = try al.alloc(u8, origNums.len * repeats + (repeats - 1));
        i = 0;
        while (i < repeats) : (i += 1) {
            if (i > 0) {
                numText[(origNums.len + 1) * i - 1] = ',';
            }
            std.mem.copy(u8, numText[(origNums.len + 1) * i .. (origNums.len + 1) * (i + 1) - 1], origNums);
        }
        var nums = std.ArrayList(u8).init(al);
        var numIt = std.mem.split(u8, numText, ",");
        while (numIt.next()) |n| {
            try nums.append(try std.fmt.parseInt(u8, n, 10));
        }
        if (std.mem.indexOfAny(u8, map, "#.") == null) {
            var s = sum(nums.items);
            var n: usize = map.len + 1 - s - nums.items.len;
            var m: usize = nums.items.len;
            var facN = try bigFac(n);
            var facM = try bigFac(m);
            var facNM = try bigFac(n + m);
            var facNfacM = try Managed.init(al);
            defer facNfacM.deinit();
            try Managed.mul(&facNfacM, &facN, &facM);
            try Managed.divFloor(&facN, &facM, &facNM, &facNfacM);
            try Managed.add(&total, &total, &facN);
        } else {
            var x = try count(blocks.items, nums.items);
            // try std.io.getStdOut().writer().print("Count line {s} {any} = {d}\n", .{ line, nums.items, x });
            try Managed.addScalar(&total, &total, x);
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
