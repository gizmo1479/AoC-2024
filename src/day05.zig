const std = @import("std");
const fs = std.fs;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Str = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const data_filepath: Str = "data/day05.txt";
// comptime const ptr -- String literal with file contents
const data = @embedFile(data_filepath);

pub fn HashSet(comptime K: type) type {
    return Map(K, void);
}

const SafetyManual = struct {
    // page -> Set<numbers that MUST come after>
    pageOrdering: Map(u32, HashSet(u32)),
    updates: List(List(u32)),
    correctlyOrderedUpdates: ?List(List(u32)),
    incorrectlyOrderedUpdates: ?List(List(u32)),

    pub fn init(content: []const u8) !SafetyManual {
        var ordering = Map(u32, HashSet(u32)).init(gpa_allocator);
        var updates = List(List(u32)).init(gpa_allocator);

        var lines = std.mem.tokenizeScalar(u8, content, '\n');
        while (lines.next()) |line| {
            if (std.mem.indexOf(u8, line, "|")) |_| {
                // build ordering
                var orderNums = std.mem.tokenizeScalar(u8, line, '|');
                const numOne: u32 = try std.fmt.parseInt(u32, orderNums.next().?, 10);
                const numTwo: u32 = try std.fmt.parseInt(u32, orderNums.next().?, 10);
                if (!ordering.contains(numOne)) {
                    _ = try ordering.put(numOne, HashSet(u32).init(gpa_allocator));
                }

                try ordering.getPtr(numOne).?.put(numTwo, {});
            } else {
                // build updates
                var updateNums = std.mem.tokenizeScalar(u8, line, ',');
                var currentUpdate = List(u32).init(gpa_allocator);
                while (updateNums.next()) |num| {
                    try currentUpdate.append(try std.fmt.parseInt(u32, num, 10));
                }

                try updates.append(currentUpdate);
            }
        }

        return SafetyManual{
            .pageOrdering = ordering,
            .updates = updates,
            .correctlyOrderedUpdates = null,
            .incorrectlyOrderedUpdates = null,
        };
    }

    pub fn checkUpdates(self: *SafetyManual) !void {
        var correctUpdates = List(List(u32)).init(gpa_allocator);
        var incorrectUpdates = List(List(u32)).init(gpa_allocator);

        outer: for (self.updates.items) |update| {
            var seenPages = HashSet(u32).init(gpa_allocator);
            for (update.items) |pageNum| {
                const numsAfterOpt = self.pageOrdering.get(pageNum);
                if (numsAfterOpt) |numsAfter| {
                    var keyIter = numsAfter.keyIterator(); // nums that must come after pagenum
                    while (keyIter.next()) |key| {
                        if (seenPages.contains(key.*)) {
                            // if we have seen the number, that means it has come before
                            // pageNum, so ordering is invalid
                            try incorrectUpdates.append(update);
                            continue :outer;
                        }
                    }
                }

                _ = try seenPages.put(pageNum, {});
            }

            try correctUpdates.append(update);
        }

        self.correctlyOrderedUpdates = correctUpdates;
        self.incorrectlyOrderedUpdates = incorrectUpdates;
    }
};

pub fn solve1(content: []const u8) !u32 {
    var safetyManual = try SafetyManual.init(content);
    try safetyManual.checkUpdates();
    const correctUpdates = safetyManual.correctlyOrderedUpdates;
    var middleSum: u32 = 0;
    for (correctUpdates.?.items) |update| {
        middleSum += update.items[(update.items.len / 2)];
    }

    return middleSum;
}

pub fn sortUpdate(
    context: SafetyManual,
    lhs: u32,
    rhs: u32,
) bool {
    const numsAfterLhsOpt = context.pageOrdering.get(lhs);
    if (numsAfterLhsOpt) |numsAfterLhs| {
        if (numsAfterLhs.contains(rhs)) {
            return true; // lhs < rhs
        }
    }

    return false;
}

pub fn solve2(content: []const u8) !u32 {
    var safetyManual = try SafetyManual.init(content);
    try safetyManual.checkUpdates();
    var middleSum: u32 = 0;
    for (safetyManual.incorrectlyOrderedUpdates.?.items) |update| {
        std.mem.sort(u32, update.items, safetyManual, sortUpdate);
        middleSum += update.items[(update.items.len / 2)];
    }

    return middleSum;
}

pub fn main() !void {
    const result = try solve1(data);
    std.debug.print("part1 Result: {}\n", .{result});
    const result2 = try solve2(data);
    std.debug.print("part2 Result: {}\n", .{result2});
}

test "part1" {
    const content =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    const result = try solve1(content);
    try std.testing.expectEqual(@as(u32, 143), result);
}

test "part2" {
    const content =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    const result = try solve2(content);
    try std.testing.expectEqual(@as(u32, 123), result);
}
