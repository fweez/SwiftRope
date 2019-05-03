//
//  Rope.swift
//  swiftrope
//
//  Created by Ryan Forsythe on 4/26/19.
//

struct Rope<Element: Equatable> {
    var head: RopeNode<Element>?
    
    var weight: Int {
        func sumOfChildrenCounts<T>(_ node: RopeNode<T>?) -> Int {
            guard let head = node else { return 0 }
            return head.weight + sumOfChildrenCounts(head.left)
        }
        return sumOfChildrenCounts(head)
    }
    
    init() {
        head = nil
    }
    
    init<C: Collection>(_ sequence: C) where C.Element == Element {
        head = RopeNode(sequence)
        head?.left = nil
        head?.right = nil
    }
    
    init(ropes: [Rope<Element>]) {
        // FIXME
        head = nil
    }
    
    init(headNode: RopeNode<Element>?) {
        head = headNode
    }
    
    internal func rebalanced() -> RopeNode<Element>? {
        var balancedRopes: [Int: RopeNode<Element>] = [:]
        
        func insertRope(_ node: RopeNode<Element>, depth: Int = 0) {
            precondition(node.contents != nil, "Must insert a leaf node!")
            if let extantRope = balancedRopes[depth] {
                // Three options:
                if extantRope.contents != nil || // the extantRope can be a leaf node
                    (extantRope.right != nil && extantRope.left != nil) { // or it's full
                    // So we create a new concatenation node, append the new node, and insert it
                    let concatenated = RopeNode(a: extantRope, b: node)
                    balancedRopes[depth] = nil
                    insertRope(concatenated, depth: depth + 1)
                } else { // extantRope must have an open right
                    precondition(extantRope.right == nil, "Should have an open position")
                    extantRope.right = node
                }
            } else {
                balancedRopes[depth] = node
            }
        }
        
        func insertLeaves(in node: RopeNode<Element>) {
            if node.contents != nil {
                insertRope(node)
                return
            }
            if let l = node.left { insertLeaves(in: l) }
            if let r = node.right { insertLeaves(in: r) }
        }
        
        guard let h = head else { return nil }
        
        insertLeaves(in: h)
        var newHead: RopeNode<Element>? = nil
        for rope in balancedRopes.sorted(by: { $0.0 < $1.0 }).map({ $0.1 }) {
            guard let left = newHead else {
                newHead = rope
                continue
            }
            
            newHead = RopeNode(a: left, b: rope)
        }
        
        return newHead
    }
}
