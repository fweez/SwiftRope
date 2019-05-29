import XCTest
@testable import Rope

class CollectionTests: XCTestCase {
    func testSet() {
        var r = Rope([0])
        XCTAssert(r[0] == 0)
        r[0] = 1
        XCTAssert(r[0] == 1, "Rope \(r) had an incorrect element")
    }
    
    func testLargerSet() {
        var r = Rope(Array(0..<2))
        r.append(contentsOf: Array(2..<4))
        r.append(contentsOf: Array(4..<6))
        r.append(contentsOf: Array(6..<8))
        r = r.balanced(minLeafSize: 0, maxLeafSize: Int.max)!
        r[3] = 99
        var a = Array(0..<8)
        a[3] = 99
        XCTAssertEqual(Array(r), a)
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
    
    func testAppendNilRope() {
        let r: Rope = [0, 1, 2, 3]
        let a = r.appendRope(nil)
        XCTAssertEqual(r, a)
    }
    
    func testLast() {
        var r = Rope([1,2,3])
        XCTAssertEqual(r.last, 3)
        r.append(contentsOf: [4, 5, 6])
        XCTAssertEqual(r.last, 6)
        r.append(contentsOf: [7, 8, 9])
        XCTAssertEqual(r.last, 9)
    }
    
    func testSimpleReplaceSubrange() {
        var r = Rope(Array(0..<10))
        var a = Array(0..<10)
        r.replaceSubrange(2..<4, with: [20, 30])
        a.replaceSubrange(2..<4, with: [20, 30])
        XCTAssertEqual(Array(r), a)
    }
    
    func testReplaceBeforeFirstElement() {
        var r = Rope(Array(0..<10))
        var a = Array(0..<10)
        r.replaceSubrange(0..<1, with: [99])
        a.replaceSubrange(0..<1, with: [99])
        XCTAssertEqual(Array(r), a)
    }
    
    func testReplaceSubrangeInLargerTree() {
        var r = Rope(Array(0..<2))
        r.append(contentsOf: Array(2..<4))
        r.append(contentsOf: Array(4..<6))
        r.append(contentsOf: Array(6..<8))
        r = r.balanced(minLeafSize: 0, maxLeafSize: Int.max)!
        let replaceRange = 3..<4
        let replaceSequence = [99]
        r.replaceSubrange(replaceRange, with: replaceSequence)
        var a = Array(0..<8)
        a.replaceSubrange(replaceRange, with: replaceSequence)
        XCTAssertEqual(Array(r), a)
    }
    
    func testReplaceLastElement() {
        var r = Rope(Array(0..<10))
        var a = Array(0..<10)
        r.replaceSubrange(9..<10, with: [99])
        a.replaceSubrange(9..<10, with: [99])
        XCTAssertEqual(Array(r), a)
    }
    
    func testIndexes() {
        let r = Rope(Array(0..<10))
        XCTAssertEqual(r.startIndex, 0)
        XCTAssertEqual(r.endIndex, 10)
        (0..<10).forEach { XCTAssertEqual(r.index(after: $0), $0 + 1) }
        (1..<9).forEach { XCTAssertEqual(r.index(before: $0), $0 - 1) }
    }
}
