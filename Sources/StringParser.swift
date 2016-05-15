//
// StringParser.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Foundation

/** Match a single character. */
public func char (_ c: Character) -> Parser<Character, Character> {
    return satisfy(expect: String(c)) { $0 == c }
}

/** Join two strings */
public func extend (_ a: String) -> (String) -> String {
    return { b in a + b }
}

/** Join a character with a string. */
//public func extend (_ a: Character) -> (String) -> String {
//    return { b in String(a) + b }
//}
public func extend (_ a: Character) -> ([Character]) -> String {
    return { b in
        return String([a] + b)
    }
}

/** Apply character parser once, then repeat until it fails. Returns a string. */
public func oneOrMore <T> (_ p: Parser<T, Character>) -> Parser<T, String> {
    return extend <^> p <*> optional( lazy(oneOrMore(p)), otherwise: [] )
}

/** Repeat character parser until it fails. Returns a string. */
public func zeroOrMore <T> (_ p: Parser<T,Character>) -> Parser<T,String> {
    return optional( oneOrMore(p), otherwise: "" )
}

/** Repeat character parser 'n' times and return as string. If 'n' == 0 it always succeeds and returns "". */
public func count <T> (_ n: Int, _ p: Parser<T,Character>) -> Parser<T,String> {
    return n == 0 ? pure("") : extend <^> p <*> count(n-1, p)
}

/**
 Repeat parser as many times as possible within the given range.
 count(2...2, p) is identical to count(2, p)
 - parameter r: A positive closed integer range.
 */
public func count <T> (_ r: ClosedRange<Int>, _ p: Parser<T,Character>) -> Parser<T,String> {
    guard r.lowerBound >= 0 else { return fail(.NegativeCount) }
    return extend <^> count(r.lowerBound, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}

/**
 Repeat parser as many times as possible within the given range.
 count(2..<3, p) is identical to count(2, p)
 - parameter r: A positive half open integer range.
 */
public func count <T> (_ r: Range<Int>, _ p: Parser<T,Character>) -> Parser<T,String> {
    guard r.lowerBound >= 0 else { return fail(.NegativeCount) }
    return extend <^> count(r.lowerBound, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}

/** Match a string. */
public func tokens (_ s: String) -> Parser<Character, String> {
    return String.init <^> tokens(s.characters)
}


/** Succeed if the next character is in the provided string. */
public func oneOf (_ s: String) -> Parser<Character,Character> {
    return oneOf(s.characters)
}

/** Succeed if the next character is _not_ in the provided string. */
public func noneOf (_ s: String) -> Parser<Character,Character> {
    return noneOf(s.characters)
}

public func char(_ set: NSCharacterSet, name: String) -> Parser<Character, Character> {
    return satisfy(expect: name) {
        return String($0).rangeOfCharacter(from: set) != nil
    }
}

/**
 Parse all of the string with parser.
 Failure to consume all of input will result in a ParserError.
 - parameter p: A parser of characters.
 - parameter input: A string.
 - returns: Output from the parser.
 - throws: A ParserError.
 */
public func parse <A> (_ p: Parser<Character, A>, _ s: String) throws -> A {
    return try (p <* eof()).parse(AnyCollection(s.characters)).output
}
