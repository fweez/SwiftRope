//
//  RebalanceTests.swift
//  RopeTests
//
//  Created by Ryan Forsythe on 5/21/19.
//

import XCTest
@testable import Rope

class RebalanceTests: XCTestCase {
    func testRebalanceLongLeft() {
        let rope = Rope(l: Rope(l: Rope(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))
        guard let balanced = rope.balanced( minLeafSize: 0, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2])
    }
    func testRebalanceLongRight() {
        let rope = Rope(l: Rope(l: Rope(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))
        guard let balanced = rope.balanced( minLeafSize: 0, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2])
    }
    
    func testRebalanceMinLeafSize() {
        let rope = Rope(l: Rope(l: Rope(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))
        guard let balanced = rope.balanced( minLeafSize: 2, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2])
        let leafCount = balanced.fold({ (a: Int?, b: Int?) -> Int in (a ?? 0) + (b ?? 0) }, { _ in return 1 })
        XCTAssertEqual(leafCount, 1)
    }
    
    func testRebalanceMinLeafSizeBelowArraySize() {
        let rope = Rope(l: Rope(l: Rope(l: .leaf(contents: [1]), r: nil), r: .leaf(contents: [2])), r: .leaf(contents: [3]))
        guard let balanced = rope.balanced( minLeafSize: 2, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2, 3])
        let leafCount = balanced.fold({ (a: Int?, b: Int?) -> Int in (a ?? 0) + (b ?? 0) }, { _ in return 1 })
        XCTAssertEqual(leafCount, 2)
    }
    
    func testRebalanceMinLeafSizeBelowContents() {
        let rope = Rope(l: Rope(l: Rope(l: .leaf(contents: [1]), r: nil), r: nil), r: .leaf(contents: [2]))
        guard let balanced = rope.balanced( minLeafSize: 3, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        XCTAssertEqual(Array(balanced), [1, 2])
        let leafCount = balanced.fold({ (a: Int?, b: Int?) -> Int in (a ?? 0) + (b ?? 0) }, { _ in return 1 })
        XCTAssertEqual(leafCount, 1)
    }
    
    func testRebalanceMaxLeafSize() {
        var rope = Rope(Array(repeating: 1, count: 10))
        rope.append(contentsOf: Array(repeating: 2, count: 10))
        guard let balanced = rope.balanced( minLeafSize: 2, maxLeafSize: 9) else {
            XCTFail()
            return
        }
        XCTAssertEqual(balanced.count, 20)
        let nodeCount = balanced.fold({ (a: Int?, b: Int?) -> Int in (a ?? 0) + (b ?? 0) }, { _ in return 1 })
        XCTAssertEqual(nodeCount, 3)
    }
    
    func testRebalanceDoesntChangeOrdering() {
        var a: Rope<Int> = [1, 2, 3]
        (1..<11).forEach { iteration in
            a.append(contentsOf: [4, 5])
            guard let b = a.balanced(minLeafSize: 0, maxLeafSize: 10) else { return XCTFail() }
            XCTAssertEqual(Array(a), Array(b), "Failed in append #\(iteration)")
        }
    }
    
    func testBalancerFunction() {
        let r1: Rope<Int> = .leaf(contents: [0])
        var balancer: [Int: Rope<Int>] = [:]
        balancer = r1.insertRopeIntoBalancer(partial: balancer, rope: r1)
        XCTAssertEqual(balancer[0], r1)
        let r2: Rope<Int> = .leaf(contents: [1])
        balancer = r1.insertRopeIntoBalancer(partial: balancer, rope: r2)
        XCTAssert(balancer[0] == nil)
        if let concatenation = balancer[1] {
            XCTAssertEqual(concatenation.height, 1)
            XCTAssertEqual(Array(concatenation), [0, 1])
        } else {
            XCTFail()
        }
        let r3: Rope<Int> = .leaf(contents: [2])
        balancer = r1.insertRopeIntoBalancer(partial: balancer, rope: r3)
        XCTAssertEqual(balancer[0], r3)
        if let concatenation = balancer[1] {
            XCTAssertEqual(concatenation.height, 1)
            XCTAssertEqual(Array(concatenation), [0, 1])
        } else {
            XCTFail()
        }
        let r4: Rope<Int> = .leaf(contents: [3])
        balancer = r1.insertRopeIntoBalancer(partial: balancer, rope: r4)
        if let concatenation = balancer[2] {
            XCTAssertEqual(concatenation.height, 2)
            XCTAssertEqual(Array(concatenation), [0, 1, 2, 3])
        } else {
            XCTFail()
        }
    }
    
    func testLongTree() {
        var rope: Rope<Int> = [0]
        let nodes = 100
        for i in 1..<nodes {
            rope.append(contentsOf: [i])
        }
        guard let balanced = rope.balanced( minLeafSize: 0, maxLeafSize: Int.max) else {
            XCTFail()
            return
        }
        let expectedHeight = Int(ceil(log2(Float(nodes))))
        XCTAssertEqual(balanced.height, expectedHeight)
    }
    
    func testAppendWithoutChangingHeightNilRight() {
        let rope = Rope(l: Rope(l: .leaf(contents: [0]), r: nil), r: nil)
        let append: Rope<Int> = .leaf(contents: [1])
        let result = rope.appendRopeWithoutChangingHeight(rope, append)
        XCTAssertNotNil(result)
        XCTAssertEqual(Array(result!), [0, 1])
    }
    
    func testAWCHFailsInNilRight() {
        let rope = Rope(l: .leaf(contents: [0]), r: nil)
        let append = Rope(l: Rope(l: .leaf(contents: [1]), r: .leaf(contents: [2])), r: nil)
        XCTAssertNil(rope.appendRopeWithoutChangingHeight(rope, append))
    }
    
    func testAWCHNonNilRight() {
        let rope = Rope(l: Rope(l: .leaf(contents: [0]), r: nil), r: Rope(l: .leaf(contents: [1]), r: nil))
        let append: Rope<Int> = .leaf(contents: [2])
        let result = rope.appendRopeWithoutChangingHeight(rope, append)
        XCTAssertNotNil(result)
        XCTAssertEqual(Array(result!), [0, 1, 2])
    }
    
    func testAWCHNilLeft() {
        let rope = Rope(l: nil, r: .leaf(contents: [0]))
        XCTAssertNil(rope.appendRopeWithoutChangingHeight(rope, .leaf(contents: [1])))
    }
}
