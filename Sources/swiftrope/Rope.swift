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
        return fold( { ($0 ?? 0) + ($1 ?? 0) }, { $0.count }) ?? 0
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
    
    init?(l: Rope<Element>?, r: Rope<Element>?) {
        if l != nil || r != nil { self = .node(l: l, r: r) }
        else { return nil }
    }
    
    func fold<Result>(_ nodeCase: (Result?, Result?) -> Result?, _ leafCase: ([Element]) -> Result?) -> Result? {
        switch self {
        case let .node(l, r): return nodeCase(l?.fold(nodeCase, leafCase), r?.fold(nodeCase, leafCase))
        case let .leaf(contents): return leafCase(contents)
        }
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
    
    func appendRope(_ newSubRope: Rope<Element>?) -> Rope<Element> {
        guard newSubRope != nil else { return self }
        switch self {
        case .leaf:
            return .node(l: self, r: newSubRope)
        case let .node(l, r):
            if let r = r {
                return .node(l: l, r: r.appendRope(newSubRope))
            } else {
                return .node(l: l, r: newSubRope)
            }
        }
    }
    
    func prependRope(_ newSubRope: Rope<Element>?) -> Rope<Element> {
        guard newSubRope != nil else { return self }
        switch self {
        case .leaf:
            return Rope<Element>.node(l: newSubRope, r: self)
        case let .node(l, r):
            return Rope<Element>.node(l: l?.prependRope(newSubRope), r: r)
        }
    }
    
    // Split this rope into two unbalanced ropes.
    func split(at splitIndex: Int) -> (a: Rope<Element>?, b: Rope<Element>?) {
        switch self {
        case let .node(l, r):
            if splitIndex <= weight {
                let (a, b) = l?.split(at: splitIndex) ?? (nil, nil)
                if let r = r {
                    return (a, r.prependRope(b))
                } else {
                    return (a, Rope(l: b, r: nil))
                }
            } else {
                let (a, b) = r?.split(at: splitIndex - weight) ?? (nil, nil)
                if let l = l {
                    return (l.appendRope(a), b)
                } else {
                    return (Rope(l: nil, r: a), b)
                }
            }
        case let .leaf(contents):
            if splitIndex == 0 { return (nil, self) }
            if splitIndex == weight { return (self, nil) }
            let aContents: [Element] = Array(contents.prefix(splitIndex))
            let bContents: [Element] = Array(contents.suffix(from: splitIndex))
            return (.leaf(value: aContents), .leaf(value: bContents))
        }
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
