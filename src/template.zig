const std = @import("std");
const fs = std.fs;
const List = std.ArrayList;
const Map = std.HashMap;
const Str = []const u8;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const gpa_allocator = gpa.allocator();

const data_filepath: Str = "data/<name>.txt";
// comptime const ptr -- String literal with file contents
const data = @embedFile(data_filepath);

pub fn main() !void {}
