//
//  Rope.swift
//  swiftrope
//
//  Created by Ryan Forsythe on 4/26/19.
//

indirect enum Rope<Element> {
    case leaf(value: [Element])
    case node(l: Rope<Element>?, r: Rope<Element>?)
    
    var sumOfLeaves: Int {
        switch self {
        case .leaf(let value): return value.count
        case let .node(l, r):
            let sumLeft = l?.sumOfLeaves ?? 0
            let sumRight = r?.sumOfLeaves ?? 0
            return sumLeft + sumRight
        }
    }

    var weight: Int {
        switch self {
        case .leaf(let value): return value.count
        case let .node(l, _): return l?.sumOfLeaves ?? 0
        }
    }
    
    init() {
        self = .node(l: nil, r: nil)
    }
    
    init(_ elements: [Element]) {
        self = .node(l: .leaf(value: elements), r: nil)
    }
    
    internal func insertRope(_ newRope: Rope<Element>, depth: Int = 0, balancedRopes: inout [Int: Rope<Element>]) {
        switch newRope {
        case .node: assertionFailure("Must insert a leaf node!")
        case .leaf:
            guard let extantRope = balancedRopes[depth] else {
                balancedRopes[depth] = newRope
                return
            }
            switch extantRope {
            case .leaf:
                balancedRopes[depth] = nil
                insertRope(.node(l: extantRope, r: newRope), depth: depth + 1, balancedRopes: &balancedRopes)
            case let .node(l, r) where l != nil && r != nil:
                balancedRopes[depth] = nil
                insertRope(.node(l: extantRope, r: newRope), depth: depth + 1, balancedRopes: &balancedRopes)
            case let .node(l, r) where r == nil:
                balancedRopes[depth] = .node(l: l, r: newRope)
            default:
                assertionFailure()
            }
        }
    }
    
    internal func insertLeaves(in node: Rope<Element>, balancedRopes: inout [Int: Rope<Element>]) {
        switch node {
        case .leaf: insertRope(node, balancedRopes: &balancedRopes)
        case let .node(l, r):
            if let left = l { insertLeaves(in: left, balancedRopes: &balancedRopes) }
            if let right = r { insertLeaves(in: right, balancedRopes: &balancedRopes) }
        }
    }
    
    internal func rebalanced() -> Rope<Element>? {
        var balancedRopes: [Int: Rope<Element>] = [:]
        
        insertLeaves(in: self, balancedRopes: &balancedRopes)
        var newHead: Rope<Element>? = nil
        for rope in balancedRopes.sorted(by: { $0.0 < $1.0 }).map({ $0.1 }) {
            guard let left = newHead else {
                newHead = rope
                continue
            }
            
            newHead = .node(l: left, r: rope)
        }
        
        return newHead
    }
    
    // Split this rope into two unbalanced ropes.
    func split(at splitIndex: Int) -> (Rope<Element>, Rope<Element>?) {
        precondition(splitIndex <= weight, "Index out of bounds")
        if splitIndex == weight { return (self, nil) }
        
        //FIXME
        return (self, nil)
    }
}

extension Rope: CustomStringConvertible {
    var description: String {
        switch self {
        case .leaf(let v): return v.description
        case let .node(l, r): return (l?.description ?? "") + (r?.description ?? "")
        }
    }
}
