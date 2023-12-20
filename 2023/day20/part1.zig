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

const Pulse = struct {
    src: []const u8,
    dest: []const u8,
    val: u2,
};

const FlipFlop = struct {
    state: u2 = 0,
};

const Conjunction = struct {
    state: std.StringHashMap(u2),
};

const Module = struct {
    ff: ?FlipFlop = null,
    con: ?Conjunction = null,
    dests: std.ArrayList([]const u8),
    fn receive(self: *Module, pulse: Pulse) ?u2 {
        if (self.ff) |*ff| {
            if (pulse.val == 1) {
                return null;
            }
            self.ff.?.state = 1 - ff.state;
            return ff.state;
        } else if (self.con) |*con| {
            con.state.put(pulse.src, pulse.val) catch unreachable;
            var allOn = true;
            var it = con.state.valueIterator();
            while (it.next()) |v| {
                if (v.* == 0) {
                    allOn = false;
                    break;
                }
            }
            return if (allOn) 0 else 1;
        } else {
            return pulse.val;
        }
    }
};

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var mods = std.StringHashMap(*Module).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenize(u8, line, " ,->");
        var thisone = it.next().?;
        var module = try al.create(Module);
        module.* = Module{ .dests = std.ArrayList([]const u8).init(al) };
        if (thisone[0] == '%') {
            module.ff = FlipFlop{};
            thisone = thisone[1..thisone.len];
        } else if (thisone[0] == '&') {
            module.con = Conjunction{ .state = std.StringHashMap(u2).init(al) };
            thisone = thisone[1..thisone.len];
        }
        while (it.next()) |dest| {
            try module.dests.append(try copy(dest));
        }
        try mods.put(try copy(thisone), module);
    }
    var it = mods.iterator();
    while (it.next()) |entry| {
        for (entry.value_ptr.*.dests.items) |dest| {
            if (mods.get(dest)) |mod| {
                if (mod.*.con) |*c| {
                    try @constCast(c).state.put(entry.key_ptr.*, 0);
                }
            }
        }
    }
    var low: u128 = 0;
    var high: u128 = 0;
    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        var queue = Queue(Pulse).init(al);
        try queue.enqueue(Pulse{ .src = "", .dest = "broadcaster", .val = 0 });
        while (!queue.empty()) {
            var pulse = queue.dequeue().?;
            if (pulse.val == 0) {
                low += 1;
            } else {
                high += 1;
            }
            // try std.io.getStdOut().writer().print("{s} {s} {d}\n", .{ pulse.src, pulse.dest, pulse.val });
            var maybeReceiver = mods.get(pulse.dest);
            if (maybeReceiver) |receiver| {
                var newPulseVal = receiver.receive(pulse);
                if (newPulseVal) |val| {
                    for (receiver.dests.items) |dest| {
                        try queue.enqueue(Pulse{ .src = pulse.dest, .dest = dest, .val = val });
                    }
                }
            }
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{low * high});
}
