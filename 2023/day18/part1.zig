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

const Pos = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.AutoHashMap(Pos, void).init(al);
    var x: i32 = 0;
    var y: i32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, " ");
        var dir = it.next().?[0];
        var amt = try std.fmt.parseInt(i32, it.next().?, 10) * 2;
        while (amt > 0) : (amt -= 1) {
            switch (dir) {
                'R' => {
                    x += 1;
                },
                'L' => {
                    x -= 1;
                },
                'U' => {
                    y -= 1;
                },
                'D' => {
                    y += 1;
                },
                else => unreachable,
            }
            try map.put(.{ .x = x, .y = y }, {});
        }
    }
    var queue = Queue(Pos).init(al);
    try queue.enqueue(.{ .x = 1, .y = 1 });
    while (!queue.empty()) {
        var here = queue.dequeue().?;
        if (!map.contains(here)) {
            try map.put(here, {});
            try queue.enqueue(.{ .x = here.x + 1, .y = here.y });
            try queue.enqueue(.{ .x = here.x - 1, .y = here.y });
            try queue.enqueue(.{ .x = here.x, .y = here.y + 1 });
            try queue.enqueue(.{ .x = here.x, .y = here.y - 1 });
        }
    }
    var total: u64 = 0;
    var iterator = map.iterator();
    while (iterator.next()) |pos| {
        if (@mod(pos.key_ptr.x, 2) == 0 and @mod(pos.key_ptr.y, 2) == 0) {
            total += 1;
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
