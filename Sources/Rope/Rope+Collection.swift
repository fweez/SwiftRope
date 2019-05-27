extension Rope: Collection {
    var startIndex: Int { return 0 }
    var endIndex: Int {
        switch self {
        case let .leaf(contents): return contents.count
        case let .node(_, r): return weight + (r?.endIndex ?? 0)
        }
    }
    
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
    
    var last: Element? {
        switch self {
        case .leaf(let contents): return contents.last
        case let .node(l, r):
            if let result = r?.last { return result }
            return l?.last
        }
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
            return .leaf(contents: contents)
        }
    }
}

extension Rope: RandomAccessCollection { }

extension Rope: RangeReplaceableCollection {
    mutating func append(contentsOf newElements: [Element]) {
        self = rewritingAppend(contentsOf: newElements)
    }
    
    private mutating func rewritingAppend(contentsOf newElements: [Element]) -> Rope<Element> {
        switch self {
        case .leaf:
            assertionFailure("Could not insert")
            return .leaf(contents: [])
        case .node(let l, var r):
            switch r {
            case .none:
                return .node(l: l, r: .leaf(contents: newElements))
            case .some(.leaf):
                return .node(l: l, r: .node(l: r, r: .leaf(contents: newElements)))
            case .some(.node):
                return .node(l: l, r: r!.rewritingAppend(contentsOf: newElements))
            }
        }
    }
    
    mutating func append(_ e: Element) {
        append(contentsOf: [e])
    }
    
    mutating func replaceSubrange<C>(_ subrange: Range<Rope.Index>, with newElements: __owned C) where C : Collection, Rope.Element == C.Element {
        // The basic idea is we split our rope into three ropes:
        // rope.start..<subrange.start, subrange.start...subrange.end, subrange.end+1..rope.end
        // then discard the middle rope
        precondition(subrange.startIndex >= 0)
        precondition(subrange.endIndex <= count)
        let (a, b) = self.split(at: subrange.startIndex)
        let (_, third) = b!.split(at: subrange.endIndex - subrange.startIndex)
        
        // then insert the newElements between the first and last rope
        // if the first rope is empty, newElements should be first:
        guard var first = a else {
            self = .node(l: .leaf(contents: Array(newElements)), r: third)
            return
        }
        
        switch first {
        case .leaf: first = .node(l: first, r: nil)
        case .node: break
        }
        self = first.appendRope(.leaf(contents: Array(newElements))).appendRope(third)
    }
}
