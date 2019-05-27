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
        return getLeafContents(rope) // FIXME: I should do the leaf resizing in one function and emit leaves, instead of re-creating all leaves
            .reduce([], splitAndConcatFn(minLeafSize, maxLeafSize))
            .map { .leaf(contents: $0) }
            .reduce([:], insertRopeIntoBalancer)
            .sorted { $0.key < $1.key }
            .map { $0.value }
            .reduce(nil, appendRopes)
    }
    
    fileprivate func getLeafContents<T>(_ rope: Rope<T>) -> [[T]] {
        return rope.fold(
            { ($0 ?? []) + ($1 ?? []) },
            { [$0] })
    }
    
    fileprivate func splitAndConcatFn<T>(_ minLeafSize: Int, _ maxLeafSize: Int) -> ([[T]], [T]) -> [[T]] {
        return { accum, contents in
            let last = accum.last ?? []
            let fullContents: [T]
            let remainder: [[T]]
            if last.count > 0 && last.count >= minLeafSize {
                fullContents = contents
                remainder = accum
            } else {
                fullContents = last + contents
                remainder = Array(accum.prefix(Swift.max(0, accum.count - 1)))
            }
            
            return remainder + stride(from: 0, to: fullContents.count, by: maxLeafSize)
                .map { Range(uncheckedBounds: ($0, Swift.min($0 + maxLeafSize, fullContents.count))) }
                .map { Array(fullContents[$0.startIndex..<$0.endIndex]) }
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

