@testable import swiftrope

var r = Rope([1,2,3])
print(r.last)
r.append(contentsOf: [3, 4, 5])
r.append(contentsOf: [5, 6, 7])

r.fold({ lElt, rElt -> Int? in
    print("node left: \(lElt ?? -1), right: \(rElt ?? -1)")
    return rElt ?? lElt
}, { contents -> Int? in
    print("leaf contents: \(contents)")
    return contents.last
})

//let v: (Int, Int) = r.fold({ (l: Rope?, lResult: (Int, Int)?, r: Rope?, rResult: (Int, Int)?) -> (Int, Int) in
//    return ((lResult?.0 ?? 0) + (rResult?.0 ?? 0) + 1, (lResult?.1 ?? 0) + (rResult?.1 ?? 0))
//}, { contents -> (Int, Int) in
//    return (0, 1)
//})
