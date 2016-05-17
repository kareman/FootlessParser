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
public func tuple <A,B> (_ a: A) -> (B) -> (A, B) {
    return { b in
        return (a, b)
    }
}

public func tuple <A,B,C> (_ a: A) -> (B) -> (C) -> (A, B, C) {
    return { b in { c in (a, b, c) }
    }
}

public func tuple <A,B,C,D> (_ a: A) -> (B) -> (C) -> (D) -> (A, B, C, D) {
    return { b in { c in { d in (a, b, c, d) } } }
}

public func tuple <A,B,C,D,E> (_ a: A) -> (B) -> (C) -> (D) -> (E) -> (A, B, C, D, E) {
    return { b in { c in { d in { e in (a, b, c, d, e) } } } }
}

/**
 Create a curried function of a normal function.

 Usage:
 ```
 func myFunc(a: A, b: B) -> C { ... }
 
 let parser = curry(myFunc) <^> string("hello") <*> string("world")
 ```
*/
public func curry<A,B,C>(_ f: (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

/**
 Create a curried function of a normal function.

 Usage:
 ```
 func myFunc(a: A, b: B, c: C) -> D { ... }

 let parser = curry(myFunc) <^> string("hello,") <*> string("dear") <*> string("world")
 ```
 */
public func curry<A,B,C,D>(_ f: (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in f(a, b, c) } } }
}

/**
 Create a curried function of a normal function.

 Usage:
 ```
 func myFunc(a: A, b: B, c: C, d: D) -> E { ... }

 let parser = curry(myFunc) <^> string("a") <*> string("b") <*> string("c") <*> string("d")
 ```
 */
public func curry<A, B, C, D, E>(_ f: (A, B, C, D) -> E) -> (A) -> (B) -> (C) -> (D) -> E {
    return { a in { b in { c in { d in f(a, b, c, d) } } } }
}


/**
 Create a curried function of a normal function.

 Usage:
 ```
 func myFunc(a: A, b: B, c: C, d: D) -> E { ... }

 let parser = curry(myFunc) <^> string("a") <*> string("b") <*> string("c") <*> string("d")
 ```
 */
public func curry<A, B, C, D, E, F>(_ f: (A, B, C, D, E) -> F) -> (A) -> (B) -> (C) -> (D) -> (E) -> F {
    return { a in { b in { c in { d in { e in f(a, b, c, d, e) } } } } }
}

