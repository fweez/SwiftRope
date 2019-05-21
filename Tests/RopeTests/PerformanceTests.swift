//
//  PerformanceTests.swift
//  RopeTests
//
//  Created by Ryan Forsythe on 5/21/19.
//

import XCTest
@testable import Rope

class PerformanceTests: XCTestCase {
    func testPerformanceExample() {
        measure {
            var rope: Rope<Int> = [0]
            for i in 0..<10000 {
                let idx = Int(arc4random_uniform(UInt32(rope.count)))
                rope.replaceSubrange(idx..<idx+1, with: [1, 2, 3, 4])
                if i % 100 == 0 { rope = rope.rebalanced(minLeafSize: 0, maxLeafSize: Int.max)! }
            }
        }
        
        
    }

}
