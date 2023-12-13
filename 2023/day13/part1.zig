const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn val(map: [][]u8) !usize {
    var i: usize = 1;
    horiz: while (i < map.len) : (i += 1) {
        var j = i - 1;
        while (0 <= j and i + i - j - 1 < map.len) : (j -= 1) {
            var k: usize = 0;
            while (k < map[j].len) : (k += 1) {
                if (map[j][k] != map[i + i - j - 1][k]) {
                    continue :horiz;
                }
            }
            if (j == 0) {
                break;
            }
        }
        return i * 100;
    }
    i = 1;
    vert: while (i < map[0].len) : (i += 1) {
        var j = i - 1;
        while (0 <= j and i + i - j - 1 < map[0].len) : (j -= 1) {
            var k: usize = 0;
            while (k < map.len) : (k += 1) {
                if (map[k][j] != map[k][i + i - j - 1]) {
                    continue :vert;
                }
            }
            if (j == 0) {
                break;
            }
        }
        return i;
    }
    return error.PathNotFound;
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var mapList = std.ArrayList([]u8).init(al);
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            total += try val(mapList.items);
            mapList.clearAndFree();
        } else {
            try mapList.append(try copy(line));
        }
    }
    if (mapList.items.len > 0) {
        total += try val(mapList.items);
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
