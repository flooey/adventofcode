const std = @import("std");
const eql = std.mem.eql;
const al = std.heap.page_allocator;

fn copy(s: []const u8) ![]u8 {
    var buf = try al.alloc(u8, s.len);
    std.mem.copy(u8, buf, s);
    return buf;
}

const Rule = struct {
    prop: u8,
    comp: u8,
    thresh: u32,
    dst: []const u8,
    pub fn applies(self: Rule, p: Part) bool {
        if (self.comp == ' ') {
            return true;
        }
        var val = switch (self.prop) {
            'x' => p.x,
            'm' => p.m,
            's' => p.s,
            'a' => p.a,
            else => unreachable,
        };
        switch (self.comp) {
            '<' => return val < self.thresh,
            '>' => return val > self.thresh,
            else => unreachable,
        }
    }
};

const Part = struct {
    x: u32,
    m: u32,
    a: u32,
    s: u32,
};

pub fn main() !void {
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    var workflows = std.StringHashMap([]const Rule).init(al);
    var total: usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |origline| {
        if (origline.len == 0) {
            continue;
        }
        var line = try copy(origline);
        if (line[0] != '{') {
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
        } else {
            var it = std.mem.tokenize(u8, line, "axms=,{}");
            var part = Part{
                .x = try std.fmt.parseInt(u32, it.next().?, 10),
                .m = try std.fmt.parseInt(u32, it.next().?, 10),
                .a = try std.fmt.parseInt(u32, it.next().?, 10),
                .s = try std.fmt.parseInt(u32, it.next().?, 10),
            };
            var workflow: []const u8 = "in";
            workflows: while (!eql(u8, workflow, "R") and !eql(u8, workflow, "A")) {
                for (workflows.get(workflow).?) |rule| {
                    if (rule.applies(part)) {
                        workflow = rule.dst;
                        continue :workflows;
                    }
                }
            }
            if (eql(u8, workflow, "A")) {
                total += part.x + part.m + part.a + part.s;
            }
        }
    }
    try std.io.getStdOut().writer().print("{d}\n", .{total});
}
