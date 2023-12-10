const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

const Dir = enum { up, down, left, right };

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

fn find(map: [][]u8, sy: u32, sx: u32, sdir: Dir, mark: bool) !i32 {
    var y = sy;
    var x = sx;
    var dir = sdir;
    var count: i32 = 0;
    while (true) {
        if (dir == .left) {
            if (x == 0) {
                return error.PathNotFound;
            }
            x -= 1;
        } else if (dir == .right) {
            if (x >= map[y].len - 1) {
                return error.PathNotFound;
            }
            x += 1;
        } else if (dir == .up) {
            if (y == 0) {
                return error.PathNotFound;
            }
            y -= 1;
        } else {
            if (y >= map.len - 1) {
                return error.PathNotFound;
            }
            y += 1;
        }
        count += 1;
        if (map[y][x] == 'S') {
            if (mark) {
                if ((dir == .up and sdir == .down) or (dir == .down and sdir == .up)) {
                    map[y][x] = 'P';
                } else if (dir == .up or sdir == .up) {
                    map[y][x] = 'U';
                } else if (dir == .down or sdir == .down) {
                    map[y][x] = 'D';
                } else {
                    map[y][x] = 'R';
                }
            }
            return @divFloor(count, 2);
        }
        switch (map[y][x]) {
            '|' => {
                if (dir != .up and dir != .down) {
                    return error.PathNotFound;
                }
            },
            '-' => {
                if (dir != .left and dir != .right) {
                    return error.PathNotFound;
                }
            },
            'L' => {
                if (dir == .left) {
                    dir = .up;
                } else if (dir == .down) {
                    dir = .right;
                } else {
                    return error.PathNotFound;
                }
            },
            'J' => {
                if (dir == .right) {
                    dir = .up;
                } else if (dir == .down) {
                    dir = .left;
                } else {
                    return error.PathNotFound;
                }
            },
            '7' => {
                if (dir == .right) {
                    dir = .down;
                } else if (dir == .up) {
                    dir = .left;
                } else {
                    return error.PathNotFound;
                }
            },
            'F' => {
                if (dir == .left) {
                    dir = .down;
                } else if (dir == .up) {
                    dir = .right;
                } else {
                    return error.PathNotFound;
                }
            },
            else => {
                return error.PathNotFound;
            },
        }
        if (mark) {
            switch (map[y][x]) {
                '|' => {
                    map[y][x] = 'P';
                },
                '-' => {
                    map[y][x] = 'R';
                },
                'L' => {
                    map[y][x] = 'U';
                },
                'J' => {
                    map[y][x] = 'U';
                },
                '7' => {
                    map[y][x] = 'D';
                },
                'F' => {
                    map[y][x] = 'D';
                },
                else => {},
            }
        }
    }
}

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var map = std.ArrayList([]u8).init(al);
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try map.append(try copy(line));
    }
    var sy: u32 = 0;
    var sx: u32 = 0;
    outer: while (sy < map.items.len) : (sy += 1) {
        sx = 0;
        while (sx < map.items[sy].len) : (sx += 1) {
            if (map.items[sy][sx] == 'S') {
                break :outer;
            }
        }
    }
    inline for (@typeInfo(Dir).Enum.fields) |sdir| {
        var result = find(map.items, sy, sx, @as(Dir, @enumFromInt(sdir.value)), false);
        var len = result catch -1;
        if (len > -1) {
            _ = try find(map.items, sy, sx, @as(Dir, @enumFromInt(sdir.value)), true);
            var count: u32 = 0;
            var parity: u32 = 0;
            var x: u32 = 0;
            var y: u32 = 0;
            while (y < map.items.len) : (y += 1) {
                x = 0;
                parity = 0;
                var lastTurn: u8 = ' ';
                while (x < map.items[y].len) : (x += 1) {
                    switch (map.items[y][x]) {
                        'P' => {
                            parity += 1;
                            lastTurn = ' ';
                        },
                        'R' => {},
                        'U' => {
                            if (lastTurn == 'U') {
                                lastTurn = ' ';
                            } else if (lastTurn == 'D') {
                                lastTurn = ' ';
                                parity += 1;
                            } else {
                                lastTurn = 'U';
                            }
                        },
                        'D' => {
                            if (lastTurn == 'D') {
                                lastTurn = ' ';
                            } else if (lastTurn == 'U') {
                                lastTurn = ' ';
                                parity += 1;
                            } else {
                                lastTurn = 'D';
                            }
                        },
                        else => {
                            if (parity % 2 == 1) {
                                // try std.io.getStdOut().writer().print("{d} {d}\n", .{ x, y });
                                count += 1;
                            }
                        },
                    }
                }
            }
            try std.io.getStdOut().writer().print("{d}\n", .{count});
            break;
        }
    }
}
