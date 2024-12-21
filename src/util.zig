const std = @import("std");
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StringSet = std.StringHashMap(void);
const Allocator = std.mem.Allocator;

const Graph = struct {
    height: usize,
    length: usize,
    items: List(List(u8)),

    pub fn init(allocator: Allocator, data: []const u8) !Graph {
        var graph = List(List(u8)).init(allocator);
        var lines = std.mem.tokenizeScalar(u8, data, '\n');
        var numRows: usize = 0;
        var numCols: usize = 0;
        while (lines.next()) |line| {
            var row = List(u8).init(allocator);
            numCols = line.len;
            for (line) |char| {
                try row.append(char);
            }

            numRows += 1;
            try graph.append(row);
        }

        return Graph{
            .height = numRows,
            .length = numCols,
            .items = graph,
        };
    }

    pub fn get(self: *Graph, row: i64, col: i64) ?u8 {
        if (row >= 0 and row < self.height and col >= 0 and col < self.length) {
            return self.items[row][col];
        }

        return null;
    }
};

pub fn parseNums(allocator: Allocator, data: []const u8) !List(List(u32)) {
    var ret = List(List(u32)).init(allocator);
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var nums = List(u32).init(allocator);
        var currNum: u32 = 0;
        for (line) |char| {
            if (std.ascii.isDigit(char)) {
                currNum = currNum * 10 + @as(u32, char - '0');
            } else if (currNum != 0) {
                try nums.append(currNum);
                currNum = 0;
            }
        } else {
            if (currNum != 0) {
                try nums.append(currNum);
            }
        }

        try ret.append(nums);
    }

    return ret;
}

test "parseNums" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();
    const data =
        \\1 234 5
        \\4
        \\1030: 10a ,20 3
    ;
    const output = try parseNums(gpa_allocator, data);
    try std.testing.expectEqual(234, output.items[0].items[1]);
    try std.testing.expectEqual(5, output.items[0].items[2]);
    try std.testing.expectEqual(4, output.items[1].items[0]);
    try std.testing.expectEqual(1030, output.items[2].items[0]);
    try std.testing.expectEqual(10, output.items[2].items[1]);
    try std.testing.expectEqual(20, output.items[2].items[2]);
    try std.testing.expectEqual(3, output.items[2].items[3]);
}
