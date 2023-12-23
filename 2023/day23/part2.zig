const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Pos = struct {
    x: usize,
    y: usize,
};

const Link = struct {
    endX: usize,
    endY: usize,
    distance: u32,
};

fn walk(map: [][]const u8, sx: usize, sy: usize, sfromx: usize, sfromy: usize) !Link {
    var x = sx;
    var y = sy;
    var fromx = sfromx;
    var fromy = sfromy;
    var distance: u32 = 1;
    while (true) {
        if ((y == map.len - 1 and x == map[0].len - 2) or (y == 0 and x == 1)) {
            return Link{ .endX = x, .endY = y, .distance = distance };
        }
        var neighbors = std.ArrayList(Pos).init(al);
        defer neighbors.deinit();
        if (map[y - 1][x] == '.' and y - 1 != fromy) {
            try neighbors.append(Pos{ .x = x, .y = y - 1 });
        }
        if (map[y][x - 1] == '.' and x - 1 != fromx) {
            try neighbors.append(Pos{ .x = x - 1, .y = y });
        }
        if (map[y + 1][x] == '.' and y + 1 != fromy) {
            try neighbors.append(Pos{ .x = x, .y = y + 1 });
        }
        if (map[y][x + 1] == '.' and x + 1 != fromx) {
            try neighbors.append(Pos{ .x = x + 1, .y = y });
        }
        if (neighbors.items.len > 1) {
            return Link{ .endX = x, .endY = y, .distance = distance };
        }
        var neighbor = neighbors.items[0];
        fromx = x;
        fromy = y;
        x = neighbor.x;
        y = neighbor.y;
        distance += 1;
    }
}

fn makeMap(map: [][]const u8, links: *std.AutoHashMap(Pos, []Link), x: usize, y: usize) !void {
    if (links.contains(Pos{ .x = x, .y = y }) or (y == map.len - 1 and x == map[0].len - 2)) {
        return;
    }
    var theseLinks = std.ArrayList(Link).init(al);
    if (map[y - 1][x] == '.') {
        try theseLinks.append(try walk(map, x, y - 1, x, y));
    }
    if (map[y][x - 1] == '.') {
        try theseLinks.append(try walk(map, x - 1, y, x, y));
    }
    if (map[y + 1][x] == '.') {
        try theseLinks.append(try walk(map, x, y + 1, x, y));
    }
    if (map[y][x + 1] == '.') {
        try theseLinks.append(try walk(map, x + 1, y, x, y));
    }
    try links.put(Pos{ .x = x, .y = y }, theseLinks.items);
    for (theseLinks.items) |link| {
        try makeMap(map, links, link.endX, link.endY);
    }
}

fn visit(map: [][]const u8, links: *std.AutoHashMap(Pos, []Link), visited: *std.AutoHashMap(Pos, void), x: usize, y: usize, distance: u32) !u32 {
    if (y == map.len - 1 and x == map[0].len - 2) {
        return distance;
    }
    var here = Pos{ .x = x, .y = y };
    if (visited.contains(here)) {
        return 0;
    }
    try visited.put(here, {});
    var max: u32 = 0;
    for (links.get(Pos{ .x = x, .y = y }).?) |link| {
        max = @max(max, try visit(map, links, visited, link.endX, link.endY, distance + link.distance));
    }
    _ = visited.remove(here);
    return max;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var mapIn = std.ArrayList([]const u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line2 = try copy(line);
        var i: usize = 0;
        while (i < line2.len) : (i += 1) {
            if (line2[i] != '.' and line2[i] != '#') {
                line2[i] = '.';
            }
        }
        try mapIn.append(line2);
    }
    var map = mapIn.items;
    var firstLink = try walk(map, 1, 1, 1, 0);
    var links = std.AutoHashMap(Pos, []Link).init(al);
    var linkArray = [1]Link{firstLink};
    var visited = std.AutoHashMap(Pos, void).init(al);
    try links.put(Pos{ .x = 1, .y = 0 }, &linkArray);
    try makeMap(map, &links, firstLink.endX, firstLink.endY);
    try std.io.getStdOut().writer().print("{d}\n", .{try visit(map, &links, &visited, firstLink.endX, firstLink.endY, firstLink.distance)});
}
