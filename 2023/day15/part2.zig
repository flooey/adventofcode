const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Lens = struct {
    label: []const u8,
    power: u8,
};

fn hash(s: []const u8) u32 {
    var result: u32 = 0;
    for (s) |c| {
        result = (result + c) * 17 % 256;
    }
    return result;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [24000]u8 = undefined;
    var lens: [256]std.ArrayList(Lens) = undefined;
    var i: usize = 0;
    while (i < 256) : (i += 1) {
        lens[i] = std.ArrayList(Lens).init(al);
    }
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, ",");
        while (it.next()) |item| {
            var it2 = std.mem.tokenize(u8, item, "=-");
            var label = it2.next().?;
            var slot = hash(label);
            var maybePower = it2.next();
            if (maybePower == null) {
                i = 0;
                while (i < lens[slot].items.len) : (i += 1) {
                    if (eql(u8, lens[slot].items[i].label, label)) {
                        _ = lens[slot].orderedRemove(i);
                        break;
                    }
                }
            } else {
                var power = try std.fmt.parseInt(u8, maybePower.?, 10);
                var added = false;
                i = 0;
                while (i < lens[slot].items.len) : (i += 1) {
                    if (eql(u8, lens[slot].items[i].label, label)) {
                        lens[slot].items[i].power = power;
                        added = true;
                        break;
                    }
                }
                if (!added) {
                    try lens[slot].append(.{ .label = try copy(label), .power = power });
                }
            }
        }
    }
    i = 0;
    while (i < 256) : (i += 1) {
        var j: usize = 0;
        while (j < lens[i].items.len) : (j += 1) {
            total += (i + 1) * (j + 1) * lens[i].items[j].power;
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
