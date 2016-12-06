//
// Converters.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

/** Return a collection containing x and all elements of xs. Works with strings and arrays. */
public func extend
    <A, C: RangeReplaceableCollection where C.Iterator.Element == A>
    (_ xs: C) -> (A) -> C {
    var result = xs
    return { x in
        // not satisfied with this way of doing it, but RangeReplaceableCollectionType has only mutable methods.
        result.append(x)
        return result
    }
}

/** Return a collection containing x and all elements of xs. Works with strings and arrays. */
public func extend
    <A, C: RangeReplaceableCollection where C.Iterator.Element == A>
    (_ x: A) -> (C) -> C {
    var result = C()
    result.append(x)
    return { xs in
        // not satisfied with this way of doing it, but RangeReplaceableCollectionType has only mutable methods.
        result.append(contentsOf: xs)
        return result
    }
}

/** Join 2 collections together. */
public func extend
    <C1: RangeReplaceableCollection, C2: Collection where C1.Iterator.Element == C2.Iterator.Element>
    (_ xs1: C1) -> (C2) -> C1 {
    var xs1 = xs1
    return { xs2 in
        xs1.append(contentsOf: xs2)
        return xs1
    }
}

/** Create a tuple of the arguments. */
public func tuple <A,B> (_ a: A) -> (B) -> (A,B) {
    return { b in
        return (a, b)
    }
}

public func tuple <A,B,C> (_ a: A) -> (B) -> (C) -> (A,B,C) {
    return { b in
        return { c in return (a, b, c) }
    }
}
