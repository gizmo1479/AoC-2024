const std = @import("std");
const util = @import("util.zig");
const fs = std.fs;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Str = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const data_filepath: Str = "data/day07.txt";
// comptime const ptr -- String literal with file contents
const data = @embedFile(data_filepath);

pub fn satisfyEquation(target: u32, nums: []u32) bool {
    return false;
}
pub fn solve1(content: []const u8) !u32 {
    const allNums = try util.parseNums(gpa_allocator, content);
    var accum: u32 = 0;
    for (allNums.items) |equation| {
        if (satisfyEquation(equation.items[0], equation.items[1..])) {
            accum += equation.items[0];
        }
    }

    return accum;
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
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    ;
    const result = try solve1(content);
    try std.testing.expectEqual(3749, result);
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
