extension Rope: Collection {
    var startIndex: Int { return 0 }
    var endIndex: Int { return weight }
    
     func index(after i: Int) -> Int {
        precondition(i < self.weight, "Index out of bounds")
        return i + 1
    }
}

extension Rope: BidirectionalCollection {
    func index(before i: Int) -> Int {
        precondition(i > 0, "Index out of bounds")
        precondition(i <= endIndex, "Index out of bounds")
        return i - 1
    }
}

extension Rope: MutableCollection {
    subscript(position: Int) -> Element {
        get {
            switch self {
            case .leaf(let contents): return contents[position]
            case let .node(l, r):
                if weight <= position {
                    precondition(r != nil, "Index out of bounds")
                    return r![position - weight]
                } else {
                    precondition(l != nil, "Index out of bounds")
                    return l![position]
                }
            }
        }
        set(newValue) {
            self = set(value: newValue, at: position)
        }
    }
    
    private func set(value: Element, at position: Int) -> Rope<Element> {
        switch self {
        case let .node(l, r):
            if weight <= position {
                precondition(r != nil, "Index out of bounds")
                return .node(l: l, r: r!.set(value: value, at: position - weight))
            } else {
                precondition(l != nil, "Index out of bounds")
                return .node(l: l!.set(value: value, at: position), r: r)
            }
        case .leaf(var contents):
            contents[position] = value
            return .leaf(value: contents)
        }
    }
}


extension Rope: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
    
    init(arrayLiteral elements: Rope.ArrayLiteralElement...) {
        self.init(elements)
    }
}

extension Rope: RandomAccessCollection { }

extension Rope: RangeReplaceableCollection {
    mutating func append(contentsOf newElements: [Element]) {
        self = rewritingAppend(contentsOf: newElements)
        switch self {
        case .leaf: assertionFailure("Could not insert")
        case var .node(_, r):
            switch r {
            case .none: r = Rope(newElements)
            case .some(.leaf):
                r = .node(l: r, r: Rope(newElements))
            case .some(.node):
                r?.append(contentsOf: newElements)
            }
        }
    }
    
    private mutating func rewritingAppend(contentsOf newElements: [Element]) -> Rope<Element> {
        switch self {
        case .leaf:
            assertionFailure("Could not insert")
            return .leaf(value: [])
        case .node(let l, var r):
            switch r {
            case .none:
                return .node(l: l, r: .leaf(value: newElements))
            case .some(.leaf):
                return .node(l: r, r: .leaf(value: newElements))
            case .some(.node):
                return r!.rewritingAppend(contentsOf: newElements)
            }
        }
    }
    
    mutating func append(_ e: Element) {
        append(contentsOf: [e])
    }
    
    func replaceSubrange<C>(_ subrange: Range<Rope.Index>, with newElements: __owned C) where C : Collection, Rope.Element == C.Element {
        // The basic idea is we split our rope into three ropes:
        // rope.start..<subrange.start, subrange.start...subrange.end, subrange.end+1..rope.end
        // then discard the middle rope
        // then insert the newElements between the first and last rope
    }
}
