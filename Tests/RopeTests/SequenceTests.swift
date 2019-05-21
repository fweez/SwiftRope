import XCTest
@testable import Rope

class SequenceTests: XCTestCase {
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
    
    fileprivate var complexTenElementRope: Rope<Int> {
        return Rope<Int>.node(l: .node(l: .leaf(contents: [0, 1, 2]), r: .node(l: nil, r: .leaf(contents: [3, 4]))), r: .node(l: .leaf(contents: [5, 6, 7]), r: .node(l: .leaf(contents: [8, 9]), r: nil)))
    }
    
    func testMap() {
        let r = complexTenElementRope.map({ "\($0)" })
        XCTAssertEqual(r[0], "0")
        XCTAssertEqual(r[9], "9")
    }
    
    enum TestError: Error {
        case justSomeError
    }
    
    func testMapThrows() {
        do {
            dump(try complexTenElementRope.map { _ in
                throw TestError.justSomeError
                })
        } catch _ as TestError {
            return
        } catch {
            XCTFail()
        }
        XCTFail()
    }
    
    func testCompactMap() {
        let mapFn = { (i: Int) -> Int? in
            guard i < 5 else { return nil }
            return i
        }
        let array = Array(0..<10)
        let mappedRope: Rope<Int> = complexTenElementRope.compactMap(mapFn)
        XCTAssertEqual(Array(mappedRope), array.compactMap(mapFn))
    }
    
    func testReduce() {
        let rope = complexTenElementRope
        let array = Array(0..<10)
        XCTAssertEqual(rope.reduce(0, +), array.reduce(0, +))
        XCTAssertEqual(rope.reduce(0, -), array.reduce(0, -))
        let s = { (i: String, x: Int) -> String in i + String(x) }
        XCTAssertEqual(rope.reduce("", s), array.reduce("", s))
    }
    
    func testShortPrefix() {
        let slice = complexTenElementRope.prefix(2)
        XCTAssertEqual(slice[0], 0)
        XCTAssertEqual(slice[1], 1)
        XCTAssertEqual(slice.count, 2)
    }
    
    func testTooLongPrefix() {
        let slice = complexTenElementRope.prefix(20)
        XCTAssertEqual(slice[0], 0)
        XCTAssertEqual(slice[9], 9)
        XCTAssertEqual(slice.count, 10)
    }
    
    func testZeroPrefix() {
        let slice = complexTenElementRope.prefix(0)
        XCTAssertEqual(slice.count, 0)
    }
    
    func testShortSuffix() {
        let slice = complexTenElementRope.suffix(2)
        XCTAssertEqual(slice[0], 8)
        XCTAssertEqual(slice[1], 9)
        XCTAssertEqual(slice.count, 2)
    }
    
    func testTooLongSuffix() {
        let slice = complexTenElementRope.suffix(20)
        XCTAssertEqual(slice[0], 0)
        XCTAssertEqual(slice[9], 9)
        XCTAssertEqual(slice.count, 10)
    }
    
    func testZeroSuffix() {
        let slice = complexTenElementRope.suffix(0)
        XCTAssertEqual(slice.count, 0)
    }
    
    func testSimpleReversed() {
        let r = Rope(Array(0..<10)).reversed()
        XCTAssertEqual(r[0], 9)
        XCTAssertEqual(r[9], 0)
    }
    
    func testNotSimpleReversed() {
        let r = complexTenElementRope.reversed()
        XCTAssertEqual(r[0], 9)
        XCTAssertEqual(r[9], 0)
    }
}
