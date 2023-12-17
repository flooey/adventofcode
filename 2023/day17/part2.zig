const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

pub fn Queue(comptime Child: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            data: Child,
            next: ?*Node,
        };
        gpa: std.mem.Allocator,
        start: ?*Node,
        end: ?*Node,
        count: u32,

        pub fn init(gpa: std.mem.Allocator) This {
            return This{
                .gpa = gpa,
                .start = null,
                .end = null,
                .count = 0,
            };
        }
        pub fn enqueue(this: *This, value: Child) !void {
            const node = try this.gpa.create(Node);
            node.* = .{ .data = value, .next = null };
            if (this.end) |end| end.next = node //
            else this.start = node;
            this.end = node;
            this.count += 1;
        }
        pub fn dequeue(this: *This) ?Child {
            const start = this.start orelse return null;
            defer this.gpa.destroy(start);
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            this.count -= 1;
            return start.data;
        }
        pub fn empty(this: *This) bool {
            return this.start == null;
        }
    };
}

const Dir = enum {
    up,
    down,
    left,
    right,
    pub fn opposite(self: Dir) Dir {
        return switch (self) {
            .up => .down,
            .down => .up,
            .left => .right,
            .right => .left,
        };
    }

    pub fn nextX(self: Dir, x: u8, maxX: usize) !u8 {
        return switch (self) {
            .up => x,
            .down => x,
            .left => if (x > 0) x - 1 else error.PathNotFound,
            .right => if (x < maxX - 1) x + 1 else error.PathNotFound,
        };
    }

    pub fn nextY(self: Dir, y: u8, maxY: usize) !u8 {
        return switch (self) {
            .left => y,
            .right => y,
            .up => if (y > 0) y - 1 else error.PathNotFound,
            .down => if (y < maxY - 1) y + 1 else error.PathNotFound,
        };
    }
};
const dirVals = [_]Dir{ .up, .down, .left, .right };

const State = struct {
    x: u8,
    y: u8,
    dir: Dir,
    count: u8,
};

fn statePrio(context: void, s1: State, s2: State) std.math.Order {
    _ = context;
    _ = s1;
    _ = s2;
    return .eq;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.ArrayList([]const u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var a = try copy(line);
        var i: usize = 0;
        while (i < a.len) : (i += 1) {
            a[i] -= '0';
        }
        try map.append(a);
    }
    var state = std.AutoHashMap(State, u32).init(al);
    var queue = Queue(State).init(al);
    const start = State{ .x = 0, .y = 0, .dir = .right, .count = 0 };
    const maxX: u8 = @intCast(map.items[0].len - 1);
    const maxY: u8 = @intCast(map.items.len - 1);
    try queue.enqueue(start);
    try state.put(start, 0);
    var i: u64 = 0;
    while (!queue.empty()) {
        i += 1;
        if (i % 10000 == 0) {
            // try std.io.getStdOut().writer().print("{d} {d} {d}\n", .{ i, queue.count, state.count() });
        }
        var p = queue.dequeue().?;
        if (p.x == maxX and p.y == maxY) {
            continue;
        }
        var cur = state.get(p).?;
        for (dirVals) |dir| {
            if (dir == p.dir.opposite()) {
                continue;
            }
            if (dir == p.dir and p.count == 10) {
                continue;
            }
            if (dir != p.dir and 0 < p.count and p.count < 4) {
                continue;
            }
            var x = dir.nextX(p.x, map.items[0].len) catch continue;
            var y = dir.nextY(p.y, map.items.len) catch continue;
            var next = State{ .x = x, .y = y, .dir = dir, .count = if (dir == p.dir) p.count + 1 else 1 };
            var nextCost = cur + map.items[y][x];
            if (state.get(next)) |val| {
                if (val <= nextCost) {
                    continue;
                }
            }
            try queue.enqueue(next);
            try state.put(next, nextCost);
        }
    }
    var min: u32 = 100000000;
    for (dirVals) |dir| {
        var count: u8 = 4;
        while (count < 11) : (count += 1) {
            if (state.get(State{ .x = maxX, .y = maxY, .dir = dir, .count = count })) |val| {
                min = @min(min, val);
            }
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{min});
}
