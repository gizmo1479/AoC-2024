const std = @import("std");
const fs = std.fs;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Str = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const data_filepath: Str = "data/day02.txt";
// comptime const ptr -- String literal with file contents
const data = @embedFile(data_filepath);

pub fn solve1(content: []const u8) !u32 {
    var safe_levels: u32 = 0;
    var content_iterator = std.mem.tokenizeScalar(u8, content, '\n');
    var line_num: u16 = 0;
    while (content_iterator.next()) |line| {
        line_num += 1;
        var is_increasing_opt: ?bool = null;
        var last_num_opt: ?u32 = null;
        var num_iter = std.mem.splitSequence(u8, line, " ");
        while (num_iter.next()) |num_chars| {
            const curr_num = try std.fmt.parseInt(u32, num_chars, 10);
            if (last_num_opt) |last_num| {
                // check difference
                const diff: i64 = @as(i64, curr_num) - @as(i64, last_num);
                const abs_diff: u64 = @abs(diff);
                if (abs_diff <= 0 or abs_diff > 3) {
                    break;
                }

                // check if level is decreasing/increasing
                if (is_increasing_opt) |is_increasing| {
                    if ((diff < 0 and is_increasing) or (diff > 0 and !is_increasing)) break;
                } else {
                    is_increasing_opt = diff > 0;
                }

                // this feels wrong
                if (num_iter.peek() == null) {
                    safe_levels += 1;
                }
            }

            last_num_opt = curr_num;
        }
    }
    return safe_levels;
}

const SkippedState = struct { times_skipped: u8, skipped_num: u32 };
// logic for this is to remove the current OR next level and perform safety check again
// window proble - do a sliding window
pub fn solve2(content: []const u8) !u32 {
    var safe_levels: u32 = 0;
    var content_iterator = std.mem.tokenizeScalar(u8, content, '\n');
    var line_num: u16 = 0;
    while (content_iterator.next()) |line| {
        line_num += 1;
        std.debug.print("line: {}, {s}\n", .{ line_num, line });
        var is_increasing_opt: ?bool = null;
        var last_num_opt: ?u32 = null;
        var num_iter = std.mem.splitSequence(u8, line, " ");
        var skipped = SkippedState{ .times_skipped = 0, .skipped_num = 0 };
        while (num_iter.next()) |num_chars| {
            const curr_num = try std.fmt.parseInt(u32, num_chars, 10);
            if (last_num_opt) |last_num| {
                // check difference
                const diff: i64 = @as(i64, curr_num) - @as(i64, last_num);
                const abs_diff: u64 = @abs(diff);
                if (abs_diff <= 0 or abs_diff > 3) {
                    if (skipped.times_skipped == 1) {
                        skipped.times_skipped += 1;
                    } else {
                        break;
                    }
                }

                // check if level is decreasing/increasing
                if (is_increasing_opt) |is_increasing| {
                    if ((diff < 0 and is_increasing) or (diff > 0 and !is_increasing)) {
                        removed += 1;
                        continue;
                    }
                } else {
                    is_increasing_opt = diff > 0;
                }

                if (num_iter.peek() == null and skipped.times_skipped <= 2) {
                    // this feels wrong
                    safe_levels += 1;
                }
            }

            last_num_opt = curr_num;
        }
    }
    return safe_levels;
}

pub fn main() !void {
    const result = try solve1(data);
    std.debug.print("part1 Result: {}\n", .{result});
    const result2 = try solve2(data);
    std.debug.print("part2 Result: {}\n", .{result2});
}

test "part1" {
    const content =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\11 13 16 17 19
    ;
    const result = try solve1(content);
    try std.testing.expectEqual(@as(u32, 2), result);
}

test "part2" {
    const content =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    const result = try solve2(content);
    try std.testing.expectEqual(@as(u32, 4), result);
}
