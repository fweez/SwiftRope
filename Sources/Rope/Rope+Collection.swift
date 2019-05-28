extension Rope: Collection {
    public var startIndex: Int { return 0 }
    public var endIndex: Int {
        return fold({ ($0 ?? 0) + ($1 ?? 0) }, { $0.count })
    }
    
    public func index(after i: Int) -> Int {
        precondition(i < endIndex, "Index out of bounds")
        return i + 1
    }
}

extension Rope: BidirectionalCollection {
    public func index(before i: Int) -> Int {
        precondition(i > 0, "Index out of bounds")
        precondition(i <= endIndex, "Index out of bounds")
        return i - 1
    }
    
    public var last: Element? {
        switch self {
        case .leaf(let contents): return contents.last
        case let .node(l, r, _, _):
            if let result = r?.last { return result }
            return l?.last
        }
    }
}

extension Rope: MutableCollection {
    public subscript(position: Int) -> Element {
        get {
            switch self {
            case .leaf(let contents): return contents[position]
            case let .node(l, r, _, weight):
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
        case let .node(l, r, _, weight):
            if weight <= position {
                precondition(r != nil, "Index out of bounds")
                let newRight = r!.set(value: value, at: position - weight)
                return Rope(l: l, r: newRight)
            } else {
                precondition(l != nil, "Index out of bounds")
                let newLeft = l!.set(value: value, at: position)
                return Rope(l: newLeft, r: r)
            }
        case .leaf(var contents):
            contents[position] = value
            return .leaf(contents: contents)
        }
    }
}

extension Rope: RandomAccessCollection { }

extension Rope: RangeReplaceableCollection {    
    public mutating func append(contentsOf newElements: [Element]) {
        self = rewritingAppend(contentsOf: newElements)
    }
    
    private mutating func rewritingAppend(contentsOf newElements: [Element]) -> Rope<Element> {
        switch self {
        case .leaf:
            assertionFailure("Could not insert")
            return .leaf(contents: [])
        case .node(let l, var r, _, _):
            let newRight: Rope<Element>
            switch r {
            case .none:
                newRight = .leaf(contents: newElements)
            case .some(.leaf):
                let newLeaf: Rope<Element> = .leaf(contents: newElements)
                newRight = Rope(l: r, r: newLeaf)
            case .some(.node):
                newRight = r!.rewritingAppend(contentsOf: newElements)
            }
            return Rope(l: l, r: newRight)
        }
    }
    
    mutating public func append(_ e: Element) {
        append(contentsOf: [e])
    }
    
    mutating public func replaceSubrange<C>(_ subrange: Range<Rope.Index>, with newElements: __owned C) where C : Collection, Rope.Element == C.Element {
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
            let newLeft: Rope<Element> = .leaf(contents: Array(newElements))
            self = Rope(l: newLeft, r: third)
            return
        }
        
        switch first {
        case .leaf: first = .node(l: first, r: nil, height: Rope.computeHeight(l: first, r: nil), weight: first.sumOfLeaves)
        case .node: break
        }
        self = first.appendRope(.leaf(contents: Array(newElements))).appendRope(third)
    }
}
