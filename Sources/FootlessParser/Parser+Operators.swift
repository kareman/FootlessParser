precedencegroup ApplyGroup { 
  associativity: right 
  higherThan: ComparisonPrecedence
}

precedencegroup FlatMapGroup {
  higherThan: ApplyGroup
  associativity: left
}

precedencegroup MapApplyGroup {
  higherThan: FlatMapGroup
  associativity: left
}

infix operator >>-: FlatMapGroup

/**
 FlatMap a function over a parser.
 - If the parser fails, the function will not be evaluated and the error is returned.
 - If the parser succeeds, the function will be applied to the output, and the resulting parser is run with the remaining input.
 - parameter p: A parser of type Parser<T,A>
 - parameter f: A transformation function from type A to Parser<T,B>
 - returns: A parser of type Parser<T,B>
 */
public func >>- <T,A,B> (p: Parser<T,A>, f: @escaping (A) throws -> Parser<T,B>) -> Parser<T,B> {
    return Parser { input in
        let result = try p.parse(input)
        return try f(result.output).parse(result.remainder)
    }
}


infix operator <^>: MapApplyGroup

/**
 Map a function over a parser
 - If the parser fails, the function will not be evaluated and the parser error is returned.
 - If the parser succeeds, the function will be applied to the output.
 - parameter f: A function from type A to type B
 - parameter p: A parser of type Parser<T,A>
 - returns: A parser of type Parser<T,B>
 */
public func <^> <T,A,B> (f: @escaping (A) throws -> B, p: Parser<T,A>) -> Parser<T,B> {
    return Parser { input in
        let result = try p.parse(input)
        return (try f(result.output), result.remainder)
    }
}


infix operator <*>: MapApplyGroup

/**
 Apply a parser returning a function to another parser.

 - If the first parser fails, its error will be returned.
 - If it succeeds, the resulting function will be applied to the 2nd parser.

 - parameter fp: A parser with a function A->B as output
 - parameter p: A parser of type Parser<T,A>

 - returns: A parser of type Parser<T,B>
 */
public func <*> <T,A,B> (fp: Parser<T,(A)->B>, p: Parser<T,A>) -> Parser<T,B> {
    return fp >>- { $0 <^> p }
}

infix operator <*: MapApplyGroup

/**
 Apply both parsers, but only return the output from the first one.

 - If the first parser fails, its error will be returned.
 - If the 2nd parser fails, its error will be returned.

 - returns: A parser of the same type as the first parser.
 */
public func <* <T,A,B> (p1: Parser<T,A>, p2: Parser<T,B>) -> Parser<T,A> {
    return { x in { _ in x } } <^> p1 <*> p2
}

infix operator *>: MapApplyGroup

/**
 Apply both parsers, but only return the output from the 2nd one.

 - If the first parser fails, its error will be returned.
 - If the 2nd parser fails, its error will be returned.

 - returns: A parser of the same type as the 2nd parser.
 */
public func *> <T,A,B> (p1: Parser<T,A>, p2: Parser<T,B>) -> Parser<T,B> {
    return { _ in { x in x } } <^> p1 <*> p2
}


/**
 Create a parser which doesn't consume input and returns this parameter.

 - parameter a: A value of type A
 */
public func pure <T,A> (_ a: A) -> Parser<T,A> {
    return Parser { input in (a, input) }
}


infix operator <|>: ApplyGroup 

/**
 Apply one of 2 parsers.

 - If the first parser succeeds, return its results.
 - Else if the 2nd parser succeeds, return its results.
 - If they both fail, return the failure from the parser that got the furthest.

 Has infinite lookahead. The 2nd parser starts from the same position in the input as the first one.
 */
public func <|> <T,A> (l: Parser<T,A>, r: Parser<T,A>) -> Parser<T,A> {
    return Parser { input in
        do {
            return try l.parse(input)
        } catch ParseError<T>.Mismatch(let lr, let le, let la) {
            do {
                return try r.parse(input)
            } catch ParseError<T>.Mismatch(let rr, let re, let ra) {
                if lr.count <= rr.count {
                    throw ParseError.Mismatch(lr, le, la)
                } else {
                    throw ParseError.Mismatch(rr, re, ra)
                }
            }
        }
    }
}
