//
//  Rope.swift
//  swiftrope
//
//  Created by Ryan Forsythe on 4/26/19.
//

public indirect enum Rope<Element> {
    case leaf(contents: [Element])
    case node(l: Rope<Element>?, r: Rope<Element>?, height: Int, weight: Int)
    
    internal var sumOfLeaves: Int {
        switch self {
        case .leaf(let contents): return contents.count
        case let .node(_, r, _, weight): return weight + (r?.sumOfLeaves ?? 0)
        }
    }

    var weight: Int {
        switch self {
        case .leaf(let contents): return contents.count
        case let .node(_, _, _, weight): return weight
        }
    }
    
    public var height: Int {
        switch self {
        case .leaf: return 0
        case let .node(_, _, height, _): return height
        }
    }
        
    public init() {
        self = .node(l: nil, r: nil, height: 0, weight: 0)
    }
    
    public init(_ elements: [Element]) {
        self = Rope(l: .leaf(contents: elements), r: nil)
    }
    
    public init(l: Rope<Element>?, r: Rope<Element>?) {
        self = .node(l: l, r: r, height: Rope.computeHeight(l: l, r: r), weight: l?.sumOfLeaves ?? 0)
    }
    
    internal static func computeHeight<T>(l: Rope<T>?, r: Rope<T>?) -> Int {
        guard l != nil || r != nil else { return 0 }
        let lh = l?.height ?? 0
        let rh = r?.height ?? 0
        return Swift.max(lh, rh) + 1
    }
    
    func fold<Result>(_ nodeCase: (Result?, Result?) throws -> Result, _ leafCase: ([Element]) throws -> Result) rethrows -> Result {
        switch self {
        case let .node(l, r, _, _): return try nodeCase(l?.fold(nodeCase, leafCase), r?.fold(nodeCase, leafCase))
        case let .leaf(contents): return try leafCase(contents)
        }
    }
    
     func appendRope(_ newSubRope: Rope<Element>?) -> Rope<Element> {
        guard newSubRope != nil else { return self }
        switch self {
        case .leaf:
            return Rope(l: self, r: newSubRope)
        case let .node(l, r, _, _):
            guard let left = l else {
                return Rope(l: newSubRope, r: r)
            }
            guard let right = r else {
                return Rope(l: left, r: newSubRope)
            }
            let newRight = right.appendRope(newSubRope)
            return Rope(l: left, r: newRight)
        }
    }
    
    func prependRope(_ newSubRope: Rope<Element>?) -> Rope<Element> {
        guard newSubRope != nil else { return self }
        switch self {
        case .leaf:
            return Rope(l: newSubRope, r: self)
        case let .node(l, r, _, _):
            return Rope(l: l?.prependRope(newSubRope), r: r)
        }
    }
    
    // Split this rope into two unbalanced ropes.
    func split(at splitIndex: Int) -> (a: Rope<Element>?, b: Rope<Element>?) {
        switch self {
        case let .node(l, r, _, weight):
            if splitIndex < weight {
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
                    return (a, b)
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
    public var description: String {
        return "Height: \(height); contents: \(contentDescription)"
    }
    
    var contentDescription: String {
        switch self {
        case .leaf(let v): return v.description
        case let .node(l, r, _, _): return (l?.contentDescription ?? "") + (r?.contentDescription ?? "")
        }
    }
}

extension Rope: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    
    public init(arrayLiteral elements: Rope.ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension Rope: Equatable where Element: Equatable { }
