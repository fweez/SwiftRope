extension Rope: Sequence {
    func makeIterator() -> AnyIterator<Element> {
        var nodeStack: [Rope] = [self]
        var leafStack: [Element] = []
        return AnyIterator {
            while leafStack.count > 0 {
                return leafStack.removeFirst()
            }
            while let next = nodeStack.popLast() {
                switch next {
                case let .leaf(contents):
                    leafStack.append(contentsOf: contents)
                    if leafStack.count > 0 { return leafStack.removeFirst() }
                case let .node(l, r):
                    if let r = r { nodeStack.append(r) }
                    if let l = l { nodeStack.append(l) }
                }
            }
            return nil
        }
    }

    func reversed() -> Rope {
        return fold({ .node(l: $1, r: $0) }, { .leaf(value: Array($0.reversed())) }) ?? .node(l: nil, r: nil)
    }
    
    func map<T>(_ transform: (Element) throws -> T) rethrows -> Rope<T> {
        return try fold({ .node(l: $0, r: $1) }, { .leaf(value: try $0.map(transform)) }) ?? .node(l: nil, r: nil)
    }
    
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        switch self {
        case let .leaf(contents): return try contents.reduce(initialResult, nextPartialResult)
        case let .node(l, r):
            let leftPartial = try l?.reduce(initialResult, nextPartialResult) ?? initialResult
            return try r?.reduce(leftPartial, nextPartialResult) ?? leftPartial
        }
    }
    
    // FIXME: prefix and suffix
    func prefix(_ maxLength: Int) -> Slice<Rope<Element>> {
        guard maxLength > 0 else { return Slice(Rope([])) }
        guard maxLength <= count else { return Slice(self) }
        let splitPosition = Swift.min(maxLength, count)
        let (prefixRope, _) = split(at: splitPosition)
        return Slice(prefixRope ?? Rope([]))
    }
    
    func suffix(_ maxLength: Int) -> Slice<Rope<Element>> {
        guard maxLength > 0 else { return Slice(Rope([])) }
        guard maxLength <= count else { return Slice(self) }
        let splitPosition = Swift.max(0, count - maxLength)
        let (_, suffixRope) = split(at: splitPosition)
        return Slice(suffixRope ?? Rope([]))
        
    }
}

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
                return .node(l: l, r: .node(l: r, r: .leaf(value: newElements)))
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
        var (first, b) = self.split(at: subrange.startIndex)
        let (_, third) = b!.split(at: subrange.endIndex - subrange.startIndex)
        // then insert the newElements between the first and last rope
        switch first! {
        case .leaf: first = .node(l: first, r: nil)
        case .node: break
        }
        self = first!.appendRope(.leaf(value: Array(newElements))).appendRope(third)
    }
}
