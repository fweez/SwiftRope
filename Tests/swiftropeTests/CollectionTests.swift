//
//  CollectionTests.swift
//  swiftropeTests
//
//  Created by Ryan Forsythe on 5/21/19.
//

import XCTest
@testable import swiftrope

class CollectionTests: XCTestCase {
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
        r.replaceSubrange(2..<4, with: [20, 30])
        XCTAssertEqual(r[1], 1)
        XCTAssertEqual(r[2], 20)
        XCTAssertEqual(r[3], 30)
        XCTAssertEqual(r[4], 4)
        XCTAssertEqual(r.count, 10)
    }
}
