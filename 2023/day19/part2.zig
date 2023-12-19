const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Range = struct {
    start: u128,
    end: u128,
};

const Chunk = struct {
    loc: []const u8,
    x: Range,
    m: Range,
    a: Range,
    s: Range,
};

const Rule = struct {
    prop: u8,
    comp: u8,
    thresh: u32,
    dst: []const u8,
};

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var workflows = std.StringHashMap([]const Rule).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |origline| {
        if (origline.len == 0) {
            break;
        }
        var line = try copy(origline);
        var it = std.mem.tokenize(u8, line, "{,}");
        var name = it.next().?;
        var rules = std.ArrayList(Rule).init(al);
        while (it.next()) |rulein| {
            if (std.mem.indexOf(u8, rulein, ":") != null) {
                var comp: u8 = if (std.mem.indexOf(u8, rulein, ">") != null) '>' else '<';
                var it2 = std.mem.splitAny(u8, rulein, ":<>");
                var prop = it2.next().?[0];
                var thresh = try std.fmt.parseInt(u32, it2.next().?, 10);
                var dst = it2.next().?;
                try rules.append(Rule{ .comp = comp, .prop = prop, .thresh = thresh, .dst = dst });
            } else {
                try rules.append(Rule{ .comp = ' ', .prop = 0, .thresh = 0, .dst = rulein });
            }
        }
        try workflows.put(name, rules.items);
    }
    var total: u128 = 0;
    var chunks = std.ArrayList(Chunk).init(al);
    try chunks.append(Chunk{ .x = Range{ .start = 1, .end = 4001 }, .m = Range{ .start = 1, .end = 4001 }, .a = Range{ .start = 1, .end = 4001 }, .s = Range{ .start = 1, .end = 4001 }, .loc = "in" });
    outer: while (chunks.items.len > 0) {
        var chunk = chunks.orderedRemove(chunks.items.len - 1);
        // try std.io.getStdOut().writer().print("{d}-{d} {d}-{d} {d}-{d} {d}-{d} {s}\n", .{ chunk.x.start, chunk.x.end, chunk.m.start, chunk.m.end, chunk.a.start, chunk.a.end, chunk.s.start, chunk.s.end, chunk.loc });
        if (eql(u8, chunk.loc, "A")) {
            total += (chunk.x.end - chunk.x.start) * (chunk.m.end - chunk.m.start) * (chunk.a.end - chunk.a.start) * (chunk.s.end - chunk.s.start);
            continue;
        } else if (eql(u8, chunk.loc, "R")) {
            continue;
        }
        for (workflows.get(chunk.loc).?) |rule| {
            if (rule.comp == ' ') {
                chunk.loc = rule.dst;
                try chunks.append(chunk);
                continue :outer;
            }
            var r = switch (rule.prop) {
                'x' => chunk.x,
                'm' => chunk.m,
                's' => chunk.s,
                'a' => chunk.a,
                else => unreachable,
            };
            if ((rule.comp == '<' and r.end <= rule.thresh) or (rule.comp == '>' and r.start > rule.thresh)) {
                // All match
                // try std.io.getStdOut().writer().print("All match to {s}\n", .{rule.dst});
                chunk.loc = rule.dst;
                try chunks.append(chunk);
                continue :outer;
            } else if ((rule.comp == '<' and r.start >= rule.thresh) or (rule.comp == '>' and r.end <= (rule.thresh - 1))) {
                // None match
                // try std.io.getStdOut().writer().print("None match to {s}\n", .{rule.dst});
                continue;
            } else {
                // Partial match
                // try std.io.getStdOut().writer().print("Partial match to {s}\n", .{rule.dst});
                var newR = r;
                if (rule.comp == '<') {
                    newR.end = rule.thresh;
                    r.start = rule.thresh;
                } else {
                    newR.start = rule.thresh + 1;
                    r.end = rule.thresh + 1;
                }
                var newChunk = chunk;
                newChunk.loc = rule.dst;
                switch (rule.prop) {
                    'x' => {
                        chunk.x = r;
                        newChunk.x = newR;
                    },
                    'm' => {
                        chunk.m = r;
                        newChunk.m = newR;
                    },
                    'a' => {
                        chunk.a = r;
                        newChunk.a = newR;
                    },
                    's' => {
                        chunk.s = r;
                        newChunk.s = newR;
                    },
                    else => unreachable,
                }
                try chunks.append(newChunk);
            }
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
