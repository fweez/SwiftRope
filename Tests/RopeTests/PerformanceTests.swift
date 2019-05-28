//
//  PerformanceTests.swift
//  RopeTests
//
//  Created by Ryan Forsythe on 5/21/19.
//

import XCTest
@testable import Rope

class PerformanceTests: XCTestCase {
    func testRopePerformance() {
        measure {
            var rope: Rope<Int> = [0]
            for i in 0..<1000 {
                let limit = max(0, rope.count - 1)
                let idx = Int(arc4random_uniform(UInt32(limit)))
                rope.replaceSubrange(idx..<idx+1, with: [1, 2, 3, 4])
                if i % 100 == 0 { rope = rope.balanced(minLeafSize: 0, maxLeafSize: Int.max)! }
            }
        }
    }

    func testStringPerformance() {
        measure {
            var s = "0"
            for _ in 0..<1000 {
                let offset = Int(arc4random_uniform(UInt32(s.count)))
                let startIdx = s.index(s.startIndex, offsetBy: offset)
                let endIdx = s.index(startIdx, offsetBy: 1)
                s.replaceSubrange(startIdx..<endIdx, with: "1234")
            }
        }
    }
}
