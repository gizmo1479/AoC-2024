const std = @import("std");
const fs = std.fs;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const Str = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const data_filepath: Str = "data/day06.txt";
// comptime const ptr -- String literal with file contents
const data = @embedFile(data_filepath);

pub fn HashSet(comptime K: type) type {
    return Map(K, void);
}

const Tuple = std.meta.Tuple;
const Coords = struct { x: i64, y: i64, orientation: u8 };

const AreaMap = struct {
    // page -> Set<numbers that MUST come after>
    graph: List(List(u8)),
    height: u32,
    length: u32,
    guardLocation: Coords,

    pub fn init(content: []const u8) !AreaMap {
        var graph = List(List(u8)).init(gpa_allocator);

        var lines = std.mem.tokenizeScalar(u8, content, '\n');
        var numRows: u32 = 0;
        var colLen: u32 = 0;
        var guardLoc = Coords{ .x = 0, .y = 0, .orientation = '^' };
        while (lines.next()) |line| {
            var row = List(u8).init(gpa_allocator);
            var numCols: u32 = 0;
            for (line) |char| {
                if (char == '>' or char == '<' or char == '^' or char == 'V') {
                    std.debug.print("SETTING GUARD LOC {}\n", .{char});
                    guardLoc = Coords{ .y = numRows, .x = numCols, .orientation = char };
                }

                try row.append(char);
                numCols += 1;
            }

            numRows += 1;
            colLen = numCols; // redundant :(
            try graph.append(row);
        }

        return AreaMap{
            .graph = graph,
            .guardLocation = guardLoc,
            .height = numRows,
            .length = colLen,
        };
    }

    fn getChar(self: *AreaMap, coords: Coords) u8 {
        std.debug.print("Coords: x,y - {},{}", .{ coords.x, coords.y });
        return self.graph.items[@intCast(coords.y)].items[@intCast(coords.x)];
    }

    fn changeCoord(self: *AreaMap, coords: Coords, newVal: u8) void {
        self.graph.items[@intCast(coords.y)].items[@intCast(coords.x)] = newVal;
    }

    fn isInBounds(self: *AreaMap, coords: Coords) bool {
        return (coords.x >= 0 and coords.y >= 0 and coords.x < self.length and coords.y < self.height);
    }

    pub fn moveGuard(self: *AreaMap) void {
        const guardOrientation = self.getChar(self.guardLocation);
        std.debug.print("GUARD LOC {}\n", .{guardOrientation});
        const nextLocation = switch (guardOrientation) {
            '^' => blk: {
                const potentialCoords = Coords{ .x = self.guardLocation.x, .y = self.guardLocation.y - 1, .orientation = self.guardLocation.orientation };
                if (self.isInBounds(potentialCoords) and self.getChar(potentialCoords) == '#') {
                    // rotate 90* and try to move again
                    self.guardLocation.orientation = '>';
                    self.moveGuard();
                    return;
                }
                break :blk potentialCoords;
            },
            '<' => blk: {
                const potentialCoords = Coords{ .x = self.guardLocation.x - 1, .y = self.guardLocation.y, .orientation = self.guardLocation.orientation };
                if (self.isInBounds(potentialCoords) and self.getChar(potentialCoords) == '#') {
                    // rotate 90* and try to move again
                    self.guardLocation.orientation = '^';
                    self.moveGuard();
                    return;
                }
                break :blk potentialCoords;
            },
            '>' => blk: {
                const potentialCoords = Coords{ .x = self.guardLocation.x + 1, .y = self.guardLocation.y, .orientation = self.guardLocation.orientation };
                if (self.isInBounds(potentialCoords) and self.getChar(potentialCoords) == '#') {
                    // rotate 90* and try to move again
                    self.guardLocation.orientation = 'V';
                    self.moveGuard();
                    return;
                }
                break :blk potentialCoords;
            },
            'V' => blk: {
                const potentialCoords = Coords{ .x = self.guardLocation.x, .y = self.guardLocation.y + 1, .orientation = self.guardLocation.orientation };
                if (self.isInBounds(potentialCoords) and self.getChar(potentialCoords) == '#') {
                    // rotate 90* and try to move again
                    self.guardLocation.orientation = '<';
                    self.moveGuard();
                    return;
                }
                break :blk potentialCoords;
            },
            else => unreachable,
        };

        // set current place to X
        self.changeCoord(self.guardLocation, 'X');
        if (!self.isInBounds(nextLocation)) return;
        // move guard
        self.changeCoord(nextLocation, nextLocation.orientation);
        self.guardLocation = nextLocation;
        self.moveGuard();
    }
};

pub fn solve1(content: []const u8) !u32 {
    var areaMap = try AreaMap.init(content);
    areaMap.moveGuard();
    var numPositions: u32 = 0;
    for (areaMap.graph.items) |row| {
        for (row.items) |col| {
            if (col == 'X') {
                numPositions += 1;
            }
        }
    }

    return numPositions;
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
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;
    const result = try solve1(content);
    try std.testing.expectEqual(@as(u32, 41), result);

    const corner =
        \\..##
        \\...#
        \\..^.
    ;
    const corner_result = try solve1(corner);
    try std.testing.expectEqual(@as(u32, 4), corner_result);
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
