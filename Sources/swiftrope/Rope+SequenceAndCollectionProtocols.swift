extension Rope: CustomStringConvertible {
    var description: String {
        func describeChildren<T>(_ node: RopeNode<T>?) -> String {
            guard let head = node else { return "" }
            let left = describeChildren(head.left)
            let right = describeChildren(head.right)
            return left + right
        }
        return describeChildren(head)
    }
}

extension Rope: Collection {
    var startIndex: Int { return 0 }
    var endIndex: Int { return weight }
    
     func index(after i: Int) -> Int {
        precondition(i < head?.weight ?? 0, "Index out of bounds")
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
            precondition(head != nil, "Index out of bounds")
            let (contentsIdx, nodeWithIdx) = head!.findNodeWithIndex(position)
            precondition(nodeWithIdx?.contents != nil, "Index out of bounds")
            return nodeWithIdx!.contents![contentsIdx]
        }
        set(newValue) {
            let (contentsIdx, nodeWithIdx) = head!.findNodeWithIndex(position)
            precondition(nodeWithIdx?.contents != nil, "Index out of bounds")
            nodeWithIdx!.contents![contentsIdx] = newValue
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
    mutating func append(contentsOf elements: [Element]) {
        guard var parent = head, endIndex > 1 else {
            head = RopeNode(elements)
            return
        }
        var curr: RopeNode? = parent
        while curr != nil {
            parent = curr!
            curr = parent.right
        }
        parent.right = RopeNode(elements)
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
