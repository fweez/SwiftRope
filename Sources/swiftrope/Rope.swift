//
//  Rope.swift
//  swiftrope
//
//  Created by Ryan Forsythe on 4/26/19.
//

indirect enum Rope<Element> {
    case leaf(contents: [Element])
    case node(l: Rope<Element>?, r: Rope<Element>?)
    
    var sumOfLeaves: Int {
        return fold( { ($0 ?? 0) + ($1 ?? 0) }, { $0.count })
    }

    var weight: Int {
        switch self {
        case .leaf(let value): return value.count
        case let .node(l, _): return l?.sumOfLeaves ?? 0
        }
    }
    
    var height: Int {
        return fold({ Swift.max($0 ?? 0, $1 ?? 0) + 1 }, { _ in return 0 })
    }
    
    init() {
        self = .node(l: nil, r: nil)
    }
    
    init(_ elements: [Element]) {
        self = .node(l: .leaf(contents: elements), r: nil)
    }
    
    init?(l: Rope<Element>?, r: Rope<Element>?) {
        if l != nil || r != nil { self = .node(l: l, r: r) }
        else { return nil }
    }
    
    func fold<Result>(_ nodeCase: (Result?, Result?) throws -> Result, _ leafCase: ([Element]) throws -> Result) rethrows -> Result {
        switch self {
        case let .node(l, r): return try nodeCase(l?.fold(nodeCase, leafCase), r?.fold(nodeCase, leafCase))
        case let .leaf(contents): return try leafCase(contents)
        }
    }
    
    internal func rebalanced(minLeafSize: Int, maxLeafSize: Int) -> Rope<Element>? {
        var balancer = RopeBalancer(rope: self, minLeafSize: minLeafSize, maxLeafSize: maxLeafSize)
        return balancer.balanced()
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
            return (.leaf(contents: aContents), .leaf(contents: bContents))
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

extension Rope: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
    
    init(arrayLiteral elements: Rope.ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension Rope: Equatable where Element: Equatable { }
