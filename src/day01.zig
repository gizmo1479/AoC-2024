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
    var left = List(i32).init(gpa_allocator);
    var right = List(i32).init(gpa_allocator);
    var content_iter = std.mem.tokenize(u8, content, "\n");
    while (content_iter.next()) |line| {
        var line_iter = std.mem.splitSequence(u8, line, "   ");
        try left.append(try std.fmt.parseInt(i32, line_iter.next().?, 10));
        try right.append(try std.fmt.parseInt(i32, line_iter.next().?, 10));
    }

    const left_arr = try left.toOwnedSlice();
    const right_arr = try right.toOwnedSlice();
    std.mem.sort(i32, left_arr, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right_arr, {}, comptime std.sort.asc(i32));
    var total_diff: u32 = 0;
    for (left_arr, right_arr) |left_min, right_min| {
        total_diff += @abs(@as(i32, left_min) - @as(i32, right_min));
    }

    return total_diff;
}

pub fn solve2(content: []const u8) !u32 {
    var left = List(i32).init(gpa_allocator);
    var right = List(i32).init(gpa_allocator);
    var content_iter = std.mem.tokenize(u8, content, "\n");
    while (content_iter.next()) |line| {
        var line_iter = std.mem.splitSequence(u8, line, "   ");
        try left.append(try std.fmt.parseInt(i32, line_iter.next().?, 10));
        try right.append(try std.fmt.parseInt(i32, line_iter.next().?, 10));
    }

    const left_arr = try left.toOwnedSlice();
    const right_arr = try right.toOwnedSlice();
    var num_to_similarity = Map(i32, u32).init(gpa_allocator);
    var total_similarity: u32 = 0;
    for (left_arr) |num| {
        const similarity_opt = num_to_similarity.get(num);
        if (similarity_opt) |similarity| {
            total_similarity += similarity;
        } else {
            const num_arr = [1]i32{num};
            const times_appeared: i32 = @intCast(std.mem.count(i32, right_arr, &num_arr));
            const similarity: i32 = num * times_appeared;
            try num_to_similarity.put(num, @intCast(similarity));
            total_similarity += @intCast(similarity);
        }
    }

    return total_similarity;
}

pub fn main() !void {
    const result = try solve1(data);
    std.debug.print("part1 Result: {}\n", .{result});
    const result2 = try solve2(data);
    std.debug.print("part2 Result: {}\n", .{result2});
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
