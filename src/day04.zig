const std = @import("std");
const fs = std.fs;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Str = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const data_filepath: Str = "data/day04.txt";
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

const Direction = enum { up, down, left, right, upLeft, upRight, downLeft, downRight };

// search for the characters in chars_to_find starting at row,co
pub fn searchXmas(xmasGraph: XmasGraph, row: i64, col: i64, chars_to_find: []const u8, dir: Direction) u8 {
    if (row < 0 or col < 0 or row >= xmasGraph.height or col >= xmasGraph.length) return 0;
    if (xmasGraph.letters.items[@intCast(row)].items[@intCast(col)] == chars_to_find[0]) {
        if (chars_to_find.len == 1) return 1;

        const nextChars = chars_to_find[1..];
        switch (dir) {
            .up => {
                return searchXmas(xmasGraph, row - 1, col, nextChars, dir);
            },
            .upLeft => {
                return searchXmas(xmasGraph, row - 1, col - 1, nextChars, dir);
            },
            .upRight => {
                return searchXmas(xmasGraph, row - 1, col + 1, nextChars, dir);
            },
            .down => {
                return searchXmas(xmasGraph, row + 1, col, nextChars, dir);
            },
            .downLeft => {
                return searchXmas(xmasGraph, row + 1, col - 1, nextChars, dir);
            },
            .downRight => {
                return searchXmas(xmasGraph, row + 1, col + 1, nextChars, dir);
            },
            .left => {
                return searchXmas(xmasGraph, row, col - 1, nextChars, dir);
            },
            .right => {
                return searchXmas(xmasGraph, row, col + 1, nextChars, dir);
            },
        }
    }

    return 0;
}

pub fn solve1(content: []const u8) !u32 {
    const xmasGraph = try XmasGraph.init(content);
    std.debug.print("Made graph: height: {}, len: {}\n", .{ xmasGraph.height, xmasGraph.length });
    var numXmas: u32 = 0;
    for (0..xmasGraph.height) |row_index| {
        for (0..xmasGraph.length) |col_index| {
            const row_index_signed: i64 = @intCast(row_index);
            const col_index_signed: i64 = @intCast(col_index);
            numXmas += searchXmas(xmasGraph, row_index_signed, col_index_signed, "XMAS", Direction.up);
            numXmas += searchXmas(xmasGraph, row_index_signed, col_index_signed, "XMAS", Direction.upRight);
            numXmas += searchXmas(xmasGraph, row_index_signed, col_index_signed, "XMAS", Direction.upLeft);
            numXmas += searchXmas(xmasGraph, row_index_signed, col_index_signed, "XMAS", Direction.left);
            numXmas += searchXmas(xmasGraph, row_index_signed, col_index_signed, "XMAS", Direction.right);
            numXmas += searchXmas(xmasGraph, row_index_signed, col_index_signed, "XMAS", Direction.down);
            numXmas += searchXmas(xmasGraph, row_index_signed, col_index_signed, "XMAS", Direction.downLeft);
            numXmas += searchXmas(xmasGraph, row_index_signed, col_index_signed, "XMAS", Direction.downRight);
        }
    }
    return numXmas;
}

pub fn solve2(content: []const u8) !u32 {
    const xmasGraph = try XmasGraph.init(content);
    var numXmas: u32 = 0;
    // can't make 3x3 square until 1,1
    var r: usize = 1;
    while (r < xmasGraph.height - 1) : (r += 1) {
        var c: usize = 1;
        while (c < xmasGraph.length - 1) : (c += 1) {
            if (xmasGraph.letters.items[r].items[c] == 'A') {
                // check 4 corners for MAS
                var numMas: u32 = 0;
                numMas += searchXmas(xmasGraph, @intCast(r - 1), @intCast(c - 1), "MAS", Direction.downRight);
                numMas += searchXmas(xmasGraph, @intCast(r - 1), @intCast(c + 1), "MAS", Direction.downLeft);
                numMas += searchXmas(xmasGraph, @intCast(r + 1), @intCast(c - 1), "MAS", Direction.upRight);
                numMas += searchXmas(xmasGraph, @intCast(r + 1), @intCast(c + 1), "MAS", Direction.upLeft);
                if (numMas == 2) {
                    numXmas += 1;
                }
            }
        }
    }

    return numXmas;
}

pub fn main() !void {
    const result = try solve1(data);
    std.debug.print("part1 Result: {}\n", .{result});
    const result2 = try solve2(data);
    std.debug.print("part2 Result: {}\n", .{result2});
}

test "part1" {
    const small_content =
        \\XMAA
        \\AASA
    ;
    const small_result = try solve1(small_content);
    try std.testing.expectEqual(0, small_result);

    const medium_content =
        \\..X...
        \\.SAMX.
        \\.A..A.
        \\XMAS.S
        \\.X....
    ;
    const medium_result = try solve1(medium_content);
    try std.testing.expectEqual(4, medium_result);

    const content =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;
    const result = try solve1(content);
    try std.testing.expectEqual(@as(u32, 18), result);
}

test "part2" {
    const small_content =
        \\M.S
        \\.A.
        \\M.S
    ;
    const small_result = try solve2(small_content);
    try std.testing.expectEqual(1, small_result);

    const medium_content =
        \\M.S.S.S.S.M
        \\.A...A...A.
        \\M.S.M.M.S.M
    ;
    const medium_result = try solve2(medium_content);
    try std.testing.expectEqual(3, medium_result);

    const content =
        \\.M.S......
        \\..A..MSMS.
        \\.M.S.MAA..
        \\..A.ASMSM.
        \\.M.S.M....
        \\..........
        \\S.S.S.S.S.
        \\.A.A.A.A..
        \\M.M.M.M.M.
        \\..........
    ;
    const result = try solve2(content);
    try std.testing.expectEqual(@as(u32, 9), result);
}
