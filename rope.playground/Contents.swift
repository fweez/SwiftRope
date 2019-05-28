import Rope

var intRope = Rope([1, 2, 3])
intRope.append(4)
(4..<100).forEach { i in intRope.append(i) }
print(intRope.height)
var balancedRope = intRope.balanced(minLeafSize: 5, maxLeafSize: 10)!
print(balancedRope.height)

intRope.reduce(0, +)
