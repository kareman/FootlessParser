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
public func extend (_ a: Character) -> (String) -> String {
    return { b in String(a) + b }
}

/** Apply character parser once, then repeat until it fails. Returns a string. */
public func oneOrMore <T> (_ p: Parser<T, Character>) -> Parser<T, String> {
    return extend <^> p <*> optional( lazy(oneOrMore(p)), otherwise:"" )
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
    precondition(r.lowerBound >= 0, "Count must be >= 0")
    return extend <^> count(r.lowerBound, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}

/**
 Repeat parser as many times as possible within the given range.
 count(2..<3, p) is identical to count(2, p)
 - parameter r: A positive half open integer range.
 */
public func count <T> (_ r: Range<Int>, _ p: Parser<T,Character>) -> Parser<T,String> {
    precondition(r.lowerBound >= 0, "Count must be >= 0")
    return extend <^> count(r.lowerBound, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}

/**
 Match a string
 - parameter: string to match
 - note: consumes either the full string or nothing, even on a partial match.
 */
public func string (_ s: String) -> Parser<Character, String> {
    let count = s.count
    return Parser { input in
        guard input.startIndex < input.endIndex else {
            throw ParseError.Mismatch(input, s, "EOF")
        }
        guard let endIndex = input.index(input.startIndex, offsetBy:Int64(count), limitedBy: input.endIndex) else {
            throw ParseError.Mismatch(input, s, String(input))
        }
        let next = input[input.startIndex..<endIndex]
        if s.elementsEqual(next) {
            return (s, input.dropFirst(count))
        } else {
            throw ParseError.Mismatch(input, s, String(next))
        }
    }
}


/** Succeed if the next character is in the provided string. */
public func oneOf (_ s: String) -> Parser<Character,Character> {
    return oneOf(Set(s))
}

/** Succeed if the next character is _not_ in the provided string. */
public func noneOf (_ s: String) -> Parser<Character,Character> {
    return noneOf(Set(s))
}

/**
 Produces a character if the character and succeeding do not match any of the strings.
 - parameter: strings to _not_ match
 - note: consumes only produced characters
 */
public func noneOf(_ strings: [String]) -> Parser<Character, Character> {
    return Parser { input in
        guard let next = input.first else {
            throw ParseError.Mismatch(input, "anything but \(strings)", "EOF")
        }
        for string in strings {
            guard string.first == next else { continue }
            let offset = Int64(string.count)
            guard Int64(input.count) >= offset else { continue }
            let endIndex = input.index(input.startIndex, offsetBy: offset)
            guard endIndex <= input.endIndex else { continue }
            let peek = input[input.startIndex..<endIndex]
            if string.elementsEqual(peek) { throw ParseError.Mismatch(input, "anything but \(string)", string) }
        }
        return (next, input.dropFirst())
    }
}

public func char(_ set: CharacterSet, name: String) -> Parser<Character, Character> {
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
    return try (p <* eof()).parse(AnyCollection(s)).output
}

public func print(error: ParseError<Character>, in s: String) {
    if case ParseError<Character>.Mismatch(let remainder, let expected, let actual) = error {
        let index = s.index(s.endIndex, offsetBy: -Int(remainder.count))
        let (lineRange, row, pos) = position(of: index, in: s)
        let line = s[lineRange.lowerBound..<lineRange.upperBound].trimmingCharacters(in: CharacterSet.newlines)

        print("An error occurred when parsing this line:")
        print(line)
        print(String(repeating: " ", count: pos - 1) + "^")
        print("\(row):\(pos) Expected '\(expected)', actual '\(actual)'")
    }
}

func position(of index: Substring.Index, in string: String) -> (line: Range<Substring.Index>, row: Int, pos: Int) {
    var head = string.startIndex..<string.startIndex
    var row = 0
    while head.upperBound <= index {
        head = string.lineRange(for: head.upperBound..<head.upperBound)
        row += 1
    }
    return (head, row, string.distance(from: head.lowerBound, to: index) + 1)
}
