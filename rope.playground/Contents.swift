@testable import swiftrope

let rope = Rope.node(l: .node(l: .node(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))

