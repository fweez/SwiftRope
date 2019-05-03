//
//  RopeNode.swift
//  swiftrope
//
//  Created by Ryan Forsythe on 4/26/19.
//

class RopeNode<Element: Equatable> {
    let weight: Int
    var contents: [Element]?
    var right: RopeNode<Element>? = nil
    var left: RopeNode<Element>? = nil
    
    init(a: RopeNode<Element>, b: RopeNode<Element>) {
        contents = nil
        weight = a.weight
        left = a
        right = b
    }
    
    init<C: Collection>(_ newContents: C) where C.Element == Element {
        weight = newContents.count
        contents = Array(newContents)
    }
    
    func findNodeWithIndex(_ index: Int) -> (nodeContentsIdx: Int, node: RopeNode<Element>?) {
        if weight <= index {
            precondition(right != nil, "Index out of bounds")
            return right!.findNodeWithIndex(index - weight)
        }
        
        if let left = left {
            return left.findNodeWithIndex(index)
        }
        
        return (index, self)
    }
    
    // Split this rope into two unbalanced ropes.
    func split(at splitIndex: Int) -> (RopeNode<Element>, RopeNode<Element>?) {
        precondition(splitIndex <= weight, "Index out of bounds")
        if splitIndex == weight { return (self, nil) }
        
        
        //FIXME
        return (self, nil)
    }
}


