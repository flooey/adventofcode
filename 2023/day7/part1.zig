const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Hand = struct {
    hand: []const u8,
    bid: u32,
};

fn handType(h: Hand) u8 {
    var counts = [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var i: u8 = 0;
    while (i < h.hand.len) : (i += 1) {
        counts[cardVal(h.hand[i])] += 1;
    }
    std.sort.heap(u8, &counts, {}, std.sort.desc(u8));
    if (counts[0] == 5) {
        return 7;
    }
    if (counts[0] == 4) {
        return 6;
    }
    if (counts[0] == 3 and counts[1] == 2) {
        return 5;
    }
    if (counts[0] == 3) {
        return 4;
    }
    if (counts[0] == 2 and counts[1] == 2) {
        return 3;
    }
    if (counts[0] == 2) {
        return 2;
    }
    return 1;
}

fn cardVal(c: u8) u8 {
    if ('2' <= c and c <= '9') {
        return c - '0';
    }
    if (c == 'T') {
        return 10;
    }
    if (c == 'J') {
        return 11;
    }
    if (c == 'Q') {
        return 12;
    }
    if (c == 'K') {
        return 13;
    }
    if (c == 'A') {
        return 14;
    }
    return 100;
}

fn lessThanHand(_: void, a: Hand, b: Hand) bool {
    if (handType(a) < handType(b)) {
        return true;
    } else if (handType(a) > handType(b)) {
        return false;
    } else {
        var i: u8 = 0;
        while (i < a.hand.len) : (i += 1) {
            if (cardVal(a.hand[i]) < cardVal(b.hand[i])) {
                return true;
            } else if (cardVal(a.hand[i]) > cardVal(b.hand[i])) {
                return false;
            }
        }
    }
    return false;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var hands = std.ArrayList(Hand).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.split(u8, line, " ");
        var hand = try al.create(Hand);
        hand.hand = try copy(it.next().?);
        hand.bid = try std.fmt.parseInt(u32, it.next().?, 10);
        try hands.append(hand.*);
    }
    std.sort.heap(Hand, hands.items, {}, lessThanHand);
    var total: u64 = 0;
    var i: u32 = 0;
    while (i < hands.items.len) : (i += 1) {
        total += (i + 1) * hands.items[i].bid;
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
