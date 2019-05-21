@testable import swiftrope

var a: Rope = [0, 1, 2]
a.append(contentsOf: [3, 4, 5])
var b: Rope = [6, 7, 8]
b.append(contentsOf: [9])
let rope = a.appendRope(b)

let m = rope.compactMap { (i) -> Int? in
    guard i > 3 else { return nil }
    return i
}

for elt in m { print(elt) }
dump(Array(m))
