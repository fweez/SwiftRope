//
//  RopeBalancer.swift
//  swiftrope
//
//  Created by Ryan Forsythe on 5/14/19.
//

extension Rope {
    func balanced(minLeafSize: Int, maxLeafSize: Int) -> Rope? {
        return balance(self, minLeafSize: minLeafSize, maxLeafSize: maxLeafSize)
    }
    
    fileprivate func balance<T>(_ rope: Rope<T>, minLeafSize: Int, maxLeafSize: Int) -> Rope<T>? {
        let splitFn: ([Rope<T>], Rope<T>) -> [Rope<T>] = splitAndConcatLeavesFn(minLeafSize, maxLeafSize)
        return getLeaves(rope)
            .reduce([], splitFn)
            .reduce([:], insertRopeIntoBalancer)
            .sorted { $0.key < $1.key }
            .map { $0.value }
            .reduce(nil, appendRopes)
    }
    
    fileprivate func getLeaves<T>(_ rope: Rope<T>?) -> [Rope<T>] {
        guard let rope = rope else { return [] }
        switch rope {
        case let .node(l, r): return [l, r].flatMap(getLeaves)
        case .leaf: return [rope]
        }
    }
    
    fileprivate func splitLeaf<T>(_ minLeafSize: Int, _ maxLeafSize: Int) -> (Rope<T>) -> [Rope<T>] {
        let splitContentsFn: ([T]) -> [Rope<T>] = splitContents(minLeafSize, maxLeafSize)
        return { leaf in
            switch leaf {
            case .node:
                assertionFailure()
                return []
            case let .leaf(contents): return splitContentsFn(contents)
            }
        }
    }
    
    fileprivate func splitContents<T>(_ minLeafSize: Int, _ maxLeafSize: Int) -> ([T]) -> [Rope<T>] {
        return { contents in
            return stride(from: 0, to: contents.count, by: maxLeafSize)
                .map { Range(uncheckedBounds: ($0, Swift.min($0 + maxLeafSize, contents.count))) }
                .map { Array(contents[$0.startIndex..<$0.endIndex]) }
                .map { Rope<T>.leaf(contents: $0) }
        }
    }
    
    fileprivate func splitAndConcatLeavesFn<T>(_ minLeafSize: Int, _ maxLeafSize: Int) -> ([Rope<T>], Rope<T>) -> [Rope<T>] {
        let splitLeafFn: (Rope<T>) -> [Rope<T>] = splitLeaf(minLeafSize, maxLeafSize)
        let splitContentsFn: ([T]) -> [Rope<T>] = splitContents(minLeafSize, maxLeafSize)
        return { partial, leaf in
            let last = partial.last
            var newContents: [T] = []
            switch last {
            case .some(.node): assertionFailure()
            case .none:
                return splitLeafFn(leaf)
            case .some(.leaf(let contents)) where contents.count >= minLeafSize:
                return partial + splitLeafFn(leaf)
            case .some(.leaf(let contents)):
                newContents = contents
            }
            
            let partialRemainder = partial.prefix(Swift.max(partial.count - 1, 0))
            switch leaf {
            case .node: assertionFailure()
            case let .leaf(contents): newContents += contents
            }
            
            return partialRemainder + splitContentsFn(newContents)
        }
    }
    
    fileprivate func appendRopeWithoutChangingHeight<T>(_ head: Rope<T>?, _ rope: Rope<T>?) -> Rope<T>? {
        guard let head = head else { return rope }
        guard let rope = rope else { return head }
        
        switch head {
        case let .node(l, r):
            if let newLeft = appendRopeWithoutChangingHeight(l, rope) {
                return .node(l: newLeft, r: r)
            }
            if let newRight = appendRopeWithoutChangingHeight(r, rope) {
                return .node(l: l, r: newRight)
            }
            return nil
        case .leaf: return nil
        }
    }
    
    func insertRopeIntoBalancer<T>(partial: [Int: Rope<T>], rope: Rope<T>) -> [Int: Rope<T>] {
        var balancedRopes = partial
        let depth = rope.height
        guard let extantRope = balancedRopes[depth] else {
            balancedRopes[depth] = rope
            return balancedRopes
        }
        
        balancedRopes[depth] = nil
        let next = appendRopeWithoutChangingHeight(extantRope, rope) ?? .node(l: extantRope, r: rope)
        return insertRopeIntoBalancer(partial: balancedRopes, rope: next)
    }
    
    fileprivate func appendRopes<T>(partial: Rope<T>?, rope: Rope<T>) -> Rope<T> {
        guard let partial = partial else { return rope }
        return .node(l: rope, r: partial)
    }
}

