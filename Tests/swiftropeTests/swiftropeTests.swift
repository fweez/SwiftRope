import XCTest
@testable import swiftrope

final class swiftropeTests: XCTestCase {
    func testBareInit() {
        let r = Rope<Int>()
        XCTAssert(r.startIndex == 0)
        XCTAssert(r.endIndex == 0)
        XCTAssert(r.count == 0)
        for _ in r {
            XCTFail("Shouldn't have any elements in the iterator!")
        }
    }
    
    func testCollectionInit() {
        let r = Rope([0, 1, 2])
        XCTAssert(r.startIndex == 0)
        XCTAssert(r.endIndex == 3)
        XCTAssert(r.count == 3)
        XCTAssert(r[0] == 0)
        XCTAssert(r[1] == 1)
        XCTAssert(r[2] == 2)
    }
    
    func testHeight() {
        let r1: Rope<Int> = .node(l: .leaf(contents: [0]), r: .leaf(contents: [1]))
        XCTAssertEqual(r1.height, 1)
        let r2: Rope<Int> = .node(l: .node(l: .leaf(contents: [0]), r: .leaf(contents: [1])), r: nil)
        XCTAssertEqual(r2.height, 2)
        let r3: Rope<Int> = .node(
            l: .node(
                l: .node(
                    l: .node(
                        l: .leaf(contents: [0]),
                        r: .leaf(contents: [1])),
                    r: nil),
                r: nil),
            r: nil)
        XCTAssertEqual(r3.height, 4)
        let r4: Rope<Int> = .node(l: nil, r: .node(l: nil, r: .leaf(contents: [0])))
        XCTAssertEqual(r4.height, 2)
    }
    
    func testArraySetter() {
        let r: Rope = [0, 1, 2]
        XCTAssert(r.startIndex == 0)
        XCTAssert(r.endIndex == 3)
        XCTAssert(r.count == 3)
        XCTAssertEqual(r[0], 0)
        XCTAssertEqual(r[1], 1)
        XCTAssertEqual(r[2], 2)
    }
    
    func testSingleLeafSplitInTwo() {
        let r: Rope = [0, 1, 2]
        let (r1, r2) = r.split(at: 1)
        XCTAssertNotNil(r1)
        XCTAssertNotNil(r2)
        XCTAssertEqual(r1![0], r[0])
        XCTAssertEqual(r2![0], r[1])
        XCTAssertEqual(r2![1], r[2])
    }
    
    func testSingleLeafSplitIntoA() {
        let r: Rope = [0, 1, 2]
        let (r1, r2) = r.split(at: 3)
        XCTAssertNotNil(r1)
        XCTAssertNil(r2)
        XCTAssertEqual(r1![0], r[0])
        XCTAssertEqual(r1![1], r[1])
        XCTAssertEqual(r1![2], r[2])
    }
    
    func testSingleLeafSplitIntoB() {
        let r: Rope = [0, 1, 2]
        let (r1, r2) = r.split(at: 0)
        XCTAssertNotNil(r2)
        XCTAssertNil(r1)
        XCTAssertEqual(r2![0], r[0])
        XCTAssertEqual(r2![1], r[1])
        XCTAssertEqual(r2![2], r[2])
    }
    
    func testMultipleLeafSplitWholeLeaves() {
        var r: Rope = [0,1,2]
        r.append(contentsOf: [3, 4, 5])
        let (a, b) = r.split(at: 3)
        XCTAssertNotNil(a)
        XCTAssertNotNil(b)
        XCTAssertEqual(a![0], r[0])
        XCTAssertEqual(a![1], r[1])
        XCTAssertEqual(a![2], r[2])
        XCTAssertEqual(b![0], r[3])
        XCTAssertEqual(b![1], r[4])
        XCTAssertEqual(b![2], r[5])
    }
    
    func testSplitNilLeft() {
        let rope: Rope<Int> = .node(l: .node(l: nil, r: .leaf(contents: [0])), r: .leaf(contents: [1]))
        let (a, b) = rope.split(at: 1)
        XCTAssertNotNil(a)
        XCTAssertNotNil(b)
        XCTAssertEqual(a![0], 0)
        XCTAssertEqual(b![0], 1)
    }
    
    func testRebalanceLongLeft() {
        let rope = Rope.node(l: .node(l: .node(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))
        guard let balanced = rope.rebalanced(minLeafSize: 0, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2])
    }
    func testRebalanceLongRight() {
        let rope = Rope.node(l: .node(l: .node(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))
        guard let balanced = rope.rebalanced(minLeafSize: 0, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2])
    }
    
    func testRebalanceMinLeafSize() {
        let rope = Rope.node(l: .node(l: .node(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))
        guard let balanced = rope.rebalanced(minLeafSize: 2, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2])
        let nodeCount = balanced.fold({ (a: Int?, b: Int?) -> Int in (a ?? 0) + (b ?? 0) }, { _ in return 1 })
        XCTAssertEqual(nodeCount, 1)
    }
    
    func testRebalanceMinLeafSizeBelowContents() {
        let rope = Rope.node(l: .node(l: .node(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))
        guard let balanced = rope.rebalanced(minLeafSize: 3, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2])
        let nodeCount = balanced.fold({ (a: Int?, b: Int?) -> Int in (a ?? 0) + (b ?? 0) }, { _ in return 1 })
        XCTAssertEqual(nodeCount, 1)
    }
    
    func testRebalanceMaxLeafSize() {
        var rope = Rope(Array(repeating: 1, count: 10))
        rope.append(contentsOf: Array(repeating: 2, count: 10))
        guard let balanced = rope.rebalanced(minLeafSize: 2, maxLeafSize: 9) else {
            XCTFail()
            return
        }
        XCTAssertEqual(balanced.count, 20)
        let nodeCount = balanced.fold({ (a: Int?, b: Int?) -> Int in (a ?? 0) + (b ?? 0) }, { _ in return 1 })
        XCTAssertEqual(nodeCount, 3)
    }
    
    
}
