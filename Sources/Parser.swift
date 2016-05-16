// would've liked a generic typealias here.
public struct Parser<Token, Output> {
    public let parse: (AnyCollection<Token>) throws -> (output: Output, remainder: AnyCollection<Token>)
}

public func satisfy<T>
    (expect: String, condition: (T) -> Bool) -> Parser<T, T> {
    return Parser { input in
        if let next = input.first {
            if condition(next) {
                return (next, input.dropFirst())
            } else {
                throw Error.Mismatch(expect, String(next))
            }
        } else {
            throw Error.EOF
        }
    }
}

public func token<T: Equatable>(_ token: T) -> Parser<T, T> {
    return satisfy(expect: String(token)) { $0 == token }
}

/** Match several tokens in a row, like e.g. a string. */
public func tokens <T: Equatable, C: Collection where C.Iterator.Element == T> (_ xs: C) -> Parser<T,C> {
    let length = xs.count as! Int
    return count(length, any()) >>- { parsedtokens in
        return parsedtokens.elementsEqual(xs) ? pure(xs) : fail(.Mismatch(String(xs), String(parsedtokens)))
    }
}

/** Return whatever the next token is. */
public func any <T> () -> Parser<T,T> {
    return satisfy(expect: "anything") { T in true }
}

/** Try parser, if it fails return 'otherwise' without consuming input. */
public func optional <T,A> (_ p: Parser<T,A>, otherwise: A) -> Parser<T,A> {
    return p <|> pure(otherwise)
}

/** Delay creation of parser until it is needed. */
public func lazy <T,A> (_ f: @autoclosure(escaping)() -> Parser<T,A>) -> Parser<T,A> {
    return Parser { input in try f().parse(input) }
}

/** Apply parser once, then repeat until it fails. Returns an array of the results. */
public func oneOrMore <T,A> (_ p: Parser<T,A>) -> Parser<T,[A]> {
    return Parser { input in
        var (first, remainder) = try p.parse(input)
        var result = [first]
        while true {
            do {
                let next = try p.parse(remainder)
                result.append(next.output)
                remainder = next.remainder
            } catch {
                return (result, remainder)
            }
        }
    }
}

/** Repeat parser until it fails. Returns an array of the results. */
public func zeroOrMore <T,A> (_ p: Parser<T,A>) -> Parser<T,[A]> {
    return optional( oneOrMore(p), otherwise: [] )
}

/** Repeat parser 'n' times. If 'n' == 0 it always succeeds and returns []. */
public func count <T,A> (_ n: Int, _ p: Parser<T,A>) -> Parser<T,[A]> {
    return Parser { input in
        var input = input
        var results = [A]()
        for _ in 0..<n {
            let (result, remainder) = try p.parse(input)
            results.append(result)
            input = remainder
        }
        return (results, input)
    }
}

/**
 Repeat parser as many times as possible within the given range.
 count(2...2, p) is identical to count(2, p)
 - parameter r: A positive closed integer range.
 */
public func count <T,A> (_ r: ClosedRange<Int>, _ p: Parser<T,A>) -> Parser<T,[A]> {
    guard r.lowerBound >= 0 else { return fail(.NegativeCount) }
    return extend <^> count(r.lowerBound, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}

/**
 Repeat parser as many times as possible within the given range.
 count(2..<3, p) is identical to count(2, p)
 - parameter r: A positive half open integer range.
 */
public func count <T,A> (_ r: Range<Int>, _ p: Parser<T,A>) -> Parser<T,[A]> {
    guard r.lowerBound >= 0 else { return fail(.NegativeCount) }
    return extend <^> count(r.lowerBound, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}

/** Succeed if the next token is in the provided collection. */
public func oneOf <T: Equatable, C: Collection where C.Iterator.Element == T> (_ collection: C) -> Parser<T,T> {
    return satisfy(expect: "one of '\(String(collection))'") { collection.contains($0) }
}

/** Succeed if the next token is _not_ in the provided collection. */
public func noneOf <T: Equatable, C: Collection where C.Iterator.Element == T> (_ collection: C) -> Parser<T,T> {
    return satisfy(expect: "something not in '\(String(collection))'") { !collection.contains($0) }
}

/** Match anything but this. */
public func not <T: Equatable> (_ token: T) -> Parser<T,T> {
    return satisfy(expect: "anything but '\(token)'") { $0 != token }
}

/** Verify that input is empty. */
public func eof <T> () -> Parser<T,()> {
    return Parser { input in
        if let next = input.first {
            throw Error.Mismatch("EOF", String(next))
        }
        return ((), input)
    }
}

/** Fail with the given error message. Ignores input. */
public func fail <T,A> (_ error: Error) -> Parser<T,A> {
    return Parser { _ in throw error }
}

/**
 Parse all of input with parser.
 Failure to consume all of input will result in a ParserError.
 - parameter p: A parser.
 - parameter input: A collection, like a string or an array.
 - returns: Output from the parser.
 - throws: ParserError.
 */
public func parse<A,T>(_ p: Parser<T,A>, _ c: [T]) throws -> A {
    return try ( p <* eof() ).parse(AnyCollection(c)).output
}
