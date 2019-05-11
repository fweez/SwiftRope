import XCTest
@testable import swiftrope

final class swiftropeTests: XCTestCase {
    static var allTests = [
        ("testBareInit", testBareInit),
        ("testSet", testSet),
    ]
    
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
    
    func testSimpleIteration() {
        let r = Rope([0, 1, 2])
        _ = r.enumerated().map { XCTAssertEqual($0, $1) }
    }
    
    func testBigTreeEnumeration() {
        var r = Rope(Array(0..<2))
        r.append(contentsOf: Array(2..<4))
        r.append(contentsOf: Array(4..<6))
        r.append(contentsOf: Array(6..<8))
        r.append(contentsOf: Array(8..<10))
        _ = r.enumerated().map { XCTAssertEqual($0, $1) }
    }
    
    func testSet() {
        var r = Rope([0])
        XCTAssert(r[0] == 0)
        r[0] = 1
        XCTAssert(r[0] == 1, "Rope \(r) had an incorrect element")
    }
    
    func testAppendElement() {
        var r = Rope([0, 1, 2])
        r.append(3)
        _ = r.enumerated().map { XCTAssertEqual($0, $1) }
    }
    
    func testAppendElements() {
        var r = Rope([0, 1, 2])
        r.append(contentsOf: [3, 4])
        _ = r.enumerated().map { XCTAssertEqual($0, $1) }
    }
    
    func testMultipleAppendElements() {
        var r = Rope([0,1,2,3])
        r.append(contentsOf: [4, 5, 6])
        r.append(contentsOf: [7, 8, 9])
        _ = r.enumerated().map { XCTAssertEqual($0, $1) }
    }
    
    func testEvenMoreAppending() {
        var r = Rope(Array(0..<2))
        r.append(contentsOf: Array(2..<4))
        r.append(contentsOf: Array(4..<6))
        r.append(contentsOf: Array(6..<8))
        _ = r.enumerated().map { XCTAssertEqual($0, $1) }
    }
    
    func testGoodnessThatsALotOfAppending() {
        var r = Rope(Array(0..<2))
        for i in 1..<200 {
            let start = 2 * i
            let end = 2 * (i + 1)
            r.append(contentsOf: Array(start..<end))
        }
        _ = r.enumerated().map { XCTAssertEqual($0, $1) }
    }
    
    func testLast() {
        var r = Rope([1,2,3])
        XCTAssertEqual(r.last, 3)
        r.append(contentsOf: [4, 5, 6])
        XCTAssertEqual(r.last, 6)
        r.append(contentsOf: [7, 8, 9])
        XCTAssertEqual(r.last, 9)
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
    
    func testSimpleReplaceSubrange() {
        var r = Rope(Array(0..<10))
        r.replaceSubrange(2..<4, with: [20, 30])
        XCTAssertEqual(r[1], 1)
        XCTAssertEqual(r[2], 20)
        XCTAssertEqual(r[3], 30)
        XCTAssertEqual(r[4], 4)
        XCTAssertEqual(r.count, 10)
    }
    
    func testSimpleReversed() {
        let r = Rope(Array(0..<10)).reversed()
        XCTAssertEqual(r[0], 9)
        XCTAssertEqual(r[9], 0)
    }
    
    func testNotSimpleReversed() {
        var a: Rope = [0, 1, 2]
        a.append(contentsOf: [3, 4, 5])
        var b: Rope = [6, 7, 8]
        b.append(contentsOf: [9])
        let c = a.appendRope(b).reversed()
        XCTAssertEqual(c[0], 9)
        XCTAssertEqual(c[9], 0)
    }
    
    func testMap() {
        var a: Rope = [0, 1, 2]
        a.append(contentsOf: [3, 4, 5])
        var b: Rope = [6, 7, 8]
        b.append(contentsOf: [9])
        let c = a.appendRope(b).map({ "\($0)" })
        XCTAssertEqual(c[0], "0")
        XCTAssertEqual(c[9], "9")
    }
}