# SwiftRope

An implementation of the Rope data structure. 

This is based on the original rope data structure paper, which you can find in [the wayback machine](https://web.archive.org/web/20180619190036/http://citeseer.ist.psu.edu/viewdoc/download?doi=10.1.1.14.9450&rep=rep1&type=pdf). I also was watching [the Swift Talk](https://talk.objc.io) sessions on `fold` (see episodes 150 through 152), and used those concepts extensively.

## Usage

You can create a Rope in a variety of ways:

```swift
var intRope = Rope([1, 2, 3])
let strRope: Rope<String> = ["Hello", "World", "!"]
let incrementedRope: Rope<Int> = intRope.map { $0 + 1 }
let reversedRope: Rope<String> = strRope.reversed()
```
And interact and manipulate it like any other `Collection`:

```swift
intRope.append(4)
intRope.append(contentsOf: [5, 6, 7])

for element in intRope {
    print(element)
}

let big = intRope.reduce(0, +)
```

To retain decent performance, you may need to rebalance after a lot of manipulation, though:

```swift
var intRope = Rope([1, 2, 3])
intRope.append(4)
(4..<100).forEach { i in intRope.append(i) }
print(intRope.height) // --> 97
var balancedRope = intRope.balanced(minLeafSize: 5, maxLeafSize: 10)!
print(balancedRope.height) // --> 5
```
