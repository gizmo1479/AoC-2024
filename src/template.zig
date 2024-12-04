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

pub fn solve1(content: []const u8) !u32 {
    _ = content;
    return 0;
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
    const content =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
        \\1212   1222
    ;
    const result = try solve1(content);
    try std.testing.expectEqual(@as(u32, 21), result);
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
