@testable import Rope


var r1: Rope<Int> = .node(l: .node(l: .leaf(contents: [1]), r: .leaf(contents: [2])), r: .node(l: .leaf(contents: [3]), r: .leaf(contents: [99])))
var r2: Rope<Int> = .leaf(contents: [4])
appendRopeWithoutChangingHeight(r1, r2)
