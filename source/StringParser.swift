//
// StringParser.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Result

/** Match a single character. */
public func char (c: Character) -> Parser<Character, Character> {
	return satisfy(expect: String(c)) { $0 == c }
}

/** Join two strings */
public func extend (a: String) (b: String) -> String {
	return a + b
}

/** Join a character with a string. */
public func extend (a: Character) (b: String) -> String {
	return String(a) + b
}

/** Apply character parser once, then repeat until it fails. Returns a string. */
public func oneOrMore <T> (p: Parser<T,Character>) -> Parser<T,String> {
	return extend <^> p <*> optional( lazy(oneOrMore(p)), otherwise: "" )
}

/** Repeat character parser until it fails. Returns a string. */
public func zeroOrMore <T> (p: Parser<T,Character>) -> Parser<T,String> {
	return optional( oneOrMore(p), otherwise: "" )
}

/** Repeat character parser 'n' times and return as string. If 'n' == 0 it always succeeds and returns "". */
public func count <T> (n: Int, _ p: Parser<T,Character>) -> Parser<T,String> {
	return n == 0 ? pure("") : extend <^> p <*> count(n-1, p)
}

/**
Repeat parser as many times as possible within the given range.

count(2...2, p) is identical to count(2, p)

- parameter r: A positive integer range.
*/
public func count <T> (r: Range<Int>, _ p: Parser<T,Character>) -> Parser<T,String> {
	if r.startIndex < 0 { return fail("count(\(r)): range cannot be negative.") }
	return extend <^> count(r.startIndex, p) <*> ( count(r.count-1, p) <|> zeroOrMore(p) )
}

/** Match a string. */
public func tokens (s: String) -> Parser<Character,String> {
	return { String($0) } <^> tokens(s.characters)
}

/** Succeed if the next character is in the provided string. */
public func oneOf (s: String) -> Parser<Character,Character> {
	return oneOf(s.characters)
}

/** Succeed if the next character is _not_ in the provided string. */
public func noneOf (s: String) -> Parser<Character,Character> {
	return noneOf(s.characters)
}

/**
Parse all of the string with parser.

Failure to consume all of input will result in a ParserError.

- parameter p: A parser of characters.
- parameter input: A string.
- returns: Output from the parser.
- throws: A ParserError.
*/
public func parse <A> (p: Parser<Character,A>, _ s: String) throws -> A {
	let result: Result<A,ParserError> = ( p <* eof() ).parse(ParserInput(s.characters)) >>- { .Success($0.output) }
	return try result.dematerialize()
}
