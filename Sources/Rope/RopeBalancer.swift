//
//  RopeBalancer.swift
//  swiftrope
//
//  Created by Ryan Forsythe on 5/14/19.
//

struct RopeBalancer<Element> {
    var rope: Rope<Element>
    var balancedRopes: [Int: Rope<Element>]!
    var minLeafSize: Int
    var maxLeafSize: Int
    var contentAccumulator: [Element] = []

    init(rope: Rope<Element>, minLeafSize: Int, maxLeafSize: Int) {
        self.rope = rope
        self.minLeafSize = minLeafSize
        self.maxLeafSize = maxLeafSize
    }
    
    mutating func balanced() -> Rope<Element> {
        balancedRopes = [:]
        insertLeaves(in: rope)
        if contentAccumulator.count > 0 {
            insertRope(.leaf(contents: contentAccumulator))
            contentAccumulator = []
        }
        var newHead: Rope<Element>? = nil
        for rope in balancedRopes.sorted(by: { $0.0 < $1.0 }).map({ $0.1 }) {
            guard let left = newHead else {
                newHead = rope
                continue
            }
            
            newHead = .node(l: left, r: rope)
        }
        
        return newHead ?? .node(l: nil, r: nil)
    }
    
    fileprivate mutating func insertRope(_ newRope: Rope<Element>, depth: Int = 0) {
        guard let extantRope = balancedRopes[depth] else {
            balancedRopes[depth] = newRope
            return
        }
        
        balancedRopes[depth] = nil
        let next = extantRope.appendRope(newRope)
        insertRope(next, depth: depth + 1)
    }
    
    
    fileprivate mutating func insertLeaves(in node: Rope<Element>) {
        switch node {
        case let .leaf(contents):
            let fullContents = contentAccumulator + contents
            contentAccumulator = []
            for idx in stride(from: 0, to: fullContents.count, by: maxLeafSize) {
                let range = Range(uncheckedBounds: (idx, min(idx + maxLeafSize, fullContents.count)))
                guard range.count > 0 else { break }
                let subSequence = Array(fullContents[range.startIndex..<range.endIndex])
                if subSequence.count < minLeafSize {
                    contentAccumulator = contentAccumulator + subSequence
                } else {
                    insertRope(.leaf(contents: subSequence))
                }
            }
        case let .node(l, r):
            if let left = l { insertLeaves(in: left) }
            if let right = r { insertLeaves(in: right) }
        }
    }
}
