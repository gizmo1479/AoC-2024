const std = @import("std");
const fs = std.fs;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Str = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const data_filepath: Str = "data/day03.txt";
// comptime const ptr -- String literal with file contents
const data = @embedFile(data_filepath);

pub fn checkMulInstr(instr: []const u8) !u32 {
    // instr: mul(X,Y)
    // check min len of 8
    if (instr.len < 8) return 0;
    // instr starts with mul(
    if (!std.mem.eql(u8, instr[0..4], "mul(")) return 0;
    // ends with )
    if (instr[instr.len - 1] != ')') return 0;
    // lastly, check if inside is X,Y
    var i: usize = 4;
    var first_num: u32 = 0;
    while (i < i + 4) : (i += 1) {
        const curr_char = instr[i];
        if (curr_char == ',') {
            break;
        } else if (std.ascii.isDigit(curr_char)) {
            first_num *= 10;
            first_num += try std.fmt.parseInt(u32, instr[i .. i + 1], 10);
        } else {
            return 0;
        }

        if (i == i + 3) return 0; // X is too big/comma not found
    }

    const second_num_opt = std.fmt.parseInt(u32, instr[i + 1 .. instr.len - 1], 10);
    if (second_num_opt) |second_num| {
        return first_num * second_num;
    } else |_| {
        return 0;
    }
}

pub fn solve1(content: []const u8) !u32 {
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var final_result: u32 = 0;
    while (lines.next()) |line| {
        var i: usize = 0;
        var instr_start_opt: ?usize = null;
        var instr_end: usize = 0;
        while (i < line.len) : (i += 1) {
            const curr_char = line[i];
            switch (curr_char) {
                'm' => {
                    instr_start_opt = i;
                },
                ')' => {
                    instr_end = i;
                    if (instr_start_opt) |instr_start| {
                        final_result += try checkMulInstr(line[instr_start .. instr_end + 1]);
                        instr_start_opt = null;
                    }
                },
                else => {
                    if (instr_start_opt) |instr_start| {
                        // Longest mul is 12 characters long
                        // ex: mul(123,123)
                        if (i - instr_start > 12) instr_start_opt = null;
                    }
                },
            }
        }
    }
    return final_result;
}

pub fn solve2(content: []const u8) !u32 {
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    var final_result: u32 = 0;
    var instr_enabled = true;
    while (lines.next()) |line| {
        var i: usize = 0;
        var instr_start_opt: ?usize = null;
        var instr_end: usize = 0;
        while (i < line.len) : (i += 1) {
            const curr_char = line[i];
            switch (curr_char) {
                'm' => {
                    instr_start_opt = i;
                },
                ')' => {
                    instr_end = i;
                    if (instr_start_opt) |instr_start| {
                        if (instr_enabled) {
                            // apparently Zig doesn't yet allow capture + conditional
                            final_result += try checkMulInstr(line[instr_start .. instr_end + 1]);
                            instr_start_opt = null;
                        }
                    }
                },
                'd' => {
                    // do()
                    if (i + 4 < line.len and std.mem.eql(u8, line[i .. i + 4], "do()")) instr_enabled = true;
                    if (i + 7 < line.len and std.mem.eql(u8, line[i .. i + 7], "don't()")) instr_enabled = false;
                    instr_start_opt = null;
                },
                else => {
                    if (instr_start_opt) |instr_start| {
                        // Longest mul is 12 characters long
                        // ex: mul(123,123)
                        if (i - instr_start > 12) instr_start_opt = null;
                    }
                },
            }
        }
    }
    return final_result;
}

pub fn main() !void {
    const result = try solve1(data);
    std.debug.print("part1 Result: {}\n", .{result});
    const result2 = try solve2(data);
    std.debug.print("part2 Result: {}\n", .{result2});
}

test "part1" {
    const content =
        \\xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
    ;
    const result = try solve1(content);
    try std.testing.expectEqual(@as(u32, 161), result);
}

test "part2" {
    const content =
        \\xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    ;
    const result = try solve2(content);
    try std.testing.expectEqual(@as(u32, 48), result);
}
