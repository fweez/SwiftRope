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
    
    func testIteration() {
        let r = Rope([0, 1, 2])
        _ = r.enumerated().map { XCTAssertEqual($0, $1) }
    }
    
    func testSet() {
        var r = Rope([0])
        XCTAssert(r[0] == 0)
        r[0] = 1
        XCTAssert(r[0] == 1)
    }
    
    func testAppendElement() {
        var r = Rope([0, 1, 2])
        r.append(3)
        XCTAssertEqual(r[3], 3)
    }
    
    func testAppendElements() {
        var r = Rope([0, 1, 2])
        r.append(contentsOf: [3, 4])
        XCTAssertEqual(r[3], 3)
        XCTAssertEqual(r[4], 4)
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
    
    
}
