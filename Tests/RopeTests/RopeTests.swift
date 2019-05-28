import XCTest
@testable import Rope

final class RopeTests: XCTestCase {
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
        let r0: Rope<Int> = .node(l: nil, r: nil, height: Rope<Int>.computeHeight(l: nil as Rope<Int>?, r: nil as Rope<Int>?), weight: 0)
        XCTAssertEqual(r0.height, 0)
        let r1: Rope<Int> = Rope(l: .leaf(contents: [0]), r: .leaf(contents: [1]))
        XCTAssertEqual(r1.height, 1)
        let r1_1: Rope<Int> = Rope(l: nil, r: .leaf(contents: [1]))
        XCTAssertEqual(r1_1.height, 1)
        let r1_2: Rope<Int> = Rope(l: .leaf(contents: [1]), r: nil)
        XCTAssertEqual(r1_2.height, 1)
        let r2: Rope<Int> = Rope(l: Rope(l: .leaf(contents: [0]), r: .leaf(contents: [1])), r: nil)
        XCTAssertEqual(r2.height, 2)
        let r3: Rope<Int> = Rope(
            l: Rope(
                l: Rope(
                    l: Rope(
                        l: .leaf(contents: [0]),
                        r: .leaf(contents: [1])),
                    r: nil),
                r: nil),
            r: nil)
        XCTAssertEqual(r3.height, 4)
        let r4: Rope<Int> = Rope(l: nil, r: Rope(l: nil, r: .leaf(contents: [0])))
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
        let rope: Rope<Int> = Rope(l: Rope(l: nil, r: .leaf(contents: [0])), r: .leaf(contents: [1]))
        let (a, b) = rope.split(at: 1)
        XCTAssertNotNil(a)
        XCTAssertNotNil(b)
        XCTAssertEqual(a![0], 0)
        XCTAssertEqual(b![0], 1)
    }
}
