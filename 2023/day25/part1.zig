const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn nextUnvisited(unvisited: std.StringHashMap(void), dist: std.StringHashMap(u32)) []const u8 {
    var min: u32 = 1000000;
    var best: *[]const u8 = undefined;
    var it = unvisited.keyIterator();
    while (it.next()) |node| {
        if (dist.contains(node.*)) {
            var val = dist.get(node.*).?;
            if (val < min) {
                min = val;
                best = node;
            }
        }
    }
    return best.*;
}

fn countVisits(g: std.StringHashMap(*std.ArrayList([]const u8)), start: []const u8) !std.StringHashMap(u32) {
    var arena = std.heap.ArenaAllocator.init(al);
    defer arena.deinit();
    var arenaAl = arena.allocator();

    var result = std.StringHashMap(u32).init(al);
    var dist = std.StringHashMap(u32).init(arenaAl);
    var prev = std.StringHashMap([]const u8).init(arenaAl);
    var unvisited = std.StringHashMap(void).init(arenaAl);
    var it = g.keyIterator();
    while (it.next()) |node| {
        try result.put(node.*, 0);
        try unvisited.put(node.*, {});
    }
    try dist.put(start, 0);
    while (unvisited.count() > 0) {
        var next = nextUnvisited(unvisited, dist);
        _ = unvisited.remove(next);
        var new = dist.get(next).? + 1;
        for (g.get(next).?.items) |neighbor| {
            if (unvisited.contains(neighbor)) {
                var old = dist.get(neighbor) orelse 1000000;
                if (new < old) {
                    try dist.put(neighbor, new);
                    try prev.put(neighbor, next);
                }
            }
        }
    }
    it = g.keyIterator();
    while (it.next()) |node| {
        var x = node.*;
        while (!eql(u8, x, start)) {
            try result.put(x, result.get(x).? + 1);
            x = prev.get(x).?;
        }
    }
    return result;
}

fn reachable(g: std.StringHashMap(*std.ArrayList([]const u8)), start: []const u8) !u32 {
    var toVisit = std.StringHashMap(void).init(al);
    defer toVisit.deinit();
    var visited = std.StringHashMap(void).init(al);
    defer visited.deinit();
    try toVisit.put(start, {});
    while (toVisit.count() > 0) {
        var keyIt = toVisit.keyIterator();
        var visit = keyIt.next().?.*;
        _ = toVisit.remove(visit);
        try visited.put(visit, {});
        for (g.get(visit).?.items) |next| {
            if (!visited.contains(next)) {
                try toVisit.put(next, {});
            }
        }
    }
    return visited.count();
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var parts = std.StringHashMap(*std.ArrayList([]const u8)).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenize(u8, line, ": ");
        var first = try copy(it.next().?);
        if (!parts.contains(first)) {
            var l = try al.create(std.ArrayList([]const u8));
            l.* = std.ArrayList([]const u8).init(al);
            try parts.put(first, l);
        }
        while (it.next()) |nx| {
            var n = try copy(nx);
            if (!parts.contains(n)) {
                var l = try al.create(std.ArrayList([]const u8));
                l.* = std.ArrayList([]const u8).init(al);
                try parts.put(n, l);
            }
            try parts.get(first).?.append(n);
            try parts.get(n).?.append(first);
        }
    }
    var visitCounts = std.StringHashMap(u32).init(al);
    var nodesSeen: usize = 0;
    var it = parts.keyIterator();
    while (it.next()) |node| : (nodesSeen += 1) {
        // try std.io.getStdOut().writer().print("{s}\n", .{node.*});
        var newCounts = try countVisits(parts, node.*);
        var cIt = newCounts.iterator();
        while (cIt.next()) |entry| {
            if (visitCounts.contains(entry.key_ptr.*)) {
                try visitCounts.put(entry.key_ptr.*, visitCounts.get(entry.key_ptr.*).? + entry.value_ptr.*);
            } else {
                try visitCounts.put(entry.key_ptr.*, entry.value_ptr.*);
            }
        }
        if (nodesSeen == 40) {
            break;
        }
    }
    var bests = [6][]const u8{ "", "", "", "", "", "" };
    var bestVals = [6]u32{ 0, 0, 0, 0, 0, 0 };
    var cIt = visitCounts.iterator();
    while (cIt.next()) |entry| {
        // try std.io.getStdOut().writer().print("{s} {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
        var i: usize = 0;
        var sub: usize = 20;
        while (i < 6) : (i += 1) {
            if (entry.value_ptr.* > bestVals[i]) {
                if (sub == 20 or bestVals[i] < bestVals[sub]) {
                    sub = i;
                }
            }
        }
        if (sub != 20) {
            bestVals[sub] = entry.value_ptr.*;
            bests[sub] = entry.key_ptr.*;
        }
    }
    var i: usize = 0;
    while (i < 6) : (i += 1) {
        var j = i + 1;
        var toRemove: usize = 255;
        while (j < 6) : (j += 1) {
            for (parts.get(bests[i]).?.items) |neighbor| {
                if (eql(u8, neighbor, bests[j])) {
                    toRemove = j;
                }
            }
        }
        if (toRemove < 255) {
            var k: usize = 0;
            var n = parts.get(bests[i]).?;
            // try std.io.getStdOut().writer().print("Removing {s}-{s}\n", .{ bests[i], bests[toRemove] });
            while (k < n.items.len) : (k += 1) {
                if (eql(u8, n.items[k], bests[toRemove])) {
                    _ = n.orderedRemove(k);
                    break;
                }
            }
            k = 0;
            n = parts.get(bests[toRemove]).?;
            while (k < n.items.len) : (k += 1) {
                if (eql(u8, n.items[k], bests[i])) {
                    _ = n.orderedRemove(k);
                    break;
                }
            }
        }
        // try std.io.getStdOut().writer().print("{s} {d}\n", .{ bests[i], bestVals[i] });
    }
    var a: u32 = 0;
    it = parts.keyIterator();
    while (it.next()) |node| {
        var b = try reachable(parts, node.*);
        if (a == 0) {
            a = b;
        } else if (a != b) {
            try std.io.getStdOut().writer().print("{d}\n", .{a * b});
            break;
        }
    }
}
