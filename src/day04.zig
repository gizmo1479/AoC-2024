const std = @import("std");
const fs = std.fs;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Str = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const data_filepath: Str = "data/day01.txt";
// comptime const ptr -- String literal with file contents
const data = @embedFile(data_filepath);

const XmasGraph = struct {
    height: usize,
    length: usize,
    letters: List(List(u8)),

    pub fn init(text: []const u8) !XmasGraph {
        var lines = std.mem.tokenizeScalar(u8, text, '\n');
        var graph = List(List(u8)).init(gpa_allocator);
        var height: usize = 0;
        var length: usize = 0;
        while (lines.next()) |line| {
            height += 1;
            length = line.len;
            var row = List(u8).init(gpa_allocator);
            for (line) |char| {
                try row.append(char);
            }

            try graph.append(row);
        }

        return XmasGraph{
            .height = height,
            .length = length,
            .letters = graph,
        };
    }
};

// search for the characters in chars_to_find starting at row,co
pub fn searchXmas(xmasGraph: XmasGraph, row: usize, col: usize, chars_to_find: []const u8) u8 {
    if (xmasGraph.letters.items[row].items[col] == chars_to_find[0]) {
        if (chars_to_find.len == 1) return 1;
        // Technically could do this in a loop but I'm just gonna unroll it :)
        // Check Above
        var numXmas: u8 = 0;
        const nextChars = chars_to_find[1..];
        if (row > 0) {
            if (col > 0) numXmas += searchXmas(xmasGraph, row - 1, col - 1, nextChars);
            numXmas += searchXmas(xmasGraph, row - 1, col, nextChars);
            if (col + 1 < xmasGraph.length) numXmas += searchXmas(xmasGraph, row - 1, col + 1, nextChars);
        }

        // Check Same Row
        if (col > 0) numXmas += searchXmas(xmasGraph, row, col - 1, nextChars);
        if (col + 1 < xmasGraph.length) numXmas += searchXmas(xmasGraph, row, col + 1, nextChars);

        // Check Below
        if (row + 1 < xmasGraph.height) {
            if (col > 0) numXmas += searchXmas(xmasGraph, row + 1, col - 1, nextChars);
            numXmas += searchXmas(xmasGraph, row + 1, col, nextChars);
            if (col + 1 < xmasGraph.length) numXmas += searchXmas(xmasGraph, row + 1, col + 1, nextChars);
        }

        if (chars_to_find[0] == 'X') {
            std.debug.print("Row: {}, Col: {}, NumFound: {}\n", .{ row, col, numXmas });
        }
        return numXmas;
    }

    return 0;
}

pub fn solve1(content: []const u8) !u32 {
    const xmasGraph = try XmasGraph.init(content);
    var numXmas: u32 = 0;
    for (0..xmasGraph.height) |row_index| {
        for (0..xmasGraph.length) |col_index| {
            numXmas += searchXmas(xmasGraph, row_index, col_index, "XMAS");
        }
    }
    return numXmas;
}

pub fn solve2(content: []const u8) !u32 {
    _ = content;
    return 0;
}

pub fn main() !void {
    //const result = try solve1(data);
    //std.debug.print("part1 Result: {}\n", .{result});
    //const result2 = try solve2(data);
    //std.debug.print("part2 Result: {}\n", .{result2});
}

test "part1" {
    const small_content =
        \\XMAA
        \\AASA
    ;
    const small_result = try solve1(small_content);
    try std.testing.expectEqual(2, small_result);

    const medium_content =
        \\..X...
        \\.SAMX.
        \\.A..A.
        \\XMAS.S
        \\.X....
    ;
    const medium_result = try solve1(medium_content);
    try std.testing.expectEqual(10, medium_result);

    const content =
        \\....XXMAS.  4,4
        \\.SAMXMS...  4
        \\...S..A...
        \\..A.A.MS.X  6
        \\XMASAMX.MM
        \\X.....XA.A
        \\S.S.S.S.SS
        \\.A.A.A.A.A
        \\..M.M.M.MM
        \\.X.X.XMASX
    ;
    const result = try solve1(content);
    try std.testing.expectEqual(@as(u32, 18), result);
}

test "part2" {
    const content =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    const result = try solve2(content);
    try std.testing.expectEqual(@as(u32, 31), result);
}
