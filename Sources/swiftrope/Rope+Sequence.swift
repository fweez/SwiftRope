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
        return fold({ .node(l: $1, r: $0) }, { .leaf(contents: Array($0.reversed())) }) ?? .node(l: nil, r: nil)
    }
    
    func map<T>(_ transform: (Element) throws -> T) rethrows -> Rope<T> {
        return try fold({ .node(l: $0, r: $1) }, { .leaf(contents: try $0.map(transform)) }) ?? .node(l: nil, r: nil)
    }
    
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        switch self {
        case let .leaf(contents): return try contents.reduce(initialResult, nextPartialResult)
        case let .node(l, r):
            let leftPartial = try l?.reduce(initialResult, nextPartialResult) ?? initialResult
            return try r?.reduce(leftPartial, nextPartialResult) ?? leftPartial
        }
    }
    
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
